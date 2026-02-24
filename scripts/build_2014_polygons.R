################################################################################
# title
################################################################################
#
# Juan Carlos Villaseñor-Derbez
# jc_villasenor@miami.edu
# date
#
# Description
#
################################################################################
  
# SET UP #######################################################################

## Load packages ---------------------------------------------------------------
library(here)
library(sf)

## Load data -------------------------------------------------------------------
pol <- read_sf(here("data/raw/PIH_MNM_2014_expansion.gpkg")) |> 
  mutate(year = 2014,
         change = "Expanded",
         period = "Obama expansion") |> 
  select(year, change, period) |> 
  st_transform(crs = "EPSG:4326")

# EXPORT #######################################################################

## The final step --------------------------------------------------------------
write_sf(obj = pol,
         dsn = here("data/processed/primnm_2014_polygons.gpkg"),
         delete_dsn = T)  
