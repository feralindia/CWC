# Monthly.R

Function based code to generat monthly reports of rainfall for each raingauge. which takes input file names of daily raingauge results and converts them into separate CSV files, each containing the  months in the top row and dates in the first column. Data for each year is saved separately. Also, missing values are entered as NA. This is necessitated by the different dates on which the loggers were installed or removed.

Added routine to plot monthly aggregates of rain on ggplot and save as png files.

Added routing to plot output onto PDF for printing
