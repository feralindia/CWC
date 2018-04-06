## This routine is called by the rc_nlg, rc_agn and disch.R scripts
## Updated 16 feb 2016
## correct station name attribute 
## THIS FILE DOES NOT CALCULATE THE SDG VALUES FOR THAT GO TO DISCHARGE/SLUG.R
## take values for salt dilution gauging and bung them into the SD file
## script to take in SDG data and process it is called Slug.R and resides in the Discharge folder

srcdir <- paste("/home/udumbu/rsb/Res/CWC/Data/", site, "/saltdilution/csv", sep="")
rawdir <- paste("/home/udumbu/rsb/Res/CWC/Data/", site, "/saltdilution/raw", sep="")
stn.name <- list.dirs(path=rawdir, full.names=FALSE, recursive=FALSE)
ratingdir <- paste("/home/udumbu/rsb/Res/CWC/Data/", site, "/rating/csv", sep="")
disch.list <- list.files(path=ratingdir, full.names=TRUE, recursive=FALSE, pattern="SD.csv$")

src.files <- list.files(path=srcdir, full.names=TRUE, recursive=FALSE)
stn.no <- as.numeric(gsub("[^[:digit:] ]", "", disch.list))
for (i in 1: length(stn.no)){
    merge.files <- subset(src.files, subset=as.numeric(gsub("[^[:digit:] ]", "", src.files))==stn.no[i])
    tmp <- lapply(merge.files, read.csv)
    tmp.stn.name <-  strsplit(merge.files, split="/")
    for (j in 1: length(tmp.stn.name)){
    tmp[[j]]$station <- gsub(pattern = ".csv", replacement="", tail(tmp.stn.name[[j]],n=1))
    } ## get station name
    all.dat <- do.call("rbind", tmp)
    ## all.dat$station <- paste("wlr_", stn.no[i], sep="")
    all.dat$DateTime <- as.POSIXct(all.dat$DateTime)
    all.dat$method <- "slug"
    all.dat <- subset(all.dat, select=c("station","file.names", "method", "Stage", "Discharge", "DateTime"))
    all.dat <- unique(all.dat)
    write.table(all.dat, file=disch.list[i], col.names=FALSE, append=TRUE, quote=FALSE, sep=",")
    cat(paste("SDG processing for stn.", stn.no[i], "completed.", sep=" "), sep="\n")
    rm(merge.files, tmp, all.dat)
}
                                       
