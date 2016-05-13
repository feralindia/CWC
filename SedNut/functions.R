## this files contains the functions needed for the processing of sediment and nutrient data

##-- Get discharge filename
## generate the relevant filename for each time stamp in the sediment nutrient discharge
## dataset so as to optimise

## x is filename to be assigned, y is full path and filename to be read, rn is row name
read.csv.files <- function(x,y){
    assign(x, read.csv(y))
    x <- get(x)
    return(x)
}

read.merge.data <- function(stn.list){
    for (i in 1: length(stn.list)){ ## HEREH
        subset(merged.flnm, subset=dis.stn==stn.list)
        x <- eval(parse(text = paste("all.sed.data$", merged.flnm$int.samp.flnm[i], sep="")))
        x$date <- as.Date(x$date, format="%d/%m/%Y")
        x$Timestamp <- as.POSIXct(paste(x$date, x$time, sep=" "), tz="Asia/Kolkata")
        x$Timestamp <- round(x$Timestamp, "mins")
        x$time.num <- as.numeric(x$Timestamp)
        y <- eval(parse(text = paste("all.dis.data$", merged.flnm$dis.flnm[i], sep="")))
        y$Timestamp <- as.POSIXct(y$Timestamp, tz="Asia/Kolkata")
        y$time.num <- as.numeric(y$Timestamp)
        xy <- merge(x, y, by = "time.num", all=TRUE)
        data.exists <- xy[complete.cases(xy[,c(4,20)]),]
        if(nrow(data.exists)>0){
            out.name <- as.character(merged.flnm$int.samp.flnm[i])
            assign(out.name, xy)## (return(xy))
            out.name <- get(out.name)
            return(out.name)
        }
    }
}
