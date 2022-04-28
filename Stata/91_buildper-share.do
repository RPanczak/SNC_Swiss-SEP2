/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Finding n'hoods with new buildings}
***/

texdoc s , nolog nodo   

u "data/NEIGHB", clear
drop part total_length b_*

* getting buildid back
mmerge gisid_orig using "data/ORIGINS", t(n:n) um(gisid) uk(buildid)
drop if _merge == 2
drop _merge
ren buildid buildid_orig

* getting age of the buildings
mmerge buildid_orig using "$co/data-raw/statpop/r18_bu_orig", t(n:1) um(r18_egid) uk(r18_buildper)
* distinct buildid_orig if _merge == 1 
drop if _merge == 2
drop _merge

gen buildper_orig = (r18_buildper >= 8020 & !mi(r18_buildper))
drop r18_buildper
* ta buildper_orig, m

* same procedure on dest side
mmerge gisid_dest using "data/ORIGINS", t(n:n) um(gisid) uk(buildid)
* distinct buildid_orig if _merge == 1 
drop if _merge == 2
drop _merge
ren buildid buildid_dest

mmerge buildid_dest using "$co/data-raw/statpop/r18_bu_orig", t(n:1) um(r18_egid) uk(r18_buildper)
drop if _merge == 2
drop _merge

gen buildper_dest = (r18_buildper >= 8020 & !mi(r18_buildper))
drop r18_buildper
* ta buildper_dest, m

sort gisid_orig destinationrank, stable
by gisid_orig: egen temp1 = max(buildper_orig)
by gisid_orig: egen temp2 = total(buildper_dest)
by gisid_orig: gen buildper_num = temp1 + temp2
by gisid_orig: gen buildper_den = _N + 1
by gisid_orig: keep if _n == 1
drop gisid_dest destinationrank buildid_orig buildper_orig buildid_dest buildper_dest temp1 temp2
gen buildper_share = buildper_num / buildper_den
univar buildper_share

hist buildper_share, width(0.05) start(0) percent

keep gisid_orig buildper_share
ren gisid_orig  gisid

egen buildper_cat = cut(buildper_share), at(0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 1.1) icodes

replace buildper_cat = buildper_cat + 1
replace buildper_cat = 0 if buildper_share == 0

fre buildper_cat

compress
sa "data/buildper_share", replace

/*
br if gisid_orig == 78091
br if gisid_orig == 78230
*/

texdoc s c




/*
* experimental index replacement depending on share of new buildings

mmerge gisid using data/buildper_share, t(n:1) uk(buildper_cat)
drop if _merge == 2
drop _merge

forv buildper = 1(1)6 {
	gen ssep3_d_`buildper' = ssep1_d
	replace ssep3_d_`buildper' = ssep2_d if buildper_cat >= `buildper'
}
*/