## Updated oct 20th 2013 with calibration added.
## Read all CSV files but chop the first 10 lines which contain the headers
## Create tables to hold the wlr datasets
## Ensure the diretories for the data are created
##----***----##
for(i in 1:length(num_wlr)){
    ## This statement is to create a table for each wlr if one doesn't exist already
    stm<-paste("CREATE TABLE IF NOT EXISTS ", site, ".wlr_", 
               num_wlr[i], "_raw(scan integer, date date, time time, wl_raw real, wl_cal real);", sep="")
    rs <- dbSendQuery(con, stm)
    rm(stm)
    ## This statement is to copy the data from the respective wlr folders into the tables.
    ## Note that only CSV files are supported - don't stick in xls sheets.
    ## List the names of the files
    wlrtab<-paste("wlr_", num_wlr[i], sep="") # Database table for storing wlr data.
    wlrtab_raw<-paste("wlr_", num_wlr[i], "_raw", sep="")
    wlrdir<-paste(wlrdatadir, wlrtab, sep="") # Directory holding all wlr sub folders
    filetype<-"/*.[Cc][Ss][Vv]" # Only list csv or CSV files
    dirliststm<-paste("ls ", wlrdir, filetype, sep="") # List contents of wlr## folder.
    filelist<-system(dirliststm, intern=TRUE) # Save the list of contents to an object
  ## run another loop within the earlier one
  ## This loop copies all the csv/dat files onto a raw wlr table
  ## In a departure from the earlier script, remove the first ten lines (header)
  ## First move to the relevant directory.
  setwd(wlrdir)
  ## First change the datestyle to dmy
  stm<-paste("SET datestyle = 'ISO, DMY';")
  rs<-dbSendQuery(con,stm)
  rm(stm)
  j=1
  while(j<=length(filelist)){
    rmhead<-paste("tail -n +13", filelist[j], " > tmp.csv")
    system(rmhead)
    stm<-paste("COPY ", site, ".wlr_", num_wlr[i], "_raw FROM '", 
               wlrdir, "/tmp.csv' DELIMITER ',' CSV;", sep="")
    rs<-dbSendQuery(con,stm)
    rm(stm)
    system("rm tmp.csv")
    j=j+1;
  }
  ## Reset the datestyle to default
  stm<-paste("SET datestyle = default;")
  rs<-dbSendQuery(con,stm)
  rm(stm)
  ## Create the tables to hold wlr data - one per wlr ## changed 
  stm<-paste("CREATE TABLE IF NOT EXISTS ", site, ".wlr_", 
             num_wlr[i], "(id SERIAL PRIMARY KEY, scan integer, date_time timestamp, 
             wl_raw real, wl_cal real);", sep="")
  rs <- dbSendQuery(con, stm)
  rm(stm)
  ## Now transfer the data from the raw table to the clean table.
  stm<-paste("INSERT INTO ", site, ".", wlrtab, "(scan, date_time, wl_raw) 
             SELECT DISTINCT ", site, ".", wlrtab_raw, ".scan, 
concat(", site, ".", wlrtab_raw, ".date, ' ', ", site, ".", wlrtab_raw, ".time)::timestamp, 
             ", site, ".", wlrtab_raw, ".wl_raw
             FROM ", site, ".", wlrtab_raw, " LEFT JOIN ", site, ".", wlrtab, "
             ON concat(", site, ".", wlrtab_raw, ".date, ' ', ", site, ".", wlrtab_raw, ".time)::timestamp=", wlrtab, ".date_time
             AND ", site, ".", wlrtab_raw, ".scan=", site, ".", wlrtab, ".scan
             WHERE ", wlrtab, ".date_time IS NULL AND ", wlrtab, ".scan IS NULL;", sep="")
  rs <- dbSendQuery(con, stm)
  rm(stm)
  ## Remove the raw raw tables or they'll grow continuously.
  stm<-paste("DROP TABLE ", site, ".", wlrtab_raw, ";", sep="")
  rs <- dbSendQuery(con, stm)
  rm(stm)
  
##---- Calibrate the readings ----##

stm <- paste("UPDATE ", site, ".", wlrtab, " SET wl_cal=(wl_raw * b.x) + b.intercept
FROM ", site, ".wlr_calib b WHERE b.wlr_id= '", wlrtab,"'", sep="")
rs <- dbSendQuery(con, stm)
  ## dump the csv and figures
  ## stm <- paste("SELECT * FROM ", site, ".", wlrtab, " ORDER BY date_time", sep="")
  ## rs <- dbSendQuery(con, stm)
  ## data <- fetch(rs, n = -1)
  ## csvout<-paste(csvdir, wlrtab ,"_15min.csv", sep="")
  ## figout<-paste(figdir, wlrtab ,".png", sep="")
  ## write.csv(data, file=csvout)
  ## main_title <- paste(wlrtab, ": 15 minutes", sep=" ")
  ## png(filename=figout, width=640, height=480, units="px", pointsize=12, type="cairo")
  ## plot(data$date_time, type="l", data$wl_cal, main=main_title, xlab="Day/date", ylab="Water Level in mm") 
  ## dev.off()
  rm(stm)
  
  ## VACUUM the tables to remove dead tuples
  stm<-paste("VACUUM ", site, ".", wlrtab, ";", sep="")
  rs <- dbSendQuery(con, stm)
  rm(stm)
  i=i+1;
}

