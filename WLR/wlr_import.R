##----- Script to import all raw files from wlr loggers, calibrate them using outputs of
## wlr_calib.R and gap fill to one minute interval.
## Prior reading is used to take succeeding values where they don't exist.
## Original written by Srinivas V, modified by RSB.
## foreach(i=1:length(num_wlr)) %dopar% {
for(i in 1:length(num_wlr)){
    cat(paste("Importing WLR station", num_wlr[i], sep=" "), sep = "\n")
    wlrtab<-paste("wlr_", num_wlr[i], sep="")
    wlrtab.cal<-paste("wlr_", num_wlr[i],"_new", sep="") ## changed on Sept '14
    wlr.fill.onemin<-paste("wlr_", num_wlr[i],"onemin", sep="")
    wlrdir<-paste(wlrdatadir, wlrtab, sep="")
    filelist <- list.files(wlrdir, full.names=TRUE, ignore.case=TRUE, pattern='CSV$')
    filename <- list.files(wlrdir, full.names=FALSE, ignore.case=TRUE, pattern='CSV$')
    wlronemincsv <- paste(csvdir, num_wlr[i], "_onemin.csv", sep="")
    xyall <- as.data.frame(matrix(nrow=0,ncol = 6))
    names(xyall) <- c("scan",  "date", "time", "raw", "cal","date_time")
    for (j in 1:length(filelist)){
        cat(paste("Reading in data file", filename[j], sep=" "), sep = "\n")
        xy <- read.csv(file=filelist[j], skip=8, header=FALSE,
                       strip.white = TRUE, blank.lines.skip = TRUE)
        xy <- na.omit(xy)
        names(xy)<- c("scan", "date", "time", "raw", "cal")
        xy$date <- gsub(pattern="-", replacement="/", x=xy$date)
        ## If statement to check for date format
        ## convert date to a set of strings using "-" as a separator.
        brk.date <- strsplit(xy$date, split="/")[[1]]
        if(nchar(brk.date[1])==2) {
               dt.format <- "%d/%m/%Y"} else {
                   dt.format <- "%Y/%m/%d" }
        if(nchar(brk.date[1])==2 & nchar(brk.date[3])==2)
        {
            stop(paste("Dates for file ", filename[j], "need fixing.", sep=""))
        }
        
        xy$date <- as.Date(xy$date, format=dt.format)## "%d/%m/%Y")
           xy<-transform(xy, date_time = paste(date, time, sep=' '))
           xy <- xy[complete.cases(xy),]
        xy$date_time<-as.POSIXct(xy$date_time, tz="Asia/Kolkata")
        
        xyall <- rbind(xyall, xy)
    }
    
    ##---- Calibrate the readings ----##
    calint <- as.numeric(subset(all.wlr.calibres, wlr==wlrtab.cal, select=c(int, x)))
    if(is.na(calint)[1]==T) (stop(paste("Calibration file", wlrtab.cal, "is missing or has errors", sep=" ")))
    xyall$cal <- (xyall$raw*calint[2])+calint[1] ## unit is centimetres
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
    ## xx2$date_time<-as.POSIXct(xx2$date_time)
    xx2 <-  xx2[!duplicated(xx2$date_time), ] # remove duplicates
    ## IMPORTANT this will remove data from xyall unless the merge
    ## lists xyall first.
    ## see  <https://stat.ethz.ch/pipermail/r-devel/2010-August/058112.html>
    xx3<-as.timeSeries(xx2)
    ## financial centre to be set in wlr_nlg and wlr_agn    setFinCenter(xx3) <- "Asia/Calcutta"
    ## ensure that the calibrated values are not NA
    xx3<-interpNA(xx3, method="before")
    xx3$date_time<-row.names(xx3)
    mmx<-as.data.frame(xx3)
    row.names(mmx) <- NULL ## 'row.names=NULL' not working!
    ## mmx <- subset(mmx, select=c("scan", "raw", "cal", "date_time"))
    mmx$date_time <- as.POSIXct(mmx$date_time, tz="Asia/Kolkata")## usetz=TRUE)
    ## write.csv(mmx, file=wlronemincsv, row.names=FALSE) ## changed sept 14
    ## should not be written causes confusion as null hasn't been merged yet
    assign(wlr.fill.onemin, mmx) # assign the output to an R object named after each wlr
    cat(paste("Finished importing data for WLR station", num_wlr[i], sep=" "), sep = "\n")
}
