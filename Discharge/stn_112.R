## Process data for station 112 -- wattle
## ar.cat <- 748462.5

wlr112.dat <- read.csv("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/wlr_112_1 hour.csv")
if(names(wlr112.dat)[[3]]=="cal"){
    names(wlr112.dat)[[3]] <- "Stage"
}
wlr112.dat$date_time <- as.POSIXct(wlr112.dat$date_time, tz="Asia/Kolkata")
wlr112.dat <- subset(wlr112.dat, subset=(wlr112.dat$date_time>=ts.start & wlr112.dat$date_time < ts.end))


summ.csvname <- paste(getwd(), "/stn112_Summary_", yr, ".csv", sep="")
dis.csvname <- paste(getwd(), "/stn112_Discharge_", yr, ".csv", sep="")
ET.csvname <- paste(getwd(), "/stn112_ET_", yr, ".csv", sep="")
## dis.figname <- paste(getwd(), "/stn112_Dis_vs_Time_", yr, ".png", sep="")
## dis.depth.figname <- paste(getwd(), "/stn112_DisDept_vs_Time_", yr, ".png", sep="")
## et.catch.figname <- paste(getwd(), "/stn112_ET_vs_Time_catchment_", yr, ".png", sep="")
## et.riper.figname <- paste(getwd(), "/stn112_ET_vs_Time_riparian_", yr, ".png", sep="")

## dis.figname <- paste(getwd(), "/stn112_Dis_vs_Time_", yr, ".pdf", sep="")
## dis.depth.figname <- paste(getwd(), "/stn112_DisDept_vs_Time_", yr, ".pdf", sep="")
## et.catch.figname <- paste(getwd(), "/stn112_ET_vs_Time_catchment_", yr, ".pdf", sep="")
## et.riper.figname <- paste(getwd(), "/stn112_ET_vs_Time_riparian_", yr, ".pdf", sep="")

## hydrograph.pdf <- paste(getwd(), "/HydroGraph_stn112_tbrg_102_", yr, ".pdf", sep="")
## hydrograph.png <- paste(getwd(), "/HydroGraph_stn112_tbrg_102_", yr, ".png", sep="")
## hydrograph.csv <- paste(getwd(), "/HydroGraph_stn112_tbrg_102_", yr, ".csv", sep="")
## p1 <- 10.3833 ## wher is this from, not consistent with flume equation
## p3 <- 3.1399
## getting equation from <http://www.openchannelflow.com/products/flumes/montana/discharge-tables>
p1 <- .1771  ## 1.765 ## Bagiger gave:  p1 <- 0.1771 ## site gives .1765
p3 <- 1.55
wlr112.dat$Discharge <- p1*(wlr112.dat$Stage)^p3
wlr112.dat$DepthDischarge <- (wlr112.dat$Discharge/ar.cat)*1e+9
wlr112.dat <- subset(wlr112.dat, select=c("Stage", "date_time", "Discharge", "DepthDischarge"))
wlr112.dat <- wlr112.dat[!is.na(wlr112.dat$Stage),]
names(wlr112.dat) <- c("Capacitance","Stage", "Timestamp", "Discharge", "DepthDischarge")


## ggtitle.dis <- "Discharge Versus Time, Wattle Catchment"
## ggtitle.et.catch <- "Daily ET Versus Time, Wattle Catchment"
## ggtitle.et.riper <- "Daily ET versus time\nWATTLE RIPARIAN AREA"
## assign(paste("wlr112.dat.112_",yr, sep=""), wlr112.dat)
## wlr112.dat.112 <- wlr112.dat ## save to unique filename
## assign(paste("wlr112.dat.gr_",yr, sep=""), wlr112.dat)

