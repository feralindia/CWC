##- note coding in progress- this is based on stn_103
## updated 10th March 2016

##-- define constants
stn.no <- 106
ar.cat <- 925662.45 ## checked March '16
catch.type <- "Grassland Catchment"
wlr.path <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
wlr.flnm <- c("wlr_106_1 min.csv", "wlr_106a_1 min.csv")
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")

## call the nls.fit function to get confidence bands around the fit
## source("./nls.fit.R", echo=TRUE)

##--- call function to get rating curve and calculate discharge
wlr.dat.all <- calc.disch.areastage(wlr.flnm,wlr.flnm.full)
wlr.dat.all$Timestamp <- as.POSIXct(wlr.dat.all$Timestamp, tz="Asia/Kolkata")

##-- run routine to get data from flume or other stations
## note the data structure should be same as wlr.dat.all
source("stn_111.R", echo=TRUE)

wlr.dat.all <- rbind(wlr.dat.all, wlr111.dat)
wlr.dat.all <- wlr.dat.all[complete.cases(wlr.dat.all$Stage),]

##--- calculate depth of discharge ----##
wlr.dat.all$DepthDischarge <- (wlr.dat.all$Discharge/ar.cat)*1e+9
wlr.dat.all.sorted <- wlr.dat.all[order(wlr.dat.all$Timestamp, na.last=FALSE),]
wlr.dat.all <- wlr.dat.all[!is.na(wlr.dat.all$Stage),]
wlr.dat.all$Discharge <- round(wlr.dat.all$Discharge, digits=5)

