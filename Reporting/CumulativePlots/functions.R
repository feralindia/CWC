
##---Functions for script CumRainDepthDischarge.R---#

AvgRain <- function(x){
    stn.pairs <- read.csv(file = "~/Res/CWC/Anl/sitewise_unintsname.csv",
                          colClasses = c(rep("character", 3)))
    stn.pairs <- stn.pairs[stn.pairs$stn==x,]
    stn.pairs <- stn.pairs[stn.pairs$log.type=="tbrg",]
    stn.tbrg <- as.list(stn.pairs$log.id)
    tbrg.fn <- lapply(stn.tbrg, function(x)(paste0("~/Res/CWC/Data/", site.name,"/tbrg/csv/tbrg_", x, "_1 day.csv")))
    tbrg.dat <- do.call(rbind, lapply(tbrg.fn, read.csv))
    dat <- stats::aggregate(mm ~ dt.tm, tbrg.dat,mean, na.rm = T)
    names(dat) <- c("Timestamp", "Daily Rain")
    dat$Timestamp <- as.POSIXct(dat$Timestamp, tz = "Asia/Kolkata")
    dat$Date <- as.Date(dat$Timestamp)
    dat$datenum <- as.numeric(as.POSIXct(dat$Date,tz = "Asia/Kolkata"))
    return(dat)
}

sum.rain <- function(x,y){
    st.prd <<- y[[1]]
    end.prd <<- y[[2]]
    dat <<- as.data.frame(c(x[2],x[3]))
    summed <- mapply(st.prd, end.prd, SIMPLIFY = TRUE, FUN =  function(st, end){
        rain <- dat$Daily.Rain[dat$Date > st & dat$Date < end]
        sum.rain <- round(sum(rain, na.rm = TRUE),0)
        names(sum.rain) <- unique(format(as.Date(st, format="%Y-%m-%d"), "%Y"))
        return(sum.rain)
    })
    return(summed)
}

plot.hydrograph <- function(x, nm.x){
    ## png(filename = nm.x)
    hydrograph(x, stream.label="Depth of Discharge", P.units="mm", S1.col="blue")
    ## dev.off()
}

write.list.to.csv <- function(x, nm.x){
    write.csv(x, file = nm.x)
    print(paste0(nm.x, " written. \n"))
}
