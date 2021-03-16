library(sf)
library(tmap)
tmap_mode("view")
library(haven)
library(dplyr)

SE_gklas_errors <- read_dta("data/gwr_extract_210225/SE_gklas_errors.dta") %>% 
  zap_formats() %>% zap_label() %>% zap_labels() %>% zap_missing() 

SE_gklas_errors_geo <- SE_gklas_errors %>% 
  as.data.frame() %>% 
  mutate(geox_new = as.numeric(geox_new), 
         geoy_new = as.numeric(geoy_new)) %>% 
  # distinct(.keep_all = TRUE) %>% 
  # st_as_sf(coords = c("geox", "geoy"), 
  st_as_sf(coords = c("geox_new", "geoy_new"), 
           crs = 2056,
           remove = FALSE)

qtm(SE_gklas_errors_geo)

