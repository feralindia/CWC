csv.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
wlr.file <- "wlr_101_1 min.csv"
wlr.stage <- read.csv(paste(csv.dir, wlr.file, sep=""))
wlr.lowstage <- wlr.stage[wlr.stage$cal<=0.603, ]
wlr.highstage <-  wlr.stage[wlr.stage$cal>0.603, ]
wlr.lowstage$discharge.m3sec <- 1.09*(1.393799*((wlr.lowstage$cal-0.2065)^2.5))
wlr.highstage$discharge.m3sec <- 1.09*((1.394*(((wlr.highstage$cal-0.2065)^2.5) - ((wlr.highstage$cal-0.603)^2.5))) + (0.719*(wlr.highstage$cal-0.603)^1.5))
wlr.discharge <- rbind(wlr.lowstage, wlr.highstage)
wlr.discharge$date_time <- as.POSIXct(wlr.discharge$date_time)
wlr.discharge.sorted <- wlr.discharge[order(wlr.discharge$date_time, na.last=FALSE),]
discharge_wlr_101 <- subset(wlr.discharge.sorted, select=c("raw", "cal", "date_time", "discharge.m3sec"))
names(discharge_wlr_101) <- c("Capacitance", "Stage_m", "date_time", "Discharge_m3s")
discharge_wlr_101$Discharge_m3s <- round(discharge_wlr_101$Discharge_m3s, digits=5)
write.csv(discharge_wlr_101, file="/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/results/discharge_wlr101.csv")
