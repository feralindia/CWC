##--load libraries
## library(zoo) # may not be needed
## library(data.table)
## library(ggplot2)
library(parallel)
library(ggplot2)
library(reshape2)
library(grid)
library(gtable)
library(gridExtra)
library(timeSeries)
library(dplyr) ## may not be needed
library(qdap)
setwd("~/CurrProj/CWC/Anl/SedNut/")
site.name <- "Nilgiris" #"Aghnashini" # or Nilgiris


## Decide what stations you want to process
if(site.name == "Nilgiris"){
    stn <- c(105:107, 109)
}else {
    stn <- c("001","002")
}
##-- load functions
source("functions.R", echo = TRUE)


## Average rainfall for rainguagues in a catchment
## supply filename containing type of unit and station number
tbrg.dat <- AvgRain("~/CurrProj/CWC/Anl/sitewise_unintsname.csv")


##--define constants
set.path(site.name)

##-- read sediment and nutrient data
## create a dataframe containing pairs of water samples and discharge datasets
int.dis.pairs <- merge(x = int.samp.data.df, y = dis.data.df, by.x = "int.samp.stn", by.y = "dis.stn")

##-- Get data for integrated samplers
use.cores <- detectCores() - 1 # use all but one cores
grab.dis.res <- mclapply(FUN=merge.dat.int, X=stn, df.stn=int.dis.pairs)
names(grab.dis.res) <- paste0("Stn.", stn)
mapply(write.list.to.csv, x = grab.dis.res, nm.x=paste0("Stn_", stn))

## Plot the data

mapply(FUN = plot.param, x = grab.dis.res, nm.x = names(grab.dis.res))
## set names of columns to process
bxplt.cover(grab.dis.res)
## add wlr.no to the grab.dis.res dataset if not already added
if(!("wlr.no" %in% names(grab.dis.res[[1]]))){
    wlr.no <- as.list(names(grab.dis.res))
    grab.dis.res <- mapply(cbind, grab.dis.res, "wlr.no"=wlr.no, SIMPLIFY=F)
}

bxplt.stn(grab.dis.res) #plot station wise nutrient load for grab

stn <- as.list(names(grab.dis.res))
lapply(FUN = plot.nutconc, X = stn, tbrg.dat = tbrg.dat, wq.dat = grab.dis.res)

## plot each nutrient
## read and bind relevant files
flnm <- as.list(list.files(path =paste0(csv.out.dir, "integrated/"), pattern ="Hyd.WtrQlStn.", full.names = TRUE))
stn.ids <- as.list(paste("Stn", gsub("[^[:digit:] ]","", flnm)))
ggdat <- do.call("rbind", mapply(read.bind, flnm, stn.ids, SIMPLIFY = FALSE, USE.NAMES = TRUE))
plot.hist.conc(ggdat)
if(site.name = "Nilgiris"){
    png.out <- paste0(fig.out.dir, "integrated/sed.mgl.png")
    plot.conc(ggdat, "sed.mgl", png.out, 0, 5)
    png.out <- paste0(fig.out.dir, "integrated/no3.mgl.png")
    plot.conc(ggdat, "no3.mgl", png.out,0,2.5)
    png.out <- paste0(fig.out.dir, "integrated/po4.mgl.png")
    plot.conc(ggdat, "po4.mgl", png.out,0, 0.015)
}else{
    png.out <- paste0(fig.out.dir, "integrated/sed.mgl.png")
    plot.conc(ggdat, "sed.mgl", png.out, 0, 150)
    png.out <- paste0(fig.out.dir, "integrated/no3.mgl.png")
    plot.conc(ggdat, "no3.mgl", png.out,0,1.5)
    png.out <- paste0(fig.out.dir, "integrated/po4.mgl.png")
    plot.conc(ggdat, "po4.mgl", png.out,0, 0.03)
}

## x.lab <- textGrob("Date", gp=gpar(fontsize=14))
## y.lab <- textGrob(expression(Discharge~m^{3}~Sec^{-1}), rot=90,gp=gpar(fontsize=14))
## leg <- legendGrob(c("Daily Rain (dm)", "Discharge"), do.lines = TRUE, ncol = 1, nrow = 2, gp=gpar(col=c("grey50", "grey30"), lwd = 2, lty = c("solid", "dotted")))
## grid.arrange(stn.101sed, stn.102sed, right = leg, left=y.lab, bottom=x.lab)






  ##   png.out <- gsub("/csv", "/fig", x)
##     png.out <- gsub(".csv", ".sedmgl.png", png.out)
## png(filename = png.out, width = 2400, height = 1600, res = 300)


##     print(grid.arrange(out, right=leg))
##     dev.off()

##---ENDED PROCESSING FOR GRAB/INTEGRATED SAMPLER --##
##-- Get data for stage samplers

all.stg.data <- read.csv.files(stg.samp.full.flnm)
## add columns for height of bottles
## as the dataset isn't large I'm keeping it in RAM
## use function write.list.to.csv to write to disk if needed
rep.tab <- "/home/udumbu/rsb/CurrProj/CWC/Anl/SedNut/stagesampler_hights.csv"
all.stg.data <- lapply(X = all.stg.data, FUN = add.bottle.heights, y = rep.tab)

## create a dataframe containing pairs of water samples and discharge datasets
stg.dis.pairs <- merge(x = stg.samp.data.df, y = dis.data.df, by.x = "stg.samp.stn", by.y = "dis.stn")
## Decide what stations you want to process
if(site.name == "Aghnashini") {
    stn <- c("001", "002")
}else{
    stn <- c("102", "106", "107", "108") # removed 115 for now
}


## subset the discharge dataset to two weeks from each sampler installation
## need to test with lapply
dis.stn <- lapply(stn, FUN = subset.dis.data, df.stn = stg.dis.pairs, wqdat = all.stg.data, simplify = FALSE)
names(dis.stn) <- paste0("stn_", stn)
##--- merge siphon data with discharge dataset ---##

siphon.dis.res <- lapply(X = names(dis.stn), FUN = get.stg, wq_data = all.stg.data, dis_data = dis.stn)
names(siphon.dis.res) <- paste0("stn_", stn)
## dev.new()
mapply(FUN = plot.stg.dis, x = siphon.dis.res, nm.x = names(siphon.dis.res))

## write results to CSV

mapply(write.stg.dis.to.csv, x = siphon.dis.res, nm.x = names(siphon.dis.res))


## Plot timeseries on hydrograph

## stn <- as.list(names(tbrg.dat))
## x <- stn[[2]]
## y <- tbrg.dat[[2]]

stn <- as.list(names(siphon.dis.res))
lapply(FUN = plot.nutconc, X = stn, tbrg.dat = tbrg.dat, wq.dat = siphon.dis.res)
## mapply(FUN = plot.nutconc, x=stn, y=tbrg.dat, SIMPLIFY = FALSE)
bxplt.cover(siphon.dis.res)
bxplt.stn(siphon.dis.res) #plot station wise nutrient load for siphon/stage

## plot each nutrient
## read and bind relevant files
flnm <- as.list(list.files(path =paste0(csv.out.dir, "stage/"), pattern ="Hyd.WtrQlstn_", full.names = TRUE))
flnm <- flnm[-5] # remove 115
stn.ids <- as.list(paste("Stn", gsub("[^[:digit:] ]","", flnm)))
ggdat <- do.call("rbind", mapply(read.bind, flnm, stn.ids, SIMPLIFY = FALSE, USE.NAMES = TRUE))
plot.hist.conc(ggdat)
if(site.name=="Nilgiris"){
    png.out <- paste0(fig.out.dir, "stage/sed.mgl.png")
    plot.conc(ggdat, "sed.mgl", png.out, 0, 400)
    png.out <- paste0(fig.out.dir, "stage/no3.mgl.png")
    plot.conc(ggdat, "no3.mgl", png.out, 0 ,3.5)
    png.out <- paste0(fig.out.dir, "stage/po4.mgl.png")
    plot.conc(ggdat, "po4.mgl", png.out, 0, 0.05)
    png.out <- paste0(fig.out.dir, "stage/disc.mgl.png")
    plot.conc(ggdat, "disl.C", png.out, 0, 25)
}else{
    png.out <- paste0(fig.out.dir, "stage/sed.mgl.png")
    plot.conc(ggdat, "sed.mgl", png.out, 0, 500)
    png.out <- paste0(fig.out.dir, "stage/no3.mgl.png")
    plot.conc(ggdat, "no3.mgl", png.out, 0 ,1.0)
    png.out <- paste0(fig.out.dir, "stage/po4.mgl.png")
    plot.conc(ggdat, "po4.mgl", png.out, 0, 0.04)
    
}

##---ENDED PROCESSING FOR STAGE/SIPHON SAMPLER --##

## test code below

names(grab.dis.res)
tmp <- grab.dis.res[[1]]
tmp <- tmp[tmp$sed.mgl<2,]
lm.tmp <- lm(tmp$sed.mgl ~ tmp$no3.mgl)
summary(lm.tmp)
plot(x =tmp$sed.mgl,y =  tmp$po4.mgl)
ggdat <- melt(tmp, measure.vars = c(5:10,12, 13), id.vars = c("sed.mgl","Timestamp", "Discharge"), variable.name = "Parameter", value.name = "Concentration")
ggdat$sed.mgl <- as.numeric(ggdat$sed.mgl)
ggdat$Concentration <- as.numeric(ggdat$Concentration)
ggplot(data = ggdat, aes(x = sed.mgl, y = Concentration)) +
                     geom_point() +
        facet_wrap(~ Parameter, scales = "free")



## nutrient|sediment conc ~ rainfall.intensity + discharge + cumulative wetness
## where nutrient|sediment conc in kg/m3/hour is nut.mgl*DepthDischarge*0.001
## cumulative wetness is cumulative rain - cumulative discharge
## starting at beginning of wet season
## HERE Need to ensure script is pulling the right rain gauge and running the cumulative rainfall on averages of concerned rain gauges.
## Also need to ensure the discharge is correctly cumulated.

x <- grab.dis.res[[1]]
x <- siphon.dis.res[[1]]

rain.files.file <- list.files(path = "~/CurrProj/CWC/Data/Nilgiris/tbrg/csv/", pattern = "1 hour")
rain.files.full <- list.files(path = "~/CurrProj/CWC/Data/Nilgiris/tbrg/csv/", pattern = "1 hour", full.names = TRUE)
rain.fn <- rain.files.full[gsub("[^0-9]", "", x$wlr.no[1]) == substr(rain.files.file, start = 6, stop = 8)]
rain.dat <- read.csv(rain.fn) # , colClasses = c(NULL, "numeric",  "Date"))
rain.dat <- rain.dat[, c(2, 3)]
names(rain.dat) <- c("Rain mm", "TimeHour")
rain.dat$TimeHour <- as.POSIXct(rain.dat$TimeHour, tz = "Asia/Kolkata")
x$TimeHour <- round(x$Timestamp, "hour")
x$Timenum <- as.numeric(x$TimeHour)
rain.dat$Timenum <- as.numeric(rain.dat$TimeHour)-3600 # go back one hour
x.y <- merge(rain.dat, x, by = "Timenum")

## get wetness
yr <- as.numeric(format(x$Timestamp, format = "%Y"))

x.y$st.date <- as.POSIXct(mapply(get.stdate, x.y$Timestamp, yr), tz = "Asia/Kolkata", origin="1970-01-01")
stm <- build.stm(x.y, "st.date", "Timestamp") # generate statement

cum.rain <- lapply(stm, function(x,...){ # run cumulation
    y <- rain.dat['TimeHour']
    y <- as.numeric(as.POSIXct(y[,1], tz = "Asia/Kolkata"))
    out <- eval(parse(text=x))
    out <- sum(out[,'Rain mm'])
    return(out)
})


cum.discharge <- sadf

tmp.fun <- function(x){
    print(x['Timestamp'])
}
lapply(x.y, tmp.fun)
