## This script should work on both Linux and Mac but probably not Windows
## Updated Wed Oct 16 07:27:49 IST 2013
## Meant to be run as routine so database connections handled by parent

dir_calib_wlr<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/calib/" # fix this according to your directory
dir_calib_res<-"/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/calibres/" # fix this according to your directory
wlr_calib_list <- system(paste("ls", dir_calib_wlr, sep=" "), intern=TRUE)
col_names <- c("y", "x")
## Create table to hold calibration results.
stm <- paste("DROP TABLE IF EXISTS nilgiris.wlr_calib; 
CREATE TABLE nilgiris.wlr_calib
(id SERIAL PRIMARY KEY, wlr_id TEXT, intercept REAL, x REAL);", sep="")
rs <- dbSendQuery(con, stm)
  rm(stm)

## Loop to build calibration from raw observations

for (i in 1: length(wlr_calib_list)){
    wlr_nme <- substr(wlr_calib_list[i], 1,7) # hold name of wlr
    sh_stm <- paste("tail -n +7 ", dir_calib_wlr, wlr_calib_list[i]," > tmp",i,  sep="") # create the shell statement
    system(sh_stm) # run the statement, assign the values to the wlr name (tmp)
    tmp <- read.table(paste("./tmp", i, sep=""), col.names=col_names)
    lmtmp <- lm(tmp$y~tmp$x) # run the linear regression
    summary_lmtmp <- summary(lmtmp) # output the results into a temporary file
    out <- capture.output(summary_lmtmp) # save them to a temporary file for recording
    outsum <- paste(dir_calib_res, wlr_nme, ".txt", sep="") # define output text file
    outcoef <- paste(dir_calib_res, wlr_nme, ".csv", sep="") # define output intercept file
    cat(out,file=outsum,sep="\n",append=TRUE) # dump to the text file
    ## Now plot the regression and abline
    outfig <- paste(dir_calib_res, wlr_nme, ".png", sep="") # define output figure name
    png(filename=outfig, width=480, height=480, units="px", pointsize=12, type="cairo") # set up the export to file
    plot(tmp$x, tmp$y, xlab="Capacitance", ylab="Water Level", main=wlr_nme) # plot it
    abline(lmtmp, lwd=2, col=2) # add line for intercept and slope (a-b)
    dev.off() # write the plot to file
    ## Export the intercept and x to a csv file
    lmmat <- c(wlr_nme, summary(lmtmp)$coef[1,1], summary(lmtmp)$coef[2,1]) # extract the intercept and x from the summary
    lmmat <- matrix(data=lmmat,nrow=1,ncol=3,byrow=FALSE,dimnames=NULL) # dump it to a 1x3 matrix
    df_lmmat <- as.data.frame(lmmat) # convert matrix to data frame
    names(df_lmmat) <- c("wlr", "int", "x") # add headers
    write.csv(df_lmmat, file=outcoef, row.names=FALSE) # export to csv
## Transfer the calibration data to the database table
stm<-paste("COPY nilgiris.wlr_calib (wlr_id, intercept, x) FROM '", outcoef, 
  "' DELIMITER ',' CSV header;", sep="")
    rs<-dbSendQuery(con,stm)
    rm(stm)
}
