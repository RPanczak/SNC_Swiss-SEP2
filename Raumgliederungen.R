library(readxl)
library(dplyr)
library(janitor)

raum_18 <- read_xlsx("data-raw/Raumgliederungen/2018-01-01_raumgliederungen.xlsx", 
                     skip = 1, 
                      col_types = c("numeric", "text", "numeric", 
                                    "text", "numeric", "text", "numeric", 
                                    "numeric", "text", "numeric", "numeric")) %>% 
  clean_names() %>% 
  remove_empty() %>% 
  filter(!is.na(bfs_gde_nummer))

View(raum_18)

saveRDS(raum_18, "data/Raumgliederungen/raum_18.Rds")

raum_20 <- read_xlsx("data-raw/Raumgliederungen/2020-01-01_raumgliederungen.xlsx", 
                     skip = 1, 
                     col_types = c("numeric", "text", "numeric", 
                                   "text", "numeric", "text", "numeric", 
                                   "numeric", "text", "numeric", "numeric")) %>% 
  clean_names() %>% 
  remove_empty() %>% 
  filter(!is.na(bfs_gde_nummer))

View(raum_20)

saveRDS(raum_20, "data/Raumgliederungen/raum_20.Rds")