---
layout: default
---

[CCAMLRGIS]:https://github.com/ccamlr/CCAMLRGIS?tab=readme-ov-file#ccamlrgis-r-package

------------------------------------------------------------------------

# Resources from and for CCAMLR Scientists

The table of contents below separates resources in broad themes,
but some topics or codes are cross-cutting and could be applied in different contexts.

[Contributors](./Contributors.html)

------------------------------------------------------------------------

<br>

# Survey Design


##	Acoustic

- Past surveys
  - [2019Area48Survey](https://github.com/ccamlr/2019Area48Survey): Matlab code to process
  the data from the International Synoptic Krill Survey in Area 48, 2019
  ([Publication](https://academic.oup.com/jcb/article/41/4/ruab071/6455606)).
  
- Current and future
  - Protocols: See annexes of [WG-ASAM-2024](https://meetings.ccamlr.org/wg-asam-2024) Meeting Report.
  - Survey design tool (*In prep?*)


## Longline

- [create_Stations](https://github.com/ccamlr/CCAMLRGIS#22-create-stations): R function from
the [CCAMLRGIS] package to create random locations inside a chosen area and within bathymetry constraints.

## Trawl

  - Protocols: See annexes of [WG-ASAM-2024](https://meetings.ccamlr.org/wg-asam-2024) Meeting Report.


<br>

# Stock Assessments and tools

## Krill

- Acoustics

  - [SDWBA_TS](https://github.com/ccamlr/SDWBA_TS): Matlab code to calculate the acoustic target
  strength of Antarctic krill using the stochastic distorted wave Born approximation scattering model.

  - [CCAMLREchoviewR](https://github.com/ccamlr/CCAMLREchoviewR): R package to interface between
  Echoview and R using COM scripting.

  - [asam_biomass_density_estimates](https://github.com/ccamlr/asam_biomass_density_estimates): Biomass
  density estimates from the ASAM-2021 Metadata table.

  - [Krill-Biomass-Estimates (private)](https://github.com/CCAMLR-Science/Krill-Biomass-Estimates):
  repository for WG-ASAM to share the codes and resources used to calculate krill biomass estimates.
  
  
- Population Dynamics

  - [Grym_Base_Case](https://github.com/ccamlr/Grym_Base_Case/tree/Simulations): R scripts
  of the base case implementation of the Grym assessment.

  - [SOA_model_input_data (private)](https://github.com/CCAMLR-Science/SOA_model_input_data): Spatial
  Overlap Analysis model inputs.
  
  - [RecMaker](https://github.com/ccamlr/RecMaker): R script to simulate time series of krill proportional
  recruitment indices.
  

## Toothfish

- Casal2 assessments

  - [Casal2_resources (private)](https://github.com/CCAMLR-Science/Casal2_resources): Casal2 training materials, 
  example R codes and diagnostics.
  
  -	Biological parameters estimation (*In prep.*)
  
  - Diagnostics (*In prep.*)
  
- [Trend_Analysis](https://github.com/CCAMLR-Science/Trend_Analysis): R scripts of the
[Trend Analysis](https://fishdocs.ccamlr.org/TrendAnalysis_2024.html).

- Tools

  - [CCAMLRTOOLS](https://github.com/CCAMLR-Science/CCAMLRTOOLS): R package for loading official CCAMLR data 
  and calculating the Tag Overlap Statistic.
  


<br>

# Geographic Information Systems 

-	[geospatial_operations](https://github.com/ccamlr/geospatial_operations): R scripts to generate
spatial layers following the [Geospatial Rules](https://github.com/ccamlr/geospatial_operations?tab=readme-ov-file#1-geospatial-rules),
and other resources such as coastlines.

-	[Geographical Data](https://github.com/ccamlr/data): Repository of georeferenced layers (*e.g.*,
CCAMLR Subareas and Divisions, bathymetry data).

-	Shiny data viewers: Online GIS data viewers, including a [public one](https://ccamlrgis.shinyapps.io/public/).

- [CCAMLRGIS] R library to assist in the production of maps and of some spatial analyses. Examples:

  - [Basemaps](https://github.com/ccamlr/CCAMLRGIS/blob/master/Basemaps/Basemaps.md#basemaps): R scripts 
  to reproduce the maps shown in the [Fishery Reports](https://fisheryreports.ccamlr.org./).

  - [Data gridding](https://github.com/ccamlr/CCAMLRGIS/blob/master/Advanced_Grids/Advanced_Grids.md#advanced-grids-tutorial): 
  R tutorial to produce maps of gridded data.

  - [Seabed area estimation](./seabed_area_doc.html): R script to estimate planimetric seabed area.

-	Satellite data (*In prep.*)

