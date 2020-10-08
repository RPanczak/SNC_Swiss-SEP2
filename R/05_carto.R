library(dplyr)
library(readr)
library(sf)
library(ggplot2)
library(RColorBrewer)

statpop18 <- read_csv("data-raw/ag-b-00.03-vz2018statpop/STATPOP2018_GMDE.csv") %>% 
  select(GDENR, B18BTOT) %>% 
  rename(GMDNR = GDENR)

str(statpop18)
View(statpop18)

# Staatswald Galm
# C'za Cadenazzo/Monteceneri
# C'za Capriasca/Lugano

gem <- st_read("data-raw/ag-b-00.03-875-gg18/ggg_2018-LV03/shp/g1g18.shp",
               options = "ENCODING=WINDOWS-1252") %>% 
  select(GMDNR, GMDNAME ) %>% 
  left_join(statpop18) %>% 
  filter(!is.na(B18BTOT))

str(gem)
View(st_drop_geometry(gem))

st_write(gem, "data/ag-b-00.03-875-gg18/gem-statpop-18.shp")

lake <- st_read("data-raw/ag-b-00.03-875-gg18/ggg_2018-LV03/shp/g1s18.shp",
               options = "ENCODING=WINDOWS-1252") %>% 
  select(SEENAME)

st_write(lake, "data/ag-b-00.03-875-gg18/lake.shp")
