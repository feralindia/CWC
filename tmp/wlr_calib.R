## modified from <http://stackoverflow.com/a/7963963/2548841>
substrLeft <- function(x, n){
    substr(x, 0, nchar(x)-n)}
wlr_calib_list <- list.files(path=dir_calib_wlr, pattern="new.csv$")
col_names <- c("y", "x")

## Loop to build calibration from raw observations
alltmp <- data.frame(x=numeric(0), y=numeric(0), wlr=character(0))
all.wlr.calibres <- as.data.frame(matrix(ncol=3))
names(all.wlr.calibres) <- c("wlr","int", "x")
for (i in 1: length(wlr_calib_list)){
    wlr_nme <- substrLeft(wlr_calib_list[i], 4)##substr(wlr_calib_list[i], 1,7) # hold name of wlr
    wlr.fl <- paste(dir_calib_wlr, wlr_calib_list[i], sep="") # name of wlr with directory
    tmp <-  read.csv(file=wlr.fl, header=FALSE, sep=",", col.names=col_names, skip=6) # read in minus header
    lmtmp <- lm(tmp$y~tmp$x) # run the linear regression
    summary_lmtmp <- summary(lmtmp) # output the results into a temporary file
    out <- capture.output(summary_lmtmp) # save them to a temporary file for recording
    outsum <- paste(dir_calib_res, wlr_nme, "_summ.txt", sep="") # define output text file
    outcoef <- paste(dir_calib_res, wlr_nme, "_coef.csv", sep="") # define output intercept file
    write.csv(out, file = outsum, quote = FALSE, row.names = FALSE) # dump to the text file
    
    ##---- Plot the regression and abline
    outpng <- paste(dir_calib_res, wlr_nme, ".png", sep="") # define output figure name
    ##outeps <- paste(dir_calib_res, wlr_nme, ".eps", sep="") # define output figure name
    png(filename=outpng, width=480, height=480, units="px", pointsize=12, type="cairo") # set up the export to file
    #postscript(outeps, horizontal=TRUE, onefile=TRUE) 
    plot(tmp$x, tmp$y, xlab="Capacitance", ylab="Water Level", main=wlr_nme) # plot it
    abline(lmtmp, lwd=2, col=2) # add line for intercept and slope (a-b)
    dev.off() # write the plot to file

    ##---- Export the intercept and x to a csv file
    lmmat <- c(wlr_nme, summary(lmtmp)$coef[1,1], summary(lmtmp)$coef[2,1]) # extract the intercept and x from the summary
    lmmat <- matrix(data=lmmat,nrow=1,ncol=3,byrow=FALSE,dimnames=NULL) # dump it to a 1x3 matrix
    df_lmmat <- as.data.frame(lmmat) # convert matrix to data frame
    names(df_lmmat) <- c("wlr", "int", "x") # add headers
    write.csv(df_lmmat, file=outcoef, row.names=FALSE) # export to csv
    all.wlr.calibres <- rbind(all.wlr.calibres, df_lmmat)
    tmp$wlr <- wlr_nme
    alltmp <- rbind(alltmp, tmp)
}
write.csv(all.wlr.calibres[-1,], paste(dir_calib_res, "AllCalibrationResults.csv", sep=""), row.names=FALSE)
outplot <- ggplot(data = alltmp, aes(x, y)) + 
    geom_point() + facet_wrap(~wlr, scales = "free_y") +
    stat_smooth(method = "lm", col = "red") +# theme(axis.text.x = element_text(angle = 90))+
    labs(x="Capacitance", y="Stage in m")
## qplot(data=alltmp, x, y, facets=~wlr)+stat_smooth(method="lm")+labs(x="Capacitance", y="Stage in m")
outplot
outpng <- paste(dir_calib_res,"AllCalibration.png", sep="") # define output figure name
outeps <- paste(dir_calib_res, "AllCalibration.eps", sep="") # define output figure name
outpdf <- paste(dir_calib_res, "AllCalibration.pdf", sep="") # define output figure name
ggsave(outplot, file=outpng, width=297, height=210, units="mm")
ggsave(outplot, file=outeps, width=297, height=210, units="mm")
ggsave(outplot, file=outpdf, width=297, height=210, units="mm")

## Create a function to add the abline onto ggplot
## From <http://susanejohnston.wordpress.com/2012/08/09/a-quick-and-easy-function-to-plot-lm-results-in-r/>
## ggplotRegression <- function (fit) {
## require(ggplot2)
## ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
##   geom_point() +
##   stat_smooth(method = "lm", col = "red") +
##   opts(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
##                      "; Intercept =",signif(fit$coef[[1]],5 ),
##                      "; Slope =",signif(fit$coef[[2]], 5),
##                      "; P =",signif(summary(fit)$coef[2,4], 5))) 
##  #+ facet_wrap(~wlr) 
## }
## calibres <- lm(y ~ x, data = alltmp)
## ggplotRegression(calibres)
