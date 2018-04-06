## ID ERE
## Import ALL data from a given site
## Define extreme range for events using the outlier package
## Identify extremes



id.ere <- function(x, site){
    dat.day <- do.call("rbind", lapply(x,function(y){
                                    tmp <- read.csv(y, row.names="X")
                                    tmp$flnm <- gsub(".*\\/(.*)\\_1 day *.*", "\\1", y)
                                    return(tmp)
                                }))
    dat.day$dt.tm <- as.POSIXct(dat.day$dt.tm, tz = "Asia/Kolkata")
    
    ere.cutoff <- as.numeric(quantile(dat.day$mm, prob = 0.99, na.rm  = T))
    daily.ere <- na.omit(dat.day[dat.day$mm>ere.cutoff,])
    ere <- as.data.frame(table(daily.ere$dt.tm))
    ere.fn <- as.data.frame(table(daily.ere$flnm))
    ggplot(ere, aes(reorder(Var1, -Freq), Freq)) +
        geom_bar(stat = "identity") +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
        ggtitle(paste0("Cutoff at 99 percentile is = ", ere.cutoff, "mm"))
    ggsave(filename = paste0(site,"_DatewiseERE.png"))
    
    ggplot(ere.fn, aes(reorder(Var1, -Freq), Freq)) +
        geom_bar(stat = "identity") +
        theme(axis.text.x = element_text(angle = 90,  vjust = 0.5)) +
        ggtitle(paste0("Cutoff at 99 percentile is = ", ere.cutoff, "mm"))
    ggsave(filename = paste0("./fig", site,"_SitewiseERE.png"))
    write.csv(file = paste0("./csv",site, "_ERE.csv"), daily.ere)
    return(daily.ere)
}



## FROM HERE
# log.nm <- "tbrg_101"

## ere.minute <- function(x, y){
    ## x <- ele.nlg
    ## y <- "tbrg_101"
    ## y <- unique(x$flnm)
## lapply(unique(x$flnm),

## plot one minute wise ERE graphs using ggplot2
## specify names of loggers as y and dataset (ere.nlg/ele.agn) as x
## and site as z
## output includes ggplot2 graph as plot, csv file and
## return data a day and after the ERE for hydrographs
    ere.minute <- function(x, y, z){
        dates <-subset(y, subset=flnm==x, select=c(dt.tm, flnm))
        ## tot.mm <- subset(y, subset=flnm==x, select=c(mm))
        ## dates <-subset(ele.nlg, select=c(dt.tm, flnm))
        dates <- as.POSIXct(dates$dt.tm, tz = "Asia/Kolkata") - (24*3600) # subtract a day
        ## dates.prev <- dates-(24*3600)
        dates.hdgrph <- append(dates, dates+(24*3600))
        ## dates.hdgrph <- append(dates.prev,dates.hdgrph)
        ## dates.hdgrph <- dates.hdgrph[order(dates.hdgrph)]
        dat <- read.csv(file = fl.nm, row.names="X")
        dat$dt.tm <- as.POSIXct(dat$dt.tm, tz = "Asia/Kolkata")
        dat$yr <- as.POSIXct(format(dat$dt.tm, "%Y-%m-%d"), tz = "Asia/Kolkata")
        dat.plot <- dat[dat$yr %in% dates,]
        dat.hdgrph <- dat[dat$yr %in% dates.hdgrph,]
## HERE
        fl.nm <- paste0("~/OngoingProjects/CWC/Data/",z,"/tbrg/csv/",x, "_1 min.csv")
        dat.plot$yr.lgr <- paste0(dat.plot$yr, dat.plot$flnm)
        ## by <- list(unique.values = dat$yr)
        ## sum.rain <- aggregate(dat$mm, by=by, FUN="sum")
        ## new <- ddply(dat, "mm", transform, numcolwise(sum))
        dat.dt <- data.table(dat.plot)
        dat.dt[, sum.rain := sum(mm), by = yr]
        ## smalldat[, sum.rain := sum(mm), by = yr.lgr]
        dat <- as.data.frame(dat.dt)
        ## yr.sum.rain <- paste(dat$yr, sum.rain)
        dat$dt.tm <- as.POSIXct(dat$dt.tm, tz = "Asia/Kolkata") + (24*3600) # add back the day

        dat.print <- dat[,c(-1, -4, -5, -6, -7)]
        flnm.png <- paste0(x, "ERE.png")
        flnm.csv <- paste0(x, "ERE.csv")
        dat$ggtit <- paste("Rain in mm on",dat$yr, "was", dat$sum.rain, "mm")
        ## dat$ggtit <- paste("Rain in mm on",dat$yr, "was", tot.mm, "mm")
        ## add total mm of rain for each ERE
        
        ggplot( data = dat, aes(dt.tm, mm )) + geom_line()  +
            ##scale_x_datetime(format = "%b-%Y") + xlab("") +
            scale_x_datetime(labels = date_format("%R")) +
            facet_wrap(~ ggtit, scales = "free_x") + ggtitle(y) +
            labs(x="Time in H:M", y="Rainfall in mm") +
            theme(axis.title=element_text(size=10,face="bold"),
                  axis.text=element_text(size=8),
                  axis.text.x = element_text(angle = 90, hjust = 1))
        
        ggsave(filename = flnm.png)
        write.csv(file = flnm.csv, dat.print)
        return(dat.hdgrph)
}

## x is nlg.hyd.list or agn.hyd.list
## y is hydrograph dataset location
## get.hyd.data <- function(x, y){}
x$start <- as.POSIXct(paste(x$dt.tm, "00:00:00"), tz = "Asia/Kolkata")
x$end <-  as.POSIXct(paste(x$dt.tm,"24:00:00"), tz = "Asia/Kolkata") + (4 * 3600)
x$filename <- ~/OngoingProjects/CWC/Data/Nilgiris/hydrograph/csv/Hydrograph_stn114_tbrg_111_01-Dec-2015_to_31-Dec-2015.csv 
