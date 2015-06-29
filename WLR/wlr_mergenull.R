for(i in 1:length(num_wlr)){
    wlrmergedcsv <- paste(csvdir, num_wlr[i], "_onemin.merged.csv", sep="")
    wlr.fill.onemin<-paste("wlr_", num_wlr[i],"onemin", sep="")
    wlr.null.onemin<-paste("wlr_", num_wlr[i],"null", sep="")
    wlr.merged.onemin<-paste("wlr_", num_wlr[i],"merged", sep="")
    wlr.raw <- get(wlr.fill.onemin)
    raw <- subset(wlr.raw, select=c("raw", "cal", "date_time"))
    ## raw$date_time <- as.POSIXct(raw$date_time, tz="Asia/Kolkata")
if (exists(wlr.null.onemin)){
    wlr.null <- get(wlr.null.onemin)
    null <- subset(wlr.null, select=c("raw", "cal", "date_time"))
    ## null$date_time <- as.POSIXct(null$date_time, tz="Asia/Kolkata")
    
    ## 1) set all of nulls to -999
    null[is.na(null)] <- -999
    ## 2) do a merge using:
    tmp.merge <- merge(raw, null, by="date_time", all=TRUE)
    ## 3) set all NAs in the merge to 1
    tmp.merge[is.na(tmp.merge)] <- 0 # changed to 0 from 1
    ## 4) create a pre-final data frame by:
    ## tmp <- data.frame(raw=tmp.merge$raw.x, cal=tmp.merge$cal.x*tmp.merge$cal.y, date_time=tmp.merge$date_time)
    tmp <- data.frame(raw=tmp.merge$raw.x, cal=tmp.merge$cal.x+tmp.merge$cal.y, date_time=tmp.merge$date_time)
    ## 5) replace all negative values with NAs
    tmp[tmp<0] <- NA
    rawnull <- tmp
    rawnull$date_time <- as.POSIXct(rawnull$date_time)
    rawnull$date_time <- round(rawnull$date_time, "mins")
    rawnull <-  rawnull[!duplicated(rawnull$date_time), ]
##    rawnull$date_time <- rawnull$date_time + 19800 ## add five and half hours
    
    ##--- dump the outputs to files and r objects-----##
    write.csv(rawnull, file=wlrmergedcsv, row.names=FALSE)
    assign(wlr.merged.onemin, rawnull) # assign the output to an R object named after each wlr
} else
{
    ## wlr.null <- raw[0,]
    fill <- get(wlr.fill.onemin)
    fill <- subset(fill, select=c("raw", "cal", "date_time"))
    fill$date_time <- as.POSIXct(fill$date_time)
    fill$date_time <- round(fill$date_time, "mins")
    fill <-  fill[!duplicated(fill$date_time), ]
    
    write.csv(fill, file=wlrmergedcsv, row.names=FALSE)
    assign(wlr.merged.onemin, fill) # assign the import file to R object
}
}
