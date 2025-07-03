
<!-- File.md is generated from File.Rmd. Please edit that file -->

# Seabed area estimation – an example in Subarea 48.6

Estimating planimetric seabed area (*i.e.*, the area between two
isobaths) is a common task in CCAMLR works (*e.g.*, in the [Trend
Analysis](https://fishdocs.ccamlr.org/TrendAnalysis_2024.html)). The R
script linked below provides an example in which seabed area is
estimated for the entire Subarea 48.6 and its Research Blocks (Fig. 1).

[**Download R script**](./Codes/Seabed_Area/seabed_area_code.R).

<a href="./Codes/Seabed_Area/seabed_area_code.R" style="font-size: 18px; color: blue;">Download
R script</a>

------------------------------------------------------------------------

<img src="https://raw.githubusercontent.com/ccamlr/CCAMLRGIS/refs/heads/master/Basemaps/Map_Area_486.png" width="100%" style="display: block; margin: auto;" />

Figure 1. Map of Subarea 48.6 and its Research Blocks
([Source](https://github.com/ccamlr/CCAMLRGIS/blob/master/Basemaps/Basemaps.md#basemaps)).

<br>

## Steps

1.  Create a folder, a new R project in that folder, and put the R
    script in that folder,

2.  Download the un-projected bathymetry from here (*link to come*),

3.  Run the script. A csv file should have been created in your folder.
