### Plot stage profile relationships to test for changes in bed profile



##-- 0. Date of data and level reading

## Date of data and level reading. This is to identify errors due to setting of the capacitance probes.
## Plot raw dates for three consecutive raw files along with the capacitance and stage readings (two scales).
## Sort raw files by date, read in header information for this and assign data to the header
library(ggplot2)
library(scales)
site <- "Nilgiris" ## OR site <- "Aghnashini"
## site <- "Aghnashini"
raw.dir <- paste("/home/udumbu/rsb/OngoingProjects/CWC/Data/", site, "/wlr/raw/", sep="")
dirlist <- list.dirs(path=raw.dir, recursive=FALSE, full.names=FALSE)
dirpath <-  list.dirs(path=raw.dir, recursive=FALSE)
for(i in 1:length(dirlist)){
    
    cat(paste("Started processing", dirlist[i], sep=" "), sep = "\n")
    
    fig.dir <- paste("/home/udumbu/rsb/OngoingProjects/CWC/Data/", site, "/wlr/check/", dirlist[i], "/", sep="")
    filelist <- list.files(path=dirpath[i], full.names=FALSE, pattern="*.csv$")
    filepath <- list.files(path=dirpath[i], full.names=TRUE, pattern="*.csv$")
    filename <- gsub(pattern=".csv", replacement="", ignore.case=TRUE, x=filelist)
    dat <- as.data.frame(matrix(nrow=0, ncol=7))
    names(dat) <- c("Sl", "Date", "Time", "Raw", "Calibrated", "FileName", "Timestamp")
    for(j in 1:length(filelist)){  ## 1:15){ ##
        rawdat <- read.csv(file=filepath[j], skip=8, header=FALSE)
        cat(paste("Reading file:", filelist[j], sep=" "), sep = "\n")
        ## rawdat <- rawdat[complete.cases(rawdat),]
        names(rawdat) <- c("Sl", "Date", "Time", "Raw", "Calibrated")
        rawdat$FileName <- filename[j]
        ## fix mixed up date formats before binding rows
        brk.date <- strsplit(as.character(rawdat$Date), split="/")
        brk.date <- head(brk.date[[2]])
        if(nchar(brk.date[1]) <4) {
            dt.format <- "%d/%m/%Y"} else {
                dt.format <- "%Y/%m/%d" }
        rawdat$Date <- as.Date(rawdat$Date, format=dt.format)
        rawdat<-transform(rawdat, Timestamp = paste(Date, Time, sep=' '))
        rawdat$Raw <- as.double(rawdat$Raw)
        rawdat$Calibrated <- as.double(rawdat$Calibrated)
        dat <- rbind(rawdat, dat)

    }
       ##  j <- j+1


        write.csv(file="~/tmp/datfile.csv", x=dat)
    
    ## organise data
    ## names(dat) <- c("Sl", "Date", "Time", "Raw", "Calibrated", "FileName", "Timestamp")
    
    dat$Date <- gsub(pattern="-", replacement="/", x=dat$Date) ## deal with incorrect formatting for Aghnashini dataset
    dat <- dat[!is.na(dat$Date),]
    dat <- dat[!is.na(dat$Raw),]
    dat <- dat[!is.na(dat$Calibrated),]
    
    dat$Timestamp<-as.POSIXct(dat$Timestamp, tz="Asia/Kolkata")
    dat <- dat[!duplicated(dat$Timestamp),]
    dat <- dat[order(dat$Timestamp),]
    head(dat)
    
    ## subset according to filename
    file.names <- unique(dat$FileName)
    no.iter <- as.integer(length(file.names)/3)
    for(k in 1:no.iter){
        ## k <- 1
        if (k==1){
            start.iter <- 1
        } else {
            start.iter <- k*3-3
        }
        end.iter <- k*3
        start.filename <- file.names[start.iter]
        end.filename <- file.names[end.iter]
        start.ts <- min(dat$Timestamp[dat$FileName==start.filename])
        end.ts <- max(dat$Timestamp[dat$FileName==end.filename])
        data <- subset(dat, Timestamp>=start.ts & Timestamp<=end.ts)
        plot.png <- paste(fig.dir, "from_", start.ts, "_to_", end.ts, ".png", sep="")
        
        ## Plot data
        ggplot(data=data, aes(x=Timestamp, y=Raw, color=factor(FileName))) +
            geom_line() +
                scale_x_datetime(breaks = "1 week", minor_breaks = "1 day", labels = date_format("%d-%b-%Y")) +
                    theme(legend.position="bottom", legend.text = element_text(size=10), axis.text.x=element_text(angle=90, vjust=0.5, size=8)) +
                        scale_colour_discrete(name  ="File Name:")
        ggsave(plot.png, width=297, height=210, units="mm")
    }
}


##-- 1. Stage vs total profile area
## cross-sectional area against stage in a particular interval where an interval is defined as between two successive downloads


##-- 2. Time versus Stage added to profile using a baseline profile and adding it to the base of the actual profile. The total area should be the same or very similar

##-- 3. Discharge versus area - unit area runoff. Should result in series of points sitting on top of one another.

##-- 4. Overlay prfile polygons so that they are centered and overlayed.
