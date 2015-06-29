##---- Chunk 1 - intitialise
library(spgrass6) # control GRASS from within R
setwd("/home/udumbu/rsb/OngoingProjects/CWC/rdata/grass/basindel/")
dsn <- paste(getwd(),"/datadir/agh/", sep="") # nlg or agn
contour.layer <- "aghna_contourline48j11_15c" # contour lines
stream.layer <- "aghnashini_stream_utm43" ## "aghna_stream_basin003" # streams
wlr.layer <- "wlr_sirsiUTM" # water leve recorders
tbrg.layer <- "tbrg_sirsiUTM" # rain gauges


## Generate functions
## function to convert intern values to a dataframe
fun.int2df <- function(x){
  x1 <- t(as.data.frame(strsplit(x, ",")))
  row.names (x1) <- NULL
  colnames (x1) <- x1[1,]
  x1 <- x1[-1,]
  return(as.data.frame(x1))
}

## Call the routines
source(file="BE_import.R", echo=TRUE)
source(file="BE_genDEM.R", echo=TRUE)
source(file="BE_burnStreams.R", echo=TRUE)
source(file="BE_findStrcoords.R", echo=TRUE)
source(file="BE_repCatchments.R", echo=TRUE)
source(file="BE_repBasins.R", echo=TRUE)
