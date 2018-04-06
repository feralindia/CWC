## Import raw data, bind and add NAs to missing timestamps for specified time period
## Also fixes the !@#$%^&* errors with the dates and months being mixed up!
## Uses the fact that the variance of days is higher than of months in a give period
## rounds of data into multiples of 5 minutes to facilitate merging with other datasets
## inputs, x: raw directory home, st.tmstmp: start timestamp, fin.tmstmp: finish timestamp.


## generic function to fill NA for missing timestamps
## called by other import functions

fill.na <- function(y){
    y$Timestamp <- as.POSIXct(y$Timestamp, tz = "Asia/Kolkata")
    y.st <- min(y$Timestamp, na.rm =TRUE)
    y.end <- max(y$Timestamp, na.rm =TRUE)
    if((y.end-y.st)>1){
        y.seq <- seq(from=y.st, to=y.end, by="15 min") # interval for hygrochrons is 15min
        y <- y[match(as.numeric(y.seq), as.numeric(y$Timestamp)),] # try using %in%
        y$Timestamp <- y.seq
    }
    return(y)
}


## fix the date/month mixup
fix.daymon <- function(x){
    tmp <- read.csv(x, skip = 20, header = FALSE)
    timestamp <- as.character(tmp[,1])
    time.split <- do.call("rbind", strsplit(timestamp, split="/"))
    ## if(max(time.split[,2]>12))time.split <- time.split[,c(2,1,3)]
    if(var(time.split[,2], na.rm=TRUE) > var(time.split[,1], na.rm=TRUE)) time.split <- time.split[,c(2,1,3)] # use variance
    tmp[,1] <- apply(time.split[ , c(1, 2, 3)], 1, paste, collapse = "/")
    return(tmp)       
}

import.hygch <- function(x, y){ #, st, fin
    fn <- list.files(x, full.names=TRUE, no.. = TRUE)
    tmp <- do.call("rbind", lapply(fn, fix.daymon))
    names(tmp) <- c("Timestamp", "Unit", "Value")
    tmp$Timestamp <- as.POSIXct(tmp$Timestamp, tz = "Asia/Kolkata", format = "%d/%m/%y %I:%M:%S %p")
    ## tmp <- tmp[, (tmp$Timestamp > st  & tmp$Timestamp < fin)] # subset by st and fin dates
    ## tmp <- subset(tmp, subset=Timestamp > st & Timestamp < fin) #processing all data
    tmp$numtime <- as.numeric(tmp$Timestamp)
    tmp$numtime <- round((tmp$numtime)/900) * 900 # round to 15 min or 900 secs
    tmp$Timestamp <- as.POSIXct(tmp$numtime,
                                origin = "1970-01-01", tz = "Asia/Kolkata")
    tmp <- fill.na(tmp) # fill NAs for missing timestamps
    assign(y, tmp, inherits=TRUE)
    print(paste("Finished importing", y))
    return(tmp)
}

## merge the raw temperature and humidity data into a three column
## dataframe containing only timestamp, temperature and humidity
 merge.bs.tabs <- function(x, y){# , names
        res <- merge(x, y, by="Timestamp", all=TRUE)
        res <- subset(res, select=c("Timestamp", "Value.x", "Value.y"))
        colnames(res) <- c("Timestamp", "temp", "humi")
        res <- res[complete.cases(res),]
        ## names(res) <- names
        return(res)
 }

agr <- function(ag, t.s, s.q){
    tmp <- as.data.frame(timeSeries::aggregate(t.s, s.q, ag, na.rm = TRUE))
    tmp$Timestamp <- round.POSIXt(as.POSIXct(row.names(tmp), tz = "Asia/Kolkata"), "day")
    tmp$numtime <- as.numeric(tmp$Timestamp)
    return(tmp)
}

## Aggregation MUST start at the 1st of June 2012 for
## weekly and monthly aggreations to make sense
## prd has to be under 1 day
## aggregate has different calls for weekly and monthly

aggregate.by <- function(x, prd){
    dat <- as.data.frame(x)
    ## names(dat) <- c("Timestamp", "t", "rh")
    daily.ts <- timeSeries(data = dat$Value, charvec = dat$Timestamp, zone="Asia/Calcutta")
    by.seq <- timeSequence(from = as.POSIXct("2012-06-01", tz = "Asia/Kolkata") , to = round(end(daily.ts), "day"), by = prd) #round(start(daily.ts), "day")
    ag <- c("min", "max", "mean", "median")
    tmp <- do.call("cbind", lapply(ag, FUN = agr, s.q = by.seq, t.s = daily.ts))
    tmp <- tmp[,c(1, 4, 7, 10)]
    colnames(tmp) <- ag
    tmp$Timestamp <- as.POSIXct(rownames(tmp), tz = "Asia/Kolkata")
    rownames(tmp) <- NULL
    return(tmp)
}

## merge the raw temperature and humidity data into a three column
## dataframe containing only timestamp, temperature and humidity
 merge.bs.agg <- function(x, y){ # , names
        res <- merge(x, y, by="Timestamp", all=TRUE)
        res <- subset(res, select=c("Timestamp", "min.x", "max.x" ,"mean.x", "median.x", "min.y", "max.y", "mean.y", "median.y" ))
        colnames(res) <- c("Timestamp", "min.t", "max.t" ,"mean.t", "median.t", "min.rh", "max.rh", "mean.rh", "median.rh" )
        res <- res[complete.cases(res),]
        # names(res) <- names
        return(res)
 }

## Plot and save data
plot.save <- function(x, hyg.no, parm){

    ## names
    hyg.nm <- gsub(" |no\\:", "", hyg.no)
    fn.png <- paste0(hyg.res.path, "/",  hyg.nm, parm, ".png" )
    fn.csv <- paste0(hyg.res.path, "/",  hyg.nm, parm, ".csv" )
    
    gg.x <- melt(x, id.vars="Timestamp", measure.vars=c("min", "max", "mean", "median"),
                 variable.name="aggregation", value.name="value")
    gg.x$Timestamp <- as.POSIXct(gg.x$Timestamp, tz="Asia/Kolkata")
    gg.x$dt <- as.Date(gg.x$Timestamp, format="%d-%b-%Y")
    gg.x$year <- format(as.POSIXct(x$Timestamp, tz="Asia/Kolkata"), format="%Y")
    gg.x$doy <- as.numeric(format(gg.x$Timestamp, "%j"))
    lab.y <- paste("Daily", parm)
    ## plot
    ggp <- ggplot( data = gg.x, aes(x=doy, y=value, color=aggregation)) +
        geom_line(size=1)+
        facet_grid(facets = year ~ .) +
        ## scale_x_date(labels = date_format("%d-%b")) +
        scale_x_continuous(labels = function(x)
            format(as.Date(as.character(x), "%j"), "%b"), breaks =seq(1, 365, 31)) +
            ## format(as.Date(as.character(x), "%j"), "%d-%b")) +
        labs(x="Date", y= lab.y, color="Statistic", title = hyg.no) +
        theme_light()+
        theme(axis.title=element_text(size=10,face="bold"),
              axis.text=element_text(size=8),
              axis.text.x=element_text(angle=90, vjust=0.5, size=8),
              panel.background = element_rect(fill = "transparent",colour = NA),
              legend.background = element_rect(fill = "transparent",colour = NA),
              plot.background = element_rect(fill = "transparent",colour = NA)
              )
    ggsave(filename = fn.png, ggp, dpi = 100)

    ## Organise for csv out
    dat.out <- x[,c(5, 1, 2, 3, 4)]
    names(dat.out) <- c("Timestamp", "Minimum", "Maximum", "Mean", "Median")
    write.csv(file = fn.csv, dat.out)
}


## UNDER PREP
## HERE

## Aggregate monthly or weekly
## x is data,
## y is one of c("min", "max", "mean", "median")
## z is one of c("monthly", "weekly")
m.w.ag <- function(x, y, z){
    ## x <- na.omit(x)
    x$Timestamp <- as.POSIXct(x$Timestamp, tz="Asia/Kolkata")
    start.date <- as.POSIXct("2012-06-01", tz="Asia/Kolkata")
    end.date <- as.POSIXct("2016-08-31", tz="Asia/Kolkata")
    date.seq <- seq.POSIXt(start.date, end.date,by="1 day",na.rm=TRUE)
    missing.dates <- date.seq[!(as.numeric(date.seq) %in% as.numeric(x$Timestamp))]
    tmp <- as.data.frame(lapply(x, function(y) rep.int(NA, length(missing.dates))))
    tmp$Timestamp <- missing.dates
    x <- rbind(x, tmp)
    
    x$Timestamp <- round(as.POSIXct(x$Timestamp, tz = "Asia/Kolkata"), "day")
    ts.obj <- timeSeries(data = x[y], charvec = x$Timestamp, zone = "Asia/Calcutta")
    out <- if(z == "monthly")
               daily2monthly(x = ts.obj) # gives subscript out of bounds error
    out <- if(z == "weekly") daily2weekly(x = ts.obj)
}
