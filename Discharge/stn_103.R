## incomplete - updated 16 feb 2016
## Station 103 is associated with:
## wlr: 103, 103a
## flume: 113
## tbrg: 103, 109
## bs: 102, 123
## this script collates data for wlr 103 & 103a and
## runs a routine for flume 113

##--- define constants
ar.cat <- 495862.50
catch.type <- "Wattle Catchment"
wlr.path <- "~/OngoingProjects/CWC/Data/Nilgiris/wlr/csv/"
wlr.fn <- c("wlr_103_1 min.csv", "wlr_103a_1 min.csv")
wlr.fn.full <- paste(wlr.path, wlr.fn, sep="")


sd.flst <- list.files(path=paste(data.dir, "/cleaned.rating/csv", sep=""),
                      pattern="WLR_103_SD.csv$", full.names=TRUE)
sd.fl <- read.csv(sd.flst)
sd.fl <- subset(sd.fl, select=c("stage", "avg.disch"))
names(sd.fl) <- c("Stage", "Discharge")
##-- run non-linear least square regression
nls.res <- nls(Discharge~p1*(Stage)^p3,data=sd.fl, start=list(p1=3,p3=5))
predict(nls.res)
coef.p1 <- as.numeric(coef(nls.res)[1])
coef.p3 <- as.numeric(coef(nls.res)[2])
### wlr.dat <- read.csv(wlr.flst)
### names(wlr.dat)[3] <- "Stage" ## check this HERE
calc.disch <- function(fn, fn.full){
    for(i in 1:length(fn))(assign(fn[i], read.csv(fn.full[i]))) ## fix
    y <- get(fn[1])
    if(length(fn)>1)for(i in 2:length(fn))(y <- rbind(y, get(fn[i])))
    names(y) <- c("ID", "Capacitance", "Stage", "Timestamp", "Date")
    ## if(duplicated(y$date_time)==TRUE)stop(paste("Timestamp is duplicated on ", x, sep="")) # this line needs fixing
    y$Discharge <- coef.p1 * (y$Stage)^coef.p3
    return(y)
}

wlr.dat.all <- calc.disch(wlr.fn,wlr.fn.full)

##-- run routine to get data from flume or other stations
## note the data structure should be same as wlr.dat.all

## source("stn_113", echo=TRUE) ## fix and activate routine
## wlr.dat.all <- rbind(wlr.dat.all, wlr112.dat)

##--- calculate depth of discharge ----##
wlr.dat.all$DepthDischarge <- (wlr.dat.all$Discharge/ar.cat)*1e+9
## plot(wlr.dat.all$Stage, wlr.dat.all$Discharge, type="p",
##      main="Stage Discharge Curve for station 103 at Lakdi",
##      xlab="Stage (m)", ylab="Discharge (m^3/sec)")

wlr.dat.all$Timestamp <- as.POSIXct(wlr.dat.all$Timestamp)
wlr.dat.all.sorted <- wlr.dat.all[order(wlr.dat.all$Timestamp, na.last=FALSE),]
wlr.dat.all <- subset(wlr.dat.all.sorted, select=c("Capacitance", "Stage", "Timestamp", "Discharge", "DepthDischarge"))
## names(wlr.dat.all) <- c("Capacitance", "Stage", "Timestamp", "Discharge")


wlr.dat.all <- wlr.dat.all[!is.na(wlr.dat.all$Stage),]


wlr.dat.all$Discharge <- round(wlr.dat.all$Discharge, digits=5)

##-- plot the nls fit
library(ggplot2)
ggplot(data = sd.fl, aes(Stage, Discharge)) + 
    geom_point(aes(position="jitter")) +
    ggtitle("SD curve for station 103") + labs(x = "Stage (m)", y = "Discharge (m3/s)") +
    theme(axis.title=element_text(size=14,face="bold"),
          axis.text=element_text(size=12)) +
    geom_smooth(formula=nls.res)


## grid <- with(mtcars, expand.grid(
##        wt = seq(min(wt), max(wt), length = 20),
##        cyl = levels(factor(cyl))
##      ))

## err <- stats::predict(model, newdata=grid, se = TRUE)
 ##     grid$ucl <- err$fit + 1.96 * err$se.fit
 ##     grid$lcl <- err$fit - 1.96 * err$se.fit
     
 ##     qplot(wt, mpg, data=mtcars, colour=factor(cyl)) +
 ##       geom_smooth(aes(ymin = lcl, ymax = ucl), data=grid, stat="identity")

grid <- with(sd.fl, expand.grid(Stage = seq(min(Stage), max(Stage), length=20), Dicharge = Discharge))                               
grid$model <-predict(nls.res, newdata=grid)

qplot(Stage, Discharge, data=sd.fl) +
                            geom_line(data=grid$model)

## qplot(wt, mpg, data=mtcars, colour=factor(cyl)) + geom_line(data=grid)
## work on getting the predict.nls working and set both interval and se.fit. Use the code above to fill into the ggplot figure.
predict(nls.res, newdata=grid,  se.fit=TRUE)


## from <http://stackoverflow.com/questions/14033551/r-plotting-confidence-bands-with-ggplot>
fit
