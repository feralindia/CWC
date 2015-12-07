## Generate summary reports for selected periods
## Need to get if statements to fix dates for subsetting and reporting


library(ggplot2)
library(zoo)
## This function was taken from <http://stackoverflow.com/questions/13297155/add-floating-axis-labels-in-facet-wrap-plot>
## helps organise the scales

library(grid)
# pos - where to add new labels
# newpage, vp - see ?print.ggplot
facetAdjust <- function(x, pos = c("up", "down"), 
                        newpage = is.null(vp), vp = NULL)
{
  # part of print.ggplot
  ggplot2:::set_last_plot(x)
  if(newpage)
    grid.newpage()
  pos <- match.arg(pos)
  p <- ggplot_build(x)
  gtable <- ggplot_gtable(p)
  # finding dimensions
  dims <- apply(p$panel$layout[2:3], 2, max)
  nrow <- dims[1]
  ncol <- dims[2]
  # number of panels in the plot
  panels <- sum(grepl("panel", names(gtable$grobs)))
  space <- ncol * nrow
  # missing panels
  n <- space - panels
  # checking whether modifications are needed
  if(panels != space){
    # indices of panels to fix
    idx <- (space - ncol - n + 1):(space - ncol)
    # copying x-axis of the last existing panel to the chosen panels 
    # in the row above
    gtable$grobs[paste0("axis_b",idx)] <- list(gtable$grobs[[paste0("axis_b",panels)]])
    if(pos == "down"){
      # if pos == down then shifting labels down to the same level as 
      # the x-axis of last panel
      rows <- grep(paste0("axis_b\\-[", idx[1], "-", idx[n], "]"), 
                   gtable$layout$name)
      lastAxis <- grep(paste0("axis_b\\-", panels), gtable$layout$name)
      gtable$layout[rows, c("t","b")] <- gtable$layout[lastAxis, c("t")]
    }
  }
  # again part of print.ggplot, plotting adjusted version
  if(is.null(vp)){
    grid.draw(gtable)
  }
  else{
    if (is.character(vp)) 
      seekViewport(vp)
    else pushViewport(vp)
    grid.draw(gtable)
    upViewport()
  }
  invisible(p)
}


## This section for TBRG
csvdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv/"
repdir<- "/home/udumbu/rsb/OngoingProjects/CWC/Reports/ForestDeptNilgiris/2015/"
tbrgnum <- c(101:133, 135)
tbrgname <- paste("Rain Gauge No.",tbrgnum, sep="")
daily.files <- paste("tbrg_",tbrgnum,"_1 day.csv", sep="")
epsout <- paste(repdir,"ERE_tbrg_all.eps", sep="")
pdfout <- paste(repdir,"ERE_tbrg_all.pdf", sep="")
alltbrg <- data.frame(dt.tm=numeric(0), mm=numeric(0), tbrg=character(0))
allmntdat <- data.frame(dt.tm=numeric(0), mm=numeric(0), tbrg=character(0))
allcumdat <- data.frame(dt.tm=numeric(0), mm=numeric(0), tbrg=character(0))
for (i in 1:length(daily.files)){
    dailydat <- paste(csvdir, daily.files[i], sep="")
    csvout <- paste(repdir,"ERE_tbrg_", tbrgnum[i], ".csv", sep="")
    dat <- read.csv(file=dailydat)
    dat <- subset(dat, subset= mm > 100, select = c(dt.tm, mm))
    dat$dt.tm <- as.Date(dat$dt.tm)
    write.csv(dat, file=csvout)
    try(dat$tbrg <- tbrgname[i], silent=TRUE)
    alltbrg <- rbind(alltbrg,dat)
    ## for monthly averages
    mntdat <- read.csv(file=dailydat)
    mntdat <- subset(mntdat,  select = c(dt.tm, mm))
    allmntdat <- rbind(allmntdat,mntdat)
    ## for cumulative rain
    cumdat <- read.csv(file=dailydat)
    cumdat <- subset(mntdat,  select = c(dt.tm, mm))
    cumdat$tbrg <- as.factor(tbrgnum[i])
    allcumdat <- rbind(allcumdat,cumdat)
}
outplot <- ggplot(data = alltbrg, aes(dt.tm, mm)) + 
    geom_point() + facet_wrap(~tbrg) +
    theme(axis.text.x = element_text(angle = 90))+
    labs(x="Date", y="Rainfall in mm")
ggsave(outplot, file=epsout, width=297, height=210, units="mm")
ggsave(outplot, file=pdfout, width=297, height=210, units="mm")

## This section for WLR

csvdir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"

## Merge data for multiple loggers per station
in.files <- list.files(csvdir, pattern="_1 day.csv$", ignore.case=TRUE, full.names=TRUE, include.dirs=FALSE)
##list.files(csvdir, pattern=".merged.csv$", full.names=TRUE, include.dirs=FALSE)

in.stn <- as.numeric(gsub("[^[:digit:] ]", "", in.files))
unique.stns <- unique(in.stn)## substr(unique(in.stn), start=0, stop=3)
stn.names <- substr(unique(in.stn), start=0, stop=3)
for(i in 1:length(unique.stns)){
    sel.stn <- in.files[in.stn==unique.stns[i]]
    merged.file <- paste(csvdir, "merged_station_", stn.names[i], "_one day.csv", sep="")
    merge.tmp <- as.data.frame(matrix(nrow=0,ncol=5))
    for(j in 1: length(sel.stn)){
        tmp <- read.csv(file=sel.stn[j], header=TRUE)
        merge.tmp <- rbind(merge.tmp, tmp)
    }
    names(merge.tmp) <- names(tmp) ## c("raw", "cal", "date_time")
    write.csv(file=merged.file, x=merge.tmp)
}

wlrnum <- stn.names
wlrname <- paste("Water Level Recorder No.",stn.names, sep="")


daily.files <- list.files(csvdir, pattern=c("merged_station", "_1 day.csv$", ignore.case=TRUE)) ##paste("wlr_",101:109,"_1 day.csv", sep="")

allwlr <- data.frame(date_time=numeric(0), mm=numeric(0), wlr=character(0))
for (i in 1:length(wlrnum)){
    ## station <- as.numeric(gsub("[^[:digit:] ]", "", daily.files))
    
    dailydat <- paste(csvdir, daily.files[i], sep="")
##    csvout <- paste(repdir,"wlr_", wlrnum[i], ".csv", sep="")

    dat <- read.csv(file=dailydat)
    dat$date_time <- as.Date(dat$date_time)
    ## dat <- subset(dat, format.Date(date_time, "%m")>"05" & format.Date(date_time, "%m")<"13", c(date_time, cal))
    ## write.csv(dat, file=csvout)
    try(dat$wlr <- wlrname[i], silent=TRUE)
    allwlr <- rbind(allwlr,dat)
}
outplot <- ggplot(data = allwlr, aes(date_time, cal)) + 
    geom_line() + facet_wrap(~wlr) +
    theme(axis.text.x = element_text(angle = 90))+
    labs(x="Date", y="Stage in cm")
epsout <- paste(repdir,"WKR.eps", sep="")
pdfout <- paste(repdir,"WLR.pdf", sep="")
ggsave(outplot, file=epsout, width=297, height=210, units="mm")
ggsave(outplot, file=pdfout, width=297, height=210, units="mm")


## Get averages of all rainfall on a monthly basis
## Note that cumulative rainfall calculations are not correct. Issues with the data as well as rain gauges were installed at different times. We can only do this on a per-rain gauge basis.
allmntdat$dt.tm <- as.yearmon(allmntdat$dt.tm)
meanmntrain <- aggregate(allmntdat$mm, by=list(allmntdat$dt.tm, allcumdat$tbrg), FUN=mean, na.rm=TRUE)
allcumdat$dt.tm <- as.yearmon(allcumdat$dt.tm)
## ensure there is no false data by subsetting
allcumdat <- subset(allcumdat, subset= dt.tm > "May 2012")
cummntrain <- aggregate(allcumdat$mm, by=list(allcumdat$dt.tm, allcumdat$tbrg), FUN=sum, na.rm=TRUE)
## total cumulatve
cumrain.tbrg<- aggregate(allcumdat$mm, by=list(allcumdat$tbrg), FUN=sum, na.rm=TRUE)
## cumulative for 2015
allcumdat15 <- subset(allcumdat, subset= dt.tm > "Dec 2014")
cumrain15.tbrg<- aggregate(allcumdat15$mm, by=list(allcumdat15$tbrg), FUN=sum, na.rm=TRUE)

## creating new container summary rain
## earlier code: summaryrain <- meanmntrain
## cols<- ncol(meanmntrain)
## rows <- nrow(cummntrain)
## summaryrain <- as.data.frame(matrix(nrow=rows, ncol=cols))
## names(summaryrain) <- names(meanmntrain)
### NEED TO FIX FROM HERE
## MISMATCH IN NUMBER OF ROWS, PROBABLY BECAUSE ONE DATASET CONTAINS 12 MONTHS AND THE OTHER 6
summaryrain <- meanmntrain
summaryrain$y <-  cummntrain$x
summaryrain$mnt <- as.character(summaryrain$Group.1)
names(summaryrain) <- c("Month", "Rain Gauge", "Average Daily Rain (mm)", "Cumulative Rain in (mm)")
write.csv(summaryrain, file=paste(repdir, "Average_Cumulative_Rainfall.csv", sep=""))
names(summaryrain) <- c("mnt", "tbrg", "avg", "cum", "month_year")
summaryrain <- subset(summaryrain, subset= format.Date(mnt, "%b")>"Dec" &  format.Date(mnt, "%Y")>"2014")
summaryrain$mnt <- as.POSIXct(summaryrain$mnt, format= "%b %Y")
## rain2013 <- subset(summaryrain, subset= mnt < "Jan 2014" & as.numeric(summaryrain$tbrg) < 10)
## rain2014 <- subset(summaryrain, subset=mnt > "Dec 2013")
## rain2013$mnt <- as.character(rain2013$mnt)

## NEed to put the two years in a loop at some point.
## doing it manually including changing the filenames for now
avgrainplot <-ggplot(data=summaryrain, aes(x=mnt,y=avg))  +
    geom_bar(stat="identity") +
    facet_wrap(~tbrg) +
    theme(axis.text.x = element_text(angle = 90,size=7))+
    labs(x="Month", y="Average Rainfall in mm")

epsout <- paste(repdir,"TBRGAvgRain2015.eps", sep="")
pngout <- paste(repdir,"TBRGAvgRain2015.png", sep="")
ggsave(avgrainplot, file=epsout, width=240, height=180, units="mm")
ggsave(avgrainplot, file=pngout, width=240, height=180, units="mm")


## Plot cumulative rainfall
## names(cumrain14.tbrg) <- c("Rain Gauge", "Rain in mm")

head(cumrain15.tbrg)
cumrain2015 <- ggplot(data=cumrain15.tbrg, aes(x=Group.1, y=x)) + ## aes(x="Rain Gauge", y="Rain in mm"))+  ## aes(x=Group.1, y=x))  +
    geom_bar(stat="identity", colour="black", fill="grey")+
    theme(axis.text.x = element_text(angle = 90))+
    labs(x="Rain Gauge", y="Cumulative Rainfall in mm")
epsout <- paste(repdir,"CumRain2015.eps", sep="")
pngout <- paste(repdir,"CumRain2015.png", sep="")

ggsave(cumrain2015, file=epsout, width=240, height=180, units="mm")
ggsave(cumrain2015, file=pngout, width=240, height=180, units="mm")
## Need to rewrite code to do monthwise cumulative rainfall.
