library(dplyr)
library(sf)
library(ggplot2)
library(RColorBrewer)
library(rcartocolor)

canton <- st_read("../ISPM_geo/data-raw/BfS/ag-b-00.03-875-gg20/ggg_2020-LV95/shp/g1k20.shp")

# lake <- st_read("../ISPM_geo/data-raw/BfS/ag-b-00.03-875-gg20/ggg_2020-LV95/shp/g1s20.shp")

lake  <- st_read("../ISPM_geo/data-raw/BfS/2019_THK_PRO/PRO/00_TOPO/K4_seenyyyymmdd/k4seenyyyymmdd_ch2007Poly.shp")
river <- st_read("../ISPM_geo/data-raw/BfS/2019_THK_PRO/PRO/00_TOPO/K4_flusyyyymmdd/k4flusyyyymmdd_ch2007.shp")

ssep3_user_geo <- readRDS("FINAL/RDS/ssep3_user_geo.Rds") %>% 
  mutate(ssep1_d = factor(ssep1_d,
                          levels = 1:10,
                          labels = c("1st - lowest", 
                                     "2", "3", "4", 
                                     "5th decile", 
                                     "6", "7", "8", "9", 
                                     "10th - highest")),
         ssep2_d = factor(ssep2_d,
                          levels = 1:10,
                          labels = c("1st - lowest", 
                                     "2", "3", "4", 
                                     "5th decile", 
                                     "6", "7", "8", "9", 
                                     "10th - highest")),
         ssep3_d = factor(ssep3_d,
                          levels = 1:10,
                          labels = c("1st - lowest", 
                                     "2", "3", "4", 
                                     "5th decile", 
                                     "6", "7", "8", "9", 
                                     "10th - highest"))) %>% 
  mutate(diff2 = as.numeric(ssep2_d) - as.numeric(ssep1_d), 
         diff3 = as.numeric(ssep3_d) - as.numeric(ssep1_d))

st_write(ssep3_user_geo, "carto/ssep3_user_geo.gpkg", delete_dsn = TRUE)
# st_write(canton, "carto/ssep3_user_geo.gpkg", append = TRUE)
# st_write(lake, "carto/ssep3_user_geo.gpkg", append = TRUE)
# st_write(river, "carto/ssep3_user_geo.gpkg", append = TRUE)

# for experiments
ssep3_user_geo_samp <- ssep3_user_geo %>% 
  sample_frac(0.01)

# colors
# 10 is easy
# display.brewer.pal(n = 10, name = "RdYlGn") 

# for more - stretch
sjmisc::frq(ssep3_user_geo$diff3)
length(unique(ssep3_user_geo$diff3))

brbg <- brewer.pal(11, "RdYlGn")
cols <- c(colorRampPalette(c(brbg[1], brbg[6]))(10), 
          colorRampPalette(c(brbg[6], brbg[11]))(10)[-1])

# sf plotting
plot(st_geometry(canton), 
     col = NA, border = "gray50", lwd = 0.1, 
     reset = FALSE)
plot(st_geometry(river), 
     # col = rgb(0, 135, 208, max = 255), border = NA, 
     col = rgb(156, 213, 248, max = 255), border = NA, 
     add = TRUE)
plot(st_geometry(lake), 
     # col = rgb(0, 135, 208, max = 255), border = NA, 
     col = rgb(156, 213, 248, max = 255), border = NA, 
     add = TRUE)
# plot(ssep3_user_geo_samp["ssep3_d"], 
#      pal = brewer.pal(n = 10, name = "RdYlGn"), 
#      cex = 0.1, pch = 16, 
#      add = TRUE)
plot(ssep3_user_geo_samp["ssep3_d"], 
     pal = cols, 
     cex = 0.1, pch = 16, 
     add = TRUE)



# gg version for deciles
ggplot() + 
  geom_sf(data = lake, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = canton, fill = NA, color = gray(.5), size = 0.25) +
  # geom_sf(data = ssep3_user_geo, aes(colour = ssep3_d), alpha = 0.66, shape = ".", size = 0.1) +
  geom_sf(data = ssep3_user_geo_samp, aes(colour = ssep3_d), 
          alpha = 0.66, shape = ".", size = 0.1) +
  scale_colour_brewer(palette = "RdYlGn") +
  theme_void() + 
  theme(legend.position = c(.05, .95), 
        legend.justification = c("left", "top"),
        legend.direction = 'vertical') +
  guides(colour = guide_legend(title = "Swiss-SEP",
                               override.aes = list(alpha = 1, shape = 16, size = 3)))

ggsave("carto/01_sep-dots.png", 
       width = 297, height = 210, units = "mm", dpi = 300,
       bg = "white")



# gg version for diff3
ggplot() + 
  geom_sf(data = lake, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = canton, fill = NA, color = gray(.5), size = 0.25) +
  geom_sf(data = ssep3_user_geo, aes(colour = factor(diff3)), 
          alpha = 0.66, shape = ".", size = 0.1) +
  # geom_sf(data = ssep3_user_geo_samp, aes(colour = factor(diff3)), 
  #         alpha = 0.66, shape = ".", size = 0.1) +
  scale_color_manual(values = cols) +
  theme_void() + 
  theme(legend.position = c(.05, .95), 
        legend.justification = c("left", "top"),
        legend.direction = 'vertical') +
  guides(colour = guide_legend(title = "Swiss-SEP 3 & 1 difference",
                               override.aes = list(alpha = 1, shape = 16, size = 3)))

ggsave("carto/01_sep-dots-diff3.png", 
       width = 297, height = 210, units = "mm", dpi = 300,
       bg = "white")



