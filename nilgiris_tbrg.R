## Needs to be updated with new directory structure
## This script is to organise the various data sets throuth PostgreSQL and PostGIS
## It automatically transfers unique datasets from csv files to database tables.
library(RPostgreSQL)
library(lattice)
library(yaml)
## Define the connection
conf <- yaml.load_file(paste(mndir,"db.config.yml", sep="")) # this is to avoid sharing credentials for the database
con <- dbConnect(PostgreSQL(), host=conf$db$host, dbname=conf$db$name, user=conf$db$user, password=conf$db$pass)
tbrgdatadir<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/raw"
tbrg_nulldatadir<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/null"
wkdir<-"/home/udumbu/rsb/OngoingProjects/CWC/rdata/"
setwd(wkdir)
## Create tables to hold the tbrg and wlr datasets
num_tbrg<-101:130 # the number of tbrgs
## Ensure the diretories for the data are created
## in the console "mkdir tbrg_{101..130}" will create directories tbrg_101 to tbrg_130
i=1
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
  stm<-paste("DROP TABLE IF EXISTS nilgiris.", tbrgtab_raw, ";", 
             "CREATE TABLE IF NOT EXISTS nilgiris.", tbrgtab_raw, 
             "(date date, time time, tips REAL);", sep="")
  rs <- dbSendQuery(con, stm)
  rm(stm)
  ## This statement is to copy the data from the respective tbrg folders into the tables.
  ## Note that only CSV files are supported - don't stick in xls sheets.
  
  ## run another loop within the earlier one
  ## This loop copies all the csv/dat files onto a raw tbrg table
  j=1
  while(j<=length(filelist)){
    stm<-paste("COPY nilgiris.", tbrgtab_raw, " FROM '", 
               tbrgdir, "/", filelist[j], "' DELIMITER ',' CSV;", sep="")
    rs<-dbSendQuery(con,stm)
    rm(stm)
    j=j+1;
  }
  
  ## This loop creates a temporary table entry for each null value pair in each tbrg.
  
  ## Now for the null tables, we need to loop thorugh the file names
  ## THIS NEEDS FIXING 
  
  ## Create the table to hold all the null values for a given tbrg
  stm <- paste("DROP TABLE IF EXISTS nilgiris.", tbrgtab_null_all, ";
  CREATE TABLE nilgiris.", tbrgtab_null_all, "(id serial NOT NULL,
    date_time timestamp without time zone, tips real,
    CONSTRAINT tbrgtab_null_all_pkey PRIMARY KEY (id ))", sep="")
  rs <- dbSendQuery(con, stm)
  rm(stm)
  
  k<-1
  while(k<=length(filelist_null)){
    ## Create vectors hold timestamp pairs of logger errors
    tbrgtab_null<-paste("tbrg_", num_tbrg[i], "_", filelist_null[k], sep="") # Table holding error file
    tbrgtab_null_pseudo <- paste(tbrgtab_null, "_pseudo", sep="") # Table with concatenated date_time (timestamp)
    tbrgtab_null_seq <- paste(tbrgtab_null, "_seq", sep="") # Table holding sequence of NULL values
    
    stm<-paste("DROP TABLE IF EXISTS nilgiris.", tbrgtab_null, ";", 
               "CREATE TABLE IF NOT EXISTS nilgiris.", tbrgtab_null, 
               "(date date, time time, tips REAL);", sep="")
    rs <- dbSendQuery(con, stm)
    rm(stm)
    ## Tansfer data from the error files to the database table
    stm<-paste("COPY nilgiris.", tbrgtab_null, " FROM '", 
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
    
    ## Create a table that concatenates the date and time into a timestamp ##### FIX FROM HERE
    stm <- paste("DROP TABLE IF EXISTS nilgiris.", tbrgtab_null_pseudo, "; 
                 CREATE TABLE nilgiris.", tbrgtab_null_pseudo, " AS
               SELECT concat(nilgiris.", tbrgtab_null, ".date, ' ', nilgiris.", tbrgtab_null, ".time)::timestamp 
 AS date_time,  tips FROM nilgiris.", tbrgtab_null, sep="")
    rs <- dbSendQuery(con, stm)
    rm(stm)
    ## Now generate a series of NULL values to fill in the gaps.
    stm<-paste("DROP TABLE IF EXISTS nilgiris.", tbrgtab_null_seq,"; 
              CREATE TABLE nilgiris.",tbrgtab_null_seq, " AS
              SELECT * FROM 
              generate_series((select min(date_time) from nilgiris.",tbrgtab_null_pseudo,"),
    (select max(date_time) from nilgiris.",tbrgtab_null_pseudo,"), '1 minute') as date_time,
              generate_series(0, 0) AS tips;
             UPDATE  nilgiris.", tbrgtab_null_seq, "
             set tips=NULL;", sep="")  # statement changed to insert series of NULL values, -999 may work better
rs <- dbSendQuery(con, stm)
rm(stm)

## Append all this data to a table named after the concerned raingauge
    ## First create the table to hold results
    stm<-paste("DROP TABLE IF EXISTS nilgiris.", tbrgtab_null_all, ";", 
               "CREATE TABLE IF NOT EXISTS nilgiris.", tbrgtab_null_all, 
               "(date_time TIMESTAMP, tips REAL);", sep="")
    rs <- dbSendQuery(con, stm)
    rm(stm)
    ## Now update and insert from sub-tables
stm <- paste("UPDATE nilgiris.", tbrgtab_null_all, " SET tips=b.tips
    FROM nilgiris.", tbrgtab_null_seq, " AS b WHERE ", tbrgtab_null_all, ".date_time=b.date_time;
                 INSERT INTO nilgiris.", tbrgtab_null_all, " (date_time, tips) 
                 SELECT date_time, tips FROM nilgiris.", tbrgtab_null_seq,";", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)
    ## The resulting table may contain duplicates, so remove them
    stm <- paste("DROP TABLE IF EXISTS nilgiris.tmp; 
  CREATE TABLE nilgiris.tmp (date_time TIMESTAMP, tips REAL);
    INSERT INTO nilgiris.tmp SELECT DISTINCT * FROM nilgiris.", tbrgtab_null_all, ";
    DROP TABLE", tbrgtab_null_all,";
    ALTER TABLE tmp RENAME TO", tbrgtab_null_all, ";", sep="")
    
## Clean up

stm <- paste("DROP TABLE IF EXISTS nilgiris.",tbrgtab_null_pseudo, ";
DROP TABLE IF EXISTS nilgiris.", tbrgtab_null_seq, ";
DROP TABLE IF EXISTS nilgiris.",tbrgtab_null,";", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)   

k <- k+1;
  }
## Create the tables to hold tbrg data - one per tbrg 
stm<-paste("DROP TABLE nilgiris.", tbrgtab, ";             
             CREATE TABLE IF NOT EXISTS nilgiris.",tbrgtab, 
           "(id SERIAL PRIMARY KEY, date_time timestamp, tips real);", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)
## Now transfer the data from the raw table to the clean table.
stm<-paste("INSERT INTO nilgiris.", tbrgtab, "(date_time, tips) 
             SELECT DISTINCT concat(nilgiris.", tbrgtab_raw, ".date, ' ', nilgiris.", tbrgtab_raw, ".time)::timestamp, 
             nilgiris.", tbrgtab_raw, ".tips
             FROM nilgiris.", tbrgtab_raw, " LEFT JOIN nilgiris.", tbrgtab, "
             ON concat(nilgiris.", tbrgtab_raw, ".date, ' ', nilgiris.", tbrgtab_raw, ".time)::timestamp=", tbrgtab, ".date_time
             WHERE ", tbrgtab, ".date_time IS NULL;", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)
## Now fill in all the blank values for timestamps where there were no tips
## First create a table for each tbrg with pseudo values corresponding to the period of data
stm<-paste("DROP TABLE IF EXISTS nilgiris.", tbrgtab_pseudo, ";",
           "CREATE TABLE nilgiris.",tbrgtab_pseudo, " AS
             SELECT * FROM 
             generate_series((select min(date_time) from nilgiris.",tbrgtab ," where date_time > date '2011-12-31'),
             (select max(date_time) from nilgiris.",tbrgtab,"), '1 minute') as date_time,
             generate_series(0, 0) AS tips;", sep="")  # statement changed to exclude dates before 2012
rs <- dbSendQuery(con, stm)
rm(stm)
## Now do a join to fill in missing values in the actual tbrgtab
stm<-paste("INSERT INTO nilgiris.", tbrgtab, "(date_time, tips) 
             SELECT DISTINCT nilgiris.", tbrgtab_pseudo, ".date_time, 
             nilgiris.", tbrgtab_pseudo, ".tips
             FROM nilgiris.", tbrgtab_pseudo, " LEFT JOIN nilgiris.", tbrgtab, "
             ON nilgiris.", tbrgtab_pseudo, ".date_time =", tbrgtab, ".date_time
             WHERE ", tbrgtab, ".tips IS NULL;", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)


## Now do a join to fill in missing values in the actual tbrgtab
stm<-paste("UPDATE nilgiris.", tbrgtab, " a 
          SET date_time=b.date_time, tips=b.tips
             FROM nilgiris.", tbrgtab_null_all, " b 
            WHERE a.date_time=b.date_time;", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)

  ## Clean up
  ##DROP redundant tables
stm<-paste("DROP TABLE IF EXISTS nilgiris.", tbrgtab_raw, ";
             DROP TABLE IF EXISTS nilgiris.",tbrgtab_pseudo, ";
             DROP TABLE IF EXISTS nilgiris.",tbrgtab_null_all, ";", sep="")

#            
rs <- dbSendQuery(con, stm)
rm(stm)
## and VACUUM the good tables to remove dead tuples

stm<-paste("VACUUM nilgiris.", tbrgtab, ";", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)
i<-i+1;
}

## Pull in the calibration data
## First delete the tbrg_calib file
## This is to ensure that the new calibration file is used.

stm<-"DELETE FROM nilgiris.tbrg_calib;"
rs <- dbSendQuery(con, stm)
rm(stm)

## Please note that the timestamp is not being imported from the CSV.
## This should be fixed first in the csv and then in the SQL statement.
## The calibration file needs to be fixed. Plenty of gaps in the Aghnashini dataset.
stm<-"COPY nilgiris.tbrg_calib( tbrg_id, rawml_pertip, tbrg_area, mm_pertip)
FROM '/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/calib/nilgiri_tbrg_calibration_fnl.csv'
DELIMITER ',' CSV header;" 
rs <- dbSendQuery(con, stm)
rm(stm)

## Now create a loop which generates the actual rainfall in mm per tip for each tbrg
## The loop requires you to state the intervals at which the data is to be pooled
## This script uses seconds as a basis (can we do it in hours and then divide)
## This does it by 15 mins, 1/2 hour, 1 hour, 4 hours, 6 hours, 12 hours and 24 hours
text_agg<-c("One minute", "Five minutes", "15 minutes", "Half hour", "One hour", "Six hours", "Twelve hours")
min_agg<-c("60", "300", "900", "1800", "3600", "21600", "43200")
tbrg_list<-c(paste("tbrg", 101:130, sep="_"))
i=1
while(i<=length(tbrg_list)){
  pngout<-paste("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/fig/", tbrg_list[i],".png", sep="")
  csvdir<-paste("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv/", sep="")   
  png(file=pngout, width = 1680, height = 780, units = "px", pointsize = 12, res=100,  bg = "white")
  par(mfrow=c(2,4), oma=c(0,0,2,0))
  j=1
  while(j<=length(min_agg)){
    ## use epoch to break timestamp into second intergers and then work back into time
    stm<-paste("SELECT to_timestamp(((extract (epoch from date_time)::int / ", min_agg[j],
               ") * ", min_agg[j], ") + ", min_agg[j], ") AS dt,
        sum(round(a.tips * 100))::INTEGER AS tips,
        sum(round(a.tips * 100) * b.mm_pertip) AS mm_rain
        FROM nilgiris.", tbrg_list[i], " a, nilgiris.tbrg_calib b
        WHERE b.tbrg_id='", tbrg_list[i], "'
        AND a.tips IS NOT NULL GROUP BY dt
        ORDER BY dt;", sep="") # the rounding is to ensure we don't get funny numbers
    rs <- dbSendQuery(con, stm)
    data <- fetch(rs, n = -1)
    csvout<-paste(csvdir, tbrg_list[i] ,"_", text_agg[j], ".csv", sep="")
    write.csv(data, file=csvout)
    rm(stm)
    plot(data$dt, data$mm_rain, type="l", main=c(text_agg[j]), xlab="Day/date", ylab="Rainfall in mm") 
    j=j+1
    
    #plot(data, type="l", main=c(text_agg[j]), xlab="Day/date", ylab="Rainfall in mm")
    #j=j+1;
  }
  ## Do for the daily aggregation separately
  ## Added to fix error pointed out by Naresh and Susan
  stm<-paste("SELECT to_timestamp(((extract (epoch from date_time)::int / 86400) * 86400)) AS dt,
        sum(round(a.tips * 100))::INTEGER AS tips,
        sum(round(a.tips * 100) * b.mm_pertip) AS mm_rain
        FROM nilgiris.", tbrg_list[i], " a, nilgiris.tbrg_calib b
        WHERE b.tbrg_id='", tbrg_list[i], "'
        GROUP BY dt
        ORDER BY dt;", sep="") # the rounding is to ensure we don't get funny numbers
  rs <- dbSendQuery(con, stm)
  data <- fetch(rs, n = -1)
  csvout<-paste(csvdir, tbrg_list[i] ,"_Daily.csv", sep="")
  write.csv(data, file=csvout)
  rm(stm)
  plot(data$dt, data$mm_rain, type="l", main="Daily", xlab="Day/date", ylab="Rainfall in mm") 
  title(tbrg_list[i], outer=TRUE)
  dev.off()
  i=i+1;
}

## Close the connection
postgresqlCloseConnection(con)
