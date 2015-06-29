## Fill in missing values with previous values at a resolution of one minute
## aggregate the data and dump to csv and plots.
## the first section needs to be rewriteen to avoid postgres
for(i in 1:length(num_wlr)){si
    stm <- paste("UPDATE ", tabname,
                 " SET date_time =(SELECT date_trunc('minute', date_time + interval '30 second'));",
                 sep="") # rounds the logger to one minute
    rs <- dbSendQuery(con, stm)
    rm(stm)
    
    stm <- paste("SELECT * FROM ", tabname, sep="") # rounds the logger to one minute
    rs <- dbSendQuery(con, stm)
    xy <- fetch(rs, n = -1) # replaces xy<-read.csv("/home/srini/Desktop/wlr_003.csv")
    rm(stm)
    ## This section from Srini
    xy$date_time<-as.POSIXct(xy$date_time)
    min(xy$date_time)
    max(xy$date_time)
    start.hr <- as.POSIXct(min(xy$date_time))
    end.hr <- as.POSIXct(max(xy$date_time))
    tint1min <- seq.POSIXt(start.hr, end.hr,by="1 min",na.rm=T)#I have kept it to one minute
    attributes(tint1min)$tzone <- "Asia/Kolkata"
    xx1<-as.data.frame(tint1min)
    colnames(xx1)<-c("date_time")
    xx2<-merge(xx1, xy, by = "date_time", all = TRUE)
    xx2$date_time<-as.POSIXct(xx2$date_time)
    ## adds duplicates, so remove it in the next line
    xx2 <-  xx2[!duplicated(xx2$date_time), ]
    xx3<-as.timeSeries(xx2)
    xx3<-interpNA(xx3, method="before")
    xx3$date_time<-row.names(xx3)
    mmx<-as.data.frame(xx3, row.names=NULL)
    names(mmx)

    ### SRINI TO CHECK THIS
    ## Start the aggregation
    agg <- c("15 min", "30 min", "1 hour", "6 hour", "12 hour", "1 day")
    epsfile<-paste(figdir, loggers[i],".eps", sep="")
    pngfile<-paste(figdir, loggers[i],".png", sep="")
    ## postscript(epsfile, horizontal=TRUE, onefile=TRUE, pointsize=9) # uncomment for eps output
    png(file=pngfile, width = 1680, height = 780, units = "px", pointsize = 12, res=100,  bg = "white")
    par(mfrow=c(2,3), oma=c(0,0,2,0)) 
    for (j in 1: length(agg)){
        csvout <- paste(csvdir, loggers[i] ,"_", agg[j], ".csv", sep="")
        by <- timeSequence(from=start.hr, to=end.hr, by=agg[j])
        tmp <- aggregate(xx3, by, mean)
        tmp.df <- as.data.frame(tmp, row.names=NULL)
        write.csv(data, file=csvout)
        plot(data$dt, data$stage, type="l", main=c(agg[j]), xlab="Day/date", ylab="Stage in cm")
    }
    title(loggers[i], outer=TRUE)
    dev.off()
}
