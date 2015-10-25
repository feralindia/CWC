# Process discharge data from float method into discharge-stage curves.
## based on disch_pyg.R
## ---- chunk 2: loop for sites
## stn.id <- c("wlr102",  "wlr103",  "wlr104",  "wlr105",  "wlr106")
stn.id <- gsub(pattern="_", replacement="", flt.loc)
for (i in 1:length(flt.drlst)){
## res <- as.data.frame(matrix(ncol = 11)) # create matrix of 10 cols to hold results
## names(res) <- c("S.No", "site", "obsfile", "stage", "areaR1", "areaR2", "areaR3", "velR1", "velR2", "velR3", "avg_disch") # give names to cols 
    res <- as.data.frame(matrix(ncol = 7)) # 5 col matrix to hold final results
    names(res) <- c("Sl.No.", "site", "obs.file", "method", "stage", "avg.disch", "timestamp")
## resSD <- as.data.frame(matrix(ncol = 3)) # create matrix of 3 cols to hold results
## names(resSD) <- c("S.No", "Stage", "Discharge")
    resSD <- as.data.frame(matrix(ncol = 7)) # 5 col matrix to hold final results
    names(resSD) <- c("Sl.No.", "site", "obs.file", "method", "stage", "avg.disch", "timestamp")
    
    cx_flt.flst <- list.files(path=cx_flt.drlst[i], pattern=".csv$", ignore.case=TRUE)
    cx_flt.fldirlst  <- list.files(path=cx_flt.drlst[i], full.names=TRUE, pattern=".csv$", ignore.case=TRUE)

    ## ---- chunk 3: Single profile measure
     for (j in 1: length(cx_flt.flst)){ 

    ## ---- chunk 4: pull in data from the cx files
        tmp <- read.csv(file=cx_flt.fldirlst[j], header = T, skip=5) # read in the csv, skip first 5 lines.
        crd <- subset(tmp, select=c(Length, Depth)) # extract coordinates
        rw.crd <- nrow(crd)
        crd[rw.crd+1, ] <- c(0, 0) # close the polygon
        crd[ , 2] <- crd[ , 2]*-1 # covert y values to negative (depth)
        gpc.crd <- as(crd, "gpc.poly") # convert to a gpc.poly object
        ##---get the timestamp
        cxt <- read.csv(cx_flt.fldirlst[j], header=FALSE)
        tmp$dt  <- cxt[2,2, drop=TRUE]
        tmp$tm  <- cxt[3,2, drop=TRUE]
        tmp$dt <- as.Date(tmp$dt, format="%d/%m/%y")
        tmp<-transform(tmp, dt.tm = paste(dt, tm, sep=' '))
        tmp$dt.tm<-as.POSIXct(tmp$dt.tm, format="%Y-%m-%d %I:%M:%S %p")
        stn.obj <- paste(stn.id[i], ".stage", sep="")## changed from stn.id
## NEEDS FIXING SHOULD DO A SEPARATE COUNT PER FLT DIRECTORY
        stg <- get(stn.obj)
        tmp.mrg <- merge(tmp, stg, by="dt.tm", all=FALSE)

## ---- chunk 5: initialise png dump for cx
        
        mn <- paste("Site: ", flt.loc[i], "|| File: ",cx_flt.flst[j], sep=" ") # create title
        figout <- paste(str_sub(cx_flt.fldirlst[j], end = -5L), ".png", sep="") # specify output destination
        
       ## postscript(figout, horizontal=TRUE, onefile=TRUE) # eps output parameters
        CairoPNG(filename=figout, width=640, height=480, units="px", pointsize=12, onefile = TRUE) # png output parameters
        plot(gpc.crd, xlab="Stream Width (cm)", ylab="Stream Depth (cm)", main=mn, add = FALSE) # plot the cx
        ar.crd <- area.poly(gpc.crd) # area of cx
        ## res[j, 5] <- ar.crd/10000 # dump to results table. Divide by 10000 to convert to metres from cm
        tmp.avgarea <- ar.crd/10000
    dev.off() # dump the data into the png driver
        
        ##---- chunk 8: Bung in initial results
        stage <- tmp.mrg$cal[[1]]
        timestamp <- tmp.mrg$dt.tm[[1]]
        res[j, 1] <- j
        res[j, 2] <- flt.loc[i]
        res[j, 3] <- cx_flt.flst[j]###
        res[j, 4] <- "float"
        res[j, 5] <- stage
        ## resSD[j, 1] <- j
        ## res[j, 3] <- cx_flt.flst[j]

        ##stage <- (min(crd$Depth)*-1)/100 # depth should become positive, divided by 100 to convert to metres
        
        ## resSD[j, 1] <- j ###
        ## resSD[j, 2] <- stage ### 
        
        ##---- chunk 9: Calculate flow rates for each reach
        ## It is assumed that the number of stream profiles and velocity measures are the same
        flt.flst <- list.files(path=flt.drlst[i], pattern=".csv$", full.names=TRUE, ignore.case=TRUE)
        tmp <- read.csv(file=flt.flst[j], header = T, skip=5) # read in the csv, skip first 5 lines.
        tmp$Time <- as.numeric(tmp$Time)
        vel <- mean(tmp$Distance/tmp$Time)*0.85 # do the mean and multiply with factor 0.85 as per USGS
        ## Need formal reference <http://www.state.nj.us/dep/wms/bwqsa/vm/docs/Stream%20Gaging%20Measuring%20flow%20and%20velocity.pdf>, <http://www.ecs.umass.edu/cee/reckhow/courses/370/Lab1/Stream%20flow%20lab.pdf>

    ## bung in the discharge values
        ##        discharge <- (res[j, 5]*vel)###
        discharge <- tmp.avgarea * vel
        
        ## res[j, 11] <- discharge###
        res[j, 6] <- discharge
        ## resSD[j, 3] <- discharge
        res[j, 7] <- timestamp
        
        ##---- chunk 10: Clean up and repeat for every cx and velocity value
        rm(tmp, crd, rw.crd, gpc.crd, mn, figout) # clean up
    }


    ## ---- chunk 11: Dump results to fig and csv directories
##    resfile <- paste(csv.dr,"/", flt.locnum[i],".txt", sep="") # location of csv result
    resSDfile <- paste(csv.dr,"/", flt.locnum[i],"_SD.csv", sep="") # location of csv result
##    ressummary <- paste(csv.dr,"/", flt.locnum[i],"_summary.txt", sep="") # location of csv result
    
##    write.table(res, file=resfile, quote=FALSE, sep = "\t", row.names=FALSE, col.names=FALSE, append=TRUE) # write it
    write.table(res, file=resSDfile, quote=FALSE, sep = ",", row.names=FALSE, col.names=FALSE, append=TRUE) # write it    
##     write.table(summary(res), file=ressummary, quote=FALSE, sep = "\t", append=TRUE, col.names=FALSE) # write it 
    rm(res, resSD) 
    ##---- chunk 12: Repeat loop for next site
    }  
