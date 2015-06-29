##----- Script to import all raw files from wlr loggers, calibrate them using outputs of
## wlr_calib.R and gap fill to one minute interval.
## Prior reading is used to take succeeding values where they don't exist.
## Original written by Srinivas V, modified by RSB.
for(i in 1:length(num_wlr)){
    wlrtab<-paste("wlr_", num_wlr[i], sep="")
    wlrtab.cal<-paste("wlr_", num_wlr[i],"_new", sep="") ## changed on Sept '14
    wlr.fill.onemin<-paste("wlr_", num_wlr[i],"onemin", sep="")
    wlrdir<-paste(wlrdatadir, wlrtab, sep="")
    filelist <- list.files(wlrdir, full.names=TRUE, ignore.case=TRUE, pattern='CSV$')
    wlronemincsv <- paste(csvdir, num_wlr[i], "_onemin.csv", sep="")
    xyall <- as.data.frame(matrix(ncol = 6))
    names(xyall) <- c("scan",  "date", "time", "raw", "cal","date_time")
    for (j in 1:length(filelist)){
        xy <- read.csv(file=filelist[j], skip=8, header=FALSE, strip.white = TRUE, blank.lines.skip = TRUE)
        names(xy)<- c("scan", "date", "time", "raw", "cal")
        xy$date <- gsub(pattern="-", replacement="/", x=xy$date)
        xy$date <- as.Date(xy$date, format="%d/%m/%Y")
        xy<-transform(xy, date_time = paste(date, time, sep=' '))
        xy$date_time<-as.POSIXct(xy$date_time, tz="Asia/Kolkata")
        xyall <- rbind(xyall, xy)
    }
    
    xyall$date_time<-as.POSIXct(xyall$date_time, origin="1970-01-01", tz="Asia/Kolkata")
    xyall$date_time<-round(xyall$date_time, "mins") ## added sept '14
    xyall <- xyall[complete.cases(xyall$date_time),] # remove row where date_time is NA
    start.hr <- round(min(xyall$date_time), "mins")
    end.hr <- round(max(xyall$date_time), "mins")
    tint1min <- seq.POSIXt(start.hr, end.hr,by="1 min",na.rm=T) # 1 minute interval
    attributes(tint1min)$tzone <- "Asia/Kolkata"
    xx1<-as.data.frame(tint1min)
    colnames(xx1)<-c("date_time")
    xx2<-merge(xyall, xx1, by = "date_time", all = TRUE)
    xx2 <-  xx2[!duplicated(xx2$date_time), ] # remove duplicates
    xx3<-as.timeSeries(xx2)
    xx3<-interpNA(xx3, method="before")
    xx3$date_time<-row.names(xx3)
    mmx<-as.data.frame(xx3)
    row.names(mmx) <- NULL 
    mmx$date_time <- as.POSIXct(mmx$date_time, tz="Asia/Kolkata")
    write.csv(mmx, file=wlronemincsv, row.names=FALSE) 
    assign(wlr.fill.onemin, mmx) # assign the output to an R object named after each wlr
}
