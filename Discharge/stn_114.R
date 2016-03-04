## Process data for station 114 - Wattle
ar.cat <- 293562.5 ## TO BE FIXED
catch.type <- "Wattle Catchment"
stn.names(114,108) ## name files
wlr.lowstage <- wlr.dat[wlr.dat$Stage<=0.603, ]
wlr.highstage <-  wlr.dat[wlr.dat$Stage>0.603, ]
wlr.lowstage$discharge.m3sec <- 1.09*(1.393799*((wlr.lowstage$Stage-0.2065)^2.5))
## wlr.lowstage$discharge.m3sec <- 1.09*(1.393799*((WLR Stage-0.2065)^2.5))

wlr.highstage$discharge.m3sec <- 1.09*((1.394*(((wlr.highstage$Stage-0.2065)^2.5) -
                                               ((wlr.highstage$Stage-0.603)^2.5))) +
                                       (0.719*(wlr.highstage$Stage-0.603)^1.5))

wlr.discharge <- rbind(wlr.lowstage, wlr.highstage)
wlr.discharge$date_time <- as.POSIXct(wlr.discharge$date_time)
wlr.discharge.sorted <- wlr.discharge[order(wlr.discharge$date_time, na.last=FALSE),]
wlr.dat <- subset(wlr.discharge.sorted, select=c("raw", "Stage", "date_time", "discharge.m3sec"))
names(wlr.dat) <- c("Capacitance", "Stage", "Timestamp", "Discharge")
summary(wlr.dat$Discharge)
wlr.dat$Discharge.hr<- wlr.dat$Discharge * 3600 ## get hourly discharge
wlr.dat$Discharge <- round(wlr.dat$Discharge, digits=5)
wlr.dat$Discharge.hr <- round(wlr.dat$Discharge.hr, digits=5)
summary(wlr.dat$Discharge.hr)
sum(wlr.dat$Discharge.hr, na.rm=TRUE)
## for correcting the datasets for sudden drops
## write.csv(wlr.dat, file="wlr101data.csv")
## wlr.dat <- read.csv(file="wlr101data.csv")
## wlr.dat$Timestamp <- as.POSIXct(wlr.dat$Timestamp, tz="Asia/Kolkata")

## wlr.dat$DepthDischarge <- (wlr.dat$Discharge/ar.cat)*1e+9  ## check if this is correct, see below
wlr.dat$DepthDischarge <- (wlr.dat$Discharge.hr/ar.cat)*1000 ## in mm per hour
sum(wlr.dat$DepthDischarge, na.rm=TRUE)
## sum(wlr.dat$DepthDischarge, na.rm=TRUE)
plot(wlr.dat$Stage, wlr.dat$Discharge, type="p",
     main="Stage Discharge Curve for V-notch at Kolaribetta",
     xlab="Stage (m)", ylab="Discharge (m^3/sec)")
## plot(wlr.dat$Timestamp, log(wlr.dat$Discharge), type="l", main="Hydrograph for V-notch at Kolaribetta \n WATTLE CATCHMENT",
##  xlab="Time", ylab="Log of discharge (m^3/sec)")
## Now do a ggplot
wlr.dat <- subset(wlr.dat, select=c("Capacitance","Stage", "Timestamp", "Discharge", "DepthDischarge", "Discharge.hr"))
wlr.dat$Date <- as.Date(wlr.dat$Timestamp, "%Y-%m-%d")
ggtitle.dis <- "Discharge Versus Time, Wattle Catchment"
ggtitle.et.catch <- "Daily ET Versus Time, Wattle Catchment"
ggtitle.et.riper <- "Daily ET Versus Time\nWATTLE RIPARIAN AREA"
assign(paste("wlr.dat.101_",yr, sep=""), wlr.dat)
wlr.dat.101 <- wlr.dat ## save to unique filename
assign(paste("wlr.dat.wt_",yr, sep=""), wlr.dat)
