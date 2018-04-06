## updated 2017-04-15
## Aghnashini wlr_001 Saimane
library(reshape2)
##-- define constants
stn.no <- "001"
ar.cat <- 5262940.060  ## based on grassdata/cwc_agn/elevation/WLR_001_catchment
catch.type <- "Saimane"
wlr.path <- "~/Res/CWC/Data/Aghnashini/wlr/csv/"
wlr.flnm <- c("wlr_001_1 hour.csv", "wlr_01b_1 hour.csv", "wlr_01c_1 hour.csv", "wlr_01d_1 hour.csv", "wlr_01e_1 hour.csv")
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")

## call the nls.fit function to get confidence bands around the fit
## source("./nls.fit.R", echo=TRUE)

##--- call function to get rating curve and calculate discharge
wlr.dat.all <- calc.disch.areastage(wlr.flnm, wlr.flnm.full)
wlr.dat.all$Timestamp <- as.POSIXct(wlr.dat.all$Timestamp, tz="Asia/Kolkata")
##-- repeat for lancaster equations
## uncomment to run
wlr.dat.all.lu <- calc.disch.areastage.lu(wlr.flnm,wlr.flnm.full)
wlr.dat.all.lu$Timestamp <- as.POSIXct(wlr.dat.all.lu$Timestamp, tz="Asia/Kolkata")

wlr.dat.all <- subset(wlr.dat.all, !duplicated(wlr.dat.all$Timestamp)) # remove duplicates
wlr.dat.all.sorted <- wlr.dat.all[order(wlr.dat.all$Timestamp, na.last=FALSE),]

wlr.dat.all.lu <- subset(wlr.dat.all.lu, !duplicated(wlr.dat.all.lu$Timestamp)) # remove duplicates
wlr.dat.all.lu.sorted <- wlr.dat.all.lu[order(wlr.dat.all.lu$Timestamp, na.last=FALSE),]

ggdat <- cbind(wlr.dat.all.sorted, wlr.dat.all.lu.sorted$Discharge)
colnames(ggdat)[c(4,5)] <- c("Ind", "UK")
ggdat <- melt(ggdat, measure.vars = c("Ind", "UK"), variable.name = "Equation", value.name = "Discharge")
ggdat.sliced <- ggdat[ggdat$Timestamp > "2013-08-01 00:00:00 IST" & ggdat$Timestamp < "2013-09-01 00:00:00 IST", ]
ggplot(data = ggdat.sliced, aes(x = Timestamp, y = Discharge, color = Equation)) +
    geom_line()

ggsave("~/tmp/StageData/Aug2013_hr.png")


ggplot(data = ggdat.sliced, aes(x = Timestamp, y = Discharge, color = Equation)) +
    geom_boxplot()
ggsave("~/tmp/StageData/Aug2013_bxp_hr.png")


## wlr.dat.all <- wlr.dat.all[!is.na(wlr.dat.all$Stage),]
## wlr.dat.all$Discharge <- round(wlr.dat.all$Discharge, digits=5)
hrly.depth.dis <- depth.dis(wlr.dat.all, "hour")
daily.depth.dis <- depth.dis(wlr.dat.all, "day")

