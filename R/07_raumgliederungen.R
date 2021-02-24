# #################################################
# Raumgliederungen checks

library(dplyr)
library(readr)
library(sf)
library(ggplot2)

# #################################################
# first focus - langreg
# 1	Deutsch
# 2	Französisch
# 3	Italienisch
# 4	Rätoromanisch

raum_18 <- readRDS("data/Raumgliederungen/raum_18.Rds") %>% 
  select(bfs_gde_nummer, sprachgebiete) %>% 
  rename(GMDNR = bfs_gde_nummer,
         langreg = sprachgebiete) %>% 
  mutate(GMDNR = as.integer(GMDNR),
         langreg = factor(langreg, levels = 1:4, 
                          labels = c("German", "French", "Italian", "Romansh")))

gem18 <- readRDS("data/swissBOUNDARIES3D/gem18.Rds")
length(unique(gem18$GMDNR))
# gem20 <- readRDS("data/swissBOUNDARIES3D/gem20.Rds")

gem18 <-  
  left_join(gem18, raum_18) # %>% filter(is.na(langreg))

# qtm(gem18, fill = "langreg")

gem18 %>% 
  st_drop_geometry() %>% 
  distinct(GMDNR, langreg) %>% 
  group_by(langreg) %>% 
  summarise(n = n())

# #################################################
# new index, communities 2018 

ssep2_user_geo <- readRDS("data/Swiss-SEP2/ssep2_user_geo.Rds") 

ssep2_user_geo_langreg <- 
  st_join(ssep2_user_geo, gem18, join = st_intersects)

ssep2_user_geo_langreg %>%  
  st_drop_geometry() %>% 
  group_by(langreg) %>% 
  summarise(n = n(),
            ssep2_mean = mean(ssep2),
            ssep2_median = median(ssep2)
  ) %>% 
  knitr::kable()

ssep2_user_geo_langreg %>% 
  filter(langreg != "Romansh") %>% 
  ggplot(aes(x = ssep2)) + 
  geom_histogram(binwidth = 1, boundary = 0) +
  facet_grid(vars(langreg), scales = "free_y")

ssep2_user_geo_langreg %>% 
  filter(langreg != "Romansh") %>% 
  ggplot(aes(ssep2_d, fill = langreg)) + 
  geom_bar(position = "dodge") +
  ggtitle("Swiss-SEP 2.0 across language regions")

# ggsave("langreg2.pdf", width = 320, height = 200, units = "mm")

# #################################################
# old index, communities 2018 

ssep_user_geo <- readRDS("data/Swiss-SEP1/ssep_user_geo.Rds") 

ssep_user_geo_langreg <- 
  st_join(ssep_user_geo, gem18, join = st_intersects) %>% 
  filter(!is.na(GMDNR))

# ssep_user_geo_langreg %>% 
#   filter(is.na(GMDNR)) %>% 
#   qtm()

ssep_user_geo_langreg %>%  
  st_drop_geometry() %>% 
  group_by(langreg) %>% 
  summarise(n = n(),
            ssep_mean = mean(ssep),
            ssep_median = median(ssep)
  ) %>% 
  knitr::kable()

ssep_user_geo_langreg %>% 
  filter(langreg != "Romansh") %>% 
  ggplot(aes(x = ssep)) + 
  geom_histogram(binwidth = 1, boundary = 0) +
  facet_grid(vars(langreg), scales = "free_y")

ssep_user_geo_langreg %>% 
  filter(langreg != "Romansh") %>% 
  ggplot(aes(ssep_d, fill = langreg)) + 
  geom_bar(position = "dodge") +
  ggtitle("Swiss-SEP 1.0 across language regions")

ssep_user_geo_langreg %>% 
  filter(langreg != "Romansh") %>% 
  ggplot(aes(ssep_d, fill = langreg)) + 
  geom_bar(aes(y = (..count..)/sum(..count..))) +
  scale_y_continuous(labels=scales::percent) +
  ggtitle("Swiss-SEP 1.0 across language regions") +
  ylab("Share of n'hoods")

# ggsave("langreg1.pdf", width = 320, height = 200, units = "mm")

