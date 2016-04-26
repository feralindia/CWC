# Code documentation for discharge calculation

## Basic structure

Each logger has its own code for the sake of flexibility. This is not the most efficient way to organise things but it allows us to tweak components of the calculations as required by field conditions. Note: some stations call other station routines. This is because loggers have been moved/replaced over time. In some cases, flumes were placed in streams during low flows.

We refer to a staion as the location on the stream where the original water level recorder was placed. For example, station 107 in the grasslands above Upper Bhavani combines results from stn_107.R (original WLR) as well as stn_110.R (flume).

The control flow is as follows:
dis.control.R -> dis.function -> station wise routines

## dis.control.R

Generate discharge for one minute intervals input: wlr no, start time, end time output: csv, figures.

### Variables to be entered by user

* Site: Nilgiris or Aghnashini
* Relative file names for scripts and data/outputs
* Start/end dates and time intervals for which discharge data is to be displayed (in months)
* Names of water level recorders to be processed.

### Other details

* Uses library timeSeries for time aggregation and ggplot2 for graphing.
* Calls function dis.plot to do the plotting.
* Gives warnings if there are duplicated timestamps - applicable where there is more than one logger. Uses function "mk.nullfile" to remove duplicates.

## dis.functs.R

Functions used by the control script reside here.

### calc.disch.areastage

Calculates discharge from a set of points describing a rating curve by using a non-linear least square fit. Original code by Jagdish Krishnaswamy. Steps involved:

* Read the stage-discharge point file.
* Run the NLS calculation:

        nls(Discharge~p1*(Stage)^p3,data=sd.fl, start=list(p1=3,p3=5))

	Get p1 and p3 from above and calculate discharge as follows:

		y$Discharge <- coef.p1 * (y$Stage)^coef.p3

### calc.disch.flume

Calculates discharges for a Montana flume based on the flume equation as below:
