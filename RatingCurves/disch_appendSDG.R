## THIS FILE DOES NOT CALCULATE THE SDG VALUES FOR THAT GO TO DISCHARGE/SLUG.R
## take values for salt dilution gauging and bung them into the SD file
## script to take in SDG data and process it is called Slug.R and resides in the Discharge folder
## NEED TO TWEAK SO THAT NILGIRIS OR AGHNASHINI IS REPLACED BY SITE
srcdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/saltdilution/csv"
stn.name <- list.dirs(path="/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/saltdilution/raw",
                      full.names=FALSE, recursive=FALSE)
ratingdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/rating/csv"
disch.list <- list.files(path=ratingdir, full.names=TRUE, recursive=FALSE, pattern="SD.csv$")

src.files <- list.files(path=srcdir, full.names=TRUE, recursive=FALSE)
stn.no <- as.numeric(gsub("[^[:digit:] ]", "", disch.list))
for (i in 1: length(stn.no)){
    merge.files <- subset(src.files, subset=as.numeric(gsub("[^[:digit:] ]", "", src.files))==stn.no[i])
    tmp <- lapply(merge.files, read.csv)
    all.dat <- do.call("rbind", tmp)
    all.dat$station <- paste("wlr_", stn.no[i], sep="")
    all.dat$method <- "slug"
    all.dat <- subset(all.dat, select=c("station","file.names", "method", "Stage", "Discharge", "DateTime"))
    all.dat <- unique(all.dat)
    write.table(all.dat, file=disch.list[i], col.names=FALSE, append=TRUE, quote=FALSE, sep=",")
    cat(paste("SDG processing for stn.", stn.no[i], "completed.", sep=" "), sep="\n")
    rm(merge.files, tmp, all.dat)
}
                                       
