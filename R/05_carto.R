library(dplyr)
library(readr)
library(sf)
library(ggplot2)
library(RColorBrewer)

# #################################################
# statpop figures needed for carto weights

statpop18 <- read_csv("data-raw/BfS/ag-b-00.03-vz2018statpop/STATPOP2018_GMDE.csv") %>%
  select(GDENR, B18BTOT) %>%
  rename(GMDNR = GDENR)

str(statpop18)
View(statpop18)

# Staatswald Galm
# C'za Cadenazzo/Monteceneri
# C'za Capriasca/Lugano

# #################################################
# shape files for cartogram input

gem <- st_read("../ISPM_geo/data-raw/BfS/ag-b-00.03-875-gg18/ggg_2018-LV95/shp/g1g18.shp",
               options = "ENCODING=WINDOWS-1252") %>%
  st_transform(2056) %>% 
  select(GMDNR, GMDNAME ) %>%
  left_join(statpop18) %>%
  filter(!is.na(B18BTOT))

str(gem)
View(st_drop_geometry(gem))

# st_write(gem, "data/BfS/ag-b-00.03-875-gg18/gem-statpop-18.shp")
# 
# lake <- st_read("../ISPM_geo/data-raw/BfS/ag-b-00.03-875-gg18/ggg_2018-LV95/shp/g1s18.shp",
#                 options = "ENCODING=WINDOWS-1252") %>%
#   select(SEENAME)
# 
# st_write(lake, "data/BfS/ag-b-00.03-875-gg18/lake.shp")
# 
# canton <- st_read("../ISPM_geo/data-raw/BfS/ag-b-00.03-875-gg20/ggg_2020-LV95/shp/g1k20.shp",
#                   options = "ENCODING=WINDOWS-1252") %>%
#   select(KTNAME)
# 
# st_write(canton, "data/BfS/ag-b-00.03-875-gg18/canton.shp")

# #################################################
# java -Xmx1024m -jar ../ISPM_geo/software/ScapeToad-v11/ScapeToad.jar
# java -Xmx1024m -jar ScapeToad.jar

# #################################################
# shape files from scapetoad

gem_carto <- st_read("data/BfS/ag-b-00.03-875-gg18/gem-statpop-18-carto.shp",
                     options = "ENCODING=WINDOWS-1252") %>% 
  select(-B18BTOTDens, -SizeError)

lake_carto <- st_read("data/BfS/ag-b-00.03-875-gg18/lake-carto.shp",
                      options = "ENCODING=WINDOWS-1252")

canton_carto <- st_read("data/BfS/ag-b-00.03-875-gg18/canton-carto.shp",
                        options = "ENCODING=WINDOWS-1252")

plot(st_geometry(lake_carto), col = "lightblue", border = NA)
plot(st_geometry(gem_carto), add = TRUE, col = NA, border = "grey40")

plot(st_geometry(lake_carto), col = "lightblue", border = NA)
plot(st_geometry(canton_carto), add = TRUE, col = NA, border = "grey40")

# #################################################
# getting gem 18 codes to sep data

ssep3_user_geo <- readRDS("FINAL/RDS/ssep3_user_geo.Rds") 

# overlay
ssep3_gem_18_sum <-  
  st_join(ssep3_user_geo, gem, join = st_intersects) %>% 
  st_drop_geometry() %>% 
  group_by(GMDNR) %>% 
  summarise(ssep3_mean = mean(ssep3),
            ssep3_median = median(ssep3)) %>% 
  mutate(decile = ntile(ssep3_median, 10))

ssep3_gem_18_carto <- gem_carto %>% 
  left_join(ssep3_gem_18_sum)

ggplot() + 
  geom_sf(data = lake_carto, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = ssep3_gem_18_carto, 
          aes(fill = ssep3_median), 
          colour = "white",
          size = 0.1) +
  geom_sf(data = canton_carto, fill = NA, color = gray(.5), size = 0.1) +
  scale_fill_distiller(palette = "RdYlGn", direction = 1) +
  theme_void() + 
  guides(colour = guide_legend(title = "Swiss-SEP",
                               override.aes = list(alpha = 1, shape = 16, size = 3)))


# ggsave("carto/03_cartogram-r-median.png", 
#        width = 297, height = 210, units = "mm", dpi = 300)


ggplot() + 
  geom_sf(data = lake_carto, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = ssep3_gem_18_carto, 
          aes(fill = ssep3_mean), 
          colour = "white",
          size = 0.1) +
  geom_sf(data = canton_carto, fill = NA, color = gray(.5), size = 0.1) +
  scale_fill_distiller(palette = "RdYlGn", direction = 1) +
  theme_void() + 
  guides(colour = guide_legend(title = "Swiss-SEP",
                               override.aes = list(alpha = 1, shape = 16, size = 3)))


# ggsave("carto/03_cartogram-r-mean.png", 
#        width = 297, height = 210, units = "mm", dpi = 300)


ggplot() + 
  geom_sf(data = lake_carto, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = ssep3_gem_18_carto, 
          aes(fill = factor(decile)), 
          colour = NA,
          alpha = 0.8) +
  geom_sf(data = canton_carto, fill = NA, color = gray(.5), size = 0.1) +
  scale_fill_brewer(palette = "RdYlGn", direction = 1) +
  theme_void() + 
  guides(colour = guide_legend(title = "Swiss-SEP",
                               override.aes = list(alpha = 1, shape = 16, size = 3)))


ggsave("carto/03_cartogram-r-decile.png", 
       width = 297, height = 210, units = "mm", dpi = 300)

# for hex on website
ggplot() + 
  geom_sf(data = lake_carto, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = ssep3_gem_18_carto, aes(fill = factor(decile)), 
          colour = NA) +
  geom_sf(data = canton_carto, fill = NA, color = "white", size = 0.1) +
  scale_fill_brewer(palette = "PuOr", direction = 1) +
  theme_void() + theme(legend.position = "none") 

ggsave("../../external/website/content/project/swisssep/carto.png", 
       width = 297, height = 210, units = "mm", dpi = 300)

