library(timeSeries)
## Import null file
tbrg.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/raw"
tbrg.raw.dirs<-list.dirs(tbrg.dir, full.names=TRUE, recursive=FALSE)
## null.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/null"
## tbrg.null.dirs<-list.dirs(null.dir, full.names=TRUE, recursive=FALSE)
## for (i in 1:length(tbrg.null.dirs)){
  tbrg.raw.files <- list.files(tbrg.raw.dirs[1], full.names=TRUE, include.dirs=FALSE, pattern=".csv$")
  
     ##for (j in 1:length(tbrg.null.files)){
   
    raw.file<- tbrg.raw.files[j]
    ## put for loop
    xy <- read.csv(file=raw.file, header=FALSE, blank.lines.skip = TRUE)
    names(xy)<- c("date", "time", "tips")
    xy$date <- as.Date(xy$date, format="%m/%d/%y")
    xy<-transform(xy, date_time = paste(date, time, sep=' '))
    xy$date_time<-as.POSIXct(xy$date_time)
    min(xy$date_time)
    max(xy$date_time)
    start.hr <- as.POSIXct(min(xy$date_time))
    end.hr <- as.POSIXct(max(xy$date_time))
    tint1min <- seq.POSIXt(start.hr, end.hr,by="1 min",na.rm=T)
attributes(tint1min)$tzone <- "Asia/Kolkata"
xx1<-as.data.frame(tint1min)
colnames(xx1)<-c("date_time")
xx2<-merge(xx1, xy, by = "date_time", all = TRUE)
xx2$date_time<-as.POSIXct(xx2$date_time)
## adds duplicates, so remove it in the next line
xx2 <-  xx2[!duplicated(xx2$date_time), ]
## FIX HERE  THE TIME SERIES COMMAND BELOW FLIPS THE DATE_TIME TO GMT
    ## see  <https://stat.ethz.ch/pipermail/r-devel/2010-August/058112.html>
xx3<-as.timeSeries(xx2)
        xx3<-substituteNA(xx3, type="zero")
xx3$date_time<-row.names(xx3) ## Probably not required. Check code here.
mmx<-as.data.frame(xx3, row.names=NULL)
names(mmx)
mmx$date_time <- as.POSIXct(mmx$date_time, tz="Asia/Kolkata")
mmx$date_time <- mmx$date_time + 19800
## THE ADDITION OF 5Hrs 30Mins DONE MANUALLY
  }
}
