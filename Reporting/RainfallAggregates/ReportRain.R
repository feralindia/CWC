library(ggplot2)
library(reshape2)
library(sf)
library(mapview)

RepRainAll <- function(x){
    df <- read.csv(x)
    unit.nm <- substr(basename(x), 0, 9)
    unit.nm <- gsub("_", " ", unit.nm)
    unit.nm <- trimws(unit.nm, "right")
    df$dt.tm <- as.POSIXct(df$dt.tm, tz = "Asia/Kolkata")
    y <- unique(format(df$dt.tm, "%Y"))
    df$Year <- format(df$dt.tm, "%Y")
    ann.rain <- do.call("rbind", lapply(y, function(z){
        rain <- df$mm[format(df$dt.tm, "%Y")==z]
        sum.rain <- sum(rain, na.rm = TRUE)
        out.df <- data.frame(unit.nm, z, sum.rain)
        names(out.df) <- c("Unit", "Year", "Rain (mm)")
        return(out.df)
    }))
    return(ann.rain)
}

PlotRainAll <- function(x){
    x$UnitYear <- paste(x$Unit, x$Year)
    names(x)[3] <- "Rain"
    ggp <- ggplot(data = x, aes(x = Unit, y = Rain)) + 
        geom_bar(stat = "identity") +
        facet_grid(facets = Year ~ .) +
        labs(y = "Rain in mm") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1))
    print(ggp)
}

RepRain <- function(x){
    df <- read.csv(x)
    unit.nm <- substr(basename(x), 0, 9)
    unit.nm <- gsub("_", " ", unit.nm)
    unit.nm <- trimws(unit.nm, "right")
    df$dt.tm <- as.POSIXct(df$dt.tm, tz = "Asia/Kolkata")
    y <- unique(format(df$dt.tm, "%Y"))
    df$Year <- format(df$dt.tm, "%Y")
    ann.rain <- do.call("rbind", lapply(y, function(z){
        rain <- df$mm[format(df$dt.tm, "%Y")==z]
        sum.rain <- sum(rain, na.rm = TRUE)
        out.df <- data.frame(z, sum.rain)
        names(out.df) <- c("Year", "Rain (mm)")
        return(out.df)
    }))
    return(ann.rain)
}
#+END_SRC R 

#+RESULTS:

#+BEGIN_SRC R :exports none
PlotRain <- function(x){
    df <- read.csv(x)
    unit.nm <- substr(basename(x), 0, 8)
    df$dt.tm <- as.POSIXct(df$dt.tm, tz = "Asia/Kolkata")
    df$Year <- format(df$dt.tm, "%Y")
    df$Date <- as.Date(paste0("2000-",format(df$dt.tm, "%j")), "%Y-%j")
    ggp <- ggplot(data = df,
           mapping = aes(x = Date, y = mm)) + #, shape = Year, colour = Year)) +
        geom_point() +
        geom_line() +
        facet_grid(facets = Year ~ .) +
        scale_x_date(labels = function(x) format(x, "%d-%b")) +
        theme_light()
    fl.nm <- paste0(unit.nm, ".png")
    ggsave(fl.nm, ggp)
    print(ggp)
    return(fl.nm)
    }

RepRain <- function(x){
    df <- read.csv(x)
    unit.nm <- substr(basename(x), 0, 9)
    unit.nm <- gsub("_", " ", unit.nm)
    unit.nm <- trimws(unit.nm, "right")
    df$dt.tm <- as.POSIXct(df$dt.tm, tz = "Asia/Kolkata")
    y <- unique(format(df$dt.tm, "%Y"))
    df$Year <- format(df$dt.tm, "%Y")
    ann.rain <- do.call("rbind", lapply(y, function(z){
        rain <- df$mm[format(df$dt.tm, "%Y")==z]
        sum.rain <- sum(rain, na.rm = TRUE)
        out.df <- data.frame(z, sum.rain)
        names(out.df) <- c("Year", "Rain (mm)")
        return(out.df)
    }))
    return(ann.rain)
}
#+END_SRC R 

#+RESULTS:

#+BEGIN_SRC R :exports none
PlotRain <- function(x){
    df <- read.csv(x)
    unit.nm <- substr(basename(x), 0, 8)
    df$dt.tm <- as.POSIXct(df$dt.tm, tz = "Asia/Kolkata")
    df$Year <- format(df$dt.tm, "%Y")
    df$Date <- as.Date(paste0("2000-",format(df$dt.tm, "%j")), "%Y-%j")
    ggp <- ggplot(data = df,
           mapping = aes(x = Date, y = mm)) + #, shape = Year, colour = Year)) +
        geom_point() +
        geom_line() +
        facet_grid(facets = Year ~ .) +
        scale_x_date(labels = function(x) format(x, "%d-%b")) +
        theme_light()
    fl.nm <- paste0(unit.nm, ".png")
    ggsave(fl.nm, ggp)
    print(ggp)
    return(fl.nm)
    }

x <- list.files("~/Res/CWC/Data/Nilgiris/tbrg/csv/", pattern = "1 day.csv", full.names = TRUE)
all.rain <- do.call("rbind", lapply(x, RepRainAll))
PlotRainAll(all.rain)

RepLogger("101")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_101_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_101_1 day.csv")

RepLogger("102")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_102_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_102_1 day.csv")

RepLogger("103")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_103_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_103_1 day.csv")

RepLogger("104")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_104_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_104_1 day.csv")

RepLogger("105")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_105_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_105_1 day.csv")

RepLogger("105a")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_105a_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_105a_1 day.csv")

RepLogger("106")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_106_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_106_1 day.csv")

RepLogger("107")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_107_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_107_1 day.csv")

RepLogger("108")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_108_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_108_1 day.csv")

RepLogger("109")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_109_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_109_1 day.csv")

RepLogger("110")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_110_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_110_1 day.csv")

RepLogger("110a")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_110a_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_110a_1 day.csv")

RepLogger("111")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_111_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_111_1 day.csv")

RepLogger("112")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_112_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_112_1 day.csv")

RepLogger("113")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_113_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_113_1 day.csv")

RepLogger("114")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_114_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_114_1 day.csv")

RepLogger("115")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_115_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_115_1 day.csv")

RepLogger("116")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_116_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_116_1 day.csv")

RepLogger("117")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_117_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_117_1 day.csv")

RepLogger("118")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_118_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_118_1 day.csv")

RepLogger("119")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_119_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_119_1 day.csv")

RepLogger("120")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_120_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_120_1 day.csv")

RepLogger("121")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_121_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_121_1 day.csv")

RepLogger("122")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_122_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_122_1 day.csv")

RepLogger("123")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_123_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_123_1 day.csv")

RepLogger("124")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_124_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_124_1 day.csv")

RepLogger("125")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_125_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_125_1 day.csv")

RepLogger("125a")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_125a_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_125a_1 day.csv")

RepLogger("126")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_126_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_126_1 day.csv")

RepLogger("127")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_127_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_127_1 day.csv")

RepLogger("128")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_128_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_128_1 day.csv")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_129_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_129_1 day.csv")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_130_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_130_1 day.csv")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_131_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_131_1 day.csv")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_132_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_132_1 day.csv")

RepLogger("133")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_133_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_133_1 day.csv")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_134_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_134_1 day.csv")

RepRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_135_1 day.csv")

PlotRain("~/Res/CWC/Data/Nilgiris/tbrg/csv/tbrg_135_1 day.csv")
