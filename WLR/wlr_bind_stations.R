## This script binds the wlr stations into asingle file

in.files <- list.files(csvdir, pattern=".merged.csv$", full.names=TRUE, include.dirs=FALSE)

in.stn <- as.numeric(gsub("[^[:digit:] ]", "", in.files))
unique.stns <- unique(in.stn)
merge.tmp <- as.data.frame(matrix(nrow=0,ncol=3))
for(i in 1:length(unique.stns)){
    sel.stn <- in.files[in.stn==unique.stns[i]]
    merged.file <- paste(csvdir, "merged_station_", unique.stns[i], ".csv", sep="")
    for(j in 1: length(sel.stn)){
        tmp <- read.csv(file=sel.stn[j], header=TRUE)
        merge.tmp <- rbind(merge.tmp, tmp)
    }
    names(merge.tmp) <- c("Capacitance", "Stage", "Timestamp")
    write.csv(file=merged.file, x=merge.tmp)
}
