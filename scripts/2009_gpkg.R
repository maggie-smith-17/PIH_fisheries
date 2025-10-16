library(sf)
library(dplyr)

#create a data frame of island coordinates 

islands <- data.frame(
  name = c("Baker", "Howland", "Jarvis", "Johnston", "Kingman", "Palmyra", "Wake"),
  lon = c(-176.476, -176.618, -160.021, -169.533, -162.417, -162.083, 166.650), 
  lat = c(0.193, 0.811, -0.374, 16.749, 6.383, 5.883, 19.283)
)

#convert to sf points

points <- st_as_sf(islands, coords = c("lon", "lat"), crs = 4326)

#projected CRS 
points_proj <- st_transform(points, 3857)

# Buffer 50 nautical miles (~92.6 km)
buffers_proj <- st_buffer(points_proj, dist = 92600)

buffers <- st_transform(buffers_proj, 4326)

st_write(buffers, "data/processed/primnm_2009.gpkg")