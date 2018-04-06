## Quick comparison of the data readout from the FREESTATION and the DAVIS
## located at the Bunker Site in Nilgiris

## load libraries
library(reshape2) # data manipulation for plotting
library(ggplot2) # plotting
library(scales) ## for manipulating dates on ggplot2

## fix headers of the Davis data which is spread across two rows
fix.header <- function(x){
    raw.file <- read.csv(x, sep = "\t", header=FALSE,stringsAsFactors=FALSE)
    names.raw.file <- trimws(paste(unlist(raw.file[1,]), unlist(raw.file[2,])))
    raw.file <- raw.file[c(-1,-2),]
    names(raw.file) <- names.raw.file
    return(raw.file)
}

## import data
freestn.fn <- "~/CurrProj/CWC/Data/Nilgiris/freestation/xls/freestn.raw.csv" # change this to match your folder settings
davis.fn <- "~/CurrProj/CWC/Data/Nilgiris/freestation/xls/bunker_aws_for_compar.txt" # change this to match your folder settings
davis.dat <- fix.header(davis.fn)
freestn.dat <- read.csv(freestn.fn)

## select relevant data (columns)
davis.dat <- davis.dat[,c(1,2,3,6,20,18,8)]
davis.dat[,c(3:7)] <- lapply(davis.dat[,c(3:7)], function(x) as.numeric(x)) # convert values to numeric

freestn.dat <- freestn.dat[,c(3:8, 11)]

## add logger id
davis.dat$LoggerID <- "Davis"
freestn.dat$LoggerID <- "FREESTATION"

## standardise headings
col.hd <- c("Date", "Time", "Temperature", "Humidity", "Solar Rad.", "Rain", "Wind Speed", "LoggerID")

names(davis.dat) <- col.hd
names(freestn.dat) <- col.hd

## clean up date and time
davis.dat$Date <- as.Date.factor(davis.dat$Date, format = "%m/%d/%y")
davis.dat$Time <- gsub("a", "AM", davis.dat$Time)
davis.dat$Time <- gsub("p", "PM", davis.dat$Time)
davis.dat$Time <- format(strptime(davis.dat$Time, "%I:%M %p"), format="%H:%M:%S")
davis.dat$Timestamp.IST <- as.POSIXct(paste(davis.dat$Date, davis.dat$Time, format="%Y-%m-%d %H:%M:%S"), tz = "Asia/Kolkata")
davis.dat$Timestamp.UTC <- format(davis.dat$Timestamp.IST, tz = "UTC", usetz = TRUE)
davis.dat$Timestamp.UTC <- as.POSIXct(davis.dat$Timestamp.UTC, tz = "UTC")


freestn.dat$Date <- as.Date(freestn.dat$Date, format = "%d/%m/%Y")
freestn.dat$Time <- format(strptime(freestn.dat$Time, "%H:%M"), format="%H:%M:%S")
freestn.dat$Timestamp.UTC <- as.POSIXct(paste(freestn.dat$Date, freestn.dat$Time), format="%Y-%m-%d %H:%M:%S", tz = "UTC")
freestn.dat$Timestamp.IST <- format(freestn.dat$Timestamp.UTC, tz = "Asia/Kolkata", usetz = TRUE)
davis.dat$Timestamp.IST <- as.POSIXct(davis.dat$Timestamp.IST, tz = "Asia/Kolkata")
freestn.dat <- freestn.dat[,c(1:8, 10, 9)]

## trim davis data to period when freestation was logging
mx.tm <- as.POSIXct("2017-01-22 04:37:00", tz = "UTC")  #max(freestn.dat$Timestamp.UTC)
mn.tm <- as.POSIXct("2017-01-19 07:50:00", tz = "UTC") # min(freestn.dat$Timestamp.UTC)
## subset(davis.dat, subset = (Timestamp.UTC >= mn.tm & Timestamp.UTC <= mx.tm))
davis.dat <- davis.dat[davis.dat$Timestamp.UTC >= mn.tm & davis.dat$Timestamp.UTC <= mx.tm,]
## append data

ggdat <- rbind(davis.dat, freestn.dat)

## plot data
ggdat <- melt(ggdat, measure.vars = c(3:7), id.vars = c("LoggerID","Timestamp.UTC"), variable.name = "Parameter")
ggdat$Timestamp.UTC <- as.POSIXct(ggdat$Timestamp.UTC, format = "%Y-%m-%d %H:%M:%S")
    ggplot(data=ggdat, aes(Timestamp.UTC, value, color = LoggerID)) +
        geom_point() +
        scale_x_datetime(labels = date_format("%d-%b-%Y")) + ##breaks = "1 week", minor_breaks = "1 day",
        facet_wrap(~Parameter, scales = "free_y", shrink=FALSE)

## output
        
ggsave("DavisFREESTNplot.png")
write.csv(file = "DavisData.csv", x = davis.dat)
write.csv(file = "FREESTATIONdata.csv", x = freestn.dat)
