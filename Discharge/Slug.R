## Script modified from original written by Jagdish K and Vivek R.

src.dirs <- list.dirs(path="/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/saltdilution/raw", recursive=FALSE)
stn.name <- list.dirs(path="/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/saltdilution/raw", full.names=FALSE, recursive=FALSE)
wlr.csvdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
dest.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/saltdilution/"
rating.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/rating/csv"
disch.list <- list.files(path=rating.dir, full.names=TRUE, recursive=FALSE, pattern="SD.csv$")
fig.dir <- paste(dest.dir, "fig", sep="")
csv.dir <- paste(dest.dir, "csv", sep="")

## reading all files from the diectory##
for(h in 1:length(src.dirs)){  ## note the numbers
    file.paths <- list.files(path=src.dirs[h], recursive=TRUE, pattern="*.csv", full.names=TRUE)
    file.names <- list.files(path=src.dirs[h], recursive=TRUE, pattern="*.csv") 
    cat(paste("Processing station: ",stn.name[h], sep=""), sep="\n")
    
    ## Extract the stage from the relevant wlr logger
    stn.no <- substr(stn.name[h], start=5, stop=nchar(stn.name[h]))
    wlr.log <- paste(wlr.csvdir, stn.no, "_onemin.merged.csv", sep="")
    stage.dat <- read.csv(wlr.log)
    stage.dat$date_time <- as.POSIXct(stage.dat$date_time, tz="Asia/Kolkata")
    ##    read in the files
    for (n in 1:length(file.names)) assign(file.names[n], read.csv(file.paths[n]))

    salt <- function(x){
        {
            ##    Extract data and time from file
            lst <- get(x)
            dt <- as.Date(lst[2,2], format="%d/%m/%Y")
            tm <- lst[3,2]
            dt.tm <- paste(dt,tm)
            dt.tm <- as.POSIXct(dt.tm, tz="Asia/Kolkata")
            stage <- as.numeric(subset(stage.dat, select=c(cal,date_time),
                                       subset=stage.dat$date_time==dt.tm))
            if(any(is.na(stage))){stop(paste("There is no stage value for the timestamp on the slug.\n  Remove the slug file:", x, sep=" "))}
            standardgm <- as.numeric(as.character((lst[10,2])))
            saltgm <- as.numeric(as.character((lst[9,2])))
            salt <- c(stage,standardgm, saltgm)
        }
        return(salt)
    }

    salt <- lapply(file.names, FUN=salt)
    rm(stage.dat) ## clean up after running the function
    salt.df <- data.frame(matrix(unlist(salt), nrow=length(salt), byrow=T),stringsAsFactors=FALSE)
    names(salt.df) <- c("Stage", "DateTime", "Standardgm", "Saltgm")
    data <- NULL
        for (j in 1:length(file.paths))
        {
            dataraw<- read.csv(file.paths[j],skip=12, stringsAsFactors = F) ## for new raw format
            salt.dat <- unlist(salt.df[j,])
            dat.lst <- c(dataraw,salt.dat)
            data2 <- lapply(as.list(dat.lst), function(x){x[!is.na(x)]})
            data <- c(data, list(data2))
        }
    dataList <- data
    
    discharge <- NULL
    Std.gm <- NULL
    Salt.gm <- NULL
    Stage.cm <- NULL
    Date.Time <- NULL
    ret <- as.data.frame(matrix(nrow=length(dataList), ncol=5))
    names(ret) <- c("Discharge", "Standard", "Salt", "Stage", "DateTime")
    SaltSluginjection <- function(data=dataList){
        for(k in 1:length(dataList)){
            Standardgm <- dataList[[k]]$Standardgm
            Saltgm <- dataList[[k]]$Saltgm
            Stage <- dataList[[k]]$Stage
            DateTime <- dataList[[k]]$DateTime
            calib.cnt <- length(dataList[[k]]$EC.Calib) ## number of calibrations readings
            conc <- function(conc){
                conc<-seq(0,0,calib.cnt)
                for(l in 1: (calib.cnt)){
                    m <- l-1
                    if(l==1){conc[l]<-0/980
                    }else{
                    conc[l]<-(Standardgm*m*10*1000)/(980+(m*10))}
                }
                return(conc)
            }
            conc <- conc(calib.cnt)
            mod1<-lm(conc~dataList[[k]]$EC.Calib)
            cnst<-mod1$coef[2]
            ec0<-dataList[[k]]$EC.SDG[1]
            discharge[k]<-Saltgm/(sum((dataList[[k]]$EC.SDG-ec0)*5*cnst))
            Std.gm[k] <- Standardgm
            Salt.gm[k] <- Saltgm
            Stage.cm[k] <- Stage
            Date.Time[k] <- DateTime
            ret[k,] <- c(discharge[k], Std.gm[k], Salt.gm[k], Stage.cm[k], Date.Time[k])
        }
        return(ret)
    }

    Discharge <- SaltSluginjection(dataList)
    Discharge$DateTime <- as.POSIXct(Discharge$DateTime, origin="1970-01-01", tz="Asia/Kolkata")

    ##For time-series EC-plots for each trial##
    png.file <- paste(fig.dir, "/",stn.name[h],"-ECplot.png", sep="")
    png(png.file,width=11,height=8, units="in", res=100)
    n.col <- trunc((length(file.names)+2)/3)
    par(mfcol=c(3,n.col))
    for(i in 1:length(dataList)){
        mn <- paste(stn.name[h], file.names[i], sep="\n")
        plot.ts(dataList[[i]]$EC.SDG, main=mn, sub=Discharge[i,1], xlab = "Time", ylab = "Electrical Conductivity")
    }
    dev.off()
    
    ##creating a data frame and file for further analysis##
    Output <- data.frame(file.names,Discharge)
    res.out <- paste(csv.dir,"/", stn.name[h], ".csv", sep="")
    write.csv(Output,res.out,row.names=FALSE,quote=FALSE)


    ## plot using ggplot2
    library(ggplot2)
    timestamp <- as.POSIXct(Discharge$DateTime, origin="1970-01-01", tz="Asia/Kolkata")
    sd.plot <- ggplot(data = Discharge, aes(Stage, Discharge, label=as.Date(as.POSIXct(timestamp, origin="1970-01-01")))) + 
        geom_point(aes(position="jitter")) +
            geom_text(size=3,angle = 45, position="jitter") +
            ggtitle(stn.name[h]) + labs(x = "Stage (m)", y = "Discharge (m3/s)") +
                theme(axis.title=element_text(size=14,face="bold"),
                      axis.text=element_text(size=12))
   sd.plot
    png.file <- paste(fig.dir, "/",stn.name[h],"-SDplot.png", sep="")
    ggsave(sd.plot, filename=png.file, width=12, height=8, units="in",dpi=300)



}

    rm(list=ls())  ## clean up memory
