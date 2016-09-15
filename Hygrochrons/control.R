## control script - set up the environment and call the relevant functions
## defined in the functions.R script.
## when completed, it makes the hyg_imp.R script redundant.

##---- Call libraries----##

library("timeSeries")
library("scales")
library("ggplot2")
library("reshape2")

##----Call functions and set file names----##

source("functions.R", echo=FALSE)

hyg.raw.path <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hygch/raw"
hyg.res.path <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hygch/csv"
hyg.raw.dirs <- dir(path=hyg.raw.path, full.names=TRUE)
flnm <- dir(path=hyg.raw.path, full.names=FALSE)
temp.flnm <- paste(flnm, "_temp", sep = "")
humi.flnm <- paste(flnm, "_humi", sep = "")
temp.dir <- paste(hyg.raw.dirs, "/temp", sep="")
humi.dir <- paste(hyg.raw.dirs, "/humi", sep="")


hyg.csv.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hygch/csv/"
hyg.raw.fl.nme <- dir(path=hyg.raw.path, full.names=FALSE)
hyg.csv.fl.nme <- gsub("raw", "csv", hyg.raw.fl.nme)
hyg.csv.nme <- gsub(pattern=".csv", replacement="", x=hyg.csv.fl.nme)
hyg.csv.temp.fl.nme <- paste("temp_",hyg.csv.fl.nme, ".csv", sep="")
hyg.csv.humi.fl.nme <- paste("humi_",hyg.csv.fl.nme, ".csv",  sep="")
hyg.csv.fl.nme <- paste(hyg.csv.fl.nme, ".csv",  sep="")
hyg.temp.path <- paste(hyg.raw.dirs, "/temp", sep="")
hyg.humi.path <- paste(hyg.raw.dirs, "/humi", sep="")

##----Process data by calling functions----##

temp.res <- mapply(import.hygch, x=temp.dir, y=temp.flnm, SIMPLIFY = FALSE) 
daily.temp <- lapply(temp.res, aggregate.by, prd = "day")
humi.res <- mapply(import.hygch, x=humi.dir, y=humi.flnm, SIMPLIFY = FALSE) 
daily.humi <- lapply(humi.res, aggregate.by, prd = "day") 

## res.names <- gsub(pattern = ".csv", replacement = "", hyg.csv.fl.nme)
temp.humi.res <- mapply(merge.bs.tabs, x = temp.res, y = humi.res, SIMPLIFY = FALSE, USE.NAMES = TRUE) # , names=res.names,
rm(temp.res, humi.res)

daily.temp.humi.res <- mapply(merge.bs.agg, x = daily.temp, y = daily.humi, SIMPLIFY = FALSE, USE.NAMES = TRUE) #, names=res.names,
## names(daily.temp.humi.res) <- res.names


parm <- "temperature"
hyg.no <- paste("Hygrochron no:",gsub("[^0-9]", "",names(daily.temp)))
mapply(plot.save, daily.temp, hyg.no, parm, SIMPLIFY = TRUE, USE.NAMES = TRUE)

parm <- "humidity"
hyg.no <- paste("Hygrochron no:",gsub("[^0-9]", "",names(daily.humi)))
mapply(plot.save, daily.humi, hyg.no, parm, SIMPLIFY = TRUE, USE.NAMES = TRUE)




rm(daily.temp, daily.humi)
rm(list=ls(pattern="^bs_*"))
ls()


## daily.temp <- lapply(temp.humi.res, aggregate.by, prd = "day")
## lapply(temp.humi.res, aggregate.by, prd = "day", y="rh")
