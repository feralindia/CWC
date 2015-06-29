##----- Script to overwrite erroneous data with NAs
## Original written by Srinivas V, modified by RSB.
for(i in 1:length(num_wlr)){
    wlrtab<-paste("wlr_", num_wlr[i], sep="")
    nulldir<-paste(wlr.nulldir, wlrtab, sep="")
    nullfile.list <- list.files(nulldir, full.names=TRUE, ignore.case=TRUE, pattern='CSV$')
    if(length(nullfile.list)>0){  # don't run if no null files
    wlr.null.onemin<-paste("wlr_", num_wlr[i],"null", sep="")
        wlr.null.csv <- paste(csvdir, num_wlr[i], "_null.csv", sep="")
        xyall <- as.data.frame(matrix(ncol = 5))
        names(xyall) <- c("date", "time", "raw", "cal","date_time")
        for (j in 1:length(nullfile.list)){
            xy <- read.csv(file=nullfile.list[j], header=FALSE, strip.white = TRUE, blank.lines.skip = TRUE)
            names(xy)<- c("date", "time", "raw", "cal")
            xy$date <- gsub(pattern="-", replacement="/", x=xy$date)
            xy$date <- as.Date(xy$date, format="%d/%m/%Y")
            xy<-transform(xy, date_time = paste(date, time, sep=' '))
            xy$date_time<-as.POSIXct(xy$date_time)
            xy$date_time <- round(xy$date_time, "min")
            start.hr <- min(xy$date_time)
            end.hr <- max(xy$date_time)
            tint1min <- seq.POSIXt(start.hr, end.hr,by="1 min",na.rm=T) # 1 minute interval
            attributes(tint1min)$tzone <- "Asia/Kolkata"
            xx1<-as.data.frame(tint1min)
            colnames(xx1)<-c("date_time")
            xx2<-merge(xy, xx1, by = "date_time", all = TRUE)
            xx2$date_time<-as.POSIXct(xx2$date_time)
            xx2 <-  xx2[!duplicated(xx2$date_time), ] # remove duplicates
            xx2 <- xx2[-1,] #remove first entry (the last correct entry before error)
            xx2 <- xx2[-nrow(xx2), ] # remove last entry (the first correct entry after error)
            xyall <- rbind(xyall, xx2)
        }
        xyall$date_time<-as.POSIXct(xyall$date_time, origin="1970-01-01", tz="Asia/Kolkata")
        xyall <- xyall[complete.cases(xyall$date_time),] # ensure there are no nulls in the timestamp
        write.csv(xyall, file=wlr.null.csv, row.names=FALSE)
        assign(wlr.null.onemin, xyall)
    }
}
