
##------------------   This is for the v-notch at the  Nilgiris  -----------------------------#####

infldir.names <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/csv", pattern="wlr_101", full.names=TRUE)
infl.names <- list.files("/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/wlr/csv", pattern="wlr_101", full.names=FALSE)
outfl.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/rating/csv/"
outfig.dir <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Nilgiris/rating/fig/"
outfig.basenames <- paste(outfig.dir, substrLeft(infl.names,4), sep="")
for (i in 1: length(infl.names)){
tmp.data <- read.csv(infldir.names[i])
## create the additional columns as per SB's equation
tmp.data$date_time <- as.POSIXct(tmp.data$date_time, tz="Asia/Kolkata")
tmp.data$stage <- tmp.data$cal ## I think there are scale issues at play check with Jagdish
tmp.data$h.big <- tmp.data$stage-0.1610 ## changed to 0.1610 from 0.0952
tmp.data$h.sml <- tmp.data$stage-0.495
tmp.data$h.sml[tmp.data$h.sml<0] <- 0
tmp.data$g <- 9.81
tmp.data$b <- 0.21
tmp.data$c1 <- 0.59
tmp.data$c2 <- 0.58
attach(tmp.data)
tmp.data$qt <- (8/15 * c1 * sqrt(2*g) * ((h.big ^ 5/2) - (h.sml ^ 5/2))) + (2/3 * c2 * sqrt(2 * g) * (2*b) * h.sml ^ 3/2)) ## corrected replaced 2/3 by 5/2
detach(tmp.data)
tmp.data$qa <- 1.09 * tmp.data$qt
##outfl.name <- paste(outfl.dir, infl.names[i], sep="")
##    write.csv(tmp.data, file=outfl.name)
##outfig.name <- paste(outfig.basenames[i], "StageDischarge.png", sep="")
##png(filename=outfig.name, width=640, height=480, units="px", pointsize=12, type="cairo")
plot(tmp.data$stage, tmp.data$qa, type="p",
     main="Stage Discharge Curve for V-notch at Kolaribetta",
     xlab="StageStage (m)", ylab="Discharge (m^3/sec)")
##dev.off()
##outfig.name <- paste(outfig.basenames[i], "DateDischarge.png", sep="")
##png(filename=outfig.name, width=640, height=480, units="px", pointsize=12, type="cairo")
##png(filename=outfig.name, width=640, height=480, units="px", pointsize=12, type="cairo")
plot(tmp.data$date_time, tmp.data$qa, type="l", main="Hydrograph for V-notch at Kolaribetta",
     xlab="Date (m)", ylab="Discharge (m^3/sec)")
##dev.off()
}
