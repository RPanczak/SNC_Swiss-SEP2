qui do "C:/projects/SNC_Swiss-SEP2/Stata/00_run_first.do"

qui version 15

u "data-raw/buclassfloor/gwrgws_buclassfloor.dta", clear
count
ta bu_class, m

ta floor, m

la var egid "Orig. building ID"
la var ewid "Orig. dwelling ID"
ren floor org_floor
ren bu_class org_bu_class
la var org_floor "Orig. cat. floor of dwelling"
la var org_bu_class "Orig. building class"

count if mi(org_bu_class)

g byte bu_resid = inrange(org_bu_class, 1110, 1130)
replace bu_resid = 9 if mi(org_bu_class)
ta bu_resid, m

la var bu_resid "Residential building"
la de resid_l 0 "Non-residential" 1 "Residential" 9 "Temporary housing/no information"
la val bu_resid resid_l
ta org_bu_class bu_resid, m

g byte homeinst = .
replace homeinst = 0 if inrange(org_bu_class, 1110, 1122)
replace homeinst = 1 if inrange(org_bu_class, 1130, 1274)
replace homeinst = 9 if mi(org_bu_class)
assert mi(homeinst) == mi(bu_resid)

la var homeinst "Flag home/institution"
la de homeinst_l 0 "Private household" 1 "Home/institution/non-residential bu." 9 "Temporary housing/no information"
la val homeinst homeinst_l
count if mi(org_floor)  // 8285

ta org_floor, m
/*
Parterre inkl. Hochparterre 3100
1. – 49. Stock (Maximum) 3101 – 3149
1. – 9. Untergeschoss (Maximum) 3201 – 3209
Maisonnette, Parterre mehrgeschossig 3300
Maisonnette, 1 - 49. Stock (Max.) mehrgeschossig 3301 – 3349

->

-1..-9 Basement
0	(Raised) ground floor
1-49	Floor number
100  Maisonette (> 1 floor)  (entrance ground floor)
101-149 Maisonette (>1 floor), floor number of entrance
999	Temporary housing, collective household, no information, missing ewid
*/

gen floor = org_floor
replace floor = floor-3100 if inrange(org_floor, 3101, 3149)
replace floor = 0 if org_floor == 3100
replace floor = 100 if org_floor == 3300
replace floor = floor-3200 if inrange(org_floor, 3301, 3349)
replace floor = -(floor-3200) if inrange(org_floor, 3201, 3209)
tabstat floor,stats(min max) by(org_floor)
replace floor = 999 if mi(org_floor)

la de floor_l 0 "0 - (Raised) ground floor" 999 "999 - Temporary housing/no information/missing EWID" ///
	100 "100 - Maisonette (>1 floor), ground floor entrance" ///
	101 "101 - Maisonette, 1st floor entrance" 102 "102 - Maisonette, 2nd floor entrance" ///
	103 "103 - Maisonette, 3rd floor entrance" ///
	1 "1 - 1st floor" 2 "2 - 2nd floor" 3 "3 - 3rd floor" -1 "-1 - 1st basement" -2 "-2 - 2nd basement" ///
	-3 "-3 - 3rd basement" 
forval f = -4(-1)-9 {
	local r = -`f'
	la de floor_l `f' "`f' - `r'th basement",add 
}
forval f = 4/49 {
	la de floor_l `f' "`f' - `f'th floor",add 
}
forval f = 104/149 {
	local e = `f' - 100
	la de floor_l `f' "`f' - Maisonette, `e'th floor entrance",add 
}

la val floor floor_l
la var floor "Floor of dwelling"

count if mi(ewid)
count if mi(egid)

preserve 
	keep if !mi(egid) & !mi(ewid)
	isid egid ewid 
restore

la de bu_class_l ///
	1110 "1110 - Building with 1 flat" ///
	1121 "1121 - Building with 2 flats" ///
	1122 "1122 - Building with >=3 flats" ///	
	1130 "1130 - Communities, home for the aged, homeless home, orphanage, dormitory" ///
	1211 "1211 - Hotel, motel" ///
	1212 "1212 - Short-term dwelling, youth hostel, holiday camp" ///
	1220 "1220 - Office building" ///
	1230 "1230 - Wholesale, retail, shopping malls, petrol station" ///
	1241 "1241 - Railway station, airport" ///
	1242 "1242 - Parking ramp, parking garage" ///
	1251 "1251 - Factory, industrial building" ///
	1252 "1252 - Storage building, warehouse, silo" ///
	1261 "1261 - Cinema, theatre, concert hall, assembly hall" ///
	1262 "1262 - Museum, library" ///
	1263 "1263 - School building, college, university" ///
	1264 "1264 - Hospital, nursing home, institution for diseabled people" ///
	1265 "1265 - Sports hall, gym, tennis court" ///
	1271 "1271 - Farm, agricultural building, greenhouse" ///
	1272 "1272 - Church, chapel, morgue" ///
	1273 "1273 - Monument, memorial" ///
	1274 "1274 - Prison, barrack, bus stop, public restroom"
la val org_bu_class bu_class_l

compress
order egid ewid floor bu_resid homeinst org_floor org_bu_class
sort egid ewid

sa "data/buclassfloor/gwrgws_buclassfloor_prep.dta", replace

