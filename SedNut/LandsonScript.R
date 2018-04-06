library(repmis)
library(dplyr)
library(ggplot2)
library(grid)
library(scales)

# download sample files from dropbox

wq <- repmis::source_data('https://dl.dropboxusercontent.com/u/10963448/wq.csv')
flow <- repmis::source_data('https://dl.dropboxusercontent.com/u/10963448/flow.csv')

# parse the dates

wq$Date <- as.Date(wq$Date)
flow$Date <- as.Date(flow$Date)

# join flows onto the water quality data

wq <- left_join(wq, flow)

# plot

ggplot(data = flow, aes(Date, Discharge)) +
    geom_line() +  # plot the hydrograph
    geom_point(data = wq, aes(Date, Discharge, color = Total.N), size = 5) + # overlay the concentrations
    scale_color_continuous(low = 'green', high = 'red', name = 'Total N (mg/L)') +
    scale_y_continuous(labels = comma, name = 'Discharge (ML/d)') +
    theme_bw() +   # beautify
    theme(
      panel.background = element_rect(fill="gray98"),
      axis.title.x = element_text(colour="grey20", size=20, vjust = -2),
      axis.text.x = element_text(colour="grey20",size=12),
      axis.title.y = element_text(colour="grey20",size=20, vjust = 2),
      axis.text.y = element_text(colour="grey20",size=12),
      legend.title = element_text(colour="grey20",size=12),
      plot.margin = unit(c(2.5, 2.5, 2.5, 2.5), "cm"))

    
