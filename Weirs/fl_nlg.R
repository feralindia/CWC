##-- calculate discharge from flumes and weirs in the nilgiris
##-- wlr ids are used as ids for fulmes as well

##-- name files and folders
wlr.dirname <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/csv"
wlr.files <- list.files(wlr.dirname, full.names=TRUE, pattern="onemin.merged.csv")
multi.wlr <- substr(wlr.files, start=60, stop=62)[duplicated(substr(wlr.files, start=0, stop=62))]
for (i in 1:length(multi.wlr)){
    tmp <- list.files(wlr.dirname, full.names=TRUE, pattern=multi.wlr[i])
    tmp <- tmp[grep("onemin.merged", tmp)]
    tmp.mat <- as.data.frame(matrix(ncol = 3))
    names(tmp.mat) <- c("raw","cal","date_time")
    for (j in 1: length(tmp)){
        ## assign(read.csv(tmp[j]), multi.wlr[i])
        tmp.mat <- rbind(read.csv(tmp[j]), tmp.mat)
    }
    merged.stage <- paste("merged_stages_wlr",multi.wlr[i], sep="")
    assign(merged.stage, tmp.mat)
    rm(tmp, tmp.mat)
}
merged.stage
