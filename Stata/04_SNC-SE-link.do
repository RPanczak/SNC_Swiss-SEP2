* ******************************************
* 02.do
* ******************************************

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Dataset - SNC SE}

Secondly, only individuals who participated in one of the SE surveys (2012-15) will be used in order to develop 'fully adjusted' model 
taking into account additionally education and occupation (note the details provided in the SE section!).

***/

texdoc s , nolog // nodo   

u "data/SNC_ALL", clear
drop recid yod m_civil geox geoy year dupli hec

* LIMIT TO SE DATA
mmerge sncid using "data/SE", t(1:1) ukeep(educ_agg educ_curr occup_isco den_ocu? SE)
/*
ta _merge se11_flag, m 
ta _merge se12_flag, m 
ta _merge se13_flag, m 
ta _merge se14_flag, m 
ta _merge se15_flag, m 
ta _merge se16_flag, m 
ta _merge SE, m 
*/
keep if _merge == 3
drop _merge 

* EDUCATION >> USE CURRENT IF HIGHER
gen educ = educ_agg
replace educ = educ_curr if educ_curr > educ_agg
la val educ educ_agg_enl
drop educ_*

gen ocu = .
replace ocu = 1 if inrange(occup_isco, 1000, 2999)
replace ocu = 2 if inrange(occup_isco, 3000, 5999)
replace ocu = 3 if inrange(occup_isco, 6000, 9999)
replace ocu = 1 if inrange(occup_isco, 100, 110)
replace ocu = 2 if inrange(occup_isco, 200, 210)
replace ocu = 3 if inrange(occup_isco, 300, 310)
replace ocu = 5 if mi(occup_isco)
replace ocu = 4 if den_ocu1 == 0 
drop occup_isco den_ocu?

la de ocu 1 "High occup" 2 "Medium occup" 3 "Low occup " 4 "Not in paid employ" 5 "Missing", modify 

* UPDATE TO LATEST SURVEY ???
replace dstart = mdy(1, 1, SE) if dstart < mdy(1, 1, SE)

la da "SSEP 2.0 - SNC 2012-2015 data for mortality analyses - SE overlap"

note: 			Including people from SE used to calculate index
note: 			Last changes: $S_DATE $S_TIME
compress
sa "data/SNC_SE", replace

texdoc s c 


texdoc s , cmdstrip

u "data/SNC_SE", clear

ta SE, m 
* tabstat d_*, statistics( sum ) labelwidth(8) varwidth(18) columns(statistics) longstub format(%9.0fc)

texdoc s c 




* ******************************************
* 03.do
* ******************************************

/***
Note for both tables: HRs for the 10th (lowest SEP) decile compared to 1st (highest SEP). 
Breast and prostate cancer: for men and women respectively. 

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Validation - SNC SE mortality}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{All cause mortality - 3.0}
***/

texdoc s , nolog // nodo   

u "data/SNC_SE", clear

* bring sep 2
mmerge buildid using "FINAL/DTA/ssep3_user_snc", t(n:1) ukeep(ssep2_d)
* distinct buildid if _merge == 1
* list buildid if _merge == 1
keep if _merge == 3
drop _merge

* bring sep 1 >> spatial join done in 02_sep-diff.Rmd
mmerge gisid using "data/Swiss-SEP2/sep2_sep1_join.dta", t(n:1) ukeep(ssep1_d)
assert _merge != 1
keep if _merge == 3
drop _merge

la var ssep1_d ""
la var ssep2_d ""

* bring sep 3
mmerge buildid using "$co/data-raw/statpop/r18_bu_orig", umatch(r18_egid) ukeep(r18_buildper)
keep if _merge == 3
drop _merge

rename r18_buildper buildper

gen buildper2 = (buildper >= 8020)
* ta buildper buildper2, m

la de buildper2 0 "Before 2000" 1 "After 2000", replace

gen ssep3_d = ssep1_d
replace ssep3_d = ssep2_d if buildper2

* STSETTING
est clear
stset dstop, origin(dob) entry(dstart) failure(d_all) scale(365.25)

* AGE & SEX
global SET = "nopv base cformat(%5.2f)"
stcox i.sex b10.ssep3_d, $SET
est sto s1
* ADJUSTED
global ADJ = "i.sex nat_bin b2.civil b2.urban b1.lang"
stcox $ADJ b10.ssep3_d, $SET
est sto s1a
* ADJUSTED 2
global ADJ2 = "i.sex nat_bin b2.civil b2.urban b1.lang b2.educ b2.ocu"
stcox $ADJ2 b10.ssep3_d, $SET
est sto s1a2

global region 	"graphregion(color(white) fc(white) margin(zero)) plotregion(fc(white) margin(vsmall)) bgcolor(white)"
global title 	"size(medsmall) color(black) margin(vsmall)"
global legend 	"legend(cols(1) ring(0) position(11) bmargin(vsmall) region(lcolor(white)))"
global lab 		"ylab(, labs(small)) xtitle("Hazard ratio", size(medsmall) margin(vsmall)) xscale(log range(0.85 1.62)) xlab(0.9(0.1)1.5)"
global misc 	"xline( 0.9(0.1)1.5, lcolor(gs14) lwidth(thin)) base ysize(3) xsize(4) msize(medium) lw(medium) grid(none)"
global groups 	"groups(*.ssep2_d = "Swiss-SEP index 2.0")"
global drop 	"drop(*.sex nat_bin *.civil *.urban *.lang *.educ *.ocu)"

coefplot (s1, label(Age & sex)) (s1a, label(Adjusted 1))  (s1a2, label(Adjusted 2)), title("HRs of all cause mortality", $title) eform $drop $lab $region $misc $legend $groups

gr export $td/gr/d_al_adj3.pdf, replace

texdoc s c 

/***
\begin{center}
\includegraphics[width=.75\textwidth]{gr/d_al_adj3.pdf} 
\end{center}

Note: See notes from previous section. 
'Adjusted 2' - additionally adjusted for education and occupation.

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Cause specific mortality - 3.0}
***/

texdoc s , nolog // nodo   

global SET = "nopv base cformat(%5.2f)"
global ADJ = "nat_bin b2.civil b2.urban b1.lang"
global ADJ2 = "i.sex nat_bin b2.civil b2.urban b1.lang b2.educ b2.ocu"

est clear

foreach EVENT in d_lc d_bc d_pc d_re d_cv d_mi d_st d_ac d_su {

	di in red "*************************************************"
	di in red "Event: `EVENT'" 

	stset dstop, origin(dob) entry(dstart) failure(`EVENT') scale(365.25)
	
	* LADIES 
	if "`EVENT'" == "d_bc" {
		
		stcox b10.ssep3_d if sex, $SET 
		est sto `EVENT'
		stcox $ADJ b10.ssep3_d if sex, $SET
		est sto `EVENT'_a	
		stcox $ADJ2 b10.ssep3_d if sex, $SET
		est sto `EVENT'_a2		
	}
	
	* GENTS
	else if "`EVENT'" == "d_pc" {

		stcox b10.ssep3_d if !sex, $SET
		est sto `EVENT'
		stcox $ADJ b10.ssep3_d if !sex, $SET
		est sto `EVENT'_a
		stcox $ADJ2 b10.ssep3_d if !sex, $SET
		est sto `EVENT'_a2		
	}	

	else {
	
		stcox i.sex b10.ssep3_d, $SET
		est sto `EVENT'
		stcox i.sex $ADJ b10.ssep3_d, $SET
		est sto `EVENT'_a
		stcox i.sex $ADJ2 b10.ssep3_d, $SET
		est sto `EVENT'_a2		
	}	
}

texdoc s c 

* VERY CRUDE WAY OR 'PRINTING' TABLE >> CAN BE TURNED INTO LATEX OUTPUT WITH BIT MORE WORK
texdoc s , cmdstrip

estout d_lc d_lc_a d_lc_a2, varl(1.ssep3_d "Lung cancer") 			c( "b(fmt(2) label(HR) ) ci(par( ( ,  ) ) label(95% CI) )" ) keep(1.ssep3_d) eform  mlabels("Age & sex" "Adjusted 1" "Adjusted 2")
estout d_bc d_bc_a d_bc_a2, varl(1.ssep3_d "Breast cancer")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)
estout d_pc d_pc_a d_pc_a2, varl(1.ssep3_d "Prostate cancer")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)

estout d_cv d_cv_a d_cv_a2, varl(1.ssep3_d "Cardiovascular")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)
estout d_mi d_mi_a d_mi_a2, varl(1.ssep3_d "Myocardial infarction")	c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)
estout d_mi d_st_a d_st_a2, varl(1.ssep3_d "Stroke")				c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)
 
estout d_re d_re_a d_re_a2, varl(1.ssep3_d "Respiratory")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)

estout d_ac d_ac_a d_ac_a2, varl(1.ssep3_d "Traffic accidents")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)
estout d_su d_su_a d_su_a2, varl(1.ssep3_d "Suicide")				c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)

texdoc s c 

/***
Note: results of traffic accidents have small number of events resulting in large CI (n=91)
***/
