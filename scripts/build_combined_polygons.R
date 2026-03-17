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
library(tidyverse)
library(sf)

## Load data -------------------------------------------------------------------
pol1 <- read_sf(here("data/processed/primnm_2009_polygons.gpkg"))
pol2 <- read_sf(here("data/processed/primnm_2014_polygons.gpkg"))
pol3 <- read_sf(here("data/processed/PRIMNM_2025_polygons.gpkg"))
pol4 <- read_sf(here("data/processed/primnm_2014_polygons.gpkg")) |> 
  mutate(year = 2025, change = "Reinstated", period = "Reinstated") |> 
  select(year, change, period)

# PROCESSING ###################################################################

## Some step -------------------------------------------------------------------
pols <- bind_rows(pol1, pol2, pol3, pol4) |> 
  mutate(period = fct_relevel(period, c("Bush creation", "Obama expansion", "Trump reopening", "Reinstated")))

# VISUALIZE ####################################################################

## Another step ----------------------------------------------------------------
ggplot(pols) +
  geom_sf() + 
  facet_wrap(~period, nrow = 1) +
  coord_sf(crs = "EPSG:8859")

# EXPORT #######################################################################

## The final step --------------------------------------------------------------
write_sf(obj = pols,
         dsn = here("data/processed/combined_primnm_polygons.gpkg"),
         delete_dsn = T)
