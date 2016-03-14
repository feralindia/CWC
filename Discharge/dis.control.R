## Generate discharge for one minute intervals
## input: wlr no, start time, end time
## output: csv, figure
## UPDATED 10th March 2016
## Each station has its own script to retain flexibility
## in file naming. Note that some stations have multiple
## recorders and some use both velocity area and flumes.
## Station number refers to the first wlr located at a give spot.

##-- Load required libraries
library(timeSeries)

##-- call functions
source("dis.functs.R", echo=FALSE) # most calculations/plotting done here

## library(hydrostats)
## library(EcoHydRology)
library(ggplot2)
## library(reshape2)
## library(scales)
setRmetricsOptions(myFinCenter = "Asia/Calcutta")
##-- Set environment as appropriate
site.name <- "Nilgiris" ## or "Aghnashini"
setwd("~/GitHub/CWC/Discharge/")
dis.code.dir <- "~/GitHub/CWC/Discharge/"
wlr.dir <- paste("~/OngoingProjects/CWC/Data/", site.name, "/wlr/csv/", sep="")
sd.dir <- paste("~/OngoingProjects/CWC/Data/", site.name, "/cleaned.rating/csv/", sep="")
discharge.dir <- paste("~/OngoingProjects/CWC/Data/", site.name, "/discharge/", sep="")
data.dir <- paste("~/OngoingProjects/CWC/Data/", site.name, "/", sep="")

## ------

## Define start date, end date and interval in months
ts.start.tmstmp <- as.POSIXct("2015-06-01 00:00:00", tz="Asia/Kolkata")
ts.end.tmstmp <- as.POSIXct("2015-12-31 23:59:59", tz="Asia/Kolkata")
ts.interval <- "1 month" ## period of reporting
ts.start <- seq(ts.start.tmstmp, ts.end.tmstmp, ts.interval)
ts.end <- ts.start[-1] ## take all but first item of ts.start
ts.end <- ts.end-1 ## end is one second less than pervious start
ts.end[[length(ts.end)+1]] <- ts.end.tmstmp ## add last ts.end value
ts.years <- as.data.frame(matrix(nrow=length(ts.start),ncol=2))
names(ts.years) <- c("start", "end") 
ts.years[,1] <- as.POSIXct(ts.start, tz="Asia/Kolkata")
ts.years[,2] <- as.POSIXct(ts.end, tz="Asia/Kolkata")

##-- Specify the stations for which you want the data processed.
## NOTE: some stations automatically call on other loggers for data
## wlr.no <- c(101:109, 114, 115)
wlr.no <- 115

for(i in 1:length(wlr.no)){
    ## i <- 1  # for testing
    source(paste(dis.code.dir, "stn_", wlr.no[i], ".R", sep=""), echo=FALSE) # calculate

    ##-- loop through time steps for reporting/plotting --##
    for(j in 1:nrow(ts.years)){
        ## j <- 1 ## remove when script is fixed
        ts.start <- ts.years$start[j]
        ts.end <- ts.years$end[j]
        yr <-  format(ts.start, "%Y") ## ts.years$year[n]
        start.month <- format(ts.start, "%d-%b-%Y")
        end.month <- format(ts.end, "%d-%b-%Y")
        prd <- paste(start.month, "to", end.month, sep="_")
        wlr.dat <- subset(wlr.dat.all, subset=(Timestamp>=ts.start & Timestamp < ts.end))

        ##--- Reporting
        stn.names(wlr.no[i]) # assign names 
        write.csv(x=wlr.dat, file=discharge.csv)
        ##--- Plotting
        dis.plot(wlr.dat)
    }
    
    ##-- check for duplicated timestamps
    ## n.dup <- data.frame(table(wlr.dat.all$Timestamp))
    ## n.dup[n.dup$Freq>1,]
    dup <- wlr.dat.all$Timestamp[duplicated(wlr.dat.all$Timestamp)]
    if(length(dup)>0)(warning(mk.nullfile(dup))) # issue warning if duplicate entries

    cat(paste("Finshed writing data and plotting figures for ", wlr.no[i], sep=""), sep="\n")
}

