## Script to generate a data frame and a hydrograph for each WLR
## Discharge in depth units
## Rainfall as averaged for all rain gauges in catchment
## Unit is hourly

library("EcoHydRology")
library("timeSeries")
site.name <- "Nilgiris"
if(site.name == "Nilgiris"){
    stn <- c("102", "107", "108", "104")
}else {
    stn <- c("001","002")
}

##---Define file names---##
data.dir <- "~/CurrProj/CWC/Data"
site.data.dir <- paste(data.dir, site.name, sep = "/")
dis.dir <- paste(site.data.dir, "discharge/csv", sep = "/")
dis.flnm <- sapply(stn, FUN = function(x)list.files(dis.dir, full.names=FALSE, pattern = paste0("stn",x)))
dis.full.flnm <- sapply(stn, FUN = function(x)list.files(dis.dir, full.names=TRUE, pattern = paste0("stn",x)))


AvgRain <- function(x){
    stn.pairs <- read.csv(file = "~/CurrProj/CWC/Anl/sitewise_unintsname.csv",
                          colClasses = c(rep("character", 3)))
    stn.pairs <- stn.pairs[stn.pairs$stn==x,]
    stn.pairs <- stn.pairs[stn.pairs$log.type=="tbrg",]
    stn.tbrg <- as.list(stn.pairs$log.id)
    tbrg.fn <- lapply(stn.tbrg, function(x)(paste0("~/CurrProj/CWC/Data/", site.name,"/tbrg/csv/tbrg_", x, "_1 hour.csv")))
    tbrg.dat <- do.call(rbind, lapply(tbrg.fn, read.csv))
    dat <- stats::aggregate(mm ~ dt.tm, tbrg.dat,mean)
    names(dat) <- c("Timestamp", "Average Rain")
    dat$numtime <- as.numeric(as.POSIXct(dat$Timestamp,tz = "Asia/Kolkata"))
    return(dat)
}

tbrg.dat <- sapply(stn, AvgRain, simplify = FALSE, USE.NAMES = TRUE)

read.csv.files <- function(x){
  stn <- paste0("stn_",substr(as.character(gsub("[^[:digit:]]", "", x)), 0, 3))
  unq.stn <- unique(stn)
  if(sum(stn %in% unq.stn)>length(unq.stn)){
    dat <- lapply(unq.stn, function(i){
      j <- paste0("stn_", substr(as.character(gsub("[^[:digit:]]", "", x)), 0, 3))
      k <- do.call("rbind", lapply(x[j==i], read.csv, strip.white=TRUE))
      return(k)
    })
    names(dat) <- unq.stn
    return(dat)
  }else{
    dat <- lapply(x, read.csv, strip.white=TRUE)
    names(dat) <- unq.stn
    return(dat)
  }
}



AvgDis <- function(x){
    dis.files <- as.list(dis.full.flnm[grep(pattern = x, dis.full.flnm)])
    dis.dat <- read.csv.files(dis.files)
    dis.dat <- dis.dat[[1]]
    dis.dat$Timestamp <- as.POSIXct(x = dis.dat$Timestamp, tz = "Asia/Kolkata")
    ## aggregate to daily
    print(paste("Averaging hourly discharge for WLR No.", x))
    charvec <- dis.dat$Timestamp
    start.time <- min(dis.dat$Timestamp)
    end.time <- max(dis.dat$Timestamp)
    dis <- dis.dat$DepthDischarge
    ts.dis <- timeSeries(data=dis, charvec=charvec)
    by <- timeSequence(from=start.time, to=end.time,
                       by="1 hour", FinCenter = "Asia/Calcutta")
    dat <- aggregate(ts.dis, by, mean)
    dat$Date<-row.names(dat)
    dat <- as.data.frame(dat)
    row.names(dat) <- NULL
    dat$Date <- as.POSIXct(dat$Date, tz="Asia/Kolkata", origin="1970-01-01",usetz=TRUE) # add timestamp back to datframe
    names(dat) <- c("Depth Discharge", "Timestamp")
    dat$numtime <- as.numeric(as.POSIXct(dat$Timestamp,tz = "Asia/Kolkata"))
    return(dat)
}

discharge.dat <- sapply(stn, AvgDis, simplify = FALSE)
rain.dd.dat <- mapply(merge, x = tbrg.dat, y = discharge.dat, by = "numtime", SIMPLIFY = FALSE)
dat <- sapply(rain.dd.dat, function(x) x <- x[,c(2,3,4)], simplify = FALSE)
dat <- sapply(dat, function(x){
    x[,1] <- as.POSIXct(x[,1], tz = "Asia/Kolkata")
    return(x)
}, simplify = FALSE)

plot.hydrograph <- function(x, nm.x){
    png(filename = nm.x)
    hydrograph(x, stream.label="Depth of Discharge", P.units="mm", S1.col="blue")
    dev.off()
}

out.png <- as.list(paste0("Hydrograph_", stn, ".png"))
mapply(FUN = plot.hydrograph, dat, out.png)

write.list.to.csv <- function(x, nm.x){
    write.csv(x, file = nm.x)
    print(paste0(nm.x, " written. \n"))
}

nm.dat <- as.list(paste0("HydData", names(dat), ".csv"))
mapply(write.list.to.csv, dat, nm.dat)
