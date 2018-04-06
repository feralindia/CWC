## Get "n" highest periods of rainfall for all raingauges
## Merge across timestamps keeping raingauge IDs
## Merge with spatial attributes
## Merge with wind direction and speed data
## Merge with ground level and 0.6m gauge

##---- Pull out period of X highest rainfall events defined in function read.max.rain
## merge the topographic data with the file

in.files <- ls(pattern = "RainFiles")
in.files <- in.files[grep(pattern=site, x=in.files)]
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
        tmp1 <- tmp
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

        outfile.csv <- paste(site, "/", outfldr, "/", short.filename, ".csv", sep = "")
        outfile.png <- paste(site, "/", outfldr, "/",short.filename, ".png", sep = "")
        
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


