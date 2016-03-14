## Station 103 is associated with:
## wlr: 103, 103a
## flume: 113
## tbrg: 103, 109
## bs: 102, 123
## this script collates data for wlr 103 & 103a and
## runs a routine for flume 113

##--- define constants
stn.no <- 102
ar.cat <- 748462.5
catch.type <- "Wattle Catchment"
wlr.path <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
wlr.flnm <- "wlr_102_1 min.csv"
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")

## call the nls.fit function to get confidence bands around the fit
## source("./nls.fit.R", echo=TRUE)

##--- call function to get rating curve and calculate discharge
wlr.dat.all <- calc.disch.areastage(wlr.flnm,wlr.flnm.full)
wlr.dat.all$Timestamp <- as.POSIXct(wlr.dat.all$Timestamp, tz="Asia/Kolkata")

##-- run routine to get data from flume or other stations
## note the data structure should be same as wlr.dat.all

source("stn_112.R", echo=TRUE)

wlr.dat.all <- rbind(wlr.dat.all, wlr112.dat)

##--- calculate depth of discharge ----##
wlr.dat.all$DepthDischarge <- (wlr.dat.all$Discharge/ar.cat)*1e+9
wlr.dat.all.sorted <- wlr.dat.all[order(wlr.dat.all$Timestamp, na.last=FALSE),]
wlr.dat.all <- wlr.dat.all[!is.na(wlr.dat.all$Stage),]
wlr.dat.all$Discharge <- round(wlr.dat.all$Discharge, digits=5)

