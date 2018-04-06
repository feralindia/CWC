library(spgrass6)
library(raster)
library(rgdal)
library(spdep)
library(rasterVis)
# Pick the dataset you'd like to work on by uncommenting the relevant line
# dataset<-"nilgiris"
# dataset<-"agnashini"
# Create a mapset
system("g.mapset -c mapset=nilgiris")
# Import the rasters
datadir<-"/home/rsb/OngoingProjects/CWC/Maps/UpperNilgiris/data/"
setwd(datadir)

rastlist<-c("ASTGTM2_N11E076.tif", "58a12_everest_clip.tif", "58a11_everest_indnep.tif")
i<-1
while(i<=length(rastlist)){
  execGRASS("r.in.gdal",
            flags=c("o", "e", "overwrite"),
            parameters=list(input=paste(datadir, rastlist[i], ".tif", sep=""),
                            output=rastlist[i])
  )
  i <- i+1;
}
system("g.region rast=ASTGTM2_N11E076@nilgiris -p")




##i.image.mosaic --overwrite input=soi_58a12@nilgiris,soi_58a11@nilgiris output=soi_58a_11_12



elmap <- "ASTGTM2_N11E076@nilgiris"

## First run r.terraflow to generate one set of input maps
# 
# execGRASS("r.terraflow", 
#           flags=c("overwrite"),
#           parameters=list(
#             elevation=elmap, 
#             filled="filled", 
#             direction="flowdir", 
#             swatershed="sinkws", 
#             accumulation="flowacc", 
#             tci="tci", 
#             memory=(1000L)
#             ) 
#           )

## Now run r.watershed with a loop to go through all the values for the threshold
thresh <- c(4444, 6944L) ## (4444L, 6944L, 10000L, 27777L)
ha <- c(20, 25) ## ((20, 25, 30, 50))
i <- 1
while(i<=length(thresh)){
  out.accum <- paste("ws", ha[i], ".accum", sep="")
  out.tci <- paste("ws", ha[i], ".tci", sep="")
  out.draindir <- paste("ws", ha[i], ".draindir", sep="")
  out.basin <- paste("ws", ha[i], ".basin", sep="")
  out.stream <- paste("ws", ha[i], ".stream", sep="")
  out.drdir <- paste("ws", ha[i], ".drdir", sep="")
  out.slope <- paste("ws.", ha[i], ".LS", sep="")
  out.steepness <- paste("ws_", ha[i], ".S", sep="")
  v.raw.stream<- paste("ws_", ha[i], "stream_raw", sep="")
  v.raw.basin <- paste("ws_", ha[i], "basin_raw", sep="")
  v.smt.stream <- paste("ws_", ha[i], "stream_smt", sep="")
  v.smt.basin <- paste("ws_", ha[i], "basin_smt", sep="")
  out.stream.thin <- paste("ws_", ha[i], "stream.thin", sep="")
  
  execGRASS("r.watershed", 
            flags=c("overwrite"),
            parameters=list(
              elevation=elmap, 
              accumulation="flowacc", 
              tci=out.tci,
              drainage=out.drdir, 
              basin=out.basin, 
              stream=out.stream, 
              length_slope=out.slope,
              slope_steepness=out.steepness,
              threshold=thresh[i], 
              convergence=(5L), 
              memory=(1000L))
            )
  
  execGRASS("r.thin", 
            flags=c("overwrite", "verbose"),
            parameters=list(
              input=out.stream, 
              output=out.stream.thin)
            )
  
  execGRASS("r.to.vect", 
            flags=c("v", "overwrite", "verbose"),
            parameters=list(
              input=out.stream.thin, 
              output=v.raw.stream, 
              type="line")
            )
  
  execGRASS("r.to.vect", 
            flags=c("v", "s", "overwrite", "verbose"),
            parameters=list(
              input=out.basin, 
              output=v.raw.basin, 
              type="area")
            )
  
  #execGRASS("v.generalize", parameters=list(input=v.raw.stream, output=v.smt.stream, type="line", method="chaiken", threshold=(10L)), flags=c("c", "overwrite", "verbose"))
  
  #execGRASS("v.generalize", parameters=list(input=v.raw.basin, output=v.smt.basin, type="area", method="chaiken", threshold=(10L)), flags=c("c", "overwrite", "verbose"))
  
  #execGRASS("g.remove", parameters=list(vect=v.raw.stream))
  
  #execGRASS("g.remove", parameters=list(vect=v.raw.basin))
  
  i <- i+1;
  
  ## Now set the region to the location of the WLRs in two selected catchments  
  
  
}


##g.region vect=Wpt13May2013@nilgiris,Wpt12May2013@nilgiris -p       

## Copy script from the Kalivelli Discharge paper which draws catchments for given points here.


