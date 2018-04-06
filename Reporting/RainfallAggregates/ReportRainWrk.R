library(zoo)
library(ggplot2)
library(reshape2)
library(sf)
library(mapview)
library(ggmap)

## x is tbrg number, y is year
## code borrowed from <https://stackoverflow.com/questions/29974535/dates-with-month-and-day-in-time-series-plot-in-ggplot2-with-facet-for-years/29975153>
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
    unit.nm <- substr(basename(x), 0, 8)
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
    print(ggp)
    fl.nm <- paste0(unit.nm, ".png")
    ggsave(fl.nm, ggp)
    return(fl.nm)
}

RepLogger <- function(x){
    df <- crd.df[gsub("TBRG_", "", crd.df$unit_id)==x, ]
    df <- df[, c(2, 3, 6, 7)]
    tdf <- as.data.frame(t(df), col.names = TRUE)
    tdf$Parameter <- row.names(tdf)
    names(tdf)[1] <- "Value"
    return(print(tdf[,c(2,1)]))
}

x <- list.files("~/Res/CWC/Data/Nilgiris/tbrg/csv/", pattern = "1 day.csv", full.names = TRUE)
all.rain <- do.call("rbind", lapply(x, RepRainAll))
PlotRainAll(all.rain)


crd.df <- read.csv("./tbrgMetadataRev.csv", stringsAsFactors=FALSE, na.strings=c("","NA"))
crd.df$Start <- as.POSIXct(crd.df$Start, tz = "Asia/Kolkata")
crd.df$End <- as.POSIXct(crd.df$End, tz = "Asia/Kolkata")
## crd.st <- st_as_sf(crd.df, coords = c("long", "lat"),
   ##                 crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
## crd.mv <- mapView(crd.st["unit_id"], label = as.character(crd.st["unit_id"]))
## mapshot(crd.mv, file = paste0(getwd(), "/MapView2.png"))

crd.df.nlg <- crd.df[-40,]
crd.df.nlg$unit.no <- gsub("TBRG_", "", crd.df.nlg$unit_id)
zoom <- calc_zoom(long, lat, crd.df.nlg)
bbx <- make_bbox(long, lat, crd.df.nlg, f = 0.05)
ooty_basemap <- get_stamenmap(bbox = bbx, zoom = zoom, maptype = "watercolor") ## toner-lite terrain-labels toner-hybrid
## ooty_basemap <- get_map(location=c(lon = crd.df.nlg$long[1], lat = crd.df$lat[1]))
## scale <- OSM_scale_lookup(zoom = zoom)
## ooty_basemap <- get_openstreetmap(bbox = bbx, scale = 75000) 
ggmap(ooty_basemap) +
    geom_point(data = crd.df.nlg, aes(x=long, y = lat), alpha = .5) +
    geom_text(data = crd.df.nlg, aes(x = long, y = lat, label = unit.no), 
              size = 3, vjust = 0, hjust = 0)


## reporting rain gauge wise details

