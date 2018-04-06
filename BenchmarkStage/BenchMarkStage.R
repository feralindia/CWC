adjust.stage.velarea <- function(x){
    bm.fn <- list.files("~/Res/CWC/Anl/CodeValidation/CapProbeLengthComparison/data/benchmarks/velarea", pattern = x, full.names = TRUE)
    bm.df <- read.csv(file = bm.fn)
    bm.df$timestamp <- as.POSIXct(bm.df$timestamp, format = "%d/%m/%y %H:%M:%S", tz = "Asia/Kolkata")
    bm.df$timestamp <- as.POSIXct(round(as.numeric(bm.df$timestamp)/(15*60))*(15*60), origin = "1970-01-01")
    stg.fn <- paste0("~/Res/CWC/Data/Nilgiris/wlr/csv/", x, "_15 min.csv")
    stg.df <- read.csv(file = stg.fn)
    stg.df <- stg.df[,c("raw", "cal", "date_time")]
    names(stg.df) <- c("cap", "stg.log", "timestamp")
    stg.df$timestamp <- as.POSIXct(stg.df$timestamp, tz = "Asia/Kolkata")
    stg.df$timestamp <- as.POSIXct(round(as.numeric(stg.df$timestamp)/(15*60))*(15*60), origin = "1970-01-01")
    ts.matched <- stg.df[stg.df$timestamp %in% bm.df$timestamp,]
    bm.stg.mtch <- merge(ts.matched, bm.df, by="timestamp")
    bm.stg.mtch$stg.diff <- bm.stg.mtch$stg.man - bm.stg.mtch$stg.log
   return(bm.stg.mtch)
}

x <- "wlr_107"
adjust.stage.velarea(x)
