for(i in 1:length(num_wlr)){
    ## create a table for each wlr if one doesn't exist already
    stm<-paste("CREATE TABLE IF NOT EXISTS ", site, "wlr_", 
               num_wlr[i], "_raw(scan integer, date date, time time, wl_raw real, wl_cal real);", sep="")
    rs <-   dbSendQuery(con, stm)
    rm(stm)
    ## copy the data from the respective wlr folders into the tables.
    ## Note: only CSV files are supported - don't stick in xls sheets.
    wlrtab<-paste("wlr_", num_wlr[i], sep="") # Database table for storing wlr data.
    wlrtab_raw<-paste("wlr_", num_wlr[i], "_raw", sep="")
    wlrdir<-paste(wlrdatadir, wlrtab, sep="") # Directory holding all wlr sub folders
    ## filetype<-"/*.[Cc][Ss][Vv]" # Only list csv or CSV files
    ## dirliststm<-paste("ls ", wlrdir, filetype, sep="") # List contents of wlr## folder.
    ## filelist<-system(dirliststm, intern=TRUE) # Save the list of contents to an object
    tmpfile <- paste(wlrdir, "/tmp.csv", sep="")
    try(file.remove(tmpfile), silent=TRUE)
    filelist <- list.files(wlrdir, full.names=TRUE, ignore.case=TRUE, pattern='CSV$')
    ## copy all the csv/dat files onto a raw wlr table
    ## remove the first ten lines (header)
    ## setwd(wlrdir) # move to the relevant directory.
    stm<-paste("SET datestyle = 'ISO, DMY';") # change the datestyle to dmy
    rs<-dbSendQuery(con,stm)
    rm(stm)


    ## j=1
    ## while(j<=length(filelist)){
    ##     rmhead<-paste("tail -n +13", filelist[j], " > tmp.csv")
    ##     system(rmhead)
    ##     stm<-paste("COPY ", site, "wlr_", num_wlr[i], "_raw FROM '", 
    ##                wlrdir, "/tmp.csv' DELIMITER ',' CSV;", sep="")
    ##     rs<-dbSendQuery(con,stm)
    ##     rm(stm)
    ##     system("rm tmp.csv")
    ##     j=j+1;
    ## }

## Ensure you don't have a residual csv.tmp file in your filelist
    ## might want to use remove whitespace to import data
    for (j in 1:length(filelist)){
        tmp <- read.csv(file=filelist[j], skip=8, header=FALSE, strip.white = TRUE)
        write.csv(tmp, file=tmpfile, row.names=FALSE, col.names=FALSE, quote=FALSE)
        stm <- paste("COPY ", site, "wlr_", num_wlr[i], "_raw FROM '", 
                   wlrdir, "/tmp.csv' DELIMITER ',' CSV header NULL 'NA';", sep="")
        rs<-dbSendQuery(con,stm)
        rm(stm)
    }
  

    
    stm<-paste("SET datestyle = default;") # reset the datestyle to default
    rs<-dbSendQuery(con,stm)
    rm(stm)
    ## create the tables to hold wlr data - one per wlr ## changed 
    stm<-paste("CREATE TABLE IF NOT EXISTS ", site, "wlr_", 
               num_wlr[i], "(id SERIAL PRIMARY KEY, scan integer, date_time timestamp, 
             wl_raw real, wl_cal real);", sep="")
    rs <- dbSendQuery(con, stm)
    rm(stm)
    ## transfer the data from the raw table to the clean table
    stm<-paste("INSERT INTO ", site, wlrtab, "(scan, date_time, wl_raw) 
             SELECT DISTINCT ", site, wlrtab_raw, ".scan, 
concat(", site, wlrtab_raw, ".date, ' ', ", site, wlrtab_raw, ".time)::timestamp, 
             ", site, wlrtab_raw, ".wl_raw
             FROM ", site, wlrtab_raw, " LEFT JOIN ", site, wlrtab, "
             ON concat(", site, wlrtab_raw, ".date, ' ', ", site, wlrtab_raw, ".time)::timestamp=", wlrtab, ".date_time
             AND ", site, wlrtab_raw, ".scan=", site, wlrtab, ".scan
             WHERE ", wlrtab, ".date_time IS NULL AND ", wlrtab, ".scan IS NULL;", sep="")
    rs <- dbSendQuery(con, stm)
    rm(stm)
    ## Remove the raw raw tables or they'll grow continuously.
    stm<-paste("DROP TABLE ", site, wlrtab_raw, ";", sep="")
    rs <- dbSendQuery(con, stm)
    rm(stm)
    ##---- fill in the gaps in readings, based on Srini's script
    
    stm <- paste("UPDATE ", tabname[i],
                 " SET date_time =(SELECT date_trunc('minute', date_time + interval '30 second'));",
                 sep="") # rounds the logger to one minute
    rs <- dbSendQuery(con, stm)
    rm(stm)
    stm <- paste("SELECT * FROM ", tabname[i], sep="") # rounds the logger to one minute
    rs <- dbSendQuery(con, stm)
    xy <- fetch(rs, n = -1)
    rm(stm)
    ## This section from Srini
    xy$date_time<-as.POSIXct(xy$date_time)
    start.hr <- round(as.POSIXct(min(xy$date_time)), "mins")
    end.hr <- round(as.POSIXct(max(xy$date_time)), "mins")
    tint1min <- seq.POSIXt(start.hr, end.hr,by="1 min",na.rm=T)#I have kept it to one minute
    attributes(tint1min)$tzone <- "Asia/Kolkata"
    xx1<-as.data.frame(tint1min)
    colnames(xx1)<-c("date_time")
    xx2<-merge(xx1, xy, by = "date_time", all = TRUE)
    xx2$date_time<-as.POSIXct(xx2$date_time)
    ## adds duplicates, so remove it in the next line
    xx2 <-  xx2[!duplicated(xx2$date_time), ]
    xx3<-as.timeSeries(xx2)
    xx3<-interpNA(xx3, method="before") ## wl_cal is all NULL throws an error
    xx3$date_time<-row.names(xx3)
    mmx<-as.data.frame(xx3, row.names=NULL)
    names(mmx)
    mmx$date_time <- as.POSIXct(mmx$date_time, tz="Asia/Kolkata")
    wlronemincsv <- paste(csvdir, loggers[i] ,"_1 minute.csv", sep="")
    write.csv(mmx, file=wlronemincsv)
    wlroneminpg <- paste(loggers[i] ,"_1_minute", sep="") # issue with schema selection
    stm <- paste("DROP TABLE IF EXISTS PUBLIC.", wlroneminpg, sep=" ")
    rs <- dbSendQuery(con, stm)
    rm(rs, stm)
    dbWriteTable(con, wlroneminpg, mmx, overwrite=TRUE) # write to temporary table
    ## copy temporary table to correct schema and tablename
    stm <- paste("DROP TABLE IF EXISTS ",  site, wlroneminpg, ";",
                 " CREATE TABLE ", site, wlroneminpg, " AS ",
                 "SELECT scan, wl_raw, wl_cal, date_time FROM PUBLIC.", wlroneminpg, ";",
                 " DROP TABLE IF EXISTS PUBLIC.", wlroneminpg, ";", sep="")
     rs <- dbSendQuery(con, stm)
    rm(rs, stm)

    
    
##    stm <- paste("UPDATE ", site, wlrtab, " SET wl_cal=(wl_raw * b.x) + b.intercept
## FROM ", site, "wlr_calib b WHERE b.wlr_id= '", wlrtab,"'", sep="")
    ## stm <- paste("DROP TABLE IF EXISTS ",  site, wlroneminpg, sep="")
    ## rs <- dbSendQuery(con, stm)
    ## rm(stm)
    ## stm <- paste("CREATE TABLE ", site, wlroneminpg,
    ##               " AS SELECT scan, wl_raw, wl_cal, date_time FROM ", wlroneminpg, sep="")
    ## rs  <- dbSendQuery(con, stm)
    ## rm(stm)
    
    ##---- Calibrate the readings ----##
    stm <- paste("UPDATE ", site,  wlroneminpg,
                 " SET wl_cal=(wl_raw * b.x) + b.intercept FROM ",
                 site, "wlr_calib b WHERE b.wlr_id= '", wlrtab,"'", sep="")
    rs <- dbSendQuery(con, stm)
    rm(stm)
##mmx$wl_cal=(wl_raw
    ## VACUUM the tables to remove dead tuples
##    stm<-paste("VACUUM ", site, wlrtab, ";", sep="")
    stm<-paste("VACUUM ", site, wlroneminpg, ";", sep="")
    rs <- dbSendQuery(con, stm)
    rm(stm)
    i=i+1;
}

