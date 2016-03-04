## Process data for station 110 -- grassland
ar.cat <- 692762.5## ORIGINAL IS 692762.5 ##69.276250000000005  605362.5 OR 437425.5
catch.type <- "Grassland Catchment"
stn.names(110, 113) ## use function to assign names
summ.csvname <- paste(getwd(), "/stn110_Summary_", yr, ".csv", sep="")
dis.csvname <- paste(getwd(), "/stn110_Discharge_", yr, ".csv", sep="")
ET.csvname <- paste(getwd(), "/stn110_ET_", yr, ".csv", sep="")
## dis.figname <- paste(getwd(), "/stn110_Dis_vs_Time_", yr, ".png", sep="")
## dis.depth.figname <- paste(getwd(), "/stn110_DisDept_vs_Time_", yr, ".png", sep="")
## et.catch.figname <- paste(getwd(), "/stn110_ET_vs_Time_catchment_", yr, ".png", sep="")
## et.riper.figname <- paste(getwd(), "/stn110_ET_vs_Time_riparian_", yr, ".png", sep="")

dis.figname <- paste(getwd(), "/stn110_Dis_vs_Time_", yr, ".pdf", sep="")
dis.depth.figname <- paste(getwd(), "/stn110_DisDept_vs_Time_", yr, ".pdf", sep="")
et.catch.figname <- paste(getwd(), "/stn110_ET_vs_Time_catchment_", yr, ".pdf", sep="")
et.riper.figname <- paste(getwd(), "/stn110_ET_vs_Time_riparian_", yr, ".pdf", sep="")

hydrograph.pdf <- paste(getwd(), "/HydroGraph_stn110_tbrg_113_", yr, ".pdf", sep="")
hydrograph.png <- paste(getwd(), "/HydroGraph_stn110_tbrg_113_", yr, ".png", sep="")
hydrograph.csv <- paste(getwd(), "/HydroGraph_stn110_tbrg_113_", yr, ".csv", sep="")
## p1 <- 10.3833 ## wher is this from, not consistent with flume equation
## p3 <- 3.1399
## getting equation from <http://www.openchannelflow.com/products/flumes/montana/discharge-tables>
p1 <- .1765 ## Badiger gave:  p1 <- 0.1771 ## site gives .1765
p3 <- 1.55
wlr.dat$Discharge <- p1*(wlr.dat$Stage)^p3
wlr.dat$Discharge.hr <- wlr.dat$Discharge * 3600 ## get hourly discharge
wlr.dat$DepthDischarge <- (wlr.dat$Discharge.hr/ar.cat)*1000 ## in mm per hour
wlr.dat <- subset(wlr.dat, select=c("Stage", "date_time", "Discharge", "DepthDischarge", "Discharge.hr"))
names(wlr.dat) <- c("Capacitance","Stage", "Timestamp", "Discharge", "DepthDischarge", "Discharge.hr")

wlr.dat$Date <- as.Date(wlr.dat$Timestamp, "%Y-%m-%d")
ggtitle.dis <- "Discharge Versus Time, Grassland Catchment"
ggtitle.et.catch <- "Daily ET Versus Time, Grassland Catchment"
ggtitle.et.riper <- "Daily ET versus time\nGRASSLAND RIPARIAN AREA"
assign(paste("wlr.dat.110_",yr, sep=""), wlr.dat)
## fill NA values with averages of previous and next value

wlr.dat.110 <- wlr.dat ## save to unique filenamae
assign(paste("wlr.dat.gr_",yr, sep=""), wlr.dat)

