## function to generate a csv file
## containing months as columns and
## data totals in rows
## x is names of dataset

library(reshape2)
library(gridExtra)
library(grid)
library(ggplot2)
library(scales)

file.list.nlg <- list.files(path="~/OngoingProjects/CWC/Data/Nilgiris/tbrg/csv", pattern= "1 day.csv", full.names=TRUE)
file.list.agn <- list.files(path="~/OngoingProjects/CWC/Data/Aghnashini/tbrg/csv", pattern= "1 day.csv", full.names=TRUE)
## create theme for grid table
mytheme <- gridExtra::ttheme_default(
    core = list(fg_params=list(cex = 0.7)),
    colhead = list(fg_params=list(cex = 0.60)),
    rowhead = list(fg_params=list(cex = 0.60)))

report.monthly <- function(x){
    dat <- read.csv(x)
    dat$dt.tm <- as.POSIXct(dat$dt.tm, tz="Asia/Kolkata")
    start.date <- as.POSIXct("2012-01-01", tz="Asia/Kolkata")
    end.date <- as.POSIXct("2016-12-31", tz="Asia/Kolkata")
    date.seq <- seq.POSIXt(start.date, end.date,by="1 day",na.rm=TRUE)
    missing.dates <- date.seq[!(as.numeric(date.seq) %in% as.numeric(dat$dt.tm))]
    tmp <- as.data.frame(lapply(dat, function(x) rep.int(NA, length(missing.dates))))
    tmp$dt.tm <- missing.dates
    dat <- rbind(dat, tmp)
    dat$Month <- format(as.POSIXct(dat$dt.tm, tz="Asia/Kolkata"), format="%B")
    dat$Year <- format(as.POSIXct(dat$dt.tm, tz="Asia/Kolkata"), format="%Y")
    dat$Date <- format(as.POSIXct(dat$dt.tm, tz="Asia/Kolkata"), format="%d")
    dat$mt <- as.Date(cut(dat$dt.tm,  breaks = "month"))# monthly aggregation
    dat$wk <- as.Date(cut(dat$dt.tm,  breaks = "week"))# weekly aggregation
    dat$dt <- as.Date(dat$dt.tm, tz="Asia/Kolkata") # daily
    mdata <- melt(dat, id=c("mt","Date", "Month", "Year"),  measure.vars="mm")
    out.png <- gsub(".*\\/(.*)\\_1 day *.*", "\\1.png", x)
    gtitle <- gsub(".*\\/(.*)\\_1 day *.*", "\\1", x)
    ## ggplot
        ggplot(data = mdata, aes(mt, value)) +
            stat_summary(fun.y = sum, na.rm = TRUE, geom = "bar") +
            scale_x_date(labels = date_format("%Y-%m"), date_breaks = "1 month")+
            labs(x="Month/Year", y="Rainfall in mm", title=gtitle) +
            theme(axis.text.x=element_text(angle=90))
    ggsave(filename = out.png)
    ## break up into years
    yrs <- c(2013,2014,2015,2016)
    lapply(yrs,function(y) {
        submdata <- subset(mdata, subset=Year==y)
        out.csv <- gsub(".*\\/(.*)\\_1 day *", paste0("\\1_",y), x)
        out.pdf <- gsub(".*\\/(.*)\\_1 day *.*", paste0("\\1_",y,".pdf"), x)
        pdftitle <- gsub(".*\\/(.*)\\_1 day *.*", paste0("\\1_",y), x)
        grid <- dcast(submdata, Date~Month)
        grid.out <- grid[,c("Date", "January", "February", "March", "April","May", "June", "July", "August", "September", "October", "November", "December")]
        ## write to csv
        write.csv(file=out.csv, grid.out, row.names=FALSE)
        ## generate pdf report
        pdf(file=out.pdf, paper = "a4", width = 8, height = 11.5, title = pdftitle)
        grid.table(grid.out, theme = mytheme, rows=NULL)
        dev.off()
    })
}

lapply(file.list.agn, report.monthly)
lapply(file.list.nlg, report.monthly)
