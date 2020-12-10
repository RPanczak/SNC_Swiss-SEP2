* ===================================================
* CHECKING HRs OF INDIVIDUAL COMPONENTS OF THE INDEX

u $dd\FINAL\DTA\ssep2_user, clear
keep gisid ocu1p ocu2p ocu3p ocu4p edu1p ppr1 rent

foreach var of varlist ocu1p ocu2p ocu3p ocu4p edu1p ppr1 rent {

	xtile `var'_d = `var', nq(10)
	drop `var'

}

mmerge gisid using $dd\SNC_ALL, t(1:n) 
keep if _merge == 3
drop _merge

global SET = "nopv base cf(%5.2f)"
stset dstop, origin(dob) entry(dstart) failure(d_all) scale(365.25)


foreach var of varlist ocu1p ocu2p ocu3p ocu4p edu1p ppr1 rent {

	di in red "******************************"
	di in red "Variable is `var'"
	stcox i.sex b10.`var', $SET

}
