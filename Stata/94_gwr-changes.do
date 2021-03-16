u "data/gwr_extract_210225/gwr_extract_210225", clear
ta gkat, m
ta gklas, m
ta gbaup, m

gen excluded = (inrange(gklas, 1130, 1278)) 
ta excluded, m

* **************************************
* BUILDING TYPE

u "data/ORIGINS", clear

mmerge buildid using "data/gwr_extract_210225/gwr_extract_210225", t(1:1) umatch(egid) // ukeep(gklas gbaup buildper)

drop if _merge == 2

* funky or unlinked buildings
ta gklas _merge, m
ta gklas if _merge == 3, m

gen new_class = (inrange(gklas, 1130, 1278))

ta new_class _merge, m
ta new_class if _merge == 3, m

keep if new_class == 1 & _merge == 3
drop _merge 

sa "data/gwr_extract_210225/gwr_class_change", replace

u "data/SE", clear

sort buildid, stable
by buildid: gen pops = _N
by buildid: keep if _n == 1

mmerge buildid using "data/gwr_extract_210225/gwr_extract_210225", t(1:1) umatch(egid) // ukeep(gklas gbaup buildper)

drop if _merge == 2

* funky or unlinked buildings
ta gklas _merge, m
ta gklas if _merge == 3, m

gen new_class = (inrange(gklas, 1130, 1278))

ta new_class _merge, m
ta new_class if _merge == 3, m

keep if new_class == 1 & _merge == 3
drop _merge 

* sa "data/gwr_extract_210225/...", replace

* **************************************
* COORDS

u "data/ORIGINS", clear

mmerge buildid using "data/gwr_extract_210225/gwr_extract_210225", t(1:1) umatch(egid) ukeep(gklas geox_new geoy_new)

keep if _merge == 3
drop _merge

gen geodiff = geox - geox_new
su geodiff, d
sort geodiff

* **************************************
* BUILDING PERIOD 
u "data/ORIGINS", clear

* getting age of the buildings
mmerge buildid using "$co/data-raw/statpop/r18_bu_orig", t(1:1) umatch(r18_egid) ukeep(r18_buildper)
keep if _merge == 3
drop _merge

gen buildper_orig = (r18_buildper >= 8020 & !mi(r18_buildper))
* ta buildper_orig, m

mmerge buildid using "data/gwr_extract_210225/gwr_extract_210225", t(1:1) umatch(egid) ukeep(gklas gbaup buildper)
keep if _merge == 3
drop _merge

ren buildper buildper_upda

ta buildper_orig buildper_upda, m

