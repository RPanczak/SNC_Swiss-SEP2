library(tidyverse)
library(magrittr)
library(sf)

# boundaries
gem_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_HOHEITSGEBIET.shp")
bezirk_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_BEZIRKSGEBIET.shp")
canton_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_KANTONSGEBIET.shp")
country_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET.shp")

# gem_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_HOHEITSGEBIET_LV03.shp")
# bezirk <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_BEZIRKSGEBIET_LV03.shp")
# canton <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_KANTONSGEBIET_LV03.shp")
# country <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_LANDESGEBIET_LV03.shp")

nrow(gem_raw)
length(unique(gem_raw$BFS_NUMMER))

# plot(st_geometry(gem_raw))

gem <- gem_raw %>% 
  st_zm(drop = TRUE) %>% 
  filter(ICC == "CH") %>% 
  filter(BFS_NUMMER < 9000) %>% 
  filter(OBJEKTART == "Gemeindegebiet") %>% 
  select(-ICC, OBJEKTART) %>% 
  arrange(BFS_NUMMER, GEM_TEIL)

any(is.na(st_dimension(gem)))
nrow(gem)
length(unique(gem$BFS_NUMMER))

View(st_drop_geometry(gem))
plot(st_geometry(gem))

# Monthey
gem %>% 
  filter(BFS_NUMMER == 6153) %>% 
  select(GEM_TEIL) %>% 
  plot()

lac <- gem_raw %>% 
  st_zm(drop = TRUE) %>% 
  filter(BFS_NUMMER >= 9000)

plot(st_geometry(lac))
View(st_drop_geometry(gem_raw))


# ssep2


# overlay
st_join(pts, gem, join = st_intersects)
