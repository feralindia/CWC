## This script needs to be worked on AFTER wlr data has been converted into discharge values
## Plot the (as of now) raw data using daily minimum, mean, median and maximum values.
## This has to be changed to cumulative flows when we get round to calibration and volume calculations
## Need to work on two loops, one for the wlr the other for the stats, else do the stats at one go
## Note that the median command needs to be loaded as a function into postgresql for this to work
## It is available here <http://wiki.postgresql.org/wiki/Aggregate_Median>
stats<-c("min", "mean", "median", "max")
wlr_list<-c(paste("wlr_",101:109, sep="")) 
csvdir<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/csv"
for (i in 1:length(wlr_list)) {
  for (j in 1:length(stats)){
    stm<-paste("SELECT to_timestamp(((extract (epoch from date_time)::int / 86400) * 86400)) AS dt,", 
               stats[j],"(a.wl_raw) AS raw_level
        FROM nilgiris.", wlr_list[i], " a 
        GROUP BY dt
        ORDER BY dt;", sep="")
    rs <- dbSendQuery(con, stm)
    data <- fetch(rs, n = -1)
    csvout<-paste(csvdir, wlr_list[i] ,"_Daily.csv", sep="")
    write.csv(data, file=csvout)
    rm(stm)
    plot(data$dt, data$mm_rain, type="l", main="Daily", xlab="Day/date", ylab="Rainfall in mm") 
    title(tbrg_list[i], outer=TRUE)
    dev.off()
    j<-j+1;
  }
  i<-i+1;
}
