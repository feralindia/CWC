## Script to add a value to the capacitance units to fix the adjusted
## height of the wlr unit after September
## This is on account of new unit set up where the cable
## is attached to a hook via a plastic needle

## Create a vector of file names and adjustment

## function borrowed from <https://amywhiteheadresearch.wordpress.com/2013/05/13/combining-dataframes-when-the-columns-dont-match/>
rbind.all.columns <- function(x, y) {
    
    x.diff <- setdiff(colnames(x), colnames(y))
    y.diff <- setdiff(colnames(y), colnames(x))
    
    x[, c(as.character(y.diff))] <- NA
    
    y[, c(as.character(x.diff))] <- NA
    
    return(rbind(x, y))
}

tofix.fldr <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/after_sep2016_raw/"
tofix.data <- read.csv("~/OngoingProjects/CWC/Data/Nilgiris/wlr/nilgiri_wlr_adjustment.csv")
tofix.dirs <- list.files(tofix.fldr)
tofix.dirs.full <- list.dirs(tofix.fldr, full.names=TRUE, recursive=FALSE)
tofix.dirs.short <- list.dirs(tofix.fldr, full.names=FALSE, recursive=FALSE)
for(i in 1:length(tofix.dirs.short)){
    adj <- tofix.data$adjustment[match(tofix.dirs.short[i] ,tofix.data$st_no)]
    adj[is.na(adj)] <- 0 ## if no adjustment is required
    flst <- list.files(tofix.dirs.full[i], full.names = FALSE)
    flst.full <- list.files(tofix.dirs.full[i], full.names = TRUE)
    for(j in 1:length(flst)){
        tmp.head <- head(read.csv2(flst.full[j],header=F, fill=FALSE, blank.lines.skip=FALSE, as.is=TRUE), n=9)
        tmp.dat <- read.csv(flst.full[j], header=F, skip=9)
        tmp.dat$V4 <- tmp.dat$V4+adj
        tmp.all <- rbind.all.columns(tmp.head, tmp.dat)
        names(tmp.all) <- NULL
        fixed.file <- gsub(pattern="raw", replacement="fixed", x=flst.full[j])
        write.csv(x=tmp.all, file=fixed.file, row.names=FALSE, quote=FALSE, na="")
    }
}

