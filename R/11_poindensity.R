library(readr)
library(dplyr)
library(sf)
library(ggmap)
library(pointdensityP)

key_google <- readr::read_file("secrets/api_google.txt")
register_google(key = key_google)

library(KernSmooth)

ssep2_user_geo <- read_rds("data/Swiss-SEP2/ssep2_user_geo.Rds") %>% 
  filter(ssep2_d == 1) %>% 
  st_transform(crs = 4326) 

x <- ssep2_user_geo %>% 
  mutate(lat = unlist(purrr::map(ssep2_user_geo$geometry, 1)),
         long = unlist(purrr::map(ssep2_user_geo$geometry, 2))) %>% 
  st_drop_geometry() %>% 
  select(lat, long) %>% 
  as.data.frame()

est <- bkde2D(x, bandwidth = c(0.05, 0.05), gridsize = c(1600, 1200)) # , range.x = list(c(-117.45, -116.66), c(32.52, 33.26)))

BKD_df <- data.frame(lat = rep(est$x2, each = 1600), lon = rep(est$x1, 1200),
                     count = c(est$fhat))

map_base <- qmap(location = "46.7985, 8.2318", 
                 maptype= "toner", source = "stamen",
                 zoom = 7, darken = 0.3)

map_base + 
  stat_contour(data = BKD_df,
               geom = "polygon", bins = 150, alpha = 0.05, 
               aes(x = lon, y = lat, z = count, fill = ..level..)) + 
  scale_fill_continuous(name = "density", low = "green", high = "red")

SD_density <- pointdensity(df = x, lat_col = "lat", lon_col = "long",
                           grid_size = 0.1, radius = 1)

map_base + 
  geom_point(data = SD_density,
             aes(x = lat, y = lon, colour = count), 
             shape = 16, size = 2) + 
  scale_colour_gradient(low = "green", high = "red")

