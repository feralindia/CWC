
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
