## Functions file added in July 2016 to streamline and speed up processing
##------NOTE-------##
## The changed conductivity of the brass portion of the probe makes no significant difference to the calibration.
## See the testlm.R script for more details
##-----------------##

## run a linear model on the calibration data to get the intercept and coefficient
## x is full filename where calibration data is stored
## use file_path_sans_ext("name1.csv") to extract filename
## use file_ext("name1.csv") to get the extension only
##-- testing
## x <- list.files(path=dir_calib_wlr, pattern="*new.csv$", full.names = TRUE)
## flnm <- "/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib/wlr_102_new.csv"
flnm <- "/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib2017/wlr_102A_calib_10122017_nozero.csv"
## col.nm <- c("y", "x")
## suggest that names of calibration files are changed to contain date of calibration
## run by: do.call("rbind", lapply(x, calc.slp.int))
do.lm <- function(flnm){
    tmp <- read.csv(flnm,header=FALSE, sep=",", col.names=c("y", "x"), skip=6)
    wlr <- as.character(gsub("\\D", "", flnm)) # this form pulls all numbers out together
    ## wlr <- unlist(regmatches(flnm,gregexpr("[[:digit:]]+\\.*[[:digit:]]*",flnm))) ## this form pulls out separate sets of numbers
    fitlm <- lm(y ~ x, data = tmp)
    int <- as.numeric(fitlm$coefficients[1])
    coef.x <- as.numeric(fitlm$coefficients[2])
    predict(fitlm, raw.wlr)
    ggp <- ggplot(tmp, aes(tmp$x,tmp$y)) +
        stat_summary(fun.data=mean_cl_normal) + 
        geom_smooth(method='lm',formula=y~x)
    print(ggp)
    return(data.frame(wlr, int, coef.x))
}

##-- Calculate lm, additive lm and interactive lm for capacitance probe
## flnm <- list.files(path=dir_calib_wlr, pattern="*new.csv$", full.names = TRUE)
## flnm <- "~/Res/CWC/Data/Nilgiris/wlr/calib/wlr_102_new.csv"
## wlrdatadir <- "~/Res/CWC/Data/Nilgiris/wlr/raw/"
do.lmi <- function(flnm, wlrdatadir){
    tmp <- read.csv(flnm, header=FALSE, sep=",", col.names=c("y", "x"), skip=6)
    tmp$material[tmp$y>0.05] <- "Wire"
    tmp$material[tmp$y<=0.05] <- "Brass"
    tmp <- tmp[tmp$y > 0,]
    ## max.brass <- max(tmp$x[tmp$y==0.1], na.rm = TRUE)
    ## max.wire <- max(tmp$x)
    fitlmi <- lm(y ~ x * material, data = tmp)# the fit with the interaction term * is better than +
    fitlma <-  lm(y ~ x + material, data = tmp)
    fitlm <- lm(y ~ x, data = tmp)
    ## ggp <- ggplot(tmp, aes(tmp$x,tmp$y)) +
    ##    stat_summary(fun.data=mean_cl_normal) + 
    ##    geom_smooth(method='lm',formula=tmp$y~tmp$x*tmp$material)
    ## print(ggp)
    plot(tmp$x, predict(fitlmi, x=(tmp$x)), col = "green")
    points(tmp$x, predict(fitlm, x=(tmp$x)), col = "red")
    ## points(tmp$x, tmp$y, col = "green")    
    wlr.numerals <- unlist(regmatches(flnm,gregexpr("[[:digit:]]+\\.*[[:digit:]]*",flnm))) ## pull separate sets of numbers
    wlr <- wlr.numerals[1]
    cal.date <- wlr.numerals[2]
    cal.date <- as.Date (paste0(substr(cal.date, 1, 2), "-", substr(cal.date, 3, 4), "-", substr(cal.date, 5, 6)), format = "%d-%m-%y") # TBD
    raw.wlr.fn <- list.files(path = wlrdatadir, pattern = wlr, recursive = TRUE, full.names = TRUE)
    raw.wlr <- do.call("rbind", lapply(raw.wlr.fn, read.csv, skip=8, header=FALSE, strip.white = TRUE, blank.lines.skip = TRUE, stringsAsFactors = FALSE))
    names(raw.wlr) <- c("scan", "date", "time", "x", "y")
    ## names(raw.wlr) <- c("sl","date","time","x","y")
    ## raw.wlr$material <- NA
    raw.wlr <- raw.wlr[complete.cases(raw.wlr),]
    brk.date <- unlist(strsplit(raw.wlr$date[[1]], split = "/")) # fix date
    if(nchar(brk.date[1])==2) {
        dt.format <- "%d/%m/%Y"} else {
                                   dt.format <- "%Y/%m/%d" }
    if(nchar(brk.date[1])==2 & nchar(brk.date[3])==2)
    {
        stop(paste("Dates for file ", y, "need fixing.", sep=""))
    }
    raw.wlr$date <- as.Date(raw.wlr$date, format = dt.format)
    raw.wlr[raw.wlr$date > cal.date, ] # TBD
    raw.wlr <- transform(raw.wlr, timestamp = paste(date, time, sep=' '))
    raw.wlr <- raw.wlr[!is.na(raw.wlr$date),]
    raw.wlr$timestamp <- as.POSIXct(raw.wlr$timestamp, tz = "Asia/Kolkata")
    raw.wlr$material[raw.wlr$y>0.1] <- "Wire"
    raw.wlr$material[raw.wlr$y<=0.1] <- "Brass"
    raw.wlr$lmi.y <- predict(fitlmi, raw.wlr)
    raw.wlr$lma.y <- predict(fitlma, raw.wlr)
    raw.wlr$lm.y <- predict(fitlm, raw.wlr)
    ## write.csv(raw.wlr, file = "~/tmp/wlr102cal.csv")
    print(paste("interaction plot lower in", nrow(raw.wlr[raw.wlr$lmi.y < raw.wlr$lm.y,]), "rows and higher in", nrow(raw.wlr[raw.wlr$lmi.y > raw.wlr$lm.y,]), "rows"))
    return(raw.wlr)
}
## this section is to plot the fitted and original values for testing.
plotfits <- function(x){
    lapply(c("ggplot2", "reshape2"), require, character.only = TRUE)
    ggdat <- melt(x, id.vars = c("scan", "date", "timestamp"), measure.vars =c("lmi.y", "lm.y"), value.name = "Stage", variable.name = "Model", na.rm = TRUE)
    ggplt <- ggplot(data = ggdat, aes(x = date, y = Stage, colour = Model)) +
        geom_line()
    print(ggplt)
    
}
splt.dt <- function(x, stval, stpval){
    return(substr(x, stval, stpval))
}

## for testing only
flnm <- "~/Res/CWC/Data/Aghnashini/wlr/calib/WLR_002_calib_301117.csv"
wlrdatadir <- "~/Res/CWC/Data/Aghnashini/wlr/raw/"
x <- do.lm(flnm)
x <- do.lmi(flnm, wlrdatadir)
## x <- x[x$date >
plotfits(x)

## Adjust capacitance for flumes to fix for ponding and
        ## variations in logger placement.
        ## Note: fulmes dampen diurnal signals and therefore need
        ## to align to the bottom of the flow amplitude not its middle.
        ## 102:112
        ## 103:113
        ## 106:111
        ## 107:110
adjust.capacitance <- function(x,y){
    if(x=="110" & format(y$date_time[1], format = "%Y")=="2014")
        y$raw <- y$raw+130 # 2028.70
    if(x=="110" & format(y$date_time[1], format = "%Y")=="2015")
        y$raw <- y$raw-20 # 2028.70
    if(x=="110" & format(y$date_time[1], format = "%Y")=="2016")
        y$raw <- y$raw+360 # 2028.70
    if(x=="111" & format(y$date_time[1], format = "%Y")=="2014")
        y$raw <- y$raw+450# 400
    if(x=="111" & format(y$date_time[1], format = "%Y")=="2015")
        y$raw <- y$raw+400#350
    if(x=="111" & format(y$date_time[1], format = "%Y")=="2016")
        y$raw <- y$raw+400
    if(x=="112" & format(y$date_time[1], format = "%Y")=="2014")
        y$raw <- y$raw+146.14
    if(x=="112" & format(y$date_time[1], format = "%Y")=="2015")
        y$raw <- y$raw-340 #-300
    if(x=="112" & format(y$date_time[1], format = "%Y")=="2016")
        y$raw <- y$raw-100 #146.14
    if(x=="103" & format(y$date_time[1], format = "%Y")<="2014")
        y$raw <- y$raw-93 #old probe appeared to have pooling. decreased.
    if(x=="113" & format(y$date_time[1], format = "%Y")=="2014")
        y$raw <- y$raw+0 # not to be changed
    if(x=="113" & format(y$date_time[1], format = "%Y")=="2015")
        y$raw <- y$raw+0 # perfectly aligned :-)
    if(x=="113" & format(y$date_time[1], format = "%Y")=="2016")
        y$raw <- y$raw+0 # perfectly aligned :-)
    return(y)
}    

  ## if(num_wlr[i]=="110" & format(xy$date_time[1], format = "%Y")=="2014")
  ##       xy$raw <- xy$raw+130 # 2028.70
  ##   if(num_wlr[i]=="110" & format(xy$date_time[1], format = "%Y")=="2015")
  ##       xy$raw <- xy$raw-20 # 2028.70
  ##   if(num_wlr[i]=="110" & format(xy$date_time[1], format = "%Y")=="2016")
  ##       xy$raw <- xy$raw+360 # 2028.70
  ##   if(num_wlr[i]=="111" & format(xy$date_time[1], format = "%Y")=="2014")
  ##       xy$raw <- xy$raw+450# 400
  ##   if(num_wlr[i]=="111" & format(xy$date_time[1], format = "%Y")=="2015")
  ##       xy$raw <- xy$raw+400#350
  ##   if(num_wlr[i]=="111" & format(xy$date_time[1], format = "%Y")=="2016")
  ##       xy$raw <- xy$raw+400
  ##   if(num_wlr[i]=="112" & format(xy$date_time[1], format = "%Y")=="2014")
  ##       xy$raw <- xy$raw+146.14
  ##   if(num_wlr[i]=="112" & format(xy$date_time[1], format = "%Y")=="2015")
  ##       xy$raw <- xy$raw-340 #-300
  ##   if(num_wlr[i]=="112" & format(xy$date_time[1], format = "%Y")=="2016")
  ##       xy$raw <- xy$raw-100 #146.14
  ##   if(num_wlr[i]=="103" & format(xy$date_time[1], format = "%Y")<="2014")
  ##       xy$raw <- xy$raw-93 #old probe appeared to have pooling. decreased.
  ##   if(num_wlr[i]=="113" & format(xy$date_time[1], format = "%Y")=="2014")
  ##       xy$raw <- xy$raw+0 # not to be changed
  ##   if(num_wlr[i]=="113" & format(xy$date_time[1], format = "%Y")=="2015")
  ##       xy$raw <- xy$raw+0 # perfectly aligned :-)
  ##   if(num_wlr[i]=="113" & format(xy$date_time[1], format = "%Y")=="2016")
  ##       xy$raw <- xy$raw+0 # perfectly aligned :-)


## read in and bind raw data
read.raw.data <- function(x, y){
    cat(paste("Reading in data file", y, sep=" "), sep = "\n")
    xy <- read.csv(file=x, skip=8, header=FALSE,
                   strip.white = TRUE, blank.lines.skip = TRUE)
    xy <- na.omit(xy)
    names(xy)<- c("scan", "date", "time", "raw", "cal")
    xy$date <- gsub(pattern="-", replacement="/", x=xy$date)
    brk.date <- unlist(strsplit(xy$date[[1]], split="/")) # fix date
    if(nchar(brk.date[1])==2) {
        dt.format <- "%d/%m/%Y"} else {
                                   dt.format <- "%Y/%m/%d" }
    if(nchar(brk.date[1])==2 & nchar(brk.date[3])==2)
    {
        stop(paste("Dates for file ", y, "need fixing.", sep=""))
    }
    xy$date <- as.Date(xy$date, format=dt.format)## "%d/%m/%Y")
    xy<-transform(xy, date_time = paste(date, time, sep=' '))
    xy <- xy[complete.cases(xy),]
    xy$date_time<-as.POSIXct(xy$date_time, tz="Asia/Kolkata")
    xy <- adjust.capacitance(num_wlr[i], xy) # adjust capacitance
    return(xy)
}

calib.wlr <- function(n){
    calint <- as.numeric(subset(all.wlr.calibres, wlr==wlrtab.cal, select=c(int, x)))
    if(is.na(calint)[1]==TRUE) (stop(paste("Calibration file", wlrtab.cal, "is missing or has errors", sep=" ")))
    n$cal <- (n$raw*calint[2])+calint[1] ## unit is metres
    n$date_time<-as.POSIXct(n$date_time, origin="1970-01-01", tz="Asia/Kolkata")
    n$date_time<-round(n$date_time, "mins") ## added sept '14
    n <- n[complete.cases(n$date_time),] # remove row where date_time is NA
    start.hr <- round(min(n$date_time), "mins")
    end.hr <- round(max(n$date_time), "mins")
    tint1min <- seq.POSIXt(start.hr, end.hr,by="1 min",na.rm=T) # 1 minute interval
    attributes(tint1min)$tzone <- "Asia/Kolkata"
    xx1<-as.data.frame(tint1min)
    colnames(xx1)<-c("date_time")
    xx2<-merge(n, xx1, by = "date_time", all = TRUE)
    ## xx2$date_time<-as.POSIXct(xx2$date_time)
    xx2 <-  xx2[!duplicated(xx2$date_time), ] # remove duplicates
    ## IMPORTANT this will remove data from n unless the merge
    ## lists n first.
    ## see  <https://stat.ethz.ch/pipermail/r-devel/2010-August/058112.html>
    xx3<-as.timeSeries(xx2)
    ## financial centre to be set in wlr_nlg and wlr_agn    setFinCenter(xx3) <- "Asia/Calcutta"
    ## ensure that the calibrated values are not NA
    xx3<-interpNA(xx3, method="before")
    xx3$date_time<-row.names(xx3)
    mmx<-as.data.frame(xx3)
    row.names(mmx) <- NULL ## 'row.names=NULL' not working!
    ## mmx <- subset(mmx, select=c("scan", "raw", "cal", "date_time"))
    mmx$date_time <- as.POSIXct(mmx$date_time, tz="Asia/Kolkata")## usetz=TRUE)
    ## write.csv(mmx, file=wlronemincsv, row.names=FALSE) ## changed sept 14
    ## should not be written causes confusion as null hasn't been merged yet
    assign(wlr.fill.onemin, mmx, envir = .GlobalEnv) # assign the output to an R object named after each wlr
    cat(paste("Finished importing data for WLR station", num_wlr[i], sep=" "), sep = "\n")
}

imp.wlr <- function(i){
    cat(paste("Importing WLR station", i, sep=" "), sep = "\n")
    wlrtab<-paste("wlr_", i, sep="")
    wlrtab.cal<-paste("wlr_", i,"_new", sep="") ## changed on Sept '14
    wlr.fill.onemin<-paste("wlr_", i,"onemin", sep="")
    wlrdir<-paste(wlrdatadir, wlrtab, sep="")
    filelist <- list.files(wlrdir, full.names=TRUE, ignore.case=TRUE, pattern='CSV$')
    filename <- list.files(wlrdir, full.names=FALSE, ignore.case=TRUE, pattern='CSV$')
    wlronemincsv <- paste(csvdir, i, "_onemin.csv", sep="")
    ##--- read in raw values and bind them together
    ##--- make necessary adjustments in capcitance
    xyall <- do.call("rbind",
                     mapply(read.raw.data, filelist, filename,
                            SIMPLIFY = FALSE, USE.NAMES = FALSE))
    
    ##---- Calibrate the readings ----##
    calib.wlr(xyall)
}
