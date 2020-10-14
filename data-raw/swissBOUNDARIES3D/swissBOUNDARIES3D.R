library(tidyverse)
library(magrittr)
library(sf)

# #################################################
# boundaries 20
gem_20_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_HOHEITSGEBIET.shp")
# bezirk_20_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_BEZIRKSGEBIET.shp")
# canton_20_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_KANTONSGEBIET.shp")
# country_20_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET.shp")

# gem_20_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_HOHEITSGEBIET_LV03.shp")
# bezirk_20_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_BEZIRKSGEBIET_LV03.shp")
# canton_20_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_KANTONSGEBIET_LV03.shp")
# country_20_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_LANDESGEBIET_LV03.shp")

nrow(gem_20_raw)
length(unique(gem_20_raw$BFS_NUMMER))

# plot(st_geometry(gem_20_raw))

gem20 <- gem_20_raw %>% 
  st_zm(drop = TRUE) %>% 
  filter(ICC == "CH") %>% 
  filter(BFS_NUMMER < 9000) %>% 
  filter(OBJEKTART == "Gemeindegebiet") %>% 
  select(-ICC, OBJEKTART) %>% 
  rename(GMDNR = BFS_NUMMER) %>% 
  arrange(GMDNR, GEM_TEIL)

any(is.na(st_dimension(gem20)))
nrow(gem20)
length(unique(gem20$GMDNR))

View(st_drop_geometry(gem20))
plot(st_geometry(gem20))

# Monthey - multi polygon example
gem20 %>% 
  filter(GMDNR == 6153) %>% 
  select(GEM_TEIL) %>% 
  plot()

lac20 <- gem_20_raw %>% 
  st_zm(drop = TRUE) %>% 
  rename(GMDNR = BFS_NUMMER) %>% 
  filter(GMDNR >= 9000)

plot(st_geometry(lac20))
View(st_drop_geometry(lac20))

gem20 %>% 
  select(GMDNR) %>% 
  saveRDS("data/swissBOUNDARIES3D/gem20.Rds")

gem20 %>% 
  select(GMDNR) %>% 
  st_write("data/swissBOUNDARIES3D/gem20.shp", delete_dsn = TRUE)

# lac20 %>% 
#   select(GMDNR) %>% 
#   st_write("data/swissBOUNDARIES3D/lac20.shp", delete_dsn = TRUE)

rm(gem_20_raw)

# #################################################
# boundaries 18
gem_18_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2018/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_HOHEITSGEBIET.shp")
# bezirk_18_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2018/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_BEZIRKSGEBIET.shp")
# canton_18_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2018/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_KANTONSGEBIET.shp")
# country_18_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2018/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET.shp")

# gem_18_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2018/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_HOHEITSGEBIET_LV03.shp")
# bezirk_18_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2018/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_BEZIRKSGEBIET_LV03.shp")
# canton_18_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2018/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_KANTONSGEBIET_LV03.shp")
# country_18_raw <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2018/DATEN/swissTLMRegio/SHAPEFILE_LV03/swissTLMRegio_LANDESGEBIET_LV03.shp")

nrow(gem_18_raw)
length(unique(gem_18_raw$BFS_NUMMER))

# plot(st_geometry(gem_18_raw))

gem18 <- gem_18_raw %>% 
  st_zm(drop = TRUE) %>% 
  filter(ICC == "CH") %>% 
  filter(BFS_NUMMER < 9000) %>% 
  filter(OBJEKTART == "Gemeindegebiet") %>% 
  select(-ICC, OBJEKTART) %>% 
  rename(GMDNR = BFS_NUMMER) %>% 
  arrange(GMDNR, GEM_TEIL)

any(is.na(st_dimension(gem18)))
nrow(gem18)
length(unique(gem18$GMDNR))

View(st_drop_geometry(gem18))
plot(st_geometry(gem18))

lac18 <- gem_18_raw %>% 
  st_zm(drop = TRUE) %>% 
  rename(GMDNR = BFS_NUMMER) %>% 
  filter(GMDNR >= 9000)

plot(st_geometry(lac18))
View(st_drop_geometry(lac18))

gem18 %>% 
  select(GMDNR) %>% 
  saveRDS("data/swissBOUNDARIES3D/gem18.Rds")

gem18 %>% 
  select(GMDNR) %>% 
  st_write("data/swissBOUNDARIES3D/gem18.shp", delete_dsn = TRUE)

# lac18 %>% 
#   select(GMDNR) %>% 
#   st_write("data/swissBOUNDARIES3D/lac18.shp", delete_dsn = TRUE)

rm(gem_18_raw)
