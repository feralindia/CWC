## function to convert intern values to a dataframe
fun.int2df <- function(x){
  x1 <- t(as.data.frame(strsplit(x, ",")))
  row.names (x1) <- NULL
  colnames (x1) <- x1[1,]
  x1 <- x1[-1,]
  return(as.data.frame(x1))
}
##---- Chunk 2 - import data in to PERMANENT and create masks
execGRASS("g.mapset",
	parameters=list(mapset='PERMANENT')
) # assign mapset
execGRASS("db.connect", flags="d")
execGRASS("v.in.ogr",
	flags=c("o", "overwrite"),
    parameters=list(dsn=dsn, layer=contour.layer,output='soi_contours')
) # import the contour vector
execGRASS("v.build",
          flags=c("e","overwrite", "verbose"),
          parameters=list(map='soi_contours', error='soi48j11c15_contour_errors')
          ) # re-build the topolgy to ensure there are no errors
execGRASS("v.in.ogr",
	flags=c("o", "overwrite"),
    parameters=list(dsn=dsn, layer=stream.layer,output='tmp_stream')
          )
execGRASS("v.build",
          flags=c("e","overwrite", "verbose"),
          parameters=list(map='tmp_stream', error='tmp_stream_errors')
          )
execGRASS("v.in.ogr",
	flags=c("o", "overwrite"),
    parameters=list(dsn=dsn, layer=tbrg.layer,output='tmp_tbrg')
          )
execGRASS("v.in.ogr",
          flags=c("o", "overwrite"),
          parameters=list(dsn=dsn, layer=wlr.layer,output='tmp_wlr')
          ) # import the wlr locations
execGRASS("v.hull",
          flags="overwrite",
          parameters=list(input='tmp_tbrg', output='tmp_tbrg_hull')
          )## create convex hull around TBRGs
execGRASS("v.buffer",
          flags="overwrite",
          parameters=list(input='tmp_tbrg_hull', output='tmp_tbrg_hull_buffer', 
                          distance=2000)
          )## create a 5k buffer around the hull
execGRASS("g.region",
          flags="p",
          parameters=list(vect='tmp_tbrg_hull_buffer', res='10')
) # set region to buffer and resolution to 10m
#         (rast='soi8j11a15c.rgb', res='10')
#         ) ## define region to extent of survey map
execGRASS("v.in.region",
          flags="overwrite",
          parameters=list(output='tmp_regvec')
          ) # convert region to a vector
execGRASS("v.overlay",
          flags=c("overwrite", "t"),
          parameters=list(ainput='tmp_tbrg_hull_buffer', 
                          binput='tmp_regvec', operator='and', output='tmp_mask')
          )

##---- Chunk 3 - create the DEM
execGRASS("g.mapset",
          flags="c", 
	parameters=list(mapset='elevation')
) # switch to elevation
execGRASS("db.connect", flags="d")
execGRASS("g.region", flags="p",
	parameters=list(vect='tmp_tbrg_hull_buffer@PERMANENT', res='10')
) # set region to vect res to 10
execGRASS("r.mask",
          flags="overwrite",
          parameters=list(vector='tmp_tbrg_hull_buffer@PERMANENT')
)# generate mask
execGRASS("v.to.rast",
	flags=c("d", "overwrite"),
	parameters=list(input='soi_contours@PERMANENT', type='line', 
                  output='soi.contour', use='attr', attrcolumn='contour_li')
) # rasterise contours
execGRASS("r.thin",
	flags="overwrite",
	parameters=list(input='soi.contour', output='soi.contour.thin')
) # thin the raster
execGRASS("r.surf.contour",
	flags="overwrite",
	parameters=list(input='soi.contour.thin@elevation', 
                  output='soi.dem')
) # generate the dem

##---- Chunk 4 - burn streams into DEM
execGRASS("v.to.rast",
          flags="overwrite",
          parameters=list(input='tmp_stream@PERMANENT', 
                          type='line', output='soi.stream', 
                          use='val', value=10)
          ) # rasterise stream vector set to 10
execGRASS("r.null",
          parameters=list(map='soi.stream', null=0)
          )## set the null to 0
execGRASS("r.buffer",
          flags=c("z", "overwrite"),
          parameters=list(input='soi.stream', 
                          output='tmp.soi.streamwide', 
                          distances=c(20,30,40,50,60,70,80,90)) 
          # generate slopes around the streams
          )
execGRASS("r.mapcalc",
          flags="overwrite",
          expression='tmp.soi.streamwide = (tmp.soi.streamwide-11)*2') 
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

##-----  Chunk 5 - get coordinates of stream closest to wlr locations

coordfile <- execGRASS("v.db.select",
          parameters=list(map='tmp_wlr@PERMANENT', columns='x,y,wlr_id', 
                          separator=','), intern=TRUE)
coordfile <- t(as.data.frame(strsplit(coordfile, ",")))
row.names(coordfile) <- NULL

## coordfile <- paste(getwd(), "/wlrcoords.csv", sep="")

execGRASS("g.mapset", flags="c",
	parameters=list(mapset='gps')
) # assign mapset
execGRASS("db.connect", flags="d")
execGRASS("g.copy", flags="overwrite", 
          parameters=list(vect='tmp_wlr@PERMANENT,tmp_wlr') # copy table to mapset gps
)# copy tmp_wlr to gps mapset

execGRASS("v.db.addcolumn",
          parameters=list(map='tmp_wlr@gps', columns="min_dist real, to_x real, to_y real")
          )

execGRASS("v.distance",
          flags=c("quiet", "overwrite"),
          parameters=list(from='tmp_wlr@gps', from_type='point', 
                          to='tmp200_stream@elevation', to_type='line',
              upload=c('dist','to_x','to_y'), column=c('min_dist','to_x','to_y'), output='wlr_dist')
              )

wlr.coords <- execGRASS("v.db.select",
          flags="overwrite",
          parameters=list(map='tmp_wlr@gps', columns=c('unit_id','wlr_id','to_x','to_y'), 
                          separator=','), intern=TRUE
          )
wlr.coords <- fun.int2df(wlr.coords)
## from: <http://pvanb.wordpress.com/2013/01/23/import-grass-function-console-output-as-data-frame-in-r/>
## this is messy
##con <- textConnection(wlr.coords)
##wlr.coords<- read.table(con, header=TRUE, sep="|", quote="")
##close(con)
##write.csv(wlr.coords, file="tmpcsv.csv", quote=FALSE, row.names=FALSE)
##wlr.coord <- read.csv(file="tmpcsv.csv", header=TRUE)
##wlr.coords$wlr_id <- c("wlr_001", "wlr_002", "wlr_003", "wlr_004", "wlr_005", "wlr_008", "wlr_009", "wlr_010", "wlr_011")
## wlr.coords <- read.csv(file=coordfile, header=TRUE)

execGRASS("g.mapset",
	parameters=list(mapset='elevation')
) # assign mapset

for(i in 1:nrow(wlr.coords)){
    outmap <- paste(wlr.coords$wlr_id[i], "_catchment", sep="")
    outmap.recl <- paste(outmap, ".recl", sep="")
    unit.id <- wlr.coords$Unit_ID[i]
    rules <- paste("1 = 1 ",unit.id, sep="") ## add name of wlr to raster label
    write.table(file="rulefile.txt", rules, quote=FALSE, row.names=FALSE, col.names=FALSE)
    execGRASS("r.water.outlet",
          flags="overwrite",
          parameters=list(input='tmp200_draindir@elevation', output=outmap, 
                          coordinates=c(wlr.coords$to_x[i], wlr.coords$to_y[i]))
          )
    
    execGRASS("r.reclass",
              flags="overwrite",
              parameters=list(input=outmap, output=outmap.recl, rules='rulefile.txt')
              )
    
    ## alternatively you can use this:
    ## execGRASS("r.basin",
    ##       parameters=list(map='tmp_dem', prefix=outmap,
    ##           coordinates=c(wlr.coords$x[i], wlr.coords$y[i]), dir=getwd(), threshold=200)
    ##       )

   
   ## exp <- paste(outmap, "=", outmap, "*", i, sep="")
    ##execGRASS("r.mapcalc",
     ##     flags="overwrite",
      ##    expression=exp)
    
    execGRASS("r.to.vect",
              flags=c("s", "overwrite"),
              parameters=list(input=outmap.recl, output=outmap, type='area', column='id')
              ) # vectorise
}

##---- Chunk 6 reporting for catchments

wlr.list <- paste(wlr.coords$wlr_id, "_catchment", sep="")


execGRASS("v.patch",
          flags=c("e","overwrite"),
          parameters=list(input=wlr.list, output='wlr_catchments_patched')
          ) # patch all catchments to one layer

## execGRASS("v.clean",
##           flags=c("overwrite"),
##           parameters=list(input='wlr_catchments_patched@elevation', output='wlr_catchments_patched_cl', tool=c('rmdupl'))
##           )

execGRASS("v.db.addcolumn",
          parameters=list(map='wlr_catchments_patched@elevation', columns="area_ha real")
          )
execGRASS("v.to.db",
          parameters=list(map='wlr_catchments_patched@elevation', option='area', columns='area_ha', units='hectares')
          )
execGRASS("v.db.renamecolumn",
          parameters=list(map='wlr_catchments_patched@elevation', column="label,wlr_id")
          )
execGRASS("v.db.dropcolumn",
          parameters=list(map='wlr_catchments_patched@elevation', columns='id')
          )
execGRASS("v.out.ogr",
          flags=c("s", "e", "overwrite"),
          parameters=list(input='wlr_catchments_patched@elevation', dsn='./', format='ESRI_Shapefile', olayer='wlr_catchments')
          )


##---- Chunk 7 generating maps and reporting for basins
##-- get optimal threshold values

execGRASS("r.terraflow",
flags="overwrite",  
parameters=list(elevation='tmp_dem@elevation', filled='tmp.flood', 
                direction='tmp.flowdir', swatershed='tmp.sink', 
                accumulation='tmp.accu', tci='tmp.tci')
) # generate accumulation and lots of unneeded rasters

execGRASS("r.threshold",
          parameters=list(acc='tmp.accu@elevation')
          ) # calculate the threshold for basin delieanation , intern=TRUE not working

thresh <- 2414 # from command above
bas.thresh <- paste("tmp", thresh, "_basin", sep='')
execGRASS("r.watershed",
          flags=c("overwrite"),
          parameters=list(elevation='tmp_dem@elevation', threshold=thresh, ## fix this
               basin=bas.thresh)
          )
 execGRASS("r.to.vect",
              flags=c("s","overwrite"),
              parameters=list(input=bas.thresh, output='allbasins', type='area')
              )
execGRASS("v.select",
          flags="overwrite",
          parameters=list(ainput='allbasins', atype='area', binput='tbrg_mar14@gps', btype='point', output='selbasins', operator='contains')
          )

execGRASS("v.db.addcolumn",
          parameters=list(map='selbasins', columns="area_ha real")
          )
execGRASS("v.to.db",
          parameters=list(map='selbasins', option='area', columns='area_ha', units='hectares')
          )  # put area onto db column

execGRASS("g.mapset",
          parameters=list(mapset='gps')
          )
execGRASS("v.db.addcolumn",
          parameters=list(map='tbrg_mar14@gps', columns="cat_basin real, area_ha real")
          )
execGRASS("v.what.vect",
          parameters=list(map='tbrg_mar14@gps', column='cat_basin', qmap='selbasins@elevation', qcolumn='cat')
          )
execGRASS("v.what.vect",
          parameters=list(map='tbrg_mar14@gps', column='area_ha', qmap='selbasins@elevation', qcolumn='area_ha')
          )
execGRASS("v.out.ogr",
          flags=c("e", "overwrite"),
          parameters=list(input='selbasins@elevation', dsn='./', format='ESRI_Shapefile', olayer='tbrg_basins')
          )
execGRASS("v.out.ogr",
          flags=c("s", "e", "overwrite"),
          parameters=list(input='tbrg_mar14@gps', dsn='./', format='ESRI_Shapefile', olayer='tbrg_wpt')
          )


