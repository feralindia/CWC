##- note coding in progress- this is based on stn_103
## updated 10th March 2016

##-- define constants
stn.no <- 108
ar.cat <- 2453662.50 # confirmed March `16
catch.type <- "Wattle Catchment"
wlr.path <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
wlr.flnm <- c("wlr_108_1 hour.csv", "wlr_108a_1 hour.csv")
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")

## call the nls.fit function to get confidence bands around the fit
## source("./nls.fit.R", echo=TRUE)

##--- call function to get rating curve and calculate discharge
wlr.dat.all <- calc.disch.areastage(wlr.flnm,wlr.flnm.full)
wlr.dat.all$Timestamp <- as.POSIXct(wlr.dat.all$Timestamp, tz="Asia/Kolkata")

##--- calculate depth of discharge ----##
wlr.dat.all$DepthDischarge <- (wlr.dat.all$Discharge/ar.cat)*1e+9
wlr.dat.all.sorted <- wlr.dat.all[order(wlr.dat.all$Timestamp, na.last=FALSE),]
wlr.dat.all <- wlr.dat.all[!is.na(wlr.dat.all$Stage),]
wlr.dat.all$Discharge <- round(wlr.dat.all$Discharge, digits=5)

