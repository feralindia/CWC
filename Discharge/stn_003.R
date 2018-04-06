## updated 2017-07-08 NOT TO BE USED
## NOTE: THIS SCRIPT IS NOT USEABLE AS OF NOW. NEEDS TO BE FIXED
## Aghnashini wlr_003 Saimane Weir

##-- define constants
stn.no <- "003"
ar.cat <- 0000.060  ## This needs to be updated
catch.type <- "Saimane"
wlr.path <- "~/CurrProj/CWC/Data/Aghnashini/wlr/csv/"
wlr.flnm <- "wlr_003_15 min.csv"
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")

## call the nls.fit function to get confidence bands around the fit
## source("./nls.fit.R", echo=TRUE)

##--- call function to get rating curve and calculate discharge
wlr.dat.all <- calc.disch.areastage(wlr.flnm, wlr.flnm.full)
wlr.dat.all$Timestamp <- as.POSIXct(wlr.dat.all$Timestamp, tz="Asia/Kolkata")
wlr.dat.all <- subset(wlr.dat.all, !duplicated(wlr.dat.all$Timestamp)) # remove duplicates
wlr.dat.all.sorted <- wlr.dat.all[order(wlr.dat.all$Timestamp, na.last=FALSE),]
## wlr.dat.all <- wlr.dat.all[!is.na(wlr.dat.all$Stage),]
## wlr.dat.all$Discharge <- round(wlr.dat.all$Discharge, digits=5)
hrly.depth.dis <- depth.dis(wlr.dat.all, "hour")
daily.depth.dis <- depth.dis(wlr.dat.all, "day")

