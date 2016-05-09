
##---- functions

## read in rainfall logs sort and limit to highest 20 events
read.max.rain <- function(ffn,sfn){
    x <- read.csv(ffn, row.names = 1)
    x$dt.tm <- as.POSIXct(x$dt.tm, tz = "Asia/Kolkata")
    ## HERE - star the sequence of timestamps at 00:00:00
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
    if(site[i]=="Nilgiris"){
        unit.topo <- subset(spat.nlg, subset=Unit_ID==tbrgno)
    } else {
        unit.topo <- subset(spat.agn, subset=spat.agn$Unit_ID==tbrgno)
    }
    if(nrow(unit.topo)==0)(unit.topo[1,] <- NA)
    x <- cbind(x, unit.topo)
    return(x)
}

remove.logger <- function(pat){ #give a pattern or a list and lapply
    remrow <- grep(pattern=pat, x=as.character(y$fn.short))
    if(length(remrow==1))(y <- y[-remrow,])
    return(y)
}
