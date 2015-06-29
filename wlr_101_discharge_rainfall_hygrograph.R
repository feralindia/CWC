library(EcoHydRology)
##  hyd.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/hydrograph/"
hyd.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hydrograph/"
hydout.csv <- paste(hyd.dir, "wlr_101_tbrg_102_15min.csv", sep="")
hydout.pdf <- paste(hyd.dir, "wlr_101_tbrg_102_15min.pdf", sep="")
## tbrg <- read.csv("/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/tbrg/csv/tbrg_001_15 minutes.csv")
tbrg <- read.csv("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv/tbrg_102_15 minutes.csv")
tbrg$dt.tm <- as.POSIXct(tbrg$dt)
## wlr<- read.csv("~/OngoingProjects/CWC/Data/Aghnashini/wlr/csv/001_onemin.merged.csv")
wlr<- tmp.data
wlr$dt.tm <- as.POSIXct(wlr$date_time)
## wlr$cal[wlr$dt.tm < "2012-09-10 16:33:50"] <- wlr$cal+34# add 34 cm to the stage reading
wlr.tbrg <- merge(wlr, tbrg, by="dt.tm", allx=TRUE)
hyd.data <- subset(wlr.tbrg, select=c(dt.tm, mm_rain, qa))
names(hyd.data) <- c("date", "P_mm", "Discharge_m")
##png(filename="/home/udumbu/rsb/tmp/stage_precip_001.png", width=1200, height=800, pointsize=10, type="cairo-png")
pdf(file=hydout.pdf, title="WLR 101 average discharge, TBRG 102 cumulative rainfall for 15 minutes", paper="a4r", width=11.3, height=8.7)
hydrograph(hyd.data, stream.label="Instantaneous Discharge at m^3/sec", P.units="mm", S1.col="blue")
title(main="Lakdihalla Weir WLR 101 vs Lakdihalla TBRG 102 - 15 minute data")
dev.off()
write.csv(file=hydout.csv, hyd.data)


### for tbrg 101 at kollaribetta

hydout.csv <- paste(hyd.dir, "wlr_101_tbrg_101_15min.csv", sep="")
hydout.pdf <- paste(hyd.dir, "wlr_101_tbrg_101_15min.pdf", sep="")
## tbrg <- read.csv("/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/tbrg/csv/tbrg_001_15 minutes.csv")
tbrg <- read.csv("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv/tbrg_101_15 minutes.csv")
tbrg$dt.tm <- as.POSIXct(tbrg$dt)
## wlr<- read.csv("~/OngoingProjects/CWC/Data/Aghnashini/wlr/csv/001_onemin.merged.csv")
wlr<- tmp.data
wlr$dt.tm <- as.POSIXct(wlr$date_time)
## wlr$cal[wlr$dt.tm < "2012-09-10 16:33:50"] <- wlr$cal+34# add 34 cm to the stage reading
wlr.tbrg <- merge(wlr, tbrg, by="dt.tm", allx=TRUE)
hyd.data <- subset(wlr.tbrg, select=c(dt.tm, mm_rain, qa))
names(hyd.data) <- c("date", "P_mm", "Discharge_m")
##png(filename="/home/udumbu/rsb/tmp/stage_precip_001.png", width=1200, height=800, pointsize=10, type="cairo-png")
## pdf(file=hydout.pdf, title="WLR 101 average discharge, TBRG 101 cumulative rainfall for 15 minutes", paper="a4r", width=11.3, height=8.7)
hydrograph(hyd.data, stream.label="Instantaneous Discharge at m^3/sec", P.units="mm", S1.col="blue")
##title(main="Lakdihalla Weir WLR 101 vs Kolaribetta TBRG 101- 15 minute data")
## dev.off()
write.csv(file=hydout.csv, hyd.data)

