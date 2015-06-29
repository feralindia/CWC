
##---- Chunk 4 - burn streams into DEM
execGRASS("v.to.rast",
          flags="overwrite",
          parameters=list(input='tmp_stream@PERMANENT', 
                          type='line', output='soi.stream', 
                          use='val', value=10) 
          ) # rasterise stream vector set to 5 from 10
execGRASS("r.null",
          parameters=list(map='soi.stream', null=0)
          )## set the null to 0

dist <- c(20,30,40,50,60,70,80,90)  #for 10m res
## dist <- c(5,10,15,20,25,30,35,40)  #for 5m res
execGRASS("r.buffer",
          flags=c("z", "overwrite"),
          parameters=list(input='soi.stream',
                          output='tmp.soi.streamwide', 
                          distances=dist) 
          # generate slopes around the streams
          )
execGRASS("r.mapcalc",
          flags="overwrite",
          expression='tmp.soi.streamwide = (tmp.soi.streamwide-6)*2')  ## changed from 11 to 6
execGRASS("r.null",
          parameters=list(map='tmp.soi.streamwide', null=0)
          )## set the null to 0
execGRASS("r.mapcalc",
          flags="overwrite",
          expression='tmp_dem = soi.dem+tmp.soi.streamwide') ## subtract stream from DEM
## extract the streams (not basins) for the DEM

execGRASS("r.watershed",
          flags=c("overwrite"),
          parameters=list(elevation='tmp_dem@elevation', threshold=200,
               drainage='tmp200_draindir', basin='tmp200_basin', 
               stream='tmp200_stream')
          ) ## 2414 pixels is r.threshold shows only third order streams
execGRASS("r.to.vect",
          flags="overwrite",
          parameters=list(input='tmp200_stream', output='tmp200_stream', type='line')
          )
## execGRASS("r.out.gdal", 
