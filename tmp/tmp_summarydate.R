## test for errors in tbrg logger data
library(svDialogs)
library(zoo)
dirname <- dlgDir(default = getwd(), title="Data Directory")$res
outcsv <- dlgSave(default = getwd(), title="Output File Name")$res
fldrnme <- list.files(dirname, full.names=TRUE, recursive=TRUE)
flnme <- list.files(dirname, recursive=TRUE)
for (i in 1:length(flnme)){
    csvtmp <- read.csv(fldrnme[i], header=FALSE, skip=0)
    dates <- as.Date(csvtmp$V1, "%m/%d/%y")
    datesfm <- format(dates, format="%d %b %Y")
    output <- c(min(datesfm), flnme[i]) 
    print(output)
    ## write.table(output, file=outcsv, row.names=FALSE, col.names=FALSE, append=TRUE)
}
