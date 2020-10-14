* ***************************************************
/*
  ___ ___ ___ ___   __  
 / __| __| _ \_  ) /  \ 
 \__ \ _||  _// / | () |
 |___/___|_| /___(_)__/ 

*/

* ***************************************************

qui do C:\projects\SNC_Swiss-SEP2\Stata\do\00_run_first.do

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
Report 1.06 - data analysis}}

\author{Radoslaw Panczak \textit{et al.}}

\begin{document}

\maketitle
\tableofcontents

***/


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Results}
\subsection{PCA on n'hood aghgregated characteristics}
***/

texdoc s , nolog // nodo   

u $dd\NEIGHB_PREP_AGG, clear

mmerge gisid_orig using $dd\NEIGHB_RENT_PREP_AGG, t(1:1)
assert _merge == 3
drop _merge 

texdoc s c 

* INDEX AS PCA >> USING BROADEST VERSION OF 'LOW' OCCUPATIONS
texdoc s  // , nodo   

pca  ocu1p edu1p ppr1 rent [aw = tot_hh]

texdoc s c 

texdoc s , nolog // nodo   

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
xtile ssep2_d = ssep2, nq(10)

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
*/


* BRING COORDINATES
* ACHTUNG THAT WILL MAKE MORE BUILDINGS and gisid IS NOT LONGER UNIQUE 
ren gisid_orig gisid
mmerge gisid using $dd\ORIGINS, t(1:n) ukeep(geox geoy)
keep if _merge==3
drop _merge
order gisid geox geoy, first 
bysort gisid: keep if _n == 1

note drop _all

la da "SSEP 2.0 - user dataset of index and coordinates with variables used for PCA"

la var gisid 		"Spatial ID"
la var ssep2 		"Swiss-SEP 2.0 index"
la var ssep2_t 		"Swiss-SEP 2.0 - tertiles"
la var ssep2_q 		"Swiss-SEP 2.0 - quintiles"
la var ssep2_d 		"Swiss-SEP 2.0 - deciles"

note gisid: "Unique ID groupping small amount of GWR buildings with the same coordinates. Use for geographical analyses and geovisualization!"

compress
note: Last changes: $S_DATE $S_TIME
sa $dd\ssep2_full, replace

/*
* https://www.stata.com/meeting/uk19/slides/uk19_newson.pdf
somersd ssep2 ssep2, taua transf(z) tdist
scsomersd difference 0, transf(z) tdist

* baplot ssep ssepALT, info

* batplot ssep ssepALT, info
batplot ssep ssepALT, notrend info dp(0)
gr export $td\gr\BA_occu.png, replace width(800) height(600)
*/

* USER DATASET
drop tot_hh ocu?p edu1p ppr1 tot_bb max_dist tot_hh_rnt tot_bb_rnt max_dist_rnt rent ocu?p2 tot_ocu? mis_ocu*  // ssep2* occup_diff

la da "SSEP 2.0 - user dataset of index and XY coordinates"

sa $dd\FINAL\ssep2_user, replace

codebookout "$dd\FINAL\ssep2_user_codebook.xls", replace

log using "$dd\FINAL\ssep2_user_data_description.txt", replace text 
d, f
notes
log close

export delim using "$dd\FINAL\ssep2_user_geo.csv", delim(",")  replace

* BRING COORDINATES
* ACHTUNG THAT WILL MAKE MORE BUILDINGS and gisid IS NOT LONGER UNIQUE 
mmerge gisid using $dd\ORIGINS, t(1:n) ukeep(buildid)
keep if _merge==3
drop _merge
order gisid buildid, first 
drop geox geoy

* NOT UNIQUE ANY LONGER!
distinct gisid
drop gisid

* ALSO NOTE THAT QUINTILES ARE A BIT 'BROKEN' NOW
* ta ssep2_d, m

la var buildid 		"SNC building ID"

note gisid: 	Nonunique ID groupping buildings with the same coordinates. Remove duplilcates when using for geographical analyses or geovisualization!
note buildid: 	Unique GWR building ID. Use to link to SNC!

la da "SSEP 2.0 - SNC user dataset of index and XY coordinates"

sa $dd\FINAL\ssep2_user_snc, replace

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Index deciles}
***/

texdoc s , cmdstrip

u $dd\FINAL\ssep2_user, clear
/*
tabstat ssep2, s(min mean max ) by(ssep2_t) f(%9.6fc)
tabstat ssep2, s(min mean max ) by(ssep2_q) f(%9.6fc)
tabstat ssep2, s(min mean max ) by(ssep2_d) f(%9.6fc)
*/
tabstat ssep2, s( min mean max ) by(ssep2_d) f(%9.2fc)

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Maps}

\begin{center}
\includegraphics[width=\textwidth]{gr/sep-old.png} 
\includegraphics[width=\textwidth]{C:/projects/SNC_Swiss-SEP2/carto/sep-new.png} 
\end{center}
***/


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Validation - SHP data}
***/

texdoc s , nolog // nodo   

u $dd\SHP, clear
keep if geocoded

mmerge gisid using $dd\FINAL\ssep2_user, t(n:1) ukeep(ssep2_d)
keep if _merge == 3
drop _merge

gr box i13eqon, over(ssep2_d) noout ytitle("Equivalised yearly household income (SFr)") ylab(, angle(horizontal)) scheme(plotplain)

gr export $td/gr/shp_income.pdf, replace

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Income graph - 1.0}

\begin{center}
\includegraphics[width=.75\textwidth]{gr/orig/orig_income.png} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Income graph - 2.0}

\begin{center}
\includegraphics[width=.75\textwidth]{gr/shp_income.pdf} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsubsection{Financial variables table - 1.0}

\begin{center}
\includegraphics[width=.95\textwidth]{gr/orig/orig_shp_table.png} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsubsection{Financial variables table - 2.0}
***/

texdoc s , cmdstrip

tabstat i13eqon if inlist(ssep2_d, 1, 5, 10), s( mean sd ) by(ssep2_d) f(%4.1f) not 
tabstat h13i51 if inlist(ssep2_d, 1, 5, 10), s( mean sd ) by(ssep2_d) f(%4.1f) not 

ta h13i20ac ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
ta h13i21ac ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
ta h13i22   ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
ta h13i23   ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
ta h13i76a  ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
ta h13i50   ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Validation - SNC mortality}

\subsubsection{All cause mortality - 1.0}

\begin{center}
\includegraphics[width=.60\textwidth, angle = 270]{gr/orig/orig_hr_all.png} 
\end{center}
***/

texdoc s , nolog // nodo   

u $dd\SNC_ALL, clear

mmerge gisid using $dd\temp, t(n:1) ukeep(ssep2_d)
keep if _merge == 3
drop _merge

* STSETTING
stset dstop, origin(dob) entry(dstart) failure(d_all) scale(365.25)

* SHOULD BE (THEORETICALLY) FASTER THX TO MULTICORE SUPPORT 
* BUT HARD TO ESTIMATE FOR UNIDENTIFIED REASONS???
* streg i.sex b10.ssep2_d, $SET d(weibull)

* AGE & SEX
global SET = "nopv base cf(%5.2f)"
stcox i.sex b10.ssep2_d, $SET
est sto s1
* ADJUSTED
global ADJ = "i.sex nat_bin b2.civil b2.urban b1.lang"
stcox $ADJ b10.ssep2_d, $SET
est sto s1a

global region 	"graphregion(color(white) fc(white) margin(zero)) plotregion(fc(white) margin(vsmall)) bgcolor(white)"
global title 	"size(medsmall) color(black) margin(vsmall)"
global legend 	"legend(cols(1) ring(0) position(11) bmargin(vsmall) region(lcolor(white)))"
global lab 		"ylab(, labs(small)) xtitle("Hazard ratio", size(medsmall) margin(vsmall)) xscale(log range(0.98 1.42)) xlab(1.0(0.1)1.4)"
global misc 	"xline( 1.00(0.05)1.40, lcolor(gs14) lwidth(thin)) base ysize(3) xsize(4) msize(medium) lw(medium) grid(none)"
global groups 	"groups(*.ssep2_d = "Swiss-SEP index 2.0")"
global drop 	"drop(*.sex nat_bin *.civil *.urban *.lang)"

coefplot (s1, label(Age & sex)) (s1a, label(Adjusted*)), title("HRs of all cause mortality", $title) eform $drop $lab $region $misc $legend $groups

gr export $td/gr/d_al.pdf, replace

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{All cause mortality - 2.0 results}

\begin{center}
\includegraphics[width=.75\textwidth]{gr/d_al.pdf} 
\end{center}

Note: Results from Cox models. 'Age \& sex' - adjusted for age (via \texttt{stset}) and sex (as in figure above); 
'Adjusted' - additionally adjusted for civil status, nationality, level of urbanization and language region.

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Cause specific mortality - 1.0}

\begin{center}
\includegraphics[width=.60\textwidth]{gr/orig/orig_hr_spec.png} 
\end{center}
***/

texdoc s , nolog // nodo   

global SET = "nopv base cf(%5.2f)"
global ADJ = "nat_bin b2.civil b2.urban b1.lang"

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


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Cause specific mortality - 2.0 results}
***/

* VERY CRUDE WAY OR 'PRINTING' TABLE >> CAN BE TURNED INTO LATEX OUTPUT WITH BIT MORE WORK
texdoc s , cmdstrip

estout d_lc d_lc_a, varl(1.ssep2_d "Lung cancer") 				c( "b(fmt(2) label(HR) ) ci(par( ( ,  ) ) label(95% CI) )" ) keep(1.ssep2_d) eform  mlabels("Age & sex" "Adjusted")
estout d_bc d_bc_a, varl(1.ssep2_d "Breast cancer")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_pc d_pc_a, varl(1.ssep2_d "Prostate cancer")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)

estout d_cv d_cv_a, varl(1.ssep2_d "Cardiovascular")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_mi d_mi_a, varl(1.ssep2_d "Myocardial infarction")	c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_mi d_mi_a, varl(1.ssep2_d "Stroke")					c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
 
estout d_re d_re_a, varl(1.ssep2_d "Respiratory")				c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)

estout d_ac d_ac_a, varl(1.ssep2_d "Traffic accidents")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_su d_su_a, varl(1.ssep2_d "Suicide")					c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)

texdoc s c 

/***
Note for both tables: HRs for the 10th (lowest SEP) decile compared to 1st (highest SEP). 
Breast and prostate cancer: for men and women respectively. 
***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Validation - SNC SE mortality}
***/

texdoc s , nolog // nodo   

u $dd\SNC_SE, clear

mmerge gisid using $dd\temp, t(n:1) ukeep(ssep2_d)
keep if _merge == 3
drop _merge

* STSETTING
stset dstop, origin(dob) entry(dstart) failure(d_all) scale(365.25)

* AGE & SEX
global SET = "nopv base cf(%5.2f)"
stcox i.sex b10.ssep2_d, $SET
est sto s1
* ADJUSTED
global ADJ = "i.sex nat_bin b2.civil b2.urban b1.lang"
stcox $ADJ b10.ssep2_d, $SET
est sto s1a
* ADJUSTED 2
global ADJ2 = "i.sex nat_bin b2.civil b2.urban b1.lang b2.educ b2.ocu"
stcox $ADJ2 b10.ssep2_d, $SET
est sto s1a2

global region 	"graphregion(color(white) fc(white) margin(zero)) plotregion(fc(white) margin(vsmall)) bgcolor(white)"
global title 	"size(medsmall) color(black) margin(vsmall)"
global legend 	"legend(cols(1) ring(0) position(11) bmargin(vsmall) region(lcolor(white)))"
global lab 		"ylab(, labs(small)) xtitle("Hazard ratio", size(medsmall) margin(vsmall)) xscale(log range(0.85 1.62)) xlab(0.9(0.1)1.5)"
global misc 	"xline( 0.9(0.1)1.5, lcolor(gs14) lwidth(thin)) base ysize(3) xsize(4) msize(medium) lw(medium) grid(none)"
global groups 	"groups(*.ssep2_d = "Swiss-SEP index 2.0")"
global drop 	"drop(*.sex nat_bin *.civil *.urban *.lang *.educ *.ocu)"

coefplot (s1, label(Age & sex)) (s1a, label(Adjusted 1))  (s1a2, label(Adjusted 2)), title("HRs of all cause mortality", $title) eform $drop $lab $region $misc $legend $groups

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

global SET = "nopv base cf(%5.2f)"
global ADJ = "nat_bin b2.civil b2.urban b1.lang"
global ADJ2 = "i.sex nat_bin b2.civil b2.urban b1.lang b2.educ b2.ocu"

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
		stcox $ADJ2 b10.ssep2_d if sex, $SET
		est sto `EVENT'_a2		
	}
	
	* GENTS
	else if "`EVENT'" == "d_pc" {

		stcox b10.ssep2_d if !sex, $SET
		est sto `EVENT'
		stcox $ADJ b10.ssep2_d if !sex, $SET
		est sto `EVENT'_a
		stcox $ADJ2 b10.ssep2_d if !sex, $SET
		est sto `EVENT'_a2		
	}	

	else {
	
		stcox i.sex b10.ssep2_d, $SET
		est sto `EVENT'
		stcox i.sex $ADJ b10.ssep2_d, $SET
		est sto `EVENT'_a
		stcox i.sex $ADJ2 b10.ssep2_d, $SET
		est sto `EVENT'_a2		
	}	
}

texdoc s c 


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Cause specific mortality - 2.0}
***/


* VERY CRUDE WAY OR 'PRINTING' TABLE >> CAN BE TURNED INTO LATEX OUTPUT WITH BIT MORE WORK
texdoc s , cmdstrip

estout d_lc d_lc_a d_lc_a2, varl(1.ssep2_d "Lung cancer") 			c( "b(fmt(2) label(HR) ) ci(par( ( ,  ) ) label(95% CI) )" ) keep(1.ssep2_d) eform  mlabels("Age & sex" "Adjusted 1" "Adjusted 2")
estout d_bc d_bc_a d_bc_a2, varl(1.ssep2_d "Breast cancer")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_pc d_pc_a d_pc_a2, varl(1.ssep2_d "Prostate cancer")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)

estout d_cv d_cv_a d_cv_a2, varl(1.ssep2_d "Cardiovascular")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_mi d_mi_a d_mi_a2, varl(1.ssep2_d "Myocardial infarction")	c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_mi d_mi_a d_mi_a2, varl(1.ssep2_d "Stroke")				c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
 
estout d_re d_re_a d_re_a2, varl(1.ssep2_d "Respiratory")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)

* estout d_ac d_ac_a d_ac_a2, varl(1.ssep2_d "Traffic accidents")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)
estout d_su d_su_a d_su_a2, varl(1.ssep2_d "Suicide")				c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep2_d) eform  mlabels(, none) collabels(, none)

texdoc s c 

/***
Note: results of traffic accidents were not possible to estimate due to small number of events (n=10)
***/

/***
\end{document}
***/

* clean graphs
! del C:\projects\EOLC\Stata\*.gph

* ===================================================
* CHECKING HRs OF INDIVIDUAL COMPONENTS OF THE INDEX

texdoc s , nolog  nodo   

u $dd\temp, clear
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

texdoc s c 


* ===================================================
* ver1.0 spatial checks

texdoc s , nolog  nodo   

import delim using "C:\projects\SNC_Swiss-SEP1\Stata\textres\FINAL\CSV\ssep_user_geo.csv", clear

isid v0_buildid
isid gwr_x00 gwr_y00

egen gisid_old = group(gwr_x00 gwr_y00)
order gisid_old, first 
distinct v0_buildid gisid_old

sort gisid_old
/*
by gisid_old: egen t1 = max(ssep)
by gisid_old: egen t2 = min(ssep)
count if t1 != t2 
drop t?
*/
by gisid_old: keep if _n == 1
drop v0_buildid ssep_q ssep_t
ren ssep ssep1
ren ssep_d ssep_d1

texdoc s c 