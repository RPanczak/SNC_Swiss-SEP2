library(dplyr)
library(sf)
library(ggplot2)
library(RColorBrewer)

canton <- st_read("../ISPM_geo/data-raw/ag-b-00.03-875-gg20/ggg_2020-LV95/shp/g1k20.shp")

lake <- st_read("../ISPM_geo/data-raw/ag-b-00.03-875-gg20/ggg_2020-LV95/shp/g1s20.shp")

ssep3_user_geo <- readRDS("FINAL/RDS/ssep3_user_geo.Rds") %>% 
  mutate(ssep3_d = factor(ssep3_d,
                          levels = 1:10,
                          labels = c("1st - lowest", 
                                     "2", "3", "4", 
                                     "5th decile", 
                                     "6", "7", "8", "9", 
                                     "10th - highest")))

# for experiments
ssep3_user_geo_samp <- ssep3_user_geo %>% 
  sample_frac(0.01)

# display.brewer.pal(n = 10, name = "RdYlGn") 

# sf plotting
plot(st_geometry(canton), 
     col = NA, border = "gray50", lwd = 0.1, 
     reset = FALSE)
plot(st_geometry(lake), 
     # col = rgb(0, 135, 208, max = 255), border = NA, 
     col = rgb(156, 213, 248, max = 255), border = NA, 
     add = TRUE)
plot(ssep3_user_geo_samp["ssep3_d"], 
     pal = brewer.pal(n = 10, name = "RdYlGn"), 
     cex = 0.1, pch = 16, 
     add = TRUE)

# gg version
ggplot() + 
  geom_sf(data = lake, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = canton, fill = NA, color = gray(.5), size = 0.25) +
  geom_sf(data = ssep3_user_geo, aes(colour = ssep3_d), alpha = 0.66, shape=".", size = 0.1) +
  # geom_sf(data = ssep3_user_geo_samp, aes(colour = ssep3_d), alpha = 0.66, shape=".", size = 0.1) +
  scale_colour_brewer(palette = "RdYlGn") +
  theme_void() + 
  theme(legend.position = c(.05, .95), 
        legend.justification = c("left", "top"),
        legend.direction = 'vertical') +
  guides(colour = guide_legend(title = "Swiss-SEP",
                               override.aes = list(alpha = 1, shape = 16, size = 3)))


ggsave("carto/01_sep-dots-r.png", width = 297, height = 210, units = "mm", dpi = 300)

