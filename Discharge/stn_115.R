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
hgt.diff <- 0.1661 # height difference b/w weir and wlr

wlr.path <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
wlr.flnm <- "wlr_115_1 min.csv"
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")

##--- call function to get rating curve and calculate discharge
wlr.dat.all <- calc.disch.weir(wlr.flnm, wlr.flnm.full )
wlr.dat.all$Timestamp <- as.POSIXct(wlr.dat.all$Timestamp, tz="Asia/Kolkata")

##--- calculate depth of discharge ----##
wlr.dat.all$DepthDischarge <- (wlr.dat.all$Discharge/ar.cat)*1e+9
wlr.dat.all.sorted <- wlr.dat.all[order(wlr.dat.all$Timestamp, na.last=FALSE),]
wlr.dat.all <- wlr.dat.all[!is.na(wlr.dat.all$Stage),]
wlr.dat.all$Discharge <- round(wlr.dat.all$Discharge, digits=5)
