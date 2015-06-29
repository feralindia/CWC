## Master script, unique for each site to call on routines
## Load required libraries
library(stringr) # to manipulate strings
library(timeSeries) # for aggregation
library(ggplot2) # for plotting

## Set directory locations - fix for your system
rdata.dr <- "/home/udumbu/rsb/OngoingProjects/CWC/rdata/WLR/"
csvdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Sikkim/wlr/csv/"
figdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Sikkim/wlr/fig/"
wlrdatadir<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Sikkim/wlr/raw/" # raw data

## --- set the wlr on which you want to run the script
wlr.nulldir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Sikkim/wlr/null/" # null directory
num_wlr<- c(43221,43223) # change as needed
loggers <- paste("wlr_", num_wlr, sep="")
setwd(rdata.dr) # set the working directory
setRmetricsOptions(myFinCenter = "Asia/Calcutta")

## ---- read in the routines
source("wlr_sikk_import.R", echo=TRUE) # import, calibrate and gap fill data
source("wlr_sikk_null.R", echo=TRUE) # insert null values from error logs
source("wlr_sikk_mergenull.R", echo=TRUE) # merge the nulls with the calibrated values
source("wlr_sikk_aggreg.R", echo=TRUE) # aggregate and output the data



