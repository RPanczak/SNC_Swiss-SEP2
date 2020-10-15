# #################################################
# example of aggregating sep to community level

library(dplyr)
library(readr)
library(sf)
library(ggplot2)
library(RColorBrewer)

# #################################################
# using gem 2020 from swisstopo

ssep2_user_geo <- readRDS("data/Swiss-SEP2/ssep2_user_geo.Rds") 

gem20 <- readRDS("data/swissBOUNDARIES3D/gem20.Rds")

# overlay
ssep2_gem_20 <- 
  st_join(ssep2_user_geo, gem20, join = st_intersects) 

ssep2_gem_20_sum <- ssep2_gem_20 %>% 
  st_drop_geometry() %>% 
  group_by(GMDNR) %>% 
  summarise(n = n(),
            ssep2_mean = mean(ssep2),
            ssep2_median = median(ssep2)
  )

# #################################################
# old sep with gem 2020 from swisstopo

ssep_user_geo <- readRDS("data/Swiss-SEP1/ssep_user_geo.Rds") 

# overlay
ssep_gem_20 <- 
  st_join(ssep_user_geo, gem20, join = st_intersects) 

ssep_gem_20_sum <- ssep_gem_20 %>% 
  st_drop_geometry() %>% 
  group_by(GMDNR) %>% 
  summarise(n = n(),
            ssep_mean = mean(ssep),
            ssep_median = median(ssep)
  )

ssep_gem_20_sum %>% 
  filter(GMDNR == 351)

ssep_gem_20 %>% 
  st_drop_geometry() %>% 
  filter(GMDNR == 351) %>% 
  ggplot(aes(x = ssep), fill = ssep_d) + 
  geom_histogram(binwidth = 1, boundary = 0) + 
  scale_fill_brewer(palette = "RdYlGn") +
  geom_vline(data = filter(ssep_gem_20_sum, GMDNR == 351), aes(xintercept = ssep_mean)) +
  labs(title = "Swiss-SEP in Bern (351)", 
       caption = "n = 13,671")
  
# ggsave("hist_bern1.pdf", width = 450, height = 250, units = "mm")

ssep_gem_20 %>% 
  st_drop_geometry() %>% 
  filter(GMDNR == 351) %>% 
  group_by(ssep_d) %>% 
  summarize(n = n()) %>% 
  ggplot(aes(x = as.factor(ssep_d), y = n, fill = as.factor(ssep_d))) + 
  geom_col() + 
  scale_fill_brewer(palette = "RdYlGn") +
  geom_vline(data = filter(ssep_gem_20_sum, GMDNR == 351), aes(xintercept = ssep_mean)) +
  labs(title = "Swiss-SEP in Bern (351)", 
       caption = "n = 13,671")

# ggsave("hist_bern2.pdf", width = 450, height = 250, units = "mm")
