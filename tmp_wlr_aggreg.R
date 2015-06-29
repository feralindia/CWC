## This scipt sends SQL statements to PostgreSQL to aggregate timestamp data into different intervals
### TODO
## It is used by both the TBRG and the WLR routines and can't be run independently.
## For now set to work with WLR data only.
text_agg<-c("15 minutes", "Half hour", "One hour", "Six hours", "Twelve hours")
min_agg<-c("900", "1800", "3600", "21600", "43200")
for (i in 1: length(loggers)){
    ## generate plots
    epsfile<-paste(figdir, loggers[i],".eps", sep="")
    pngfile<-paste(figdir, loggers[i],".png", sep="")
    ## postscript(epsfile, horizontal=TRUE, onefile=TRUE, pointsize=9) # dump to eps
    png(file=pngfile, width = 1680, height = 780, units = "px", pointsize = 12, res=100,  bg = "white") # dump to png
    par(mfrow=c(2,3), oma=c(0,0,2,0)) #, oma=c(0,0,2,0)
    for (j in 1:length(min_agg)){
        ## use epoch to break timestamp into second intergers and then work back into time
        stm<-paste("SELECT to_timestamp(((extract (epoch from date_time)::int / ", min_agg[j],
                   ") * ", min_agg[j], ") + ", min_agg[j], ") AS dt,
        avg((wl_cal / 100)) AS stage_m
        FROM  ", site, loggers[i], " GROUP BY dt ORDER BY dt;", sep="") ## WHERE wl_cal IS NOT NULL  this statement is changed [avg(round(wl_cal / 10)) AS stage]
        rs <- dbSendQuery(con, stm)
        data <- fetch(rs, n = -1)
        csvout<-paste(csvdir, loggers[i] ,"_", text_agg[j], ".csv", sep="")
        write.csv(data, file=csvout)
        rm(stm)
        plot(data$dt, data$stage, type="l", main=c(text_agg[j]), xlab="Day/date", ylab="Stage in cm") 
    }
    ## Do for the daily aggregation separately
    stm<-paste("SELECT to_timestamp(((extract (epoch from date_time)::int / 86400) * 86400)) AS dt,
        avg((wl_cal/100)) AS stage_m
                FROM  ", site, loggers[i], " GROUP BY dt ORDER BY dt;", sep="") #  WHERE wl_cal IS NOT NULL
    ##the rounding has been removed is to ensure we don't get funny numbers
    rs <- dbSendQuery(con, stm)
    data <- fetch(rs, n = -1)
    csvout<-paste(csvdir, loggers[i] ,"_Daily.csv", sep="")
    write.csv(data, file=csvout)
    rm(stm)
    plot(data$dt, data$stage, type="l", main="Daily", xlab="Day/date", ylab="Stage in cm")
    title(loggers[i], outer=TRUE)
    dev.off()
}

