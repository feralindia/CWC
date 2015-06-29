## Take rating curves from all wlrs and convert to discharge for each wlr unit
## list wlr units measuring stage from streams (not weirs or flumes)
site <- "Nilgiris"
if(site=="Nilgiris"){
    wlr.units <- paste("wlr_",c(102:109), sep="")
}
if(site=="Aghnashini"){
    wlr.units <- c() ## get from susan
}
## get rating curve results
data.dir <- paste("/home/udumbu/rsb/OngoingProjects/CWC/Data", site, sep="/")
RCformulae <- read.csv(paste(data.dir, "/hydrograph/curves/RCformulas.csv", sep=""))
for(i in 1:length(wlr.units)){
    wlr.flst <- list.files(path=paste(data.dir,"/wlr/csv", sep=""), pattern=wlr.units[i], full.names=TRUE)
    for(j in 1:length(wlr.flst)){
        wlr.dat <- read.csv(wlr.flst[j])
        names(wlr.dat)[3] <- "Stage"
        form <- RCformulae[wlr.units[i]==RCformulae$stn_no,]
        if(is.na(form$p2)){
            wlr.dat$Discharge <- form$p1 * (wlr.dat$Stage)^form$p3
        }
        write.csv(file=wlr.flst[j], wlr.dat)
    }
}
   
    
