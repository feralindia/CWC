## Generate a hydrograph for the specified time period
## input: wlr no, tbrg no, start time, end time
## output: csv, figure
## NOTE THAT THIS SCRIPT OPERATES ON AN HOURLY DISCHARGE BASIS.
## Updated March 2016

##-- Load required libraries
library(timeSeries)
library(hydrostats)
library(EcoHydRology)
library(ggplot2)
library(reshape2)
library(scales)
setRmetricsOptions(myFinCenter = "Asia/Calcutta")
##-- Set environment as appropriatestn
setwd(dir="~/GitHub/CWC/Hydrographs/")
hyd.code.dir <- "~/GitHub/CWC/Hydrographs/"
wlr.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
tbrg.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv/"
hygch.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/hygch/csv/"
sd.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/cleaned.rating/csv/"
hydrograph.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/hydrograph/"
data.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/"
## summ.hyd.csv <- paste(hydrograph.dir, "/wlr", stn.pairs$wlr[i], "_tbrg", stn.pairs$tbrg[i], "_Hydrograph_stats_", prd, ".csv", sep="")

####----SPECIFY DISCHARGE TYPE
## decide what type and units you want to show discharge (per hour) in.
discharge.type <- "Discharge"## Options are c("Capacitance", "Stage", "Discharge", "DepthDischarge")

####-------

if(discharge.type=="Discharge"){
    dis.units <- "m^3/hr"}else if(discharge.type=="Stage"){
                             dis.units <- "m"}else {dis.units <- "farad"}
##--- Load Functions ---##
source("hyd.functs.R", echo=FALSE)

##--- Write the numbers of the station and corresponding tbrg you'd like processed
##-- alernatively let the function "pair.units" create the list
## wlr.no <- c("101", "115")## , "109")
## tbrg.no <- c("102", "105")## , "116")
## stn.pairs <- as.data.frame(matrix(nrow=length(wlr.no), ncol=2))
## names(stn.pairs) <- c("wlr", "tbrg")
## stn.pairs[,1] <- wlr.no
## stn.pairs[,2] <- tbrg.no
stn.pairs <- pair.units("tbrg")

## Define start date, end date and interval in months
ts.start.tmstmp <- as.POSIXct("2015-06-01 00:00:00", tz="Asia/Kolkata")
ts.end.tmstmp <- as.POSIXct("2015-12-31 23:59:59", tz="Asia/Kolkata")
ts.interval <- "3 month" ## period of reporting
ts.start <- seq(ts.start.tmstmp, ts.end.tmstmp, ts.interval)
ts.end <- ts.start[-1] ## take all but first item of ts.start
ts.end <- ts.end-1 ## end is one second less than pervious start
ts.end[[length(ts.end)+1]] <- ts.end.tmstmp ## add last ts.end value

ts.years <- as.data.frame(matrix(nrow=length(ts.start),ncol=2))
names(ts.years) <- c("start", "end") # "year", 
## ts.years[,1] <- format(ts.start, "%Y")
ts.years[,1] <- as.POSIXct(ts.start, tz="Asia/Kolkata")
ts.years[,2] <- as.POSIXct(ts.end, tz="Asia/Kolkata")
for(i in 1:nrow(stn.pairs)){
 ##        i <- 1
    stn.names(stn.pairs$wlr[i], stn.pairs$tbrg[i])
    source(paste(hyd.code.dir, "stn_", stn.pairs$wlr[i], ".R", sep=""), echo=FALSE) # calculate
    tbrg.dat.all <- read.tbrg.csv(tbrg.full.flnm)
    
     for(j in 1:nrow(ts.years)){
 ##       j <- 1 ## remove when script is fixed
        ts.start <- ts.years$start[j]
        ts.end <- ts.years$end[j]
        yr <-  format(ts.start, "%Y") ## ts.years$year[n]
        start.month <- format(ts.start, "%d-%b-%Y")
        end.month <- format(ts.end, "%d-%b-%Y")
        prd <- paste(start.month, "to", end.month, sep="_")
        wlr.dat <- subset(wlr.dat.all, subset=(Timestamp>=ts.start & Timestamp < ts.end))
        tbrg.dat <- subset(tbrg.dat.all, subset=(Timestamp>=ts.start & Timestamp < ts.end))
        hyd.data <- hydgrph.dat(wlr.dat, tbrg.dat) # generate data for hydrograph
        ifelse(nrow(hyd.data)>10,
               hydgraph.plot(stn.pairs$wlr[i], stn.pairs$tbrg[i], prd),
               paste("WARNING: There is no data for a hydrograph for", prd, "for station", stn.pairs$wlr[i], sep=" "))
                # plot hydrograph
    }
}
## }
