## This script merges discharge data with the sediment/nutrient dataset and generates two outputs:
## 1) a replicat of the discharge with the nutrient dat slapped on
## 2) a series of discharge points for each of the sediment/nutrient points.
## Integrated and stage samplers are treated differently
## Note that stage samplers are only taking water from the surface of the stream as it rises (rising limb)
## Time stamps of the stage samplers are adjusted based on the stage of the stream and the time of installation of the sampler
## Note that time between collection and analysis of the sample is much  higher for the stage samplers.

##--load libraries
library(timeSeries)

##-- load functions
source("functions.R", echo = TRUE)

##--define constants
site.name <- "Nilgiris" # "Aghnashini"
data.dir <- "~/OngoingProjects/CWC/Data"
site.data.dir <- paste(data.dir, site.name, sep = "/")
dis.dir <- paste(site.data.dir, "discharge/csv", sep = "/")
dis.flnm <- list.files(dis.dir, full.names=FALSE)
dis.full.flnm <- list.files(dis.dir, full.names=TRUE)
dis.stn <- as.numeric(substr(dis.flnm, start=14, stop=16))
dis.data.df <- data.frame(dis.stn, dis.flnm, dis.full.flnm)
int.samp.dir <- list.dirs(paste(site.data.dir, "wtr.qual/integrated", sep="/"), recursive=FALSE)
int.samp.stn <- as.numeric(gsub("[^[:digit:] ]", "", int.samp.dir))
int.samp.flnm <- unlist(lapply(int.samp.dir, list.files))
int.samp.full.flnm <- unlist(lapply(int.samp.dir, list.files, full.names=TRUE))
int.samp.data.df <- data.frame(int.samp.stn, int.samp.flnm, int.samp.full.flnm)

##-- read sediment and nutrient data
all.sed.data <- mapply(read.csv.files, int.samp.flnm, int.samp.full.flnm, SIMPLIFY=FALSE)
names(all.sed.data)

all.dis.data <- mapply(read.csv.files, dis.flnm, dis.full.flnm, SIMPLIFY=FALSE)
names(all.dis.data)
##-- match the loggers
merged.flnm <- merge(dis.data.df, int.samp.data.df, by.x="dis.stn", by.y="int.samp.stn", all = TRUE)
names(merged.flnm)
merged.data <- read.merge.data(merged.flnm)

##--- Integrated sampler section ---##
