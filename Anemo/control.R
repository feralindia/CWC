## Script to import anemometer data and export it to CSV files and draw windroses

library(openair)

dir.lst <- list.dirs(path = "~/Res/CWC/Data/Nilgiris/anemometers/raw", recursive = F)
dir.nm <- list.dirs(path = "~/Res/CWC/Data/Nilgiris/anemometers/raw", recursive = F, full.names = FALSE)
nm.csv <- paste0("~/Res/CWC/Data/Nilgiris/anemometers/csv/", dir.nm, ".csv")
nm.fig <- paste0("~/Res/CWC/Data/Nilgiris/anemometers/fig/", dir.nm, ".png")
fl.lst <- lapply(dir.lst,list.files, full.names = TRUE)
names(fl.lst) <- dir.nm

bind.files <- function(x, y, z) {
    anem.df <- do.call(rbind, lapply(x, read.csv, skip=5))
    anem.df$Date.Time <- as.POSIXct(anem.df$Date.Time, tz = "Asia/Kolkata",
                                    format="%m/%d/%Y %I:%M %p")
    write.csv(anem.df, y)
    names(anem.df) <- c("date", "ws", "ws2", "wd")
    png(filename = z, width = 1200, height = 600, type = "cairo")
    windRose(anem.df, type = "month")
    dev.off()
    return(anem.df)
}

anem.df <- mapply(bind.files, x=fl.lst, y=nm.csv, z = nm.fig, SIMPLIFY = FALSE, USE.NAMES = TRUE)

