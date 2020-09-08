library(haven)
adresses_13 <- read_sav("./Stata/orig/SHP/SHPaddresses/adresses_13.sav")
View(adresses_13)
write_dta(adresses_13, "./Stata/orig/SHP/SHPaddresses/adresses_13.dta", version = 14)
