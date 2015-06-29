## This scipt sends SQL statements to PostgreSQL to aggregate timestamp data into different intervals
## It is used by both the TBRG and the WLR routines and can't be run independently.
## For now set to work with WLR data only.
text_agg<-c("One minute", "Five minutes", "15 minutes", "Half hour", "One hour", "Six hours", "Twelve hours")
min_agg<-c("60", "300", "900", "1800", "3600", "21600", "43200")
for (i in 1: length(loggers){
    pngout<-paste(figdir, loggers[i],".eps", sep="")
    postscript(figfile, horizontal=TRUE, onefile=TRUE) # dump to eps
    ## png(file=pngout, width = 1680, height = 780, units = "px", pointsize = 12, res=100,  bg = "white")
    par(mfrow=c(2,4), oma=c(0,0,2,0))
    for (j in 1:length(min.agg)){
        ## use epoch to break timestamp into second intergers and then work back into time
        stm<-paste("SELECT to_timestamp(((extract (epoch from date_time)::int / ", min_agg[j],
                   ") * ", min_agg[j], ") + ", min_agg[j], ") AS dt,
        sum(round(a.tips * 100))::INTEGER AS tips,
        sum(round(a.tips * 100) * b.mm_pertip) AS mm_rain
        FROM  ", site, loggers[i], " a, ", site, "tbrg_calib b
        WHERE b.tbrg_id='", loggers[i], "'
        AND a.tips IS NOT NULL GROUP BY dt
        ORDER BY dt;", sep="") # the rounding is to ensure we don't get funny numbers
        rs <- dbSendQuery(con, stm)
        data <- fetch(rs, n = -1)
        csvout<-paste(csvdir, loggers[i] ,"_", text_agg[j], ".csv", sep="")
        write.csv(data, file=csvout)
        rm(stm)
        plot(data$dt, data$mm_rain, type="l", main=c(text_agg[j]), xlab="Day/date", ylab="Rainfall in mm") 
    }
    ## Do for the daily aggregation separately
    ## Added to fix error pointed out by Naresh and Susan
    stm<-paste("SELECT to_timestamp(((extract (epoch from date_time)::int / 86400) * 86400)) AS dt,
        sum(round(a.tips * 100))::INTEGER AS tips,
        sum(round(a.tips * 100) * b.mm_pertip) AS mm_rain
        FROM  ", site, loggers[i], " a, ", site, "tbrg_calib b
        WHERE b.tbrg_id='", loggers[i], "'
        GROUP BY dt
        ORDER BY dt;", sep="") # the rounding is to ensure we don't get funny numbers
    rs <- dbSendQuery(con, stm)
    data <- fetch(rs, n = -1)
    csvout<-paste(csvdir, loggers[i] ,"_Daily.csv", sep="")
    write.csv(data, file=csvout)
    rm(stm)
    plot(data$dt, data$mm_rain, type="l", main="Daily", xlab="Day/date", ylab="Rainfall in mm") 
    title(loggers[i], outer=TRUE)
    dev.off()
}
