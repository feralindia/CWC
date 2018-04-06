## Script to generate a data frame and a hydrograph for each WLR
## Discharge in depth units
## Rainfall as averaged for all rain gauges in catchment
## Unit is daily
## Script reads in processed csv files generated from
## discharge and tbrg routines
## NOTE: WEIRS NEED TO BE PROCESSED INDEPENDENTLY## library("xts")

##-- load libraries
library("EcoHydRology")
library("reshape2")
library("ggplot2")
library("scales")
setwd("~/Res/CWC/Anl/Reporting/CumulativePlots/")
## library("timeSeries")

##-- call functions
source("./functions.R", echo = TRUE)

##-- specify periods to be processed 
St.prd.wet <- as.Date(as.POSIXct(c("2013-04-30","2014-04-30","2015-04-30")), format = "%Y-%M-%D", tz = "Asia/Kolkata", origin = "1970-01-01")
end.prd.wet <- as.Date(as.POSIXct(c("2014-01-01", "2015-01-01", "2016-01-01")), format = "%Y-%M-%D", tz = "Asia/Kolkata", origin = "1970-01-01")
wet.prd <- data.frame(st.prd.wet, end.prd.wet)
st.prd.dry <- as.Date(as.POSIXct(c("2013-12-31","2014-12-31","2015-12-31")), format = "%Y-%M-%D", tz = "Asia/Kolkata", origin = "1970-01-01")
end.prd.dry <- as.Date(as.POSIXct(c("2014-05-01","2015-05-01","2016-05-01")), format = "%Y-%M-%D", tz = "Asia/Kolkata", origin = "1970-01-01")
dry.prd <- data.frame(st.prd.dry, end.prd.dry)

##-- define sites and units to be processed
site.name <- "Nilgiris" # or "Aghnashini"
if(site.name == "Nilgiris") stn <- c("102","104", "107") #, "107", "108", "104")
if(site.name == "Aghnashini")  stn <- c("001","002")

stn <- "102"

##---define file names
data.dir <- "~/Res/CWC/Data"
site.data.dir <- paste(data.dir, site.name, sep = "/")
dis.dir <- paste(site.data.dir, "discharge/csv/DailyDepth", sep = "/")

##--Start processing

    dis.flnm <- sapply(stn, FUN = function(x)
        list.files(dis.dir, full.names=FALSE, pattern = paste0("Stn",x)))
    dis.full.flnm <- sapply(stn, FUN = function(x)
        list.files(dis.dir, full.names=TRUE, pattern = paste0("Stn",x)))

if(length(>1)){
    
    tbrg.dat <- sapply(stn, AvgRain, simplify = FALSE, USE.NAMES = TRUE) # read data and average rainfall
    discharge.dat <- sapply(dis.full.flnm, read.csv, simplify = FALSE) # read discharge dat
    ## discharge.dat <- discharge.dat[[1]] # for list
    ## discharge.dat <- sapply(stn, ReadDis, simplify = FALSE)
    rain.dd.dat <- mapply(merge, x = tbrg.dat, y = discharge.dat, by.x = "Date", by.y="date", SIMPLIFY = FALSE)
    ## for 101
    ## discharge.dat <- discharge.dat[[1]] # for list
    ## dat <- sapply(rain.dd.dat, function(x) x <- x[,c(1,3,5)], simplify = FALSE) #NEEDS FIXING
    dat <- sapply(rain.dd.dat, function(x) subset(x, select = c("Date", "Daily Rain", "depth.mm")), simplify = FALSE)
    
    dat <- sapply(dat, function(x){
        x[,1] <- as.POSIXct(x[,1], tz = "Asia/Kolkata")
        return(x)
    }, simplify = FALSE)
    
    ## out.png <- as.list(paste0("Hydrograph_", stn, ".png"))
    mapply(FUN = plot.hydrograph, dat), "out.png")

    nm.dat <- as.list(paste0("HydData", names(dat), ".csv"))
    mapply(write.list.to.csv, dat, nm.dat)
    ## x$DepthDischarge <- x$DepthDischarge*.5
    x <- dat[[1]] # for list
} else {
    tbrg.dat <- AvgRain(x = stn) # use for individual files
    ## tbrg.dat <- read.csv(file = "~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_102_1 day.csv") # for weir
    names(tbrg.dat) <- c("ID", "Daily Rain", "Timestamp")
    tbrg.dat$Timestamp <- as.POSIXct(tbrg.dat$Timestamp, tz = "Asia/Kolkata", origin = "1970-01-01")
    tbrg.dat$Date <- as.Date(tbrg.dat$Timestamp)
    tbrg.dat$datenum <- as.numeric(as.POSIXct(tbrg.dat$Date,tz = "Asia/Kolkata", origin = "1970-01-01"))

    discharge.dat <- read.csv(dis.full.flnm)
    discharge.dat$Timestamp <- as.POSIXct(discharge.dat$timestamp, tz = "Asia/Kolkata", origin = "1970-01-01")
    discharge.dat$date <- as.Date(discharge.dat$Timestamp)
    rain.dd.dat <- merge(x = tbrg.dat, y = discharge.dat, by.x = "Date", by.y="date")

    ## rain.dd.dat <- merge(x = tbrg.dat, y = discharge.dat[[1]], by = "Date", SIMPLIFY = FALSE)
    ## dat <- rain.dd.dat[,c(1,3,10)]
    dat <- subset(rain.dd.dat, select = c("Date", "Daily Rain", "depth.mm"))


    dat$Date <- as.POSIXct(dat$Date, tz = "Asia/Kolkata")

    hydrograph(dat, stream.label="Depth of Discharge", P.units="mm", S1.col="blue")
    x <- dat
   ##  x <- x[x$Date > "2015-02-11" & x$Date < "2015-04-13",] 
    ## x <- x[x$Date > "2014-02-27" & x$Date < "2016-08-26",] 
    ## x <- x[x$Date > "2015-04-27" & x$Date < "2016-01-29",] # selecting continuous data for x[[2]]
    names(x) <- c("dt", "rain", "discharge")
    x$Date <- as.Date(x$dt, "%Y-%m-%d")
    ## x <- transform(x, discharge = na.locf(discharge), rain = na.locf(rain)) # only do to remove gaps
    x$cumrain <- cumsum(x$rain)
    x$cumdis <- cumsum(x$discharge)

    ## prepare data for plotting
    ggdat <- melt(data = x, na.rm = T, value.name = "mm", id.vars = "dt", measure.vars = c("rain", "discharge", "cumrain", "cumdis"), variable.name = "Variable")
    ggplot(data = subset(ggdat,Variable %in% c("rain" , "discharge")), aes(dt)) +
        scale_color_manual(labels=c("Rain", "Discharge"), values = c("Blue", "Red")) +
        geom_line(aes(y = mm, colour = Variable)) 
    ##  ggsave(filename = "~/tmp/WeirRG102_Trevformula.png")

    ggplot(data=subset(ggdat,Variable %in% c("cumrain" , "cumdis")), aes(dt))+
        scale_color_manual(labels=c("Cumulative Rain", "Cumulative Discharge"), values = c("Blue", "Red")) +
        geom_line(aes(y = mm, colour = Variable)) 
    ggsave(filename = "~/tmp/WeirRG102.png")
}

