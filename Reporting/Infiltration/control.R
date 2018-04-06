## Script to import and plot K-sat values

library(ggplot2)

## Pull in rainfall data for suitable rain gauge

data.rain <- read.csv("~/CurrProj/CWC/Data/Nilgiris/tbrg/csv/tbrg_109_1 hour.csv")
data.rain$dt.tm <- as.POSIXct(data.rain$dt.tm, tz="Asia/Kolkata")
data.rain <- subset(data.rain, subset = dt.tm>"2013-01-01 00:00:00 IST" & dt.tm < "2016-01-01 00:00:00 IST")
data.rain$Year <- format(data.rain$dt.tm, format="%Y")
data.rain <- data.rain[data.rain$mm>0,] # removing all no-rain days - probably not correct.
bplot.rain <- ggplot(data.rain, aes (x=Year, y=mm))+
    geom_boxplot()+
    labs(x="Year", y="Rainfall in mm/hr")#  +
## theme(axis.text.x=element_text(angle=90, vjust=0.5, size=8))
bplot.rain
ggsave(filename = "HrlyRainBoxplots.png", plot=bplot.rain, width = 12, height = 8, units = "in")
max.2013 <- max(data.rain$mm[data.rain$Year==2013])
max.2014 <- max(data.rain$mm[data.rain$Year==2014])
max.2015 <- max(data.rain$mm[data.rain$Year==2015])

data.ksat <- read.csv("~/CurrProj/CWC/Data/Nilgiris/Infiltration/KKsat.csv")
bplot.ksat <- ggplot(data.ksat, aes(Land.Cover,Ksat)) +
    geom_boxplot() +
    geom_hline(aes(yintercept=max.2013), colour="black", linetype="dashed") +
    geom_text(aes(0.5,max.2013),label = "2013", vjust = -0) +
    geom_hline(aes(yintercept=max.2014), colour="black", linetype="dashed") +
    geom_text(aes(4.5,max.2014),label = "2014", vjust = +1) +
    geom_hline(aes(yintercept=max.2015), colour="black", linetype="dashed") +
    geom_text(aes(0.5,max.2015),label = "2015", vjust = -0) +
    labs(x="Land Cover", y="Saturated Hydraulic Conductivity in mm/hr") +
    theme(axis.text.x=element_text(vjust=0.5, size=12)) # +
   ## ggtitle("Saturated Hydraulic Conductivity Under Different Land Cover")
bplot.ksat
ggsave(filename = "KsatBoxplots.png", plot=bplot.ksat, width = 12, height = 8, units = "in")
## Test for homogeniety of variance
bartlett.test(Ksat ~ Land.Cover, data = data.ksat)
fit <- aov(Ksat ~ Land.Cover, data = data.ksat)
anova(fit)
## Plot diagnostics
par(mfrow=c(1,2))         # set graphics window to plot side-by-side
plot(fit, 1)         # graphical test of homogeneity
plot(fit, 2)           # graphical test of normality
dev.off()

## Tukey test
tukeyres <- TukeyHSD(fit)
## Plot Tukey HSD
par(mar=c(4, 8, 3, 3))
plot(TukeyHSD(fit), las=1)
dev.off()

## Do pairwise t-test as well
pairwise.t.test(data.ksat$Ksat, data.ksat$Land.Cover, p.adjust="bonferroni")


## to be fixed from here
