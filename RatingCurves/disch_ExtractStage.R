## Extract the stage for a given WLR given the data and time of
## the stream profile and put in csv file and r object
## Need to run separately for nilgiris and aghnashini as different
## date formats have been used.
ts.cx <- as.data.frame(matrix(ncol = 5))
names(ts.cx) <- c("site", "stn", "type","dt", "tm")
ts.cxall <- as.data.frame(matrix(ncol = 5))
names(ts.cxall) <- c("site", "stn", "type","dt", "tm")
##--- read in csv files from pyg and flt ---##
## disch.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/rating/"
## pyg.dirs <- list.dirs(paste(disch.dr, "cx_pyg", sep=""), recursive=FALSE)
## flt.dirs <- list.dirs(paste(disch.dr, "cx_flt", sep=""), recursive=FALSE)
## loc.dirs <- c(pyg.dirs, flt.dirs)
type <- c("cx_pyg", "cx_flt")
for (j in 1: length(type)){
    loc.dirs <-  list.dirs(paste(disch.dr, type[j], sep=""), recursive=FALSE)
    for (k in 1:length(loc.dirs)){
        cx.files <- list.files(loc.dirs[k], pattern="csv$", ignore.case=TRUE, include.dirs=FALSE, full.names=TRUE)
        
        for (l in 1: length(cx.files)){
            cxt <- read.csv(cx.files[l], header=FALSE)
            ts.cx$site <- site
            ts.cx$stn <- cxt[4,2, drop=TRUE]
            ts.cx$type <- type[j]
            ts.cx$dt  <- cxt[2,2, drop=TRUE]
            ts.cx$tm  <- cxt[3,2, drop=TRUE]
            ts.cxall <- rbind(ts.cxall, ts.cx)
        }
        ts.cxall <- ts.cxall[complete.cases(ts.cxall),] ## remove blank rows
    }
}
## ts.cxall <- ts.cxall[complete.cases(ts.cxall),]
ts.cxall$stn <- tolower(ts.cxall$stn) ## change to lower
ts.cxall$dt <- as.Date(ts.cxall$dt, format="%d/%m/%y")
ts.cxall<-transform(ts.cxall, dt.tm = paste(dt, tm, sep=' '))
ts.cxall$dt.tm<-as.POSIXct(ts.cxall$dt.tm, format="%Y-%m-%d %I:%M:%S %p")

    for (m in 1: length(stn.dir)){
        ts.cx$stn <- tolower(ts.cx$stn) ## changed case 
        ts.cx.stn <- subset(ts.cxall, stn==stn.id[m])
        stn.file <- paste(wlr.dir, oneminfile[m], sep="")
        stn.csv <- read.csv(stn.file)
        stn.csv$date_time<-as.POSIXct(stn.csv$date_time)
        stn.csv <- subset(stn.csv, select=c("raw", "cal", "date_time"))
        names(stn.csv) <- c("raw", "cal", "dt.tm")
        tmp.ext <- merge(stn.csv, ts.cx.stn, by="dt.tm", all=FALSE)
        tmp.ext <-  tmp.ext[!duplicated(tmp.ext), ]
        stn.obj <- paste(stn.id[m], ".stage", sep="")
        assign(stn.obj, tmp.ext)
        stage.file <- paste(disch.dr, "stage/", disch.stn.name[m], sep="")
        write.table(tmp.ext, file=stage.file, append=TRUE)  ## overwrites older file
    }
##}
## rm(ts.cx, ts.cxall, type, loc.dirs, cx.files, cxt, wlr.dir, stn.dir, stn.name,  disch.stn.name, oneminfile, ts.cx.stn, stn.file, stn.csv, tmp.ext, stn.obj, stage.file)
