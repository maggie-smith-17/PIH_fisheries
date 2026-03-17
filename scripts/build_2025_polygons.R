# =============================================================================
# build_2025_polygons.R
# =============================================================================
#
# PURPOSE
# --------
# This script builds 2025 Pacific Remote Islands Marine National Monument
# (PRIMNM) polygons by taking existing monument boundaries and "cutting out"
# a 50-nautical-mile buffer zone around each monument. The result represents
# the area that would be newly protected under a 2025 expansion (i.e., the
# area outside the current monument but inside the 50 nm ring).
#
# IMPORTANT: DATA SOURCE NEEDS TO BE FIXED
# ----------------------------------------
# The input file read on line 24 (see "Read input polygons" section below) is
# currently INCORRECT. The script reads "primnm_2014_polygons.gpkg", but that
# file actually contains 2009 monument boundaries, not 2014. Until the correct
# 2014 (or intended baseline) polygon data are used here, the output will be
# wrong. You MUST rerun this script after updating the data path or replacing
# the input file with the correct polygons. Do not treat the current output
# as the final 2025 product until the input data are corrected.
#
# THE MAP AT THE END IS JUST A CHECK / TEST
# -----------------------------------------
# The ggplot map drawn near the end of this script (gray, red, and blue
# layers) is only for visual checking. It lets you confirm that the three
# layers (original polygons, 50 nm buffer, and "2025" result) look sensible
# and don't overlap in a weird way. It is NOT the final map product. Treat it
# as a quick sanity check before writing the output to disk.
#
# =============================================================================

# --- Load packages -----------------------------------------------------------
library(here)       # consistent paths relative to project root
library(tidyverse)  # data manipulation and piping
library(sf)         # simple features: read/write/transform spatial data
library(mapview)    # optional: interactive viewing (not used in this script)

# --- Helper functions --------------------------------------------------------
# These are used later to do geometry operations per-monument (by "name").

# Removes geometry y from geometry x (generic version; not used per-name).
st_erase <- function(x, y) {
  st_difference(x, st_union(st_combine(y)))
}

# Intersection of polygon x with only the polygons in y that have the same
# "name" as x. Used to keep the 50 nm buffer within each monument's boundary.
my_intersect <- function(x, y) {
  st_intersection(x, y |> filter(name == unique(x$name)))
}

# Removes from polygon x the union of all polygons in y that have the same
# "name". Used to subtract the 50 nm ring from each monument, giving the
# "interior" that becomes the 2025 polygon for that monument.
my_erase <- function(x, y) {
  y <- y |>
    filter(name == unique(x$name)) |>
    st_combine() |>
    st_union()
  
  st_difference(x, y)
}

# --- Read input polygons -----------------------------------------------------
# WARNING: The file "primnm_2014_polygons.gpkg" currently contains 2009
# boundaries, not 2014. The variable is named mpa_2014 for consistency with
# the intended design, but the data are wrong until the file is replaced or
# the path is updated. Rerun this script after fixing the input data.
mpa_2014 <- st_read("data/processed/primnm_2014_polygons.gpkg") |>
  st_transform(crs = "EPSG:8859")  # WGS 84 / pseudo-Mercator for buffer in metres
mpa_2014 <- mpa_2014 |> 
  st_cast("POLYGON") |> 
  mutate(name = paste0("poly_", row_number()))



# --- Build the 50 nautical mile "ring" per monument --------------------------
# This needs to be done only for Wake, Johnston, and Jarvis based on the below:
# The Secretary of Defense shall continue to manage Wake Island and Johnston
# Atoll as specified in Proclamation 8336.’ (Bush proclamation)
# “The president’s proclamation, issued the same day as his EO 14276, basically
# opens up the waters between 50 and 200 miles around the Pacific Remote Islands
# Monument – the islands of Wake, Johnston, and Jarvis – for commercial fishing,”
# says Eric Kingma, executive director of the Hawaii Longline Association (HLA).
# 
# The steps are:
# 1. Convert polygon boundaries to lines (LINESTRING).
# 2. Buffer by 50 nm (50 * 1854 metres per nautical mile).
# 3. For each monument, intersect that buffer with the same monument's polygon
#    so the buffer is clipped to the monument extent (my_intersect).
# Result: buffered_linestring = the 50 nm band around each monument boundary.
buffered_linestring <- mpa_2014 %>%
  mutate(area = st_area(.)) |> 
  arrange(desc(area)) |> 
  head(3) |> 
  st_cast("MULTILINESTRING") |>
  st_cast("LINESTRING") |>
  st_buffer(dist = 50 * 1854) |>
  group_by(name) |>
  group_split() |>
  map_dfr(my_intersect, y = mpa_2014)

# --- Build 2025 polygons -----------------------------------------------------
# For each monument: take the full polygon and subtract the 50 nm ring
# (my_erase). What remains is the "interior" used as the 2025 polygon.
# Then transform back to WGS 84 (EPSG:4326) for saving.
mpa_2025 <- mpa_2014 |>
  group_by(name) |>
  group_split() |>
  map_dfr(my_erase, y = buffered_linestring) |>
  st_transform(crs = "EPSG:4326") |> 
  mutate(year = 2025,
         change = "Reopoened",
         period = "Trump reopening") |> 
  group_by(year, change, period) |> 
  summarize(.groups = "drop")

# --- Visual check (test only) ------------------------------------------------
# This map is for checking that layers look correct. Gray = original input,
# red = 50 nm buffer, blue = 2025 result. It is NOT the final deliverable.
ggplot() +
  geom_sf(data = mpa_2014, fill = "gray", alpha = 0.5) +
  geom_sf(data = buffered_linestring, fill = "red", alpha = 0.5) +
  geom_sf(data = mpa_2025, fill = "blue", alpha = 0.5)

# --- Write output -----------------------------------------------------------
write_sf(obj = mpa_2025,
         dsn = here("data/processed/primnm_2025_polygons.gpkg"),
         delete_dsn = T)


