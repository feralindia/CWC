Processing Hygrochron Data
======

Code Documentation
------------

This R code is for processing temperature and humidity data collected using the [i-button hygrochron](https://www.maximintegrated.com/en/products/digital/data-loggers/DS1923.html).

There are two files associated with this code: *control.R* which calls the functions stored in the *functions.R* script. The file *hyg_imp.R* is the earlier version of the script and has been kept here for archival purposes only.
This code does not use any loops :-).

Sections in the second level headings correspond to comments in the R code which appear as:  `##----section title----##`
	
# [control.R](control.R)

## Call libraries

The code uses functions from the libraries `timeSeries`, `scales`, `ggplot2` and `reshape2`.


## Call functions and set file names

Call the `functions.R` script and define the location and file names of the folders holding the hygrocrhon data and the destination folder for results.

## Process data by calling functions

The final section of the control script calls the various functions defined in the `functions.R` script described below.

# [functions.R](functions.R)

Functions generated to do the following - listed in sequence they are called by the `control.R` script. 

Note: some of the functions depend on other functions separately defined or defined internally.

1. `import.hygch` imports hygrochron dat which is called using `mapply` and requires the inputs:
   * temp.dir or humi.dir - directory holding temperature or humidity data.
   * temp.flnm or humi.flnm - file name for each raw (logger generated) file.
   
2. `aggregate.by` aggregates the imported data and aggregates it into min, max, mean and median and allows the user to specify period of  aggregation. It is called using `lapply` and takes the inputs:
   * temp.res or humi.res which is the output of the function call above and
   * prd which is the period for which the aggregation is required.
   
3. `merge.bs.tabs` takes the two button sensor tables (temp.res and humi.res) and merges them into a single data frame which can be exported to csv if required. It is called using the `mapply` function and requires the inputs temp.res and humi.res - the results from the `import.hygch` script.

4. `merge.bs.agg` merges the aggregated hygrochron data and is called using the `mapply` function. It requires the inputs daily.temp and daily.humi - the aggregated dataset for humidity and temperature. Note that the file names could change depending on the user and so could the aggregation period as per the inputs for the `aggregate.by` script above.

5. `plot.save` - this is the last script which generates a plot with separate panels for each year showing the different aggregations. It also dumps the data as a CSV file. The function needs to be called separately for temperature or humidity calcuations as putting them on the same graph is quite messy (completely different scales). The script is called from the `mapply` function and requires the inputs:
   * daily.temp or daily.humi - data generated from the `aggregate.by` script is used as an input. Any aggregation can be used as mentioned earlier.
   * hyg.no - number of the hygrochron, used to generate the title and file name for the plot.
   * parm - the name of the parameter being reported on. Could be "temperature" or "humidity". Again used for the titles and file names. 
   
   ----##----
   
   
