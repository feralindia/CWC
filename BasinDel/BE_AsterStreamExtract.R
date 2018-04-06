## Extract streams from the ASTER DEM

## set mapset to aststream as an alternative to soidem
execGRASS("g.mapset",
          flags="c", 
	parameters=list(mapset='aststrm')
        )

## generate a mask based on the hull
execGRASS("r.mask",
          flags="overwrite",
          parameters=list(vector='tmp_tbrg_hull_buffer@PERMANENT')
          )

## set region to mask extent
execGRASS("g.region", flags="p",
	parameters=list(zoom="MASK")
        )

## create a copy of the aster clipped to the region of interest
execGRASS("r.mapcalc", flags = "overwrite", expression = "aster = ASTGTM2_N11E076@nilgiris")

execGRASS("g.region", flags="p",
	parameters=list(raster="aster")
        )



##- Option 1: generate stream map from the DEM - prone to errors
## generate accumulation map
execGRASS("r.terraflow",
          flags="overwrite",
          parameters=list(elevation="aster", filled="flooded", direction="flowdir", swatershed="swatershed", accumulation="accum", tci="tci")
          )

## generate streams
execGRASS("r.stream.extract", flags = "overwrite",
          parameters = list(elevation="aster", accumulation="accum", threshold=2, stream_vector="aststrm")
          )

## Option 2: digitise the streams from googlemaps and burn into the aster
## reset resolution to 5m
execGRASS("g.region", flags="p",  res = "5")

## resample the dem
execGRASS("r.resample", flags = "overwrite",
          parameters = list(input="aster", output="aster5m")
          )

## carve the stream
execGRASS("r.carve", flags = "overwrite",
          parameters = list(raster="aster5m", vector="gglstrm", output="carvedaster",
                            width=2, depth=2)
          )

## get the threshold for r.watershed
thresh <- execGRASS("r.threshold", flags = "g",  acc="accum5m", intern = TRUE)
thresh <- as.numeric(gsub("\\D", "", thresh)) 

## generate drain direction map
execGRASS("r.watershed",
          flags=c("overwrite"),
          parameters=list(elevation='carvedaster', threshold=400, # 400
               drainage='draindir5m', basin='basin5m', 
               stream='stream5m')
          ) ## 2414 pixels is r.threshold shows only third order streams

## get catchment areas
## This is being done manually and data recorded below.
## can copy procedure from earlier code to automate, however
## automation takes away the ability to id each point visually.
## command is:
## r.water.outlet --overwrite input=draindir5m@aststrm output=tmpwlr103@aststrm coordinates=670570.103456,1246668.6322
## r.stats -a -n input=tmpwlr103@aststrm 
## note: these coordinates are manually entered.
