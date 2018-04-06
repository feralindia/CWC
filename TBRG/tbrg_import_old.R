##---- import raw and zero fill for each minute ----##
## read in calibration file
print(paste("Processing TBRG No.", num_tbrg[i], sep=" "))

cal.file <- read.csv(calibfile)
tbrg.raw <- data.frame(tips=numeric(0), mm=numeric(0), dt.tm=numeric(0))
for (j in 1:length(filelist)){
    print(paste("Importing raw data from", filelist[j], sep=" "))
    tmp.raw <- read.csv(filelist.full[j], header=FALSE, sep=",", quote="", blank.lines.skip = TRUE)
    names(tmp.raw) <- c("dt", "tm", "tips")
    tmp.raw$dt <- as.Date(tmp.raw$dt, format="%m/%d/%y")
    tmp.raw<-transform(tmp.raw, dt.tm = paste(dt, tm, sep=' '))
    tmp.raw$dt.tm<-as.POSIXct(tmp.raw$dt.tm, tz="Asia/Kolkata")
    tmp.year <- format(tmp.raw$dt.tm, "%Y")
    if(min(tmp.year) < 2012){
        stop(paste("File name", filelist[j], "starts before 2012.", sep=" "))
    } else if (max(tmp.year) > 2016) {
        stop(paste("File name", filelist[j], "ends after 2015.", sep=" "))
    }
    
    tmp.raw$dt.tm<-round(x=tmp.raw$dt.tm, units="mins")
   
    ## Calibrate the raw values
    cal.value <- as.numeric(subset(cal.file, subset=tbrg_id==tbrgtab,select="mm_pertip"))
    tmp.raw$mm <- tmp.raw$tips * cal.value * 100 # NOTE READING IN MM
    ## Start zero filling
    start.hr <- min(tmp.raw$dt.tm)
    end.hr <- max(tmp.raw$dt.tm)
    tint1min <- seq.POSIXt(start.hr, end.hr,by="1 min",na.rm=TRUE)
    ## attributes(tint1min)$tzone <- "Asia/Kolkata" ## not required, already defined
    tmp.raw.seq <-as.data.frame(tint1min)
    colnames(tmp.raw.seq)<-c("dt.tm")
    tmp.raw.1min <- merge(tmp.raw, tmp.raw.seq, by="dt.tm", all=TRUE)
    ##  tmp.raw.1min <- subset(tmp.raw.1min, select=c("tips","mm","dt.tm"))
    tmp.raw.1min <-  tmp.raw.1min[!duplicated(tmp.raw.1min$dt.tm), ]
    tmp.raw.1min <- tmp.raw.1min[!(is.na(tmp.raw.1min$dt.tm)),]
    ## remove NAs here

    tmp.raw.ts <- as.timeSeries(tmp.raw.1min)
    tmp.raw.ts<-substituteNA(tmp.raw.ts, type="zero")
    tmp.raw.ts$dt.tm<-row.names(tmp.raw.ts)
    tmp.raw<-as.data.frame(tmp.raw.ts)
    row.names(tmp.raw)<- NULL
    tmp.raw <- subset(tmp.raw, select=c("tips", "mm", "dt.tm"))
    tbrg.raw <- rbind(tbrg.raw, tmp.raw)
}
tbrg.raw$dt.tm <- as.POSIXct(tbrg.raw$dt.tm, tz="Asia/Kolkata")
tbrg.raw <-  tbrg.raw[!duplicated(tbrg.raw$dt.tm), ]# Added to remove duplicated values
## tbrg.raw$dt.tm <- tbrg.raw$dt.tm + 19800 ## add five and half hours
## The need to do this implies there is something wrong with the code. Fix it when you have time.
assign(tbrgtab_raw, tbrg.raw)
## rm(tmp.raw)

print(paste("Finished importing data for TBRG No.", num_tbrg[i], sep=" "))

## head(subset(tmp.raw.1min, subset=tips>0))
