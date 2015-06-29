## Fill previous WLR values each minute
## Null might work better need to discuss
for(i in 1:length(num_wlr)){
## Create the tables to hold wlr data - one per wlr

    ## First round off the time stamp to minutes. Some gauges have it to seconds
    stm <- paste("UPDATE ", site, num_wlr[i], " SET date_time =
(SELECT date_trunc('minute', date_time + interval '30 second'));", sep="")
    ## now create a temporary table to hold null values for range of data at one minute intervals

 stm <- paste("CREATE TABLE ", num_wlr[i], " AS SELECT * FROM 
 generate_series((SELECT MIN(date_time) FROM ", site, num_wlr[i], "),
 (SELECT MAX(date_time)  FROM ", site, num_wlr[i], "), '1 minute') 
	AS date_time, generate_series(0, 0) AS wl_cal; "
ALTER TABLE agnashini.tfill_wlr_003 ADD COLUMN id serial;
ALTER TABLE agnashini.tfill_wlr_003 ADD CONSTRAINT pk PRIMARY KEY (id);
UPDATE agnashini.tfill_wlr_003
SET wl_cal =  a.wl_cal
FROM agnashini.wlr_003 AS a, agnashini.tfill_wlr_003 AS b
WHERE a.date_time = b.date_time;


site, num, sep="")

    
stm<-paste("DROP TABLE  ", site, wlrtab, ";             
             CREATE TABLE IF NOT EXISTS  ", site,wlrtab, 
           "(id SERIAL PRIMARY KEY, date_time timestamp, tips real);", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)
## Now transfer the data from the raw table to the clean table.
stm<-paste("INSERT INTO  ", site, wlrtab, "(date_time, tips) 
             SELECT DISTINCT concat( ", site, wlrtab_raw, ".date, ' ',  ", site, wlrtab_raw, ".time)::timestamp, 
              ", site, wlrtab_raw, ".tips
             FROM  ", site, wlrtab_raw, " LEFT JOIN  ", site, wlrtab, "
             ON concat( ", site, wlrtab_raw, ".date, ' ',  ", site, wlrtab_raw, ".time)::timestamp=", wlrtab, ".date_time
             WHERE ", wlrtab, ".date_time IS NULL;", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)
## Now fill in all the blank values for timestamps where there were no tips
## First create a table for each wlr with pseudo values corresponding to the period of data
stm<-paste("DROP TABLE IF EXISTS  ", site, wlrtab_pseudo, ";",
           "CREATE TABLE  ", site,wlrtab_pseudo, " AS
             SELECT * FROM 
             generate_series((select min(date_time) from  ", site,wlrtab ," where date_time > date '2011-12-31'),
             (select max(date_time) from  ", site,wlrtab,"), '1 minute') as date_time,
             generate_series(0, 0) AS tips;", sep="")  # statement changed to exclude dates before 2012
rs <- dbSendQuery(con, stm)
rm(stm)
## Now do a join to fill in missing values in the actual wlrtab
stm<-paste("INSERT INTO  ", site, wlrtab, "(date_time, tips) 
             SELECT DISTINCT  ", site, wlrtab_pseudo, ".date_time, 
              ", site, wlrtab_pseudo, ".tips
             FROM  ", site, wlrtab_pseudo, " LEFT JOIN  ", site, wlrtab, "
             ON  ", site, wlrtab_pseudo, ".date_time =", wlrtab, ".date_time
             WHERE ", wlrtab, ".tips IS NULL;", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)


## Now merge the NULL values using a join.
stm<-paste("UPDATE  ", site, wlrtab, " a 
          SET date_time=b.date_time, tips=b.tips
             FROM  ", site, wlrtab_null_all, " b 
            WHERE a.date_time=b.date_time;", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)

  ## Clean up
  ##DROP redundant tables
stm<-paste("DROP TABLE IF EXISTS  ", site, wlrtab_raw, ";
             DROP TABLE IF EXISTS  ", site,wlrtab_pseudo, ";", sep="")

#             DROP TABLE IF EXISTS  ", site,wlrtab_null_all, ";", sep="")

#            
#rs <- dbSendQuery(con, stm)
#rm(stm)
## and VACUUM the good tables to remove dead tuples

stm<-paste("VACUUM  ", site, wlrtab, ";", sep="")
rs <- dbSendQuery(con, stm)
rm(stm)
i<-i+1;
}
