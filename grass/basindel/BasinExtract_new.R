
##---- Chunk 2 - import data in to PERMANENT and create masks
execGRASS("g.mapset",
	parameters=list(mapset='PERMANENT')
) # assign mapset

execGRASS("db.connect", flags="d") # generate a sqlite connection and make it default

##----- need to instert a call to import the raster here.
##execGRASS("r.in.gdal",
  ##        )
##--------------------

execGRASS("v.in.ogr",
	flags=c("o", "overwrite"),
    parameters=list(dsn=dsn, layer=contour.layer,output='contours')
) # digitised contour lines
execGRASS("v.build",
          flags=c("e","overwrite", "verbose"),
          parameters=list(map='contours', error='contour_errors')
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
          parameters=list(input='tmp_tbrg_hull', output='tmp_tbrg_hull_buffer', distance=5000)
          )## create a 5k buffer around the hull
execGRASS("g.region",
          flags="p",
          parameters=list(rast=soitopo.rgb, res='10')
          ) ## define region to extent of survey map
execGRASS("v.in.region",
          flags="overwrite",
          parameters=list(output='tmp_regvec')
          ) # convert region to a vector
execGRASS("v.overlay",
          flags=c("overwrite", "t"),
          parameters=list(ainput='tmp_tbrg_hull_buffer', binput='tmp_regvec', operator='and', output='tmp_mask')
          )

##---- Chunk 3 - create the DEM
execGRASS("g.mapset",
	parameters=list(mapset='elevation')
) # switch to elevation

execGRASS("db.connect", flags="d") # generate a sqlite connection and make it default

execGRASS("g.region", flags="p",
	parameters=list(vect='tmp_tbrg_hull_buffer@PERMANENT', res='10')
) # set region to vect res to 10
execGRASS("r.mask",
          flags="overwrite",
          parameters=list(vector='tmp_mask@PERMANENT')
)# generate mask
execGRASS("v.to.rast",
	flags=c("d", "overwrite"),
	parameters=list(input='contours@PERMANENT', type='line', output='contour', use='attr', attrcolumn='contour_li')
) # rasterise contours
execGRASS("r.thin",
	flags="overwrite",
	parameters=list(input='contour', output='contour.thin')
) # thin the raster
execGRASS("r.surf.contour",
	flags="overwrite",
	parameters=list(input='contour.thin@elevation', output='dem')
) # generate the dem

##---- Chunk 4 - burn streams into DEM
execGRASS("v.to.rast",
          flags="overwrite",
          parameters=list(input='tmp_stream@PERMANENT', type='line', output='stream', use='val', value=10)
          ) # rasterise stream vector set to 10
execGRASS("r.null",
          parameters=list(map='stream', null=0)
          )## set the null to 0
execGRASS("r.buffer",
          flags=c("z", "overwrite"),
          parameters=list(input='stream', output='tmp.streamwide', distances=c(20,30,40,50,60,70,80,90)) # generate slopes around the streams
          )
execGRASS("r.mapcalc",
          flags="overwrite",
          expression='tmp.streamwide = (tmp.streamwide-11)*2') 
execGRASS("r.null",
          parameters=list(map='tmp.streamwide', null=0)
          )## set the null to 0
execGRASS("r.mapcalc",
          flags="overwrite",
          expression='tmp_dem = dem+tmp.streamwide') ## subtract stream from DEM
## extract the basins for the DEM
execGRASS("r.watershed",
          flags=c("overwrite"),
          parameters=list(elevation='tmp_dem@elevation', threshold=200,
               drainage='tmp200_draindir', basin='tmp200_basin', stream='tmp200_stream')
          )
execGRASS("r.thin",
	flags="overwrite",
	parameters=list(input='tmp200_stream', output='tmp200_stream.thin')
) # thin the raster
          

execGRASS("r.to.vect",
          flags="overwrite",
          parameters=list(input='tmp200_stream.thin', output='tmp200_stream', type='line')
          )

##-----  Chunk 5 - get coordinates of stream closest to wlr locations
coordfile <- paste(getwd(), "/wlrcoords.csv", sep="")

execGRASS("g.mapset",
	parameters=list(mapset='gps')
) # assign mapset


execGRASS("db.connect", flags="d") # generate a sqlite connection and make it default

execGRASS("g.copy",
          flags="overwrite",
          parameters=list(vect="tmp_wlr@PERMANENT,wlr_streams")
          ) # copy tmp_wlr to gps mapset. Should relook at the mapsets
## copy the tbrg map to gps mapset
execGRASS("g.copy",
          flags="overwrite",
          parameters=list(vect="tmp_tbrg@PERMANENT,tbrg_loc")
          ) # copy tmp_wlr to gps mapset. Should relook at the mapsets

execGRASS("v.db.addcolumn",
          parameters=list(map='wlr_streams@gps', columns="min_dist real, x real, y real")
          )

execGRASS("v.distance",
          flags=c("quiet", "overwrite"),
          parameters=list(from='wlr_streams@gps', from_type='point', to='tmp200_stream@elevation', to_type='line',
              upload=c('dist','to_x','to_y'), column=c('min_dist','x','y'), output='wlr_dist')
              )

execGRASS("v.db.select",
          flags="overwrite",
          parameters=list(map='wlr_streams@gps', columns=c('unit_id','wlr_id','x','y'), separator=',', file=coordfile)
          ) # need to standardise the column names in the original files. This is ridiculous.
## from: <http://pvanb.wordpress.com/2013/01/23/import-grass-function-console-output-as-data-frame-in-r/>
## this is messy
##con <- textConnection(wlr.coords)
##wlr.coords<- read.table(con, header=TRUE, sep="|", quote="")
##close(con)
##write.csv(wlr.coords, file="tmpcsv.csv", quote=FALSE, row.names=FALSE)
##wlr.coord <- read.csv(file="tmpcsv.csv", header=TRUE)
##wlr.coords$wlr_id <- c("wlr_001", "wlr_002", "wlr_003", "wlr_004", "wlr_005", "wlr_008", "wlr_009", "wlr_010", "wlr_011")
wlr.coords <- read.csv(file=coordfile, header=TRUE)

execGRASS("g.mapset",
	parameters=list(mapset='elevation')
) # assign mapset

for(i in 1:nrow(wlr.coords)){
    outmap <- paste(wlr.coords$wlr_id[i], "_catchment", sep="")
    outmap.recl <- paste(outmap, ".recl", sep="")
    unit.id <- wlr.coords$unit_id[i]
    rules <- paste("1 = 1 ",unit.id, sep="")
    write.table(file="rulefile.txt", rules, quote=FALSE, row.names=FALSE, col.names=FALSE)
    execGRASS("r.water.outlet",
          flags="overwrite",
          parameters=list(input='tmp200_draindir@elevation', output=outmap, coordinates=c(wlr.coords$x[i], wlr.coords$y[i]))
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
              )
}

##---- Chunk 6 reporting for catchments

wlr.list <- paste(wlr.coords$wlr_id, "_catchment", sep="")


execGRASS("v.patch",
          flags=c("e","overwrite"),
          parameters=list(input=wlr.list, output='wlr_catchments_patched')
          )

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
          parameters=list(input='wlr_catchments_patched@elevation', dsn=dsn, format='ESRI_Shapefile', olayer='wlr_catchments')
          )


##---- Chunk 7 generating maps and reporting for basins

execGRASS("r.watershed",
          flags=c("overwrite"),
          parameters=list(elevation='tmp_dem@elevation', threshold=10000,
               basin='tmp10000_basin')
          )
 execGRASS("r.to.vect",
              flags=c("s","overwrite"),
              parameters=list(input='tmp10000_basin', output='allbasins', type='area')
              )
execGRASS("v.select",
          flags="overwrite",
          parameters=list(ainput='allbasins', atype='area', binput='tbrg_loc@gps', btype='point', output='selbasins', operator='contains')
          )

execGRASS("v.db.addcolumn",
          parameters=list(map='selbasins', columns="area_ha real")
          )
execGRASS("v.to.db",
          parameters=list(map='selbasins', option='area', columns='area_ha', units='hectares')
          )

execGRASS("g.mapset",
          parameters=list(mapset='gps')
          )
execGRASS("v.db.addcolumn",
          parameters=list(map='tbrg_loc@gps', columns="cat_basin real, area_ha real")
          )
execGRASS("v.what.vect",
          parameters=list(map='tbrg_loc@gps', column='cat_basin', qmap='selbasins@elevation', qcolumn='cat')
          )
execGRASS("v.what.vect",
          parameters=list(map='tbrg_loc@gps', column='area_ha', qmap='selbasins@elevation', qcolumn='area_ha')
          )
execGRASS("v.out.ogr",
          flags=c("e", "overwrite"),
          parameters=list(input='selbasins@elevation', dsn=dsn, format='ESRI_Shapefile', olayer='tbrg_basins')
          )
execGRASS("v.out.ogr",
          flags=c("s", "e", "overwrite"),
          parameters=list(input='tbrg_loc@gps', dsn=dsn, format='ESRI_Shapefile', olayer='tbrg_wpt')
          )


