# Tipping Bucket Rain Gauge (TBRG)

R scripts used to import, calibrate, aggregate and plot all rain gauge data for the CWC project. Note, we are using Rainwise Inc. Rain Loggers. Most of the units are using version 1 of the loggers, some are upgraded to version 2 which fixes the date settings for after 2016.

Sequence of scripts is:
[site].R --> import.R --> fillnull.R --> aggreg.R

### Recent changes of import

* Data aggregation now starts from the 15th of August 2012 - this is just before the first logger was installed and happens to be India's independence day :grin:.
* Attempted to fix the long-pending date/time regression. Seems to be working after setting the financial centre in the initialisation of the script.


### TODO

Issues with the rain gauge processing:

* [ ] This is the first script written for data processing, can be cleaned up both in terms of creating functions for repetitive tasks and in fixing date/time issues. There have been difficulties in attempts to use the scripts for other kinds of loggers - probably to do with the importing of data.
* [x] @rsb Datestamp keeps switching back to GMT when timedate package is used. Setting time zone while initialising doesn't seem to work.
* [ ] Need to clean up code, insert if-else statements to allow a master routine to turn sub-routines on and off.

###  Wish List

Link up code to GIS. Need to discuss with JK, NC & SV on what sort of outputs we should be looking at.

## [[site].R](tbrg_agn.R)

Both agn.R and nlg.R are the same, only site names and logger codes differ. Users can decide to process specific loggers by assigning them to the vector `num_tbrg`.

This script essentially states the file names and paths and calls the other sub-routines via a loop which goes through all the listed loggers in sequence.

## [import.R](tbrg_import.R)

Imports the logs for each rain gauge, binds them together and calibrates the readings against a csv file based on annual calibration of the gauges.

Sample of the calibration file for Aghnashini below:

tbrg_id | rawml_tip | tbrg_area | mm_pertip
------- | --------- | --------- | ---------
tbrg_001 | 9.38 | 362.529 | 0.2587
tbrg_002 | 9.19 | 362.529 | 0.2535
tbrg_003 | 9.78 | 362.529 | 0.2698
tbrg_004 | 9.48 | 362.529 | 0.2615

## [fillnull.R](tbrg_fillnull.R)

Imports null files, i.e. simple text files containing timestamps of periods where loggers were malfunctioning or not working correctly. This occasionally occurred during very cold/wet weather when batteries ran out or there were short-circuits in the logger unit due to moisture.

A sample of the null file is as follows:

	08/23/2015,21:30,0.00
	08/24/2015,18:03,0.00

It comprises of a start time-stamp comprising of date (mm/d/yyyy) followed by time (hr:min), followed by tips (usually 0.00, but any value will do as it is ignored). This file is saved with a name corresponding to the date of the null values, for e.g. "tbrg108_23_12_2014.dat".

The file is saved in the "null" folder under a sub-folder with the name of the logger. For e.g. "/tbrg/null/tbrg_108".

## [aggreg.R](tbrg_aggreg.R)

Aggregates the merged rain gauge logs to different time periods, saves the output as CSV files and a figure containing a panel of the different aggregations. At present the aggregations are for 1 minute, 15 minutes, 30 minutes, 1 hour, 6 hours, 12 hours, 1 day, 15 days and 1 month.
