##--- define useful functions---##

substrLeft <- function(x, n){
    substr(x, 0, nchar(x)-n)}

substrRight <- function(x, n){
    substr(x, nchar(x)-n, nchar(x))}

is.even <- function(x) x %% 2 == 0
is.odd <- function(x) x %% 2 != 0
## improved list of objects <http://stackoverflow.com/questions/1358003/tricks-to-manage-the-available-memory-in-an-r-session>
.ls.objects <- function (pos = 1, pattern, order.by,
                         decreasing=FALSE, head=FALSE, n=5) {
    napply <- function(names, fn) sapply(names, function(x)
                                      fn(get(x, pos = pos)))
    names <- ls(pos = pos, pattern = pattern)
    obj.class <- napply(names, function(x) as.character(class(x))[1])
    obj.mode <- napply(names, mode)
    obj.type <- ifelse(is.na(obj.class), obj.mode, obj.class)
    obj.size <- napply(names, object.size)
    obj.dim <- t(napply(names, function(x)
        as.numeric(dim(x))[1:2]))
    vec <- is.na(obj.dim)[, 1] & (obj.type != "function")
    obj.dim[vec, 1] <- napply(names, length)[vec]
    out <- data.frame(obj.type, obj.size, obj.dim)
    names(out) <- c("Type", "Size", "Rows", "Columns")
    if (!missing(order.by))
        out <- out[order(out[[order.by]], decreasing=decreasing), ]
    if (head)
        out <- head(out, n)
    out
}
                                        # shorthand
lsos <- function(..., n=10) {
    .ls.objects(..., order.by="Size", decreasing=TRUE, head=TRUE, n=n)
}



delfiles <- function(x){
    delfile <- paste(disch.dr, x,"/*", sep="")
    unlink(delfile, recursive = FALSE, force = FALSE)
}


## credits <http://stackoverflow.com/questions/2261079/how-to-trim-leading-and-trailing-whitespace-in-r>
fix.time <- function(x){
    x <- sub("^\\s+", "", x)## remove leading spaces
    y <- substr(x, start=1, stop=2)
    y <- gsub(":", "", y)
    z <- y
    y <- as.numeric(y)
    for(i in 1: length(y)){
        if(y[i]>12)(y[i] <- y[i] - 12)
        if(nchar(y[i])==1)(z[i] <- paste("0",y[i], sep = ""))
    }
    
    x <- paste(z, substr(x, start=3, stop=15), sep="")
    return(x)
}


## export to shapefiles to help with cross checking results
## Note: sections with multiple polygons get messed up
writeshape <- function(coords, cx.shapeout){
    ddTable <- data.frame(Id=ids,Name="poly")
    ddShapefile <- convert.to.shapefile(coords, ddTable, "Id", 5)
    write.shapefile(ddShapefile, cx.shapeout, arcgis=TRUE)
}
##--- end of functions set --##
