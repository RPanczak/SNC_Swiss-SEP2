use "$od\snc2_std_pers_90_00_14_all_207_full", clear 
keep if se12_flag == 1 

mmerge sncid using $od\SE\SE12_pers_full, t(1:1) ukeep(weight2012)
* tab _merge se12_flag, m 
assert _merge == 3
drop _merge

* VARS NOT NEEDED
drop v9* v0* *_geox *_geoy *_flatid *_hhid shs92 *_hhpers *_dch_arriv *_permit *_nat *_dseparation *_dcivil *_ddiv_dod_p *_dmar *_civil_old *_canton dswiss zarflag zar natbirth *_comm2006 *_comm *_dmove *_canton2006 *_lang2006 *_urban2006 dis_conc1_icd8* dis_conc2_icd8* dis_init_icd8* dis_init_icd10* dis_cons_icd10* dis_conc1_icd10* dis_conc2_icd10*  *_mo_flag
drop r10_* se10_flag r11_commyears r11_commsincebirth m_nat_bin

* NO IMPUTED FOR THE MOMENT 
drop imputed *_imputed 

drop r11_* r13_* r14_* se11_flag se13_flag se12_flag

* DOD DISCREPANCIES ???
su dod, f d 
drop if dod <= mdy(12, 31, 2011) & !cancelled_death

* AGE ON 1.1.2012; KEEP ONLY 30YEARS AND OLDER
gen age = (mdy(1, 1, 2012) - dob ) / 365.25
* su age
* su dob if age < 0, f 
drop if age < 30 

* FIXING `dstart' VARIABLE >> CANNOT BE LOWER THAN 1.1.2012
replace dstart = mdy(1, 1, 2012) if dstart < mdy(1, 1, 2012)

* UPDATE TO LATES AVAILABLE INFORMATION
foreach VAR in nat_bin urban lang civil buildid {

	ren r12_`VAR' `VAR'
}

* RHAETO-ROMANSCH 
recode lang (4=1)

* MISSING CIVIL
drop if mi(civil)

* EXCLUDE THOSE FROM BUILDINGS WITHOUT SEP
mmerge buildid using $dd\ORIGINS, t(n:1)
keep if _merge == 3
drop _merge 

* ALL DEATHS >> LATER CASUE SPECIFIC WILL BE ADDED
gen d_all = (inlist(stopcode, 5, 15))

* LUNG CANCER 
gen d_lc = ( d_all & (cause_prim_icd10s=="C" & (cause_prim_icd10n2d>=33 & cause_prim_icd10n2d<=34)) )

* BREAST CANCER
gen d_bc = ( d_all & (cause_prim_icd10s=="C" & cause_prim_icd10n2d==50) )

* PROSTATE CANCER
gen d_pc = ( d_all & (cause_prim_icd10s=="C" & cause_prim_icd10n2d==61) )

* RESPIRATORY
gen d_re = ( d_all & (cause_prim_icd10s=="J") )

* CVD
gen d_cv = ( d_all & (cause_prim_icd10s=="I") )

* MYOCARDIAL INFARCTION
gen d_mi = ( d_all & (cause_prim_icd10s=="I" & (cause_prim_icd10n2d>=21 & cause_prim_icd10n2d<=22)) )

* STROKE
gen d_st = ( d_all & (cause_prim_icd10s=="I" & (cause_prim_icd10n2d>=60 & cause_prim_icd10n2d<=64)) )

* ACCIDENTS TRAFFIC
gen d_ac = ( d_all & (cause_prim_icd10s=="V" & (cause_prim_icd10n2d>=1 & cause_prim_icd10n2d<=99)) )

* ALC LIVER DISEASE
gen d_al = ( d_all & (cause_prim_icd10s=="K" & cause_prim_icd10n2d==70) )

* SUICIDE
gen d_su = ( d_all & (cause_prim_icd10s=="X" & (cause_prim_icd10n2d>=60 & cause_prim_icd10n2d<=84)) )

la var d_all "All deaths"
la var d_lc  "Lung cancer"
la var d_bc  "Breast cancer"
la var d_pc  "Prostate cancer"
la var d_re  "Respiratory"
la var d_cv  "CVD"
la var d_mi  "MI"
la var d_st  "Stroke"
la var d_ac  "Traffic accidents"
la var d_al  "Alc liver disease"
la var d_su  "Suicide"

/*
note drop _all
la da "SSEP 2.0 - full SNC 2012-2014 data for mortality analyses"

note: 			SNC: people 30 and over; linked to building with index; covariates calculated using latest available info.
note civil: 	Missing data excluded
note lang: 		Rhaeto-romansch to German langreg 
note: 			Last changes: $S_DATE $S_TIME
compress
save $dd\SNC_ALL, replace
*/
