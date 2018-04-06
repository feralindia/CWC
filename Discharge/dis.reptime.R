
## ---- specify timeslots for reporting
ts.years <- as.data.frame(matrix(nrow=3, ncol=2))
names(ts.years) <- c("start", "end") 
ts.years[1,1] <- as.POSIXct("2014-01-01 00:00:00", tz="Asia/Kolkata")
ts.years[1,2] <- as.POSIXct("2014-04-01 00:00:00", tz="Asia/Kolkata")
ts.years[2,1] <- as.POSIXct("2014-04-01 00:00:00", tz="Asia/Kolkata")
ts.years[2,2] <- as.POSIXct("2014-07-01 00:00:00", tz="Asia/Kolkata")
ts.years[3,1] <- as.POSIXct("2014-07-01 00:00:00", tz="Asia/Kolkata")
ts.years[3,2] <- as.POSIXct("2014-10-01 00:00:00", tz="Asia/Kolkata")
ts.years[4,1] <- as.POSIXct("2014-10-01 00:00:00", tz="Asia/Kolkata")
ts.years[4,2] <- as.POSIXct("2015-01-01 00:00:00", tz="Asia/Kolkata")
## ts.years[5,1] <- as.POSIXct("2014-09-01 00:00:00", tz="Asia/Kolkata")
## ts.years[5,2] <- as.POSIXct("2014-011-01 00:00:00", tz="Asia/Kolkata")

ts.years[6,1] <- as.POSIXct("2015-01-01 00:00:00", tz="Asia/Kolkata")
ts.years[6,2] <- as.POSIXct("2015-04-01 00:00:00", tz="Asia/Kolkata")
ts.years[7,1] <- as.POSIXct("2015-04-01 00:00:00", tz="Asia/Kolkata")
ts.years[7,2] <- as.POSIXct("2015-07-01 00:00:00", tz="Asia/Kolkata")
ts.years[8,1] <- as.POSIXct("2015-07-01 00:00:00", tz="Asia/Kolkata")
ts.years[8,2] <- as.POSIXct("2015-10-01 00:00:00", tz="Asia/Kolkata")
ts.years[9,1] <- as.POSIXct("2015-10-01 00:00:00", tz="Asia/Kolkata")
ts.years[9,2] <- as.POSIXct("2016-01-01 00:00:00", tz="Asia/Kolkata")
## ts.years[10,1] <- as.POSIXct("2015-05-01 00:00:00", tz="Asia/Kolkata")
## ts.years[10,2] <- as.POSIXct("2015-06-01 00:00:00", tz="Asia/Kolkata")

ts.years[11,1] <- as.POSIXct("2016-01-01 00:00:00", tz="Asia/Kolkata")
ts.years[11,2] <- as.POSIXct("2016-04-01 00:00:00", tz="Asia/Kolkata")
ts.years[12,1] <- as.POSIXct("2016-04-01 00:00:00", tz="Asia/Kolkata")
ts.years[12,2] <- as.POSIXct("2016-07-01 00:00:00", tz="Asia/Kolkata")
## ts.years[13,1] <- as.POSIXct("2016-03-01 00:00:00", tz="Asia/Kolkata")
## ts.years[13,2] <- as.POSIXct("2016-04-01 00:00:00", tz="Asia/Kolkata")
## ts.years[11,1] <- as.POSIXct("2016-05-01 00:00:00", tz="Asia/Kolkata")
## ts.years[11,2] <- as.POSIXct("2016-06-61 00:00:00", tz="Asia/Kolkata")
## ts.years[12,1] <- as.POSIXct("2016-06-01 00:00:00", tz="Asia/Kolkata")
## ts.years[12,2] <- as.POSIXct("2016-07-01 00:00:00", tz="Asia/Kolkata")

## ts.start.tmstmp <- as.POSIXct("2013-06-01 00:00:00", tz="Asia/Kolkata")
## ts.end.tmstmp <- as.POSIXct("2016-05-31 23:59:59", tz="Asia/Kolkata")
## ts.interval <- "1 month" ## period of reporting
## ts.start <- seq(ts.start.tmstmp, ts.end.tmstmp, ts.interval)
## ts.end <- ts.start[-1] ## take all but first item of ts.start
## ts.end <- ts.end-1 ## end is one second less than pervious start
## ts.end[[length(ts.end)+1]] <- ts.end.tmstmp ## add last ts.end value
## ts.years <- as.data.frame(matrix(nrow=length(ts.start),ncol=2))
## names(ts.years) <- c("start", "end") 
## ts.years[,1] <- as.POSIXct(ts.start, tz="Asia/Kolkata")
## ts.years[,2] <- as.POSIXct(ts.end, tz="Asia/Kolkata")
ts.years <- na.omit(ts.years)
