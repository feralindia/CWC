 ## This script is meant to hold the variables for Nilgiris and call sub routines.
library(timeSeries)
library(ggplot2)
library(parallel)

source("myfuncts.R", echo=FALSE)

## set the financial centre
setRmetricsOptions(myFinCenter = "Asia/Calcutta")
Sys.setenv(TZ='Asia/Kolkata')
## setRmetricsOptions(tz = "Asia/Kolkata")

site <- "nilgiris."
tbrgdatadir<-"~/Res/CWC/Data/Nilgiris/tbrg/raw"
tbrg_nulldatadir<-"~/Res/CWC/Data/Nilgiris/tbrg/null"
## wkdir<-"/home/udumbu/rsb/OngoingProjects/CWC/rdata/"
wkdir <-"~/Res/CWC/Anl/TBRG/"
setwd(wkdir)
## Create tables to hold the tbrg and wlr datasets
num_tbrg <- c(101:135, "105a","110a", "125a", "134a") # testing
## num_tbrg <- c(101:105)
## Ensure the diretories for the data are created
## in the console "mkdir tbrg_{101..130}" will create directories tbrg_101 to tbrg_130
calibfile <- "~/Res/CWC/Data/Nilgiris/tbrg/calib/nilgiri_tbrg_calibration_fnl.csv"
figdir <- "~/Res/CWC/Data/Nilgiris/tbrg/fig/"
csvdir <- "~/Res/CWC/Data/Nilgiris/tbrg/csv/"

## Set up the cores for multi-core processing to speed up stuff
## remember there is quite a bit of writing to disk so this won't
## necessarily speed things up too much.
##---------WARNING-------------###
## ONLY WORKS ON LINUX BOXES.
## visit this page to see how to set up for windows
## <https://www.r-bloggers.com/a-no-bs-guide-to-the-basics-of-parallelization-in-r/>

## Fix the year on data downloaded 2016 and after - run only once
## note original data needs to be stored in folder named as below
x <- list.files("~/Res/CWC/Data/Nilgiris/tbrg/original.raw/", full.names=TRUE, recursive=TRUE)
lapply(x, fix.tbrg.yr)

use.cores <- detectCores() - 1 # use all but one cores
mclapply(X=num_tbrg, FUN=control.funct, mc.cores=use.cores)

print("Finished processing TBRG data for Nilgiris")
