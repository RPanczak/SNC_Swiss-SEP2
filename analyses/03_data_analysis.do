* ***************************************************
/*
  ___ ___ ___ ___   __  
 / __| __| _ \_  ) /  \ 
 \__ \ _||  _// / | () |
 |___/___|_| /___(_)__/ 

Data analysis file

*/

* ***************************************************

qui version 15

qui do "C:\projects\SNC_Swiss-SEP2\Stata\00_run_first.do"

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
\hypersetup{unicode=true, pdfborder = {0 0 0}, colorlinks, citecolor=blue, filecolor=black, linkcolor=blue, urlcolor=blue, pdftitle={Swiss-SEP 2.0 data analysis}, pdfauthor={Radoslaw Panczak}}

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
\graphicspath{ {C:/projects/SNC_Swiss-SEP2/analyses/gr} }
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
Report 1.09 - data analysis}}

\author{Radoslaw Panczak \textit{et al.}}

\begin{document}

\maketitle
\tableofcontents
***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{PCA on n'hood aggregated characteristics}
***/

texdoc s , nolog // nodo   

u "data\NEIGHB_PREP_AGG", clear

mmerge gisid_orig using "data\NEIGHB_RENT_PREP_AGG", t(1:1)
assert _merge == 3
drop _merge 

* saving index 'components'
preserve 

	keep gisid_orig ocu1p edu1p ppr1 rent

	ren gisid_orig gisid

	mmerge gisid using "data/ORIGINS", t(1:n) uk(buildid geox geoy)
	order gisid buildid geox geoy, first 
	keep if _merge==3
	drop _merge

	bysort gisid: keep if _n == 1
	save "$pp/data-raw/Swiss-SEP2/ssep2_components", replace
	
restore

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

texdoc s c 

texdoc s , nolog // nodo   

* BRING COORDINATES
* ACHTUNG THAT WILL MAKE MORE BUILDINGS and gisid IS NOT LONGER UNIQUE 
ren gisid_orig gisid

mmerge gisid using "data/ORIGINS", t(1:n) uk(buildid geox geoy)
order gisid buildid geox geoy, first 
keep if _merge==3
drop _merge

* save intermediate dataset for spatial link, keeping on record per gisid!
preserve
	keep gisid geox geoy ssep2 ssep2_t ssep2_q ssep2_d
	bysort gisid: keep if _n == 1
	compress
	save "$pp/data-raw/Swiss-SEP2/ssep2_user", replace
restore

* run 01_Swiss-SEP2.R now to transform to Rds & geo
* rscript using "R/01_Swiss-SEP2.R"

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Building construction period}

Construction period of the building is retrived sfrom \texttt{STATPOP 2018} dataset. Detailed typology is recoded to binary indicator flagging buildings constructed on or after 2001. Buidlings with missing information about age are treated as 'old' ones. 

In case of small onount of buildings with same gisid but different buildid 
(spatial duplicates, n = 1886, 0.1\%) 
when two different periods were recorded (old AND new) building is treated as new. 
***/

texdoc s , nolog // nodo   

* getting age of the buildings
mmerge buildid using "$co/data-raw/statpop/r18_bu_orig", um(r18_egid) uk(r18_buildper)

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
drop miss_age
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

gen buildper2 = (buildper >= 8020 & !mi(buildper))
* ta buildper buildper2, m

/*
preserve
	bysort gisid: keep if _N > 2
	distinct gisid buildid
	egen b_min = min(buildper2)
	egen b_max = max(buildper2)
	bysort gisid: keep if _n == 1
	gen mismatch = (b_min != b_max)
	fre mismatch
restore
*/

/*
* duplicate example 
* with two diff building periods!
list if gisid == 1526778
*/

ren buildper2 orig_buildper2
sort gisid
by gisid: egen buildper2 = max(orig_buildper2)
gen temp = (buildper2 != orig_buildper2)
* by gisid: egen buildper2_mod = sum(temp)
drop temp buildper orig_buildper2

la de buildper2 0 "Before 2000" 1 "After 2000", replace
la val buildper2 buildper2
la var buildper2 "Building period (binary)"

/*
* duplicate example 
* with two diff building periods!
br if gisid == 1526778

fre buildper
fre buildper2
distinct buildid 
distinct buildid if buildper2
*/

* back to unique point dataset!
by gisid: keep if _n == 1
drop buildid

texdoc s c 

texdoc s    

fre buildper2

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Hybrid version of SEP}

This solution is mixing versions 1.0 \& 2.0. First the new buildings have value of index 1.0 assigned using the closest (linear dstance) neighbour. 

Then, construction period of the building is retrived sfrom \texttt{STATPOP 2018} dataset and then buildings built before year 2000 have the values of 1.0 index assigned and buildings constructed after 2000 have new values assigned. Buildings without the defined period of construction keep values 1.0 also. 
***/

texdoc s , nolog // nodo   

* bring sep 1 >> sep 2 spatial join done in 02_sep-diff.Rmd
* rscript using "R/02_sep-diff.R"
mmerge gisid using "data/Swiss-SEP2/sep2_sep1_join.dta", t(1:1) uk(ssep1 ssep1_t ssep1_q ssep1_d)
assert _merge == 3
drop _merge

gen ssep3 = ssep1
replace ssep3 = ssep2 if buildper2

xtile ssep3_t  = ssep3, nq(3)
xtile ssep3_q  = ssep3, nq(5)
xtile ssep3_d  = ssep3, nq(10)

la val ssep1_d ssep1_d
la val ssep2_d ssep1_d
la val ssep3_d ssep1_d

la var ssep1_d ""
la var ssep2_d ""
la var ssep3_d ""

order ssep1* ssep2* ssep3*, last

note drop _all

la da "SSEP 3.0 - user dataset of index and coordinates with variables used for PCA"

la var gisid 		"Spatial ID"

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

note buildper2: "Buildings with missing period treated as old ones"

compress
note: Last changes: $S_DATE $S_TIME
sa "FINAL/DTA/ssep3_full.dta", replace

drop tot_hh ocu?p edu1p ppr1 tot_bb max_dist tot_hh_rnt tot_bb_rnt max_dist_rnt rent tot_ocu? mis_ocu* buildper

preserve 

	mmerge gisid using "data/ORIGINS", t(1:n) um(gisid) uk(buildid)
	drop gisid

	la var buildid "SNC building ID"
	note buildid: "Unique GWR building ID. Use to link to SNC!"

	la da "SSEP 3.0 - SNC user dataset of index and XY coordinates"
	sa "FINAL/DTA/ssep3_user_snc", replace
	
restore 

* USER DATASET
la da "SSEP 3.0 - user dataset of index and XY coordinates"

sa "FINAL/DTA/ssep3_user.dta", replace

codebookout "FINAL/ssep3_user_codebook.xls", replace

log using "FINAL/ssep3_user_data_description.txt", replace text 
d, f
notes
log close

export delim using "FINAL/CSV/ssep3_user_geo.csv", delim(",") nolab replace

* run 03_Swiss-SEP3.R for data conversions to Rds & shp
* rscript using "R/03_Swiss-SEP3.R"

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Index deciles}
***/

texdoc s , cmdstrip

u "FINAL/DTA/ssep3_full.dta", clear

/*
tab1  ssep1_d ssep2_d ssep3_d

tabstat ssep3, s(min mean max ) by(ssep3_t) f(%9.6fc)
tabstat ssep3, s(min mean max ) by(ssep3_q) f(%9.6fc)
tabstat ssep3, s(min mean max ) by(ssep3_d) f(%9.6fc)
*/

tabstat ssep3, s( min mean max ) by(ssep3_d) f(%9.2fc)

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Quantiles}

Note that the deciles of third version in \texttt{user} dataset:
***/

texdoc s , cmdstrip

ta ssep3_d, m

texdoc s c 

/***
... are tad 'broken' in \texttt{snc} dataset :
***/

texdoc s , cmdstrip

preserve 
	u "FINAL/DTA/ssep3_user_snc.dta", clear
	ta ssep3_d, m
restore
 
texdoc s c 

/***
... This is expected behaviour since SNC dataset includes buildings with different BfS IDs but same coordinates. 
Same applies for missing data - there are few buildings where SEP could not have been calculated due to road network constraints.  
***/

/***
\begin{landscape}
Some transitions happened:  
***/

texdoc s , cmdstrip

*ta ssep2_t ssep3_t, m
*ta ssep2_q ssep3_q, m
ta ssep2_d ssep3_d, m
 
texdoc s c 

/***
\end{landscape}

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
\subsubsection{SEP2 vs. SEP1}

\begin{center}
\includegraphics[width=\textwidth]{gr/BA_sep1_sep2.png} 
\end{center}

\subsubsection{SEP3 vs. SEP1}

\begin{center}
\includegraphics[width=\textwidth]{gr/BA_sep1_sep3.png} 
\end{center}
***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Tables}
***/

* rscript using "R/21_table1.R"

/***
\newpage
\subsection{Old index}
\begin{landscape}
\begin{footnotesize}
\input(table-1)
\end{footnotesize}
\end{landscape}

\newpage
\subsection{New index}
\begin{landscape}
\begin{footnotesize}
\input(table-2)
\end{footnotesize}
\end{landscape}

\newpage
\subsection{Hybrid index}
\begin{landscape}
\begin{footnotesize}
\input(table-3)
\end{footnotesize}
\end{landscape}

***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Maps}
***/

/***
\subsection{Original map}
***/

/***
\begin{center}
\includegraphics[width=\textwidth]{gr/sep-old.png} 
\end{center}
***/

* rscript using "R/22_grid.R"

/***
\newpage 
\subsection{SEP 2 \& 3 index}

Using hexagonal grid 500m size.  
***/

/***
\begin{center}
\includegraphics[width=\textwidth]{C:/projects/SNC_Swiss-SEP2/analyses/Figure_1.png} 
\end{center}
***/

/***
\newpage
\subsection{Differences}
***/

/***
\begin{center}
\includegraphics[width=\textwidth]{C:/projects/SNC_Swiss-SEP2/carto/08_sep-diff-grid_hex_500.png} 
\end{center}
***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Validation - SHP data}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Income graph - original}

\begin{center}
\includegraphics[width=.75\textwidth]{gr-orig/orig_income.png} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Income graph - new indices}
***/

texdoc s , nolog // nodo   

u "data/SHP", clear
ta geocoded, m
keep if geocoded
drop geocoded

mmerge gisid using "FINAL/DTA/ssep3_user", t(n:1) uk(ssep1_d ssep2_d ssep3_d) 
assert _merge != 1
keep if _merge == 3
drop _merge

* survey setup
svyset, clear
svyset _n [pweight = wh14css]

* medians for paper
* tabstat eq_ihtyni, s(p50) by(ssep3_d)
table ssep3_d [pweight = wh14css] , c(med eq_ihtyni) row f(%9.0fc)

* share figures with tiles
preserve 

	keep idhous14 eq_ihtyni wh14css ssep?_d

	drop if mi(eq_ihtyni)

	reshape long ssep, i(idhous14 eq_ihtyni) j(sep_version) string

	graph box eq_ihtyni ///
	[pweight = wh14css], ///
		over(sep_version, relabel(1 "Old" 2 "New" 3 "Hybrid") label(nolabel)) ///
		over(ssep) asyvars nooutsides ///
		ytitle(Household income [CHF]) ylabel(0(50000)200000, format(%9,0gc)) ymtick(##2, grid) ///
		title(Equivalised yearly household income, ring(0)) ///
		subtitle(Across deciles of three versions of the indes, size(small) ring(0) margin(medlarge)) ///
		note("") legend(title(Index version)) ///
		scheme(plotplainblind) graphregion(margin(zero))

	gr export $td/gr/shp_income.pdf, replace
	gr export $td/gr/shp_income.png, replace

restore 

* journal figures with no tiles
preserve 

	keep idhous14 eq_ihtyni wh14css ssep?_d

	drop if mi(eq_ihtyni)

	reshape long ssep, i(idhous14 eq_ihtyni) j(sep_version) string

	graph box eq_ihtyni ///
	[pweight = wh14css], ///
		over(sep_version, relabel(1 "Old" 2 "New" 3 "Hybrid") label(nolabel)) ///
		over(ssep) asyvars nooutsides ///
		ytitle(Household income [CHF]) ylabel(0(50000)200000, format(%9,0gc)) ymtick(##2, grid) ///
		note("") legend(title("Index version")) ///
		scheme(plotplainblind) graphregion(margin(zero))

	gr export $td/Figure_2.pdf, replace
	gr export $td/Figure_2.png, replace

restore 

texdoc s c 

/***
\begin{center}
\includegraphics[width=.75\textwidth]{gr/shp_income.pdf} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Financial variables table - original}

\begin{center}
\includegraphics[width=.95\textwidth]{gr-orig/orig_shp_table.png} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Financial variables table - 1.0}
***/

texdoc s , cmdstrip

* tabstat eq_ihtyni if inlist(ssep1_d, 1, 5, 10), s( mean sd ) by(ssep1_d) f(%4.1f) not 
table ssep1_d if inlist(ssep1_d, 1, 5, 10) [pweight = wh14css], c(m eq_ihtyni) row f(%9.0fc)

* tabstat h14i51 if inlist(ssep1_d, 1, 5, 10), s( mean sd ) by(ssep1_d) f(%4.1f) not 
table ssep1_d if inlist(ssep1_d, 1, 5, 10) [pweight = wh14css], c(m h14i51) row f(%9.0fc)

* ta h14i20ac ssep1_d if inlist(ssep1_d, 1, 5, 10), m col nokey 
svy: ta h14i20ac ssep1_d if inlist(ssep1_d, 1, 5, 10), col count perc 

* ta h14i21ac ssep1_d if inlist(ssep1_d, 1, 5, 10), m col nokey 
svy: ta h14i21ac ssep1_d if inlist(ssep1_d, 1, 5, 10), col count perc

texdoc s c 

/***
\newpage
***/

texdoc s , cmdstrip

ta h14i22   ssep1_d if inlist(ssep1_d, 1, 5, 10), m col nokey 
svy: ta h14i22   ssep1_d if inlist(ssep1_d, 1, 5, 10), col count perc

ta h14i23   ssep1_d if inlist(ssep1_d, 1, 5, 10), m col nokey 
svy: ta h14i23   ssep1_d if inlist(ssep1_d, 1, 5, 10), col count perc

texdoc s c 

/***
\newpage
***/

texdoc s , cmdstrip

* ta h14i76a ssep1_d if inlist(ssep1_d, 1, 5, 10), m col nokey 
svy: ta h14i76a ssep1_d if inlist(ssep1_d, 1, 5, 10), col count perc 

* ta h14i50 ssep1_d if inlist(ssep1_d, 1, 5, 10), m col nokey 
svy: ta h14i50 ssep1_d if inlist(ssep1_d, 1, 5, 10), col count perc 

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Financial variables table - 2.0}
***/

texdoc s , cmdstrip

* tabstat eq_ihtyni if inlist(ssep2_d, 1, 5, 10), s( mean sd ) by(ssep2_d) f(%4.1f) not 
table ssep2_d if inlist(ssep2_d, 1, 5, 10) [pweight = wh14css], c(m eq_ihtyni) row f(%9.0fc)

* tabstat h14i51 if inlist(ssep2_d, 1, 5, 10), s( mean sd ) by(ssep2_d) f(%4.1f) not 
table ssep2_d if inlist(ssep2_d, 1, 5, 10) [pweight = wh14css], c(m h14i51) row f(%9.0fc)

* ta h14i20ac ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
svy: ta h14i20ac ssep2_d if inlist(ssep2_d, 1, 5, 10), col count perc 

* ta h14i21ac ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
svy: ta h14i21ac ssep2_d if inlist(ssep2_d, 1, 5, 10), col count perc 

texdoc s c 

/***
\newpage
***/

texdoc s , cmdstrip

* ta h14i22   ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
svy: ta h14i22 ssep2_d if inlist(ssep2_d, 1, 5, 10), col count perc 

* ta h14i23   ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
svy: ta h14i23 ssep2_d if inlist(ssep2_d, 1, 5, 10), col count perc 

texdoc s c 

/***
\newpage
***/

texdoc s , cmdstrip

* ta h14i76a ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
svy: ta h14i76a ssep2_d if inlist(ssep2_d, 1, 5, 10), col count perc 

* ta h14i50 ssep2_d if inlist(ssep2_d, 1, 5, 10), m col nokey 
svy: ta h14i50 ssep2_d if inlist(ssep2_d, 1, 5, 10), col count perc 

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Financial variables table - 3.0}
***/

texdoc s , cmdstrip

* tabstat eq_ihtyni if inlist(ssep3_d, 1, 5, 10), s( mean sd ) by(ssep3_d) f(%4.1f) not 
table ssep3_d if inlist(ssep3_d, 1, 5, 10) [pweight = wh14css], c(m eq_ihtyni) row f(%9.0fc)

* tabstat h14i51 if inlist(ssep3_d, 1, 5, 10), s( mean sd ) by(ssep3_d) f(%4.1f) not 
table ssep3_d if inlist(ssep3_d, 1, 5, 10) [pweight = wh14css], c(m h14i51) row f(%9.0fc)

* ta h14i20ac ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 
svy: ta h14i20ac ssep3_d if inlist(ssep3_d, 1, 5, 10), col count perc 

* ta h14i21ac ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 
svy: ta h14i21ac ssep3_d if inlist(ssep3_d, 1, 5, 10), col count perc 

texdoc s c 

/***
\newpage
***/

texdoc s , cmdstrip

* ta h14i22 ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 
svy: ta h14i22 ssep3_d if inlist(ssep3_d, 1, 5, 10), col count perc 

* ta h14i23 ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 
svy: ta h14i23 ssep3_d if inlist(ssep3_d, 1, 5, 10), col count perc 

texdoc s c 

/***
\newpage
***/

texdoc s , cmdstrip

* ta h14i76a ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 
svy: ta h14i76a ssep3_d if inlist(ssep3_d, 1, 5, 10), col count perc 

* ta h14i50 ssep3_d if inlist(ssep3_d, 1, 5, 10), m col nokey 
svy: ta h14i50 ssep3_d if inlist(ssep3_d, 1, 5, 10), col count perc 

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Validation - SNC mortality}

\subsection{All cause mortality - original}

\begin{center}
\includegraphics[width=.50\textwidth, angle = 270]{gr-orig/orig_hr_all.png} 
\end{center}

Note: 	Calculations from 'old' SNC data from the \textbf{2001 - 2008 period}, as described in original paper!

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{All cause mortality - new indices}
***/

texdoc s , nolog // nodo   

u "data/SNC_ALL", clear

* bring sep 1, 2 & 3
mmerge buildid using "FINAL/DTA/ssep3_user_snc", t(n:1) uk(ssep1_d ssep2_d ssep3_d)
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

* drop labels to save space on graph
la var ssep1_d ""
la var ssep2_d ""
la var ssep3_d ""
la val ssep1_d ssep1_d
* est tab u*, eform

* figure with tiles 
global title 	"size(medsmall) color(black) margin(vsmall)"
global lab 		"ylab(, labs(small)) xtitle("Hazard ratio", size(medsmall) margin(vsmall)) xscale(log range(0.98 1.52)) xlab(1.0(0.1)1.5)"
global misc 	"xline( 1.00(0.05)1.50, lcolor(gs14) lwidth(thin)) base ysize(3) xsize(4) msize(medium) lw(medium) grid(none)"
global groups 	"groups(*.ssep3_d = "Hybrid" *.ssep2_d = "New" *.ssep1_d = "Old", angle(vertical))"
global drop 	"drop(*.sex nat_bin *.civil *.urban *.lang)"

coefplot u_ssep1_d u_ssep2_d u_ssep3_d, title("Age & sex adjusted", $title) eform $drop $lab $region $misc $legend $groups scheme(plotplainblind) graphregion(margin(zero)) leg(off) saving(U, replace)

*gr export $td/gr/sep3u.pdf, replace
*gr export $td/gr/sep3u.png, replace

coefplot a_ssep1_d a_ssep2_d a_ssep3_d, title("Fully adjusted", $title) eform $drop $lab $region $misc $legend $groups scheme(plotplainblind) graphregion(margin(zero)) leg(off) saving(A, replace)

*gr export $td/gr/sep3a.pdf, replace
*gr export $td/gr/sep3a.png, replace

gr combine U.gph A.gph, title("Hazard ratios of all cause mortality across deciles of three versions of the indices", $title) graphregion(margin(zero))

gr export $td/gr/sep3.pdf, replace
gr export $td/gr/sep3.png, replace

* figure without tiles for journal sub
gr combine U.gph A.gph, graphregion(margin(zero))

gr export $td/Figure_3.pdf, replace
gr export $td/Figure_3.png, replace

cap rm A.gph
cap rm U.gph

texdoc s c

/***
\begin{center}
\includegraphics[width=\textwidth]{gr/sep3.pdf}
\end{center}

Note: 	Results from Cox models. Calculations from 'new' SNC data from the \textbf{2012 - 2018 period}!  
		'Age \& sex' - adjusted for age (via \texttt{stset}) and sex (as in original figure above);  
		'Adjusted' - additionally adjusted for civil status, nationality, level of urbanization and language region.  
		This is not the same adjustment as in adsjudsted models in original papers since we are missing some crucial variables. 
***/


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Cause specific mortality - original}

\begin{center}
\includegraphics[width=.60\textwidth]{gr-orig/orig_hr_spec.png} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Cause specific mortality - 1.0}
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
		
		stcox b10.ssep1_d if sex, $SET 
		est sto `EVENT'
		stcox $ADJ b10.ssep1_d if sex, $SET
		est sto `EVENT'_a		
	}
	
	* GENTS
	else if "`EVENT'" == "d_pc" {

		stcox b10.ssep1_d if !sex, $SET
		est sto `EVENT'
		stcox $ADJ b10.ssep1_d if !sex, $SET
		est sto `EVENT'_a		
	}	

	else {
	
		stcox i.sex b10.ssep1_d, $SET
		est sto `EVENT'
		stcox i.sex $ADJ b10.ssep1_d, $SET
		est sto `EVENT'_a		
	}	
}

/*
global lab 		"ylab(none) xtitle("Hazard ratio", size(medsmall) margin(vsmall)) xscale(log range(0.78 3.1)) xlab(0.8(0.2)2.4) xline(0.8(0.2)2.6, lcolor(gs14) lwidth(thin))"
global misc 	"ysize(3) xsize(4) msize(medium) lw(medium) grid(none)"

coefplot d_lc d_bc d_pc d_re d_cv d_mi d_st d_ac d_su, title("HRs of mortality", $title) eform $lab $region $misc $legend keep(1.ssep1_d)
*/
texdoc s c 


* VERY CRUDE WAY OR 'PRINTING' TABLE >> CAN BE TURNED INTO LATEX OUTPUT WITH BIT MORE WORK
texdoc s , cmdstrip

estout d_lc d_lc_a, varl(1.ssep1_d "Lung cancer")			c( "b(fmt(2) label(HR) ) ci(par( ( ,  ) ) label(95% CI) )" ) keep(1.ssep1_d) eform  mlabels("Age & sex" "Adjusted")
estout d_bc d_bc_a, varl(1.ssep1_d "Breast cancer")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep1_d) eform  mlabels(, none) collabels(, none)
estout d_pc d_pc_a, varl(1.ssep1_d "Prostate cancer")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep1_d) eform  mlabels(, none) collabels(, none)

estout d_cv d_cv_a, varl(1.ssep1_d "Cardiovascular")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep1_d) eform  mlabels(, none) collabels(, none)
estout d_mi d_mi_a, varl(1.ssep1_d "Myocardial infarction")	c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep1_d) eform  mlabels(, none) collabels(, none)
estout d_st d_st_a, varl(1.ssep1_d "Stroke")				c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep1_d) eform  mlabels(, none) collabels(, none)
 
estout d_re d_re_a, varl(1.ssep1_d "Respiratory")			c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep1_d) eform  mlabels(, none) collabels(, none)

estout d_ac d_ac_a, varl(1.ssep1_d "Traffic accidents")		c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep1_d) eform  mlabels(, none) collabels(, none)
estout d_su d_su_a, varl(1.ssep1_d "Suicide")				c( "b(fmt(2)) ci(par( ( ,  ) ) )" ) keep(1.ssep1_d) eform  mlabels(, none) collabels(, none)

texdoc s c 

/***
Note for both tables: HRs for the 10th (lowest SEP) decile compared to 1st (highest SEP). 
Breast and prostate cancer: for men and women respectively. 

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
***/

/***
\end{document}
***/

* clean graphs
! del "C:\projects\EOLC\Stata\*.gph"