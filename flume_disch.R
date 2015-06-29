# This equation works in metres.
# divide capacitance values by 100 before pluggin in
# as there are only few flumes this is being done manually.
# the sql statement is self evident.
## Plot the stage-discharge and discharge-stage curves based on WLR readings
library(RPostgreSQL)
library(yaml)
conf <- yaml.load_file(paste(rdata.dr,"db.config.yml", sep=""))
con <- dbConnect(PostgreSQL(), host=conf$db$host, dbname=conf$db$name, user=conf$db$user, password=conf$db$pass)
##disch <- .1771 * (wlr_cal/100)^1.55

##------------------   These are for the flumes at Aghnashini-----------------------------#####

stm.wlr020 <- "SELECT wl_cal/100 AS Stage, 0.1771*((wl_cal/100)^1.55)
AS Discharge FROM agnashini.wlr_020 WHERE wl_cal/100>0"

stm.wlr021 <- "SELECT wl_cal/100 AS Stage, 0.1771*((wl_cal/100)^1.55)
AS Discharge FROM agnashini.wlr_021 WHERE wl_cal/100>0"

## pull in the results, save to csv and plot
csvdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/disch/csv/"
figdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/disch/fig/"
wlrnum <- c("020", "021")
for (i in 1:length(wlrnum)){
    stm <- get(paste("stm.wlr", wlrnum[i], sep=""))
    rs <- dbSendQuery(con,stm)
    data <- fetch(rs, n = -1)
    csvout<-paste(csvdir, "StageDischarge_", wlrnum[i] ,".csv", sep="")
    figoutSD<-paste(figdir, "StageDischarge_", wlrnum[i] ,".png", sep="")
    figoutDS<-paste(figdir, "DischargeStage_", wlrnum[i] ,".png", sep="")
    figtitle <- paste("Stage Discharge Curve -- WLR ", wlrnum[i], sep="")
    write.csv(data, file=csvout)
    

    png(filename=figoutSD, width=640, height=480, units="px", pointsize=12, type="cairo")
    plot(data$stage/100, data$discharge, type="p", main=figtitle, xlab="StageStage (m)", ylab="Discharge (m^3/sec)") 
    dev.off()

    png(filename=figoutDS, width=640, height=480, units="px", pointsize=12, type="cairo")
    plot(data$discharge, data$stage/100, type="p", main=figtitle, xlab="Discharge (m^3/sec)", ylab="Stage (m)") 
    
    dev.off()
}


##------------------   This is for the v-notch at the  Nilgiris  -----------------------------#####
## Note height of v-notch above WLR is suspect. Was .0952 but changed here in line 4 of stm
stm <- "DROP TABLE IF EXISTS nilgiris.wlr_101tmp;
CREATE TABLE nilgiris.wlr_101tmp AS 
SELECT date_time AS tstmp, wl_cal/100 AS stg, 
(wl_cal/100)-0.0952 AS h_big,  
(SELECT (wl_cal/100)-.495 WHERE ((wl_cal/100)-.495)>0) h_sml, 
9.81 AS g, 0.21 AS b, 0.59 AS c1, 0.58 AS c2 
FROM nilgiris.wlr_101;
UPDATE nilgiris.wlr_101tmp
SET h_sml=0 WHERE h_sml IS NULL;
SELECT * FROM nilgiris.wlr_101tmp;"
                                        # select all variables required for the formula
rs <- dbSendQuery(con,stm)
data <- fetch(rs, n = -1)
write.csv(data, file="/home/udumbu/rsb/tmp/sqldata.csv")
attach(data)
qt <- (8/15 * c1 * sqrt(2*g) * ((h_big ^ 5/2) - (h_sml ^ 5/2))) + (2/3 * c2 * sqrt(2 * g) * (2*b) * h_sml ^ 5/2) ## corrected replaced 2/3 by 5/2
qa <- 1.09 * qt
data$qt <- qt
data$qa <- qa
    write.csv(data, file="/home/udumbu/rsb/tmp/result.csv")
## png(filename="/home/udumbu/rsb/tmp/StDis_wlr101.png", width=640, height=480, units="px", pointsize=12, type="cairo")
plot(stg, qa, type="p", main="Stage Discharge Curve for V-notch at Kolaribetta",
     xlab="StageStage (m)", ylab="Discharge (m^3/sec)")
##dev.off()
summary(data)

## png(filename="/home/udumbu/rsb/tmp/DateDis_wlr101.png", width=640, height=480, units="px", pointsize=12, type="cairo")
plot(tstmp, qa, type="p", main="Hydrograph for V-notch at Kolaribetta",
     xlab="Date (m)", ylab="Discharge (m^3/sec)")
##dev.off()
detach(data)
##------------------   These are for the flumes at Nilgiris  -----------------------------#####


stm.wlr020 <- "SELECT wl_cal/100 AS Stage, 0.1771*((wl_cal/100)^1.55)
AS Discharge FROM agnashini.wlr_020 WHERE wl_cal/100>0"## For flumes in Nilgiris

## pull in the results, save to csv and plot
csvdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/disch/csv/"
figdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/disch/fig/"
wlrnum <- c("102", "103", "106")
for (i in 1:length(wlrnum)){
    stm <- get(paste("stm.wlr", wlrnum[i], sep=""))
    rs <- dbSendQuery(con,stm)
    data <- fetch(rs, n = -1)
    csvout<-paste(csvdir, "StageDischarge_", wlrnum[i] ,".csv", sep="")
    figoutSD<-paste(figdir, "StageDischarge_", wlrnum[i] ,".png", sep="")
    figoutDS<-paste(figdir, "DischargeStage_", wlrnum[i] ,".png", sep="")
    figtitle <- paste("Stage Discharge Curve -- WLR ", wlrnum[i], sep="")
    write.csv(data, file=csvout)

    png(filename=figoutSD, width=640, height=480, units="px", pointsize=12, type="cairo")
    plot(data$stage/100, data$discharge, type="p", main=figtitle, xlab="StageStage (m)", ylab="Discharge (m^3/sec)") 
    dev.off()

    png(filename=figoutDS, width=640, height=480, units="px", pointsize=12, type="cairo")
    plot(data$discharge, data$stage/100, type="p", main=figtitle, xlab="Discharge (m^3/sec)", ylab="Stage (m)") 
    
    dev.off()
}


##------------------   For the flume at WLR 003 and 003a at Aghnishini - note the data has been merged -------------------------#####
## Calculations based on Shrini's formula as below:
## Discharge, Q = 4969 * (H ^ 2.5)
## Q = m3/hour
## H = meters above the crest = [stage (in meters) – 0.47]
## pull in the results, and plot
files <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/wlr/share", pattern=".csv", full.names=TRUE)
filenames <-  list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/wlr/share/", pattern=".csv", full.names=FALSE)
filenames <- substrLeft(filenames, 4)
for (i in 1: length(files)){
file <- infiles[i]
filename <- paste(filenames[i], ".png", sep="")
data <- read.csv(file)
names(data) <- c("stage", "date_time")
## From Shrinivas Badiger's formula
H <- (data$stage/100) - 0.47
H[H<0] <- NA # remove all heights below 47cm (height of notch)
data$discharge <- 4969*((H)^2.5) # this formula needs checking
data$date_time <- as.POSIXct(data$date_time, tz="Asia/Kolkata")
figdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/disch/fig/"
figoutDisDate <- paste(figdir, "DischargeDate_", filename, sep="")
figoutDisStg<-paste(figdir, "DischargeStage_", filename, sep="")
figtitle <- paste("Stage Discharge Curve -- ", filename, sep="")

    png(filename=figoutDisStg, width=640, height=480, units="px", pointsize=12, type="cairo")
    plot(data$stage/100, data$discharge, type="p", main=figtitle, xlab="StageStage (m)", ylab="Discharge (m^3/hour)") 
    dev.off()

    png(filename=figoutDisDate, width=640, height=480, units="px", pointsize=12, type="cairo")
    plot(data$date_time, data$discharge, type="p", main=figtitle, xlab="Date", ylab="Stage (m)Discharge (m^3/hour)") 
    
    dev.off()
}






##disch <- .1771 * (wlr_cal/100)^1.55
## Need to yank in calibration values for wlr 020 and 021
