data.dir <- "~/Res/CWC/Data/"
site <- c("Nilgiris", "Aghnashini")
aws.dir <- list.dirs(paste0(data.dir, site[1], "/aws/raw/"), full.names = TRUE, recursive = FALSE)
aws.dirnames <- list.dirs(paste0(data.dir, site[1], "/aws/raw/"), full.names = FALSE, recursive = FALSE)
aws.files <- lapply(aws.dir, list.files, full.names=TRUE)
## aws.files.2 <- mapply(list.files, aws.dir, full.names=TRUE, SIMPLIFY = FALSE)
names(aws.files) <- aws.dirnames

aws.data <- lapply(aws.files, function(x){
    do.call("rbind", lapply (x, function(x){
        read.csv(x, header=FALSE, skip=2, sep = "\t")
    }))})


## names(aws.files.2) <- aws.dirnames
## do.call("rbind",
##         lapply(aws.files, function(x){
##             read.csv(x, header=FALSE, skip=2,  sep = "\t")
##         })
##         )



###
## processing for bunker
bunker.df <- do.call("rbind", lapply(aws.files[[2]], FUN = read.csv, header=FALSE, skip=2, sep = "\t"))
hd1 <- scan(aws.files[[2]][1], nlines = 1, what = character())
hd1 <- c(rep("",3), hd1)
hd2 <- scan(aws.files[[2]][1], skip = 1, nlines = 1, what = character())

paste0(hd1,hd2)
