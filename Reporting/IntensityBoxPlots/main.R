## create box plots of rainfall events for each catchment
## Plot hourly data for each rain gauge grouped by catchment for each month of the year
data.dir <- "~/OngoingProjects/CWC/Data/"
site <- c("Nilgiris", "Aghnashini")

bplot.rain <- function(tbrg.dat){ #tmp <- get("101")
    tmp <- get(tbrg.dat)
    tmp$dt.tm <- as.POSIXct(tmp$dt.tm, tz = "Asia/Kolkata")
    tmp$mnt.yr <- paste(months.POSIXt(tmp$dt.tm), substr(tmp$dt.tm, 1,4))
    
    tmp.plot <- ggplot(tmp, aes( mnt.yr,mm)) +
        geom_boxplot() +
        labs(x = "Month/Year",  y = "Rainfall in mm/hr") +
        theme(axis.text.x=element_text(angle=90, vjust=0.5, size=8)) +
        ggtitle(paste("tbrg_",tbrg.dat, sep = ""))
    ## return(tmp.plot)
    png.name <- paste("./",site[s], "/tbrg_",tbrg.dat,".png", sep = "")
    return(ggsave(filename = png.name, plot = tmp.plot))
}

for(s in 1: 2){
    file.names <- list.files(paste(data.dir, site[s], "/tbrg/csv/", sep = ""), pattern = "1 hour.csv")
    file.paths <- list.files(paste(data.dir, site[s], "/tbrg/csv/", sep = ""), pattern = "1 hour.csv", full.names = TRUE)
    
    tbrg.units <- strsplit(file.names, split = "_")
    tbrg.units <- as.data.frame(matrix(unlist(tbrg.units), ncol=3, byrow=TRUE))[,2]
    tbrg.units <- as.character(tbrg.units)
    
    for (n in 1:length(file.names)) assign(tbrg.units[n], read.csv(file.paths[n]))
    lapply(tbrg.units, bplot.rain)
}
