

##---- Chunk 3 - create the DEM
execGRASS("g.mapset",
          flags="c", 
	parameters=list(mapset='elevation')
) # switch to elevation
execGRASS("db.connect", flags="d")
execGRASS("g.region", flags="p",
	parameters=list(vector='tmp_tbrg_hull_buffer@PERMANENT', res='10')
) # set region to vect res to 10
execGRASS("r.mask",
          flags="overwrite",
          parameters=list(vector='tmp_tbrg_hull_buffer@PERMANENT')
)# generate mask
## execGRASS("v.to.rast",
## 	flags=c("d", "overwrite"),
## 	parameters=list(input='soi48_11j15c_contours@PERMANENT', type='line', 
##                   output='soi.contour', use='attr', attribute_column='contour_li')
## ) # rasterise contours
## rasterise contours replaced by re-projected soi.contour file sittingin data directory
execGRASS("r.import", flags = c("o", "overwrite"), parameters = list(input=paste0(dsn, "soi_contour_modified2.tif"), output="soi.contour"))

execGRASS("r.thin",
	flags="overwrite",
	parameters=list(input='soi.contour', output='soi.contour.thin')
) # thin the raster
execGRASS("r.surf.contour",
	flags="overwrite",
	parameters=list(input='soi.contour.thin@elevation', 
                  output='soi.dem')
) # generate the dem

## execGRASS("r.out.gdal", 
