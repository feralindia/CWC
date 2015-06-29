##-------
## Script to partially automate extraction of
## nonlinear least squares for fitting stage-discarge curves
## and generating stage-discharge curves and hydrographs
## FIX THE DIRECTORY STRUCTURE
##-------
library(EcoHydRology)
library(ggplot2)
sd.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/disch/csv/"
hydro.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hydrograph/csv/"
wlr.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
tbrg.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv/"
hydro.fig.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hydrograph/fig/"
dfvals <- read.csv("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hydrograph/SDcalcVals.csv") # read parameter values from file
names(dfvals) <- c("wlr.id", "p1", "p2", "p3")
pairs <- read.csv("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/hydrograph/wlr_tbrg_pairs.csv")
wlrid <- as.character(pairs$wlrid)
tbrgid <- as.character(pairs$tbrgid)
## wlrid <- dfvals$wlrid
for(i in 1:nrow(pairs)){
    sd.files <- paste(sd.dir, wlrid[i], "_Stage_Discharge.csv", sep="")
    sd.fileout <- paste(hydro.dir, wlrid[i], "_SD_Scatter.csv", sep="")
    wlrno <- substr(wlrid[i], start=5, stop=nchar(wlrid[i]))
    tbrgno <- substr(tbrgid[i], start=6, stop=nchar(tbrgid[i]))
    wlrdatfile <- paste(wlr.dir, wlrno, "_onemin.merged.csv", sep="")
    tbrgdatfile <- paste(tbrg.dir,"tbrg_",  tbrgno, "_15 min.csv", sep="")
    wlr.disch.file <- paste(wlr.dir, wlrid[i], "_discharge_1min.csv", sep="")
    wlr.disch.image <- paste(hydro.fig.dir, wlrid[i], "_discharge_1min.png", sep="")
    wlr.hydrograph <- paste(hydro.fig.dir, wlrid[i], tbrgid[i], "_hydrograph.png", sep="")
    wlr.hydrodata <- paste(hydro.dir, wlrid[i], tbrgid[i], "_hydrograph_data.csv", sep="")
    ##for (j jn 1:length(sd.files)){
        sd.data <- read.csv(sd.files)
        wlr.data <- read.csv(wlrdatfile)
        tbrg.data <- read.csv(tbrgdatfile)
        wlr.data$date_time <- as.POSIXct(wlr.data$date_time)
        names(wlr.data)[names(wlr.data) == 'date_time'] <- 'dt.tm'
        tbrg.data$dt.tm <- as.POSIXct(tbrg.data$dt.tm)### wlrid is from two sources, change name for attr in first loop
        p1 <- as.numeric(subset(x=dfvals, subset=wlr.id==wlrid[i], select=p1))
        p3 <- as.numeric(subset(x=dfvals, subset=wlr.id==wlrid[i], select=p3))
        sd.res <- nls(Discharge~p1*(Stage)^p3,data=sd.data, start=list(p1=p1,p3=p3))
        sd.sum <- summary(sd.res)
        out<-capture.output(sd.sum)
        unlink(paste(hydro.dir, "SummaryNLS_", wlrid[i], ".txt", sep=""))
        cat(out,file=paste(hydro.dir, "SummaryNLS_", wlrid[i], ".txt", sep=""),sep="\n",append=TRUE)# HERE
        
                                        # Extract p1 and p3
        sd.coef<- coef(sd.res)
        sd.p1 <- as.numeric(sd.coef[1])
        sd.p3 <- as.numeric(sd.coef[2])
                                        # run the final multiplication
        
        wlr.data$disch <- sd.p1*(wlr.data$cal)^sd.p3
        ## write.csv(file=wlr.disch.file[i],  wlr.data)
        
    SDPlot <- ggplot() +
        geom_line(data=wlr.data, aes(cal, disch), colour="steelblue")+ 
            geom_point(data=sd.data, aes(Stage,Discharge), colour="red") +
                ggtitle(wlrid[i]) +
                    labs(x="Stage in m", y="Discharge in m^3/s")
    ggsave(filename=wlr.disch.image, plot=SDPlot, width=11.3, height=8.7, units="in")
    plot.new()
    
                                            # generate a hydrograph
    wlr.tbrg.data <- merge(wlr.data, tbrg.data, by="dt.tm", all=TRUE)
    hyd.data <- subset(wlr.tbrg.data, select=c(dt.tm, mm, disch, cal))
    names(hyd.data) <- c("date", "P_mm", "Streamflow_m3s", "Stage_m")
    ##pdf(file=wlr.hydrograph, paper="a4r", width=11.3, height=8.7)
    ## png(filename=wlr.hydrograph[j], width=1200, height=800, pointsize=10, type="cairo-png")
    hydrograph(hyd.data, stream.label="Instantaneous Discharge at m^3/sec", P.units="mm", S1.col="blue", S2.col="red")
    ## dev.off()
    ##write.csv(file=wlr.hydrodata, hyd.data)
   ##  write.csv(file=sd.fileout, sd.data)
}
##   ## Correlation plot NEEDS TO BE FIXED
    hyd.data <- hyd.data[complete.cases(hyd.data),] ## remove rows with NAs
    hyd.data <- subset(hyd.data, subset=date > as.POSIXct("2013-06-15 00:00:00") & date < as.POSIXct("2013-09-15 00:00:00"))
## ##hyd.data <- head(hyd.data, n=100)
    obj <- ccf(hyd.data[,4], hyd.data[,2],type="correlation",plot=T,lag.max=100)
png(filename="/home/udumbu/rsb/tmp/CCwlr109tbrg119.png",width=1200, height=800, pointsize=14, type="cairo-png")
    plot(obj[0:100],type="l",xlim=c(0,40),bty="l",ylab="Correlation Coefficient",main="Cross Correlation WLR 109, TBRG 119 \n from Sept 05 to 15, 2013", xlab="Lag in 15 minute units")
dev.off()
