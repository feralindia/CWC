library(sf)
library(reshape2)
library(ggplot2)

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
  calibdat <- read.csv(x, header=FALSE, sep=",", col.names=c("stage", "capacitance"), skip=6)
  if(max(calibdat$stage, na.rm = TRUE) > 5) calibdat$stage <- calibdat$stage/100 # convert to meters when calibration is done in cm
  fitlm <- lm(stage ~ capacitance, data = calibdat)
  print(tail(calibdat))
  print(summary(fitlm))
  return(fitlm) 
}

getlm.brass <- function(x){
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

intersect.xsec <- function(x,y){ 
  rec <- list(x)
  rec <- st_polygon(rec)
  int <- st_intersection(xsec, rec)
  int.st <- st_as_sfc(st_as_text(int))
  st_write(int.st, paste0(y, ".shp"), driver = "ESRI Shapefile", delete_dsn= TRUE)
  return(st_area(int))
}

vel.area <- function(x, y){    
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
  pat <- paste0(y, "_15 min.csv")
  fn <- list.files(path ="~/Res/CWC/Data/Nilgiris/wlr/csv/", pattern = pat, full.names = TRUE )
  wlr <- read.csv(fn)
  x$timestamp <- as.POSIXct(x$timestamp, tz = "Asia/Kolkata")
  wlr$date_time <- as.POSIXct(wlr$date_time, tz = "Asia/Kolkata")
  x$dt.round <- as.POSIXct(round(as.double(x$timestamp)/(15*60))*(15*60),origin=(as.POSIXct('1970-01-01')))
  wlr$dt.round <- as.POSIXct(round(as.double(wlr$date_time)/(15*60))*(15*60),origin=(as.POSIXct('1970-01-01')))
  merged.df <- merge(x, wlr, by = "dt.round")
  merged.df <- merged.df[complete.cases(merged.df),]
  merged.df <- merged.df[,c("site", "obs.file", "timestamp", "avg.disch", "xsec.depth.m", "raw", "cal", "date_time")]
  names(merged.df) <- c("site", "obs.file", "vel.timestamp", "avg.disch", "xsec.depth", "scan", "stage", "wlr.timestamp") 
  return(merged.df)
}

calc.disch.areastage <- function(x, y){
  sd <- y[,c("stage", "avg.disch")]
  names(sd) <- c("Stage", "Discharge")
  nls.res <- nls(Discharge~p1*Stage^p3, data=sd, start=list(p1=3,p3=5), control = list(maxiter = 500)) # (p1=3,p3=5)
  coef.p1 <- as.numeric(coef(nls.res)[1])
  coef.p3 <- as.numeric(coef(nls.res)[2])
  x <- x[, c("capacitance", "stagecalc", "timestamp")]
  names(x) <- c("Capacitance", "Stage", "Timestamp")
  x$Discharge <- coef.p1*x$Stage^coef.p3
  return(x)
}

fix.flume.stage <- function(x, y){
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

calc.disch.flume <- function(x){
  x <- x[,c("capacitance", "stagecalc", "timestamp")]
  names(x) <- c("Capacitance", "Stage", "Timestamp")
  p1 <- 176.5
  p3 <- 1.55
  x$Discharge <- p1*(x$Stage)^p3*0.001 # in m cube per sec
  return(x)
}

plot.discharges <- function(x, y, nms){
  x$Timestamp <- as.POSIXct(round(as.double(x$Timestamp)/(15*60))*(15*60),origin=(as.POSIXct('1970-01-01')))
  y$Timestamp <- as.POSIXct(round(as.double(y$Timestamp)/(15*60))*(15*60),origin=(as.POSIXct('1970-01-01')))
  merged <- merge(x, y, by = "Timestamp")
  merged$group <- c(0, cumsum(diff(as.Date(merged$Timestamp)) > 1))
  names(merged) <- c("Timestamp", "Capacitance.sw", "Stage.sw", "Discharge.sw", "Capacitance.fl", "Stage.fl", "Discharge.fl", "Group")
  ggdat <- melt(merged, value.name = "Discharge", measure.vars = c("Discharge.sw", "Discharge.fl"), id.vars = c("Timestamp", "Group"))
  ggp <- ggplot(data = ggdat, aes(x = Timestamp, y = Discharge, colour = variable))+
    facet_wrap(~ Group, scales = "free") +
    geom_line()
  print(ggp)
  ggsave(filename = paste0(output.dir, "discharge/figures/", nms, ".png"), plot = ggp)
  return(merged)
 }

setwd("./")
if(!dir.exists("./Data"))unzip("DataSets.zip")

input.dir <- "./Data/input/"
output.dir <- "./Data/output/"

in.wlr.dir <- list.dirs(paste0(input.dir, "wlr"), recursive = FALSE)
in.wlr.files <- lapply(in.wlr.dir, list.files, full.names = TRUE)
names(in.wlr.files) <- basename(in.wlr.dir)
stillwell <- lapply(in.wlr.files, importdata)
head(stillwell[[1]])

in.cal.files <- list.files(paste0(input.dir, "calib"), full.names = TRUE)
lm.stillwell <- lapply(in.cal.files, getlm)
names(lm.stillwell) <- basename(in.wlr.dir)
stillwell <- mapply(do.wlr.cal, lm.stillwell, stillwell, SIMPLIFY = FALSE)
head(stillwell[[2]])

in.xsec.dir <- list.dirs(paste0(input.dir, "xsec"), recursive = FALSE)
 xsec.fls <- lapply(in.xsec.dir, list.files, full.names = TRUE)
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
 mapply(function(x, y) write.csv(x, file = paste0(output.dir, "rating/", y, ".csv"), row.names = FALSE),
   x = s.d.pts,
   y = basename(in.xsec.dir))
head(s.d.pts[[1]])

if(!exists("s.d.pts")) s.d.pts <- lapply(list.files(paste0(output.dir, "rating/"), full.names = TRUE), read.csv)
names(s.d.pts) <- basename(in.xsec.dir)
s.d.pts <- mapply(get.stage, s.d.pts, names(s.d.pts), SIMPLIFY = FALSE)
mapply(function(x, y) write.csv(x, file = paste0(output.dir, "rating/", y, ".csv"), row.names = FALSE),
  x = s.d.pts,
  y = basename(in.xsec.dir))
if(!exists("s.d.pts")) s.d.pts <- lapply(list.files(paste0(output.dir, "rating/"), full.names = TRUE), read.csv)
xsec.vel.data <- mapply(calc.disch.areastage, x = stillwell[names(stillwell) %in% names(s.d.pts)], y = s.d.pts, SIMPLIFY = FALSE)

flume.names <- c("wlr_110", "wlr_111", "wlr_112", "wlr_113")
flume.data <- mapply(fix.flume.stage,
  y = list.files(paste0(input.dir, "flume_stage_correction"), full.names = TRUE),
  x = stillwell[names(stillwell) %in% flume.names], SIMPLIFY = FALSE)
flume.data <- lapply(flume.data, calc.disch.flume)

nms <- mapply(paste, names(xsec.vel.data), sub(".csv", "", basename(names(flume.data))), sep = "_")
xsec.val.merged <- mapply(plot.discharges, xsec.vel.data, flume.data, nms)
head(xsec.val.merged[[1]])
