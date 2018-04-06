Extreme Rainfall Events in the Western Ghats
================

Impacts of Land Cover on Discharge Volume and Quality
------------------

# Script Description

## Objectives

1. Identify extreme rainfall events in statistical terms
2. Identify pattern of rainfall in spatial terms (isohet for each ERE)
3. Identify catchment based on location of ERE
2. Determine discharge from associated streams for each of these events
3. Identify dominant land cover for each of the stream catchments 
4. Determine nutrient content in the discharge
5. Investigate statistical relationships
6. Investigate ecological ramifications

# Identify extreme rainfall events in statistical terms

Goswami et al., identify ERE at 150mm per day for central India on the basis that this area had fairly homogenous seasonal as well as daily variabiliy in rainfall. On the other hand they clarified that a fixed threshhold would not be appropirate for areas with high variability.

Hence we adopted a statistical approach based on our own datasets. We computed the *daily* outliers for each of the sites separately based on the 95th percentile based on a chi square score: `(x - mean(x))^2/var(x)` as implemented by the outliers package and described [here](http://r-statistics.co/Outlier-Treatment-With-R.html#outliers%20package).

Dates from each of these daily events were then used to identify one-minute rain events.

# Determine discharge from associated streams for each of these events

# Identify dominant land cover for each of the stream catchments 

# Determine nutrient content in the discharge

# Investigate statistical relationships

# Investigate ecological ramifications

