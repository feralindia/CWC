## script to plot the manually cleaned rating curves after visual assessment
## the input dataset includes justifications for setting outliers to NA
## this data is to be used for calculating the discharges in stead of the rating data

##--- load libraries
library(ggplot2)
library(scales)
##--- define constants
raw.dr <- "~/OngoingProjects/CWC/Data/Nilgiris/cleaned.rating/raw/"
csv.dr <- "~/OngoingProjects/CWC/Data/Nilgiris/cleaned.rating/csv/"
fig.dr <- "~/OngoingProjects/CWC/Data/Nilgiris/cleaned.rating/fig/"
raw.flst <- list.files(path=raw.dr, pattern=".csv$", ignore.case=TRUE, full.names=TRUE)
csv.flno <- as.numeric(gsub("[^[:digit:] ]", "", raw.flst))

##--- Import the results CSV file and plot the discharge-stage curve for each site

for (x in 1:length(raw.flst)){
    raw.file <- raw.flst[x]
    out.file <- paste(csv.dr, "WLR_", csv.flno[x],"_SD.csv", sep="")
    tmp <- read.csv(raw.file, header=TRUE, sep=",", row.names=1)
    tmp[tmp==""] <- NA  # replace blanks with missing data
    tmp <- tmp[complete.cases(tmp[, c(5,6)]),] ## remove rows with missing data in stage or discharge column
    names(tmp) <- c("Sl.No.", "site", "obs.file", "method", "stage", "avg.disch", "timestamp", "notes")
    wlr.no <- csv.flno[x]
    figfile <- paste(fig.dr, "/WLR_", wlr.no, ".png", sep="")
    mn <- paste("Stage Discharge Curve || Site: WLR_", wlr.no, sep="") # figure title

    ##--- plot using ggplot2
     sd.plot <- ggplot(data = tmp, aes(stage, avg.disch, group=method, label=as.Date(as.POSIXct(timestamp, origin="1970-01-01")))) + 
        geom_point(aes(color=method, position="jitter")) +
            geom_text(size=1,angle = 45, position="jitter") +
            ggtitle(mn) + labs(x = "Stage (m)", y = "Discharge (m3/s)") +
                theme(axis.title=element_text(size=10,face="bold"),
                      axis.text=element_text(size=8))
   sd.plot
    ggsave(sd.plot, filename=figfile, width=6, height=4, units="in",dpi=450)
    ## legend.names <- levels(tmp$method)
    ## legend('topright', legend.names ,  fill=c('red', 'blue', 'green',' brown'), bty='n', cex=.75)
    ## dev.off() # transfer data to file
    write.csv(tmp, file=out.file)
}
