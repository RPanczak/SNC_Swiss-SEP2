library(sf)
library(tmap)
tmap_mode("view")

# untermatweg
check <- st_as_sf(st_sfc(st_point(c(2596958.937, 1199519.492), 
                                  dim = "XY"), 
                         crs = 2056))
qtm(check)

st_join(check, ssep3_user_geo, join = st_nearest_feature)

# Wabernstrasse 65
check <- st_as_sf(st_sfc(st_point(c(2600025.250, 1198558.375), 
                                  dim = "XY"), 
                         crs = 2056))
qtm(check)

st_join(check, ssep3_user_geo, join = st_nearest_feature)

# Oenz
check <- st_as_sf(st_sfc(st_point(c(2619560, 1226440), 
                                  dim = "XY"), 
                         crs = 2056))
qtm(check)

st_join(check, ssep3_user_geo, join = st_nearest_feature)

