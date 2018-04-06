# Animations for hydrographs and rainfall

This code is *work in progress*. It attmpts to do the following:

* Takes results from the scripts in [the hydrograph script directory](../Hydrographs/) and extracts the highest streamflow events for a given station for a stated period before and after the event and for a specific frequency of measurement. Note that the user may need to generate the hydrograph dataset using a `stage` instead of `discharge` depending on the quality of the rating curves. Also note that he user needs to picke the desired level of aggregation for the hydrograph, ranging from five minutes to daily.
Note: the scripts to process hydrograph data are yet to be documented.
* For each of these high stremflow periods, the [HydroResponse.R script](HydroResponse.R) collates the data from all the rain gauges at the site. Each timestamp in the hydrograph is paired with a interpolatd surface (IDW) of rainfall. These outputs are dumped into a folder and then can be easily converted to animated GIF images using packages such as ImageMagic.
* The [RainResponse.R script](RainResponse.R) also generates a surface for "n" highest rainfall events for each rain logger. For example, if raingauge 001 has the higest event at 2013-12-06 03:40:00, an IDW interpolated surface of all rain gauges at that timestamp is drawn. This is repeated for all rain gauges.
* The [SynopticEvents.R script](SynopticEvents.R) develops similar surfaces for all the rain gauges for significant synoptic events observed by the meteorology team at Lancaster.

Data to use these scripts is available at the data sharing site to the project team. The sequence of *relevant* scripts is below. Other scripts will probably be removed from this repository later. 

	ControlScript.R -> functions.R -> {HydroResponse.R RainResponse.R SynopticEvents.R}

## [functions.R](functions.R)

Functions for repetitive jobs. These are:

### read.max.hydgr

This is used by the [HydroResponse.R](HydroResponse.R) script. Full file names (with entire directory tree) and short file names (just the file name) are inputs to be provided. These files are outputs of the [Hydrograph](../Hydrograph/) script set.  Note that the input data can be set to discharge, depth of discharge or stage.

The script reads in the csv file, orders it by maximum events which are 36 units apart. This implies that if the input data set is for 1 hour, the script will extract the maximum discharge event and all discharge from that station 24 hours before the maximum and 12 hours after the maximum event. Then it picks up the next highest event and repeats this process until its selected the "n" highest events.

The script uses a function called fun.12 to do the data frame extraction. This function has been written by and shared at this site <http://www.r-bloggers.com/identifying-records-in-data-frame-a-that-are-not-contained-in-data-frame-b-%E2%80%93-a-comparison/>.

### read.max.rain

This function is called by the [RainResponse.R](RainResponse.R) script. It reads in "n" maximum rainfall events from an input rainfall file supplied to it using the full file name and the short file name. The [TBRG](../TBRG/) set of scripts is used to convert the raw datasets into rainfall aggregated at different time intervals.

### read.max.hydrain

Analogous to the `read.max.rain()` function above,  called by the [HydroResponse.R](HydroResponse.R) script. It reads in "n" maximum rainfall events corresponding to the timestamp in the hydrograph from an input rainfall file supplied to it. Input uses the full file name and the short file name. The [TBRG](../TBRG/) set of scripts is used to convert the raw datasets into rainfall aggregated at different time intervals.

### read.othermax.rain

This is a modification of the read.max.rain script. It takes reads in data from a supplied file name (full and short file names) and extracts the rainfall for a given timestamp. The latter is provided via the [RainResponse.R](RainResponse.R) script.

### add.tpoinfo

Selects the spatial information from the relevant site and logger type and slaps it onto the input file. The input file must contain a unit ID which matches the spatial data set for the script to work.

### remove.logger

A simple function to remove a specific logger from a vector of file names supplied as a vector. Inputs is the logger to be removed and the vector of file names.

### To Do

* [ ] Functions could include additional inputs to define number of maximum events to be extracted.
* [ ] Input file names could be simplified to the short file name.
	
## [Control Script.R](ControlScript.R)

Sets the environment and organises data to be used by the other routines. The main steps are:

* Load the relevant libraries (rgdal, maptools, sp and gstat).
* Run the functions.R script to load relevant functions.
* User input for relevant site ("Nilgiris" or "Aghnashini").
* User input for number of maximum events to be processed. For e.g. if only the top two maximum events, the user enters "2".
* Define data directory.
* User input for sampling period (15 minutes to 15 days).
* Read in spatial data (location of rain gauges and water leven loggers) for the two sites.
* Specify the data directories holding rain gauge hydrograph data.
* Generate list of file names containing input data by looping through relevant directories. Assign the file names to a vector named after the file.
* Call in the other sub-routines as per requirement. Note, the sub-routines can be run independent of each other.

### Todo

* [ ] At present the script needs to be fed in outputs from the hydrograph scripts manually, this is to be automated so it harvests all relevant data automatically. Alternatively the hydrographs should be generated by this script directly.
* [ ] Hydrographs for Aghnashini are yet to be generated.


## [RainResponse.R](RainResponse.R)

Subsets the "n" highest periods of rainfall for each rain gauges at a site and then uses timestamps to merge with the rainfall received by all other rain gauges at that time. Output is in terms of rainfall at all raingauges and a IDW interpolated surface.

The script does the following:

* List all the "RainFiles" i.e. vector of file names created by the [control script](ControlScript.R) based on the user defined filters, i.e. site name, number of top rainfall events to be processed and time period for rainfall aggregation.
* Give the user an option to remove any particular logger from the list of files to be processed. This is in case any of the datasets are incomplete or corrupt. This uses the `remove.logger()` function.
* Read in the maximum rainfall for the highest "n" rain events using the `read.max.rain()` function.
* Add spatial information to the maximum rainfall events from the imported spatial data using the `add.topoinfo()` function.
* For each of the maximum rainfall events, read in the rainfall received at all other rain-gauges at that specific time using the `read.othermax.rain()` function.
* Prepare the names of files for outputs - png and csv.
* Plot the IDW interpolated surface for the top "n" rainfall events for each rain gauge. This portion of the script uses code from <http://personal.colby.edu/personal/m/mgimond/Spatial/Interpolation.html>.

### To Do

* [ ] Need to add analysis for comparison with ground level rain gauges and affects of wind speed/direction, elevation, slope and aspect on the rainfall received.

## [HydroResponse.R](HydroResponse.R)

Selects the "n" highest discharge events per hydrograph generated by the [Hydrographs](../Hydrographs) scripts and slaps on corresponding rainfall events. Plots the same using the spatial information for the relevant site. Steps involved are as follows:

* List all the "HydroFiles", i.e. vector of file names created by the [control script](ControlScript.R) based on the user fefined filters.
* For each of file names in the vector (loop not yet activated - set for manual for now), get the short and full file name.
* Read in the hydrograph data generated by the [Hydrograph](../Hydrgraphs/) scripts.
* Call the `read.max.hydgr()` function to pull in the top "n" stream flow events.
* Read in the rainfall data corresponding to the timestamp of the streamflow logger by calling the `read.max.hydrain()` function.
* Slap on the spatial information on the dataset using the `add.topoinfo()` function.
* Loop through all the hydrograph files provided and generate both CSV files and PNG figures. The former containing the datasets the latter, an IDW based interpolation of rainfall which can be converted into an animation.

One way of generating the animation (on Linux) is to use the following command:

	convert -delay 120 -loop 0 *.png animated.gif

### To Do

* [ ] Fix the loops which requires a re-working of the scripts for generating the output file names.

* [ ] Add code to animate hydrographs as well. Perhaps as a panel where one side shows the interpolated rainfall and the other shows the hydrograph for the same time-step.
