<<<<<<< Updated upstream
## this files contains the functions needed for the processing of sediment and nutrient data

##-- Get discharge filename
## generate the relevant filename for each time stamp in the sediment nutrient discharge
## dataset so as to optimise

## x is filename to be assigned, y is full path and filename to be read, rn is row name
read.csv.files <- function(x,y){
    assign(x, read.csv(y))
    x <- get(x)
    return(x)
}

read.merge.data <- function(stn.list){
    for (i in 1: length(stn.list)){ ## HEREH
        subset(merged.flnm, subset=dis.stn==stn.list)
        x <- eval(parse(text = paste("all.sed.data$", merged.flnm$int.samp.flnm[i], sep="")))
        x$date <- as.Date(x$date, format="%d/%m/%Y")
        x$Timestamp <- as.POSIXct(paste(x$date, x$time, sep=" "), tz="Asia/Kolkata")
        x$Timestamp <- round(x$Timestamp, "mins")
        x$time.num <- as.numeric(x$Timestamp)
        y <- eval(parse(text = paste("all.dis.data$", merged.flnm$dis.flnm[i], sep="")))
        y$Timestamp <- as.POSIXct(y$Timestamp, tz="Asia/Kolkata")
        y$time.num <- as.numeric(y$Timestamp)
        xy <- merge(x, y, by = "time.num", all=TRUE)
        data.exists <- xy[complete.cases(xy[,c(4,20)]),]
        if(nrow(data.exists)>0){
            out.name <- as.character(merged.flnm$int.samp.flnm[i])
            assign(out.name, xy)## (return(xy))
            out.name <- get(out.name)
            return(out.name)
        }
    }
}
=======
 ## this files contains the functions needed for the processing and visualisation of sediment and nutrient data.
## README.md file has more details

##---PART 1: DATA ORGANISATION----##

##-- Get discharge filename
## generate the relevant filenames

## set paths
set.path <- function(x){
  data.dir <- "~/CurrProj/CWC/Data"
  site.data.dir <- paste(data.dir, site.name, sep = "/") 
  dis.dir <- paste(site.data.dir, "discharge/csv", sep = "/")
  dis.flnm <<- list.files(dis.dir, full.names=FALSE)
  dis.full.flnm <<- list.files(dis.dir, full.names=TRUE)
  dis.stn <<- as.character(substr(dis.flnm, start=14, stop=16)) # use gsub
  dis.data.df <<- data.frame(dis.stn, dis.flnm, dis.full.flnm)
  int.samp.dir <<- list.dirs(paste(site.data.dir, "SedNut/raw/integrated", sep="/"), recursive=FALSE)
  int.samp.stn <<- as.character(gsub("[^[:digit:] ]", "", int.samp.dir))
  int.samp.flnm <<- unlist(lapply(int.samp.dir, list.files))
  int.samp.full.flnm <<- unlist(lapply(int.samp.dir, list.files, full.names=TRUE))
  int.samp.data.df <<- data.frame(int.samp.stn, int.samp.flnm, int.samp.full.flnm)
  stg.samp.dir <<- list.dirs(paste(site.data.dir, "SedNut/raw/stage", sep="/"), recursive=FALSE)
  stg.samp.stn <<- as.character(gsub("[^[:digit:] ]", "", stg.samp.dir))
  stg.samp.flnm <<- unlist(lapply(stg.samp.dir, list.files))
  stg.samp.full.flnm <<- unlist(lapply(stg.samp.dir, list.files, full.names=TRUE))
  stg.samp.data.df <<- data.frame(stg.samp.stn, stg.samp.flnm, stg.samp.full.flnm)
  ## output destinations
  csv.out.dir <<- paste0(site.data.dir, "/SedNut/csv/")
  fig.out.dir <<- paste0(site.data.dir, "/SedNut/fig/")
  print("Paths set")
}


## Read in csv files, if they are broken into seasonal chunks, bind them together.
## x is full filename
read.csv.files <- function(x){
  stn <- paste0("stn_",substr(as.character(gsub("[^[:digit:]]", "", x)), 0, 3))
  unq.stn <- unique(stn)
  if(sum(stn %in% unq.stn)>length(unq.stn)){
    dat <- lapply(unq.stn, function(i){
      j <- paste0("stn_", substr(as.character(gsub("[^[:digit:]]", "", x)), 0, 3))
      k <- do.call("rbind", lapply(x[j==i], read.csv, strip.white=TRUE))
      return(k)
    })
    names(dat) <- unq.stn
    return(dat)
  }else{
    dat <- lapply(x, read.csv, strip.white=TRUE)
    names(dat) <- unq.stn
    return(dat)
  }
}

## Modified to do one file at a time to save memory
## stn is list of stations to be processed
## df.stn is data frame containing file names of stations for both
## sediment sample and discharge files
## use lapply (FUN=merge.dat, X=stn, df.stn=int.dis.pairs)
merge.dat.int <- function(stn, df.stn){
  x <- unique(subset(df.stn, subset=int.samp.stn==stn, select = int.samp.full.flnm))
  x <- as.character(x[[1]])
  y <- unique(subset(df.stn, subset=int.samp.stn==stn, select = dis.full.flnm))
  y <- as.character(y[[1]])
  ## for all.int.data    
  dat.x <- read.csv.files(x)
  nm.x <- names(dat.x)
  dat.x <- dat.x[[1]]
  if(site.name == "Aghnashini") {dat.x$date <- as.Date(dat.x$date, format="%Y/%m/%d")
  }else{
      dat.x$date <- as.Date(dat.x$date, format="%d/%m/%Y")
  }
  dat.x$Timestamp <- as.POSIXct(paste(dat.x$date, dat.x$time, sep=" "), tz="Asia/Kolkata")
  dat.x$time.num <- as.numeric(dat.x$Timestamp)
  ## for all.dis.data
  dat.y <- read.csv.files(y)
  nm.y <- names(dat.y[1])
  dat.y <- dat.y[[1]]
  dat.y$Timestamp <- as.POSIXct(dat.y$Timestamp, tz="Asia/Kolkata")
  dat.y$time.num <- as.numeric(dat.y$Timestamp)
  sel.y <- dat.y[,c(7,2:6)][dat.y$time.num %in% dat.x$time.num,]
  ## merge
  xy <- merge(dat.x[,c(17,16,4:14)], sel.y, by = "time.num", all = TRUE)
  xy <- xy[!duplicated(xy),]
  names(xy)[2] <- "Timestamp"
  return(xy)
}

## write output of list of dataframes to csv
write.list.to.csv <- function(x, nm.x){
  out.file.nm <- paste0(csv.out.dir, "integrated/", nm.x, ".csv")
  write.csv(x, file = out.file.nm)
  print(paste0(out.file.nm, " written. \n"))
}


##-- this section deals with siphon/stage sampler data processing

##-- add columns for height of bottles to raw data. Using the qdap package
## x is filename, y is string to search for z is number to replace with

add.bottle.heights <- function(x, y){
  rep.tab <- read.csv(y, stringsAsFactors=FALSE) # y
  ## dat <- read.csv("/home/udumbu/rsb/CurrProj/CWC/Data/Nilgiris/SedNut/raw/stage/wlr_102/stg_102_march16.csv") #x
  x$bot.hgt <- as.numeric(mgsub(rep.tab$Position, rep.tab$Height_cm, x$bot.posn))
  return(x)
}

## select relevant WQ and discharge dataset
## trim the dis datset to two weeks from dates of wq sampler installation
subset.dis.data <- function(stn, df.stn, wqdat){
  x <- all.stg.data[names(all.stg.data)==paste0("stn_", stn)][[1]]
  y <- unique(subset(df.stn, subset=stg.samp.stn==stn, select = dis.full.flnm))
  y <- as.character(y[[1]])
  ## for all.dis.data
  dat.y <- read.csv.files(y)
  nm.y <- names(dat.y[1])
  dat.y <- dat.y[[1]]
  dat.y$Timestamp <- as.POSIXct(dat.y$Timestamp, tz="Asia/Kolkata")
  dat.y$numtime <- as.numeric(dat.y$Timestamp)
  x$date <- as.Date(x$date, format="%d/%m/%Y")
  x$Timestamp <- as.POSIXct(paste(x$date, as.character(x$time), sep=" "), tz="Asia/Kolkata")
  x$numtime <- as.numeric(x$Timestamp)
  ## now run lapply for all entries in x$numtime
  ## for each, select two weeks prior data from discharge
  ## note that timestamp and height measurements on sednut is on day of collection
  ## and not the day of installation of the unit
  ## rbind into a single file for subsequent processing
  sel.y <- do.call("rbind", lapply(x$numtime, dis=dat.y, function(nt, dis){
    end.numtime <- nt
    start.numtime <- nt - (14*24*60*60) # two weeks
    subset.y <- dat.y[dat.y$numtime >= start.numtime & dat.y$numtime <= end.numtime,]
    return(subset.y)
  }))
  ### sel.y <- unique(sel.y)
  sel.y <- sel.y[!duplicated(sel.y),]
  sel.y <- dat.y
  return(sel.y)
}


## get stage of bottles siphon or "stg" sampler by back calculating from the timestamp,
## of installation and depth of installation of the unit.
## x is name of dis.stn and all.stg.data.
## Note: the names of list elements should be the same.
## Get height of unit in lapply and extract from the dis dataframe
get.stg <- function(x, wq_data, dis_data){
  wqdat <- wq_data[[x]]
  disdat <- dis_data[[x]]
  disdat <- disdat[!is.na(disdat$Discharge),] # remove where discharge is NA
  wqdat$date <- as.Date(wqdat$date, format="%d/%m/%Y")
  wqdat$Timestamp <- as.POSIXct(paste(wqdat$date, wqdat$time, sep=" "), tz="Asia/Kolkata")
  wqdat$Timestamp <- round(wqdat$Timestamp, "mins")
  wqdat$numtime <- as.numeric(wqdat$Timestamp)
  ## Following section takes stage from discharge data wherever
  ## water quality height has not been recorded - all Aghnashini siphon
  ## but also some Nilgiris data has this problem
  ## wqdat <- wqdat[!is.na(wqdat$wtr.hgt.cm),] # Changed
  dis.stg <- disdat$Stage[match(wqdat$numtime, disdat$numtime)]
  wqdat$wtr.hgt.cm[is.na(wqdat$wtr.hgt.cm)] <- dis.stg * 100
  ##--- finished harvesting stage from discharge dataset ---##
  
  ## harvested data from discharge dataset
  wqdat$wtr.hgt.cm <- as.numeric(wqdat$wtr.hgt.cm)
  i <- paste0(wqdat$numtime, wqdat$bot.posn)
  xy <- do.call("rbind",
    lapply(X = i, j=wqdat, k = disdat, FUN = function(i, j, k){ 
      ## get dis.stage from timestamp
      wqrow <- wqdat[paste0(wqdat$numtime, wqdat$bot.posn)==i,] # i
      dis.stg <- disdat$Stage[disdat$numtime==wqrow$numtime]
      if(length(dis.stg)>0){
        hgt.dif <- dis.stg - (wqrow$wtr.hgt.cm/100) # bot.hgt is in cm
        bot.stg <- hgt.dif + (wqrow$bot.hgt/100)
        err.txt <- paste("Bottle height", bot.stg, "on", wqrow$Timestamp,
          "for stn_", wqrow$wlr.no, "bottle no",
          wqrow$bot.posn)
        if(!is.na(bot.stg) & bot.stg > 0){ # check for na in case discharge is missing
          dis.cnd <- disdat[disdat$Stage>=bot.stg,] # discharge candidates
          if(nrow(dis.cnd) > 0  & # shld have data
               nrow(dis.cnd[dis.cnd$numtime<wqrow$numtime,])>0){ # before
            dis.cnd <- dis.cnd[dis.cnd$numtime<wqrow$numtime &
                                 dis.cnd$numtime>wqrow$numtime -
                                 (60*60*24*10),] # 10 days
            if(nrow(dis.cnd)>0){
              sel.dis <- dis.cnd[which((wqrow$numtime - dis.cnd$numtime)==
                                         max(wqrow$numtime - dis.cnd$numtime,
                                           na.rm = TRUE)),]
              sel.dis <- unique(sel.dis)
              wtr.dis.dat <- cbind(sel.dis, wqrow)
              colnames(wtr.dis.dat)[4] <- "Samp_Timestamp"
              colnames(wtr.dis.dat)[29] <- "Inst_Timestamp"
              wtr.dis.dat <- wtr.dis.dat[,c(2:6, 11:29)]
              return(wtr.dis.dat)
            } else {
              print(paste("No discharge for", err.txt))
              return(NULL)
            }
          } else {
            print(paste("No discharge in specified time period for", err.txt))
            return(NULL)  
          }
        } else {
          print(paste("Siphon unit set too high for",err.txt))
          return(NULL)  
        }
      } else {
        print(paste("There is no stage reading for sample from",
          wqrow$Timestamp, "for stn_", wqrow$wlr.no,
          "bottle no", wqrow$bot.posn))
        return(NULL)  
      }
    })
  )
  ## names(xy)[3] <- "Timestamp" # Changed
  ## write.csv(x = errors, file = paste0(csv.out.dir, "/stage/errors.csv")) # uncomment to record errors
  return(xy)
}

##---END OF DATA PROCESSING---##

##---PART 2: PLOTTING----##

## Plot water quality parameters in a grid
## Code modified from <https://mcfromnz.wordpress.com/2011/06/09/gridextra-multiple-plots-from-ggplot2/>
plot.param <- function(x, nm.x){
    ggdat <- melt(x, measure.vars = c(11:13), id.vars = c("Discharge", "Timestamp"), variable.name = "Parameter") # measure.vars = c(3:13) ## only sed, no3 and po4
    ggdat$value <- as.numeric(ggdat$value)
    ggdat$date <- as.Date(ggdat$Timestamp)
    out <- by(data = ggdat, INDICES = ggdat$Parameter, FUN = function(m) {
        m <- droplevels(m) 
        m <- ggplot(data=m, aes(Discharge, value, label= date)) +
            geom_point(data = m, aes(Discharge, value, color = value), size = 1) +
            geom_text(size=1, angle=45, position="jitter") + 
            scale_color_continuous(low = 'green', high = 'red', name = "") +
            theme(legend.position="none") +
            xlab(NULL) +
            ylab(NULL) +
            facet_wrap( ~ Parameter, scales = "free", ncol = 3) 
    })
    ## geom_smooth(method="loess", se=T)
    grb.out <- do.call(arrangeGrob, out)
    png.out <- paste0(fig.out.dir, "integrated/Scatter_Conc_vs_Discharge", nm.x, ".png")
    png(filename = png.out, width = 12, height = 9, units = "in", res = 200)
    print(grid.arrange(grb.out, bottom=textGrob(expression(Discharge~m^{3}~Sec^{-1}), gp=gpar(fontsize=14)), left=textGrob("Concentration", rot=90,gp=gpar(fontsize=14))))
    dev.off()
}

## Plot water quality parameters in a grid
plot.stg.dis <- function(x, nm.x){
    if(site.name == "Nilgiris") mvars <- c(17:21) else mvars <- c(16:18) # nilgiri c(9:21), agn c(10:18)
    ggdat <- melt(x, measure.vars = mvars, id.vars = c("Discharge", "Samp_Timestamp"), variable.name = "Parameter")
    ggdat$value <- as.numeric(ggdat$value)
    ggdat$date <- as.Date(ggdat$Samp_Timestamp)
    out <- by(data = ggdat, INDICES = ggdat$Parameter, FUN = function(m) {
        m <- droplevels(m)    
        m <- ggplot(data=m, aes(Discharge, value, label= date)) +
            geom_point(data = m, aes(Discharge, value, color = value), size = 1) +
            geom_text(size=1, angle=45, position="jitter") + 
            scale_color_continuous(low = 'green', high = 'red', name = "") +
            theme(legend.position="none") +
            xlab(NULL) +
            ylab(NULL) +
            facet_wrap( ~ Parameter, scales = "free", ncol = 3)
    })
    ## geom_smooth(method="loess", se=T)
    grb.out <- do.call(arrangeGrob, out)
    png.out <- paste0(fig.out.dir, "stage/Scatter_Conc_vs_Discharge", nm.x, ".png")
    png(filename = png.out, width = 12, height = 9, units = "in", res = 200)
    print(grid.arrange(grb.out, bottom=textGrob(expression(Discharge~m^{3}~Sec^{-1}), gp=gpar(fontsize=14)), left=textGrob("Concentration", rot=90,gp=gpar(fontsize=14))))
    dev.off()
}

## write output of list of dataframes to csv
write.stg.dis.to.csv <- function(x, nm.x){
  out.file.nm <- paste0(csv.out.dir, "stage/", nm.x, ".csv")
  write.csv(x, file = out.file.nm)
  print(paste0(out.file.nm, " written. \n"))
}


## Average catchment rain fall
## given the variation in rainfall no single rg can be used
## various sophisticated measurements are possible.
## we opt for simple averageing for now
## input is list of raingauges for each catchment named after wlr station
## input format should be as in file "~/CurrProj/CWC/Anl/sitewise_unintsname.csv"
AvgRain <- function(x){
    stn.pairs <- read.csv(file = x, colClasses = c(rep("character", 3)))
    if(site.name == "Aghnashini"){
       stn.pairs <- stn.pairs[as.numeric(stn.pairs$stn) < 100,]
    }else{
        stn.pairs <- stn.pairs[as.numeric(stn.pairs$stn) > 100,]
    }
    stn.pairs <- stn.pairs[stn.pairs$log.type=="tbrg",]
    stn.no <- unique(stn.pairs$stn)
    stn.tbrg <- lapply(stn.no, function(x)(stn.pairs$log.id[x==stn.pairs$stn]))
    names(stn.tbrg) <- unique(stn.pairs$stn)
    stn.tbrg <- lapply(stn.tbrg, function(x)(
        paste0("~/CurrProj/CWC/Data/", site.name,"/tbrg/csv/tbrg_", x, "_1 day.csv")))
    tbrg.dat <- lapply(stn.tbrg, function(y)(do.call(rbind, lapply(y, read.csv))))
    avg.tbrg.dat <- lapply(tbrg.dat, function(x)(stats::aggregate(mm ~ dt.tm, x, mean)))
    return(avg.tbrg.dat)
}

## Plot using a modified version of Landson's script
## Need to fill in the time series not just dates of sediment capture
## Add in a line for rainfall from a nearby rain gauge (to be interpolated in later versions)
## x is list of wlr stations with sediment as character
## y is list of relevant tbrg stations as character
## use : mapply(FUN = plot.nutconc, stn=stn.pairs.wlr, tbrg.no=stn.pairs.tbrg, SIMPLIFY = FALSE)
## where stn.pairs is the pairs of wlr stations and tbrg where water quality has been measured.
## HERE Needs fixing. Doesn't run for grab samplers where siphon units are set.
## Should run for both, first one then the other.


plot.nutconc <- function(stn, tbrg.dat, wq.dat){ 
    stn.no <- gsub(pattern = "[^0-9]", replacement = "", x = stn)
    tbrg <- tbrg.dat[[stn.no]]
    x <- wq.dat[[stn]]
    nm.x <- names(x)
    if(ncol(x) == 19) { # 19 is grab 24 is siphon
        names(x)[2] <- "Samp_Timestamp"
        measure.vars <- c(12:14)
        png.out <- paste0(fig.out.dir, "integrated/Hyd.WtrQl", stn, ".png")
        csv.out <- paste0(csv.out.dir, "integrated/Hyd.WtrQl", stn, ".csv")
    }
    if (ncol(x) == 24 & site.name == "Aghnashini") {
        png.out <- paste0(fig.out.dir, "stage/Hyd.WtrQl", stn, ".png")
        csv.out <- paste0(csv.out.dir, "stage/Hyd.WtrQl", stn, ".csv")
        measure.vars <- c(17:19)        
    }

    if(ncol(x)==24 & site.name=="Nilgiris"){
        png.out <- paste0(fig.out.dir, "stage/Hyd.WtrQl", stn, ".png")
        csv.out <- paste0(csv.out.dir, "stage/Hyd.WtrQl", stn, ".csv")
        measure.vars <- c(18:21) 
    }
    ## tbrg <- y
    tbrg$dt <- as.Date(tbrg$dt.tm, format = "%Y-%m-%d")
    dis.files <- as.list(dis.full.flnm[grep(pattern = stn.no, dis.full.flnm)])
    dis.dat <- read.csv.files(dis.files)
    dis.dat <- dis.dat[[1]]
    dis.dat$Timestamp <- as.POSIXct(x = dis.dat$Timestamp, tz = "Asia/Kolkata")
    ## aggregate to daily
    print(paste("Averaging daily discharge for WLR No.", stn))
    charvec <- dis.dat$Timestamp
    start.time <- min(dis.dat$Timestamp)
    end.time <- max(dis.dat$Timestamp)
    dis <- dis.dat$Discharge
    ts.dis <- timeSeries(data=dis, charvec=charvec)
    by <- timeSequence(from=start.time, to=end.time,
                       by="1 day", FinCenter = "Asia/Calcutta")
    dat <- aggregate(ts.dis, by, mean)
    dat$Date<-row.names(dat)
    dat <- as.data.frame(dat)
    row.names(dat) <- NULL
    dat$Date <- as.POSIXct(dat$Date, tz="Asia/Kolkata", origin="1970-01-01",usetz=TRUE) # add timestamp back to datframe
    ## get the sediment data    
    x$Date <- round(x$Samp_Timestamp, "day")
    start.dt <- round(min(x$Date, na.rm = TRUE) - 7, "day") # start one week before first date
    end.dt <- round(max(x$Date, na.rm = TRUE) + 7, "day") # end one week after last date
    tint.daily <- seq.POSIXt(start.dt, end.dt,by="1 day",na.rm=TRUE)
    tmstmps <- tint.daily[!(as.numeric(tint.daily)
        %in% as.numeric(x$Date))] # get missing timestamps
    x.new <- as.data.frame(lapply(x, function(i)
        rep.int(NA, length(tmstmps)))) # create container
    x.new$Samp_Timestamp <- as.POSIXct(x.new$Samp_Timestamp, tz = "Asia/Kolkata")
    x.new$Date <- tmstmps
    x <- rbind(x.new, x)
    x <- x[order(x$Date),]
    x$dt <- as.Date(x$Date, "%Y-%m-%d")
    dat$dt <- as.Date(dat$Date, "%Y-%m-%d")
    merged.x.dat <-  merge(x, dat, by="dt")
    merged.x.dat <- merge(merged.x.dat, tbrg, by= "dt")
    names(merged.x.dat)[names(merged.x.dat)=="TS.1"] <- "Daily.Discharge"
    names(merged.x.dat)[names(merged.x.dat)=="mm"] <- "Daily.Rain"
    ggdat <- melt(merged.x.dat, measure.vars = measure.vars, id.vars = c("dt", "Discharge", "Samp_Timestamp", "Daily.Discharge", "Daily.Rain"), variable.name = "Parameter")
    ggdat$value <- as.numeric(ggdat$value)
    ggdat$Discharge <- as.numeric(ggdat$Discharge)
    ggdat$Daily.Discharge <- as.numeric(ggdat$Daily.Discharge)
    ggdat$Daily.Rain <- as.numeric(ggdat$Daily.Rain)
    write.csv(x = ggdat, file = csv.out)
    print(paste("File", csv.out, "written."))
    out <- by(data = ggdat, INDICES = ggdat$Parameter, FUN = function(m) {
        ## m <- ggdat[ggdat$Parameter == "coll.temp",]
        m <- droplevels(m)    
        ggplot(data=m, aes(dt)) +
            theme_bw() +
            geom_line(aes(y = Daily.Rain/100, colour = "Daily Rain (dm)"),
                      colour = "grey50", linetype = "solid") + 
            geom_line(aes(y = Daily.Discharge, colour = "Daily Discharge"),
                      colour = "grey30", linetype = "dotted") +
            geom_point(aes(y = Discharge, fill = value), pch=21, size=2,
                       colour="black", stroke = 0.1) +
            scale_fill_continuous(low = 'green', high = 'red',
                                  name = "Concentration", na.value = "transparent") +
            guides(fill = guide_colorbar(barwidth = 5.5, barheight = 0.5, label.theme = element_text(colour = "black", angle = 0, size = 6))) +
            theme(legend.position="bottom") +
            xlab(NULL) +
            ylab(NULL) +
            facet_wrap( ~ Parameter, scales = "free", ncol = 3)
    })
    grb.out <- do.call(arrangeGrob, out)
    x.lab <- textGrob("Date", gp=gpar(fontsize=14))
    y.lab <- textGrob(expression(Discharge~m^{3}~Sec^{-1}), rot=90,gp=gpar(fontsize=14))
    leg <- legendGrob(c("Daily Rain (dm)", "Discharge"), do.lines = TRUE, ncol = 1, nrow = 2, gp=gpar(col=c("grey50", "grey30"), lwd = 2, lty = c("solid", "dotted"))) ## , vp = viewport(width=0.8, height=10.8))
    png(filename = png.out, width = 3200, height = 3200, res = 300)
    print(grid.arrange(grb.out, left=y.lab, right=leg, bottom=x.lab))
    dev.off()
}

## Do a faced_wrap on the specified files
## Supply file name and station ID (or name) in two separate lists.
## call: mapply(FUN = plot.conc.sed, full.file.name, stationID)

read.bind <- function(x,y){
    tmp <- read.csv(x)
    tmp$UnitID <- y
    return(tmp)
}

plot.conc <- function(x, param, png.out, min.x, max.x){
    ggdat$dt <- as.Date(ggdat$dt)
    ggdat <- ggdat[ggdat$Parameter==param,]
    leg.name <- "Concentration mg/l"
    out <- ggplot(data=ggdat, aes(dt)) +
        theme_bw() +
        geom_line(aes(y = Daily.Rain/100, colour = "Daily Rain (dm)"),
                  colour = "grey50", linetype = "solid", show.legend = TRUE) + 
        geom_line(aes(y = Daily.Discharge, colour = "Daily Discharge"),
                  colour = "grey30", linetype = "dotted") +
        geom_point(aes(y = Discharge, fill = value), pch=21, size=3,
                   colour="black", stroke = 0.1) +
        scale_fill_continuous(low = 'green', high = 'red',limits = c(min.x, max.x)
                            , na.value = "transparent") +
        guides(fill = guide_colorbar(barwidth = 20, 
                                     barheight = 0.75, 
                                     label.theme = element_text(colour = "black",
                                                                angle = 0, size = 8))) +
        theme(legend.position="bottom") +
            xlab("Date") +
            ylab(expression(Discharge~m^{3}~Sec^{-1})) +
        facet_wrap( ~ UnitID, ncol = 1)
    leg <- legendGrob(c("Daily Rain (dm)", "Discharge"), do.lines = TRUE, ncol = 1, nrow = 2, gp=gpar(col=c("grey50", "grey30"), lwd = 2, lty = c("solid", "dotted")))
    png(filename = png.out, width = 2400, height = 2400, res = 300)
    grid.arrange(out, right = leg)
    dev.off()
    return(grid.arrange(out, right = leg))
}

plot.hist.conc <- function(x){
    ggplot(data=x, aes(value)) +
        theme_bw() +
        ## geom_density() +   # no point data not normal
        geom_histogram()+
        facet_wrap( ~ Parameter, scales = "free", ncol = 1)
}

## Create boxplots from each station based on dominant land cover
## Note: each station is kept separate
## operates on both grab and multi-stage sampler.
## x is grab or siphon sampler dataset, y is start of col to plot
## z is end col to plot for measure variables (ggplot2)
## call as: bxplt.cover(grab.dis.res) or bxplt.cover(siphon.dis.res)

##-- function to add stats to the boxplot from <https://stackoverflow.com/questions/3483203/create-a-boxplot-in-r-that-labels-a-box-with-the-sample-size-n>

give.n <- function(x){
    return(c(y = max(x, na.rm=TRUE) + mean(x), label = length(x))) #mean(x)
}

bxplt.cover <- function(x){
    if(length(names(x[[1]]))<20 & site.name == "Nilgiris"){
        x.cover <-  as.list(c("Wattle", "Wattle", "Wattle", "Scotchbroom", "Wattle", "Scotchbroom", "Grassland", "Shola", "Shola", "Wattle", "Wattle"))
        m.v.start <- 11 # 5 only sed, no3 and po4
        m.v.end <- 13
        m.v.load.start <- 11
        m.v.load.end <- 13
        fig.out <- paste0(fig.out.dir, "/integrated/Grab.Cover.WtrQl.png")
        load.fig.out <- paste0(fig.out.dir, "/integrated/Grab.Cover.WtrQl.Load.png")
        ## csv.out <- paste0(csv.out.dir, "/integrated/Grab.Cover.WtrQl.TukeyHSD.csv")
        out.dir <- paste0(csv.out.dir, "integrated/TukeyHSD.Grab.Cover.WtrQl_")
    }    
    if(length(names(x[[1]]))==24 & site.name == "Nilgiris"){
        x.cover <- as.list(c("Wattle", "Scotchbroom", "Grassland", "Shola"))
        m.v.start <-  17# 11
        m.v.end <- 20
        m.v.load.start <- 17
        m.v.load.end <- 20
        fig.out <- paste0(fig.out.dir, "/stage/Siphon.Cover.WtrQl.Conc.png")
        load.fig.out <- paste0(fig.out.dir, "/stage/Siphon.Cover.WtrQl.Load.png")
        ## csv.out <- paste0(csv.out.dir, "/stage/Siphon.Cover.WtrQl.TukeyHSD.csv")
        out.dir <- paste0(csv.out.dir, "stage/TukeyHSD.Siphon.Cover.WtrQl_")
    }
    if(length(names(x[[1]]))<20 & site.name == "Aghnashini"){
        x.cover <-  as.list(c("Forest Dominated", "Agriculture Dominated"))
        m.v.start <- 11 # 5
        m.v.end <- 13
        m.v.load.start <- 11
        m.v.load.end <- 13
        fig.out <- paste0(fig.out.dir, "/integrated/Grab.Cover.WtrQl.png")
        load.fig.out <- paste0(fig.out.dir, "/integrated/Grab.Cover.WtrQl.Load.png")
        ## csv.out <- paste0(csv.out.dir, "/integrated/Grab.Cover.WtrQl.TukeyHSD.csv")
        out.dir <- paste0(csv.out.dir, "integrated/TukeyHSD.Grab.Cover.WtrQl_")
    }
    if(length(names(x[[1]]))>20 & site.name == "Aghnashini"){
        x.cover <- as.list(c("Forest Dominated", "Agriculture Dominated"))
        m.v.start <- 16 #10
        m.v.end <- 18
        m.v.load.start <- 16
        m.v.load.end <- 18
        fig.out <- paste0(fig.out.dir, "/stage/Siphon.Cover.WtrQl.Conc.png")
        load.fig.out <- paste0(fig.out.dir, "/stage/Siphon.Cover.WtrQl.Load.png")
        ## csv.out <- paste0(csv.out.dir, "/stage/Siphon.Cover.WtrQl.TukeyHSD.csv")
        out.dir <- paste0(csv.out.dir, "stage/TukeyHSD.Siphon.Cover.WtrQl_")
    }
    x <- mapply(cbind, x, "Cover"=x.cover, SIMPLIFY=F)# add cover name as column
    x <- do.call(rbind, x) # bind to single dataframe

    if(length(names(x))<25 & site.name == "Nilgiris"){
        names(x)[c(2, 11, 12, 13)] <- c("Timestamp", "Sediment", "Nitrates", "Phosphates")
    }
    if(length(names(x))==25 & site.name == "Nilgiris"){
        names(x)[c(3, 17, 18, 19, 20)] <- c("Timestamp", "Sediment", "Nitrates", "Phosphates", "Dissolved Carbon") ## , "Dissolved Nitrogen"
    }
    if(length(names(x))==20 & site.name == "Aghnashini"){
        names(x)[c(2, 11, 12, 13)] <- c("Timestamp", "Sediment", "Nitrates", "Phosphates")
    }
    if(length(names(x))>20 & site.name == "Aghnashini"){
        names(x)[c(3, 16, 17, 18)] <- c("Timestamp", "Sediment", "Nitrates", "Phosphates")
    }
    
    
    x$Date <- as.Date(x$Timestamp, "%Y-%m-%d")
    
    gg.dat <- melt(x, measure.vars = c(m.v.start:m.v.end), id.vars = c("Date", "Discharge", "DepthDischarge", "Timestamp", "Cover"), variable.name = "Parameter")
    gg.dat$value <- as.numeric(gg.dat$value)
    gg.dat <- gg.dat[!is.na(gg.dat$value),]
    plt <- ggplot(gg.dat, aes(x = Cover, y = value, colour = Discharge)) +
        geom_boxplot(notch = FALSE) + 
        facet_wrap( ~ Parameter, scales = "free", ncol = 3) +
        ## stat_summary(fun.y=mean, geom="point", shape=5, size=4)+
        labs(x = "Land Cover", y = "Concentration") +
        theme(legend.position="none") +
        stat_summary(fun.data = give.n, geom = "text", vjust = 0) 
    print(plt)
    ggsave(filename = fig.out, width = 12, height = 9, units = "in")

gg.dat <- melt(x, measure.vars = c(m.v.load.start:m.v.load.end), id.vars = c("Date", "Discharge", "DepthDischarge", "Timestamp", "Cover"), variable.name = "Parameter")
    gg.dat$value <- as.numeric(gg.dat$value)
    gg.dat$LoadKgcum <- gg.dat$value * 0.001 # mg/l*0.001 = kg/m^3
    gg.dat$Load <- gg.dat$LoadKgcum * gg.dat$DepthDischarge * 3600 * 10000 ## HERE per ha
    gg.dat <- gg.dat[!is.na(gg.dat$Load),]
    plt <- ggplot(gg.dat, aes(x = Cover, y = Load, colour = Discharge)) +
        geom_boxplot(notch = FALSE) + 
        facet_wrap( ~ Parameter, scales = "free", nrow = 3) +
        ## stat_summary(fun.y=mean, geom="point", shape=5, size=4)+
        labs(x = "Land Cover", y = "Load in kg. per hour per hectare") +
        theme(legend.position="none")+
        stat_summary(fun.data = give.n, geom = "text", vjust = 0) 
    print(plt)
    ggsave(filename = load.fig.out, width = 12, height = 9, units = "in")
    
    ## Stats
    tmp <- with(gg.dat,
                by(gg.dat, Parameter,
                   function(x) aov(value ~ Cover, data = x)))
    hsd.res <- sapply(tmp, TukeyHSD)
    nm.x <- names(hsd.res)
    mapply(
        function(x, nm.x)(write.csv(x, file = paste0(out.dir, nm.x, ".csv")))
      , x = hsd.res, nm.x = nm.x)
    return(hsd.res)
}

## boxplots of all instantaneous nutrient or sediment loads in kg/ha/minute or kg/ha/hr with land cover or land use or station no on x axis.

bxplt.stn <- function(x){
    x <- do.call("rbind",
                 lapply(x, function(y){
                     if(length(names(y))<20 & site.name == "Nilgiris"){
                         m.v.start <<- 11 #5
                         m.v.end <<- 13
                         m.v.load.start <<- 11
                         m.v.load.end <<- 13
                         fig.out <<- paste0(fig.out.dir, "/integrated/Grab.Stn.WtrQl.png")
                         load.fig.out <<- paste0(fig.out.dir, "/integrated/Grab.Stn.WtrQl.Load.png")
                         csv.out <<- paste0(csv.out.dir, "/integrated/Grab.Stn.WtrQl.TukeyHSD.csv")
                         out.dir <<- paste0(csv.out.dir, "integrated/TukeyHSD.Grab.Stn.WtrQl_")
                     }    
                     if(length(names(y))>20 & site.name == "Nilgiris"){
                         m.v.start <<- 17 # 11
                         m.v.end <<- 21
                         m.v.load.start <<- 17
                         m.v.load.end <<- 21
                         fig.out <<- paste0(fig.out.dir, "/stage/Siphon.Cover.WtrQl.Conc.png")
                         load.fig.out <<- paste0(fig.out.dir, "/stage/Siphon.Cover.WtrQl.Load.png")
                         csv.out <<- paste0(csv.out.dir, "/stage/Siphon.Cover.WtrQl.TukeyHSD.csv")
                         out.dir <<- paste0(csv.out.dir, "stage/TukeyHSD.Siphon.Cover.WtrQl_")
                         names(y)[3] <- "Timestamp"
                     }
                     if(length(names(y))<20 & site.name == "Aghnashini"){
                         m.v.start <<- 11 #5
                         m.v.end <<- 13
                         m.v.load.start <<- 11
                         m.v.load.end <<- 13
                         fig.out <<- paste0(fig.out.dir, "/integrated/Grab.Stn.WtrQl.png")
                         load.fig.out <<- paste0(fig.out.dir, "/integrated/Grab.Stn.WtrQl.Load.png")
                         csv.out <<- paste0(csv.out.dir, "/integrated/Grab.Stn.WtrQl.TukeyHSD.csv")
                         out.dir <<- paste0(csv.out.dir, "integrated/TukeyHSD.Grab.Stn.WtrQl_")
                     }
                     if(length(names(y))>20 & site.name == "Aghnashini"){
                         m.v.start <<- 16 #10
                         m.v.end <<- 18
                         m.v.load.start <<- 16
                         m.v.load.end <<- 18
                         fig.out <<- paste0(fig.out.dir, "/stage/Siphon.Stn.WtrQl.Conc.png")
                         load.fig.out <<- paste0(fig.out.dir, "/stage/Siphon.Stn.WtrQl.Load.png")
                         csv.out <<- paste0(csv.out.dir, "/stage/Siphon.Stn.WtrQl.TukeyHSD.csv")
                         out.dir <<- paste0(csv.out.dir, "stage/TukeyHSD.Siphon.Stn.WtrQl_")
                     }
                     return(y)
                 }))
    x$Date <- as.Date(x$Timestamp, "%Y-%m-%d")
    x$Station <- as.factor(substr(row.names(x), start = 1, stop = 7)) # x$wlr.no)
    gg.dat <- melt(x, measure.vars = c(m.v.start:m.v.end), id.vars = c("Station", "Discharge", "DepthDischarge", "Timestamp"), variable.name = "Parameter")
    gg.dat$value <- as.numeric(gg.dat$value)
    gg.dat <- gg.dat[!is.na(gg.dat$value),]
    plt <- ggplot(gg.dat, aes(x = Station, y = value, colour = value)) +
        geom_boxplot(notch = FALSE) + 
        facet_wrap( ~ Parameter, scales = "free", ncol = 3) +
        ## stat_summary(fun.y=mean, geom="point", shape=5, size=4)+
        labs(x = "Station Number", y = "Concentration") +
        theme(legend.position="none")
    print(plt)
    ggsave(filename = fig.out, width = 12, height = 9, units = "in")
    
    gg.dat <- melt(x, measure.vars = c(m.v.load.start:m.v.load.end), id.vars = c("Station", "Discharge", "DepthDischarge", "Timestamp"), variable.name = "Parameter")
    gg.dat$value <- as.numeric(gg.dat$value)
    gg.dat$LoadKgcum <- gg.dat$value * 0.001 # mg/l*0.001 = kg/m^3
    gg.dat$Load <- gg.dat$LoadKgcum * gg.dat$DepthDischarge * 3600 * 10000
    gg.dat <- gg.dat[!is.na(gg.dat$Load),]
    plt <- ggplot(gg.dat, aes(x = Station, y = Load, colour = value)) +
        geom_boxplot(notch = FALSE) + 
        facet_wrap( ~ Parameter, scales = "free", nrow = 3) +
        ## stat_summary(fun.y=mean, geom="point", shape=5, size=4)+
        labs(x = "Station Number", y = "Load in kg. per hour per hectare") +
        theme(legend.position="none")
    print(plt)
    ggsave(filename = load.fig.out, width = 12, height = 9, units = "in")
    
    ## Stats
    tmp <- with(gg.dat,
                by(gg.dat, Parameter,
                   function(x) aov(value ~ Station, data = x)))
    hsd.res <- sapply(tmp, TukeyHSD)
    nm.x <- names(hsd.res)
    mapply(
        function(x, nm.x)(write.csv(x, file = paste0(out.dir, nm.x, ".csv")))
      , x = hsd.res, nm.x = nm.x)
    return(hsd.res)
    rm(m.v.start, m.v.end, m.v.load.start, m.v.load.end, fig.out, out.dir, csv.out) # clean up
}

## Functions to derive cumulative values for wetness and rainfall.

get.stdate <- function(x, y){ # x is x.y, y is yr
    st <- as.POSIXct(paste0(y, "-06-05 00:00"), tz = "Asia/Kolkata")
    if((x - st) > (86400 * 7)){ # one week
        st.date <- as.POSIXct(paste0(y-1, "-06-05 00:00"), tz = "Asia/Kolkata")
    } else {
        st.date <- as.POSIXct(paste0(y, "-06-05 00:00"), tz = "Asia/Kolkata")
    }
    return(st.date)
}

build.stm <- function(x, col1, col2){ #x is x.y, y is data to be cumulated
    st.date <- as.numeric(as.POSIXct(x[, col1], tz = "Asia/Kolkata"))
    end.date <- as.numeric(as.POSIXct(x[,col2], tz = "Asia/Kolkata"))
    stm <- paste0("rain.dat[y > ", st.date, " & y < ", end.date, ",]")
    return(stm)   
}




##---END OF DATA VISUALISATION---##
>>>>>>> Stashed changes
