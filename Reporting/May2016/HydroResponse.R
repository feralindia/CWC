## Get "n" highest discharge per selected station
## Merge across timestamps keeping raingauge IDs
## Merge with spatial attributes
## Merge with wind direction and speed data
## Merge with ground level and 0.6m gauge

##---- Pull out period of X highest rainfall events defined in function read.max.disch
## merge the topographic data with the file
    
hydro.files <- ls(pattern = "HydroGraph")
   ##  in.files <- in.files[grep(pattern=site, x=in.files)]  ## need to fix this for automatic changing of sites
    for(n in 1: length(hydro.files)){} ## to be done manually for now
n <- 1
        hydro.filename <- hydro.files[n]
        y.hyd <- get(hydro.files[n])
        ## loggers giving trouble can be removed here
        ## y <- remove.logger("tbrg_125a")
        ## prd <-  unlist(strsplit(in.filename, split="_"))[3] # not relevant
        ## outfldr <- paste("sel_", gsub(pattern = " ", replacement = "", prd), sep="")
        
        for(m in 1:nrow(y.hyd)){} ## to be done manually for now
m <- 1
            full.filename <- as.character(y.hyd$fn.full[m])
            short.filename <-as.character(y.hyd$fn.short[m])
            tmp <- read.max.hydgr(full.filename, short.filename)

in.files <- ls(pattern = "RainFiles")
in.files <- in.files[grep(pattern=site, x=in.files)]
in.files <- in.files[grep(pattern="_15 min", x=in.files)]


y.rain <- get(in.files)
    ## loggers giving trouble can be removed here
y.rain <- remove.logger("tbrg_125a", y.rain)

for(p in 1:nrow(y.rain)){
    #p <- 1
    full.filename <- as.character(y.rain$fn.full[p])
    short.filename <-as.character(y.rain$fn.short[p])
    if(p==1){
        tmp1 <- read.max.hydrain(full.filename, short.filename)
        tmp1 <- add.topoinfo(tmp1)
    }else{
        tmp2 <- read.max.hydrain(full.filename, short.filename)
        tmp2 <- add.topoinfo(tmp2)
        tmp1 <- rbind(tmp1, tmp2)
    }
}

### HERE
## need to check the graphs and ranking - seems to be mixing up labels and ranks.

tmp1 <- tmp1[complete.cases(tmp1$x),]

##--- name output files for each logger
## do one rank at a time for 

## outfile.csv <- paste(site, "/", datadir, "/", "TestAnim", ".csv", sep = "")
##outfile.png <- paste(site, "/", datadir, "/","TestAnim", ".png", sep = "")

##--- plot 
## png(filename = outfile.png, width = 1200, height = 800)
## OP <- par( mar=c(0,0,0,0), mfrow = c(2,round(max.event/1.9)))##
for(l in 1:max.event){} ## open this loop later now we work on rank 1 only
l <- 1
    dat <- subset(tmp1, subset=(tmp1$Rank==l))
    ## if(nrow(dat)>0){
        uni.date <- unique(dat$dt.tm)
        
        par(cex.main = 1, col.main = "red", mar=c(0,0,1.2,0))
        for(q in 1:length(uni.date)){
        #q <- 1
        outfile.png <- paste("00", q, ".png", sep="")  ##paste(site, "/", datadir, "/wlr_101_rain",uni.date[q], ".png", sep = "")
            ## outfile.png <- gsub(":", "_", outfile.png)
        dat.ani <- subset(dat, subset=dat$dt.tm==uni.date[q])
        png(filename = outfile.png, width = 1200, height = 800)
        ## modified from:
        ## <http://personal.colby.edu/personal/m/mgimond/Spatial/Interpolation.html>
        coordinates(dat.ani) <- c("x","y")
        ## plot(dat.ani, pch=16, , cex=( (dat.ani$mm/10)))
        ## text(dat.ani, as.character(dat.ani$mm), pos=3, col="grey", cex=0.8)
        dat.ani <- dat.ani[complete.cases(dat.ani$mm),]
        ## Create an empty grid where n is the total number of cells
        grd <- as.data.frame(spsample(dat.ani, "regular", n=10000))
        names(grd) <- c("x", "y")
        coordinates(grd) <- c("x", "y")
        gridded(grd) <- TRUE  # Create SpatialPixel object
        fullgrid(grd) <- TRUE  # Create SpatialGrid object
        ## Interpolate the surface using a power value of 2 (idp=2.0)
        dat.idw <- idw(mm~1,dat.ani,newdata=grd,idp=2.0)
        ## Plot the raster and the sampled points
        image(dat.idw,"var1.pred",col=terrain.colors(20))
        plot(dat.ani, add=TRUE, pch=16, cex=0.5, col="blue")
        contour(dat.idw,"var1.pred", add=TRUE, nlevels=10, col="#656565")
        points(hydgrph.x, hydgrph.y,
               cex=1.5, pch=16, col="red")  ## change this to wlr coordinates   dat.ani[dat.ani$Unit_ID==tmp$Unit_ID[1] , ],
        title(paste("Rank", 1, dat.ani$dt.tm[l]), line = 0.15)
        text(coordinates(dat.ani), as.character(round(dat.ani$mm,1)),
             pos=4, cex=0.8, col="blue")
        box(lty = 'solid',col="gray")
        dev.off()
    }
## }

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

}

