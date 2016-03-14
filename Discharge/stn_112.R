## Process data for station 112 -- 

wlr.path <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
wlr.flnm <- "wlr_112_1 min.csv" # contatenated multiple names area allowed
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")
## Import data and calculate flume discharge by calling the function
wlr112.dat <- calc.disch.flume(wlr.flnm,wlr.flnm.full)
wlr112.dat$Timestamp <- as.POSIXct(wlr112.dat$Timestamp, tz="Asia/Kolkata")
