* ***************************************************
/*
  ___ ___ ___ ___   __  
 / __| __| _ \_  ) /  \ 
 \__ \ _||  _// / | () |
 |___/___|_| /___(_)__/ 

Data analysis file

*/

* ***************************************************

qui do C:\projects\SNC_Swiss-SEP2\Stata\00_run_first.do

qui version 15

texdoc init $td\report_sep2_analysis.tex, replace logdir(log) grdir(gr) prefix("ol_") cmdstrip lbstrip gtstrip linesize(120)
	
clear

/***
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REPORT FOR SWISS-SEP 2.0 DATA ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LATEX settings
\documentclass[a4paper, notitlepage, fleqn]{article} % USE titlepage IF YOU WANT TOC TO APPEAR ON NEXT PAGE
\usepackage[a4paper]{geometry}
\usepackage{stata} 

\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
 
\usepackage{fullpage} % SMALL MARGINS
% \usepackage[cm]{fullpage} % VERY SMALL MARGINS
 
\usepackage{lscape} % BETTER FOR PRINTING, PAGE DISPLAYED VERTICALLY
% \usepackage{pdflscape} % BETTER FOR SCREEN, PAGE DISPLAYED HORIZONTALLY
 
\usepackage{mathtools, amssymb, bookmark, framed, longtable, booktabs, graphicx, url, multirow, cancel}
 
\usepackage{hyperref}
\hypersetup{unicode=true, pdfborder = {0 0 0}, colorlinks, citecolor=blue, filecolor=black, linkcolor=blue, urlcolor=blue, pdftitle={Swiss-SEP 2.0 data management}, pdfauthor={Radoslaw Panczak}}

\renewcommand{\familydefault}{\sfdefault}
\usepackage[usenames, dvipsnames]{color}
\usepackage[table]{xcolor}
\usepackage[normalem]{ulem}

\usepackage[hang,flushmargin]{footmisc} 

% to avoid error http://tex.stackexchange.com/questions/165929/semiverbatim-with-tikz-in-beamer
\makeatletter
\global\let\tikz@ensure@dollar@catcode=\relax
\makeatother

\setlength{\parindent}{0pt} % no indent for ne paras
\graphicspath{ {d:/Data_RP/data/projects/EOLC/stata/graphres/} }
\setcounter{tocdepth}{2}

\usepackage{array}
\newcolumntype{L}[1]{>{\raggedright\let\newline\\\arraybackslash\hspace{0pt}}m{#1}}

% \linespread{1.3}
%
% \usepackage{setspace}
% \singlespacing
% \onehalfspacing
% \doublespacing

\usepackage{multirow}

% https://tex.stackexchange.com/questions/52317/pdftex-warning-version-allowed
\pdfminorversion=6

\title{\textbf{Swiss-SEP 2.0 index \endgraf 
Report 1.08 - data analysis}}

\author{Radoslaw Panczak \textit{et al.}}

\begin{document}

\maketitle
\tableofcontents

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \newpage
% \section{Finding n'hoods with new buildings}
***/

texdoc s , nolog nodo   

u "data/NEIGHB", clear
drop part total_length b_*

* getting buildid back
mmerge gisid_orig using "data/ORIGINS", t(n:n) umatch(gisid) ukeep(buildid)
drop if _merge == 2
drop _merge
ren buildid buildid_orig

* getting age of the buildings
mmerge buildid_orig using "data-raw/statpop/r18_bu_orig", t(n:1) umatch(r18_egid) ukeep(r18_buildper)
drop if _merge == 2
drop _merge

gen buildper_orig = (r18_buildper >= 8020)
drop r18_buildper
* ta buildper_orig, m

* same procedure on dest side
mmerge gisid_dest using "data/ORIGINS", t(n:n) umatch(gisid) ukeep(buildid)
drop if _merge == 2
drop _merge
ren buildid buildid_dest

mmerge buildid_dest using "data-raw/statpop/r18_bu_orig", t(n:1) umatch(r18_egid) ukeep(r18_buildper)
drop if _merge == 2
drop _merge

gen buildper_dest = (r18_buildper >= 8020)
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
save data/buildper_share, replace

/*
br if gisid_orig == 78091
br if gisid_orig == 78230
*/

texdoc s c


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{PCA on n'hood aghgregated characteristics}
***/

texdoc s , nolog // nodo   

u "data\NEIGHB_PREP_AGG", clear

mmerge gisid_orig using "data\NEIGHB_RENT_PREP_AGG", t(1:1)
assert _merge == 3
drop _merge 

texdoc s c 

* INDEX AS PCA >> USING BROADEST VERSION OF 'LOW' OCCUPATIONS
texdoc s  // , nodo   

pca  ocu1p edu1p ppr1 rent [aw = tot_hh]

predict i_hw

/* DIAGNOSTICS
estat kmo 
estat residual, fit f(%7.3f)
estat smc
estat anti, nocov f(%7.3f)
* screeplot, mean ci
*/

* 0-100 score
* based on p.6 http://www.geosoft.com/media/uploads/resources/technical-notes/Principal%20Component%20Analysis.pdf
egen A = min(i_hw)
egen B = max(i_hw)
gen ind = (i_hw-A)*100/(B-A)
gen ssep2 = (ind - 100)*(-1)

xtile ssep2_t  = ssep2, nq(3)
xtile ssep2_q  = ssep2, nq(5)
xtile ssep2_d  = ssep2, nq(10)

drop  i_hw ind A B

/* PCA >> USING DIFFERENT OCCUP DENOMINATOR >> FOR SENSITIVITY ANALYSIS

pca  ocu1p2 edu1p ppr1 rent [aw = tot_hh]

predict i_hw

/* DIAGNOSTICS
estat kmo 
estat residual, fit f(%7.3f)
estat smc
estat anti, nocov f(%7.3f)
* screeplot, mean ci
*/

* 0-100 score
* based on p.6 http://www.geosoft.com/media/uploads/resources/technical-notes/Principal%20Component%20Analysis.pdf
egen A = min(i_hw)
egen B = max(i_hw)
gen ind = (i_hw-A)*100/(B-A)
gen ssepALT = (ind - 100)*(-1)

*xtile ssepALT_t = ssepALT, nq(3)
*xtile ssepALT_q = ssepALT, nq(5)
xtile ssepALT_d = ssepALT, nq(10)

drop  i_hw ind A B

la de ssepALT_d 1 "1 (lowest SEP)" 2 "2" 3 "3" 4 "4" 5 "5th decile" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10 (highest SEP)", modify 
la val ssepALT_d ssep2_10

gen occup_diff = ssep2 - ssepALT
* univar occup_diff
* hist occup_diff, w(0.25) start(-10) percent

ta ssep2_d ssepALT_d , m

* https://www.stata.com/meeting/uk19/slides/uk19_newson.pdf
somersd ssep ssepALT, taua transf(z) tdist
scsomersd difference 0, transf(z) tdist

* baplot ssep ssepALT, info

* batplot ssep ssepALT, info
batplot ssep ssepALT, notrend info dp(0)
gr export $td\gr\BA_occu.png, replace width(800) height(600)
*/

* BRING COORDINATES
* ACHTUNG THAT WILL MAKE MORE BUILDINGS and gisid IS NOT LONGER UNIQUE 
ren gisid_orig gisid
mmerge gisid using "data/ORIGINS", t(1:n) ukeep(buildid geox geoy)
keep if _merge==3
drop _merge
order gisid buildid geox geoy, first 

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Hybrid version of SEP}

This solution is mixing versions 1.0 \& 2.0. First the new buildings have value of index 1.0 assigned using the closest (linear dstance) neighbour. 

Then, construction period of the building is retrived sfrom \texttt{STATPOP 2018} dataset and then buildings build before year 2000 have the values of 1.0 index assigned and buildings constructed after 2000 have new values assigned. Buildings without the defined period of construction keep values 1.0 also. 
***/

texdoc s , nolog // nodo   

* bring sep 1 >> spatial join done in 04_sep-diff.Rmd
mmerge gisid using "data/Swiss-SEP2/sep2_sep1_join.dta", t(n:1) ukeep(ssep1 ssep1_t ssep1_q ssep1_d)
assert _merge == 3
drop _merge

* getting age of the buildings
mmerge buildid using "data-raw/statpop/r18_bu_orig", umatch(r18_egid) ukeep(r18_buildper)

/*
* eda of unlinked
* br if _merge == 1 

gen miss_age = (_merge == 1)

tabstat ocu1p, s(mean median) by(miss_age) f(%9.6fc)
tabstat edu1p, s(mean median) by(miss_age) f(%9.6fc)
tabstat ppr1,  s(mean median) by(miss_age) f(%9.6fc)
tabstat rent,  s(mean median) by(miss_age) f(%9.6fc)

logistic miss_age ocu1p edu1p ppr1 rent
coefplot, drop(_cons) eform
*/

drop if _merge == 2
drop _merge

ren r18_buildper buildper

/*
Periode vor 1919				8011
Periode von 1919 bis 1945		8012
Periode von 1946 bis 1960		8013
Periode von 1961 bis 1970		8014
Periode von 1971 bis 1980		8015
Periode von 1981 bis 1985		8016
Periode von 1986 bis 1990		8017
Periode von 1991 bis 1995		8018
Periode von 1996 bis 2000		8019
Periode von 2001 bis 2005		8020
Periode von 2006 bis 2010		8021
Periode von 2011 bis 2015		8022
Periode nach 2015				8023
*/

gen buildper2 = (buildper >= 8020)
* ta buildper buildper2, m

la de buildper2 0 "Before 2000" 1 "After 2000", replace
/*
fre buildper
fre buildper2
distinct buildid 
distinct buildid if buildper2
*/

gen ssep3 = ssep1
replace ssep3 = ssep2 if buildper2

gen ssep3_t = ssep1_t
gen ssep3_q = ssep1_q
gen ssep3_d = ssep1_d
replace ssep3_t = ssep2_t if buildper2
replace ssep3_q = ssep2_q if buildper2
replace ssep3_d = ssep2_d if buildper2

la val ssep2_d ssep1_d
la val ssep3_d ssep1_d

la var ssep1_d ""
la var ssep2_d ""
la var ssep3_d ""

order ssep1* ssep2* ssep3*, last

note drop _all

la da "SSEP 3.0 - user dataset of index and coordinates with variables used for PCA"

la var gisid 		"Spatial ID"
la var buildid 		"SNC building ID"

la var ssep1 		"Swiss-SEP 1.0 index"
la var ssep1_t 		"Swiss-SEP 1.0 - tertiles"
la var ssep1_q 		"Swiss-SEP 1.0 - quintiles"
la var ssep1_d 		"Swiss-SEP 1.0 - deciles"

la var ssep2 		"Swiss-SEP 2.0 index"
la var ssep2_t 		"Swiss-SEP 2.0 - tertiles"
la var ssep2_q 		"Swiss-SEP 2.0 - quintiles"
la var ssep2_d 		"Swiss-SEP 2.0 - deciles"

la var ssep3 		"Swiss-SEP 3.0 index"
la var ssep3_t 		"Swiss-SEP 3.0 - tertiles"
la var ssep3_q 		"Swiss-SEP 3.0 - quintiles"
la var ssep3_d 		"Swiss-SEP 3.0 - deciles"

note gisid: "Unique ID groupping small amount of GWR buildings with the same coordinates. Use for geographical analyses and geovisualization!"

note buildid: "Unique GWR building ID. Use to link to SNC!"

/*
* experimental index replacement depending on share of new buildings

mmerge gisid using data/buildper_share, t(n:1) ukeep(buildper_cat)
drop if _merge == 2
drop _merge

forv buildper = 1(1)6 {
	gen ssep3_d_`buildper' = ssep1_d
	replace ssep3_d_`buildper' = ssep2_d if buildper_cat >= `buildper'
}
*/

/*
* experimental - fixing deciles

xtile ssep4_d  = ssep3, nq(10)
fre ssep3_d
fre ssep4_d
ta ssep3_d ssep4_d, m
*/

compress
note: Last changes: $S_DATE $S_TIME
sa "FINAL/DTA/ssep3_full.dta", replace

drop tot_hh ocu?p edu1p ppr1 tot_bb max_dist tot_hh_rnt tot_bb_rnt max_dist_rnt rent ocu?p2 tot_ocu? mis_ocu* buildper

preserve 
	drop gisid
	la da "SSEP 3.0 - SNC user dataset of index and XY coordinates"
	sa "FINAL/DTA/ssep3_user_snc", replace
restore 

* USER DATASET
bysort gisid: keep if _n == 1
drop buildid

la da "SSEP 3.0 - user dataset of index and XY coordinates"

sa "FINAL/DTA/ssep3_user.dta", replace

codebookout "FINAL/ssep3_user_codebook.xls", replace

log using "FINAL/ssep3_user_data_description.txt", replace text 
d, f
notes
log close

export delim using "FINAL/CSV/ssep3_user_geo.csv", delim(",") nolab replace

rscript using "data-raw/Swiss-SEP2/Swiss-SEP2.R"

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Index deciles}
***/

texdoc s , cmdstrip

u "FINAL/DTA/ssep3_user", clear

/*
tabstat ssep3, s(min mean max ) by(ssep3_t) f(%9.6fc)
tabstat ssep3, s(min mean max ) by(ssep3_q) f(%9.6fc)
tabstat ssep3, s(min mean max ) by(ssep3_d) f(%9.6fc)
*/

tabstat ssep3, s( min mean max ) by(ssep3_d) f(%9.2fc)

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Quantiles}

Note that the original quantiles of second version :
***/

texdoc s , cmdstrip

ta ssep2_d, m
 
texdoc s c 

/***
... are tad 'broken' after replacements:
***/

texdoc s , cmdstrip

ta ssep3_d, m
 
texdoc s c 

/***
Some transitions happened:  
***/

texdoc s , cmdstrip

ta ssep2_d ssep3_d, m
 
texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Bland Altman plots of diffs}
***/

texdoc s , nolog 

batplot ssep2 ssep1, notrend info dp(0)
gr export $td\gr\BA_sep1_sep2.png, replace width(800) height(600)

batplot ssep3 ssep1, notrend info dp(0)
gr export $td\gr\BA_sep1_sep3.png, replace width(800) height(600)
 
texdoc s c 

/***

\begin{center}
\includegraphics[width=\textwidth]{gr/BA_sep1_sep2.png} 
\includegraphics[width=\textwidth]{gr/BA_sep1_sep3.png} 
\end{center}
***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Maps}
***/

* rscript using "R/03_sep-map.R"

/***
\begin{center}
\includegraphics[width=\textwidth]{gr/sep-old.png} 
\includegraphics[width=\textwidth]{C:/projects/SNC_Swiss-SEP2/carto/01_sep-dots.png} 
\end{center}
***/


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Validation - SHP data}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Income graph - 1.0}

\begin{center}
\includegraphics[width=.75\textwidth]{gr/orig/orig_income.png} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Income graph - 2.0}
***/

texdoc s , nolog // nodo   

u "data/SHP", clear
keep if geocoded

mmerge gisid using "FINAL/DTA/ssep3_user", t(n:1) ukeep(ssep1_d ssep2_d ssep3_d) 
keep if _merge == 3
drop _merge

preserve 

	keep idhous13 i13eqon ssep?_d

	drop if mi(i13eqon)

	reshape long ssep, i(idhous13 i13eqon) j(sep_version) string

	graph box i13eqon, ///
		over(sep_version, relabel(1 "Old" 2 "New" 3 "Hybrid") label(nolabel)) ///
		over(ssep) asyvars nooutsides ///
		ytitle(Household income [CHF]) ylabel(0(50000)180000, format(%9,0gc)) ymtick(##2, grid) ///
		title(Equivalised yearly household income, ring(0)) ///
		subtitle(Across deciles of three versions of the indes, size(small) ring(0) margin(medlarge)) ///
		note("") legend(title(Index version)) ///
		scheme(plotplainblind) graphregion(margin(zero))

	gr export $td/gr/shp_income.pdf, replace
	gr export $td/gr/shp_income.png, replace

restore 

texdoc s c 

/***
\begin{center}
\includegraphics[width=.75\textwidth]{gr/shp_income.pdf} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Financial variables table - 1.0}

\begin{center}
\includegraphics[width=.95\textwidth]{gr/orig/orig_shp_table.png} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Financial variables table - 2.0}
***/

texdoc s , cmdstrip

tabstat i13eqon if inlist(ssep2_d, 1, 5, 10), s( mean sd ) by(ssep2_d) f(%4.1f) not 
tabstat h13i51 if inlist(ssep2_d, 1, 5, 10), s( mean sd ) by(ssep2_d) f(%4.1f) not 

ta h13i20ac ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
ta h13i21ac ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 

texdoc s c 

/***
\newpage
***/

texdoc s , cmdstrip

ta h13i22   ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
ta h13i23   ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 

texdoc s c 

/***
\newpage
***/

texdoc s , cmdstrip

ta h13i76a  ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
ta h13i50   ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Financial variables table - 3.0}
***/

texdoc s , cmdstrip

tabstat i13eqon if inlist(ssep3_d, 1, 5, 10), s( mean sd ) by(ssep3_d) f(%4.1f) not 
tabstat h13i51 if inlist(ssep3_d, 1, 5, 10), s( mean sd ) by(ssep3_d) f(%4.1f) not 

ta h13i20ac ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 
ta h13i21ac ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 

texdoc s c 

/***
\newpage
***/

texdoc s , cmdstrip

ta h13i22   ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 
ta h13i23   ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 

texdoc s c 

/***
\newpage
***/

texdoc s , cmdstrip

ta h13i76a  ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 
ta h13i50   ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Validation - SNC mortality}

\subsection{All cause mortality - 1.0}

\begin{center}
\includegraphics[width=.50\textwidth, angle = 270]{gr/orig/orig_hr_all.png} 
\end{center}

Note: 	Calculations from 'old' SNC data from the \textbf{2001 - 2008 period}, as described in original paper!

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{All cause mortality - three SEP indices}
***/

texdoc s , nolog // nodo   

u "data/SNC_ALL", clear

* bring sep 1, 2 & 3
mmerge buildid using "FINAL/DTA/ssep3_user_snc", t(n:1) ukeep(ssep1_d ssep2_d ssep3_d)
keep if _merge == 3
drop _merge

* SETTINGS
est clear
stset dstop, origin(dob) entry(dstart) failure(d_all) scale(365.25)
global SET = "nopv base cformat(%5.2f)"
global ADJ = "i.sex nat_bin b2.civil b2.urban b1.lang"

est clear

foreach SEP in ssep1_d ssep2_d ssep3_d {
	* AGE & SEX
	stcox i.sex b10.`SEP', $SET
	est sto u_`SEP'
	* FULLY
	global ADJ = "i.sex nat_bin b2.civil b2.urban b1.lang"
	stcox $ADJ b10.`SEP', $SET
	est sto a_`SEP'
}

la var ssep3_d ""

* est tab u*, eform

global title 	"size(medsmall) color(black) margin(vsmall)"
global lab 		"ylab(, labs(small)) xtitle("Hazard ratio", size(medsmall) margin(vsmall)) xscale(log range(0.98 1.52)) xlab(1.0(0.1)1.5)"
global misc 	"xline( 1.00(0.05)1.50, lcolor(gs14) lwidth(thin)) base ysize(3) xsize(4) msize(medium) lw(medium) grid(none)"
global groups 	"groups(*.ssep3_d = "Hybrid" *.ssep2_d = "New" *.ssep1_d = "Old", angle(vertical))"
global drop 	"drop(*.sex nat_bin *.civil *.urban *.lang)"

coefplot u_ssep1_d u_ssep2_d u_ssep3_d, title("Age & sex adjusted", $title) eform $drop $lab $region $misc $legend $groups scheme(plotplainblind) graphregion(margin(zero)) leg(off) saving(U, replace)

gr export $td/gr/sep3u.pdf, replace
gr export $td/gr/sep3u.png, replace

coefplot a_ssep1_d a_ssep2_d a_ssep3_d, title("Fully adjusted", $title) eform $drop $lab $region $misc $legend $groups scheme(plotplainblind) graphregion(margin(zero)) leg(off) saving(A, replace)

gr export $td/gr/sep3a.pdf, replace
gr export $td/gr/sep3a.png, replace

gr combine U.gph A.gph, title("Hazard ratios of all cause mortality across deciles of three versions of the indices", $title) graphregion(margin(zero))

gr export $td/gr/sep3.pdf, replace
gr export $td/gr/sep3.png, replace

texdoc s c

/***
\begin{center}
\includegraphics[width=.6\textwidth]{gr/sep3u.pdf}
\end{center}
\begin{center}
\includegraphics[width=.6\textwidth]{gr/sep3a.pdf} 
\end{center}

Note: 	Results from Cox models.  
		Calculations from 'new' SNC data from the \textbf{2012 - 2018 period}!  
		'Age \& sex' - adjusted for age (via \texttt{stset}) and sex (as in original figure above);  
		'Adjusted' - additionally adjusted for civil status, nationality, level of urbanization and language region.  
		This is not the smae adjustment as in adsjudsted models in original papers since we are missing some crucial variables. 

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{All cause mortality - three indices, stratified by age}
***/

texdoc s , nolog // nodo   

* STRATIFIED
* age cat
egen age_bin = cut(age), at(19, 65, 110) label
order age_bin, a(age)

/*
fre age_bin
table age_bin, contents(min age max age)
*/

est clear

foreach SEP in ssep1_d ssep2_d ssep3_d {
	forv AGE = 0/1 {
		* AGE & SEX
		stcox i.sex b10.`SEP' if age_bin == `AGE', $SET
		est sto u_`SEP'_age_`AGE'
		* FULLY
		global ADJ = "i.sex nat_bin b2.civil b2.urban b1.lang"
		stcox $ADJ b10.`SEP' if age_bin == `AGE', $SET
		est sto a_`SEP'_age_`AGE'
	}
}

* est tab  u_*   a_*, eform

global title 	"size(medsmall) color(black) margin(vsmall)"
global lab 		"ylab(, labs(small)) xtitle("Hazard ratio", size(medsmall) margin(vsmall)) xscale(log range(0.98 1.92)) xlab(1.0(0.1)1.9)"
global misc 	"xline( 1.00(0.1)1.90, lcolor(gs14) lwidth(thin)) base ysize(3) xsize(4) msize(medium) lw(medium) grid(none)"
global groups 	"groups(*.ssep2_d = "Swiss-SEP index 2.0" *.ssep1_d = "Swiss-SEP index 1.0", angle(vertical))"

coefplot (u_ssep1_d_age_0, label(Young)) (u_ssep1_d_age_1, label(Old)), title("HRs of all cause mortality SSEP 1", $title) eform $drop $lab $region $misc $legend $groups

gr export $td/gr/strat_sep1.pdf, replace
gr export $td/gr/strat_sep1.png, replace

coefplot (u_ssep2_d_age_0, label(Young)) (u_ssep2_d_age_1, label(Old)), title("HRs of all cause mortality SSEP 2", $title) eform $drop $lab $region $misc $legend $groups

gr export $td/gr/strat_sep2.pdf, replace
gr export $td/gr/strat_sep2.png, replace

coefplot (u_ssep3_d_age_0, label(Young)) (u_ssep3_d_age_1, label(Old)), title("HRs of all cause mortality SSEP 3", $title) eform $drop $lab $region $misc $legend $groups

gr export $td/gr/strat_sep3.pdf, replace
gr export $td/gr/strat_sep3.png, replace

texdoc s c  

/***
\begin{center}
\includegraphics[width=.6\textwidth]{gr/strat_sep1.pdf}
\end{center}
\begin{center}
\includegraphics[width=.6\textwidth]{gr/strat_sep2.pdf}
\end{center}
\begin{center}
\includegraphics[width=.6\textwidth]{gr/strat_sep3.pdf}
\end{center}
***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%\newpage
%\subsection{All cause mortality - exploring  different building age structures of SEP 3}
***/

texdoc s , nolog  nodo   

* alternative solutions of 3 using n'hood age structure
mmerge buildid using FINAL/DTA/ssep3_user_snc, t(n:1) ukeep(ssep3_d_?)
keep if _merge == 3
drop _merge

gen SEP = . 

foreach SEP in ssep3_d ssep3_d_1 ssep3_d_2 ssep3_d_3 ssep3_d_4 ssep3_d_5 ssep3_d_6 {
	* AGE & SEX
	replace SEP = `SEP' // smae name for better tabs
	stcox i.sex b10.SEP, $SET
	est sto u_`SEP'
	/* FULLY
	global ADJ = "i.sex nat_bin b2.civil b2.urban b1.lang"
	stcox $ADJ b10.`SEP', $SET
	est sto a_`SEP'
	*/
}

est tab u_*

Results from version 4 onwards converge to simple solution.  

texdoc s c


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Cause specific mortality - 1.0}

\begin{center}
\includegraphics[width=.60\textwidth]{gr/orig/orig_hr_spec.png} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Cause specific mortality - 2.0 results}
***/

texdoc s , nolog // nodo   

global SET = "nopv base cformat(%5.2f)"
global ADJ = "nat_bin b2.civil b2.urban b1.lang"

est clear

foreach EVENT in d_lc d_bc d_pc d_re d_cv d_mi d_st d_ac d_su {


	di in red "*************************************************"
	di in red "Event: `EVENT'" 

	stset dstop, origin(dob) entry(dstart) failure(`EVENT') scale(365.25)
	
	* LADIES 
	if "`EVENT'" == "d_bc" {
		
		stcox b10.ssep2_d if sex, $SET 
		est sto `EVENT'
		stcox $ADJ b10.ssep2_d if sex, $SET
		est sto `EVENT'_a		
	}
	
	* GENTS
	else if "`EVENT'" == "d_pc" {

		stcox b10.ssep2_d if !sex, $SET
		est sto `EVENT'
		stcox $ADJ b10.ssep2_d if !sex, $SET
		est sto `EVENT'_a		
	}	

	else {
	
		stcox i.sex b10.ssep2_d, $SET
		est sto `EVENT'
		stcox i.sex $ADJ b10.ssep2_d, $SET
		est sto `EVENT'_a		
	}	
}

/*
global lab 		"ylab(none) xtitle("Hazard ratio", size(medsmall) margin(vsmall)) xscale(log range(0.78 3.1)) xlab(0.8(0.2)2.4) xline(0.8(0.2)2.6, lcolor(gs14) lwidth(thin))"
global misc 	"ysize(3) xsize(4) msize(medium) lw(medium) grid(none)"

coefplot d_lc d_bc d_pc d_re d_cv d_mi d_st d_ac d_su, title("HRs of mortality", $title) eform $lab $region $misc $legend keep(1.ssep2_d)
*/
texdoc s c 


* VERY CRUDE WAY OR 'PRINTING' TABLE >> CAN BE TURNED INTO LATEX OUTPUT WITH BIT MORE WORK
texdoc s , cmdstrip

estout d_lc d_lc_a, varl(1.ssep2_d "Lung cancer")			c( "b(fmt(2) label(HR) ) ci(par( ( ,  ) ) label(95% CI) )" ) keep(1.ssep2_d) eform  mlabels("Age & sex" "Adjusted")
estout d_bc d_bc_a, varl(1.ssep2_d "Breast cancer")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_pc d_pc_a, varl(1.ssep2_d "Prostate cancer")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)

estout d_cv d_cv_a, varl(1.ssep2_d "Cardiovascular")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_mi d_mi_a, varl(1.ssep2_d "Myocardial infarction")	c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_st d_st_a, varl(1.ssep2_d "Stroke")				c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
 
estout d_re d_re_a, varl(1.ssep2_d "Respiratory")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)

estout d_ac d_ac_a, varl(1.ssep2_d "Traffic accidents")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_su d_su_a, varl(1.ssep2_d "Suicide")				c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)

texdoc s c 

/***
Note for both tables: HRs for the 10th (lowest SEP) decile compared to 1st (highest SEP). 
Breast and prostate cancer: for men and women respectively. 

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Cause specific mortality - 3.0 results}
***/

texdoc s , nolog // nodo   

est clear

foreach EVENT in d_lc d_bc d_pc d_re d_cv d_mi d_st d_ac d_su {


	di in red "*************************************************"
	di in red "Event: `EVENT'" 

	stset dstop, origin(dob) entry(dstart) failure(`EVENT') scale(365.25)
	
	* LADIES 
	if "`EVENT'" == "d_bc" {
		
		stcox b10.ssep3_d if sex, $SET 
		est sto `EVENT'_3
		stcox $ADJ b10.ssep3_d if sex, $SET
		est sto `EVENT'_3_a		
	}
	
	* GENTS
	else if "`EVENT'" == "d_pc" {

		stcox b10.ssep3_d if !sex, $SET
		est sto `EVENT'_3
		stcox $ADJ b10.ssep3_d if !sex, $SET
		est sto `EVENT'_3_a		
	}	

	else {
	
		stcox i.sex b10.ssep3_d, $SET
		est sto `EVENT'_3
		stcox i.sex $ADJ b10.ssep3_d, $SET
		est sto `EVENT'_3_a		
	}	
}

texdoc s c 

texdoc s , cmdstrip

estout d_lc_3 d_lc_3_a, varl(1.ssep3_d "Lung cancer")			c( "b(fmt(2) label(HR) ) ci(par( ( ,  ) ) label(95% CI) )" ) keep(1.ssep3_d) eform  mlabels("Age & sex" "Adjusted")
estout d_bc_3 d_bc_3_a, varl(1.ssep3_d "Breast cancer")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)
estout d_pc_3 d_pc_3_a, varl(1.ssep3_d "Prostate cancer")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)

estout d_cv_3 d_cv_3_a, varl(1.ssep3_d "Cardiovascular")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)
estout d_mi_3 d_mi_3_a, varl(1.ssep3_d "Myocardial infarction")	c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)
estout d_st_3 d_st_3_a, varl(1.ssep3_d "Stroke")				c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)
 
estout d_re_3 d_re_3_a, varl(1.ssep3_d "Respiratory")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)

estout d_ac_3 d_ac_3_a, varl(1.ssep3_d "Traffic accidents")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)
estout d_su_3 d_su_3_a, varl(1.ssep3_d "Suicide")				c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep3_d) eform  mlabels(, none) collabels(, none)

texdoc s c 

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

* bring sep 1 >> spatial join done in 04_sep-diff.Rmd
mmerge gisid using "data/Swiss-SEP2/sep2_sep1_join.dta", t(n:1) ukeep(ssep1_d)
assert _merge != 1
keep if _merge == 3
drop _merge

la var ssep1_d ""
la var ssep2_d ""

* bring sep 3
mmerge buildid using "data-raw/statpop/r18_bu_orig", umatch(r18_egid) ukeep(r18_buildper)
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

/***
\end{document}
***/

* clean graphs
! del "C:\projects\EOLC\Stata\*.gph"