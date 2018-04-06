
##---- Chunk 4 - burn streams into DEM

execGRASS("g.mapset",
          flags="c", 
          parameters=list(mapset='elevation')
          )

## burn stream routine now uses r.carve

## carve the stream - DO NOT DO THIS YET THIS IS TEST CODE
## execGRASS("r.carve", flags = "overwrite",
##           parameters = list(raster="soi.dem", vector="gglstrm", output="tmp_dem1",
##                             width=25, depth=6)
##           )

execGRASS("r.carve", flags = "overwrite",
          parameters = list(raster="soi.dem", vector="gglstrm", output="tmp_dem",
                            width=4, depth=2)
          )
execGRASS("g.remove", type = "raster", name = "tmp_dem1", flags = "f")

## extract the streams (not basins) for the DEM

## generate accumulation map: Ignored because thresh is set to 200
## execGRASS("r.terraflow",
##           flags="overwrite",
##           parameters=list(elevation="tmp_dem", filled="flooded", direction="flowdir", swatershed="swatershed", accumulation="accum", tci="tci")
##           )

## get the threshold for r.watershed: Ignored because thresh is set to 200
## thresh <- execGRASS("r.threshold", flags = "g",  acc="accum5m", intern = TRUE)
## thresh <- as.numeric(gsub("\\D", "", thresh)) 

execGRASS("r.watershed",
          flags=c("overwrite"),
          parameters=list(elevation='soi.dem@elevation', threshold=100, convergence = 10,
               drainage='tmp200_draindir', basin='tmp200_basin', 
               stream='tmp200_stream')
          ) ## 2414 pixels is r.threshold shows only third order streams



execGRASS("r.thin",
	flags="overwrite",
	parameters=list(input='tmp200_stream', output='tmp200_stream_thin')
) 


## execGRASS("r.to.vect",
##           flags="overwrite",
##           parameters=list(input='tmp200_stream_thin', output='tmp200_stream', type='line')
##           )

## execGRASS("v.out.ogr",
##           flags=c("s", "e", "overwrite"),
##           parameters=list(input='tmp200_stream@elevation', output='./datadir/nlg/', format='ESRI_Shapefile', output_layer='extracted_streams'))
