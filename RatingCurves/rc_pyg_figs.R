## This script converts the x,y coordinates from a CSV file into area measured in cm2
## Note: the stage is taken from the timestamp on the WLR cx header.

## @knitr chunk1

for (i in 1:length(pyg.dir)){
    res <- as.data.frame(matrix(ncol = 5)) # 5 col matrix to hold final results
    tmp.res <- as.data.frame(matrix(ncol = 8)) # 8 col matrix to hold temporary results
    prf.res <- as.data.frame(matrix(ncol = 8)) # 8 col matrix to hold profile results
    ## give names to cols
    names(res) <- c("Sl.No.", "site", "obs.file", "stage", "avg.disch")
    names(tmp.res) <- c("Sl.No.", "site", "obs.file", "stage", "cx.no", "cx.area", "avg.vel", "avg.disch")
    names(prf.res) <- c("Sl.No.", "site", "obs.file", "stage", "cx.no", "cx.area", "avg.vel", "avg.disch")
    ## list files with and without directory names    
    pyg.fldirlst <- list.files(path=pyg.dir[i], pattern=".csv$", full.names=TRUE, ignore.case=TRUE)
    cx.fldirlst <- gsub(pattern="/pyg/", replacement="/cx_pyg/", x=pyg.fldirlst)
    flst <- list.files(path=pyg.dir[i], pattern=".csv$", ignore.case=TRUE) # same for pyg, cx and cx_fix
    cat(paste("Processing files for pygmy velocity meter:", pyg.loc[i], sep=" "), sep="\n")
    
    ## @knitr chunk2    
    ## loop for profiles and velocities
    for (j in 1: length(flst)){  # changed from cx.flst Dec 14
        cat(paste("Processing:", flst[j], sep=" "), sep="\n")
        tmp <- read.csv(file=cx.fldirlst[j], header = T, skip=5) # read in the csv
        crd <- subset(tmp, select=c(Length, Depth)) # extract coordinates
        rw.crd <- nrow(crd)
        crd[rw.crd+1, ] <- c(0, 0) # close the polygon
        crd[ , 2] <- crd[ , 2]*-1 # covert y values to negative (depth)
        gpc.crd <- as(crd, "gpc.poly") # convert to a gpc.poly object
        mn <- paste("Site: ", pyg.loc[i], "|| File: ",flst[j], sep=" ") # create title
        cx.fig <- paste(str_sub(flst[j], end =-5L), ".png", sep="") # fig file name
        cx.figout <- paste(cx.pyg.man[i], cx.fig, sep="/") # fig file name and folder
        cx.csvout <- paste(cx.pyg.man[i], "/cx_results.csv", sep="")
        ## postscript(figout, horizontal=TRUE, onefile=TRUE) # eps output parameters
        CairoPNG(filename=cx.figout, width=1800, height=800, units="px", pointsize=12, onefile = TRUE) # png output parameters
        ab.x <- seq(from=0, to= max(crd$Length), by=max(crd$Length/100))
        ab.y <- seq(to=0, from=round(min(crd$Depth))-1, by=1)
        max.x <- max(crd$Length)
        par(mar=c(6,5,4,2)+0.1,mgp=c(5,1,0))
        plot(gpc.crd, xlab="Stream Width (cm)", ylab="Stream Depth (cm)", xaxp=c(0, max.x, 100), las=2, main=mn, add = FALSE) # plot the cx
        abline(v=ab.x, col="lightgray", lty="dashed")
        ## abline(h=ab.y, col="lightgray", lty="dotted")

        ## @knitr chunk3
        tmp.pyg <- read.csv(file=pyg.fldirlst[j], header = T, skip=5) # read in the csv, skip first 5 lines.
        names(tmp.pyg) <- c("Sl.No.", "Length", "Depth", "Measure.Depth", "vel.rd1", "vel.rd2", "vel.rd3")
        n.rect <- length(unique(substr(tmp.pyg$Sl.No., start=1, stop=1)))        
        max.xy <- c(max(crd$Length), min(crd$Depth))
        min.xy <- c(min(crd$Length), max(crd$Depth))
        max.x <- max(crd$Length)
        min.y <- min(crd$Depth)
        steps.x <- tmp.pyg$Length ## taking measurement lengths from pyg file
        steps.y <- tmp.pyg$Measure.Depth 
        for (k in 1 : nrow(tmp.pyg)){ ## changed from 1: n.rect
            rect <- as.data.frame(matrix(ncol = 2)) 
            names(rect) <- c("x", "y")
            if(k == 1){
                step.x <- steps.x[k] ## k is 1
                step.xprev <- 0
            } else {
                step.x <- steps.x[k]
                step.xprev <- step.x-steps.x[k-1]
            }
            step.y <- steps.y[k]*-1
            rect[1, ] <- c(step.x , 0.0) # min x, min y
            rect[2, ] <- c(step.x, 0.0) # max x, min y
            rect[3, ] <- c(step.x, step.y) # max x, max y
            rect[4, ] <- c(step.x, step.y) # min x, max y
            rect[5, ] <- c(step.x , 0.0) # min x, min y
            step.x <- steps.x[k]+step.xprev
            if(is.odd(k)){
                lnstl <- 1
            } else {
                lnstl <- 2
            }
            gpc.rect <- as(rect, "gpc.poly") # convert to gpc polygon object
            plot(gpc.rect, poly.args = list(border = k + 1, lty = lnstl), add = TRUE) # plot the segment      
        }
        dev.off() 
    }
    ## @knitr chunk4
    rm(tmp.res,tmp, tmp.mrg, tmp.pyg, crd, rw.crd, gpc.crd, mn, cx.figout, max.xy, min.xy, max.x, min.y, step.x, step.y, cx.csv, cx.fig)
}
cat("Finished processing figures for manual section selection", sep="\n")
