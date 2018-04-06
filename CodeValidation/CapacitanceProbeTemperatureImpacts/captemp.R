## determine the relationship between capacitance readings and temperature and use these to calibrate the capacitance readings for all the loggers.
library(reshape2)
library(ggplot2)

## x is list of files, y is lines to be skipped, z is names
import.sw <- function(x){
    x <- do.call("rbind", lapply(x, read.csv, skip=9, header=FALSE, strip.white = TRUE, blank.lines.skip = TRUE, stringsAsFactors = FALSE))
    names(x)<- c("scan", "date", "time", "capacitance", "stage")
    x <- x[!is.na(x$date) & !is.na(x$capacitance),]
    x$date <- as.Date(x$date, format = "%d/%m/%Y") 
    x <- transform(x, timestamp = paste(date, time, sep=' '))
    x <- x[!is.na(x$date),]
    x$timestamp <- as.POSIXct(x$timestamp, tz = "Asia/Kolkata")
    x <- x[, c(6, 4)]
    return(x)
}

import.tmp <- function(x){
    x <- do.call("rbind", lapply(x, read.csv, skip=15, header=FALSE, strip.white = TRUE, blank.lines.skip = TRUE, stringsAsFactors = FALSE))
    names(x)<- c("timestamp", "Unit", "Temperature")
    x <- x[!is.na(x$timestamp) & !is.na(x$Temperature),]
    x$timestamp <- as.POSIXct(x$timestamp, format = "%m/%d/%y %I:%M:%S %p", tz = "Asia/Kolkata")
    x$timestamp <- as.POSIXct(round(as.numeric(x$timestamp)/(5*60))*(5*60), origin = "1970-01-01")
    x <- x[,c(1, 3)]
    return(x)
}


sw.ground.files <- list.files("~/Res/CWC/Data/LoggerErrorCorrection/wlr/ground/", full.names = TRUE)
sw.stream.files <-  list.files("~/Res/CWC/Data/LoggerErrorCorrection/wlr/stream", full.names = TRUE)
tmp.air.files <- list.files("~/Res/CWC/Data/LoggerErrorCorrection/wlr/groundtemp", full.names = TRUE)
tmp.water.files <- list.files("~/Res/CWC/Data/LoggerErrorCorrection/wlr/streamtemp", full.names = TRUE)

sw.ground.dat <- do.call("rbind", lapply(sw.ground.files, import.sw))
names(sw.ground.dat)[2] <- "cap.ground"
sw.stream.dat <- do.call("rbind", lapply(sw.stream.files, import.sw))
names(sw.stream.dat)[2] <- "cap.stream"
tmp.air.dat <- do.call("rbind", lapply(tmp.air.files, import.tmp))
names(tmp.air.dat)[2] <- "tmp.air"
tmp.water.dat <- do.call("rbind", lapply(tmp.water.files, import.tmp))
names(tmp.water.dat)[2] <- "tmp.water"
## from <https://stackoverflow.com/questions/14096814/merging-a-lot-of-data-frames>
merged <- Reduce(function(...) merge(..., all=TRUE), list(sw.ground.dat, sw.stream.dat, tmp.air.dat, tmp.water.dat))
write.csv(merged, "merged.csv")


## Analysis
lm.ground <- lm(formula = cap.ground ~ tmp.air, data = merged)
summary(lm.ground)
plot(tmp.cap$Value, tmp.cap$Stage)
abline(lm.res)

summary(lm(formula = Stage ~ Value, data = tmp.cap))

