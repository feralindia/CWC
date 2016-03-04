## Generate discharge for one minute intervals
## input: wlr no, start time, end time
## output: csv, figure
## UPDATED 15th Feb 2016

##-- Load required libraries
library(timeSeries)
## library(hydrostats)
## library(EcoHydRology)
## library(ggplot2)
## library(reshape2)
## library(scales)
setRmetricsOptions(myFinCenter = "Asia/Calcutta")
##-- Set environment as appropriate tn
setwd(dir="~/GitHub/CWC/Discharge/")
dis.code.dir <- "~/GitHub/CWC/Discharge/"
wlr.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
## tbrg.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv"
## hygch.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/hygch/csv"
sd.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/rating/csv/"
discharge.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/discharge/"
data.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/"

##-- write code for different resolutions of discharge here:

##-- Specify the stations for which you want the data processed.
## NOTE: some stations automatically call on other loggers for data

wlr.no <- c(103)## , "109"

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
names(ts.years) <- c("start", "end") # "year", 
## ts.years[,1] <- format(ts.start, "%Y")
ts.years[,1] <- as.POSIXct(ts.start, tz="Asia/Kolkata")
ts.years[,2] <- as.POSIXct(ts.end, tz="Asia/Kolkata")

##--- functions ----###

## feed it x (name of station) and y (name of rain gaugge) to globally assign
## names to files etc.
stn.names <- function(x){
    discharge.pdf <<- paste(discharge.dir, "/fig/Discharge_stn", x, "_", prd, ".pdf", sep="")
    discharge.png <<- paste(discharge.dir, "/fig/Discharge_stn", x,  "_", prd,".png", sep="")
    discharge.csv <<- paste(discharge.dir, "/csv/Discharge_stn", x,  "_", prd,".csv", sep="")
    wlr.nm <<- paste("WLR ",x, sep="")
}

## for(i in 1:length(wlr.no)){
         i <- 1
    ## pat <- paste(wlr.no[i], "_1 min.csv", sep="")
    ## wlr.fn <- list.files(path=wlr.dir, pattern=pat, full.names=T)
    ## wlr.dat.all <- read.csv(wlr.fn)
    ## if(names(wlr.dat.all)[[3]]=="cal"){
    ##     names(wlr.dat.all)[[3]] <- "Stage"
    ## }
    ## wlr.dat.all$date_time <- as.POSIXct(wlr.dat.all$date_time, tz="Asia/Kolkata")
    ## wlr.dat.all$date_time <- round(wlr.dat.all$date_time, "mins")
    
    source(paste(dis.code.dir, "/stn_", wlr.no[i], ".R", sep=""), echo=FALSE) 
    
    for(j in 1:nrow(ts.years)){
        ## j <- 1 ## remove when script is fixed
        ts.start <- ts.years$start[j]
        ts.end <- ts.years$end[j]
        yr <-  format(ts.start, "%Y") ## ts.years$year[n]
        start.month <- format(ts.start, "%d-%b-%Y")
        end.month <- format(ts.end, "%d-%b-%Y")
        prd <- paste(start.month, "to", end.month, sep="_")
        
        wlr.dat <- subset(wlr.dat.all, subset=(wlr.dat.all$date_time>=ts.start &
                                               wlr.dat.all$date_time < ts.end),
                          select=c("X", "raw", "Stage", "date_time"))## ADD OTHER FIELDS HERE
        ##   if(nrow(wlr.dat)>0){ ## uncomment when fixed
        ## wlr.dat$date_time <- as.POSIXct(wlr.dat$date_time, tz="Asia/Kolkata")
        
        ##--- Process station data ---##
       ##  stn.names(wlr.no[i]) # assign names

       
        
        ##--- Reporting
        
        stn.names(wlr.no[i]) # assign names 
        write.csv(x=wlr.dat, file=discharge.csv)

        ##--- Plotting
        
    }
}
## }
