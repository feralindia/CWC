## Process data for station 113 -- 

wlr.path <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
wlr.flnm <- "wlr_113_1 min.csv" # contatenated multiple names area allowed
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")
## Import data and calculate flume discharge by calling the function
wlr113.dat <- calc.disch.flume(wlr.flnm,wlr.flnm.full)
wlr113.dat$Timestamp <- as.POSIXct(wlr113.dat$Timestamp, tz="Asia/Kolkata")
