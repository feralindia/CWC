## Process data for station 111 -- grassland

wlr.path <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
wlr.flnm <- "wlr_111_1 hour.csv" # contatenated multiple names area allowed
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")
## Import data and calculate flume discharge by calling the function
wlr111.dat <- calc.disch.flume(wlr.flnm,wlr.flnm.full)
wlr111.dat$Timestamp <- as.POSIXct(wlr111.dat$Timestamp, tz="Asia/Kolkata")
