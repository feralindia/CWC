## Import null file
tbrg.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/raw"
tbrg.raw.dirs<-list.dirs(tbrg.dir, full.names=TRUE, recursive=FALSE)
null.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/null"
tbrg.null.dirs<-list.dirs(null.dir, full.names=TRUE, recursive=FALSE)
## for (i in 1:length(tbrg.null.dirs)){
  tbrg.null.files <- list.files(tbrg.null.dirs[11], full.names=TRUE, include.dirs=FALSE, pattern=".csv$")
  
  if(length(tbrg.null.files>0)){
    
    ##for (j in 1:length(tbrg.null.files)){
   
      null.file<- tbrg.null.files[j]
    ## put for loop
    xy <- read.csv(file=null.file, header=FALSE, blank.lines.skip = TRUE)
    names(xy)<- c("date", "time", "tips")
    xy$date <- as.Date(xy$date, format="%m/%d/%y")
    xy<-transform(xy, date_time = paste(date, time, sep=' '))
    xy$date_time<-as.POSIXct(xy$date_time)
    min(xy$date_time)
    max(xy$date_time)
    start.hr <- as.POSIXct(min(xy$date_time))
    end.hr <- as.POSIXct(max(xy$date_time))
    tint1min <- seq.POSIXt(start.hr, end.hr,by="1 sec",na.rm=T)#I have kept it 
    
    
    xx2<-merge(xx1, xy, by = "date_time", all = TRUE)
  }
}
