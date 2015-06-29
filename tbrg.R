## Needs to be updated with new directory structure
## This script is to organise the various data sets throuth PostgreSQL and PostGIS
## It automatically transfers unique datasets from csv files to database tables.
library(RPostgreSQL)
library(ggplot2)
library(yaml)
## Define the connection
conf <- yaml.load_file(paste(wkdir,"db.config.yml", sep="")) # this is to avoid sharing credentials for the database
con <- dbConnect(PostgreSQL(), host=conf$db$host, dbname=conf$db$name, user=conf$db$user, password=conf$db$pass)

i <- 1
while(i<=length(num_tbrg)){
  ## List the names of the files
  tbrgtab<-paste("tbrg_", num_tbrg[i], sep="") # Directory/table per tbrg holding csv files are stored.
  tbrgtab_raw<-paste("tbrg_", num_tbrg[i], "_raw", sep="")
  tbrgtab_pseudo<-paste("tbrg_", num_tbrg[i], "_pdeudo", sep="")
  tbrgdir<-paste(tbrgdatadir, tbrgtab, sep="/") # Directory holding all tbrg sub folders
  tbrgdir_null<-paste(tbrg_nulldatadir, tbrgtab, sep="/") # Directory holding all tbrg_null sub folders
  tbrgtab_null_all<-paste(tbrgtab, "_null_all",sep="") # Directory holding all tbrg_null sub folders
  dirliststm<-paste("ls ", tbrgdir, sep="") # List contents of tbrg## folder.
  dirliststm_null<-paste("ls ", tbrgdir_null, sep="") # List contents of tbrg_error folders.
  filelist<-system(dirliststm, intern=TRUE) # Save the list of contents to an object
  filelist_null<-system(dirliststm_null, intern=TRUE) # Save the list of error files to an object
  ## This statement is to create a table for each tbrg and tbrg_null.
  stm<-paste("DROP TABLE IF EXISTS ", site, tbrgtab_raw, ";", 
             "CREATE TABLE IF NOT EXISTS ", site, tbrgtab_raw, 
             "(date date, time time, tips REAL);", sep="")
  rs <- dbSendQuery(con, stm)
  rm(stm)
  ## This statement is to copy the data from the respective tbrg folders into the tables.
  ## Note that only CSV files are supported - don't stick in xls sheets.
  
  ## run another loop within the earlier one
  ## This loop copies all the csv/dat files onto a raw tbrg table
  j=1
  while(j<=length(filelist)){
    stm<-paste("COPY ", site, tbrgtab_raw, " FROM '", 
               tbrgdir, "/", filelist[j], "' DELIMITER ',' CSV;", sep="")
    rs<-dbSendQuery(con,stm)
    rm(stm)
    j=j+1;
  }
  
  ## This loop creates a temporary table entry for each null value pair in each tbrg.
  ## Now for the null tables, we need to loop thorugh the file names
  ## Create the table to hold all the null values for a given tbrg
stm <- paste("DROP TABLE IF EXISTS ", site, tbrgtab_null_all, ";
 CREATE TABLE ", site, tbrgtab_null_all,
             " (date_time timestamp without time zone, tips real)", sep="")
  rs <- dbSendQuery(con, stm)
  rm(stm)
  
  k<-1
  while(k<=length(filelist_null)){
  n <- nchar(filelist_null[k])
  n <- n - 4
  nulltab <- substr(filelist_null[k],1, n) # list of files minus suffix.
    ## Create vectors hold timestamp pairs of logger errors
    tbrgtab_null<-paste("tbrg_", num_tbrg[i], "_", nulltab, sep="") # Table holding error file
    tbrgtab_null_pseudo <- paste(tbrgtab_null, "_pseudo", sep="") # Table with concatenated date_time (timestamp)
    tbrgtab_null_seq <- paste(tbrgtab_null, "_seq", sep="") # Table holding sequence of NULL values
    
    stm<-paste("DROP TABLE IF EXISTS ", site, tbrgtab_null, "; 
               CREATE TABLE IF NOT EXISTS ", site, tbrgtab_null, 
               "(date date, time time, tips REAL);", sep="")
    rs <- dbSendQuery(con, stm)
    rm(stm)
    ## Tansfer data from the error files to the database table
    stm<-paste("COPY ", site, tbrgtab_null, " FROM '", 
               tbrgdir_null, "/", filelist_null[k], "' DELIMITER ',' CSV;", sep="")
    try(rs<-dbSendQuery(con,stm), silent=TRUE)
    rm(stm)
    ## Fill in the time intervals first with 0 and then with NULL
    ## INSERT the NULL values, This needs to be fixed
    ## Major change is that each set of null values needs a separate table which
    ## is then merged into a single table of null values before being merged into
    ## the actual dataset. This requires one additional loop.
    ## First create a table for each of the NULL value series based on the entries in the null directory
    #   dir_tbrgerrors<-paste(tbrgdatadir, "/errors", sep="")
    
    ## Create a table that concatenates the date and time into a timestamp
    stm <- paste("DROP TABLE IF EXISTS ", site, tbrgtab_null_pseudo, "; 
                 CREATE TABLE  ", site, tbrgtab_null_pseudo, " AS
               SELECT concat( ", site, tbrgtab_null, ".date, ' ',  ", site, tbrgtab_null, ".time)::timestamp 
 AS date_time,  tips FROM  ", site, tbrgtab_null, sep="")
    rs <- dbSendQuery(con, stm)
    rm(stm)
    ## Now generate a series of NULL values to fill in the gaps.
    stm<-paste("DROP TABLE IF EXISTS  ", site, tbrgtab_null_seq,"; 
              CREATE TABLE  ", site,tbrgtab_null_seq, " AS
              SELECT * FROM 
              generate_series((select min(date_time) from  ", site,tbrgtab_null_pseudo,"),
    (select max(date_time) from  ", site,tbrgtab_null_pseudo,"), '1 minute') as date_time,
              generate_series(0, 0) AS tips;
             UPDATE   ", site, tbrgtab_null_seq, "
             set tips=NULL;", sep="")  # statement changed to insert series of NULL values, -999 may work better
rs <- dbSendQuery(con, stm)
rm(stm)

## Append all this data to a table named after the concerned raingauge
    ## First create the table to hold results
    ## stm<-paste("DROP TABLE IF EXISTS  ", site, tbrgtab_null_all, ";", 
    ##            "CREATE TABLE IF NOT EXISTS  ", site, tbrgtab_null_all, 
    ##            "(date_time TIMESTAMP, tips REAL);", sep="")
    ## rs <- dbSendQuery(con, stm)
    ## rm(stm)
    ## Now update and insert from sub-tables
stm <- paste("UPDATE  ", site, tbrgtab_null_all, " SET tips=b.tips
    FROM  ", site, tbrgtab_null_seq, " AS b WHERE ", tbrgtab_null_all, ".date_time=b.date_time;
                 INSERT INTO  ", site, tbrgtab_null_all, " (date_time, tips) 
                 SELECT date_time, tips FROM  ", site, tbrgtab_null_seq,";", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)
    ## The resulting table may contain duplicates, so remove them
    stm <- paste("DROP TABLE IF EXISTS ", site, "tmp; 
  CREATE TABLE ", site, "tmp (date_time TIMESTAMP, tips REAL);
    INSERT INTO ", site, "tmp SELECT DISTINCT * FROM  ", site, tbrgtab_null_all, ";
    DROP TABLE ", site, tbrgtab_null_all,";
    ALTER TABLE ", site," tmp RENAME TO ", tbrgtab_null_all, ";", sep="")
    
rs <- dbSendQuery(con, stm)
rm(stm)
## Clean up

stm <- paste("DROP TABLE IF EXISTS  ", site,tbrgtab_null_pseudo, ";
DROP TABLE IF EXISTS  ", site, tbrgtab_null_seq, ";
DROP TABLE IF EXISTS  ", site,tbrgtab_null,";", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)   

k <- k+1;
  }
## Create the tables to hold tbrg data - one per tbrg 
stm<-paste("DROP TABLE  ", site, tbrgtab, ";             
             CREATE TABLE IF NOT EXISTS  ", site,tbrgtab, 
           "(id SERIAL PRIMARY KEY, date_time timestamp, tips real);", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)
## Now transfer the data from the raw table to the clean table.
stm<-paste("INSERT INTO  ", site, tbrgtab, "(date_time, tips) 
             SELECT DISTINCT concat( ", site, tbrgtab_raw, ".date, ' ',  ", site, tbrgtab_raw, ".time)::timestamp, 
              ", site, tbrgtab_raw, ".tips
             FROM  ", site, tbrgtab_raw, " LEFT JOIN  ", site, tbrgtab, "
             ON concat( ", site, tbrgtab_raw, ".date, ' ',  ", site, tbrgtab_raw, ".time)::timestamp=", tbrgtab, ".date_time
             WHERE ", tbrgtab, ".date_time IS NULL;", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)
## Now fill in all the blank values for timestamps where there were no tips
## First create a table for each tbrg with pseudo values corresponding to the period of data
stm<-paste("DROP TABLE IF EXISTS  ", site, tbrgtab_pseudo, ";",
           "CREATE TABLE  ", site,tbrgtab_pseudo, " AS
             SELECT * FROM 
             generate_series((select min(date_time) from  ", site,tbrgtab ," where date_time > date '2011-12-31'),
             (select max(date_time) from  ", site,tbrgtab,"), '1 minute') as date_time,
             generate_series(0, 0) AS tips;", sep="")  # statement changed to exclude dates before 2012
rs <- dbSendQuery(con, stm)
rm(stm)
## Now do a join to fill in missing values in the actual tbrgtab
stm<-paste("INSERT INTO  ", site, tbrgtab, "(date_time, tips) 
             SELECT DISTINCT  ", site, tbrgtab_pseudo, ".date_time, 
              ", site, tbrgtab_pseudo, ".tips
             FROM  ", site, tbrgtab_pseudo, " LEFT JOIN  ", site, tbrgtab, "
             ON  ", site, tbrgtab_pseudo, ".date_time =", tbrgtab, ".date_time
             WHERE ", tbrgtab, ".tips IS NULL;", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)


## Now merge the NULL values using a join.
stm<-paste("UPDATE  ", site, tbrgtab, " a 
          SET date_time=b.date_time, tips=b.tips
             FROM  ", site, tbrgtab_null_all, " b 
            WHERE a.date_time=b.date_time;", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)

  ## Clean up
  ##DROP redundant tables
stm<-paste("DROP TABLE IF EXISTS  ", site, tbrgtab_raw, ";
             DROP TABLE IF EXISTS  ", site,tbrgtab_pseudo, ";", sep="")

#             DROP TABLE IF EXISTS  ", site,tbrgtab_null_all, ";", sep="")

#            
#rs <- dbSendQuery(con, stm)
#rm(stm)
## and VACUUM the good tables to remove dead tuples

stm<-paste("VACUUM  ", site, tbrgtab, ";", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)
i<-i+1;
}

## Pull in the calibration data
## First delete the tbrg_calib file
## This is to ensure that the new calibration file is used.

stm<-paste("DELETE FROM ", site, "tbrg_calib;", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)

## Please note that the timestamp is not being imported from the CSV.
## This should be fixed first in the csv and then in the SQL statement.
## The calibration file needs to be fixed. Plenty of gaps in the Aghnashini dataset.
stm<-paste("COPY ", site, "tbrg_calib( tbrg_id, rawml_pertip, tbrg_area, mm_pertip)
FROM '", calibfile, "' DELIMITER ',' CSV header;", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)

## Now create a loop which generates the actual rainfall in mm per tip for each tbrg
## The loop requires you to state the intervals at which the data is to be pooled
## This script uses seconds as a basis (can we do it in hours and then divide)
## This does it by 15 mins, 1/2 hour, 1 hour, 4 hours, 6 hours, 12 hours and 24 hours
text_agg<-c("Five minutes", "15 minutes", "Half hour", "One hour", "Six hours")
min_agg<-c(300, 900, 1800, 3600, 21600)
tbrg_list<-c(paste("tbrg", num_tbrg, sep="_"))
i <- 1
while(i<=length(tbrg_list)){
    figout<-paste(figdir, tbrg_list[i],".png", sep="")
    ##  pdf(file=figout, width = 16.6, height = 23.4, pointsize = 10, bg = "white")
    png(file=figout, width = 16.6, height = 23.4, units = "in", pointsize = 10, res=100, bg = "white")
    figtitle <- tbrg_list[i] # for use in graphing routine
    par(mfrow=c(6,3), oma=c(0,0,1,0), mar=c(3,2.5,2,2)) # for the graphing routine
    
    j<-1
  while(j<=length(min_agg)){
    ## use epoch to break timestamp into second intergers and then work back into time
      stm<-paste("SELECT to_timestamp(((extract (epoch from date_time)::int / ", min_agg[j],
                 ") * ", min_agg[j], ") + ", min_agg[j], ") AS dt,
        sum(round(a.tips * 100))::INTEGER AS tips,
        sum(round(a.tips * 100) * b.mm_pertip) AS mm_rain
        FROM  ", site, tbrg_list[i], " a, ", site, "tbrg_calib b
        WHERE b.tbrg_id='", tbrg_list[i], "'
        GROUP BY dt
        ORDER BY dt;", sep="") # the rounding is to ensure we don't get funny numbers
      
      rs <- dbSendQuery(con, stm)
      data <- fetch(rs, n = -1)
      ## FIX NEXT TWO LINES
      datname <- paste(tbrg_list[i], min_agg[j], sep="")
      assign(datname, data)
      csvout<-paste(csvdir, tbrg_list[i] ,"_", text_agg[j], ".csv", sep="")
      write.csv(data, file=csvout)
      rm(stm)
      ### plot(data$dt, data$mm_rain, type="l", main=c(text_agg[j]), xlab="Day/date", ylab="Rainfall in mm")
      agg <- text_agg[j] # for the main label in graphing routine
      source(paste(wkdir,"tbrg_graphing.R", sep=""), echo=TRUE)
      j=j+1
      
                                        #plot(data, type="l", main=c(text_agg[j]), xlab="Day/date", ylab="Rainfall in mm")
                                        #j=j+1;
  }
  ## Do for the daily aggregation separately
  ## Added to fix error pointed out by Naresh and Susan
  stm<-paste("SELECT to_timestamp(((extract (epoch from date_time)::int / 86400) * 86400)) AS dt,
        sum(round(a.tips * 100))::INTEGER AS tips,
        sum(round(a.tips * 100) * b.mm_pertip) AS mm_rain
        FROM  ", site, tbrg_list[i], " a, ", site, "tbrg_calib b
        WHERE b.tbrg_id='", tbrg_list[i], "'
        GROUP BY dt
        ORDER BY dt;", sep="") # the rounding is to ensure we don't get funny numbers
  rs <- dbSendQuery(con, stm)
  data <- fetch(rs, n = -1)
  ## FIX NEXT TWO LINES
  datname <- c(text <- paste(tbrg_list[i], "Daily", sep=""))
  assign(datname, data)
  csvout<-paste(csvdir, tbrg_list[i] ,"_Daily.csv", sep="")
  write.csv(data, file=csvout)
  rm(stm)
  agg <- "Daily" # for the main label in the graphing routine
  source(paste(wkdir,"tbrg_graphing.R", sep=""), echo=TRUE)
  ### plot(data$dt, data$mm_rain, type="l", main="Daily", xlab="Day/date", ylab="Rainfall in mm")
  title(tbrg_list[i], outer=TRUE)
  dev.off()
  i=i+1;
}

#title(figtitle, outer=TRUE)

## Close the connection
postgresqlCloseConnection(con)
