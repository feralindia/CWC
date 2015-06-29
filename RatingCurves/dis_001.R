## Stage-discharge calculation for Saimane - wlr_001, Aghnashini


## Formula: discharge ~ p1 * (stage)^p3

## Parameters:
##    Estimate Std. Error t value Pr(>|t|)    
## p1    4.700      2.147   2.189 0.041255 *  
## p3    3.247      0.795   4.084 0.000633 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

## Residual standard error: 0.3056 on 19 degrees of freedom

## Number of iterations to convergence: 12 
## Achieved convergence tolerance: 8.246e-06
##--------Start of script------##
library(ggplot2)

flname <- "merged_station_1.csv"
figname <- "merged_station_1.png"
wlr.folder <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/wlr/csv"
sd.folder <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/rating/csv"
fig.folder <- "/home/udumbu/rsb/OngoingProjects/CWC/Data/Aghnashini/rating/fig"
fig.dest <-  paste(fig.folder, figname, sep="/")
csv.name <- "merged_discharge_stn_1.csv"
csv.dest <- (paste(sd.folder, csv.name, sep="/"))
wlr <- read.csv(paste(wlr.folder, flname, sep="/"))
sd <- read.csv(paste(sd.folder, flname, sep="/"))
p1 <- 4.700
p3 <- 3.247
wlr$Discharge <- p1*((wlr$Stage^p3))
write.csv(file=csv.dest, x=wlr)

wlr$Method <- NA ## for ggplot2

sd.plot <- ggplot(data = sd, aes(Stage, Discharge, group=Method)) +
    geom_point(data=wlr, aes(Stage, Discharge)) +
        geom_point(aes(color=Method)) +
            ggtitle("Stage-Discharge Curve for station 001") +
                labs(x = "Stage (m)", y = "Discharge (m3/s)") +
                    theme(axis.title=element_text(size=10,face="bold"),
                          axis.text=element_text(size=8)) 

ggsave(sd.plot, filename=fig.dest, width=6, height=4, units="in")

## analyse the results
qnt.data <- subset(wlr, select=c(Stage, Discharge))
quantile(wlr$Stage, probs = c(0, 0.9, 0.95, 0.995, 0.999, 0.9995, 1), na.rm = TRUE)
good.discharge <- subset(wlr, subset=(Stage>1.19361842 & Stage < 1.39386912))
summary(good.discharge)
## good.discharge[with(good.discharge, order(Stage, Discharge)), ]

# the subsequent line is dumb. WE need thedischarge for the value of 0.9995 above
quantile(wlr$Discharge, probs = c(0.9, 0.95, 0.995, 0.9995), na.rm = TRUE)
summary(wlr$Stage)
