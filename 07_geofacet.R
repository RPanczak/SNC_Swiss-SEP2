# #################################################
# example of assigning canton to sep to get geofacets

library(dplyr)
library(readr)
library(sf)
library(ggplot2)
library(geofacet)

# # #################################################
# # example online
# # two grids are available
# 
# library(readxl)
# 
# url <- "http://www.data.efv.admin.ch/Finanzstatistik/d/fs_ktn/ktn_schuld.xlsx"
# tf <- tempfile(fileext = ".xlsx")
# download.file(url, "ktn_schuld.xlsx")
# 
# dta2 <- read_excel("ktn_schuld.xlsx", 
#                    sheet = "schuld_per_capita", skip = 6) %>% 
#   select(-...1) %>% 
#   rename(geo = CHF) %>% 
#   gather(-geo, key = "year", value = "value") %>% 
#   filter(geo != "Kantone") %>% 
#   mutate(year = as.integer(year)) %>% 
#   mutate(geo = gsub("Kanton ", "", geo)) %>% 
#   mutate(geo = gsub(" ", "-", geo)) %>% 
#   mutate(geo = gsub("St.-Gallen", "St.Gallen", geo))
# 
# ggplot(dta2, aes(x = year, y = value)) + 
#   geom_line() +
#   theme_bw() + 
#   facet_geo(~ geo, grid = ch_cantons_grid2) +
#   ggtitle("gross debt of swiss cantons", subtitle = "per capita")
# 
# dta1 <- dta2 %>% 
#   mutate(geo = gsub("Appenzell-Innerrhoden", "Appenzell I.Rh.", geo)) %>% 
#   mutate(geo = gsub("Appenzell-Ausserrhoden", "Appenzell A.Rh.", geo)) %>% 
#   mutate(geo = gsub("St.Gallen", "St. Gallen", geo))
# 
# ggplot(dta1, aes(x = year, y = value)) + 
#   geom_line() +
#   theme_bw() + 
#   facet_geo(~ geo, grid = ch_cantons_grid1) +
#   ggtitle("gross debt of swiss cantons", subtitle = "per capita")

# #################################################
# using canton 2020 from swisstopo

ssep2_user_geo <- readRDS("data/Swiss-SEP2/ssep2_user_geo.Rds") 

canton_20 <- st_read("data-raw/swissBOUNDARIES3D/BOUNDARIES_2020/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV03_LN02/swissBOUNDARIES3D_1_3_TLM_KANTONSGEBIET.shp") %>% 
  select(NAME) %>% 
  mutate(NAME = gsub("Appenzell Innerrhoden", "Appenzell-Innerrhoden", NAME)) %>% 
  mutate(NAME = gsub("Appenzell Ausserrhoden", "Appenzell-Ausserrhoden", NAME)) %>% 
  mutate(NAME = gsub("St. Gallen", "St.Gallen", NAME))

# View(st_drop_geometry(canton_20))

ssep2_user_geo_canton <- 
  st_join(ssep2_user_geo, canton_20, join = st_intersects)

ssep2_user_geo_canton %>%  
  st_drop_geometry() %>% 
  group_by(NAME) %>% 
  summarise(n = n(),
            ssep2_mean = mean(ssep2),
            ssep2_median = median(ssep2)
  ) %>% 
  knitr::kable()

ssep2_user_geo %>% 
  ggplot(aes(x = ssep2)) + 
  geom_histogram(binwidth = 1, boundary = 0)

ssep2_user_geo_canton %>% 
  ggplot(aes(x = ssep2)) + 
  geom_histogram(binwidth = 1, boundary = 0) +
  theme_bw() + 
  facet_geo(~ NAME, grid = ch_cantons_grid2) +
  ggtitle("Swiss-SEP 2.0 across cantons")

# #################################################
# same for old index

ssep_user_geo <- readRDS("data/Swiss-SEP1/ssep_user_geo.Rds") 

# View(st_drop_geometry(canton_20))

ssep_user_geo_canton <- 
  st_join(ssep_user_geo, canton_20, join = st_intersects) 

temp <- ssep_user_geo_canton %>% 
  filter(is.na(NAME))

# correctly out of map!
# https://map.geo.admin.ch/?zoom=11&lang=fr&topic=ech&bgLayer=ch.swisstopo.pixelkarte-farbe&layers=ch.swisstopo.zeitreihen,ch.bfs.gebaeude_wohnungs_register,ch.bav.haltestellen-oev,ch.swisstopo.swisstlm3d-wanderwege&layers_opacity=1,1,1,0.8&layers_visibility=false,false,false,false&layers_timestamp=18641231,,,&E=2539814&N=1207015&crosshair=marker

ssep_user_geo_canton <- ssep_user_geo_canton %>% 
  filter(!is.na(NAME))

ssep_user_geo_canton %>%  
  st_drop_geometry() %>% 
  group_by(NAME) %>% 
  summarise(n = n(),
            ssep_mean = mean(ssep),
            ssep_median = median(ssep)
  ) %>% 
  knitr::kable()

ssep_user_geo_canton %>% 
  ggplot(aes(x = ssep)) + 
  geom_histogram(binwidth = 1, boundary = 0)

ssep2_user_geo_canton %>% 
  ggplot(aes(x = ssep2)) + 
  geom_histogram(binwidth = 1, boundary = 0) +
  theme_bw() + 
  facet_geo(~ NAME, grid = ch_cantons_grid2) +
  ylab("Number on n'hoods") +
  ggtitle("Swiss-SEP across cantons")

# ggsave("hist1.pdf", width = 320, height = 200, units = "mm")

ssep2_user_geo_canton %>% 
  ggplot(aes(x = ssep2)) + 
  geom_histogram(binwidth = 1, boundary = 0) +
  theme_bw() + 
  facet_geo(~ NAME, grid = ch_cantons_grid2, scales = "free_y") +
  ylab("Number on n'hoods") +
  ggtitle("Swiss-SEP across cantons")

# ggsave("hist2.pdf", width = 450, height = 250, units = "mm")
