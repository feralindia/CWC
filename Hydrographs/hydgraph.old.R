## Generate a hydrograph for the specified time period
## input: wlr no, tbrg no, start time, end time
## output: csv, figure
## NOTE THAT THIS SCRIPT OPERATES ON AN HOURLY DISCHARGE BASIS.
## Updated Feb 2016

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
dis.code.dir <- "~/GitHub/CWC/Discharge"
hyd.code.dir <- "~/GitHub/CWC/Hydrographs/"
wlr.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv"
tbrg.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv"
hygch.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/hygch/csv"
sd.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/rating/csv"
hydgrph.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/hydrograph"
data.dir <- "~/OngoingProjects/CWC/Data/Nilgiris/"

####----SPECIFY DISCHARGE TYPE
## decide what type and units you want to show discharge (per hour) in.
discharge.type <- "Discharge"## Options are c("Capacitance", "Stage", "Discharge", "DepthDischarge")

####-------

if(discharge.type=="Discharge"){
    dis.units <- "m^3/hr"}else if(discharge.type=="Stage"){
                             dis.units <- "m"}else {dis.units <- "farad"}
##--- Load Functions ---##
## source("et_functions.R", echo=FALSE)

##--- Write the numbers of the station and corresponding tbrg you'd like processed
wlr.no <- c("101", "104", "109")## , "109")
tbrg.no <- c("102", "103", "112")## , "116")
stn.no <- as.data.frame(matrix(nrow=length(wlr.no), ncol=2))
names(stn.no) <- c("wlr", "tbrg")
stn.no[,1] <- wlr.no
stn.no[,2] <- tbrg.no

## Define start date, end date and interval in months
ts.start.tmstmp <- as.POSIXct("2012-08-15 00:00:00", tz="Asia/Kolkata")
ts.end.tmstmp <- as.POSIXct("2016-03-31 23:59:59", tz="Asia/Kolkata")
ts.interval <- "4 year" ## period of reporting
ts.start <- seq(ts.start.tmstmp, ts.end.tmstmp, ts.interval)
ts.end <- ts.start[-1] ## take all but first item of ts.start
ts.end <- ts.end-1 ## end is one second less than pervious start
ts.end[[length(ts.end)+1]] <- ts.end.tmstmp ## add last ts.end value

ts.years <- as.data.frame(matrix(nrow=length(ts.start),ncol=2))
names(ts.years) <- c("start", "end") # "year", 
## ts.years[,1] <- format(ts.start, "%Y")
ts.years[,1] <- as.POSIXct(ts.start, tz="Asia/Kolkata")
ts.years[,2] <- as.POSIXct(ts.end, tz="Asia/Kolkata")

## ts.years$start <- as.POSIXct("2015-05-10 23:59:59", tz="Asia/Kolkata")

##--- functions ----###

## feed it x (name of station) and y (name of rain gaugge) to globally assign
## names to files etc.
stn.names <- function(x,y){
    ## prd <- paste(start.month, "to", end.month, "", yr, sep="_")

    hydrograph.pdf <<- paste(hydgrph.dir, "/fig/HydroGraph_stn", x, "_tbrg_", y, "_", discharge.type, "_", prd, ".pdf", sep="")
    hydrograph.png <<- paste(hydgrph.dir, "/fig/HydroGraph_stn", x, "_tbrg_", y, "_", discharge.type,"_", prd, ".png", sep="")
    hydrograph.csv <<- paste(hydgrph.dir, "/csv/HydroGraph_stn", x, "_tbrg_", y, "_", discharge.type, "_", prd, ".csv", sep="")
    
    tbrg.filename <<- paste("/tbrg_", y, "_15 min.csv", sep="") ## changed from _1 hour.csv
    wlr.nm <<- paste("WLR ",x, sep="")
    tbrg.nm <<- paste("TBRG ",y, sep="")
}

for(i in 1:nrow(stn.no)){
    ##     i <- 1
    pat <- paste(stn.no$wlr[i], "_15 min.csv", sep="") ## changed to 15 min, to be changed to _1 hour
    wlr.fn <- list.files(path=wlr.dir, pattern=pat, full.names=T)
    wlr.dat.all <- read.csv(wlr.fn)
    if(names(wlr.dat.all)[[3]]=="cal"){
        names(wlr.dat.all)[[3]] <- "Stage"
    }
    wlr.dat.all$date_time <- as.POSIXct(wlr.dat.all$date_time, tz="Asia/Kolkata")
    ## wlr.dat.all$date_time <- round.POSIXt(wlr.dat.all$date_time, "hours") # rounding off now done at wlr aggregation time
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
                          select=c("X", "raw", "Stage", "date_time"))
        ##   if(nrow(wlr.dat)>0){ ## uncomment when fixed
        wlr.dat$date_time <- as.POSIXct(wlr.dat$date_time, tz="Asia/Kolkata")
        
        ##--- Process station data ---##
        stn.names(stn.no$wlr[i], stn.no$tbrg[i]) # assign names

        ## run till here to initalise for stn_xxx.R
        
        source(paste(hyd.code.dir, "/stn_", stn.no$wlr[i], ".R", sep=""), echo=FALSE) 
        
        ##--- Run hydrograph calculations----##
        
        summ.hyd.csv <- paste(hydgrph.dir, "/wlr", stn.no$wlr[i], "_tbrg", stn.no$tbrg[i], "_Hydrograph_stats_", prd, ".csv", sep="")

        tbrg <- read.csv(paste(tbrg.dir,tbrg.filename, sep=""))
        tbrg$dt.tm <- as.POSIXct(tbrg$dt.tm, tz="Asia/Kolkata")
        tbrg <- subset(tbrg, subset=(tbrg$dt.tm>=ts.start & tbrg$dt.tm < ts.end), select=c("mm", "dt.tm"))
        names(tbrg) <- c("mm","Timestamp")
        ## round off the time to hours for merge to work

        ## tbrg$Timestamp <- round(tbrg$Timestamp, "hour") #done at tbrg aggregation
        tbrg$numtime <- as.numeric(tbrg$Timestamp)
        ## wlr.dat$Timestamp <- round(wlr.dat$Timestamp, "hour") #done at wlr aggregation
        wlr.dat$numtime <- as.numeric(wlr.dat$Timestamp)

        wlr.tbrg <- merge(wlr.dat, tbrg, by="numtime", all=TRUE)
        ## complete cases won't work with date, using na.omit instead
        wlr.tbrg <- na.omit(wlr.tbrg)
        ## will probably have to include a lag of a day, i.e. remove all data
        ## within 24 hours of a rain event. Could be refined to use the max lag period as well.
        ## norain.dat <- wlr.tbrg[wlr.tbrg$mm==0,]
        hyd.data <- subset(wlr.tbrg, select=c("Timestamp.x", "mm", discharge.type))
        names(hyd.data) <- c("date", "P_mm", discharge.type)
        
        png(filename=hydrograph.png, width=1200, height=600, pointsize=10, type="cairo")
        ## pdf.title <- paste("Hourly Rainfall and Discharge wlr ", stn.no$wlr[i], " tbrg ", stn.no$tbrg[i], prd, sep="")

        ## pdf(file=hydrograph.pdf, title=pdf.title,  width=12, height=7)
        ##par(cex=1.6)
        hydrograph(hyd.data, stream.label=paste("Mean Hourly ", discharge.type,
                                                "\n in ",dis.units, sep=""),
                   P.units="mm", S1.col="blue")
        ## title(main="Hourly Rainfall and Discharge - Wattle Catchment")
        dev.off()
        write.csv(file=hydrograph.csv, hyd.data)

        ## Correlation plots
        main.title <- paste("Cross Correlation", wlr.nm, tbrg.nm, sep=" ")
        obj <- ccf(hyd.data[,3], hyd.data[,2],type="correlation",plot=T, lag.max=240)## mod from 3 to 4
        tmp.max <- max(obj$acf)
        obj$lag[obj$acf==tmp.max]
        plot(obj[0:400],type="l",xlim=c(0,100),bty="l",ylab="Correlation Coefficient",
             main=main.title, xlab="Lag in hours")
        wlr.dat <- wlr.tbrg

        summ.hyd <- as.data.frame(as.matrix(summary(hyd.data)))
        names(summ.hyd) <- c("Variable", "Statistic", "Value")
        write.csv(summ.hyd, file=summ.hyd.csv)
        
    }
}
## }
