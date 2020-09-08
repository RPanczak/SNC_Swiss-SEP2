* use $dd\SNC_SE, clear

mmerge gisid using $dd\SSEP, t(n:1) ukeep(ssep_10)
keep if _merge == 3
drop _merge

* STSETTING
stset dstop [pw=weight2012], origin(dob) entry(dstart) failure(d_all) scale(365.25)

* AGE & SEX
global SET = "nopv base cformat(%5.2f)"
stcox i.sex b10.ssep_10 , $SET
est sto s1
* ADJUSTED
global ADJ = "i.sex nat_bin b2.civil b2.urban b1.lang"
stcox $ADJ b10.ssep_10, $SET
est sto s1a
* ADJUSTED 2
global ADJ2 = "i.sex nat_bin b2.civil b2.urban b1.lang b2.educ b2.ocu"
stcox $ADJ2 b10.ssep_10, $SET
est sto s1a2

global region 	"graphregion(color(white) fc(white) margin(zero)) plotregion(fc(white) margin(vsmall)) bgcolor(white)"
global title 	"size(medsmall) color(black) margin(vsmall)"
global legend 	"legend(cols(1) ring(0) position(11) bmargin(vsmall) region(lcolor(white)))"
global lab 		"ylab(, labs(small)) xtitle("Hazard ratio", size(medsmall) margin(vsmall)) xscale(log range(0.88 1.72)) xlab(0.9(0.1)1.7)"
global misc 	"xline( 0.9(0.1)1.7, lcolor(gs14) lwidth(thin)) base ysize(3) xsize(4) msize(medium) lw(medium) grid(none)"
global groups 	"groups(*.ssep_10 = "Swiss-SEP index 2.0")"

* global drop 	"drop(*.sex nat_bin *.civil *.urban *.lang *.educ *.ocu)"
* coefplot (s1, label(Age & sex)) (s1a, label(Adjusted 1)) (s1a2, label(Adjusted 2)), title("HRs of all cause mortality", $title) eform $drop $lab $region $misc $legend $groups

global drop 	"drop(*.sex nat_bin *.civil *.urban *.lang)"
coefplot (s1, label(Age & sex)) (s1a, label(Adjusted 1)) , title("HRs of all cause mortality", $title) eform $drop $lab $region $misc $legend $groups

gr export $td/gr/d_al_adj2.pdf, replace

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{All cause mortality - 2.0}
\begin{center}
\includegraphics[width=.75\textwidth]{gr/d_al_adj2.pdf} 
\end{center}

Note: See notes from previous section. 
'Adjusted 2' - additionally adjusted for education and occupation.
***/

texdoc s , nolog // nodo   

global SET = "nopv base cformat(%5.2f)"
global ADJ = "nat_bin b2.civil b2.urban b1.lang"
global ADJ2 = "i.sex nat_bin b2.civil b2.urban b1.lang b2.educ b2.ocu"

foreach EVENT in d_lc d_bc d_pc d_re d_cv d_mi d_st d_ac d_su {


	di in red "*************************************************"
	di in red "Event: `EVENT'" 

	stset dstop, origin(dob) entry(dstart) failure(`EVENT') scale(365.25)
	
	* LADIES 
	if "`EVENT'" == "d_bc" {
		
		stcox b10.ssep_10 if sex, $SET 
		est sto `EVENT'
		stcox $ADJ b10.ssep_10 if sex, $SET
		est sto `EVENT'_a	
		stcox $ADJ2 b10.ssep_10 if sex, $SET
		est sto `EVENT'_a2		
	}
	
	* GENTS
	else if "`EVENT'" == "d_pc" {

		stcox b10.ssep_10 if !sex, $SET
		est sto `EVENT'
		stcox $ADJ b10.ssep_10 if !sex, $SET
		est sto `EVENT'_a
		stcox $ADJ2 b10.ssep_10 if !sex, $SET
		est sto `EVENT'_a2		
	}	

	else {
	
		stcox i.sex b10.ssep_10, $SET
		est sto `EVENT'
		stcox i.sex $ADJ b10.ssep_10, $SET
		est sto `EVENT'_a
		stcox i.sex $ADJ2 b10.ssep_10, $SET
		est sto `EVENT'_a2		
	}	
}
