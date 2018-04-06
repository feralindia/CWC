
##---- functions
## http://www.r-bloggers.com/identifying-records-in-data-frame-a-that-are-not-contained-in-data-frame-b-%E2%80%93-a-comparison/

fun.12 <- function(x.1,x.2,...){
    x.1p <- do.call("paste", x.1)
    x.2p <- do.call("paste", x.2)
    x.1[! x.1p %in% x.2p, ]
}


## read in hydrographs sort and limit to highest 8 events
## Get one week of data for highest discharge events in input hydrograph dataset

## reduce the number of iterations to about 30 and animate them
read.max.hydgr <- function(ffn,sfn){
    ## no.reads <- 
    x <- read.csv(ffn, row.names = 1)
    x$Unit_ID <- hydgrph.UnitID[j]
    x$dt.tm <- as.POSIXct(x$date, tz = "Asia/Kolkata")
    for(n in 1: max.event){
        x.ord <- x[order(x$Discharge, decreasing = TRUE),]
        x.ord <- head(x.ord, 1)
        print(x.ord)
        rn.x <- as.numeric(rownames(x.ord))
        if(n==1){
            x.sel <- subset(x, subset=(as.numeric(rownames(x))) > (rn.x-24) & as.numeric(rownames(x)) < (rn.x+12)) # changed from 672
            x.sel$Rank <- n
        }else{
            x.sel.next <- subset(x, subset=(as.numeric(rownames(x))) > (rn.x-24) & as.numeric(rownames(x)) < (rn.x+12))
            x.sel.next$Rank <- n
            x.sel <- rbind(x.sel, x.sel.next)
        }
        ## x <- x[! x %in% x.sel[,-5], ]
        x <- fun.12(x, x.sel[,-6])
    }
    return(x.sel)
}



## read in rainfall logs limit to dates specified by other logger
read.max.hydrain <- function(ffn,sfn){
    x <- read.csv(ffn, row.names = 1)
    x$dt.tm <- as.POSIXct(x$dt.tm, tz = "Asia/Kolkata")
    x <- x[match(tmp$dt.tm, x$dt.tm),]    
    x$Unit_ID <- unlist(strsplit(sfn, split="_"))[2]
    x$Unit_ID <- paste("TBRG", x$Unit_ID, sep = " ")
    x$Rank <- tmp$Rank
    return(x)
}


## read in rainfall logs sort and limit to highest 20 events
read.max.rain <- function(ffn,sfn){
    x <- read.csv(ffn, row.names = 1)
    x$dt.tm <- as.POSIXct(x$dt.tm, tz = "Asia/Kolkata")
    x <- x[order(x$mm, decreasing = TRUE),]
    x <- head(x, n=max.event)
    x$Unit_ID <- unlist(strsplit(sfn, split="_"))[2]
    x$Unit_ID <- paste("TBRG", x$Unit_ID, sep = " ")
    x$Rank <- seq(1, max.event)
    return(x)
}
## read in rainfall logs limit to dates specified by other logger
read.othermax.rain <- function(ffn,sfn){
    x <- read.csv(ffn, row.names = 1)
    x$dt.tm <- as.POSIXct(x$dt.tm, tz = "Asia/Kolkata")
    x <- x[match(tmp$dt.tm, x$dt.tm),]    
    x$Unit_ID <- unlist(strsplit(sfn, split="_"))[2]
    x$Unit_ID <- paste("TBRG", x$Unit_ID, sep = " ")
    x$Rank <- seq(1, max.event)
    return(x)
}

## add topographic information onto the rainfall logs
add.topoinfo <- function(x){
    tbrgno <- x$Unit_ID[1]
    if(site=="Nilgiris"){
        unit.topo <- subset(spat.nlg, subset=Unit_ID==tbrgno)
    } else {
        unit.topo <- subset(spat.agn, subset=spat.agn$Unit_ID==tbrgno)
    }
    if(nrow(unit.topo)==0)(unit.topo[1,] <- NA)
    x <- cbind(x, unit.topo)
    return(x)
}

remove.logger <- function(pat,y){ #give a pattern or a list and lapply
    remrow <- grep(pattern=pat, x=as.character(y$fn.short))
    if(length(remrow==1))(y <- y[-remrow,])
    return(y)
}


