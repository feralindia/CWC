## Process data for station 115 - Wattle
## this sript is called both for hydrograph
## and for discharge calculations
## stn.names(115,105) ## name files done in hydgrph or discharge script

##-----IMPORTANT NOTE-----###
## input data is AVERAGED BASED ON THE 5/10 OR 15 MINUTE LOG
## POSTERIOR VALUES ARE USED TO POPULATE PRIOR NA VALUES
## observed height of the water above the notch on:
## 28 June 2015 at 11:20:00 am was 0.157m
## stage at that time was 0.31610m
## HEIGHT OF V ABOVE STILLING WELL IS 0.1661m
## forumula is Q (m3/hr) = 4969 * (H^2.5)
##-----END OF NOTE-----##

##--- define constants
cat(paste("Processing data for station: ", wlr.no, sep=""),"\n")
ar.cat <- 293562.5 ## TO BE FIXED
catch.type <- "Wattle Catchment"

##--- pull in data using a routine
source("read.wlrdat.R", echo=TRUE)

##--- do the discharge calculations

wlr.dat$Stage <- wlr.dat$Stage-0.1661 ## adjusting for difference in v-notch and logger
wlr.dat$Discharge <- 4969 * wlr.dat$Stage^2.5

##-- round off 
wlr.dat$Discharge <- round(wlr.dat$Discharge, digits=5)
summary(wlr.dat$Discharge)

wlr.dat$date_time <- as.POSIXct(wlr.dat$date_time)
wlr.dat.sorted <- wlr.dat[order(wlr.dat$date_time, na.last=FALSE),]
wlr.dat <- subset(wlr.dat.sorted, select=c("raw", "Stage", "date_time", "Discharge"))
names(wlr.dat) <- c("Capacitance", "Stage", "Timestamp", "Discharge")
## sum(wlr.dat$Discharge, na.rm=TRUE)
## for correcting the datasets for sudden drops
## write.csv(wlr.dat, file="wlr115data.csv")
## wlr.dat <- read.csv(file="wlr115data.csv")
## wlr.dat$Timestamp <- as.POSIXct(wlr.dat$Timestamp, tz="Asia/Kolkata")

## wlr.dat$DepthDischarge <- (wlr.dat$Discharge/ar.cat)*1e+9
## check if this is correct, see below
wlr.dat$DepthDischarge <- (wlr.dat$Discharge/ar.cat)*1000 ## in mm per hour
sum(wlr.dat$DepthDischarge, na.rm=TRUE)
## sum(wlr.dat$DepthDischarge, na.rm=TRUE)
plot(wlr.dat$Stage, wlr.dat$Discharge, type="p",
     main="Stage Discharge Curve for V-notch near Devar Betta",
     xlab="Stage (m)", ylab="Discharge (m^3/hr)")
## plot(wlr.dat$Timestamp, log(wlr.dat$Discharge), type="l", main="Hydrograph for V-notch at Kolaribetta \n WATTLE CATCHMENT",
##  xlab="Time", ylab="Log of discharge (m^3/sec)")
## Now do a ggplot
wlr.dat <- subset(wlr.dat, select=c("Capacitance","Stage", "Timestamp", "Discharge", "DepthDischarge"))

## --- for plotting, commented out for now
## wlr.dat$Date <- as.Date(wlr.dat$Timestamp, "%Y-%m-%d")
## ggtitle.dis <- "Discharge Versus Time, Wattle Catchment"
## ggtitle.et.catch <- "Daily ET Versus Time, Wattle Catchment"
## ggtitle.et.riper <- "Daily ET Versus Time\nWATTLE RIPARIAN AREA"
## assign(paste("wlr.dat.115_",yr, sep=""), wlr.dat)
## wlr.dat.115 <- wlr.dat ## assign to unique filename
## assign(paste("wlr.dat.wt_",yr, sep=""), wlr.dat)

