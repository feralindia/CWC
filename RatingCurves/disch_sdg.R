## THIS FILE DOES NOT CALCULATE THE SDG VALUES FOR THAT GO TO DISCHARGE/SLUG.R
## take values for salt dilution gauging and bung them into the SD file
## script to eventually take in SDG data and process it

#mergecsv <- function(srcdir, destdir){
srcdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/rating/saltdilution/raw"
destdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/rating/saltdilution/csv/"

ratingdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/rating/csv"
disch.list <- list.files(path=ratingdir, full.names=TRUE, recursive=FALSE, pattern="SD.csv$")

src.list <- list.dirs(path=srcdir, full.names=TRUE, recursive=FALSE)
stn.name <- list.dirs(path=srcdir, full.names=FALSE, recursive=FALSE)
dest.list <- list.dirs(path=srcdir, full.names=FALSE, recursive=FALSE)
for(i in 1:length(src.list)){
    cat(paste("Processing files for folder:", stn.name[i], sep=" "), sep="\n")
    stn <- src.list[i]
    dest.flnm <- paste(destdir, dest.list[i], ".csv", sep="")
    file.list <- list.files(path=stn, full.names=TRUE, ignore.case=TRUE)
    cols <- ncol(read.csv(file.list[1]))
    names <- names(read.csv(file.list[1]))
    stn.data <- as.data.frame(matrix(nrow=0, ncol=cols))
    names(stn.data) <- names
    for(j in 1: length(file.list)){
        flnm <- file.list[j]
        stn.data <- rbind(read.csv(flnm), stn.data)
    }
    ## basic duplicate checking
    stn.data <- unique(stn.data)
    write.csv(file=dest.flnm, stn.data)
}

## proceed to merge the results with pyg and flt
## ensure that the stations for input and output match
disch.stns <- as.numeric(gsub("[^[:digit:] ]", "", disch.list))
dest.stns <- as.numeric(gsub("[^[:digit:] ]", "", dest.list))
## disch.stns==dest.stns
for (k in 1: length(disch.stns)){
    sdg.in <- read.csv(paste(destdir,"wlr_", disch.stns[k], ".csv", sep=""))
    sdg.in$station <- paste("wlr_", disch.stns[k], sep="")
    sdg.in$filename <- paste("wlr_", disch.stns[k], ".csv", sep="")
    sdg.in <- subset(sdg.in, select=c("station","filename", "method", "stage", "discharge"))
    write.table(sdg.in, file=disch.list[k], col.names=FALSE, append=TRUE, quote=FALSE, sep=",")
    cat(paste("SDG processing for stn.", dest.stns[k], "completed.", sep=" "), sep="\n")
}
