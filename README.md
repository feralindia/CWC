# CWC
R scripts to process rain gauge data for the CWC project. There are number of related scripts which basically run the following steps:

* Process data from loggers and convert it into CSV files with corrected (time zone is IST) time stamps and units. Some of the scripts have a routine to calibrate the data based on calibration done at regular intervals.
* Aggregate the data into desired time periods, plot and export CSV files.
* Process data from stream profiles and velociy measurements and generate rating curves.
* Generate hydrographs.

TODO

* Script to merge water quality data with discharge measurements
* Script to import and aggregate hygrochrons and AWS readings.

