## Process data for station 110 -- grassland

## catch.type <- "Grassland Catchment"

wlr.path <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
wlr.flnm <- "wlr_110_1 min.csv" # contatenated multiple names area allowed
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")
## Import data and calculate flume discharge by calling the function
wlr110.dat <- calc.disch.flume(wlr.flnm,wlr.flnm.full)
wlr110.dat$Timestamp <- as.POSIXct(wlr110.dat$Timestamp, tz="Asia/Kolkata")
