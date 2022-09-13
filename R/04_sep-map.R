# #######################################
library(dplyr)
library(sf)
library(ggplot2)
library(RColorBrewer)
library(rcartocolor)

import::from("sjmisc", "frq")

canton <- st_read("../ISPM_geo/data-raw/BfS/ag-b-00.03-875-gg20/ggg_2020-LV95/shp/g1k20.shp")

# lake <- st_read("../ISPM_geo/data-raw/BfS/ag-b-00.03-875-gg20/ggg_2020-LV95/shp/g1s20.shp")

lake  <- st_read("../ISPM_geo/data/KM04-00-c-suis-2022-q/2022_GEOM_TK/00_TOPO/K4_seenyyyymmdd/k4seenyyyymmdd_ch2007Poly.shp")
river <- st_read("../ISPM_geo/data/KM04-00-c-suis-2022-q/2022_GEOM_TK/00_TOPO/K4_flusyyyymmdd/k4flusyyyymmdd_ch2007.shp")

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
  mutate(diff2d = as.numeric(ssep2_d) - as.numeric(ssep1_d), 
         diff3d = as.numeric(ssep3_d) - as.numeric(ssep1_d),
         diff2q = as.numeric(ssep2_q) - as.numeric(ssep1_q), 
         diff3q = as.numeric(ssep3_q) - as.numeric(ssep1_q))

# st_write(ssep3_user_geo, "carto/ssep3_user_geo.gpkg", delete_dsn = TRUE)
# 
# st_write(canton, "carto/ssep3_user_geo.gpkg", 
#          layer = "canton", append = TRUE)
# st_write(lake, "carto/ssep3_user_geo.gpkg", 
#          layer = "lake", append = TRUE)
# st_write(river, "carto/ssep3_user_geo.gpkg", 
#          layer = "river", append = TRUE)

# for experiments
ssep3_user_geo_samp <- ssep3_user_geo %>% 
  sample_frac(0.01)

frq(ssep3_user_geo_samp$ssep3_d)

# #######################################
# colors - 10 is easy
# display.brewer.pal(n = 10, name = "RdYlGn") 
cols <- brewer.pal(10, "RdYlGn")

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


# #######################################
# gg version for deciles
ggplot() + 
  geom_sf(data = lake, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = canton, fill = NA, color = gray(.5), size = 0.25) +
  geom_sf(data = ssep3_user_geo, aes(colour = ssep2_d), 
          alpha = 0.66, shape = ".", size = 0.1) +
  # geom_sf(data = ssep3_user_geo_samp, aes(colour = ssep2_d), 
  #         alpha = 0.66, shape = ".", size = 0.1) +
  scale_colour_brewer(palette = "RdYlGn") +
  theme_void() + 
  theme(legend.position = c(.05, .95), 
        legend.justification = c("left", "top"),
        legend.direction = "vertical") +
  guides(colour = guide_legend(title = "Swiss-SEP 2",
                               override.aes = list(alpha = 1, shape = 16, size = 3)))

ggsave("carto/01_sep2-dots.png", 
       width = 297, height = 210, units = "mm", dpi = 300,
       bg = "white")

ggplot() + 
  geom_sf(data = lake, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = canton, fill = NA, color = gray(.5), size = 0.25) +
  geom_sf(data = ssep3_user_geo, aes(colour = ssep3_d), 
          alpha = 0.66, shape = ".", size = 0.1) +
  # geom_sf(data = ssep3_user_geo_samp, aes(colour = ssep3_d), 
  #         alpha = 0.66, shape = ".", size = 0.1) +
  scale_colour_brewer(palette = "RdYlGn") +
  theme_void() + 
  theme(legend.position = c(.05, .95), 
        legend.justification = c("left", "top"),
        legend.direction = "vertical") +
  guides(colour = guide_legend(title = "Swiss-SEP 3",
                               override.aes = list(alpha = 1, shape = 16, size = 3)))

ggsave("carto/01_sep3-dots.png", 
       width = 297, height = 210, units = "mm", dpi = 300,
       bg = "white")

# #######################################
# gg version for diff2

# we need more colours for differences on deciles

frq(ssep3_user_geo$diff3d)
length(unique(ssep3_user_geo$diff3d))

frq(ssep3_user_geo$diff2d)
length(unique(ssep3_user_geo$diff2d))

# stretch the pallete from 11 to 19
brewer <- brewer.pal(11, "RdYlGn")
cols <- c(colorRampPalette(c(brewer[1], brewer[6]))(10), 
          colorRampPalette(c(brewer[6], brewer[11]))(10)[-1])
length(unique(cols))

barplot(1:19, col = cols)

# masking middle with light grey? get rids of yellow middle band
cols[10] <- "#E5E5E5"

barplot(1:19, col = cols)

ggplot() + 
  geom_sf(data = lake, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = canton, fill = NA, color = gray(.5), size = 0.25) +
  geom_sf(data = ssep3_user_geo, 
          aes(colour = factor(diff3d)), 
          alpha = 0.66, shape = ".", size = 0.1) +
  scale_color_manual(values = cols) +
  theme_void() + 
  theme(legend.position = c(.05, .95), 
        legend.justification = c("left", "top"),
        legend.direction = "vertical") +
  guides(colour = guide_legend(title = "Swiss-SEP 3 & 1 difference",
                               override.aes = list(alpha = 1, shape = 16, size = 3)))

# doesnt really work so no save
# ggsave("carto/01_sep-diff3d.png", 
#        width = 297, height = 210, units = "mm", dpi = 300,
#        bg = "white")


# #######################################
# gg version for differences
# using deciles 
# masking [-1, 1] difference
# splitting data : plotting grey first to avoid overplotting

ssep2_grey <- ssep3_user_geo %>% 
  filter(diff2d >= -1 & diff2d  <= 1)

ssep2_color <- ssep3_user_geo %>% 
  filter(diff2d <= -2 | diff2d >= 2)

stopifnot(nrow(ssep3_user_geo) == nrow(ssep2_grey) + nrow(ssep2_color))

scales::percent(nrow(ssep2_color) / nrow(ssep3_user_geo), accuracy = 0.01)

frq(ssep2_grey$diff2d)
frq(ssep2_color$diff2d)

# we need more colours for differences on deciles
length(unique(ssep2_color$diff2d))

# stretch to 16
brewer <- brewer.pal(11, "PiYG")
cols <- c(colorRampPalette(c(brewer[1], brewer[5]))(8), 
          colorRampPalette(c(brewer[7], brewer[11]))(8))
length(unique(cols))

barplot(1:16, col = cols)

ggplot() + 
  geom_sf(data = lake, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = canton, fill = NA, color = gray(.5), size = 0.25) +
  geom_sf(data = ssep2_grey,
          color = "grey95",
          shape = ".", size = 0.01) +
  geom_sf(data = ssep2_color,
          aes(colour = factor(diff2d)),
          shape = ".", size = 0.6) +
  scale_color_manual(values = cols) +
  theme_void() + 
  theme(legend.position = c(.05, .95), 
        legend.justification = c("left", "top"),
        legend.direction = "vertical") +
  guides(colour = guide_legend(title = "Swiss-SEP 2 & 1 difference",
                               override.aes = list(alpha = 1, shape = 16, size = 3)))

ggsave("carto/01_sep-dots-diff2d.png", 
       width = 297, height = 210, units = "mm", dpi = 300,
       bg = "white")

# st_write(ssep2_grey, "carto/ssep3_user_d.gpkg", 
#          layer = "grey", delete_dsn = TRUE)
# st_write(ssep2_color, "carto/ssep3_user_d.gpkg", 
#          layer = "color", append = TRUE)



# now same but on quintiles
ssep2_grey <- ssep3_user_geo %>% 
  filter(diff2q == 0)

ssep2_color <- ssep3_user_geo %>% 
  filter(diff2q <= -1 | diff2q >= 1)

stopifnot(nrow(ssep3_user_geo) == nrow(ssep2_grey) + nrow(ssep2_color))

frq(ssep2_grey$diff2q)
frq(ssep2_color$diff2q)
length(unique(ssep2_color$diff2q))

# skipping lightest tones on both sides
brewer <- brewer.pal(10, "PiYG")
cols <- c(brewer[1:4],
          brewer[7:10])
length(unique(cols))
barplot(1:8, col = cols)

scales::percent(nrow(ssep2_color) / nrow(ssep3_user_geo), accuracy = 0.01)

frq(ssep2_color$diff2q)

ggplot() + 
  geom_sf(data = lake, color = NA,  fill = rgb(156, 213, 248, max = 255)) + 
  geom_sf(data = canton, fill = NA, color = gray(.5), size = 0.25) +
  geom_sf(data = ssep2_grey, 
          color = "grey95", 
          shape = ".", size = 0.01) +
  geom_sf(data = ssep2_color, 
          aes(colour = factor(diff2q)), 
          shape = ".", size = 0.6) +
  scale_color_manual(values = cols) +
  theme_void() + 
  theme(legend.position = c(.05, .95), 
        legend.justification = c("left", "top"),
        legend.direction = "vertical") +
  guides(colour = guide_legend(title = "Swiss-SEP 2 & 1 difference",
                               override.aes = list(alpha = 1, shape = 16, size = 3)))

ggsave("carto/01_sep-dots-diff2q.png", 
       width = 297, height = 210, units = "mm", dpi = 300,
       bg = "white")

# st_write(ssep2_grey, "carto/ssep3_user_q.gpkg", 
#          layer = "grey", delete_dsn = TRUE)
# st_write(ssep2_color, "carto/ssep3_user_q.gpkg", 
#          layer = "color", append = TRUE)

# #######################################
library(tmap)
tmap_mode("plot")

# #######################################
tmap_mode("view")

ssep2_color %>% 
  filter(diff2d < -4) %>% 
  mutate(diff2d = factor(diff2d)) %>% 
  tm_shape() +
  tm_dots("diff2d", n = 6, palette = "RdYlGn", midpoint = NA)
