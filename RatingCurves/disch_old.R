## This script converts the x,y coordinates from a CSV file into area measured in cm2
## library(geosphere) # to convert from x,y to area

## ---- chunk 1: load libraries

library(sp) # to plot polygons
library(gpclib) # polygon clipping operations
# library(maptools) # spatial data conversion, may be needed later.
library(stringr) # to manipulate strings
library(Cairo)
## ---- chunk 2: loop for sites
for (i in 1:length(pyg.drlst)){
    cx.flst <- list.files(path=cx.drlst[i], pattern=".csv$", ignore.case=TRUE)
    cx.fldirlst  <- list.files(path=cx.drlst[i], full.names=TRUE, pattern=".csv$", ignore.case=TRUE)

    ## ---- chunk 3: loop for profiles and velocities
    for (j in 1: length(cx.flst)){ 

        ## ---- chunk 4: pull in data from the cx files
        tmp <- read.csv(file=cx.fldirlst[j], header = T, skip=5) # read in the csv, skip first 5 lines.
        crd <- subset(tmp, select=c(Length, Depth)) # extract coordinates
        rw.crd <- nrow(crd)
        crd[rw.crd+1, ] <- c(0, 0) # close the polygon
        crd[ , 2] <- crd[ , 2]*-1 # covert y values to negative (depth)
        gpc.crd <- as(crd, "gpc.poly") # convert to a gpc.poly object

## ---- chunk 5: initialise png dump for cx
        
        mn <- paste("Site: ", sites[i], "|| File: ",cx.flst[j], sep=" ") # create title
        figout <- paste(str_sub(cx.fldirlst[j], end = -5L), ".png", sep="") # specify output destination
        
       ## postscript(figout, horizontal=TRUE, onefile=TRUE) # eps output parameters
        CairoPNG(filename=figout, width=640, height=480, units="px", pointsize=12, onefile = TRUE) # png output parameters
        plot(gpc.crd, xlab="Length in cm", ylab="Depth in cm", main=mn, add = FALSE) # plot the cx
        
## ---- chunk 6: break the cross section into three portions and calculate their areas
        
        ## Need to split the polygon into three equally spaced chunks and calculate
        ## their areas separatey. This requires two steps
        ## 1) create three rectangular polygons each a third in size
        ## 2) intersect the cx with these three one by one
        ## 3) calculate the areas of each of these three.
        ## first create the three rectangles, remember y is in depth so min y is deepest
        max.xy <- c(max(crd$Length), min(crd$Depth))
        min.xy <- c(min(crd$Length), max(crd$Depth))
        max.x <- max(crd$Length)
        min.y <- min(crd$Depth)
        step.x <- max.x/3
        step.y <- min.y

        ##----- chunk 7: Loop for cross sectional area for segments
        ## Loop to calculate area of each reach
        for (k in 1 : 3){ # needs to be changed to automatically take segments
            rect <- as.data.frame(matrix(ncol = 2)) # create a dataframe to hold the three rectangles
            names(rect) <- c("x", "y")
            rect[1, ] <- c((step.x * k) - step.x, 0.0) # min x, min y
            rect[2, ] <- c(step.x * k, 0.0) # max x, min y
            rect[3, ] <- c(step.x * k, step.y) # max x, max y
            rect[4, ] <- c((step.x* k) - step.x, step.y) # min x, max y
            rect[5, ] <- c((step.x* k) - step.x, 0.0) # min x, min y
            gpc.rect <- as(rect, "gpc.poly") # convert to gpc polygon object
            plot(gpc.rect, poly.args = list(border = 1+k), add = TRUE) # plot the segment
            ar.rect <- area.poly(gpc.rect) # area of 1/3rd rectangle
            ar.crd <- area.poly(gpc.crd) # area of cx
            ar.rectUcrd <- area.poly(union(gpc.crd,gpc.rect)) # area of cx under rectangle
            res[j, k + 4] <- (ar.rect + ar.crd - ar.rectUcrd)/10000 # dump to results table. Divide by 10000 to convert to metres from cm
            ##area.poly(gpc.rect) + area.poly(gpc.crd) - area.poly(union(gpc.crd,gpc.rect)) # area calculation
        }
        dev.off() # dump the data into the png driver
        
        ##---- chunk 8: Bung in initial results
        res[j, 1] <- j
        res[j, 2] <- sites[i]
        resSD[j, 1] <- j
        res[j, 3] <- cx.flst[j]
        stage <- (min.y*-1)/100 # depth should become positive, divided by 100 to convert to metres
        
        res[j, 4] <- stage
        resSD[j, 2] <- stage
        
        ##---- chunk 9: Calculate flow rates for each reach
        ## It is assumed that the number of stream profiles and velocity measures are the same
        site.dr <- paste(pyg.dr,"/",  sites[i], sep="")
        pyg.flst <- list.files(path=site.dr, pattern=".csv$", full.names=TRUE, ignore.case=TRUE)
        tmp <- read.csv(file=pyg.flst[j], header = T, skip=5) # read in the csv, skip first 5 lines.
        vel <- subset(tmp, select=c(velR1, velR2, velR3)) # extract reach velocity readings
        ## The subsequent code will need to be turned into a loop to handle raw data which
        ## covers more than three reaches and more than a single
        ## depth measure (.8 and .2 instead of .6 of stream depth).
        res[j, 8] <- mean(vel$velR1) # mean for reach 1
        res[j, 9] <- mean(vel$velR2) # mean for reach 2
        res[j, 10] <- mean(vel$velR3) # mean for reach 3
        
        ## bung in the discharge values
        discharge <- (res[j, 5]*res[j, 8])+(res[j, 6]*res[j, 9])+(res[j, 7]*res[j, 10])
        
        res[j, 11] <- discharge
        resSD[j, 3] <- discharge

        
        ##---- chunk 10: Clean up and repeat for every cx and velocity value
        rm(tmp, crd, rw.crd, gpc.crd, mn, figout, max.xy, min.xy, max.x, min.y, step.x, step.y) # clean up
    }


    ## ---- chunk 11: Dump results to fig and csv directories
    resfile <- paste(csv.dr,"/", sites[i],".txt", sep="") # location of csv result
    resSDfile <- paste(csv.dr,"/", sites[i],"_SD.txt", sep="") # location of csv result
    ressummary <- paste(csv.dr,"/", sites[i],"_summary.txt", sep="") # location of csv result
    
    write.table(res, file=resfile, quote=FALSE, sep = "\t", row.names=FALSE) # write it
    write.table(resSD, file=resSDfile, quote=FALSE, sep = "\t", row.names=FALSE) # write it    
    write.table(summary(res), file=ressummary, quote=FALSE, sep = "\t") # write it    
    figfile <- paste(fig.dr,"/", sites[i], ".png", sep="") # location of png resultsCHECK FROM HERE
    mn <- paste("Stage Discharge Curve || Site: ", sites[i], sep=" ") # figure title
    ## postscript(figfile, horizontal=TRUE, onefile=TRUE) # dump to eps
    png(filename=figfile, width=640, height=480, units="px", pointsize=12, type="cairo") # dump to png
    plot(res$stage, res$avg_disch, xlab="Stage (m)", ylab="Discharge (m^3/s)", main=mn, type="p") # do the plot, note stage in m and discharge in m3/sec
    dev.off() # transfer data to file

    ##---- chunk 12: Repeat loop for next site
    }
