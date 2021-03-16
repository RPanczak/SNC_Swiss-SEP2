library(sf)
library(tmap)
tmap_mode("view")
library(haven)
library(dplyr)

gwr_class_change <- read_dta("data/gwr_extract_210225/gwr_class_change.dta") %>% 
  zap_formats() %>% zap_label() %>% zap_labels() %>% zap_missing()

gwr_class_change_geo <- gwr_class_change %>% 
  mutate(geox_new = as.numeric(geox_new), 
         geoy_new = as.numeric(geoy_new)) %>% 
  # distinct(.keep_all = TRUE) %>% 
  # st_as_sf(coords = c("geox", "geoy"), 
  st_as_sf(coords = c("geox_new", "geoy_new"), 
           crs = 2056,
           remove = FALSE)

qtm(gwr_class_change_geo)