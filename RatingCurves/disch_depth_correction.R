## Correct the values of the raw files before 18th Dec.2013
## to reflect the velocities at 60% of stream depth from top
## as opposed to 60% of depth from bottom which was being done till now

##------initialise------#
library(stringr) # to manipulate strings

##------list files to be worked on------##
site <- c("Nilgiris/", "Aghnashini/")
site.nm <- c("Nilgiris", "Aghnashini")
dat.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/"
err.pyg.dir <- paste(dat.dir, site, "rating/errpyg", sep="") # note removed backslash
res.pyg.dir <- paste(dat.dir, site, "rating/pyg/", sep="")
##------list files in each directory-----##
for (i in 1:length(site.nm)){
    err.dir.list <- dir(path = err.pyg.dir[i], full.names = TRUE, no.. = FALSE)
    res.dir.list <- res.pyg.dir[i]
    err.dir <- dir(path = err.pyg.dir[i], full.names = FALSE)
    for (j in 1: length(err.dir)){
        ## err.files <- err.dir[j]
        res.files <- err.dir[j]
        err.files <- list.files(path=err.dir.list[j])
        res.folder <- paste(res.dir.list, res.files, sep="")
        for (k in 1:length(err.files)){
            err.file <- paste(err.dir.list[j],"/", err.files[k], sep="") 
            res.file <- paste(res.folder,"/", err.files[k], sep="")
            disch <- read.csv(file=err.file, header = T, skip=5)
            v04 <- disch$Measure_60pc
            d04 <- disch$Depth
            for (l in 1:length(v04)){
                v04t <- v04[l]
                d04t <- d04[l]
                D <- d04t/0.4 # actual depth
                d06t <- D*0.6
                corr <- log(D-d06t)/log(D-d04t)
                v06t <- corr*v04t
                disch$Measure_60pc[l] <- v06t
            }
            dir.create(res.folder, showWarnings = FALSE)
            ## Read the first 5 lines from the original file and re-write them
            hdr <- readLines(file.path(err.file), n=5)
            writeLines(hdr, res.file)
            write.table(disch, file=res.file, sep=",",
                        quote=FALSE, append=TRUE, row.names = FALSE)
        }
    }
}
  
