## This script converts the x,y coordinates from a CSV file into area measured in cm2
## Note: the stage is taken from the timestamp on the WLR cx header.

## @knitr chunk1

## export to shapefiles to help with cross checking results
## Note: sections with multiple polygons get messed up
writeshape <- function(coords, cx.shapeout){
    ddTable <- data.frame(Id=ids,Name="poly")
    ddShapefile <- convert.to.shapefile(coords, ddTable, "Id", 5)
    write.shapefile(ddShapefile, cx.shapeout, arcgis=TRUE)
}

for (i in 1:length(pyg.dir)){
    res <- as.data.frame(matrix(ncol = 6)) # 5 col matrix to hold final results
    tmp.res <- as.data.frame(matrix(ncol = 9)) # 8 col matrix to hold temporary results
    prf.res <- as.data.frame(matrix(ncol = 9)) # 8 col matrix to hold profile results
    ## give names to cols
    names(res) <- c("Sl.No.", "site", "obs.file", "method", "stage", "avg.disch")
    names(tmp.res) <- c("Sl.No.", "site", "obs.file", "method", "stage", "cx.no", "cx.area", "avg.vel", "avg.disch")
    names(prf.res) <- c("Sl.No.", "site", "obs.file", "method", "stage", "cx.no", "cx.area", "avg.vel", "avg.disch")
    
    ## @knitr chunk2
    
    cx.flst <- list.files(path=cx.drlst[i], pattern=".csv$", ignore.case=TRUE)
cx.fldirlst  <- list.files(path=cx.drlst[i], full.names=TRUE, pattern=".csv$", ignore.case=TRUE)
    cx.fixflst <- list.files(path=cxfix.drlst[i], pattern=".csv$", ignore.case=TRUE)
cx.fixfldirlst  <- list.files(path=cxfix.drlst[i], full.names=TRUE, pattern=".csv$", ignore.case=TRUE)
pyg.flst <- list.files(path=pyg.dir[i], pattern=".csv$", full.names=TRUE, ignore.case=TRUE)
    ## loop for profiles and velocities
    for (j in 1: length(cx.flst)){ 
        tmp <- read.csv(file=cx.fldirlst[j], header = T, skip=5) # read in the csv, skip first 5 lines.
        crd <- subset(tmp, select=c(Length, Depth)) # extract coordinates
        rw.crd <- nrow(crd)
        crd[rw.crd+1, ] <- c(0, 0) # close the polygon
        crd[ , 2] <- crd[ , 2]*-1 # covert y values to negative (depth)
        gpc.crd <- as(crd, "gpc.poly") # convert to a gpc.poly object
        ##---get the timestamp
        cxt <- read.csv(cx.fldirlst[j], header=FALSE)
        tmp$dt  <- cxt[2,2, drop=TRUE]
        tmp$tm  <- cxt[3,2, drop=TRUE]
        tmp$dt <- as.Date(tmp$dt, format="%d/%m/%y")
        tmp <- transform(tmp, dt.tm = paste(dt, tm, sep=' '))
        tmp$dt.tm <- as.POSIXct(tmp$dt.tm, format="%Y-%m-%d %I:%M:%S %p") ## format converts from pm 
        stn.obj <- paste(stn.id[i], ".stage", sep="") 
        stg <- get(stn.obj)
        ## stg$dt.tm <- as.POSIXct(stg$dt.tm) ## not needed
        tmp.mrg <- merge(tmp, stg, by="dt.tm", all=FALSE)
        tmp.mrg <- tmp.mrg[1,] ## uncomment if you want only one row
        if (nrow(tmp.mrg) > 0){
            stage <- tmp.mrg$cal ##[[1]]
        }  else {stage <- NA}
        ## @knitr chunk3
        ## initialise png dump for cx
        
        mn <- paste("Site: ", pyg.loc[i], "|| File: ",cx.flst[j], sep=" ") # create title
        figout <- paste(str_sub(cx.fldirlst[j], end = -5L), ".png", sep="") # specify output destination
        cx.fig <- paste(str_sub(cx.flst[j], end =-5L), ".png", sep="") # names for cross section output
        ### cx.csv <- paste(str_sub(cx.flst[j], end =-5L), ".csv", sep="") # modified 24 nov 2014
        cx.figout <- paste(cx.pyg.res[i], cx.fig, sep="/")
        cx.csvout <- paste(cx.pyg.res[i], "/cx_results.csv", sep="")
        cx.shapeout <- paste(cx.shape[i], substrLeft(cx.flst[j],4), sep="/")
        ## postscript(figout, horizontal=TRUE, onefile=TRUE) # eps output parameters
        CairoPNG(filename=cx.figout, width=640, height=480, units="px", pointsize=12, onefile = TRUE) # png output parameters
        
        plot(gpc.crd, xlab="Stream Width (cm)", ylab="Stream Depth (cm)", main=mn, add = FALSE) # plot the cx
        
        ## @knitr chunk4: break the cross section into three portions and calculate their areas
        tmp.pyg <- read.csv(file=pyg.flst[j], header = T, skip=5) # read in the csv, skip first 5 lines.
        names(tmp.pyg) <- c("Sl.No.", "Length", "Depth", "Measure.Depth", "vel.rd1", "vel.rd2", "vel.rd3")

        ## @knitr chunk5
        ## calculate the average velocities of the cross sectional profiles
        ## It is assumed that the number of stream profiles and velocity measures are the same
        ## Note: naming is alpha numerical such as a6, b6, a2, a8, b2, b8 where 6 is 60% height, 2 is 20% and 8, 80%
        
        vel6 <- subset(tmp.pyg, subset=(substr(Sl.No.,2,2)==6 | (substr(Sl.No.,2,2)=="")), select=c(vel.rd1, vel.rd2, vel.rd3)) ## changed 26Nov14
        vel2 <- subset(tmp.pyg, subset=(substr(Sl.No.,2,2)==2), select=c(vel.rd1, vel.rd2, vel.rd3))##### ## changed 26Nov14
        vel8 <- subset(tmp.pyg, subset=(substr(Sl.No.,2,2)==8), select=c(vel.rd1, vel.rd2, vel.rd3)) ## changed 26Nov14
        
        ## 1) averages are produced for three readings
        ## 2) we have variable number of reaches per stream each has specific cx and cx.area
        ## 3) stage for survey will be the same
        
        if(nrow(vel6)>0){ ## changed 26Nov14
            avgvel6 <- apply(vel6, 1, mean) ## changed 26Nov14
        } else {vel6 <- NULL} ## changed 26Nov14
        if(nrow(vel2)>0){ ## changed 26Nov14
            vel28 <- (vel2 + vel8)/2 ## changed 26Nov14
            avgvel28 <- apply(vel28, 1, mean) ## changed 26Nov14
        } else {avgvel28 <- NULL} ## changed 26Nov14
        ## sort according to names so sequence is correct ## changed 26Nov14
        avgvel <- c(avgvel6,avgvel28) ## changed 26Nov14
        seq <- as.numeric(names(avgvel)) ## changed 26Nov14
        seq.avgvel <- as.data.frame(cbind(seq,avgvel)) ## changed 26Nov14
        sorted <- seq.avgvel[with(seq.avgvel, order(seq,avgvel)),] ## changed 26Nov14
        avgvel <- sorted$avgvel
        ## res[j, 8:10] <- avgvel
        ## @knitr chunk6
        ## Loop for cross sectional area for segments
        ## Loop to calculate area of each reach
        ## insert results into temporary results table

            ## for manual cross sections (cxfix)
      

        tmp.cxfix <- read.csv(file=cx.fixfldirlst[j], header = T)
        n.rect.cxfix <- nrow(tmp.cxfix)

        shp.coords <- as.data.frame(matrix(ncol = 3, nrow=0))
        names(shp.coords) <- c("Id", "X", "Y")
        for (k in 1 : n.rect.cxfix){ ## changed from n.rect
            rect <- as.data.frame(matrix(ncol = 2)) 
            names(rect) <- c("x", "y")
            ## shpout <- paste(cx.shapeout, k, sep="_")
            min.x.rect <- tmp.cxfix$start[k]
            max.x.rect <- tmp.cxfix$end[k]
            min.y.rect <- min(crd$Depth)
            max.y.rect <- max(crd$Depth)

            rect[1,] <- c(min.x.rect, min.y.rect)
            rect[2,] <- c(min.x.rect, max.y.rect)
            rect[3,] <- c(max.x.rect, max.y.rect)
            rect[4,] <- c(max.x.rect, min.y.rect)
            rect[5,] <- c(min.x.rect, min.y.rect)
                        
            gpc.rect <- as(rect, "gpc.poly") # convert to gpc polygon object
            plot(gpc.rect, poly.args = list(border = 1+k), add = TRUE) # uncomment to plot the segment
            ## text(c(2,2),c(37,35),labels=c("Non-case","Case"))
            ## area.poly(gpc.rect) + area.poly(gpc.crd) - area.poly(union(gpc.crd,gpc.rect)) # area calculation
            ar.rect <- area.poly(gpc.rect) # area of rectangle
            ar.crd <- area.poly(gpc.crd) # area of cx
## from here see if you can export the clipped polygon coordinates
            ## ar.rectUcrd <- area.poly(union(gpc.crd,gpc.rect)) # area of cx under rectangle
            # fixed dec 2014
            intr <- intersect(gpc.crd,gpc.rect)
            ar.int <- area.poly(intr) 
            ## Get the coordinates to export to a shape file
            ptlist <- get.pts(intr)
            coord.int <- ldply(ptlist, data.frame) ## as.data.frame(ptlist)
            ## coord.int <- unique(coord.int)
            
            ##coord.int <- rbind(coord.int, coord.int[duplicated(coord.int),])
            ## close.xy <- c(max(coord.int$x),0,k)
            ## coord.int <- rbind(coord.int, close.xy)
            ## coord.int <- rbind(coord.int, coord.int[coord.int$Y==0,])
            ## coord.int <- coord.int[with(coord.int, order(x,-y)), ]
            names(coord.int) <- c("X", "Y", "Id")
            coord.int <- coord.int[,c(3,1,2)]
            coord.int$Id <- k
            ## coords.int$X <- ptlist[[2]]$x
            ## coords.int$Y<- ptlist[[2]]$y
            ## coords.int$Id <- k
            ## shp.coords$X <- as.data.frame(ptlist[[1]]$x)
            ## shp.coords$Y<- ptlist[[1]]$y
            ## shp.coords$Id <- k
            shp.coords <- rbind(shp.coords,coord.int)
            ## Get results for output tables
            tmp.res[k, 1] <- j
            tmp.res[k, 2] <- pyg.loc[i]
            tmp.res[k, 3] <- cx.flst[j]
            tmp.res[k, 4] <- "pygmy"
            tmp.res[k, 5] <- stage
            tmp.res[k, 6] <- k
            tmp.res[k, 7] <- ar.int/10000 # fixed dec 2014
            ## tmp.res[k, 6] <- (ar.rect + ar.crd - ar.rectUcrd)/10000 #  Divide by 10000 to convert to metres from cm
            tmp.res[k, 8] <- sorted[k, 2]
            tmp.res[k, 9] <- tmp.res[k, 7] * tmp.res[k, 8] ## stage into area
            rm(ptlist)
        }
        ids <- unique(shp.coords$Id)
        writeshape(shp.coords, cx.shapeout)
        
        dev.off() # dump the data into the png driver
        ## from HERE, Oct '14
        ## rbind the tmp.res to profile results save to file for error checking
        prf.res <- rbind(prf.res, tmp.res)
        ## write.csv (file=cx.csvout, prf.res)
        ## dump to results
        res[j, 1] <- j
        res[j, 2] <- pyg.loc[i]
        res[j, 3] <- cx.flst[j]
        res[j, 4] <- "pygmy"
        res[j, 5] <- stage
        ## average out the reading for tmp.res to a single reading
        res[j, 6] <- sum(tmp.res$avg.disch) ## CHECK FROM HERE
       
### Need to change the recording of results here. HERE Oct, 2014
        
        ##---- chunk 8: Bung in initial results
        ##  res[j, 1] <- j
        ## res[j, 2] <- pyg.loc[i]
        ##  res[j, 3] <- cx.flst[j]
        ##  res[j, 4] <- stage
        
        
        ##---- chunk 9: Calculate flow rates for each reach
        ## It is assumed that the number of stream profiles and velocity measures are the same
        ## site.dr <- paste(pyg.dr,"/",  pyg.loc[i], sep="")
        ## pyg.flst <- list.files(path=site.dr, pattern=".csv$", full.names=TRUE, ignore.case=TRUE)
###  pyg.flst <- list.files(path=pyg.dir[i], pattern=".csv$", full.names=TRUE, ignore.case=TRUE)
###  tmp.pyg <- read.csv(file=pyg.flst[j], header = T, skip=5) # read in the csv, skip first 5 lines.
        ## vel <- subset(tmp.pyg, select=c(velR1, velR2, velR3)) # extract reach velocity readings FROM HERE
        ## Note: naming is alpha numerical such as a6, b6, a2, a8, b2, b8 where 6 is 60% height, 2 is 20% and 8, 80%
        ##  moved up so that it could be added to the tmp.res ## Oct, '14
        ## vel6 <- subset(tmp.pyg, subset=(substr(Sl.No.,2,2)==6 | (substr(Sl.No.,2,2)=="")), select=c(vel.rd1, vel.rd2, vel.rd3)) 
        ## vel2 <- subset(tmp.pyg, subset=(substr(Sl.No.,2,2)==2), select=c(vel.rd1, vel.rd2, vel.rd3))#####
        ## vel8 <- subset(tmp.pyg, subset=(substr(Sl.No.,2,2)==8), select=c(vel.rd1, vel.rd2, vel.rd3))
        ## need to add an if statement as such
        ## count Sl.No. with duplicate entries. These use the two point method.
        ## The subsequent code will need to be turned into a loop to handle raw data which
        ## covers more than three reaches and more than a single
        ## depth measure (.8 and .2 instead of .6 of stream depth).
        ## res[j, 8] <- mean(vel$velR1) # mean for reach 1
        ## MAJOR CORRECTION IN SCRIPT
        ## corrected this is reading 1, reading 2 and reading 3 not reach
        ## res[j, 9] <- mean(vel$velR2) # mean for reach 2
        ## res[j, 10] <- mean(vel$velR3) # mean for reach 3
        ## Above three lines can be changed as below
        ##  if(nrow(vel6)>0){
        ##     avgvel6 <- apply(vel6, 1, mean)
        ## } else {vel6 <- NULL}
        ##     if(nrow(vel2)>0){
        ##         vel28 <- (vel2 + vel8)/2
        ##         avgvel28 <- apply(vel28, 1, mean)
        ##     } else {vel28 <- NULL}
        ##     ## sort according to names so sequence is correct
        ##     avgvel <- c(avgvel6,avgvel28)
        ##     seq <- as.numeric(names(avgvel))
        ##     seq.avgvel <- as.data.frame(cbind(seq,avgvel))
        ##     sorted <- seq.avgvel[with(seq.avgvel, order(seq,avgvel)),]
        ##     avgvel <- sorted$avgvel
        
        ## res[j, 8:10] <- avgvel
        ## bung in the discharge values NEED TO FIX FROM HERE



        ## discharge <- (res[j, 5]*res[j, 8])+(res[j, 6]*res[j, 9])+(res[j, 7]*res[j, 10])
        
        ## res[j, 11] <- discharge
        
        ## resSD[j, 1] <- j
        ## resSD[j, 2] <- stage
        
        ## resSD[j, 3] <- discharge

        
        ##---- chunk 10: Clean up and repeat for every cx and velocity value
        ## rm(tmp, tmp.mrg, tmp.pyg, crd, rw.crd, gpc.crd, mn, figout, max.xy, min.xy, max.x, min.y, step.x, step.y) # clean up
    }


    ## @knitr chunk7
    ## Dump results to fig and csv directories


 ##    resfile <- paste(csv.dr,"/", pyg.locnum[i],".txt", sep="") # location of csv result
    resSDfile <- paste(csv.dr,"/", pyg.locnum[i],"_SD.csv", sep="") # location of csv result
##    ressummary <- paste(csv.dr,"/", pyg.locnum[i],"_summary.txt", sep="") # location of csv result
    
    write.table(prf.res, file=cx.csvout, quote=FALSE, sep = ", ", row.names=FALSE, append=TRUE) # write it
##     write.table(res, file=resfile, quote=FALSE, sep = "\t", row.names=FALSE, col.names=FALSE, append=TRUE) # write it
    
    write.table(res, file=resSDfile, quote=FALSE, sep = ",", row.names=FALSE, col.names=FALSE, append=TRUE) # write it    
##    write.table(summary(prf.res), file=ressummary, quote=FALSE, sep = "\t", append=TRUE) # write it    
    figfile <- paste(fig.dr,"/", pyg.locnum[i], ".png", sep="")
    ## rm(res, resSD)
}
 rm(tmp.res,tmp, tmp.mrg, tmp.pyg, crd, rw.crd, gpc.crd, mn, figout, max.xy, min.xy, max.x, min.y, step.x, step.y, cx.csv, cx.fig)
