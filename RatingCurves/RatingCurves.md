# Deriving Rating Curves

This document explains the code used to derive the rating curve from four different methods used during this project. These are:

1. Flow rates or velocity measurements taken using pygmy flow meters in combination with stream profiles.

2. Flow rates measured using a floating orange in combination with stream profiles.

3. Discharges measured using the salt dilution 'slug' method.

4. Discharges measured using the salt dilution constant release method.

The code used to run these procedure is in nine parts or chunks namely:

Chunk 0: [disch.R](../disch.R)

Control script to run the sub-routines.

Chunk 1: [useful.functs.R](../useful.functs.R)

This lists useful functions used in the script.

Chunk 2: [disch_managefiles.R](../disch_managefiles.R)

File management and checking including checks to see if the number of profiles and the number of velocity reading match. The script stops if they don't.

Chunk 3: [disch_libs.R](../disch_libs.R)

Relevant libraries

Chunk 4: [disch_ExtractStage.R](../disch_ExtractStage.R)

Get stage values, i.e. height of water at a given time-stamp from the water level recorder dataset.

Chunk 5: [disch_pyg_figs.R](../disch_pyg_figs.R)

Draw velocity profiles for manual analysis of where the sections for averaging velocities are to be laid.

Chunk 6: [disch_pyg.R](../disch_pyg.R)

Process the pygmy current meter data logs.

Chunk 7: [disch_flt.R](../disch_flt.R)", echo=TRUE) # p

Process the data logs from the orange or float method.

Chunk 8: [disch_fig.R](../disch_fig.R)", echo=TRUE) # m

Merge the discharge data from various sources and draw the rating curves

