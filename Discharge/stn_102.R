##-- calculate the rating parameters
##-- updated 21 Feb 2016 to be based on cleaned rating data
## First run wlr_112.R to get the data for dry months for year 2015
ar.cat <- 748462.5
catch.type <- "Wattle Catchment"
## stn.names(102, 102) ## should be done in the hydgrph.R script
if(yr==2015) source("stn_112.R", echo=TRUE)

## now proceed with wlr_102 calculations

summ.csvname <- paste(getwd(), "/stn102_Summary_", yr, ".csv", sep="")
dis.csvname <- paste(getwd(), "/stn102_Discharge_", yr, ".csv", sep="")
ET.csvname <- paste(getwd(), "/stn102_ET_", yr, ".csv", sep="")
## dis.figname <- paste(getwd(), "/stn102_Dis_vs_Time_", yr, ".png", sep="")
## dis.depth.figname <- paste(getwd(), "/stn102_DisDept_vs_Time_", yr, ".png", sep="")
## et.catch.figname <- paste(getwd(), "/stn102_ET_vs_Time_catchment_", yr, ".png", sep="")
## et.riper.figname <- paste(getwd(), "/stn102_ET_vs_Time_riparian_", yr, ".png", sep="")

dis.figname <- paste(getwd(), "/stn102_Dis_vs_Time_", yr, ".pdf", sep="")
dis.depth.figname <- paste(getwd(), "/stn102_DisDept_vs_Time_", yr, ".pdf", sep="")
et.catch.figname <- paste(getwd(), "/stn102_ET_vs_Time_catchment_", yr, ".pdf", sep="")
et.riper.figname <- paste(getwd(), "/stn102_ET_vs_Time_riparian_", yr, ".pdf", sep="")

hydrograph.pdf <- paste(getwd(), "/HydroGraph_stn102_tbrg_102_", yr, ".pdf", sep="")
hydrograph.png <- paste(getwd(), "/HydroGraph_stn102_tbrg_102_", yr, ".png", sep="")
hydrograph.csv <- paste(getwd(), "/HydroGraph_stn102_tbrg_120_", yr, ".csv", sep="")
### pat <- "wlr_102_1 min.csv"
### wlr.flst <- list.files(path=paste(data.dir,"/wlr/csv", sep=""),
###                       pattern=pat, full.names=TRUE)
sd.flst <- list.files(path=paste(data.dir, "/cleaned.rating/csv", sep=""),
                      pattern="WLD_102_SD.csv$", full.names=TRUE)
sd.fl <- read.csv(sd.flst)
sd.fl <- subset(sd.fl, select=c("stage", "avg.disch"))
names(sd.fl) <- c("Stage", "Discharge")
##-- run non-linear least square regression
nls.res <- nls(Discharge~p1*(Stage)^p3,data=sd.fl, start=list(p1=3,p3=5))
coef.p1 <- as.numeric(coef(nls.res)[1])
coef.p3 <- as.numeric(coef(nls.res)[2])
### wlr.dat <- read.csv(wlr.flst)
### names(wlr.dat)[3] <- "Stage" ## check this HERE
wlr.dat$Discharge <- coef.p1 * (wlr.dat$Stage)^coef.p3

##--- calculate depth of discharge ----##
wlr.dat$DepthDischarge <- (wlr.dat$Discharge/ar.cat)*1e+9
plot(wlr.dat$Stage, wlr.dat$Discharge, type="p",
     main="Stage Discharge Curve for V-notch at Lakdi - stn 102",
     xlab="Stage (m)", ylab="Discharge (m^3/sec)")

## Organise for ggplot

wlr.dat <- subset(wlr.dat, select=c("Capacitance","Stage", "date_time", "Discharge", "DepthDischarge", "Discharge.hr"))
names(wlr.dat) <- c("Stage", "Timestamp", "Discharge", "DepthDischarge", "Discharge.hr"

##--- yank in data from wlr_112.R
if(yr==2015) {
wlr.dat <- wlr.dat[!is.na(wlr.dat$Stage),]
wlr.dat <- rbind(wlr.dat, wlr112.dat)
}
wlr.dat <- wlr.dat[order(wlr.dat$Timestamp),]

wlr.dat$Date <- as.Date(wlr.dat$Timestamp, "%Y-%m-%d"))

ggtitle.dis <- "Discharge Versus Time, Wattle Catchment"
ggtitle.et.catch <- "Daily ET Versus Time, Wattle Catchment"
assign(paste("wlr.dat.102_",yr, sep=""), wlr.dat)
wlr.dat.102 <- wlr.dat ## save to unique filename
assign(paste("wlr.dat.wt_",yr, sep=""), wlr.dat)
