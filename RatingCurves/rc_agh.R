## This script sets the environment for Aghnashini

wk.dr <- "/home/udumbu/rsb/GitHub/CWC/RatingCurves/" # default working dir
setwd(wk.dr) # set the working directory
site <- "Aghnashini"

## call the routines
source("useful.functs.R", echo=TRUE)
source("rc_managefiles.R", echo=TRUE)
source("rc_libs.R", echo=TRUE) # load required libraries
source("rc_ExtractStage.R", echo=TRUE) # get stage values from wlr
## use only when necessary
## source("rc_pyg_figs.R")  # draw velocity profiles for manual analysis.
source("rc_pyg.R", echo=TRUE) # process pygmy data
# source("rc_flt.R", echo=TRUE) # process float data
source("rc_appendSDG.R", echo=TRUE) # append salt dilution gauging results
source("rc_fig.R", echo=TRUE) # draw figures


## clean up
## obj.list <- row.names(lsos(n=50))
## rm(list=obj.list)
