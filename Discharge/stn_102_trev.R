## Station 103 is associated with:
## wlr: 103, 103a
## flume: 113
## tbrg: 103, 109
## bs: 102, 123
## this script collates data for wlr 103 & 103a and
## runs a routine for flume 113

##--- define constants
stn.no <- 102
ar.cat <- 748462.5  ##748462.5
catch.type <- "Wattle Catchment"
wlr.path <- "/home/udumbu/rsb/Res/CWC/Data/Nilgiris/wlr/csv/"
wlr.flnm <- "wlr_102_1 hour.csv"
wlr.flnm.full <- paste(wlr.path, wlr.flnm, sep="")

## call the nls.fit function to get confidence bands around the fit
## source("./nls.fit.R", echo=TRUE)

##--- call function to get rating curve and calculate discharge
wlr.dat.all <- calc.disch.areastage(wlr.flnm,wlr.flnm.full)
wlr.dat.all$Timestamp <- as.POSIXct(wlr.dat.all$Timestamp, tz="Asia/Kolkata")

##-- repeat for lancaster equations
## uncomment to run
wlr.dat.all.lu <- calc.disch.areastage.lu(wlr.flnm,wlr.flnm.full)
wlr.dat.all.lu$Timestamp <- as.POSIXct(wlr.dat.all.lu$Timestamp, tz="Asia/Kolkata")


##-- run routine to get data from flume or other stations
## note the data structure should be same as wlr.dat.all

source("stn_112.R", echo=TRUE)

wlr.dat.all <- rbind(wlr.dat.all, wlr112.dat)
wlr.dat.all <- subset(wlr.dat.all, !duplicated(wlr.dat.all$Timestamp)) # remove duplicates


wlr.dat.all.lu <- rbind(wlr.dat.all.lu, wlr112.dat)
wlr.dat.all.lu <- subset(wlr.dat.all.lu, !duplicated(wlr.dat.all.lu$Timestamp)) 
##--- calculate depth of discharge ----##
## wlr.dat.all$DepDisMin <- wlr.dat.all$Discharge/ar.cat * 1000 * 60
## * 1000 to convert from m to mm, *60 to convert from per sec to per min
wlr.dat.all.sorted <- wlr.dat.all[order(wlr.dat.all$Timestamp, na.last=FALSE),]
wlr.dat.all.lu.sorted <- wlr.dat.all.lu[order(wlr.dat.all.lu$Timestamp, na.last=FALSE),]
## wlr.dat.all <- wlr.dat.all[!is.na(wlr.dat.all$Stage),]


ggdat <- cbind(wlr.dat.all.sorted, wlr.dat.all.lu.sorted$Discharge)
colnames(ggdat)[c(4,5)] <- c("Ind", "UK")
ggdat <- melt(ggdat, measure.vars = c("Ind", "UK"), variable.name = "Equation", value.name = "Discharge")
ggdat.sliced <- ggdat[ggdat$Timestamp > "2014-08-01 00:00:00 IST" & ggdat$Timestamp < "2014-09-01 00:00:00 IST", ]
ggplot(data = ggdat.sliced, aes(x = Timestamp, y = Discharge, color = Equation)) +
    geom_line()

ggsave("~/tmp/StageData/Wlr102Aug2014_hr_raw.png")


ggplot(data = ggdat.sliced, aes(x = Timestamp, y = Discharge, color = Equation)) +
    geom_boxplot()
ggsave("~/tmp/StageData/Wlr102Aug2014_bxp_hr_raw.png")


wlr.dat.all$Discharge <- round(wlr.dat.all$Discharge, digits=5)
hrly.depth.dis <- depth.dis(wlr.dat.all, "hour")
daily.depth.dis <- depth.dis(wlr.dat.all, "day")
