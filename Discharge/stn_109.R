ar.cat <- 2680462.5
catch.type <- "Shola Catchment"
stn.names(109, 126) ## use function to assign names

## organise data for calculating dicharge from rating
## note - we're only using files from the slug - salt dilution gauging
sd <- read.csv(file="/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/saltdilution/csv/wlr_109.csv")
sd <- subset(sd, select=c("Stage", "Discharge"))
StreamRating(sd) # calculating the rating using the StreamRating function
wlr.dat$Discharge <- coef.p1*(wlr.dat$Stage)^coef.p3
wlr.dat <- subset(wlr.dat, select=c("raw", "Stage", "date_time", "Discharge"))
names(wlr.dat) <- c("Capacitance", "Stage", "Timestamp", "Discharge")

wlr.dat$Discharge.hr<- wlr.dat$Discharge * 3600 ## get hourly discharge
wlr.dat$Discharge <- round(wlr.dat$Discharge, digits=5)
wlr.dat$Discharge.hr <- round(wlr.dat$Discharge.hr, digits=5)


wlr.dat$DepthDischarge <- (wlr.dat$Discharge.hr/ar.cat)*1000 ## in mm per hour
sum(wlr.dat$DepthDischarge, na.rm=TRUE)
## sum(wlr.dat$DepthDischarge, na.rm=TRUE)
plot(wlr.dat$Stage, wlr.dat$Discharge, type="p",
     main="Stage Discharge Curve for WLR109, Shola at Avalanche PH",
     xlab="Stage (m)", ylab="Discharge (m^3/sec)")
## plot(wlr.dat$Timestamp, log(wlr.dat$Discharge), type="l", main="Hydrograph for V-notch at Kolaribetta \n WATTLE CATCHMENT",
##  xlab="Time", ylab="Log of discharge (m^3/sec)")
## Now do a ggplot
wlr.dat <- subset(wlr.dat, select=c("Capacitance","Stage", "Timestamp", "Discharge", "DepthDischarge", "Discharge.hr"))
wlr.dat$Date <- as.Date(wlr.dat$Timestamp, "%Y-%m-%d")
wlr.dat <- wlr.dat[order(wlr.dat$Timestamp),]
ggtitle.dis <- "Discharge Versus Time, Shola Catchment"
ggtitle.et.catch <- "Daily ET Versus Time, Shola Catchment"

assign(paste("wlr.dat.109_",yr, sep=""), wlr.dat)
wlr.dat.109 <- wlr.dat ## save to unique filename
assign(paste("wlr.dat.sh_",yr, sep=""), wlr.dat)

