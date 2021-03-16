qui do C:/projects/SNC_Swiss-SEP2/Stata/00_run_first.do

qui version 15

u "data-raw/buclassfloor/gwrgws_buclassfloor", clear

mdesc egid ewid
sort egid ewid, stable
/*
by egid: egen t1 = min(bu_class)
by egid: egen t2 = max(bu_class)
count if t1 != t2
drop t?
*/
by egid: keep if _n == 1
drop ewid

mdesc bu_class
drop if mi(bu_class)

sa "data/buclassfloor/gwrgws_buclassfloor_included", replace

u "data-raw/gwr_extract_210225/gwr_extract_210225", clear
isid egid_snc
rename egid_snc egid

mdesc gklas
drop if mi(gklas)

mmerge egid using "data/buclassfloor/gwrgws_buclassfloor_included", t(1:1)

keep if _merge == 3

gen byte other = .

replace other = 1 if inrange(gklas, 1130, 1278) & inrange(bu_class, 1130, 1278) 

replace other = 2 if !inrange(gklas, 1130, 1278) & inrange(bu_class, 1130, 1278) 

replace other = 3 if inrange(gklas, 1130, 1278) & !inrange(bu_class, 1130, 1278) 

la de other ///
	1 "other in both files" ///
	2 "other in old file only" ///
	3 "other in new file only", replace
la val other other 

ta other, m
ta other

/* CHECKING AGAINST FULL SNC WITH 2014 AS TEST
u r14_pe_flag r14_buildid v0_hhtyp3 using "$co/data-raw/SNC/snc2_std_pers_90_00_14_all_207_full.dta", clear 

keep if r14_pe_flag == 1

mmerge r14_buildid using "data/gwr_extract_210225/gwr_extract_210225", t(n:1) umatch(egid)

ta gklas, m 
ta gklas if _merge == 3, m 

keep if _merge == 3

ta v0_hhtyp3 if inrange(gklas, 1130, 1278) 
ta v0_hhtyp3 if !inrange(gklas, 1130, 1278) 