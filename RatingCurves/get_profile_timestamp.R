## Get the timestamp for a given filename
wkdir <- "./"
setwd(wkdir)
cxdir.list <- list.dirs(cxdir.loc, full.names=FALSE, recursive=FALSE)
## get new areas
for (i in 1:length(pyg.name)){
    cxrect <- read.csv(file=paste(cxfix.dr, pyg.name, sep="/"))
    for (j in 1: nrow(cxarea)){
        
