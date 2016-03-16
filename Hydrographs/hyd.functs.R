## All functions relevant to processing discharge values to come here
## Created March 2016


## feed it x (name of station) and y (name of rain gaugge) to globally assign
## names to files etc.
stn.names <- function(x, y){
    tbrg.flnm <<- paste("/tbrg_", y, "_1 hour.csv", sep="")
    tbrg.full.flnm <<- paste(tbrg.dir,tbrg.flnm, sep="")
    wlr.nm <<- paste("WLR ",x, sep="")
    tbrg.nm <<- paste("TBRG ",y, sep="")
}

##-- Calculate dischcharge from a rating curve using a non linear least square fit

calc.disch.areastage <- function(fn, fn.full){
    ##-- calculate area-stage relationship
    sd.fl <- read.csv(paste(sd.dir, "WLR_", stn.pairs$wlr[i], "_SD.csv", sep=""))
    sd.fl <- subset(sd.fl, select=c("stage", "avg.disch"))
    names(sd.fl) <- c("Stage", "Discharge")
    nls.res <- nls(Discharge~p1*(Stage)^p3,data=sd.fl, start=list(p1=3,p3=5))
    coef.p1 <- as.numeric(coef(nls.res)[1])
    coef.p3 <- as.numeric(coef(nls.res)[2])
    ##-- calculate discharge
    for(i in 1:length(fn))(assign(fn[i], read.csv(fn.full[i], row.names=1))) 
    y <- get(fn[1])
    if(length(fn)>1)for(i in 2:length(fn))(y <- rbind(y, get(fn[i])))
    y <- y[,-4]
    names(y) <- c("Capacitance", "Stage", "Timestamp")
    y$Discharge <- coef.p1 * (y$Stage)^coef.p3
    return(y)
}

## calculate discharge of a two inch montana flume
calc.disch.flume <- function(fn, fn.full){
    for(i in 1:length(fn))(assign(fn[i], read.csv(fn.full[i], row.names=1))) 
    y <- get(fn[1])
    names(y)[[3]] <- "Stage"
    if(length(fn)>1)for(i in 2:length(fn))(y <- rbind(y, get(fn[i])))
    y <- y[,-4]
    names(y) <- c("Capacitance", "Stage", "Timestamp")
    y <- y[!is.na(y$Stage),]
    p1 <- .1771  ## 1.765 ## Badiger gave:  p1 <- 0.1771 ## site gives .1765
    p3 <- 1.55
    y$Discharge <- p1*(y$Stage)^p3
    return(y)
}
## calculate discharge of a v-noth weir
calc.disch.weir <- function(fn, fn.full){
    for(i in 1:length(fn))(assign(fn[i], read.csv(fn.full[i], row.names=1))) 
    y <- get(fn[1])
    names(y)[[3]] <- "Stage"
    if(length(fn)>1)for(i in 2:length(fn))(y <- rbind(y, get(fn[i])))
    y <- y[,-4]
    names(y) <- c("Capacitance", "Stage", "Timestamp")
    y <- y[!is.na(y$Stage),]
    y$Stage <- y$Stage - hgt.diff
    y$Discharge <- 1.380278 * y$Stage^2.5 ## in m3/s
    return(y)
}

##--- read tbrg data in

read.tbrg.csv <- function(x){
    tbrg <- read.csv(x) # x is tbrg csv file
    tbrg$dt.tm <- as.POSIXct(tbrg$dt.tm, tz="Asia/Kolkata")
    tbrg <- subset(tbrg, select=c("mm", "dt.tm"))
    names(tbrg) <- c("mm","Timestamp")
    return(tbrg)
}

 ##--- Run hydrograph calculations----##
        hydgrph.dat <- function(wlr.dat, tbrg.dat){
            wlr.dat$Timestamp <- round(wlr.dat$Timestamp, "hour")
            wlr.dat$numtime <- as.numeric(wlr.dat$Timestamp)
            tbrg.dat$Timestamp <- round(tbrg.dat$Timestamp, "hour")
            tbrg.dat$numtime <- as.numeric(tbrg.dat$Timestamp)
            wlr.tbrg <- merge(wlr.dat, tbrg.dat, by="numtime", all=TRUE)
            ## complete cases won't work with date, using na.omit instead
            wlr.tbrg <- na.omit(wlr.tbrg)
            ## will probably have to include a lag of a day, i.e. remove all data
            ## within 24 hours of a rain event. Could be refined to use the max lag period as well.
            ## norain.dat <- wlr.tbrg[wlr.tbrg$mm==0,]
            hyd.data <- subset(wlr.tbrg, select=c("Timestamp.x", "mm", discharge.type))
            names(hyd.data) <- c("date", "P_mm", discharge.type)
            return(hyd.data)
        }
            
hydgraph.plot <- function(x, y, prd){
    ## file names
    corr_plot.png <- paste(hydrograph.dir, "/fig/CorrelationPlot_stn", x, "_tbrg_",
                             y, "_", prd, ".png", sep="")
    hydrograph.png <- paste(hydrograph.dir, "/fig/Hydrograph_stn", x, "_tbrg_",
                             y,  "_", prd,".png", sep="")
    hydrograph.csv <- paste(hydrograph.dir, "/csv/Hydrograph_stn", x, "_tbrg_",
                             y,  "_", prd,".csv", sep="")
    summ.hyd.csv <- paste(hydrograph.dir, "/csv/Summary_Hydrograph_stn", x, "_tbrg_",
                             y,  "_", prd,".csv", sep="")

    ## Hydrograph
    hydrograph.title <- paste("Station", x, "_tbrg_", y, prd, sep=" ")
    png(filename=hydrograph.png, width=1200, height=600, pointsize=10)
    hydrograph(hyd.data, stream.label=paste("Mean Hourly ", discharge.type,"\n in ",dis.units, sep=""),
               P.units="mm", S1.col="blue")
    title(main=hydrograph.title)
    dev.off()
    write.csv(file=hydrograph.csv, hyd.data)
    
    ## Correlation plot
    main.title <- paste("Cross Correlation", wlr.nm, tbrg.nm, sep=" ")
    obj <- ccf(hyd.data[,3], hyd.data[,2],type="correlation",plot=T, lag.max=240)## mod from 3 to 4
    tmp.max <- max(obj$acf)
    obj$lag[obj$acf==tmp.max]
    png(filename=corr_plot.png, width=1200, height=600, pointsize=10)
    plot(obj[0:400],type="l",xlim=c(0,100),bty="l",ylab="Correlation Coefficient",
         main=main.title, xlab="Lag in hours")
    dev.off()
    summ.hyd <- as.data.frame(as.matrix(summary(hyd.data)))
    names(summ.hyd) <- c("Variable", "Statistic", "Value")
    write.csv(summ.hyd, file=summ.hyd.csv)
    return(summ.hyd)    
}

mk.nullfile <- function(dup){
x <- paste(length(dup), " timestamps for wlr ", wlr.no[i], " are duplicated. Consider adding the following null file to ", wlr.no[i], ": \n", format(head(dup, n=1), format="%d/%m/%Y"), ", ", format(head(dup, n=1), format="%H:%M:%S"), ", 0000, 0000 \n",  format(tail(dup, n=1), format="%d/%m/%Y"), ", ", format(tail(dup, n=1), format="%H:%M:%S"), ", 0000, 0000", sep = "")
return(x)
}

pair.units <- function(logger.type){
    x <- read.csv(file="../sitewise_unintsname.csv")
    x <- subset(x, subset = (log.type == logger.type), select = c("stn", "log.id"))
    names(x) <- c("wlr", logger.type)
    return(x)
}
