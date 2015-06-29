##------------------   For the flume at WLR 003 and 003a at Aghnishini - note the data has been merged -------------------------#####
## Calculations based on Shrini's formula as below:
## Discharge, Q = 4969 * (H ^ 2.5)
## Q = m3/hour
## H = meters above the crest = [stage (in meters) – 0.47]
## pull in the results, and plot
csv.files <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/wlr/share", pattern=".csv", full.names=TRUE)
csv.filenames <-  list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/wlr/share/", pattern=".csv", full.names=FALSE)
file.names <- substrLeft(csv.filenames, 4)
for (i in 1: length(csv.files)){
    csv.file <- csv.files[i]
    png.filename <- paste(file.names[i], ".png", sep="")
    csv.filename <- paste(file.names[i], ".csv", sep="")
    data <- read.csv(csv.file)
    names(data) <- c("stage", "date_time")
    ## From Shrinivas Badiger's formula
    H <- (data$stage/100) - 0.47
    H[H<0] <- NA # remove all heights below 47cm (height of notch)
    data$dis.m3h <- 4969*((H)^2.5) # this formula needs checking
    data$dis.m3s <- 1.380278 * (H ^ 2.5) # converting to sec
    data$date_time <- as.POSIXct(data$date_time, tz="Asia/Kolkata")
    figdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/rating/fig/"
    figoutDisDate <- paste(figdir, "DischargeDate_", png.filename, sep="")
    figoutDisStg<-paste(figdir, "DischargeStage_", png.filename, sep="")
    figtitle <- paste("Stage Discharge Curve -- ", png.filename, sep="")
    png(filename=figoutDisStg, width=640, height=480, units="px", pointsize=12, type="cairo")
    plot(data$stage/100, data$discharge, type="p", main=figtitle, xlab="StageStage (m)",
         ylab="Discharge (m^3/hour)") 
    dev.off()
    png(filename=figoutDisDate, width=640, height=480, units="px", pointsize=12, type="cairo")
    plot(data$date_time, data$discharge, type="p", main=figtitle, xlab="Date",
         ylab="Stage (m)Discharge (m^3/hour)") 
    dev.off()

    csv.odir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/rating/csv/"
    csv.oname <- paste(csv.odir, csv.filename, sep="")
    write.csv(data, file=csv.oname)
    
}
