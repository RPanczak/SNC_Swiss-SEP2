library(sf)
library(tmap)
tmap_mode("view")

check <- st_as_sf(st_sfc(st_point(c(2600025.250, 1198558.375), 
                                  dim = "XY"), 
                         crs = 2056))
qtm(check)

check_join <- st_join(check, sep3, join = st_nearest_feature)

