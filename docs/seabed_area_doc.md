
<!-- File.md is generated from File.Rmd. Please edit that file -->

# Seabed area estimation – an example in Subarea 48.6

Estimating planimetric seabed area (*i.e.*, the area between two
isobaths) is a common task in CCAMLR works (*e.g.*, in the [Trend
Analysis](https://fishdocs.ccamlr.org/TrendAnalysis_2024.html)). The R
script linked below provides an example in which seabed area is
estimated for the entire Subarea 48.6 and its Research Blocks (Fig. 1).

<a href="./Codes/Seabed_Area/seabed_area_code.R" style="font-size: 18px; color: #337ab7; font-weight: bold">Download
R script</a>

------------------------------------------------------------------------

<img src="https://raw.githubusercontent.com/ccamlr/CCAMLRGIS/refs/heads/master/Basemaps/Map_Area_486.png" width="100%" style="display: block; margin: auto;" />

Figure 1. Map of Subarea 48.6 and its Research Blocks
([Source](https://github.com/ccamlr/CCAMLRGIS/blob/master/Basemaps/Basemaps.md#basemaps)).

<br>

## Steps

1.  Create a folder, a new R project in that folder, and put the R
    script in that folder,

2.  Download the un-projected bathymetry from here (*link to come*) and
    put it in that folder,

3.  Run the script. A csv file should have been created in your folder
    (Table 1).

<br>

Table 1. Seabed area (km$^2$) between 600 and 1800m (referred to as
“*Fishable area*”) in Subarea 48.6 and its Research Blocks.

| GAR_Long_Label | Fishable_area |
|:---------------|--------------:|
| 48.6           |      80964.82 |
| 48.6_2         |       9330.55 |
| 48.6_3         |        943.37 |
| 48.6_4         |      10511.03 |
| 48.6_5         |       8390.91 |
