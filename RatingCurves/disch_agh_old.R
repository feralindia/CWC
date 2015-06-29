## This script sets the environment for Aghnashini
wk.dr <- "/home/udumbu/rsb/OngoingProjects/CWC/rdata" # default working directory
setwd(wk.dr) # set the working directory
site <- "Aghnashini"
disch.dr <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/disch/" # discharge data folder
data.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/"
cx.dr <- paste(disch.dr, "cx_pyg", sep="") # profile data folder
cx_flt.dr <- paste(disch.dr, "cx_flt", sep="") # profile data folder
pyg.dr <- paste(disch.dr, "pyg", sep="") # pygmy current meter data folder
flt.dr <- paste(disch.dr, "flt", sep="") # float method data folder 
csv.dr <- paste(disch.dr, "csv", sep="") # output csv files
fig.dr <- paste(disch.dr, "fig", sep="") # output figures
pyg.loc <- list.dirs(path=pyg.dr, recursive=FALSE, full.names=FALSE)
## pyg.locnum <- unlist(regmatches(pyg.loc,gregexpr('\\w\\w\\w\\w[[:digit:]]+', pyg.loc)))
pyg.locnum <- pyg.loc
flt.loc <- list.dirs(path=flt.dr, full.names=FALSE, recursive=FALSE)
    ##paste("wlr_", 102:109, sep="") # list sites NOTE: all these directories need to have data
cx.drlst <- list.dirs(path = cx.dr, full.names = TRUE, recursive=FALSE)
cx_flt.drlst <- list.dirs(path = cx_flt.dr, full.names = TRUE, recursive=FALSE)
# cx.drlst <- list.dirs(path=cx.dr, full.names=TRUE)
pyg.drlst <- list.dirs(path=pyg.dr, full.names=TRUE, recursive=FALSE)
flt.drlst <- list.dirs(path=flt.dr, full.names=TRUE, recursive=FALSE)
## csv.drlst <- list.dirs(path=csv.dr, full.names=TRUE)
## fig.drlst <- list.dirs(path=fig.dr, full.names=TRUE)


## delete earlier results files
del.csv <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/disch/csv/*"
unlink(del.csv, recursive = FALSE, force = FALSE)
del.fig <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/disch/fig/*"
unlink(del.fig, recursive = FALSE, force = FALSE)

## call the routines
source("disch_libs.R", echo=TRUE) # load required libraries
source("disch_ExtractStage.R", echo=TRUE) # get stage values from wlr
source("disch_pyg.R", echo=TRUE) # process pygmy data
source("disch_flt.R", echo=TRUE) # process float data
source("disch_fig.R", echo=TRUE) # draw figures



## cx.dr <- paste(disch.dr, "cx", sep="") # profile data folder
## cx_flt.dr <- paste(disch.dr, "cx_flt", sep="") # profile data folder
## pyg.dr <- paste(disch.dr, "pyg", sep="") # pygmy current meter data folder
## flt.dr <- paste(disch.dr, "flt", sep="") # float method data folder 
## csv.dr <- paste(disch.dr, "csv", sep="") # output csv files
## fig.dr <- paste(disch.dr, "fig", sep="") # output figures
## pyg.loc <- dir(path=pyg.dr, full.names=FALSE)
## pyg.locnum <- unlist(regmatches(pyg.loc,gregexpr('\\w\\w\\w\\w[[:digit:]]+', pyg.loc)))
## flt.loc <- dir(path=flt.dr, full.names=FALSE)

## sites <- c("wlr_001","wlr_002", "wlr_004", "wlr_005")
## cx.drlst <- dir(path = cx.dr, full.names = TRUE, no.. = TRUE)
## cx_flt.drlst <- dir(path = cx_flt.dr, full.names = TRUE, no.. = TRUE)
## pyg.drlst <- dir(path=pyg.dr, full.names=TRUE)
## flt.drlst <- dir(path=flt.dr, full.names=TRUE)
## # sites <- paste("wlr_", 001:009, sep="") # list sites NOTE: all these directories need to have data
## # fltpe <- "*.[Cc][Ss][Vv]" # filter so that only csv files are listed

## ## delete earlier results files
## del.csv <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/disch/csv/*"
## unlink(del.csv, recursive = FALSE, force = FALSE)
## del.fig <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/disch/fig/*"
## unlink(del.fig, recursive = FALSE, force = FALSE)



## ## call the routines
## source("disch_libs.R", echo=TRUE) # load required libraries
## source("disch_pyg.R", echo=TRUE) # process pygmy data
## source("disch_flt.R", echo=TRUE) # process float data
## source("disch_fig.R", echo=TRUE) # draw figures

## res <- as.data.frame(matrix(ncol = 11)) # create matrix of 10 cols to hold results
## names(res) <- c("S.No", "site", "obsfile", "stage", "areaR1", "areaR2", "areaR3", "velR1", "velR2", "velR3", "avg_disch") # give names to cols 
## resSD <- as.data.frame(matrix(ncol = 3)) # create matrix of 3 cols to hold results
## names(resSD) <- c("S.No", "Stage", "Discharge")
## ## call the routine
## source("disch.R", echo=TRUE) # call the sub-routine to do the calculations
