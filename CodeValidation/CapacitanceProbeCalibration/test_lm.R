## Script to compare difference in linear model with and without the brass portion of the capacitance probe.
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

getlm <- function(x){ #x is calibration file name, y = wlr file name
    calibdat <- read.csv(x, header=FALSE, sep=",", col.names=c("stage", "capacitance"), skip=6)
    if(max(calibdat$stage, na.rm = TRUE) > 5) calibdat$stage <- calibdat$stage/100 # convert to meters when calibration is done in cm
    fitlm <- lm(stage ~ capacitance, data = calibdat)
    print(tail(calibdat))
    print(summary(fitlm))
    return(fitlm) 
}

getlm.brass <- function(x){ #x is calibration file name, y = wlr file name
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


calc.disch.areastage <- function(x, y){ # x is sw data, y is sd curve
    sd <- read.csv(y) # "~/Res/CWC/Data/Nilgiris/cleaned.rating/csv/WLR_107_SD.csv")
    sd <- sd[,c("stage", "avg.disch")]
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


## calculate discharge of a two inch montana flume
calc.disch.flume <- function(x){
    x <- x[,c("capacitance", "stagecalc", "timestamp")]
    names(x) <- c("Capacitance", "Stage", "Timestamp")
    ## y <- y[!is.na(y$Stage),]
    ## p1 <- 176.5 ## <https://www.openchannelflow.com/flumes/montana-flumes/discharge-tables>
    ## p3 <- 1.55
    # for 2 inch flume: 120.7*H^1.55 for 3 inch: 176.5*H^1.55
    p1 <- 176.5
    p3 <- 1.55
    x$Discharge <- p1*(x$Stage)^p3*0.001 # in m cube per sec
    return(x)
}

##--- Does the brass section of the capacitance probe lead to messing up the data?
##--- compare the results of the regression with and without the brass section

flnm <- "/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib2017/wlr_102A_calib_10122017_nozero.csv"
wlrdatadir <- "~/Res/CWC/Data/Nilgiris/wlr/raw/"
wlr <- unlist(regmatches(flnm,gregexpr("[[:digit:]]+\\.*[[:digit:]]*",flnm))) ## this form pulls out separate sets of numbers
wlr <- wlr[2]
calibdat <- read.csv(flnm,header=FALSE, sep=",", col.names=c("y", "x"), skip=6)
calibdat$y <- calibdat$y/100 # convert to meters
raw.wlr.fn <- list.files(path = wlrdatadir, pattern = wlr, recursive = TRUE, full.names = TRUE)
raw.wlr.fn <- raw.wlr.fn[1]
raw.wlr <- do.call("rbind", lapply(raw.wlr.fn, read.csv, skip=8, header=FALSE, strip.white = TRUE, blank.lines.skip = TRUE, stringsAsFactors = FALSE))
names(raw.wlr) <- c("scan", "date", "time", "x", "y")
raw.wlr$date <- as.Date(raw.wlr$date, format = "%d/%m/%Y")
raw.wlr <- transform(raw.wlr, timestamp = paste(date, time, sep=' '))
raw.wlr <- raw.wlr[!is.na(raw.wlr$date),]
raw.wlr$timestamp <- as.POSIXct(raw.wlr$timestamp, zone = "Asia/Kolkata")


fitlm <- lm(y ~ x, data = calibdat)
summary(fitlm)
calibdat2 <- calibdat[calibdat$y>=0.010,]
## calibdat2 <- calibdat[calibdat$y>=10,]
fitlm2 <- lm(y ~ x, data = calibdat2)
summary(fitlm2)

raw.wlr$with.brass <- predict(fitlm, raw.wlr)
raw.wlr$without.brass <- predict(fitlm2, raw.wlr)

head(raw.wlr)

ggdat <- melt(raw.wlr, id.vars = c("scan", "date", "timestamp"), measure.vars =c("with.brass", "without.brass"), value.name = "Stage", variable.name = "Model", na.rm = TRUE)
    ggplt <- ggplot(data = ggdat, aes(x = timestamp, y = Stage, colour = Model)) +
        geom_line()
    print(ggplt)


##--- This section is to see whether there is a difference in the amplitude of diurnal signals between the flume (110) and stilling well (107)

flnm <- list.files("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_110/", full.names = TRUE)
flume <- importdata(flnm)
## flume <- flume[flume$Timestamp<"2014-01-23 12:26:14",] # data after this date is shot to hell
## flume <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_110/WLR110_110_036_25_04_2017.CSV")
## flume <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_110/WLR110_110_034_25_02_2017.CSV")
## flume <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_110/WLR110_110_035_28_03_2017.CSV")
lm.flume <- getlm("/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib2017/wlr_110_calib_30012018.csv")
flume$stagecalc <- predict(lm.flume, flume)

flnm <- list.files("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_107/", full.names = TRUE)
stillwell <- importdata(flnm)
## stillwell <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_107/WLR107_107_067_25_04_2017.CSV")
## stillwell <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_107/WLR107_107_065_25_02_2017.CSV")
## stillwell <- importdata("~/Res/CWC/Data/Nilgiris/wlr/raw/wlr_107/WLR107_107_066_28_03_2017.CSV")
lm.stillwell <- getlm("/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib2017/wlr_107.csv")
stillwell$stagecalc <- predict(lm.stillwell, stillwell)
## accounting for brass
## lm.stillwell <- getlm.brass("/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/calib2017/wlr_107_calib_15122017.csv")
## stillwell$material[stillwell$capacitance<cutoff] <- "Brass"
## stillwell$material[stillwell$capacitance>=cutoff] <- "Teflon"
## stillwell$stagecalc <- predict(lm.stillwell, stillwell)


merged <- merge(stillwell, flume, by = "timestamp")[,c("timestamp", "capacitance.x", "stagecalc.x", "capacitance.y", "stagecalc.y")] # 1, 5, 7, 11, 13)]
names(merged) <- c("timestamp", "cap.sw", "stage.sw", "cap.fl", "stage.fl")
ggdat <- melt(merged, value.name = "Stage", measure.vars = c("stage.sw", "stage.fl"), id.vars = "timestamp")
ggplot(data = ggdat, aes(x = timestamp, y = Stage, colour = variable))+
        geom_line()

## calculate the daily amplitude of stage and discharge for stillingwell and flume

##- this section calculates the discharge and plots it

sd.file <- "~/Res/CWC/Data/Nilgiris/cleaned.rating/csv/WLR_107_SD.csv"
## sd.file <- "./sd.107.flume2.csv" # taken from flume results 
stillwell <- calc.disch.areastage(x = stillwell, y = sd.file)
## do this for flume here
flume <- calc.disch.flume(flume)

merged <- merge(stillwell, flume, by = "Timestamp")
names(merged) <- c("Timestamp", "Capacitance.sw", "Stage.sw", "Discharge.sw", "Capacitance.fl", "Stage.fl", "Discharge.fl")
##-- next few lines are fiddling with the results to see where the error is coming from##
## merged$Discharge.sw <- merged$Discharge.sw*0.28

ggdat <- melt(merged, value.name = "Discharge", measure.vars = c("Discharge.sw", "Discharge.fl"), id.vars = "Timestamp")

## ggdat$seq <- seq_along(!is.na(ggdat$Discharge)))

ggplot(data = ggdat, aes(x = Timestamp, y = Discharge, colour = variable))+
    geom_line()
    


## g <- ggplot(data.frame(Time, Value, Group)) + 
##   geom_line (aes(x=Time, y=Value)) +
##   facet_grid(~ Group, scales = "free_x")

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
