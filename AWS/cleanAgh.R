## Fixes the data in Aghnashini AWS where there are some missing columns.
## Also rewrites the column name so it is not spread across two rows

folder.loc <- "/media/rsb/rsb_work/aws/saimane/"
file.names <- list.files(folder.loc, full.names = FALSE)
full.file.names <- list.files(folder.loc, full.names = TRUE)

fix.header <- function(x){
    raw.file <- read.csv(x, sep = "\t", header=FALSE)
    names.raw.file <- trimws(paste(unlist(raw.file[1,]), unlist(raw.file[2,])))
    raw.file <- raw.file[c(-1,-2),]
    names(raw.file) <- names.raw.file
    return(raw.file)
}


fixed.fileheaders <- lapply(full.file.names, fix.header)
names(fixed.fileheaders) <- file.names


## insert missing columns

fixed.names.file <- fix.header("~/tmp/names.csv") ## get in the names from a file

nms <- names(fixed.names.file) # complete set of names

## From <http://stackoverflow.com/questions/9236992/r-find-missing-columns-add-to-data-frame-if-missing>

fix.missing <- function(x,nms){
    missing.nms <- setdiff(nms, names(x)) # Find names of missing columns
    x[missing.nms] <- "---"                    # Add them, filled with '0's
    x <- x[nms]                    
    return(x)
}

tmp <- lapply(fixed.fileheaders, FUN=fix.missing, nms=nms)


fixed.full.file.names <- gsub(full.file.names, pattern = ".txt", replacement=".csv")

mapply(write.csv, file=fixed.full.file.names, x=tmp)
