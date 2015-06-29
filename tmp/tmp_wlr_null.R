## Read null values from date stamps and overwrite incorrect values with NULL
## stm <- paste("ls", wlr.nulldir, sep=" ") 
## try(wlr.nulldirlist <- system(stm, intern=TRUE), silent=TRUE) # list of folders in null dir
## rm(stm)
for (n in 1:length(num_wlr)){ # changed to num_wlr from wlr.nulldirlist
    wl.tab <- paste("wlr_", num_wlr[n], sep="") # needs a fresh counter
    wl.onemintab <- paste("wlr_", num_wlr[n], "_1_minute", sep="") # needs a fresh counter
    ##---- system command replaced with native R command
    ##    stm <- paste("ls ", wlr.nulldir, wl.tab , sep="") # changed to wl.tab from wlr.nulldirlist[i]
    ##   try(wlr.nullfilelist <- system(stm, intern=TRUE), silent=TRUE) # list null files in each dir
    nulldir <- paste(wlr.nulldir, wl.tab , sep="") 
    wlr.nullfilelist <- list.files(nulldir)
    
    ## rm(stm)
    ## Create a table for each null directory to hold all the null values
    ## for a given wlr
    wlr.nullsubdir <- paste("wlr_", num_wlr[n], "/", sep="")

    ## NO USE PLEASE CHECK
 ##    wlr.null.tab <- paste(wlr.nulldirlist[n], "_null", sep="")
 ##    stm <- paste("DROP TABLE IF EXISTS ", site, wlr.null.tab, ";
 ## CREATE TABLE ", site, wlr.null.tab,
 ##                 " (scan INTEGER, date_time TIMESTAMP WITHOUT TIME ZONE, wl_raw REAL, wl_cal REAL);", sep="")
 ##    rs <- dbSendQuery(con, stm)
 ##    rm(stm)
#### create loop for wlr.nullfilelist
    for (k in 1:length(wlr.nullfilelist)){
        o <- nchar(wlr.nullfilelist[k])
        o <- o - 4
        nulltab <- substr(wlr.nullfilelist[k],1, o) # list of files minus suffix.
        ## Create vectors hold timestamp pairs of logger errors
        wlr.null<-paste(wl.tab, "_", nulltab, sep="") # Table holding error file
        wlr.null.ts <- paste(wlr.null, "_ts", sep="") # Table with concatenated date_time (timestamp)
        
        stm<-paste("DROP TABLE IF EXISTS ", site, wlr.null, ";", 
                   " CREATE TABLE IF NOT EXISTS ", site, wlr.null, 
                   " (date DATE, time TIME, wl_raw REAL, wl_cal REAL);", sep="") # removed scan INTEGER 
        ## needs to be changed back to "(scan INTEGER, date DATE, time TIME, wl_raw REAL, wl_cal REAL);"
        rs <- dbSendQuery(con, stm)
        rm(stm)
##        setwd(wlr.nulldir) # move to the relevant directory.
        stm<-paste("SET datestyle = 'ISO, DMY';") # change the datestyle to dmy
        rs<-dbSendQuery(con,stm)
        rm(stm)
        ## Tansfer data from the null files to the relevant database table
                                        #  for(j in length(wlr.nullfilelist)){
        stm<-paste("COPY ", site, wlr.null, " FROM '", 
                   wlr.nulldir, wlr.nullsubdir, wlr.nullfilelist[k], "' DELIMITER ',' CSV;", sep="")
        try(rs<-dbSendQuery(con,stm), silent=TRUE)
        rm(stm)
        stm<-paste("SET datestyle = default;") # reset the datestyle to default
        rs<-dbSendQuery(con,stm)
        rm(stm)
        ## Fill in the time intervals first with 0 and then with NULL
        ## Major change is that each set of null values needs a separate table which
        ## is then merged into a single table of null values before being merged into
        ## the actual dataset. This requires one additional loop.
        ## First create a table for each of the NULL value series based on the entries in the null directory
        ## dir_tbrgerrors<-paste(tbrgdatadir, "/errors", sep="")
        
        ## Create a table that concatenates the date and time into a timestamp 
        stm <- paste("DROP TABLE IF EXISTS ", site, wlr.null.ts, "; ",
                     "  CREATE TABLE  ", site, wlr.null.ts, " AS ",
                     "SELECT CONCAT( ", site, wlr.null, ".date, ' ',  ", site, wlr.null,
                     ".time)::TIMESTAMP  AS date_time,  wl_raw, wl_cal FROM  ",
                     site, wlr.null,";", sep="")
        ## again removed scan from statement due to susan's goof
        rs <- dbSendQuery(con, stm)
        rm(stm)
        
        ## TAKE THE UPPER AND LOWER LIMITS FROM THE CONCAT TABLE AND MODIFY
        ## THE RAW DATA ACCORDINGLY
        # changed from wl.tab to wl.onemintab

        stm <- paste("UPDATE ", site, wl.onemintab, " a ",
                     "SET wl_cal = NULL WHERE a.date_time BETWEEN ",
                     "(SELECT min(date_time) FROM ", site, wlr.null.ts,")",
                     " AND",  
                     " (SELECT max(date_time) FROM ", site, wlr.null.ts,");", sep="")
        rs <- dbSendQuery(con, stm)
        rm(stm)
        
        ## Clean up

#stm <- paste("DROP TABLE IF EXISTS  ", site, wlr.null.ts, ";
# DROP TABLE IF EXISTS  ", site, wlr.null,";", sep="")
#rs <- dbSendQuery(con, stm)
#rm(stm)   
}
}
