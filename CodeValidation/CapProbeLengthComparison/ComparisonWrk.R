##+Summary: Compare the readings across different probes.

## Call libraries
library(reshape2)
library(ggplot2)
## library(cosinor)

## Call functions

importdata <- function(flnm){
    logger.name <- sub('_.*', '', basename(flnm))
    x <- do.call("rbind", lapply(flnm, read.csv, skip=8, header=FALSE, strip.white = TRUE, blank.lines.skip = TRUE, stringsAsFactors = FALSE))
    names(x)<- c("scan", "date", "time", "capacitance", "stage")
    x <- x[!is.na(x$date),]
    x$date <- as.Date(x$date, format = "%d/%m/%Y") 
    x <- transform(x, timestamp = paste(date, time, sep=' '))
    x <- x[!is.na(x$date),]
    x$timestamp <- as.POSIXct(x$timestamp, tz = "Asia/Kolkata")
    x$LoggerName <- logger.name
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

append.lm <- function(x,y){
    x$stagecalc <- predict(y, x)
    return(x)
}

calc.disch.areastage <- function(x, y){ # x is sw data, y is sd curve
    sd <- read.csv(y) # "~/Res/CWC/Data/Nilgiris/cleaned.rating/csv/WLR_107_SD.csv")
    sd <- sd[,c("stage", "avg.disch")]
    names(sd) <- c("Stage", "Discharge")
    ## sd$Discharge <- sd$Discharge*0.13 # TBD Correction factor averages to about 0.28
    nls.res <- nls(Discharge~p1*Stage^p3, data=sd, start=list(p1=3,p3=5), control = list(maxiter = 500)) # (p1=3,p3=5)
    coef.p1 <- as.numeric(coef(nls.res)[1])
    coef.p3 <- as.numeric(coef(nls.res)[2])
    x <- x[, c("capacitance", "stagecalc", "timestamp", "LoggerName")]
    names(x) <- c("Capacitance", "Stage", "Timestamp", "Logger")
    x$Discharge <- coef.p1*x$Stage^coef.p3
    return(x)
}

## Correct the stage of wlr based on manual readings for one-time measurements
## input is a dataframe of unit name, timestamp and manual height measurement
wlr.no <- c("wlr_104", "wlr_118", "wlr_119")
timestamp <- c(rep("2018-03-07 13:15:00",3))
stage.man <- c(rep(0.16,3))
manual.stage <- data.frame(wlr.no, timestamp, stage.man)
## in.df <- data.frame("wlr_104", "2018-03-07 13:15:00", 0.16)
## names(in.df) <- c("unit", "timestamp", "height")
## x is stage, y is in.df
adjust.stage.once <- function(x, y){
    x.wlrno <- unique(as.numeric(gsub("\\D", "", x[,7])))
    y.wlrno <- as.numeric(gsub("\\D", "", y[,1]))
    y <- y[y.wlrno==x.wlrno,]
    timestamp <- as.POSIXct(y[,2], tz = "Asia/Kolkata")
    x.height <- x[,8][x[,6]==timestamp]
    hgt.dif <- y[,3]-x.height
    x[,8] <- x[,8] + hgt.dif
    return(x)
}

## Adjust stage from benchmark for entire dataset
## 
adjust.stage <- function(x, y){
    x.wlrno <- unique(as.numeric(gsub("\\D", "", x[,7])))
    y.wlrno <- as.numeric(gsub("\\D", "", y[,1]))
    y <- y[y.wlrno==x.wlrno,]
    timestamp <- as.POSIXct(y[,2], tz = "Asia/Kolkata")
    x.height <- x[,8][x[,6]==timestamp]
    hgt.dif <- y[,3]-x.height
    x[,8] <- x[,8] + hgt.dif
    return(x)
}


## Get file names

log.files <- list.files(path = "./data/raw", recursive = TRUE, full.names = TRUE)
calib.files <- list.files(path = "./data/calib", recursive = TRUE, full.names = TRUE)
sd.data <- "./data/sd/WLR_104_SD.csv"

## Run for stage

raw.log <- lapply(log.files, importdata)
lm.loggers <- lapply(calib.files, getlm)
stage <- mapply(append.lm, raw.log, lm.loggers, SIMPLIFY = FALSE)
names(stage) <- sapply(stage, function(x) unique(x["LoggerName"]))
stage <- do.call("rbind", lapply(stage, adjust.stage, y=manual.stage))

ggplot(data = stage, mapping = aes(x = timestamp,  y = stagecalc, color = LoggerName)) +
    geom_line()
ggsave("Stage.png")

## Run for discharge

discharge <- calc.disch.areastage(x = stage, y = sd.data)
ggplot(data = discharge, mapping = aes(x = Timestamp,  y = Discharge, color = Logger)) +
    geom_line()
ggsave("Discharge.png")

## Statistics for stage

logger <- unique(stage$LoggerName)
mean.stage <- do.call("rbind", lapply(logger, function(x){
    dat <- stage[stage$LoggerName==x,]
    return(mean(dat$stagecalc, na.rm = TRUE))
    }))
data.frame(logger, mean.stage)

## Statistics for discharge

logger <- unique(discharge$Logger)
mean.discharge <- do.call("rbind", lapply(logger, function(x){
    dat <- discharge[discharge$Logger==x,]
    return(mean(dat$Discharge, na.rm = TRUE))
    }))
data.frame(logger, mean.discharge)

## vm.stage <- stage[,c("LoggerName", "stagecalc", "timestamp")]
## vm.stage$timestamp <- time(vm.stage$timestamp)
## cosinor_analyzer(data = stage)

## cosinor.lm(Y ~ time(time) + X + amp.acro(X), data = vitamind, period = 12)


## head(vitamind)

## amp.acro(stage$stagecalc)
