
## function to list top few non-zero tips for checking
tips <- function(x){
    return(head(subset(x, subset=x$tips>0)))
}

searchdate <- function(x, dt, tm){
    dt <- as.Date(dt, format="%m/%d/%y")
    tmstmp <- paste(dt, tm, sep=' ')
    return(x[x$dt.tm==tmstmp,])
}
         
