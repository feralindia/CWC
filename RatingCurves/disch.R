## This script controls the discharge calculations

wk.dr <- "/home/udumbu/rsb/GitHub/CWC/RatingCurves/" # default working dir
setwd(wk.dr) # set the working directory
## Chose the site you want to do the pre-processing for
site <- "Nilgiris"
##site <- "Aghnashini"

## call the routines
source("../useful.functs.R", echo=TRUE)
source("disch_managefiles.R", echo=TRUE)
source("disch_libs.R", echo=TRUE) # load required libraries
source("disch_ExtractStage.R", echo=TRUE) # get stage values from wlr
## use only when necessary

## source("disch_pyg_figs.R")  # draw velocity profiles for manual analysis.


source("disch_pyg.R", echo=TRUE) ## process pygmy data

<<<<<<< HEAD
## source("disch_flt.R", echo=TRUE) ## process float data
=======
source("disch_flt.R", echo=TRUE) ## process float data
>>>>>>> 789b06ffaa372221217ba5c7e04b6e6e03f250b3

source("disch_sdg.R", echo=TRUE) ## process SDG data

source("disch_fig.R", echo=TRUE) ## merge discharge data and draw S-D graphs

## clean up
## obj.list <- row.names(lsos(n=50))
## rm(list=obj.list)
