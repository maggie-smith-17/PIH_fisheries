library(sf)

#convert to decimal degrees

dms_to_dd <- function(deg, min, sec, dir) {
  dd <- deg + min / 60 + sec / 3600
  if (dir %in% c("S", "W")) dd <- -dd
  return(dd)
}

#create polygon
create_box <- function(name, lat1, lon1, lat2, lon2) {
  poly <- st_polygon(list(rbind(
    c(lon1, lat1), 
    c(lon2, lat1),
    c(lon2, lat2), 
    c(lon1, lat2), 
    c(lon1, lat1)
  )))
  st_sf(name = name, geometry = st_sfc(poly, crs = 4326))
  
  #boxes for each island group
  wake <- create_box(
    "Wake Island",
    dms_to_dd(20, 9, 27, "N"), dms_to_dd(165, 42, 56, "E"),
    dms_to_dd(18, 25, 51, "N"), dms_to_dd(167, 32, 23, "E")
  )
  
  howland_baker <- create_box(
    "Howland and Baker Islands",
    dms_to_dd(1, 39, 15, "N"), dms_to_dd(177, 27, 7, "W"),
    dms_to_add(0, 38, 33, "S"), dms_to_dd(175, 38, 32, "W")
  )
  
  jarvis <- create_box(
  "Jarvis Island",
  dms_to_dd(0, 28, 39, "N"), dms_to_dd(160, 50, 52, "W"),
  dms_to_dd(1, 13, 15, "S"), dms_to_dd(168, 37, 32, "W")
  )

johnston <- create_box(
  "Johnston Atoll", 
  dms_to_dd(17, 35, 39, "N"), dms_to_dd(170, 24, 37, "W"),
  dms_to_dd(15, 53, 26, "N"), dms_to_dd(168, 37, 32, "W")
)

palmyra_kingman <- create_box(
  "Palmyra Atoll and Kingman Reef", 
  dms_to_dd(7, 14, 38, "N"), dms_to_dd(163, 11, 16, "W"), 
  dms_to_dd(5, 1, 34, "N"), dms_to_dd(161, 12, 3, "W")
)

#combine 
primnm_boxes <- rbind(wake, howland_baker, jarvis, johnston, palmyra_kingman)

#looking

install.packages("mapview")  
library(mapview)

mapview(primnm_boxes)

