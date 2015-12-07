## Take rating curves from all wlrs and convert to discharge for each wlr unit
## list wlr units measuring stage from streams (not weirs or flumes)
## NEED TO ENSURE ALL DATA IS OUTPUT TO THE /DISCHARGE/STN/ FOLDER
library(ggplot2) # for plotting
library(scales) ## for manipulating dates on ggplot2
library("reshape2")

site <- "Nilgiris"

data.dir <- paste("/home/udumbu/rsb/OngoingProjects/CWC/Data", site, sep="/")
StnType <- read.csv(file=paste(data.dir, "/discharge/StnType.csv", sep=""))
fig.dir <- paste(data.dir, "/discharge/fig/", sep="")

for(i in 1:nrow(StnType)){
    
    if(StnType$type[i]=="flume"){
        pat <- as.character(StnType$unit_no[i])
        wlr.flst <- list.files(path=paste(data.dir,"/wlr/csv", sep=""),
                               pattern=pat, full.names=TRUE)
        for(j in 1:length(wlr.flst)){
            wlr.dat <- read.csv(wlr.flst[j])
            names(wlr.dat)[3] <- "Stage"
            wlr.dat$Discharge <-  0.1771 * (wlr.dat$Stage^1.55)
            write.csv(file=wlr.flst[j], wlr.dat)
            print(paste("File", wlr.flst[j], "written.", sep=" "))
        }
    }

    if(StnType$type[i]=="stream"){
        ##-- calculate the rating parameters
        pat <- as.character(StnType$unit_no[i])
        wlr.flst <- list.files(path=paste(data.dir,"/wlr/csv", sep=""),
                               pattern=pat, full.names=TRUE)
        sd.flst <- list.files(path=paste(data.dir, "/rating/csv/", sep=""),
                              pattern="_Stage_Discharge.csv$", full.names=TRUE)
        sd.no <- as.data.frame(as.numeric(gsub("[^0-9]", "", sd.flst)))
        unit.no <-  as.numeric(gsub("[^0-9]", "", StnType$unit_no[i]))
        sd.fl <- read.csv(sd.flst[unit.no==sd.no])
        sd.fl <- subset(sd.fl, select=c("stage", "avg.disch"))
        names(sd.fl) <- c("Stage", "Discharge")
        ##-- run non-linear least square regression
        nls.res <- nls(Discharge~p1*(Stage)^p3,data=sd.fl, start=list(p1=3,p3=5))
        coef.p1 <- as.numeric(coef(nls.res)[1])
        coef.p3 <- as.numeric(coef(nls.res)[2])
        for(j in 1:length(wlr.flst)){
            wlr.dat <- read.csv(wlr.flst[j])
            names(wlr.dat)[3] <- "Stage"
            wlr.dat$Discharge <- coef.p1 * (wlr.dat$Stage)^coef.p3
            ## form <- RCformulae[wlr.units[i]==RCformulae$stn_no,]
            ## if(is.na(form$p2)){
            ##     wlr.dat$Discharge <- form$p1 * (wlr.dat$Stage)^form$p3
            ## }
            write.csv(file=wlr.flst[j], wlr.dat)
            print(paste("File", wlr.flst[j], "written.", sep=" "))
        }
    }

    if(StnType$type[i]=="weir" && StnType$unit_no=="wlr_101"){
        pat <- as.character(StnType$unit_no[i])
        wlr.flst <- list.files(path=paste(data.dir,"/wlr/csv", sep=""),
                               pattern=pat, full.names=TRUE)
        out.flst <- list.files(path=paste(data.dir,"/wlr/csv", sep=""),
                               pattern=pat, full.names=FALSE)
        out.dir <- paste(data.dir,"/discharge/stn/", sep="")
        out.flname <- paste(out.dir, out.flst, sep="")
        for(j in 1:length(wlr.flst)){
            wlr.dat <- read.csv(wlr.flst[j])
            names(wlr.dat)[3] <- "Stage"
            wlr.lowstage <- wlr.dat[wlr.dat$Stage<=0.603, ]
            wlr.highstage <-  wlr.dat[wlr.dat$Stage>0.603, ]
            wlr.lowstage$discharge <- 1.09*(1.393799*((wlr.lowstage$Stage-0.2065)^2.5))
            wlr.highstage$discharge <- 1.09*((1.394*(((wlr.highstage$Stage-0.2065)^2.5) - ((wlr.highstage$Stage-0.603)^2.5))) + (0.719*(wlr.highstage$Stage-0.603)^1.5))
            wlr.discharge <- rbind(wlr.lowstage, wlr.highstage)
            wlr.discharge$date_time <- as.POSIXct(wlr.discharge$date_time)
            wlr.discharge.sorted <- wlr.discharge[order(wlr.discharge$date_time, na.last=FALSE),]
            dis.wlr101 <- subset(wlr.discharge.sorted, select=c("raw", "Stage", "date_time", "dt","discharge"))
            names(dis.wlr101) <- c("raw", "Stage", "date_time", "dt","Discharge")
            dis.wlr101 <- dis.wlr101[!is.na(dis.wlr101$Discharge),]
            dis.wlr101$Discharge <- round(dis.wlr101$Discharge, digits=6)
            dis.wlr101$date_time<-  as.POSIXct(dis.wlr101$date_time, tz="Asia/Kolkata", origin="1970-01-01")
            write.csv(dis.wlr101, file=out.flname[j])
            print(paste("File", out.flname[j], "written.", sep=" "))


            ## Plot stage and discharge together
            dis.wlr101$dt <- as.Date(dis.wlr101$date_time, "%Y-%m-%d")
            gg.data$agg <- factor(gg.data$agg, levels = c("1 min", "15 min", "30 min", "1 hour", "6 hour", "12 hour", "1 day", "15 day", "1 month"))
            ## plot.new()
            ## gg.data <- gg.data[!is.na(gg.data$cal),] ## remove NAs throws errors
            gg.data <- subset(dis.wlr101, select=c("dt", "Stage", "Discharge"))
            gg.data <- melt(gg.data, id="dt")  # convert to long format
            wlrplot <- ggplot(data=gg.data,
                              aes(x=dt, y=value, colour=variable)) +
                geom_line()  +
                scale_x_date(labels = date_format("%d-%b-%Y")) +
                ggtitle("WLR 101, Lakdihalla Wier") +
                labs(x="Date", y="Stage in m\nDischarge in m3/s") +
                theme(axis.title=element_text(size=10,face="bold"),
                      axis.text=element_text(size=8),
                      axis.text.x=element_text(angle=90, vjust=0.5, size=8))
            
            wlrplot
            png.file <- paste(fig.dir, pat, "Discharge.png", sep="")
            ggsave(wlrplot, filename=png.file, width=297, height=210, units="mm")

        }
    }
}
