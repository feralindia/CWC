##---- Chunk 1 - intitialise
library(spgrass6) # control GRASS from within R
setwd("/home/udumbu/rsb/OngoingProjects/CWC/rdata/grass/basindel/")
dsn <- paste(getwd(),"/datadir/nlg/", sep="") # nlg or agn
contour.layer <- "nilgiri_contour_line" # contour lines
stream.layer <- "nilgiri_streams_line" # streams
wlr.layer <- "wlrloc" # water leve recorders
tbrg.layer <- "tbrgloc" # rain gauges
soitopo.rgb <- "soi58a11_12"

## Call the routine
source(file="BasinExtract.R", echo=TRUE)
