## Process data for station 101 - Wattle
ar.cat <- 293562.5 ## Original is 293562.5 ## By other calculations 275462.5 OR 232480.336 OR 242941.951 depending on parameters selected in GRASS
catch.type <- "Wattle Catchment"
wlr.flnm <- "wlr_101_1 hour.csv"
wlr.flnm.full <- paste(wlr.dir, wlr.flnm, sep="")

for(i in 1:length(wlr.flnm))(assign(wlr.flnm[i], read.csv(wlr.flnm.full[i], row.names=1))) 
wlr.dat.all <- get(wlr.flnm[1])
if(length(wlr.flnm)>1)for(i in 2:length(wlr.flnm))(wlr.dat.all <- rbind(wlr.dat.all, get(wlr.flnm[i])))
wlr.dat.all <- wlr.dat.all[,-4]
wlr.dat.all <- wlr.dat.all[!is.na(wlr.dat.all$cal),]
names(wlr.dat.all) <- c("Capacitance", "Stage", "Timestamp")
wlr.dat.all$Timestamp <- as.POSIXct(wlr.dat.all$Timestamp, tz="Asia/Kolkata")

##--- Calculate the discharge for compound weir --##
wlr.lowstage <- wlr.dat.all[wlr.dat.all$Stage<=0.603, ]
wlr.highstage <-  wlr.dat.all[wlr.dat.all$Stage>0.603, ]
wlr.lowstage$Discharge <- 1.09*(1.393799*((wlr.lowstage$Stage-0.2065)^2.5))
wlr.highstage$Discharge <- 1.09*((1.394*(((wlr.highstage$Stage-0.2065)^2.5) -
                                               ((wlr.highstage$Stage-0.603)^2.5))) +
                                       (0.719*(wlr.highstage$Stage-0.603)^1.5))
wlr.dat.all <- rbind(wlr.lowstage, wlr.highstage)
wlr.dat.all$Timestamp <- as.POSIXct(wlr.dat.all$Timestamp)
wlr.dat.all <- wlr.dat.all[order(wlr.dat.all$Timestamp, na.last=FALSE),]
wlr.dat.all$Discharge <- round(wlr.dat.all$Discharge, digits=5)
wlr.dat.all$DepthDischarge <- (wlr.dat.all$Discharge/ar.cat)*1000
