## This scrips is meant to hold the variables for Aghnashini and call sub routines.
library(timeSeries)
library(ggplot2)

## set the financial centre
setRmetricsOptions(myFinCenter = "Asia/Calcutta")
Sys.setenv(TZ='Asia/Kolkata')
## setRmetricsOptions(tz = "Asia/Kolkata")

site <- "agnashini."
tbrgdatadir<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/tbrg/raw"
tbrg_nulldatadir<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/tbrg/null"
## wkdir<-"/home/udumbu/rsb/OngoingProjects/CWC/rdata/"
wkdir <-"/home/udumbu/rsb/GitHub/CWC/TBRG/"
setwd(wkdir)
## Create tables to hold the tbrg and wlr datasets
num_tbrg<- c(paste("00", 7:9, sep=""), paste("0", 10:26, sep=""))
## num_tbrg <- c(paste("0", 18:26, sep=""))
## Ensure the diretories for the data are created
## in the console "mkdir tbrg_{101..130}" will create directories tbrg_101 to tbrg_130
calibfile <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/tbrg/calib/agnashini_tbrg_calibration_fnl.csv"
figdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/tbrg/fig/"
csvdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/tbrg/csv/"

for (i in 1: length(num_tbrg)){
    ## List the names of the files
    tbrgtab<-paste("tbrg_", num_tbrg[i], sep="") # Directory/table per tbrg holding csv files are stored.
    tbrgtab_raw<-paste("tbrg_", num_tbrg[i], "_raw", sep="")
    tbrgtab_pseudo<-paste("tbrg_", num_tbrg[i], "_pdeudo", sep="")
    tbrgdir<-paste(tbrgdatadir, tbrgtab, sep="/") # Directory holding all tbrg sub folders
    tbrgdir_null<-paste(tbrg_nulldatadir, tbrgtab, sep="/") # Directory holding all tbrg_null sub folders
    tbrgtab_null_all<-paste(tbrgtab, "_null_all",sep="") # Directory holding all tbrg_null sub folders
    filelist <- list.files(tbrgdir, pattern="\\.csv$|\\.dat$", ignore.case=TRUE, full.names=FALSE)
    filelist.full <- list.files(tbrgdir, pattern="\\.csv$|\\.dat$" , ignore.case=TRUE, full.names=TRUE)
    filelist_null<- list.files(tbrgdir_null, pattern="\\.csv$|\\.dat$" , ignore.case=TRUE, full.names=FALSE)
    filelist_null.full <- list.files(tbrgdir_null, pattern="\\.csv$|\\.dat$", ignore.case=TRUE, full.names=TRUE)
    csv.out <- paste(csvdir, tbrgtab, "_onemin.csv", sep="")

    ## source(paste(wkdir,"myfuncts.R", sep=""), echo=TRUE)
    source(paste(wkdir,"tbrg_import.R", sep=""), echo=TRUE)
    source(paste(wkdir,"tbrg_fillnull.R", sep=""), echo=TRUE)
    source(paste(wkdir,"tbrg_aggreg.R", sep=""), echo=TRUE)

}
