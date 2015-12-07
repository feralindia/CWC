
##---- Chunk 4 - burn streams into DEM

execGRASS("g.mapset",
          flags="c", 
	parameters=list(mapset='elevation')
)
execGRASS("g.region", raster='soi.dem@elevation', res='10') ## THIS NEEDS TO BE SET FOR AGHNASHINI
execGRASS("v.to.rast",
          flags="overwrite",
          parameters=list(input='tmp_stream@PERMANENT', 
                          type='line', output='soi.stream', 
                          use='val', value=5.0) 
          ) # rasterise stream vector set to 5 from 10
execGRASS("r.null",
          parameters=list(map='soi.stream', null=0)
          )## set the null to 0

## dist <- c(2,4,8,16)  # reduced
## dist <- c(20,30,40,50,60,70,80,90)  #for 10m res
dist <- c(5,10,15)  #for 5m res
execGRASS("r.buffer",
          flags=c("z", "overwrite"),
          parameters=list(input='soi.stream',
                          output='tmp.soi.streamwide', 
                          distances=dist) 
          # generate slopes around the streams
          )
execGRASS("r.mapcalc",
          flags="overwrite",
          expression='tmp.soi.streamwide = (tmp.soi.streamwide-6)*2.0')  ## changed from 11 to 6
execGRASS("r.null",
          parameters=list(map='tmp.soi.streamwide', null=0)
          )## set the null to 0
execGRASS("r.mapcalc",
          flags="overwrite",
          expression='tmp_dem_stream = soi.dem+tmp.soi.streamwide') ## subtract stream from DEM
## add if statement for Nilgiris here
if(site=="Nilgiris"){
## sink reservoirs
execGRASS("v.to.rast",
          flags="overwrite",
          parameters=list(input='reservoirs@PERMANENT', 
                          type='area', output='reservoirs', 
                          use='val', value=-20.0) 
          )

execGRASS("r.null",
          parameters=list(map='reservoirs', null=0)
          )## set the null to 0

execGRASS("r.mapcalc",
          flags="overwrite",
          expression='tmp_dem = tmp_dem_stream+reservoirs') ## subtract reservoirs from DEM
} else {
    execGRASS("g.rename", raster="tmp_dem_stream,tmp_dem")
}


## extract the streams (not basins) for the DEM

execGRASS("r.watershed",
          flags=c("overwrite"),
          parameters=list(elevation='tmp_dem@elevation', threshold=400,
               drainage='tmp200_draindir', basin='tmp200_basin', 
               stream='tmp200_stream')
          ) ## 2414 pixels is r.threshold shows only third order streams

execGRASS("r.thin",
	flags="overwrite",
	parameters=list(input='tmp200_stream', output='tmp200_stream_thin')
) 


execGRASS("r.to.vect",
          flags="overwrite",
          parameters=list(input='tmp200_stream_thin', output='tmp200_stream', type='line')
          )

execGRASS("v.out.ogr",
          flags=c("s", "e", "overwrite"),
          parameters=list(input='tmp200_stream@elevation', output='./datadir/nlg/', format='ESRI_Shapefile', output_layer='extracted_streams'))
