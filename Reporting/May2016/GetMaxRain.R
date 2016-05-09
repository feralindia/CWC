## Get 20 highest periods of rainfall per raingauge
## Merge across timestamps keeping raingauge IDs
## Merge with spatial attributes
## Merge with wind direction and speed data
## Merge with ground level and 0.6m gauge

##---- libraries

library(rgdal) # manipulate raster images
library(maptools)
library(sp)
library(gstat)


##---- load functions
source("functions.R", echo=FALSE)

##---- Get file names into object by site and period
max.event <- 8 ## how many maximum rainfall events to be processed?
datadir <- paste(getwd(), "/", sep="")
samp.prd <- c("15 min", "1 hour", "1 day", "15 day") # sampling period
site <- c("Aghnashini", "Nilgiris") # select site

##--- read in spatial data
    
    spat.agn <- as.data.frame(readOGR(dsn = "./", paste("tbrg_", "Aghnashini", sep = ""))) # data is in UTM 43 North EPSG 32643
    spat.nlg <- as.data.frame(readOGR(dsn = "./", paste("tbrg_", "Nilgiris", sep = ""))) # data is in UTM 43 North EPSG 32643
    spat.nlg$Unit_ID <- paste("TBRG", spat.nlg$Unit_ID)  ## Need to fix this field in the shape file
    

##---- loop through sites 
for(i in 1:2){
    tbrg.csv.dir <- paste("~/OngoingProjects/CWC/Data/", site[i], "/tbrg/csv/", sep = "")

    ##---- loop through sampling periods
    for(j in 1:length(samp.prd)){
        fn.short <- gsub(pattern = ".csv", replacement = "",
                         x = list.files(tbrg.csv.dir, pattern = samp.prd[j]))
        ## fn.short <- gsub(pattern = " ", replacement = "_", x = fn.short) # remove space
        fn.full <- list.files(tbrg.csv.dir, pattern = samp.prd[j], full.names = TRUE)
        site.prd <- paste("MaxRain",site[i], samp.prd[j], sep = "_")
        assign(site.prd, data.frame(fn.full, fn.short))
    }

  
    
    ##---- Pull out period of X highest rainfall events defined in function read.max.rain
    ## merge the topographic data with the file
    
    in.files <- ls(pattern = "MaxRain")
    in.files <- in.files[grep(pattern=site[i], x=in.files)]
    for(n in 1: length(in.files)){
        in.filename <- in.files[n]
        y <- get(in.files[n])
        ## loggers giving trouble can be removed here
        y <- remove.logger("tbrg_125a")
        prd <-  unlist(strsplit(in.filename, split="_"))[3]
        outfldr <- paste("sel_", gsub(pattern = " ", replacement = "", prd), sep="")
        
        for(m in 1:nrow(y)){
            full.filename <- as.character(y$fn.full[m])
            short.filename <-as.character(y$fn.short[m])
            tmp <- read.max.rain(full.filename, short.filename)
            tmp <- add.topoinfo(tmp)
            tmp1 <- tmp ## need to create a version which gets rows slapped on
            z <- y[-m,]
            ## get data for all other stations for max rain timestamps of this logger
            for(o in 1:nrow(z)){
                full.flnm <- as.character(z$fn.full[o])
                short.flnm <-as.character(z$fn.short[o])
                tmp2 <- read.othermax.rain(full.flnm, short.flnm)
                tmp2 <- add.topoinfo(tmp2)
                tmp1 <- rbind(tmp1, tmp2)
            }

            tmp1 <- tmp1[complete.cases(tmp1$x),]

            ##--- name output files for each logger

            outfile.csv <- paste(site[i], "/", outfldr, "/", short.filename, ".csv", sep = "")
            outfile.png <- paste(site[i], "/", outfldr, "/",short.filename, ".png", sep = "")
            
            ##--- plot 
            png(filename = outfile.png, width = 1200, height = 800)
            OP <- par( mar=c(0,0,0,0), mfrow = c(2,round(max.event/1.9)))##
            for(l in 1:max.event){
                dat <- subset(tmp1, subset=(tmp1$Rank==l))
                if(nrow(dat)>0){
                    ## modified from:
                    ## <http://personal.colby.edu/personal/m/mgimond/Spatial/Interpolation.html>
                    coordinates(dat) <- c("x","y")
                    ## plot(dat, pch=16, , cex=( (dat$mm/10)))
                    ## text(dat, as.character(dat$mm), pos=3, col="grey", cex=0.8)
                    dat <- dat[complete.cases(dat$mm),]
                    ## Create an empty grid where n is the total number of cells
                    grd <- as.data.frame(spsample(dat, "regular", n=10000))
                    names(grd) <- c("x", "y")
                    coordinates(grd) <- c("x", "y")
                    gridded(grd) <- TRUE  # Create SpatialPixel object
                    fullgrid(grd) <- TRUE  # Create SpatialGrid object
                    ## Interpolate the surface using a power value of 2 (idp=2.0)
                    dat.idw <- idw(mm~1,dat,newdata=grd,idp=2.0)
                    ## Plot the raster and the sampled points
                    par(cex.main = 1, col.main = "red", mar=c(0,0,1.2,0))
                    image(dat.idw,"var1.pred",col=terrain.colors(20))
                    contour(dat.idw,"var1.pred", add=TRUE, nlevels=10, col="#656565")
                    plot(dat, add=TRUE, pch=16, cex=0.5, col="blue")
                    points(dat[dat$Unit_ID==tmp$Unit_ID[1] , ],
                           cex=1.5, pch=16, col="red")
                    title(paste("Rank", l, tmp$dt.tm[l]), line = 0.15)
                    text(coordinates(dat), as.character(round(dat$mm,1)),
                         pos=4, cex=0.8, col="blue")
                    box(lty = 'solid',col="gray")
                }
            }
            
            par(OP)
            martxt <- paste(tmp$Unit_ID[1], prd, sep="--")
            mtext(martxt, side = 3,  cex = 1, line=3.25)
            dev.off()
            
            assign(as.character(y$fn.short[m]), tmp1)
            write.csv(file=outfile.csv, tmp1)

                cat(paste("Top", max.event, "rainfall events for", as.character(y$fn.short[m]), "processed."),"\n")
                
            

            
        }
        cat(paste("Files for ", in.files[n], "processed."),"\n")

    }
    
    ##out.files <- ls(pattern = "tbrg_")
}

##---- Convert the data into a 
