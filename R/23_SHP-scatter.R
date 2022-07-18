library(pacman)
p_load(tidyverse, haven)


SHP_income <- read_dta("data/SHP_income.dta") %>%
  zap_label() %>%
  zap_labels()

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

