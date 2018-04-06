

##---- Chunk 6 reporting for catchments

## execGRASS("g.mapset",
## 	parameters=list(mapset='elevation')
## ) # assign mapset

## wlr.list <- paste(wlr.coords$wlr_id, "_catchment", sep="")
## wlr.list <- paste("catchment_", wlr.coords$wlr_id, sep="")

## execGRASS("v.patch",
##          flags=c("e","overwrite"),
##          parameters=list(input=wlr.list, output='wlr_catchments_patched')
##          ) # patch all catchments to one layer

## execGRASS("v.clean", flags=c("overwrite"), parameters=list(input='wlr_catchments_patched@elevation', output='wlr_catchments_patched_cl', tool=c('rmdupl')))

## execGRASS("g.rename",flags=c("overwrite"), vector="wlr_catchments_patched_cl,wlr_catchments_patched")

## execGRASS("db.dropcolumn", flags="f",
##           parameters=list(table='wlr_catchments_patched', column='area_ha')
##           )

## execGRASS("v.db.addcolumn",
##           parameters=list(map='wlr_catchments_patched@elevation', columns="area_ha real")
##           )
## execGRASS("v.to.db",
##           parameters=list(map='wlr_catchments_patched@elevation', option='area', columns='area_ha', units='hectares')
##           )
## execGRASS("v.db.renamecolumn",
##           parameters=list(map='wlr_catchments_patched@elevation', column="label,wlr_id")
##           )
## execGRASS("v.db.dropcolumn",
##           parameters=list(map='wlr_catchments_patched@elevation', columns='id')
##           )
## execGRASS("v.out.ogr",
##           flags=c("s", "e", "overwrite"),
##           parameters=list(input='wlr_catchments_patched@elevation', dsn='./', format='ESRI_Shapefile', olayer='wlr_catchments')
##           )
