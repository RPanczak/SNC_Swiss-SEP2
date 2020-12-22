qui do H:\RP\projects\sep2\Stata\do\00_run_first.do

forv PART = 1/6 {
	import delim using "$od\neighb_snc\SNC_101_neighb_20km_`PART'.txt", varn(1) clear 
	drop objectid originid destinationid shape_length

	gen gisid_orig = word(name, 1)
	destring gisid_orig, replace

	gen gisid_dest = word(name, 3)
	destring gisid_dest, replace

	drop name 

	gen part = `PART' 
	order part gisid_orig gisid_dest, first 
	
	replace total_length = round(total_length)
	
	drop if destinationrank > 50

	sort gisid_orig destinationrank
	by gisid_orig: egen b_maxdest = max(destinationrank)
	by gisid_orig: egen b_totdist = total(total_length)
	format %10.0fc total_length b_totdist
	compress
	
	if `PART' == 1 {
		save $dd\NEIGHB_SNC, replace
	}
	else {
		append using $dd\NEIGHB_SNC
		save $dd\NEIGHB_SNC, replace
	}

}

keep if b_maxdest < 50
sort gisid_orig destinationrank
by gisid_orig: keep if _n == 1

mmerge gisid_orig using $dd\ORIGINS, umatch(gisid) t(1:n)
assert _merge != 1
keep if _merge == 3
drop _merge

bysort gisid_orig: keep if _n == 1
drop hec dupli year gisid_dest destinationrank total_length

* save $dd\NEIGHB_SNC_ERROR, replace
* export delim using "$gis\data\NEIGHB_SNC_ERROR.csv", delim(",")  replace

/*
legitimate no neighb

644959 - on the highway
1182865 - on the island

two more errors on road network :/
191628
209805


