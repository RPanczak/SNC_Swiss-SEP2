library(pacman)
p_load(tidyverse, haven, ggridges, hrbrthemes, ggbeeswarm)

SHP_income <- read_dta("data/SHP_income.dta") %>%
  zap_label() %>% zap_labels() %>% 
  mutate(ssep1_d = factor(ssep1_d),
         ssep2_d = factor(ssep2_d),
         ssep3_d = factor(ssep3_d))

# full dataset
ggplot(SHP_income, aes(x = ssep3, y = eq_ihtyni / 10000)) +
  geom_point(shape = 16, alpha = 0.1) +
  geom_smooth(aes(weight = wh14css)) +
  ylab("Equivalised income [in 10k CHF]") +
  xlab("Swiss-SEP3") +
  coord_fixed() +
  theme_minimal() +
  theme(aspect.ratio = 1)

# excluding four outliers of income
ggplot(SHP_income, aes(x = ssep3, y = eq_ihtyni / 10000)) +
  geom_point(shape = 16, alpha = 0.1) +
  geom_smooth(aes(weight = wh14css)) +
  ylab("Equivalised income [in 10k CHF]") +
  xlab("Swiss-SEP3") +
  coord_fixed(ylim = c(NA, 57)) +
  theme_minimal() +
  theme(aspect.ratio = 1)

# distributions
ggplot(SHP_income, aes(x = eq_ihtyni / 10000, weight = wh14css)) +
  geom_density(aes(color = ssep3_d)) +
  scale_colour_brewer(palette = "RdYlGn") +
  ylab("Equivalised income [in 10k CHF]") +
  xlab("Swiss-SEP3") +
  theme_minimal() 

# ggridges 
ggplot(SHP_income,
       aes(x = eq_ihtyni / 10000, 
           y = ssep3_d, 
           fill = ssep3_d)) +
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01) +
  coord_cartesian(xlim = c(NA, 30)) +
  scale_fill_brewer(palette = "RdYlGn", name = "Index decile") +
  theme_ipsum_rc() +
  ylab("Swiss-SEP index decile") + xlab("Equivalence income")

# beeswarm
ggplot(SHP_income, aes(x = ssep3_d, y = eq_ihtyni / 10000)) +
  ggbeeswarm::geom_quasirandom(alpha = 0.2) +
  stat_summary(fun = median, fun.min = median, fun.max = median, geom = "crossbar", 
               width = 0.2, size = 1.5, fatten = 1, color = "red") +
  theme_ipsum_rc() +
  xlab("Swiss-SEP index decile") + ylab("Equivalence income")

# beeswarm
ggplot(SHP_income, aes(x = ssep3_d, y = eq_ihtyni / 10000)) +
  ggbeeswarm::geom_quasirandom(alpha = 0.2) +
  stat_summary(fun = median, fun.min = median, fun.max = median, geom = "crossbar", 
               width = 0.2, size = 1.5, fatten = 1, color = "red") +
  coord_cartesian(ylim = c(NA, 57)) +
  theme_ipsum_rc() +
  xlab("Swiss-SEP index decile") + ylab("Equivalence income")
