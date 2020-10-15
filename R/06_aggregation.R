# #################################################
# example of aggregating sep to community level

library(dplyr)
library(readr)
library(sf)

# #################################################
# using gem 2020 from swisstopo

ssep2_user_geo <- readRDS("data/Swiss-SEP2/ssep2_user_geo.Rds") 

gem20 <- readRDS("data/swissBOUNDARIES3D/gem20.Rds")

# overlay
ssep2_gem_20_sum <- 
  st_join(ssep2_user_geo, gem20, join = st_intersects) %>% 
  st_drop_geometry() %>% 
  group_by(GMDNR) %>% 
  summarise(n = n(),
            ssep2_mean = mean(ssep2),
            ssep2_median = median(ssep2)
  )
