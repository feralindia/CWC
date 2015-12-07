

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
try(execGRASS("v.db.addcolumn",
          parameters=list(map='tbrg_mar14@gps', columns="cat_basin real, area_ha real")
          ), silent=TRUE)
execGRASS("v.what.vect",
          parameters=list(map='tbrg_mar14@gps', column='cat_basin', qmap='selbasins@elevation', qcolumn='cat')
          )
execGRASS("v.what.vect",
          parameters=list(map='tbrg_mar14@gps', column='area_ha', qmap='selbasins@elevation', qcolumn='area_ha')
          )
execGRASS("v.out.ogr",
          flags=c("e", "overwrite"),
          parameters=list(input='selbasins@elevation', output=dsn, format='ESRI_Shapefile', olayer='tbrg_basins')
          )
execGRASS("v.out.ogr",
          flags=c("s", "e", "overwrite"),
          parameters=list(input='tbrg_mar14@gps', output=dsn, format='ESRI_Shapefile', olayer='tbrg_wpt')
          )


