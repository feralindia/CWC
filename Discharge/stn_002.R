## updated 2017-04-15
## Aghnashini wlr_001 Saimane

##-- define constants
stn.no <- "002"
ar.cat <- 1051778.232  ## based on grassdata/cwc_agn/elevation/WLR_002_catchment
catch.type <- "Hosagadde"
wlr.path <- "~/CurrProj/CWC/Data/Aghnashini/wlr/csv/"
wlr.flnm <- "wlr_002_1 min.csv"
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")

## call the nls.fit function to get confidence bands around the fit
## source("./nls.fit.R", echo=TRUE)

##--- call function to get rating curve and calculate discharge
wlr.dat.all <- calc.disch.areastage(wlr.flnm, wlr.flnm.full)
wlr.dat.all$Timestamp <- as.POSIXct(wlr.dat.all$Timestamp, tz="Asia/Kolkata")
wlr.dat.all <- subset(wlr.dat.all, !duplicated(wlr.dat.all$Timestamp)) # remove duplicates
##--- calculate depth of discharge ----##
## wlr.dat.all$DepDisMin <- wlr.dat.all$Discharge/ar.cat *1000 *60
wlr.dat.all.sorted <- wlr.dat.all[order(wlr.dat.all$Timestamp, na.last=FALSE),]
## wlr.dat.all <- wlr.dat.all[!is.na(wlr.dat.all$Stage),]
## wlr.dat.all$Discharge <- round(wlr.dat.all$Discharge, digits=5)
hrly.depth.dis <- depth.dis(wlr.dat.all, "hour")
daily.depth.dis <- depth.dis(wlr.dat.all, "day")

