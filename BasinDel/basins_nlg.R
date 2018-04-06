##---- Chunk 1 - intitialise
library(rgrass7) # (spgrass6) # control GRASS from within R
setwd("/home/udumbu/rsb/Res/CWC/Anl/BasinDel/")
dsn <- paste(getwd(),"/datadir/nlg/", sep="") # nlg or agn
contour.layer <- "nilgiri_contour_line" # contour lines
stream.layer <- "nilgiri_streams_line" # streams
wlr.layer <- "wlr_location_11units" # water leve recorders
tbrg.layer <- "tbrg_location_29units" # rain gauges
soitopo.rgb <- "soi58a1158a12"
site <- "Nilgiris"
## Call the routine
##  source(file="BasinExtract.R", echo=TRUE)
## function to convert intern values to a dataframe
fun.int2df <- function(x){
  x1 <- t(as.data.frame(strsplit(x, ",")))
  row.names (x1) <- NULL
  colnames (x1) <- x1[1,]
  x1 <- x1[-1,]
  return(as.data.frame(x1))
}

## Call the routines
## source(file="BE_import.R", echo=TRUE)

## source(file="BE_genDEM.R", echo=TRUE)
source(file="BE_burnStreams.R", echo=TRUE) # Burning not done. Check script
source(file="BE_findStrcoords.R", echo=TRUE)
## source(file="BE_repCatchments.R", echo=TRUE)
source(file="BE_repBasins.R", echo=TRUE)
