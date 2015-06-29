## data.dir <- "E:/ATREE/Odyssey Data/SikkimHydrlogydata03April/KAS"
## data.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/raw"
csv.dir <- "E:/ATREE/Odyssey Data/SikkimHydrlogydata03April/KAS/csv/"
list.dirs <- dir(data.dir, full.names=TRUE)
list.dirname <- dir(data.dir, full.names=FALSE)
for (i in 1: length(list.dirs)){
    dirname <- list.dirname[i]
    filename <- paste(csv.dir, list.dirname[i], ".csv", sep="")
    file.list <- list.files(list.dirs[i], full.names=TRUE, include.dirs=FALSE)
    tmp <- as.data.frame(matrix(ncol = 3))
    for (j in 1:length(file.list)){
        tmpnew <- read.csv(file=file.list[j], skip=9, header=FALSE, strip.white = TRUE)
        tmp <- rbind(tmp, tmpnew)
    }
   
    source(nullroutine.R, echo=TRUE) 
    assign(dirname, tmp)
    write.csv(filename, get(dirname))
}
