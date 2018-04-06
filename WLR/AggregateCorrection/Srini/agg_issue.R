library(zoo)
library(timeSeries)
agh<-read.csv("/media/data/sriniworking/feral/proposals2016/MoES/santeguli.csv")
agh$date<-as.POSIXct(agh$date, tz="Asia/Kolkata")
flow.ts1<-zoo(agh$Streamflow_m3s, as.Date(agh$date,tz = "Asia/Kolkata"))
flow.ts<-timeSeries(agh$Streamflow_m3s, as.Date(agh$date),tz = "Asia/Kolkata")
st.flow<-as.Date("1998-05-01", tz = "Asia/Kolkata") # set start
head(index(flow.ts))
b <- (timeSequence(from=st.flow, to=end(flow.ts),
                   by="month", FinCenter = "Asia/Calcutta"))
head(b)
t1<-aggregate(flow.ts, by=b, sum)#using timeseries 
t2<-aggregate(flow.ts1,as.yearmon,sum)#using zoo
results<-cbind(t1,t2)
head(results)

#### The fix ####
tm <- seq(from=st.flow, to=as.Date(end(flow.ts1)), by = "1 day")### you can use min, hour, day, month, week etc
tmp<-zoo(tm,tm)
t4<-merge.zoo(tmp,flow.ts1)
t4<-t4$flow.ts1
test2<-aggregate(t4, list(day = cut(tm, "1 month")), sum) #Aggregation is changed here 1 month can become 3 or 3 or what ever