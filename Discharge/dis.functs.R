## All functions relevant to processing discharge values to come here
## Created March 2016

##-- Calculate dischcharge from a rating curve using a non linear least square fit

calc.disch.areastage <- function(fn, fn.full){
    ##-- calculate area-stage relationship
    sd.fl <- read.csv(paste(sd.dir, "WLR_", stn.no, "_SD.csv", sep=""))
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

## calculate discharge of a v-noth weir
## NOT SURE IF THIS IS REQUIRED GIVEN THAT THERE ARE DIFFERENT DESIGNS
## OF THESE WEIRS. MAY BE SIMPLER TO CODE IT INTO THE RESPECTIVE STATIONS
## calc.disch.compoundweir <- function(fn, fn.full){
##     for(i in 1:length(fn))(assign(fn[i], read.csv(fn.full[i], row.names=1))) 
##     y <- get(fn[1])
##     names(y)[[3]] <- "Stage"
##     if(length(fn)>1)for(i in 2:length(fn))(y <- rbind(y, get(fn[i])))
##     y <- y[,-4]
##     names(y) <- c("Capacitance", "Stage", "Timestamp")
##     y <- y[!is.na(y$Stage),]
    
##     wlr.lowstage <- wlr.dat[wlr.dat$Stage<=0.603, ]
##     wlr.highstage <-  wlr.dat[wlr.dat$Stage>0.603, ]
##     wlr.lowstage$discharge.m3sec <- 1.09*(1.393799*((wlr.lowstage$Stage-0.2065)^2.5))
##     ## wlr.lowstage$discharge.m3sec <- 1.09*(1.393799*((WLR Stage-0.2065)^2.5))
    
##     wlr.highstage$discharge.m3sec <- 1.09*((1.394*(((wlr.highstage$Stage-0.2065)^2.5) -
##                                                    ((wlr.highstage$Stage-0.603)^2.5))) +
##                                            (0.719*(wlr.highstage$Stage-0.603)^1.5))
##     ## High Discharge in m3/s = 1.09*{[1.394*(((WLRstage-0.2065)^2.5) - ((WLRstage-0.603)^2.5)))] + [0.719*(WLRstage-0.603)^1.5]}
##     wlr.discharge <- rbind(wlr.lowstage, wlr.highstage)
    
##     return(y)
## }



## feed it x (name of station) and y (name of rain gaugge) to globally assign
## names to files etc.
stn.names <- function(x){
    discharge.pdf <<- paste(discharge.dir, "/fig/Discharge_stn", x, "_", prd, ".pdf", sep="")
    discharge.png <<- paste(discharge.dir, "/fig/Discharge_stn", x,  "_", prd,".png", sep="")
    discharge.csv <<- paste(discharge.dir, "/csv/Discharge_stn", x,  "_", prd,".csv", sep="")
    discharge.title <<- paste("Station", x, prd, sep=" ")
    wlr.nm <<- paste("WLR ",x, sep="")
}

mk.nullfile <- function(dup){
x <- paste(length(dup), " timestamps for wlr ", wlr.no[i], " are duplicated. Consider adding the following null file to ", wlr.no[i], ": \n", format(head(dup, n=1), format="%d/%m/%Y"), ", ", format(head(dup, n=1), format="%H:%M:%S"), ", 0000, 0000 \n",  format(tail(dup, n=1), format="%d/%m/%Y"), ", ", format(tail(dup, n=1), format="%H:%M:%S"), ", 0000, 0000", sep = "")
return(x)
}

## Function to be called from within the j loop for reporting
## in discharge.R
dis.plot <- function(wlr.dat){
    gg.plt <- ggplot( data = wlr.dat, aes(x=Timestamp, y=Discharge)) +
        geom_line(size=1)+
        labs(x = "Date",  y = "Discharge in m^3/sec", title = discharge.title)
    ggsave(filename=discharge.png, plot=gg.plt, width=12, height=8, units="in")
    return(gg.plt)
}
