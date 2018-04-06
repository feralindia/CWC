##---- libraries

library(rgdal) # manipulate raster images
library(maptools)
library(sp)
library(gstat)

##---- Select site ---##

site <- "Nilgiris" ## Aghnashini
## outfldr <- datadir



##---- load functions
source("functions.R", echo=FALSE)

##---- Get file names into object by site and period
max.event <- 8 ## how many maximum rainfall events to be processed?
datadir <- paste(getwd(), "/", site,"/", sep="")
samp.prd <- "15 min" ## c("15 min", "1 hour", "1 day", "15 day") # sampling period
##--- list hydgrpharge stations to be processed
## note that temporal resolution is 15 minutes

if(site=="Nilgiris"){
    hydgrph.stn <- c("HydroGraph_stn101_tbrg_102_Discharge_15-Aug-2012_to_31-Mar-2016.csv","HydroGraph_stn104_tbrg_109_Discharge_15-Aug-2012_to_31-Mar-2016.csv","HydroGraph_stn109_tbrg_112_Discharge_15-Aug-2012_to_31-Mar-2016.csv")
    hydgrph.cover <- c("Wattle", "Grassland", "Shola")
    hydgrph.UnitID <- c("TBRG 101", "TBRG 109", "TBRG 112")
    hydgrph.x <- c(671021)
    hydgrph.y <- c(1247924)
}else{
     hydgrph.stn <- c("a", "b", "c") ## NEED TO IDENTIFY STATIONS FOR AGHNASHINI
     hydgrph.cover <- c("Forest", "Agriculture", "Mixed")
}

##--- read in spatial data
    
    spat.agn <- as.data.frame(readOGR(dsn = "./", paste("tbrg_", "Aghnashini", sep = ""))) # data is in UTM 43 North EPSG 32643
    spat.nlg <- as.data.frame(readOGR(dsn = "./", paste("tbrg_", "Nilgiris", sep = ""))) # data is in UTM 43 North EPSG 32643
    spat.nlg$Unit_ID <- paste("TBRG", spat.nlg$Unit_ID)  ## Need to fix this field in the shape file
    


tbrg.csv.dir <- paste("~/OngoingProjects/CWC/Data/", site, "/tbrg/csv/", sep = "")
hydgrph.csv.dir <- paste("~/OngoingProjects/CWC/Data/", site, "/hydrograph/csv/", sep = "")

## /home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hydrograph/csv/HydroGraph_stn101_tbrg_102_Discharge_15-Aug-2012_to_31-Mar-2016.csv

##---- get file names
## for rain gauges for sampling period
for(j in 1:length(samp.prd)){
    fn.short <- gsub(pattern = ".csv", replacement = "",
                     x = list.files(tbrg.csv.dir, pattern = samp.prd[j]))
    ## fn.short <- gsub(pattern = " ", replacement = "_", x = fn.short) # remove space
    fn.full <- list.files(tbrg.csv.dir, pattern = samp.prd[j], full.names = TRUE)
    site.prd <- paste("RainFiles",site, samp.prd[j], sep = "_")
    assign(site.prd, data.frame(fn.full, fn.short))
}

##---- file names for discharge events with a one week period before and after
for(j in 1:length(disch.stn)){}
j <- 1
    fn.short <- list.files(hydgrph.csv.dir, pattern = hydgrph.stn[j], full.names = FALSE)
    fn.full <- list.files(hydgrph.csv.dir, pattern = hydgrph.stn[j], full.names = TRUE)
    hydgrph.files <- gsub(pattern=".csv", replacement="", x=fn.short) ## HERE HERE 
    assign(hydgrph.files, data.frame(fn.full, fn.short))
}


source("RainResponse.R", echo=TRUE)
source("HydroResponse.R", echo=TRUE)

