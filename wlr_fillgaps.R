## Fill in missing values with previous values at a resolution of one minute
## aggregate the data and dump to csv and plots.
## the first section needs to be rewriteen to avoid postgres
for(i in 1:length(num_wlr)){
    stm <- paste("UPDATE ", tabname[i],
                 " SET date_time =(SELECT date_trunc('minute', date_time + interval '30 second'));",
                 sep="") # rounds the logger to one minute
    rs <- dbSendQuery(con, stm)
    rm(stm)
    stm <- paste("SELECT * FROM ", tabname[i], sep="") # rounds the logger to one minute
    rs <- dbSendQuery(con, stm)
    xy <- fetch(rs, n = -1)
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
    mmx$date_time <- as.POSIXct(mmx$date_time, tz="Asia/Kolkata")
    allwlrdat <- paste(csvdir, loggers[i] ,"_1 minute.csv", sep="")
    write.csv(mmx, file=allwlrdat)
}
