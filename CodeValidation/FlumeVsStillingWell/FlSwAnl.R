## Check differences between flume and velocity area calculations of discharge

library(reshape2)
library(ggplot2)
library(sf)
## library(rgeos)
## library(sp)
## library(gpclib) # polygon clipping operations
### library(shapefiles)

importdata <- function(flnm){
    x <- do.call("rbind", lapply(flnm, read.csv, skip=8, header=FALSE, strip.white = TRUE, blank.lines.skip = TRUE, stringsAsFactors = FALSE))
    names(x)<- c("scan", "date", "time", "capacitance", "stage")
    x <- x[!is.na(x$date),]
    x$date <- as.Date(x$date, format = "%d/%m/%Y") 
    x <- transform(x, timestamp = paste(date, time, sep=' '))
    x <- x[!is.na(x$date),]
    x$timestamp <- as.POSIXct(x$timestamp, tz = "Asia/Kolkata")
    return(x)
}

getlm <- function(x){
    ##x is calibration file name, y = wlr file name
    calibdat <- read.csv(x, header=FALSE, sep=",", col.names=c("stage", "capacitance"), skip=6)
    if(max(calibdat$stage, na.rm = TRUE) > 5) calibdat$stage <- calibdat$stage/100 # convert to meters when calibration is done in cm
    fitlm <- lm(stage ~ capacitance, data = calibdat)
    print(tail(calibdat))
    print(summary(fitlm))
    return(fitlm) 
}

getlm.brass <- function(x){
    ##x is calibration file name, y = wlr file name
    calibdat <- read.csv(x, header=FALSE, sep=",", col.names=c("stage", "capacitance"), skip=6)
    if(max(calibdat$stage, na.rm = TRUE) > 5) calibdat$stage <- calibdat$stage/100 # convert to meters when calibration is done in cm
    calibdat$material[calibdat$stage>0.055] <- "Teflon"
    calibdat$material[calibdat$stage<=0.055] <- "Brass"
    fitlm <- lm(stage ~ capacitance*material, data = calibdat)
    cutoff<<-min(calibdat$capacitance[calibdat$material=="Teflon"])
    print(tail(calibdat))
    print(summary(fitlm))
    return(fitlm)
}

do.wlr.cal <- function(x, y){
    y$stagecalc <- predict(x, y)
    return(y)
}

calc.disch.areastage <- function(x, y){
    ## x is sw data, y is sd curve
    ## sd <- read.csv(y) # "~/Res/CWC/Data/Nilgiris/cleaned.rating/csv/WLR_107_SD.csv")
    sd <- y[,c("stage", "avg.disch")]
    names(sd) <- c("Stage", "Discharge")
    ## sd$Discharge <- sd$Discharge*0.13 # TBD Correction factor averages to about 0.28
    nls.res <- nls(Discharge~p1*Stage^p3, data=sd, start=list(p1=3,p3=5), control = list(maxiter = 500)) # (p1=3,p3=5)
    coef.p1 <- as.numeric(coef(nls.res)[1])
    coef.p3 <- as.numeric(coef(nls.res)[2])
    x <- x[, c("capacitance", "stagecalc", "timestamp")]
    names(x) <- c("Capacitance", "Stage", "Timestamp")
    x$Discharge <- coef.p1*x$Stage^coef.p3
    return(x)
}

## x <- paste0(data.dir, "./flume_stage_correction/wlr_110.csv")
fix.flume.stage <- function(x, y){ # correct for height difference between capacitance probe in flume and manual measurements
    ## x is manual flume readings y is the flume wlr with calibrated stages
    x$dt.round <- as.POSIXct(round(as.double(x$timestamp)/(15*60))*(15*60),origin=(as.POSIXct('1970-01-01')))
    dat <- read.csv(y)
    dat$Height <- dat$Height/100 # convert to metres
    dat$Timestamp <- as.POSIXct(dat$Timestamp, tz = "Asia/Kolkata", format = "%d/%m/%y %H:%M")
    dat$dt.round <- as.POSIXct(round(as.double(dat$Timestamp)/(15*60))*(15*60),origin=(as.POSIXct('1970-01-01')))
    merged <- merge(dat, x, by = "dt.round")
    merged$stgfix <- merged$stagecalc-merged$Height
    avg.fix <- mean(merged$stgfix, na.rm = TRUE)
    x$stagecalc <- x$stagecalc-avg.fix
    return(x[,-8])
}

## calculate discharge of a two inch montana flume
## x is flume data 
calc.disch.flume <- function(x){
    x <- x[,c("capacitance", "stagecalc", "timestamp")]
    names(x) <- c("Capacitance", "Stage", "Timestamp")
    ##    x["Stage"] <- x["Stage"]
    ## y <- y[!is.na(y$Stage),]
    ## p1 <- 176.5 ## <https://www.openchannelflow.com/flumes/montana-flumes/discharge-tables>
    ## p3 <- 1.55
    # for 2 inch flume: 120.7*H^1.55 for 3 inch: 176.5*H^1.55
    p1 <- 176.5
    p3 <- 1.55
    x$Discharge <- p1*(x$Stage)^p3*0.001 # in m cube per sec
    return(x)
}

intersect.xsec <- function(x,y){ #intersect cross section with velocity reading regions
    ## function used by vel.area to export shape files
    rec <- list(x)
    rec <- st_polygon(rec)
    int <- st_intersection(xsec, rec)
    int.st <- st_as_sfc(st_as_text(int))
    st_write(int.st, paste0(y, ".shp"), driver = "ESRI Shapefile", delete_dsn= TRUE)
    return(st_area(int))
}

vel.area <- function(x, y){    
    ## calculate stage discharge using v/a method x is list of xsec files y is list of vel readings
    if(basename(x)==basename(y)){
        crd <- read.csv(x, header = TRUE, skip = 5)[,-1]
        vel <- read.csv(y, header = TRUE, skip = 5)
        obs.file <- gsub(".csv| ", "", basename(x))
        site <- strsplit(x, split="/")[[1]][5]
        print(paste0(site, ": ", obs.file))
        out.dir.name <- paste0(output.dir, "cx_shapefiles/", site)
        if(!dir.exists(out.dir.name))dir.create(out.dir.name)
        out.nm <- paste0(out.dir.name, "/", obs.file)
        crd <- crd/100 # convert to metres
        if(crd[1,1] != 0 | crd[1,2] != 0) crd <- rbind(c(0,0),crd) ## add row of 0,0 if missing
        crd <- rbind(crd, c(0,0))
        ## crd <- rbind(crd, crd[1,])
        crd[ , 2] <- crd[ , 2]*-1 # covert y values to negative (depth)
        crd.mat <- as.matrix(crd)
        xsec <<- st_polygon(list(crd.mat))
        xsec.st <- st_as_sfc(st_as_text(xsec)) # convert to wkt then sfc
        st_write(xsec.st, paste0(out.nm, "crossec.shp"), driver = "ESRI Shapefile", delete_dsn= TRUE) # write to shapefile        
        ## st_area(xsec)
        plot(xsec)
        divs <- length(unique(gsub("[[:digit:]]", "", vel$Sl.No.))) # number of divisions of xsec
        seg.ln <- max(crd$Length, na.rm = T)
        seg.ht <- min(crd$Depth, na.rm = T)
        bbx <- paste(seq(0, seg.ln, length.out = divs+1), seg.ht, sep = ",")
        cl1 <- seq(0, seg.ln, length.out = divs+1)
        cl2 <- rep(seg.ht,divs+1)
        bbx <- matrix(c(cl1,cl2), nrow=length(cl1))
        st <- seq(1, nrow(bbx)-1, by=1)
        rec <- lapply(st, function(x){
            y <- x+1
            r1 <- bbx[x,]
            r2 <- bbx[y,]
            r3 <- cbind(bbx[y,1], 0)
            r4 <- cbind(bbx[x,1], 0)
            r5 <- bbx[x,]
            return(rbind(r1,r2,r3, r4, r5))
        })
        rec.ln <- paste0(out.nm, "RecNo_",1:length(rec)) # suffix of shapefile
        sx.area <- mapply(intersect.xsec, rec, rec.ln) # export to shapefile   
        vel$secno <- gsub("[[:digit:]]", "", vel$Sl.No.)
        vel <- aggregate(cbind(velR1, velR2, velR3) ~ secno, data=vel, FUN=mean)
        avg.vel <- as.list(apply(vel,1, function(x) mean(as.numeric(x[2:4]))))
        avg.disch <- sum(mapply(prod, sx.area, avg.vel)) # multiply each velocity with each xsec and add
        xsec.depth.m <- seg.ht*-1
        ## get timestamp of velocity readings
        vel.dt <- as.Date(read.csv(y, skip=1,nrows=1, header=F)[,c(2)], format = "%d/%m/%y")
        vel.tm <- read.csv(y, skip=2,nrows=1, header=F)[,c(2)]
        vel.dt.tm <- paste(vel.dt, vel.tm, sep=' ')
        timestamp <- as.POSIXct(vel.dt.tm, format="%Y-%m-%d %I:%M:%S %p", tz="Asia/Kolkata") 
        res.df <- data.frame(site, obs.file, timestamp, avg.disch, xsec.depth.m)
        return(res.df)
    } else {
        print("ERROR: File names differ.")
    }
}

get.stage <- function(x, y){
    ## use the timestamp on the vel.area file to get stage and append. X is stage discharge points, y is wlr stage.
    ## use list.files to get x and y.
    ## x is stage discharge file (s.d.pts) y is names(s.d.pts)
    ## sd <- read.csv(x)
    pat <- paste0(y, "_15 min.csv")
    fn <- list.files(path ="~/Res/CWC/Data/Nilgiris/wlr/csv/", pattern = pat, full.names = TRUE )
    wlr <- read.csv(fn)
    x$timestamp <- as.POSIXct(x$timestamp, tz = "Asia/Kolkata")
    ## wlr <- read.csv(y)
    wlr$date_time <- as.POSIXct(wlr$date_time, tz = "Asia/Kolkata")
    x$dt.round <- as.POSIXct(round(as.double(x$timestamp)/(15*60))*(15*60),origin=(as.POSIXct('1970-01-01')))
    wlr$dt.round <- as.POSIXct(round(as.double(wlr$date_time)/(15*60))*(15*60),origin=(as.POSIXct('1970-01-01')))
    merged.df <- merge(x, wlr, by = "dt.round")
    merged.df <- merged.df[complete.cases(merged.df),]
    merged.df <- merged.df[,c("site", "obs.file", "timestamp", "avg.disch", "xsec.depth.m", "raw", "cal", "date_time")]
    names(merged.df) <- c("site", "obs.file", "vel.timestamp", "avg.disch", "xsec.depth", "scan", "stage", "wlr.timestamp") 
    return(merged.df)
}


plot.discharges <- function(x, y, nms){
    x$Timestamp <- as.POSIXct(round(as.double(x$Timestamp)/(15*60))*(15*60),origin=(as.POSIXct('1970-01-01')))
    y$Timestamp <- as.POSIXct(round(as.double(y$Timestamp)/(15*60))*(15*60),origin=(as.POSIXct('1970-01-01')))
    ## y$Discharge <- y$Discharge*10
    merged <- merge(x, y, by = "Timestamp")
    merged$group <- c(0, cumsum(diff(as.Date(merged$Timestamp)) > 1))
    names(merged) <- c("Timestamp", "Capacitance.sw", "Stage.sw", "Discharge.sw", "Capacitance.fl", "Stage.fl", "Discharge.fl", "Group")
    ggdat <- melt(merged, value.name = "Discharge", measure.vars = c("Discharge.sw", "Discharge.fl"), id.vars = c("Timestamp", "Group"))
    ggp <- ggplot(data = ggdat, aes(x = Timestamp, y = Discharge, colour = variable))+
        facet_wrap(~ Group, scales = "free") +
        geom_line()
    print(ggp)
    ggsave(paste0(output.dir, "discharge/figures/", nms, ".png"))
    return(merged)
}

## Provide file locations

input.dir <- "./Data/input/"
output.dir <- "./Data/output/"

## xsec.dir <- paste0(data.dir, "cx/")
## vel.dir <- paste0(data.dir, "pyg/")
## sd.res.dir <- paste0(data.dir, "sd_res_pyg/")

## nil.data.dir <- "~/Res/CWC/Data/Nilgiris/rating/"
## xsec.dir <- paste0(nil.data.dir, "cx_pyg/wlr_107/")
## vel.dir <- paste0(nil.data.dir, "pyg/wlr_107/")

##------**----------##

##----- calculate the stage using lm

##--- for stilling well or wlr

in.wlr.dir <- list.dirs(paste0(input.dir, "wlr"), recursive = FALSE)
in.wlr.files <- lapply(in.wlr.dir, list.files, full.names = TRUE)
names(in.wlr.files) <- basename(in.wlr.dir)
## wlr.raw <- "./Data/raw/wlr_107/WLR107_107_080_31_01_2018.CSV"
## wlr.raw <- list.files("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_107/", full.names = TRUE)
## stillwell <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_107/WLR107_107_067_25_04_2017.CSV")
## stillwell <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_107/WLR107_107_065_25_02_2017.CSV")
## stillwell <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_107/WLR107_107_066_28_03_2017.CSV")
stillwell <- lapply(in.wlr.files, importdata)
##importdata(in.wlr)

## lm.stillwell <- getlm("/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib2017/wlr_107.csv")
## stillwell$stagecalc <- predict(lm.stillwell, stillwell)
in.cal.files <- list.files(paste0(input.dir, "calib"), full.names = TRUE)
lm.stillwell <- lapply(in.cal.files, getlm)
names(lm.stillwell) <- basename(in.wlr.dir)
stillwell <- mapply(do.wlr.cal, lm.stillwell, stillwell, SIMPLIFY = FALSE)


##---- repeat for flume
## flnm <- list.files("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_110/", full.names = TRUE)
## flnm <- "./Data/raw/wlr_110/WLR110_110_040_31_01_2018.CSV"
## flume <- importdata(flnm)
## flume <- flume[flume$Timestamp<"2014-01-23 12:26:14",] # data after this date is shot to hell
## flume <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_110/WLR110_110_036_25_04_2017.CSV")
## flume <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_110/WLR110_110_034_25_02_2017.CSV")
## flume <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_110/WLR110_110_035_28_03_2017.CSV")
## lm.flume <- getlm("/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib2017/wlr_110_calib_30012018.csv")
## flume$stagecalc <- predict(lm.flume, flume)
## head(flume)
## tmp.fix <- 0.2000258-.153 # use for testing only
## flume$stagecalc <- flume$stagecalc-tmp.fix
## head(flume)
## head(stillwell)

## TBD: write code to take the manual measurements of VA method and compare with flume



##-- Do velocity area calculations

## xsec.fls <- list.files(xsec.dir, full.names = TRUE)
## xsec.fls <- "./Data/cx/31jan2018.csv" # for testing

in.xsec.dir <- list.dirs(paste0(input.dir, "xsec"), recursive = FALSE)
xsec.fls <- lapply(in.xsec.dir, list.files, full.names = TRUE)

## vel.fls <- list.files(vel.dir, full.names = TRUE)
## vel.fls <- "./Data/pyg/31jan2018.csv" # for testing
in.vel.dir <- list.dirs(paste0(input.dir, "vel"), recursive = FALSE)
vel.fls <- lapply(in.vel.dir, list.files, full.names = TRUE)

xsec.vel.dirs <- data.frame(in.xsec.dir, in.vel.dir , stringsAsFactors = FALSE)

s.d.pts <- apply(xsec.vel.dirs, 1,  function(x){
    xsec <- lapply(as.character(x["in.xsec.dir"]), list.files, full.names = TRUE)
    xsec <- unlist(xsec)
    vel <- lapply(as.character(x["in.vel.dir"]), list.files, full.names = TRUE)
    vel <- unlist(vel)
    s.d.pts <- do.call("rbind", mapply(vel.area, xsec, vel, SIMPLIFY = FALSE, USE.NAMES = FALSE))
    return(s.d.pts)
})
## names(s.d.pts) <- basename(in.xsec.dir)

mapply(function(x, y) write.csv(x, file = paste0(output.dir, "rating/", y, ".csv"), row.names = FALSE),
       x = s.d.pts,
       y = basename(in.xsec.dir))

##------ merge the stage from wlr with the vel-area using timestamp 

## sd.file <- "~/Res/CWC/Data/Nilgiris/cleaned.rating/csv/WLR_107_SD.csv"
## sd.file <- paste0(sd.res.dir,"wlr_107_SD.csv")
if(!exists("s.d.pts")) s.d.pts <- lapply(list.files(paste0(output.dir, "rating/"), full.names = TRUE), read.csv)
names(s.d.pts) <- basename(in.xsec.dir)
s.d.pts <- mapply(get.stage, s.d.pts, names(s.d.pts), SIMPLIFY = FALSE)
mapply(function(x, y) write.csv(x, file = paste0(output.dir, "rating/", y, ".csv")),
       x = s.d.pts,
       y = basename(in.xsec.dir))
if(!exists("s.d.pts")) s.d.pts <- lapply(list.files(paste0(output.dir, "rating/"), full.names = TRUE), read.csv)

xsec.vel.data <- mapply(calc.disch.areastage,
                        x = stillwell[names(stillwell) %in% names(s.d.pts)],
                        y = s.d.pts, SIMPLIFY = FALSE)

flume.names <- c("wlr_110", "wlr_111", "wlr_112", "wlr_113")
flume.data <- mapply(fix.flume.stage,
                     y = list.files(paste0(input.dir, "flume_stage_correction"), full.names = TRUE),
                     x = stillwell[names(stillwell) %in% flume.names], SIMPLIFY = FALSE)
flume.data <- lapply(flume.data, calc.disch.flume)


## calc.disch.areastage(x = stillwell, y = sd.file)
## wlr.15.min <- lapply(list.files(path = "~/Res/CWC/Data/Nilgiris/wlr/csv/", pattern = "*_15 min.csv", full.names = TRUE), read.csv)
## ## list.files(path = "~/Res/CWC/Data/Nilgiris/wlr/csv/", pattern = "*_15 min.csv")

## ## ## read.matched.files <- function(x){
## ## ##     pat <- paste0(x, "_15 min.csv")
## ## ##     fn <- list.files(path ="~/Res/CWC/Data/Nilgiris/wlr/csv/", pattern = pat, full.names = TRUE )
## ## ##     return(read.csv(fn))
## ## ## }

## read.matched.files(basename(in.xsec.dir))

## sd.file <-  paste0(sd.res.dir,"wlr_107_SD.csv")
## wlr.15min <- "~/Res/CWC/Data/Nilgiris/wlr/csv/wlr_107_15 min.csv"
## write.csv(get.stage(sd.file, wlr.15min), sd.file) # overwrite x with file including stage

##----- calculate the discharge using area-stage

## stillwell <- calc.disch.areastage(x = stillwell, y = sd.file)
## do this for flume here
## flume <- calc.disch.flume(flume)


nms <- mapply(paste, names(xsec.vel.data), sub(".csv", "", basename(names(flume.data))), sep = "_")
xsec.val.merged <- mapply(plot.discharges, xsec.vel.data, flume.data, nms)

## merged <- merge(stillwell, flume, by = "Timestamp")
## names(merged) <- c("Timestamp", "Capacitance.sw", "Stage.sw", "Discharge.sw", "Capacitance.fl", "Stage.fl", "Discharge.fl")
##-- next few lines are fiddling with the results to see where the error is coming from##
## merged$Discharge.sw <- merged$Discharge.sw*0.28

## ggdat <- melt(merged, value.name = "Discharge", measure.vars = c("Discharge.sw", "Discharge.fl"), id.vars = "Timestamp")

## ggdat$seq <- seq_along(!is.na(ggdat$Discharge)))

## ggplot(data = ggdat, aes(x = Timestamp, y = Discharge, colour = variable))+
##  geom_line()
    


## g <- ggplot(data.frame(Time, Value, Group)) + 
##   geom_line (aes(x=Time, y=Value)) +
##   facet_grid(~ Group, scales = "free_x")


##--- This section is to see whether there is a difference in the amplitude of diurnal signals between the flume (110) and stilling well (107)

## accounting for brass
## lm.stillwell <- getlm.brass("/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib2017/wlr_107_calib_15122017.csv")
## stillwell$material[stillwell$capacitance<cutoff] <- "Brass"
## stillwell$material[stillwell$capacitance>=cutoff] <- "Teflon"
## stillwell$stagecalc <- predict(lm.stillwell, stillwell)

## merged <- merge(stillwell, flume, by = "Timestamp")[,c("Timestamp", "Capacitance.x", "Stage.x", "Capacitance.y", "Stage.y")] # 1, 5, 7, 11, 13)]
## names(merged) <- c("timestamp", "cap.sw", "stage.sw", "cap.fl", "stage.fl")
## ggdat <- melt(merged, value.name = "Stage", measure.vars = c("stage.sw", "stage.fl"), id.vars = "timestamp")
## ggplot(data = ggdat, aes(x = timestamp, y = Stage, colour = variable))+
##         geom_line()

## calculate the daily amplitude of stage and discharge for stillingwell and flume

###---for trial to be deleted


getlmraw <- function(x){ #x is calibration file name, y = wlr file name
    calibdat <- read.csv(x, header=FALSE, sep=",", col.names=c("stage", "capacitance"), skip=6)
    ## if(max(calibdat$stage>10, na.rm = TRUE)) calibdat$stage <- calibdat$stage/100 # convert to meters
    fitlm <- lm(stage ~ capacitance, data = calibdat)
    print(calibdat)
    return(fitlm)
}

x <- "/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib2017/wlr_102A_calib_10122017.csv"
flume <- read.csv(x, header=FALSE, sep=",", col.names=c("stage", "capacitance"), skip=6)
lm.flume <- getlm("/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib2017/wlr_102A_calib_10122017.csv")
lmraw.flume <- getlmraw("/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib2017/wlr_102A_calib_10122017.csv")
flume$stagecalc <- predict(lm.flume, flume)
flume$stagecalcraw <- predict(lmraw.flume, flume)
head(flume)
tail(flume)
