library(dplyr)
library(sf)
library(ggplot2)
library(RColorBrewer)

gem18_st <- readRDS("data/swissBOUNDARIES3D/gem18.Rds") 

lake_st <- st_read("data-raw/ag-b-00.03-875-gg20/ggg_2020-LV03/shp/g1s20.shp")


gem18_bfs <- st_read("data-raw/ag-b-00.03-875-gg18/ggg_2018-LV95/shp/g1g18.shp") %>% 
  select(GMDNR)#, GMDNAME)

lake_bfs <- st_read("data-raw/ag-b-00.03-875-gg20/ggg_2020-LV03/shp/g1s20.shp")

ssep_user_geo <- readRDS("FINAL/RDS/ssep3_user_geo.Rds") %>% 
  mutate(ssep3_d = factor(ssep3_d,
                          levels = 1:10,
                          labels = c("1st - lowest", 
                                     "2", "3", "4", 
                                     "5th decile", 
                                     "6", "7", "8", "9", 
                                     "10th - highest")))

# for experiments
ssep_user_geo_samp <- ssep_user_geo %>% 
  sample_frac(0.01)