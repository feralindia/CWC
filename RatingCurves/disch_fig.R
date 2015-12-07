## Import the results CSV file and plot the discharge-stage curve for each site
csv.flst <- list.files(path=csv.dr, pattern="_SD.csv$", ignore.case=TRUE, full.names=TRUE)
csv.flno <- list.files(path=csv.dr, pattern="_SD.csv$", ignore.case=TRUE, full.names=FALSE)
csv.flno <- substr(csv.flno, start=5, stop=(nchar(csv.flno)-7))
for (x in 1:length(csv.flst)){
    csv.file <- csv.flst[x]
    out.file <- paste(substr(csv.file, start=0, stop=(nchar(csv.file)-6)), "Stage_Discharge.csv", sep="")
    tmp <- read.csv(csv.file, header=FALSE, sep=",")
    tmp <- tmp[complete.cases(tmp[, c(5,6)]),] ## remove rows with missing data in stage or discharge column
    names(tmp) <- c("Sl.No.", "site", "obs.file", "method", "stage", "avg.disch", "timestamp")
    wlr.no <- csv.flno[x]
    ## wlr.no <- unlist(regmatches(csv.file, gregexpr('\\(?[0-9]+a?', csv.file)))
    figfile <- paste(fig.dr, "/WLR_", wlr.no, ".png", sep="")
    mn <- paste("Stage Discharge Curve || Site: WLR_", wlr.no, sep="") # figure title
    ##  obsdate <- substr(tmp$obs.file, start=0, stop=nchar(tmp$obs.file)-4)
    ## plot using ggplot2
    timestamp <- as.POSIXct(tmp$timestamp, origin="1970-01-01", tz="Asia/Kolkata")
    sd.plot <- ggplot(data = tmp, aes(stage, avg.disch, group=method, label=as.Date(as.POSIXct(timestamp, origin="1970-01-01")))) + 
        geom_point(aes(color=method, position="jitter")) +
            geom_text(size=1,angle = 45, position="jitter") +
            ggtitle(mn) + labs(x = "Stage (m)", y = "Discharge (m3/s)") +
                theme(axis.title=element_text(size=10,face="bold"),
                      axis.text=element_text(size=8))
   ##  sd.plot
    ggsave(sd.plot, filename=figfile, width=6, height=4, units="in",dpi=450)
    ## legend.names <- levels(tmp$method)
    ## legend('topright', legend.names ,  fill=c('red', 'blue', 'green',' brown'), bty='n', cex=.75)
    ## dev.off() # transfer data to file
    write.csv(tmp, file=out.file)
}
