#This works, I have not done the input dir and output dir. Please add if you think it is useful
library(plyr)
filenames <- list.files(path = "/media/data/sriniworking/feral/MoES_NERC/temp/sample_tbrg_dat/", pattern = NULL, all.files = FALSE, full.names = F, recursive =T, ignore.case = FALSE)
import.list <- llply(filenames, read.csv)
read_csv_filename <- function(filename){
  ret <- read.csv(filename,  header=FALSE, skip=0, sep=",")
  ret$Source <- filename #EDIT
  ret$V1 <- as.Date(ret$V1, "%m/%d/%y")
  ret$V1 <- format(ret$V1, format="%d %b %Y")
  ret$checked<-"yes"
  names(ret) <- c("date", "time", "tip", "filename","checked")
  ret
}
import.list <- ldply(filenames, read_csv_filename)
output <- ddply(import.list, .(filename, checked), summarise, min = min(date, na.rm = TRUE)) 
write.csv(output, "/media/data/sriniworking/feral/MoES_NERC/temp/sample_tbrg_dat/out.csv", row.names=F)
