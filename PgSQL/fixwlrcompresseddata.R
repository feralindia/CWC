xy<-read.csv("/home/srini/Desktop/wlr_003.csv")
xy$date_time<-as.POSIXct(xy$date_time)
min(xy$date_time)
max(xy$date_time)
start.hr <- as.POSIXct(min(xy$date_time))
end.hr <- as.POSIXct(max(xy$date_time))
tintervalWLR_003 <- seq.POSIXt(start.hr, end.hr,by="1 min",na.rm=T)#I have kept it to one minute as the time has not been rounded to the nearest 5 minunte interval.
attributes(tintervalWLR_003)$tzone <- "Asia/Kolkata"
xx1<-as.data.frame(tintervalWLR_003)
colnames(xx1)<-c("date_time")
xx2<-merge(xx1, xy, by = "date_time", all = TRUE)
xx2$date_time<-as.POSIXct(xx2$date_time)
#adds duplicates, so remove it in the next line
xx2 <-  xx2[!duplicated(xx2$date_time), ]
library(timeSeries)
xx3<-as.timeSeries(xx2)
xx3<-interpNA(xx3, method="before")
xx3$date_time<-row.names(xx3)
mmx<-as.data.frame(xx3, row.names=NULL)
names(mmx)
write.csv(mmx,"/home/srini/Desktop/wlr_003_fixed.csv")