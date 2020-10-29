library(tidyverse)
library(magrittr)
library(sf)
library(tmap)
tmap_mode("view")

# #################################################
# boundaries 2020-10
plz_20_10 <- st_read("data-raw/PLZ/20201001/PLZO_SHP_LV95/PLZO_PLZ.shp") %>% 
  select(PLZ) %>% 
  filter(PLZ != 9999) %>% 
  filter(PLZ < 9485 | PLZ > 9499)

any(is.na(st_dimension(plz_20_10)))

# # FL
# plz_20_10 %>%
#   filter(PLZ>= 9485 & PLZ <= 9499) %>%
#   qtm()

# # lakes
# plz_20_10 %>% 
#   filter(PLZ == 9999) %>% 
#   qtm(fill = NULL, borders = "red")

# funny ones
plz_20_10 %>%
  filter(PLZ %in% c(8238, )) %>%
  qtm(fill = NULL, borders = "red")

nrow(plz_20_10)
length(unique(plz_20_10$PLZ))
summary(plz_20_10$PLZ)

# plot(st_geometry(plz_20_10))
qtm(plz_20_10)
# View(st_drop_geometry(plz_20_10))
# View(plz_20_10)

# 1000 - multi polygon example
plz_20_10 %>% 
  filter(PLZ == 1000) %>% 
  qtm(fill = NULL, borders = "red")

plz_20_10 %>% 
  write_rds("data/PLZ/plz_20_10.Rds")

plz_20_10 %>% 
  st_write("data/PLZ/plz_20_10.shp", delete_dsn = TRUE)
