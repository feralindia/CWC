
##-----  Chunk 5 - get coordinates of stream closest to wlr locations
## Commented out. Modified to manual input for the stream outlets. This was validated with GoogeEarth imagery and catchment demarcations also compared.
## Data from the exercise stored in file SoICatchmentAreasUpdatedNov17.csv

## coordfile <- execGRASS("v.db.select",
##           parameters=list(map='tmp_wlr@PERMANENT', columns='x,y,wlr_id', 
##                           separator=','), intern=TRUE)
## coordfile <- t(as.data.frame(strsplit(coordfile, ",")))
## row.names(coordfile) <- NULL

## ## coordfile <- paste(getwd(), "/wlrcoords.csv", sep="")

## execGRASS("g.mapset", flags="c",
## 	parameters=list(mapset='gps')
## ) # assign mapset

## execGRASS("db.connect", flags="d")
## execGRASS("g.copy", flags="overwrite", 
##           parameters=list(vector='tmp_wlr@PERMANENT,tmp_wlr') # copy table to mapset gps
## )# copy tmp_wlr to gps mapset

## execGRASS("v.db.addcolumn",
##           parameters=list(map='tmp_wlr@gps', columns="min_dist real, to_x real, to_y real")
##           )

## execGRASS("v.distance",
##           flags=c("quiet", "overwrite"),
##           parameters=list(from='tmp_wlr@gps', from_type='point', 
##                           to='tmp200_stream@elevation', to_type='line',
##               upload=c('dist','to_x','to_y'), column=c('min_dist','to_x','to_y'), output='wlr_dist')
##               )

## wlr.coords <- execGRASS("v.db.select",
##           flags="overwrite",
##           parameters=list(map='tmp_wlr@gps', columns=c('wlr_id','to_x','to_y'), 
##                           separator=','), intern=TRUE
##           ) ## removed unit_id, may need to correct CHECK HERE IN CASE OF ERROR
## wlr.coords <- fun.int2df(wlr.coords)
## wlr.coords$to_x <- as.numeric(as.character(wlr.coords$to_x))
## wlr.coords$to_y <- as.numeric(as.character(wlr.coords$to_y))
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

wlr.coords <- read.csv(file ="SoICatchmentAreasUpdatedDec2017.csv")

for(i in 1:nrow(wlr.coords)){
    outmap <- paste("catchment_", wlr.coords$wlr_id[i],"Dec17", sep="") 
    outmap.recl <- paste(outmap, ".recl", sep="")
    unit.id <- wlr.coords$wlr_id[i]
    rules <- paste("1 = 1 ", unit.id, sep="") ## add name of wlr to raster label
    write.table(file="rulefile.txt", rules, quote=FALSE, row.names=FALSE, col.names=FALSE)
    execGRASS("r.water.outlet",
          flags="overwrite",
          parameters=list(input='tmp200_draindir@elevation', output=outmap, 
                          coordinates=c(wlr.coords$x[i],wlr.coords$y[i]))
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
    vectmap <- outmap

    execGRASS("v.db.addcolumn",
               parameters=list(map=vectmap, columns="area_ha real")
          )
execGRASS("v.to.db",
          parameters=list(map=vectmap, option='area', columns='area_ha', units='hectares')
          )
execGRASS("v.db.renamecolumn",
          parameters=list(map=vectmap, column="label,wlr_id")
          )
execGRASS("v.db.dropcolumn",
          parameters=list(map=vectmap, columns='id')
          )
execGRASS("v.out.ogr",
          flags=c("s", "e", "overwrite"),
          parameters=list(input=vectmap, output=dsn, format='ESRI_Shapefile')
          )
}
