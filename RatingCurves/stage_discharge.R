## To plot stage-discharge relationship for manually merged data from
## different methods (pyg, flt, slug and constant release) into the Stage_Discharge.csv file

csv.flst <- list.files(path=csv.dr, pattern="_Stage_Discharge.csv$", ignore.case=TRUE, full.names=TRUE)
station <- list.files(path=csv.dr, pattern="_Stage_Discharge.csv$", ignore.case=TRUE, full.names=FALSE)
station <- as.numeric(gsub("[^[:digit:] ]", "", station))
for (x in 1:length(csv.flst)){
    tmp <- read.csv(csv.flst[x], header=TRUE, sep=",")
    wlr.no <- station[x]
    ## wlr.no <- unlist(regmatches(csv.file, gregexpr('\\(?[0-9]+a?', csv.file)))
    figfile <- paste(fig.dr, "/WLR_", wlr.no, ".png", sep="")
    mn <- paste("Stage Discharge Curve || Site: WLR_", wlr.no, sep="") # figure title
    ## plot using ggplot2
    
    sd.plot <- ggplot(data = tmp, aes(stage, avg.disch, group=method)) +
        geom_point(aes(color=method)) +
            ggtitle(mn) + labs(x = "Stage (m)", y = "Discharge (m3/s)") +
                theme(axis.title=element_text(size=10,face="bold"),
                      axis.text=element_text(size=8))
    ggsave(sd.plot, filename=figfile, width=6, height=4, units="in")
}
