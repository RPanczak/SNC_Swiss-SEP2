library(pacman)
p_load(tidyverse, haven, finalfit, writexl)


ssep3_user_snc <- read_dta("FINAL/DTA/ssep3_user_snc.dta") %>% 
  select(buildid, 
         ssep1_d, ssep2_d, ssep3_d) %>% 
  mutate(ssep1_d = factor(ssep1_d),
         ssep2_d = factor(ssep2_d),
         ssep3_d = factor(ssep3_d))


SE <- read_dta("data/SE.dta") %>% 
  zap_labels() %>% 
  left_join(ssep3_user_snc) %>% 
  filter(!is.na(ssep3_d)) %>% 
  rename(Gender = sex) %>% 
  mutate(Gender = factor(Gender, 
                         labels = c("Male", "Female"))) %>% 
  rename(Age = age) %>% 
  mutate(Age = cut(Age, 
                   breaks = c(0, 35, 50, 65, 112), right = FALSE, 
                   labels = c("19-34", "35-49", "50-64", "Above 65"))) %>% 
  mutate(civil = factor(civil, 
                        labels = c("Single", "Married", 
                                   "Widowed", "Divorced"))) %>% 
  rename(Nationality = nat_bin) %>% 
  mutate(Nationality = factor(Nationality, 
                              labels = c("Swiss", "Foreigner"))) %>% 
  rename(Language = langmain1) %>% 
  mutate(Language = factor(Language, 
                           labels = c("German", "French", "Italian", 
                                      "Other language"))) %>% 
  rename(Education = educ_agg) %>% 
  mutate(Education = factor(Education, 
                            labels = c("Primary education or less", 
                                       "Upper secondary level", 
                                       "Tertiary level"))) %>% 
  mutate(sopc_agg = factor(sopc_agg, 
                           labels = c("Top management and independent professions", 
                                      "Other self-employed", 
                                      "Professionals and senior management", 
                                      "Supervisors/low level management and skilled labour", 
                                      "Unskilled employees and workers", 
                                      "In paid employment, not classified elsewhere", 
                                      "Unemployed/job-seeking", 
                                      "Not in paid employment"))) %>% 
  mutate(urban = factor(urban, 
                        labels = c("Urban", 
                                   "Peri-urban", 
                                   "Rural")))

sjmisc::frq(SE, ssep3_d)
sjmisc::frq(SE, Gender)
sjmisc::frq(SE, Age)
sjmisc::frq(SE, civil)
sjmisc::frq(SE, Nationality)
sjmisc::frq(SE, Language)
sjmisc::frq(SE, Education)
sjmisc::frq(SE, sopc_agg)
sjmisc::frq(SE, urban)

# rm(ssep3_user_snc); gc()

explanatory = c("Gender", "Age", 
                "civil", "Nationality", "Language",
                "Education", "sopc_agg", "urban")

# fix labels
SE %<>%
  mutate(civil = ff_label(civil, "Civil status"),
         sopc_agg = ff_label(sopc_agg, "Professional status"), 
         urban = ff_label(urban, "Level of urbanisation"))

SE %>%
  summary_factorlist("ssep1_d", explanatory,
                     p = FALSE, 
                     total_col = TRUE, 
                     na_include = TRUE,
                     add_dependent_label = FALSE) %>% 
  rename(Characteristic = label) %>% 
  select(1:3, 7, 12, 13) -> table_1_ssep1

SE %>%
  summary_factorlist("ssep2_d", explanatory,
                     p = FALSE, 
                     total_col = TRUE, 
                     na_include = TRUE,
                     add_dependent_label = FALSE) %>% 
  rename(Characteristic = label) %>% 
  select(1:3, 7, 12, 13) -> table_1_ssep2

SE %>%
  summary_factorlist("ssep3_d", explanatory,
                     p = FALSE, 
                     total_col = TRUE, 
                     na_include = TRUE,
                     add_dependent_label = FALSE) %>% 
  rename(Characteristic = label) %>% 
  select(1:3, 7, 12, 13) -> table_1_ssep3


write_xlsx(list(table_1_ssep1 = table_1_ssep1, 
                table_1_ssep2 = table_1_ssep2, 
                table_1_ssep3 = table_1_ssep3), 
           "analyses/table_1.xlsx")

knitr::kable(table_1_ssep3, 
             row.names = FALSE, align = c("l", "l", "r", "r", "r"))
