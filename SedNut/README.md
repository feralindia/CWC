Sediment and Nutrient Loads at Specific Discharges
==================================================

# Introduction

Sediment and nutrient loads were measured using the DH83 integrated sampler as well as the modified siphon sampler (stage sampler). To determine the relationship between water quality and hydrologic variables, the time at which the water quality sample was collected needs to be matched with the hydrologic variable. The processing is broken into two scripts. The master or control script [control.R](control.R)  defines the environment, calls libraries and sequentially calls functions. The script of functions,  [functions.R](functions.R), does the actual processing. 

## [control.R](./control.R)

The control script performs the following:

### Load libraries

Calls the libraries required for the various operations and functions. May be more efficient for memory use to use the require() command within a function for some of these libraries.

### Load functions

Calls the functions.R script so all functions are loaded to memory.

### Define constants

1. Constants required for the scripts are defined here. The site is first identified (Nilgiris or Aghnashini) after which the 'set.path' function is called.
2. int.dis.pairs: Pairs of file names containing data are defined by merging the integrated sampler data and the discharge data file names.
3. Stations (wlr numbers) to be processed are listed.

### Process integrated or grab sampler data

1. Multi-core processing is used for this function call to speed up the processing. This will slow down some computers and may not be stable on a Windows box.
2. merge.dat.int: merges data from integrated samplers and discharge to create a vector 'merged.int.data'.
3. The output is then written to csv files using the 'write.list.to.csv' function.
4. 'plot.parms' function is called to create a scatterplot of the data from the integrated sampler and corresponding discharges.


### Process stage or siphon sampler data

1. Use the function 'read.csv.files' to create a list of dataframes containing discharge datasets called 'all.stg.data'.
2. Call the function 'add.bottle.heights' by providing it the location of the stage sampler data and the csv file containing heights of bottles "/home/udumbu/rsb/CurrProj/CWC/Anl/SedNut/stagesampler_hights.csv". The function appends the bottle heights to the stage sampler data.
3. Merge the data frames containing the names of files holding stage sampler data and discharge data.
4. Select the stations to be processed.
5. Trim the discharge dataset so it corresponds to not more than two weeks of data before the time of sample collection. Note this function uses half the cores on the computer - may cause issues with Windows.
6. Calculate the stage of the sample with reference to the WLR based on when the water level reached the heigh of the siphon sampler bottle.
7. Plot the concentration/dishcharge graph as a scatterplot.
8. Write the results to a CSV file.

### Plot timeseries on a hydrograph

1. Average the rainfall for all the rain gauges in the catchment of a specific water level recorder.
2. Select the names of the stations.
3. Plot the nutrient concentations against the hydrographs.

### Create boxplots and run anova

Calls the function bxplt.cover which plots analyses and reports data to the fig and tab folder. Note: analysis does not check for normality of data (yet), we may need to use a non-parametric test.

## [functions.R](./functions.R) 
The functions.R script has two parts.  
The first merges the discharge and sediment/nutrient datasets and generates two outputs:

1. Discharge and sediment/nutrient concentrations for integrated samplers.
2. The same for stage or siphon samplers.

The second section of the script visualises this data by:

1. Creating a scatterplot showing discharges and nutrient sediment/concentration along with the dates of each event on each point.
2. Crating a hydrograph showing averaged rainfall received in the catchment (mean of all rain gauges) and the sediment/nutrient concentrations.
3. TODO: Creating a panel of box plots showing land cover and nutrient/sediment loads.

Each function is briefly described below.


The following functions are used in the processing of the data:


### set.path

Sets names of folders and then creates lists of file names which are called by the other scripts. Note that the global assignment operator is used so the vectors are accessible outside the function. 

### read.csv.files

Binds together csv files which may be broken into chunks on account of timestamps. For example dicharge data is broken into six month chunks which needs to be bound together for using for other operations. This was done because discharge results were broken into seasons to limit the file size. Note that the data is in one minute intervals. 
  
### merge.dat.int

Takes the list of stations and a dataframe containing filenames of water quality and discharge datasets and merges them on timestamps to create a list of data frames with each data frame containing water qality data and relevant discharges.

### write.list.to.csv

Utility function to write a list of data frames into respective csv files.

###  add.bottle.heights
  Uses the qdap package to create a column of sampler bottle heights based on the sampler number. It reads the csv file "stagesampler_hights.csv" to get this data and creates a data frame "all.stg.data".

### subset.dis.data

Select relevant WQ and discharge dataset and trims the discharge datset to two weeks before dates of wq sampler collection.  Inputs "stn" - names of station; "df.stn" dataframe containing WQ and discharge data filenames.

### get.stg

Calculates the stage of bottles siphon or "stg" sampler by back calculating from the timestamp, of installation and depth of installation of the unit.

1. The timestamp of collection of the stage sampler along provides the stage of the stream at installtion (StI). 
2. The depth at which the sampler is placed in the stream is used to calibrate the stages at which the bottles are placed.
3. The number of samples collected after each installation of the stage sampler was determined by the stage to which the stream rose. Consequently, there were many occasions when only the first one or two stream stages were sampled. This information is collected from the stage sampler data.
4. The timestamp at which the sample was collected is identified by working backword from the time of sample collectino and matching the stage of the sampler and water level recorder.
5. This timestamp is then used to extract 
   1. The corresponding discharge.
   2. The corresponding rainfall and hydrograph (past 24 hours + 6 hours).
   
Function get.stg has the following if statements to help deal with data issues. These are:

1. bot.stg values have to be over 0 else the siphon samplers have been placed too high and the equivalent stage of the WLR can't be extracted.
2. Candidates for discharge (dis.cand) has been given a range of one cm (+ and -) this is to allow for errors in height calculations. Given that we are looking at a rising limb, this should not affect results significantly.
3. The number of rows in the discharge candidates which fall in the range should be more than zero and the time of the water sample should be in the future. If this condition isn't being met it indicates there is an error in the logger.

### bxplt.cover

Create boxplots from each station based on dominant land cover. The function assigns cover to specific loggers and also assigns output file names and parameters for the melt command though a couple of if-else statements. These statement will need to be changed for Aghnashini datasets.
There is no testing for normality of data before the parametric (anova) test is run. This needs to be added to the function as an if statement. i.e. if the test of normality fails it should do a Kurskal Wallis test in stead of an Anova.

## Note: each station is kept separate
## operates on both grab and multi-stage sampler.
## x is grab or siphon sampler dataset call as: bxplt.cover(merged.int.data) or bxplt.cover(stg.dis.res)

NOTES
======

## Sediment/Nutrient measurments from Integrated Sampler

This is based on the USGS DH-81 integrated sampler[^1]. A simpler version of the stage-sampler script re-uses the functions to identify discharges and hydrographs from the timestamp. 

## Ouput CSV and figure description

Here is a list of columns produced in the output CSV file for the integrated sampler and what they are. The output columns will probably trimmed in future versions.

1. time.num: Numerical time (to be removed)
2. Timestamp.x: Timestamp at water sample (to be re-named)
3. coll.temp: Temperature in deg.C at time of collection of sample.	
4. an.temp: Temperature in deg. C at time of analysis.
5. ph: pH in 
6. sal.ppt: Salinity in parts per thousand.
7. ec.mus: Electrical conductivity in micro Siemens per m (distance unit to be confirmed).
8. tds.ppm: Total dissolved solids in parts per million or mg/L.
9. do.ppm: Dissolved oxygen in parts per million or mg/L.
10. turb.ntu: Turbidity in Nephelometric Turbidity Unit (NTU) 	
11. sed.mgl: Sediments in parts per million or mg/L.
12. no3.mgl: Nitrates in parts per million or mg/L.
13. po4.mgl: Phosphates in parts per million or mg/L.
14. Capacitance: Capacitance at WLR at time of sample in 
15. Stage: Stage at WLR at time of sample in m.	
16. Timestamp.y: Timestamp at WLR - used to match with sample.	
17. Discharge: Discharge in m3/s at time of water quality sample.
18. DepthDischarge: Depth of discharge (discharge/catchment area) at time of sample (to be confirmed). 

Figures comprise of all the water quality parameters above against the discharge in m3/s.

## Sediment/Nutrient Discharges Using Stage Samplers

The modifed siphon smapler is based on the USGS design of the same [^2] and measures the *rising limb* of the stream for up to three different stages, 20cm apart [picture]. 

The sampler was used during the onset of the monsoon. It was placed in streams emerging from catchments comprising different land-covers when rain was predicted by local weather forecasts. 


## Ouput CSV and figure description

1. Capacitance: Capacitance at WLR at time of sample in farad.
2. Stage: Stage at WLR at time of sample in m.	
3. Timestamp: Timestamp when the stream height reached the siphon sampler height - i.e. when the water sample was collected in the siphon sampler.
4. Discharge: Discharge in m3/s at time of water quality sample.	
5. DepthDischarge: Depth of discharge (discharge/catchment area) at time of sample (to be confirmed). 
6. numtime: Numerical time (to be removed)
7. X: Row number generated by R - to be removed.	
8. date: Date of sample collection.
9. time: Time of sample collection.
10. wlr.no: Station ID.
11. bot.posn: Position of the bottle - see figure for details.
12. wtr.hgt.cm: Hight of the water with respect to the sampler at time of sample collection.
13. coll.temp: Temperature of water at time of collection in deg. C.
14. an.temp	ph: Temperature in deg. C at time of analysis.
15. sal.ppt: Salinity in parts per thousand.
16. ec.mus: Electrical conductivity in micro Siemens per m (distance unit to be confirmed).
16. tds.ppm: Total dissolved solids in parts per million or mg/L.
17. do.ppm: Dissolved oxygen in parts per million or mg/L.	
18. turb.ntu: Turbidity in Nephelometric Turbidity Unit (NTU) 		
19. sed.mgl: Sediments in parts per million or mg/L.	
20. no3.mgl: Nitrates in parts per million or mg/L.	
21. po4.mgl: Phosphates in parts per million or mg/L.	
22. disl.C: Total dissolved carbon - units not known.
23. disl.N: Total dissolved nitrogen - units not known.
24. Remarks: Any comments/remarks during fieldwork or labwork.
25. bot.hgt: Height of bottle with respect to WLR stage.
26. Timestamp: Timestamp when sample was collected by team - not to be mixed up with earlier timestamp.
27. numtime: Numerical timestamp - to be removed.

Figures comprise of all the water quality parameters above against the discharge in m3/s.

# Plotting Water Quality and Discharge

### plot.params and plot.stg.discharge

Both these functions plot discharge and concentration as a scatter plot with dates or month indicated. 
FROM JK: This type of plot may show hysterisis and will tell us whether system is supply or energy limited. And when the supply gets exhausted. 

### write.stg.dis.to.csv

Write the list of data frames to individual CSV files.

### AvgRain

Average rainfall from all rain gauges in a catchment. Note data input is on daily basis.

### plot.nutconc
Plot discharge and rainfall intensity as lines with sediment/nutrient concentrations as points. Location of the points on the Y axis is discharge and on the X is date. The colour is the concentration.
FROM JK: This will tell us a lot about pathways, supply exhaustion and so on. 



-------------------------------------------------------------------------------

[^1]: Shelton, Larry R. Field guide for collecting and processing stream-water samples for the National Water-Quality Assessment Program. No. 94-455. US Geological Survey; USGS Earth Science Information Center, Open-File Reports Section [distributor], 1994.

[^2]: Diehl, T.H., 2008, A modified siphon sampler for shallow water: U.S. Geological Survey Scientific Investigations. Report 2007–5282, 11 p.


## TODO

1. Boxplots of sediment and nutrient conc or load as a function of land-cover. Sediment/nutrient load can be expressed in kg/ha/day. Concentration  multiplied by discharge is equal to instantaneous load in (appropriate units).  Eg If concentration is in mg/l and discharge is in m3/s you should do the appropriate conversions and get load in kg/minute or kg/hr. 
4. Showing boxplots of all instantaneous nutrient or sediment loads in kg/ha/minute or kg/ha/hr with land cover or land use or station no on x axis. 
5. A regression of nutrient or sediment conc as a function of rainfall intensity, discharge and accumulated rainfall. Tons of useful insight from such a model. 
