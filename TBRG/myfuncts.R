
## function to list top few non-zero tips for checking
tips <- function(x){
    return(head(subset(x, subset=x$tips>0)))
}

searchdate <- function(x, dt, tm){
    dt <- as.Date(dt, format="%m/%d/%y")
    tmstmp <- paste(dt, tm, sep=' ')
    return(x[x$dt.tm==tmstmp,])
}

## fix years so that 00-16;  01=17; 02=18
## modified from <https://stat.ethz.ch/pipermail/r-help/2008-June/163634.html>
## x is list of full file names
## use as follows for ALL raw tbrg files:
## --- x <- list.files("~/Res/CWC/Data/Nilgiris/tbrg/raw/", full.names=TRUE, recursive=TRUE)
##--- lapply(x, fix.tbrg.yr)
## you can also only list the files you want to process
## for example if only some trbg units are giving this problem
fix.tbrg.yrs <- function(x){
    df <- read.csv(x, header=F)
    out.dir <- gsub("/original.raw/", "/raw/", x)
    df[,1] <- gsub("/00$", "/16", gsub("/01$", "/17", gsub("/02$", "/18", df[,1])))
    write.table(df, out.dir, col.names = FALSE, row.names = FALSE, quote = FALSE, sep = ",")
}

## Function version of the tbrg_import.R script
## x is list of full raw file names, y is calibration file name
import.tbrg <- function(x, y){
    tmp.raw <- do.call("rbind",  lapply(x, read.csv, header=FALSE, sep=",", quote="", blank.lines.skip = TRUE))
    names(tmp.raw) <- c("dt", "tm", "tips")
    tmp.raw$dt <- as.Date(tmp.raw$dt, format="%m/%d/%y")
    tmp.raw<-transform(tmp.raw, dt.tm = paste(dt, tm, sep=' '))
    tmp.raw$dt.tm<-as.POSIXct(tmp.raw$dt.tm, tz="Asia/Kolkata")
    tmp.year <- format(tmp.raw$dt.tm, "%Y")
    if(min(tmp.year) < 2012){
        stop(paste("Input raw file starts before 2012.", sep=" "))
    } else if (max(tmp.year) > 2020) {
        stop(paste("Input raw file ends after 2020.", sep=" "))
    }
    tmp.raw$dt.tm<-round(x=tmp.raw$dt.tm, units="mins")
    ## Calibrate the raw values
    cal.file <- read.csv(y)
    cal.value <- as.numeric(subset(cal.file, subset=tbrg_id==tbrgtab,select="mm_pertip"))
    tmp.raw$mm <- tmp.raw$tips * cal.value * 100 # NOTE READING IN MM
    ## Start zero filling
    start.hr <- min(tmp.raw$dt.tm)
    end.hr <- max(tmp.raw$dt.tm)
    tint1min <- seq.POSIXt(start.hr, end.hr,by="1 min",na.rm=TRUE)
    tmstmps <- tint1min[!(as.numeric(tint1min)
        %in% as.numeric(tmp.raw$dt.tm))] # get missing timestamps
    tmp.new <- as.data.frame(lapply(tmp.raw, function(x)
        rep.int(0, length(tmstmps)))) # create container
    tmp.new$dt.tm <- tmstmps
    tmp.raw <- rbind(tmp.new, tmp.raw)
    tmp.raw <- tmp.raw[order(tmp.raw$dt.tm),]
    print(paste("Finished importing data for TBRG No.", num_tbrg_i, sep=" "))
    return(tmp.raw)
}
## Function to replace the tbrg_fillnull.R script
## which is now named to tbrg_fillnull.R.OLD
## input is list of full filenames of null files
## output is the NULL merged tbrg data.

fill.null <- function(x){
    if(length(x)>0){
        tmp <- lapply(x, function(y) {
            null.dates <- read.csv(y, header=FALSE, sep=",",
                                   quote="", blank.lines.skip = TRUE)
            ts <- transform(null.dates, dt.tm = paste(null.dates[,1], null.dates[,2]))
            start.ts <- as.POSIXct(ts$dt.tm[1], format = "%m/%d/%Y %H:%M")
            end.ts <- as.POSIXct(ts$dt.tm[2], format = "%m/%d/%Y %H:%M")
            return(seq.POSIXt(start.ts, end.ts,by="1 min",na.rm=TRUE))
        })
        tbrg.raw$mm[as.numeric(tbrg.raw$dt.tm) %in% unlist(tmp)] <- NA
        write.csv(file=csv.out, tbrg.raw)
        print(paste("Finished processing NULL files for TBRG No.", num_tbrg_i, sep=" "))
        return(tbrg.raw)
    }else{
        write.csv(file=csv.out, tbrg.raw)
        print(paste("Logger",num_tbrg_i, "has no NULL files."))
        return(tbrg.raw)
    }
    print(paste("Finished processing NULL files for TBRG No.", num_tbrg_i, sep=" "))
}

## Function to replace the tbrg_aggreg.R
## input is tbrg.merged
## outputs in aggregated data saved to csv
## a panel of graphs at every aggregation

agg.data <- function(x){
    print(paste("Aggregating data for TBRG No.", num_tbrg_i, sep=" "))
    charvec <- x$dt.tm
    tbrg.mm <- subset(x, select=c("mm"))
    ts.tbrg <- timeSeries(data=tbrg.mm, charvec=charvec)
    start.ts.tbrg <- as.POSIXct("2012-08-15 00:00:00", tz = "Asia/Kolkata") # set start
    agg <- c("1 min","15 min", "30 min", "1 hour", "6 hour", "12 hour", "1 day", "15 day", "1 month")
    dat <- do.call("rbind", lapply(agg, function(y){
        csvout <- paste(csvdir, tbrgtab,"_", y, ".csv", sep="")
        by <- timeSequence(from=start.ts.tbrg, to=end(ts.tbrg),
                           by=y, FinCenter = "Asia/Calcutta")  
        dat <- aggregate(ts.tbrg, by, sum) 
        dat$dt.tm<-row.names(dat)
        dat <- as.data.frame(dat)
        row.names(dat) <- NULL
        dat$dt.tm<-  as.POSIXct(dat$dt.tm, tz="Asia/Kolkata", origin="1970-01-01",usetz=TRUE) # add timestamp back to datframe
        write.csv(dat, file=csvout)
        dat$dt <- as.Date(dat$dt.tm, "%Y-%m-%d")
        dat$agg <- y
        print(paste("Finished aggregating at", y))
        return(dat)
    }))
    ## plot
    dat$agg <- factor(dat$agg, levels = c("1 min", "15 min", "30 min", "1 hour", "6 hour", "12 hour", "1 day", "15 day", "1 month"))
    ## plot.new() # uncomment when running in non-mc mode
    tbrgplot <- ggplot( data = dat, aes( dt, mm )) + geom_line()  +
        facet_wrap(~agg, scales = "free_y") + ggtitle(tbrgtab) +
        labs(x="Date", y="Sum rainfall in mm") +
        theme(axis.title=element_text(size=10,face="bold"),
              axis.text=element_text(size=8))
    pngfile <- paste(figdir, tbrgtab, ".png", sep="")
    epsfile <- paste(figdir, tbrgtab, ".eps", sep="")
    pdffile <- paste(figdir, tbrgtab, ".pdf", sep="")
    ggsave(tbrgplot, filename=pngfile, width=397, height=210, units="mm")
    ggsave(tbrgplot, filename=epsfile, width=297, height=210, units="mm")
    ggsave(tbrgplot, filename=pdffile, width=297, height=210, units="mm")
    print(paste("Finished aggregating and plotting TBRG No.", num_tbrg_i, sep=" "))
    ## print(tbrgplot) # uncomment when running in non-mc mode
}


## indexing trick from <http://stackoverflow.com/questions/9950144/access-lapply-index-names-inside-fun>
control.funct <- function(x){
    ## lapply(seq_along(x), function(i){
    ##     num_tbrg_i <<-  names(x)[i]
    num_tbrg_i <<- x
    tbrgtab <<- paste("tbrg_", x, sep="")
    tbrgtab_raw<-paste("tbrg_", num_tbrg_i, "_raw", sep="")
    tbrgtab_pseudo<-paste("tbrg_", num_tbrg_i, "_pdeudo", sep="")
    tbrgdir<-paste(tbrgdatadir, tbrgtab, sep="/") # Directory holding all tbrg sub folders
    tbrgdir_null<-paste(tbrg_nulldatadir, tbrgtab, sep="/") # Directory holding all tbrg_null sub folders
    tbrgtab_null_all<<-paste(tbrgtab, "_null_all",sep="") # Directory holding all tbrg_null sub folders
    filelist <<- list.files(tbrgdir, pattern="\\.csv$|\\.dat$", ignore.case=TRUE, full.names=FALSE)
    filelist.full <<- list.files(tbrgdir, pattern="\\.csv$|\\.dat$" , ignore.case=TRUE, full.names=TRUE)
    filelist_null<<- list.files(tbrgdir_null, pattern="\\.csv$|\\.dat$" , ignore.case=TRUE, full.names=FALSE)
    filelist_null.full <<- list.files(tbrgdir_null, pattern="\\.csv$|\\.dat$", ignore.case=TRUE, full.names=TRUE)
    csv.out <<- paste(csvdir, tbrgtab, "_onemin.csv", sep="")
    ## source(paste(wkdir,"myfuncts.R", sep=""), echo=TRUE)
    tbrg.raw <<- import.tbrg(filelist.full, calibfile) # import data
    tbrg.merged <<- fill.null(filelist_null.full) # fill in nulls
    agg.data(tbrg.merged) # aggregate and plot
}
