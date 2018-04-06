## Define the files and directories

## Location of types of data folders
data.dir <- "/home/udumbu/rsb/Res/CWC/Data/"
site.datadir <- paste(data.dir, site, "/", sep="")
disch.dr <- paste(site.datadir, "rating/", sep="")

pyg.dr <- paste(disch.dr, "pyg", sep="") # pygmy current meter data folder
flt.dr <- paste(disch.dr, "flt", sep="") # float method data folder 
csv.dr <- paste(disch.dr, "csv", sep="") # output csv files
fig.dr <- paste(disch.dr, "fig", sep="") # output figures
cx.dr <- paste(disch.dr, "cx_pyg", sep="") # profile data folder for pygmy current meter
cx_flt.dr <- paste(disch.dr, "cx_flt", sep="") # profile data folder for float method (to be discarded)
cxfix.dr <- paste(disch.dr, "cx_sec", sep="") # profile data folder fixed manually
shape.dr <- paste(disch.dr, "cx_shape", sep="") # profile data folder shape files for checking
wlr.dir <- paste(data.dir, site, "/wlr/csv/", sep="") # wlr data 

pyg.loc <- list.dirs(path=pyg.dr, recursive=FALSE, full.names=FALSE)
## pyg.loc <- "wlr_102" # remove this
## pyg.locnum <- unlist(regmatches(pyg.loc,gregexpr('\\w\\w\\w\\w[[:digit:]]+', pyg.loc))) ## remove the characters after wlr no.
pyg.locnum <- as.numeric(gsub("[^[:digit:] ]", "", pyg.loc))
pyg.locnum <- paste("wlr_00",pyg.locnum, sep="")
pyg.name <- pyg.loc
pyg.id <- paste("wlr", substr(pyg.loc, start=5, stop=9), sep="") ## remove underscore

## List of folders under data types

pyg.dir <- list.files(pyg.dr, full.names=TRUE, recursive=FALSE )
## pyg.dir <- "/home/udumbu/rsb/Res/CWC/Data/Nilgiris/rating/pyg/wlr_102" # remove this
cx.pyg.man <- paste(disch.dr, "cx_pyg_man/", pyg.name, sep="")
cx.pyg.res <- paste(disch.dr, "cx_pyg_res/", pyg.name, sep="")
cx.shape <- paste(shape.dr, pyg.name, sep="/")
cx.drlst <- gsub(pattern="/pyg/", replacement="/cx_pyg/", x=pyg.dir)
cx_flt.drlst <- list.dirs(path = cx_flt.dr, full.names = TRUE, recursive=FALSE)
cxfix.drlst <- list.dirs(path=cxfix.dr, full.names=TRUE, recursive=FALSE)


## pyg.locnum <- pyg.loc


## cx.drlst <- list.dirs(path = cx.dr, full.names = TRUE, recursive=FALSE)

## list all files 
flt.dir <- list.files(flt.dr, full.names=TRUE, recursive=FALSE )
## flt.dir <- "/home/udumbu/rsb/Res/CWC/Data/Nilgiris/rating/flt/wlr_102" # remove this
flt.drlst <- list.files(flt.dr, full.names=TRUE, recursive=FALSE )
flt.name <- list.files(flt.dr, full.names=FALSE, recursive=FALSE)
flt.loc <- list.dirs(path=flt.dr, full.names=FALSE, recursive=FALSE)
flt.id <- paste("wlr", substr(flt.name, start=5, stop=9), sep="") ## remove underscore
flt.locnum <- as.numeric(gsub("[^[:digit:] ]", "", flt.loc))
flt.locnum <- paste("wlr_00",flt.locnum, sep="")

stn.dir <- c(pyg.dir, flt.dir )
stn.name <- c(pyg.name, flt.name ) 

stn.id <- c(pyg.id, flt.id )

disch.stn.name <- tolower(paste(stn.name, "_stage.txt",sep="")) ## made lower case
oneminfile <- tolower(paste(substr(stn.name, start=5, stop=9), "_onemin.merged.csv",sep="")) 

## ## list folder names to be deleted
del.cxres <- dir(path=paste(disch.dr, "cx_pyg_res", sep=""), full.names=TRUE, no..=TRUE)
del.cxres <- substrRight(del.cxres, 17)
todel <- c("csv", "fig", "stage", "cx_pyg_res", del.cxres)
lapply(todel, delfiles)

## list missing files between the velocity measures and cross section
if(site == "Nilgiris"){
    pyg.fl <- list.files(pyg.dir, full.names=TRUE)
    pyg.fl <- substr(pyg.fl, start=62, stop=nchar(pyg.fl))
    cx.pyg.fl <- list.files(cx.drlst, full.names=TRUE)
    cx.pyg.fl <- substr(cx.pyg.fl, start=65, stop=nchar(cx.pyg.fl))
    missing.pyg.files <- cx.pyg.fl[!(cx.pyg.fl %in% pyg.fl)]
    missing.cx.files <- pyg.fl[!(pyg.fl %in% cx.pyg.fl)]
} else if(site == "Aghnashini") {
    pyg.fl <- list.files(pyg.dir, full.names=TRUE)
    pyg.fl <- substr(pyg.fl, start=64, stop=nchar(pyg.fl))
    cx.pyg.fl <- list.files(cx.drlst, full.names=TRUE)
    cx.pyg.fl <- substr(cx.pyg.fl, start=67, stop=nchar(cx.pyg.fl))
    missing.pyg.files <- cx.pyg.fl[!(cx.pyg.fl %in% pyg.fl)]
    missing.cx.files <- pyg.fl[!(pyg.fl %in% cx.pyg.fl)]
}

if(length(missing.pyg.files) > 0 || length(missing.cx.files) > 0){
    stop("The numberof velocity readings and cross sections don't match")
}

