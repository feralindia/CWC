## Define the framework for the analysis

##---call libraries
library(outliers)
library(ggplot2)
library(data.table)
library(scales)

source("functions.R", echo = TRUE)
##--- define folder locations

rain.dat.nlg.min <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv/", pattern="onemin.csv")
rain.dat.nlg.fn.min <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv/", pattern="onemin.csv", full.names = TRUE)
rain.dat.nlg.day <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv/", pattern="1 day.csv")
rain.dat.nlg.fn.day <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv/", pattern="1 day.csv", full.names = TRUE)
logid.nlg <- gsub("[^0-9a?]", "", rain.dat.nlg.min)

rain.dat.agn.min <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/tbrg/csv/", pattern="onemin.csv")
rain.dat.agn.fn.min <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/tbrg/csv/", pattern="onemin.csv", full.names = TRUE)
rain.dat.agn.day <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/tbrg/csv/", pattern="1 day.csv")
rain.dat.agn.fn.day <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/tbrg/csv/", pattern="1 day.csv", full.names = TRUE)
logid.agn <-  gsub("[^0-9a?]", "", rain.dat.agn.min) ## i?


## dat.mins.nlg <- read.csv(rain.dat.nlg.fn[1], row.names="X")
## dat.day.nlg <- do.call("rbind", lapply(rain.dat.nlg.fn.day, read.csv, row.names="X"))
## dat.day.nlg$dt.tm <- as.POSIXct(dat.day.nlg$dt.tm, tz = "Asia/Kolkata")

## daily.ere.nlg <- na.omit(dat.day.nlg[dat.day$mm>quantile(dat.day.nlg$mm, prob = 0.99, na.rm  = T),])
## ere.cutoff.nlg <- quantile(dat.day.nlg$mm, prob = 0.99, na.rm  = T)
## ere.nlg <- as.data.frame(table(daily.ere.nlg$dt.tm))

## dat.mins.agn <- read.csv(rain.dat.agn.fn[1], row.names="X")
## dat.day.agn <- do.call("rbind", lapply(rain.dat.agn.fn.day, read.csv, row.names="X"))
## dat.day.agn$dt.tm <- as.POSIXct(dat.day.agn$dt.tm, tz = "Asia/Kolkata")

## daily.ere.agn <- na.omit(dat.day.agn[dat.day.agn$mm>quantile(dat.day.agn$mm, prob = 0.99, na.rm  = T),])
## ere.cutoff.agn <- quantile(dat.day.agn$mm, prob = 0.99, na.rm  = T)
## ere.agn <- as.data.frame(table(daily.ere.agn$dt.tm))



##     gg.plt(ere.agn, ere.cutoff.agn)
##     ggsave(filename = "EREagn.png")
##     gg.plt(ere.nlg, ere.cutoff.nlg)
##     ggsave(filename = "EREnlg.png")

ele.nlg <- id.ere(rain.dat.nlg.fn.day, "Nilgiris")
ele.agn <- id.ere(rain.dat.agn.fn.day, "Agnashini")


##-- ext.surfaces

flnms <- unique(ele.nlg$flnm)
lapply(flnms, ere.minute, ele.nlg, "Nilgiris")

flnms <- unique(ele.agn$flnm)

lapply(flnms, ere.minute, ele.agn, "Aghnashini")


##---get list of units to subset hydrographs

unit.name <- read.csv("/home/udumbu/rsb/GitHub/CWC/sitewise_unintsname.csv")
unit.name$tbrg <- with(unit.name, paste(log.type, log.id, sep="_"))
unit.name <- subset(unit.name, log.type=="tbrg", select=c(stn, tbrg))
colnames(ele.nlg)[4] <- "tbrg"
nlg.hyd.list <- unique(na.omit(merge(ele.nlg, unit.name, by = "tbrg", all = TRUE)))
## colnames(ele.agn)[4] <- "tbrg"
## agn.hyd.list <- unique(na.omit(merge(ele.agn, unit.name, by = "tbrg", all = TRUE)))
