## Script by Srini 31-05-2017
library(zoo)
### I have mereged to two csv and subsetted the data in calc
### you might want to do this in R

wlr<-read.csv("HydData_cumsum.csv")
head(wlr)
summary(wlr)
wlr102.ts<-zoo(wlr$dis102, order.by=as.POSIXct(wlr$Timestamp, tz="Asia/Kolkata"))
wlr107.ts<-zoo(wlr$dis107, order.by=as.POSIXct(wlr$Timestamp, tz="Asia/Kolkata"))

wlr102.ts1d<-aggregate(wlr102.ts, time(wlr102.ts)-as.numeric(time(wlr102.ts)) %% 86400, sum,na.rm=TRUE)
wlr107.ts1d<-aggregate(wlr107.ts, time(wlr107.ts)-as.numeric(time(wlr107.ts)) %% 86400, sum,na.rm=TRUE)

rain.ts<-zoo(((wlr$rain102+wlr$rain107)/2), order.by=as.POSIXct(wlr$Timestamp, tz="Asia/Kolkata"))
rain.ts1d<-aggregate(rain.ts, time(rain.ts)-as.numeric(time(rain.ts)) %% 86400, sum,na.rm=TRUE)

nldata<-cbind(cbind(rain.ts1d,wlr102.ts1d),wlr107.ts1d)
str(nldata)
names(nldata)<-c("Rainfall","Wattle","Grassland")
summary(nldata)
plot.zoo(cumsum(nldata),plot.type="single",lty = c(1:3),xlab = "Date 01-June-2014 to 31-May-2015",
         ylab = "mm")
legend(x = "topleft", bty = "n", lty = c(1:3),
       legend = names(nldata))

