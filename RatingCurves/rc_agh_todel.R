## This script sets the environment for Aghnashini

wk.dr <- "/home/udumbu/rsb/OngoingProjects/CWC/rdata/RatingCurves/" # default working directory
setwd(wk.dr) # set the working directory
site <- "Aghnashini"
##disch.dr <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashinis/rating/" # discharge data folder
## changed for testing

data.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/"
disch.dr <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/rating/"

pyg.dr <- paste(disch.dr, "pyg", sep="") # pygmy current meter data folder
flt.dr <- paste(disch.dr, "flt", sep="") # float method data folder 
csv.dr <- paste(disch.dr, "csv", sep="") # output csv files
fig.dr <- paste(disch.dr, "fig", sep="") # output figures
cx.dr <- paste(disch.dr, "cx_pyg", sep="") # profile data folder
cxfix.dr <- paste(disch.dr, "cx_sec", sep="") # profile data folder
shape.dr <- paste(disch.dr, "cx_shape", sep="") # profile data folder
cx_flt.dr <- paste(disch.dr, "cx_flt", sep="") # profile data folder
wlr.dir <- paste(data.dir, site, "/wlr/csv/", sep="") # wlr data output

pyg.loc <- list.dirs(path=pyg.dr, recursive=FALSE, full.names=FALSE)
pyg.locnum <- unlist(regmatches(pyg.loc,gregexpr('\\w\\w\\w\\w[[:digit:]]+', pyg.loc))) ## remove the characters after wlr no.

pyg.name <- list.files(pyg.dr, full.names=FALSE, recursive=FALSE) 
pyg.id <- paste("wlr", substr(pyg.name, start=5, stop=9), sep="") ## remove underscore

pyg.dir <- list.files(pyg.dr, full.names=TRUE, recursive=FALSE )
cx.pyg.man <- paste(disch.dr, "cx_pyg_man/", pyg.name, sep="")
cx.pyg.res <- paste(disch.dr, "cx_pyg_res/", pyg.name, sep="")
cx.shape <- paste(shape.dr, pyg.name, sep="/")
cx.drlst <- gsub(pattern="/pyg/", replacement="/cx_pyg/", x=pyg.dir)
cx_flt.drlst <- list.dirs(path = cx_flt.dr, full.names = TRUE, recursive=FALSE)
cxfix.drlst <- list.dirs(path=cxfix.dr, full.names=TRUE, recursive=FALSE)
## pyg.locnum <- pyg.loc
## cx.drlst <- list.dirs(path = cx.dr, full.names = TRUE, recursive=FALSE)

                                        # list all files in pyg and flt dirs
flt.dir <- list.files(flt.dr, full.names=TRUE, recursive=FALSE )
flt.drlst <- list.files(flt.dr, full.names=TRUE, recursive=FALSE )
flt.name <- list.files(flt.dr, full.names=FALSE, recursive=FALSE)
flt.loc <- list.dirs(path=flt.dr, full.names=FALSE, recursive=FALSE)
flt.id <- paste("wlr", substr(flt.name, start=5, stop=9), sep="") ## remove underscore


    ##paste("wlr_", 102:109, sep="") # list sites NOTE: all these directories need to have data
# cx.drlst <- list.dirs(path=cx.dr, full.names=TRUE)
stn.dir <- c(pyg.dir, flt.dir )
stn.name <- c(pyg.name, flt.name ) ## FIX DATA FORMAT HERE we can't have names other than stations (ball or stick won't work)
stn.id <- c(pyg.id, flt.id )

    disch.stn.name <- tolower(paste(stn.name, "_stage.txt",sep="")) ## made lower case
    oneminfile <- tolower(paste(substr(stn.name, start=5, stop=9), "_onemin.merged.csv",sep=""))

## csv.drlst <- list.dirs(path=csv.dr, full.names=TRUE)
## fig.drlst <- list.dirs(path=fig.dr, full.names=TRUE)


## delete earlier results files
del.csv <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/rating/csv/*"
unlink(del.csv, recursive = FALSE, force = FALSE)
del.fig <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/rating/fig/*"
unlink(del.fig, recursive = FALSE, force = FALSE)
del.stage <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/rating/stage/*"
unlink(del.stage, recursive = FALSE, force = FALSE)
del.cxres <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/rating/cx_pyg_res"
cx.res.flist <- list.files(path=del.cxres, all.files=TRUE, full.names=TRUE, recursive=TRUE)
file.remove (cx.res.flist, recursive = TRUE)

## call the routines
source("../useful.functs.R", echo=TRUE)
source("rc_libs.R", echo=TRUE) # load required libraries
source("rc_ExtractStage.R", echo=TRUE) # get stage values from wlr
source("rc_pyg_figs.R")  # draw velocity profiles for manual analysis.
source("rc_pyg.R", echo=TRUE) # process pygmy data
source("rc_flt.R", echo=TRUE) # process float data
source("rc_fig.R", echo=TRUE) # draw figures

## clean up
obj.list <- row.names(lsos(n=50))
rm(list=obj.list)
