* ***************************************************
/*
  ___ ___ ___ ___   __  
 / __| __| _ \_  ) /  \ 
 \__ \ _||  _// / | () |
 |___/___|_| /___(_)__/ 

Data preparation file

Version 01:~Created. 
Version 02:~New SNC dataset 208. SE processing in loop.
Version 03:~Network connectivity processing.
Version 04:~Dropping data from SE 10 & 11 >> no chance for flatarea.
				Using ISCO instead of SOPC >> BfS warns about poor quality; and sopc is missing.
				Integrating SE 15
				Playing with different ideas for ISCO categorization
Version 05:~Prelim report:
				Using ISCO in range 6,000-9,999 as low professions
				Somehow weird results of SE sample >> to be resolved?
Version 06:~ReRun of analyses:
				Fixing directories & renaming files a bit
Version 07:~Change to SNC 4.0				
Version 08:~New GWR data for better building class &  		
				construction period		
Version 09:~Excluding SNC-SE experimentals	
Version 10:~Switch to 2014 SHP & better income	
Version 11:~
*/

* ***************************************************

qui version 15

qui do "C:\projects\SNC_Swiss-SEP2\Stata\00_run_first.do"

texdoc init $td/SEP2_supplement.tex, replace logdir(log) grdir(gr) prefix("ol_") cmdstrip lbstrip gtstrip linesize(120)
	
clear

/***
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLEMENT FOR SWISS-SEP 2.0 DATA PREP & ANALYSIS
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
\hypersetup{unicode=true, pdfborder = {0 0 0}, colorlinks, citecolor=blue, filecolor=black, linkcolor=blue, urlcolor=blue, pdftitle={Swiss-SEP 2.0 supplement}, pdfauthor={Radoslaw Panczak}}

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

% for subtitle hack 
\usepackage{relsize}

% for subtitle hack 
% https://tex.stackexchange.com/questions/5948/subtitle-doesnt-work-in-article-document-class
\usepackage{relsize}

\title{The Swiss Neighbourhood Index of Socioeconomic Position: Update and Re-validation\\[0.2em]\smaller{}Supplementary materials}

\author{Radoslaw Panczak, Claudia Berlin, Marieke Voorpostel, Marcel Zwahlen, Matthias Egger}

\begin{document}

\maketitle
\tableofcontents
***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Data preparation}
\subsection{SNC - buildings}
***/

* ***************************************************
* DATA PREP 
texdoc s , nolog // nodo 

* *****
* BU_CLASS >> DATA FROM KS
* do "Stata/02_gwrgws-buclassfloor.do"
u "data/buclassfloor/gwrgws_buclassfloor_prep" , clear 

fre org_bu_class
keep if !inrange(org_bu_class, 1110, 1122) & !mi(org_bu_class)

sort egid, stable 

/*
by egid: egen t1 = min(org_bu_class) 
by egid: egen t2 = max(org_bu_class) 
assert t1 == t2
drop t?
*/

by egid: keep if _n ==1 
drop ewid floor org_floor

ta org_bu_class, m sort

compress
sa "data/buclassfloor/gwrgws_buclassfloor_excluded" , replace 

* *****
* COLLECT ALL YEARS 
* still using snc 2.0 here >> might be worth changing to 4.0 but new network analyses would be needed!
forv year = 10/14 {
	
	u r`year'_buildid r`year'_geox r`year'_geoy  ///
		using "$co/data-raw/SNC/snc2_std_pers_90_00_14_all_207_full.dta", clear 

	ren (r`year'_buildid r`year'_geox r`year'_geoy) (buildid geox geoy)
	
	drop if mi(geox) | mi(geoy)  

	* exclude unidentifiable ones; vast majority has no coordinates
	* mdesc geox if mi(buildid) 
	drop if mi(buildid) 
	
	* keep only unique set 
	duplicates drop

	isid buildid

	gen year = `year'
	
	if `year' == 10 {	
		sa "data/ORIGINS", replace
	}
	else {
		append using "data/ORIGINS"
		sa "data/ORIGINS", replace
	}
}


* *****
* 1M PRECISION IS FINE 
* might be worth to investigate why 191 buildings have submeter coords?
replace geox = round(geox)
replace geoy = round(geoy)

* *****
* KEEP NEWEST RECORD IF ALL IS MATCHING
duplicates t buildid geox geoy, gen(dupli)
fre dupli
* distinct buildid if dupli == 0
* distinct buildid if dupli >  0

sort buildid geox geoy year, stable
by buildid geox geoy (year): gen n = _n
by buildid geox geoy (year): gen N = _N

drop if dupli > 0 & n < N
drop dupli n N

* *****
* KEEP LATEST YEAR IF SAME ID BUT DIFFERENT COORDINATES
duplicates t buildid, gen(dupli)
fre dupli
* distinct buildid if dupli == 0
* distinct buildid if dupli >  0

sort buildid year, stable
by buildid (year): gen n = _n
by buildid (year): gen N = _N

* sort buildid year, stable 
drop if dupli > 0 & n < N
drop dupli n N

* HAS TO BE UNIQUE NOW
isid buildid

* *****
* BUILDING TYPE
mmerge buildid using "data/buclassfloor/gwrgws_buclassfloor_excluded", t(1:1) umatch(egid) ukeep(org_bu_class)
drop if _merge == 2

* ta org_bu_class _merge, m row

drop if _merge == 3 // 1.31% funky buildings
drop _merge org_bu_class

* *****
* REMOVE DUPLICATED COORDS
* 1.47% of buildings
duplicates t geox geoy, gen(dupli)
fre dupli

* 153 is a camping! 
* 2602700 1123700 <> 46.264721251 7.473664256 <> https://goo.gl/maps/eC8fDZtEboP2

* 70 probably imprecise
* 2568900 1113700 <> 46.174048609 7.035939244 <> https://goo.gl/maps/JD5AnuyeACS2 

* 56 caravans
* 2581575 1176360 <> 46.738176735 7.197558855 <> https://goo.gl/maps/tqR5NcbmLMR2 

* 33 caravans
* 2581575 1176360 <> 47.052499592 7.072425038 <> https://goo.gl/maps/EKWKJuS7SCk 

egen long gisid = group(geox geoy)
order gisid, a(buildid)

* *****
* UNSOLVED <> HECTAR COORDS ???
generate round_x = ((int(geox/100)*100) == geox) if geox != .
generate round_y = ((int(geoy/100)*100) == geoy) if geoy != .
count if round_x & round_y
* br if round_x & round_y
gen hec = (round_x & round_y)
drop round_?
fre hec 

* LOOKS LIKE AN ERROR
* 2713700 1237100 <> 47.275003744 8.941361570 <> https://goo.gl/maps/i6kgcX8k7xH2

* LOOKS LEGITIMATE
* 2685000 1239200 <> 47.298210169 8.562501479 <> https://goo.gl/maps/7wRKTFw6Per

* *****
la var buildid 	"Building ID"
la var gisid 	"Building ID (GIS)"
la var geox 	"X coord"
la var geoy 	"Y coord"
la var year 	"Year of coordinates"
la var hec 		"Hectare coordinates (analytical)"
la var dupli 	"Duplicate buildid"

note drop _all
la da "SSEP 2.0 - 'origin' SNC buildings for network analysis"
note gisid: "Separate ID for all buildings sharing the same coordinates; removes 13,411 (~1.5%) duplicates of buildid"
note hec: "Hectar coordinates defined analytically, ie. both end with 00 - it might be still legit pair of coordinates!"
note: Last changes: $S_DATE $S_TIME
compress
sa "data/ORIGINS", replace

/* 
* data for GIS

distinct buildid gisid
mdesc buildid gisid

bysort gisid: keep if _n == 1
drop buildid hec dupli

xtile part = gisid, nq(6) // around 250k chunks of data
fre part

export delim using "$sp/ORIGINS.csv", delim(",")  replace
*/ 

texdoc s c 


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Eligible buildings}

\textbf{Origin} buildings are defined as all buildings for which index 
is going to be calculated. These buildings need to:

\begin{enumerate}

	\item Be present at least once in the \textbf{period of 2010-2014} in the SNC dataset.
	\item Have valid 2010+ \textbf{building ID}.
	\item Have valid 2010+ \textbf{geographical coordinates}.
	\item Belong to category of 'normal' \textbf{residential buildings} (ie. no prisons, churches or nursing homes; see Appendix).
	
\end{enumerate}
	
Buildings are selected from the \texttt{snc2\_std\_pers\_90\_00\_14\_all\_206\_full} dataset 
and processed as follows:
	
\begin{enumerate}

	\item All buildings that have an ID and coordinates on any year from \textbf{2010} onward are selected
		
	\item Submeter coordinates are rounded to 1m
		
	\item \textbf{Newest} coordinates are always used when several are available under the same building ID
	
	\item \textbf{Non-residential} buildings (see above) are excluded
	
	\item Buildings having different ID but \textbf{same coordinates} are grouped together using synthetic 'GIS ID'
		(for instance 153 (sic!) different IDs pointing to the same coordinates \href{https://goo.gl/maps/eC8fDZtEboP2}{on a caravan site?})
		
\end{enumerate}

These coordinates become \textbf{n'hood centres} for network analysis and construction of an index.  

***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Results}

Distribution of years from which coordinates of a building are taken: 
***/

texdoc s , cmdstrip

u "data/ORIGINS", clear
fre year

texdoc s c 

/***
Note the distinction between IDs (ie. small amount of buildings with different ID but same coordinates):
***/

texdoc s , cmdstrip

distinct buildid gisid

texdoc s c 


* *****
* EXTRA CHECKS ON BUILDING DATSETS

texdoc s , nolog  nodo

u "$co/data-raw/SNC/snc2_std_pers_90_00_14_all_207_full", clear 
drop v9* v0*

keep if r10_pe_flag == 1

* BUILDINGS WITH MISSING r??\_buildid BUT HAVING (HECTAR?) COORDINATES FROM GIVEN YEAR?
distinct sncid	if mi(r10_buildid) & !mi(r10_geox) & !mi(r10_geoy)
br 				if mi(r10_buildid) & !mi(r10_geox) & !mi(r10_geoy)
ta link 		if mi(r10_buildid) & !mi(r10_geox) & !mi(r10_geoy)
br *buildid *geox *geoy // if inlist(v0_buildid, 2, 3, 4, 7)
br *buildid *geox *geoy if inlist(sncid, "SNC12640943", "SNC14636688")

* BUILDINGS HAVING DIFFERENT COORDINATES IN ONE OF THE YEARS?
distinct sncid 			if r10_buildid == r11_buildid & r10_geox != r11_geox & !mi(r10_buildid)
br *buildid *geox *geoy if r10_buildid == r11_buildid & r10_geox != r11_geox & !mi(r10_buildid)
* gen temp = r10_geox - r11_geox
* su temp if r10_buildid == r11_buildid & r10_geox != r11_geox & !mi(r10_buildid)
* hist temp if r10_buildid == r11_buildid & r10_geox != r11_geox & !mi(r10_buildid)

* CHECKING COVERAGE
mmerge r10_buildid using data/ORIGINS, t(n:1) umatch(buildid)
fre _merge

* CHECKING COVERAGE <> VICE VERSA
u "data/ORIGINS", clear
mmerge buildid using "$co/data-raw/SNC/snc2_std_pers_90_00_14_all_207_full", t(1:n) umatch(r10_buildid) uif(r10_pe_flag == 1)
fre _merge

texdoc s c 


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{SE}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Eligible persons \& households}

\textbf{Destination} households are defined as all household that can provide information for calculation of the index. 
They need to be present in at least one Structural Survey (SE) during the period of 2012-2015.
Surveys of 2010 and 2011 do not provide information
about m2 area of the flat which is needed for calculation of standardised rent and were therefore excluded. 
Additionally, there are some reservations as to quality of the 2010 data. \\

In order to be included, SE personal record must (sequentially): 

\begin{enumerate}

	\item Link to household record.
	
	\item Link to full SNC for \texttt{buildid}.\footnote{Apart from 2015 SE data that are not yet included in the full SNC; \texttt{egid} identifier of the building was kindly provided by the SNC team}
	
	\item Link to valid coordinates (from ORIGINS dataset, see previous section).

\end{enumerate}

Key variables\footnote{Where 'yy' in the name stands for the year of the SE} needed are then selected from each of the sources:
	
\begin{enumerate}

	\item \texttt{sncid, hhyid, age, sex, educ\_agg, educ\_curr, occup\_isco, workstatus} from the 
		\texttt{SEyy\_pers\_full} dataset.
		
	\item \texttt{hhyid, hhtype, hhpos, hhpers, flatrooms, typeowner, rentnet}
		from the \texttt{SEyy\_hh\_full} dataset (linked via \texttt{hhyid}) 
	
	\item \texttt{buildid}
		from the \texttt{snc2\_std\_pers\_90\_00\_14\_all\_206\_full} dataset 
		(linked via \texttt{sncid})
	
	\item \texttt{geox, geoy}
		from the \texttt{ORIGINS} dataset (linked via \texttt{buildid} 	)

\end{enumerate}

At next stage, individuals are excluded if:

\begin{enumerate}
	
	\item Are younger than 19 at the time of SE.
	
	\item Have one of the 'unusual' types of residence permit 
	(Cross-border commuter (G), Short stay (L), Asylum seeker (N), People in need of protection (S), 
	Person required to notify (Meldepflichtige), 
	Diplomat/internat. official with diplomatic immunity, 
	Internat. official without diplomatic immunity, 
	Not classified elsewhere)	
	
	\item If individual participated in more than one SE, the latest record is kept.

\end{enumerate}

For remaining individuals and their households, the following data are prepared:

\begin{enumerate}
	
	\item Individuals are flagged if they work in \textbf{manual or unskilled occupations} 
		(BUT only if they are in \textbf{paid employment} at the time of SE; see below).
	\item Individuals are flagged if they have \textbf{no formal or have only compulsory education} 
		AND are not currently pursuing any further education.
	\item Households have their \textbf{crowding} (number of persons per room) calculated.
	\item Households are flagged if they have \textbf{three to five rooms and are rented}.
	
\end{enumerate}

***/


* ***************************************************
* DATA PREP 

texdoc s , nolog // nodo 

forv YR = 12/15 { 

	if `YR' <= 14 { 
		u sncid age sex hhyid educ_agg educ_curr occup_isco workstatus resiperm canton civil migratstat urban nat_bin sopc_agg langmain1 migratstat using "$co/data-raw/SE/SE`YR'_pers_full", clear 
	}

	if `YR' == 15 { 
		u sncid age sex hhyid educ_agg educ_curr occup_isco workstatus resiperm canton civil migratstat nat_bin sopc_agg langmain1 migratstat using "$co/data-raw/SE/SE`YR'_pers_full", clear 
	}
	
	* starting point
	count 
	texdoc local start_`YR' = `r(N)'	
		
	order hhyid, a(sncid)
	isid sncid
	isid hhyid
	sort hhyid, stable

	gen num_ocu1 = 0
	gen num_ocu2 = 0
	gen num_ocu3 = 0
	* gen num_ocu4 = 0 // ISEI
	* gen num_ocu5 = 0 // SIOPS
	gen den_ocu1 = 1 // !!! change below !!!
	gen den_ocu2 = 1 // !!! change below !!!
	
	gen num_edu = 0
	
	* *****
	* EXCLUDING

	* BELOW 19
	* su age, d
	* ta age, m
	count if age < 19
	texdoc local age_`YR' = `r(N)'
	drop if age < 19

	/* RESIDENCE PERMIT

	0  "Swiss" 
	1  "Seasonal residence permit (A)" 
	2  "Annual residence permit (B)" 
	3  "Permanent residence permit (C)" 
	4  "Permit with gainful employment (Ci)" 
	5  "Provisionally admitted foreigners (F)" 
	6  "Cross-border commuter permit (G)" 
	7  "Short stay (L)" 
	8  "Asylum seeker (N)" 
	9  "People in need of protection (S)" 
	10 "Person required to notify (Meldepflichtige)" 
	11 "Diplomat/internat. official with diplomatic immunity " 
	12 "Internat. official without diplomatic immunity" 
	13 "Not classified elsewhere", replace	*/
	
	* fre resi 

	count if resiperm > 5
	texdoc local res_`YR' = `r(N)'
	drop if resiperm > 5

	* *****
	* OCCUPATIONS
	/* 
	fre occup_isco
	fre workstatus

						   Self-employed       1
			 Collaborating family member       2
								Employee       3
		  Dual basic vocational training       4
							  Unemployed       5
	Not in paid employment - in training       6
		Not in paid employment - retired       7
	   Not in paid employment - disabled       8
	  Not in paid employment - homemaker       9
	 Other person not in paid employment      10
	*/
	
	* HEAVILY RELAYING ON ISCO-08
	* http://www.harryganzeboom.nl/isco08/index.htm 

	* FIX DENOMINATOR >> NOT IN PAID EMPLOYMENT
	replace den_ocu1 = 0 if workstatus >= 6
	replace den_ocu2 = 0 if workstatus >= 6

	* MISSING INDICATOR
	gen mis_ocu_isco = mi(occup_isco)
	replace mis_ocu_isco = 0 if workstatus >= 6
	replace den_ocu2 = 0 if mis_ocu_isco // also removed from denominator #2
	
	* FARMERS >> inrange(occup_isco, 9200, 9299) IS IN UNSKILLED OCCUP!
	* UNSKILLED & MANUAL WORKERS >> BROADEST DEFINITION

	replace num_ocu1 = 1 if inrange(occup_isco, 6000, 6399) & den_ocu1
	replace num_ocu1 = 1 if inrange(occup_isco, 7000, 9999) & den_ocu1
	replace num_ocu1 = 0 if mis_ocu_isco

	* UNSKILLED & MANUAL WORKERS >> NARROWER DEFINITION
	replace num_ocu2 = 1 if inrange(occup_isco, 6000, 6399) & den_ocu1
	replace num_ocu2 = 1 if inrange(occup_isco, 8000, 9999) & den_ocu1
	replace num_ocu2 = 0 if mis_ocu_isco
	
	* UNSKILLED & MANUAL WORKERS >> VERY NARROW DEFINITION >> NO FARMERS!
	replace num_ocu3 = 1 if inrange(occup_isco, 8000, 9999) & den_ocu1
	replace num_ocu3 = 0 if mis_ocu_isco
	
	/*
	ta den_ocu1, m
	ta den_ocu2, m
	ta mis_ocu_isco, m
	ta num_ocu1, m 
	ta num_ocu2, m 
	ta num_ocu3, m 

	tab den_ocu1 mis_ocu_isco , m
	tab den_ocu2 mis_ocu_isco , m

	tab num_ocu1 mis_ocu_isco , m
	tab num_ocu2 mis_ocu_isco , m
	tab num_ocu3 mis_ocu_isco , m
	
	tab num_ocu1 den_ocu1 , m
	tab num_ocu2 den_ocu1 , m
	tab num_ocu3 den_ocu1 , m
	
	tab num_ocu1 den_ocu2 , m
	tab num_ocu2 den_ocu2 , m
	tab num_ocu3 den_ocu2 , m
	*/

	* ISEI 
	if `YR' == 12 { 
		qui do "Stata/isco08/iskoisei08.do" // only once needed to define
	}
	iskoisei08 num_ocu4, isko(occup_isco) 
	order num_ocu4 mis_ocu_isco, a(num_ocu3)
	order mis_ocu_isco, b(den_ocu2)

	/*
	univar num_ocu4
	hist num_ocu4, w(5) start(0)
	*/

	* *****
	/* EDUCATION 
	fre educ_curr

				No formal education       0
			   Compulsory education       1
	Upper secondary level education       2
		   Tertiary level education       3

	fre educ_agg 

		Compulsory education or less      1
	 Upper secondary level education      2
			Tertiary level education      3

	ta educ_agg educ_curr, m 
	ta educ_agg educ_curr if den, m 
	*/

	replace num_edu = 1 if educ_agg == 1
	replace num_edu = 0 if inlist(educ_curr, 2, 3)

	/*
	ta num_edu, m 
	ta num_edu educ_agg , m 
	ta num_edu educ_curr , m 
	*/
	
	* extra vars for table 1
	if `YR' != 15 { 

		order sopc_agg langmain1 migratstat urban, last
		replace urban = 2 if urban == 3
		replace urban = 3 if urban == 4
		la de urban_enl 3 "Rural" 4 "", modify
	}
	
	if `YR' == 15 { 
		order sopc_agg langmain1 migratstat, last
	}
	
	replace langmain1 = 14 if langmain1 >= 4 & langmain1 <= 13
	fre langmain1
	
	replace migratstat = 6 if migratstat >= 3 & migratstat <= 5
	
	la de migratstat2_enl 1 "Swiss without migrant background" 2 "Swiss with migrant background" 6 "Foreigner of 1st-3rd generation", replace
	fre migratstat
	
	compress 
	sa "data/SE`YR'_pers_full", replace


	* ***************************************************
	* DATA PREP HOUSEHOLDS
	
	* AREA AND RENT
	
	u sncid hhyid hhtype hhpos hhpers flatrooms typeowner rentnet flatarea using "$co/data-raw/SE/SE`YR'_hh_full.dta", clear

	sort hhyid
	order hhyid, a(sncid)
	
	* RENI in 3-5 bed (ninmissing rent & area!)
	gen rent35 = ( inrange(flatrooms, 3, 5) & !mi(rentnet) & !mi(flatarea) )
	
	* univar rentnet if rent35, dec(0)
	* univar rentnet if rent35, dec(0) by(flatrooms)
	
	* STANDARDIZE BY M2
	replace rentnet = rentnet / flatarea
	
	* univar flatarea if rent35, dec(0)
	* univar flatarea if rent35, dec(0) by(flatrooms)
	
	* univar rentnet if rent35, dec(0)
	* univar rentnet if rent35, dec(0) by(flatrooms)
	
	* CROWDING 
	* ta flatrooms hhpers, m col
	
	gen ppr = hhpers / flatrooms 
	la var ppr 		"Persons per room"
	* univar ppr

	compress
	sa "data/SE`YR'_hh_full", replace


	* ***************************************************
	* START FROM PERSONAL
	u "data/SE`YR'_pers_full", clear
	
	* ADD HH
	mmerge sncid using "data/SE`YR'_hh_full"
	
	preserve
		ren _merge miss
		replace miss = 0 if miss == 3
		la de miss 0 "Fine" 1 "Missing hh" 2 "Missing pe", replace
		la val miss miss
		save data/SE`YR'_miss, replace
	restore

	count if _merge == 1
	texdoc local hhl_`YR' = `r(N)'	
	
	drop if _merge == 1 // no link to hh ???
	drop if _merge == 2 // hh data of not used 
	drop _merge

	* BRING BUILDID FROM FULL SNC DATASET
	
	if `YR' <= 14 { 
	
		mmerge sncid using "$co/data-raw/SNC/snc2_std_pers_90_00_14_all_207_full", t(1:1) ukeep(r`YR'_buildid)  

		assert _merge != 1 // no snc data ???
		drop if _merge == 2 // no SE data available
		drop _merge

		count if mi(r`YR'_buildid) // no building ID
		texdoc local mhi_`YR' = `r(N)'	
		drop if mi(r`YR'_buildid) 
	}
	
	if `YR' == 15 { 
	
		mmerge sncid using "data/SE15_egid", t(1:1) ukeep(buildid)

		assert _merge != 2 
		
		count if  _merge == 1
		texdoc local fbd_`YR' = `r(N)'	
	
		drop if _merge == 1
		drop _merge
		
		ren buildid r15_buildid
	}
	

	* ELIGIBLE BUILDINGS, BRING COORDINATES
	ren r`YR'_buildid buildid
	mmerge buildid using "data/ORIGINS", t(n:1) ukeep(gisid geox geoy year)

	if `YR' <= 14 { 

		count if _merge == 1
		texdoc local fbd_`YR' = `r(N)'	
	}

	drop if _merge ==  1  // no coords or funky building
	drop if _merge ==  2 // no SE data available
	drop _merge

	* BRING URBAN MISSING IN 15
	
	if `YR' == 15 { 

		mmerge buildid using "data/SE15_urban.dta", t(n:1) umatch(r15_buildid) 
		drop if _merge == 2
		drop _merge
		rename r15_urban urban
	}

	order buildid gisid geox geoy year, a(hhyid)
	gen SE = 2000 + `YR'
	la var SE "Survey year"
	order SE, first

	distinct buildid gisid

	count 
	texdoc local end_`YR' = `r(N)'	

	if `YR' == 12 {
		sa "data/SE", replace
	}
	else {
		append using "data/SE"
		sa "data/SE", replace
	}
	
	rm "data/SE`YR'_hh_full.dta"
	rm "data/SE`YR'_pers_full.dta"
}

sa "data/SE_dupli", replace

sort sncid SE, stable 
by sncid: keep if _n == _N 

* age cat
egen age_cat = cut(age), at(18, 35, 50, 65, 110) label
order age_cat, a(age)

/*
fre age_cat
table age_cat, contents(min age max age)
*/

la da "SSEP 2.0 - 'destination' SE 2012-15 data for SwissSEP 2.0"
note drop _all
note: Last changes: $S_DATE $S_TIME

compress
sa "data/SE", replace

* dataset for missing hh sensitivity analysis
use "data/SE12_miss", clear
gen SE = 2012
la var SE "Survey year"
order SE, first

sa "data/SE_miss", replace
		
forv YR = 13/15 { 
	
	use data/SE`YR'_miss, clear
	gen SE = 2000 + `YR'
	la var SE "Survey year"
	order SE, first

	append using "data/SE_miss"
	sa "data/SE_miss", replace

	rm "data/SE`YR'_miss.dta"
}	

rm "data/SE12_miss.dta"

sort sncid SE, stable 
* by sncid: gen n = _N 
by sncid: keep if _n == _N 

* age cat
egen age_cat = cut(age), at(19, 30, 40, 50, 65, 110) label
order age_cat, a(age)

compress 
sa "data/SE_miss", replace

drop if miss == 2

recode migratstat (4=3) (5=3)
la de migratstat2_enl 3 "Foreigner", modify

ta sex miss, m row nokey
ta age_cat miss, m row nokey
ta civil miss, m row nokey
ta num_edu miss, m row nokey
ta num_ocu1 miss, m row nokey
ta nat_bin miss, m row nokey
ta canton miss, m row nokey

logistic miss i.sex b3.age_cat b2.civil b2.educ_agg i.nat_bin
logistic miss i.sex b3.age_cat b2.civil b2.educ_agg i.migratstat

logistic miss i.sex b3.age_cat b2.civil i.num_edu i.num_ocu1 i.nat_bin i.canton

coefplot, drop(_cons *canton) eform baselevels ///
	ti(Missing household link) xti(OR)
	
gr export $td/gr/hh_miss_ind.png, width(800) height(600) replace 
 
coefplot, keep( *canton) eform baselevels ///
	ti(Missing household link) xti(OR)

gr export $td/gr/hh_miss_cant.png, width(800) height(600) replace

* melogit miss i.sex b3.age_cat b2.civil i.num_edu i.num_ocu1 i.nat_bin || canton:

texdoc s c

/*
* missing ISCO by sex&age

ta SE mis_ocu_isco if den_ocu , m row
ta sex mis_ocu_isco if den_ocu , m row
ta age_cat mis_ocu_isco if den_ocu , m row
ta age_cat mis_ocu_isco if den_ocu & sex , m row
ta age_cat mis_ocu_isco if den_ocu & !sex, m row
*/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsubsection{Exclusions: eligibility criteria}

\begin{table}[!htbp]
\centering
%\caption{My caption}
%\label{my-label}
\begin{tabular}{rrrrr}
\hline
\multicolumn{1}{l}{\multirow{2}{*}{Exclusion}} & \multicolumn{4}{c}{Year}                                                                                  \\
\multicolumn{1}{l}{}                           & \multicolumn{1}{c}{2012} & \multicolumn{1}{c}{2013} & \multicolumn{1}{c}{2014} & \multicolumn{1}{c}{2015} \\
\hline
\multicolumn{1}{l}{\textbf{Start}}             & `start_12'               & `start_13'               & `start_14'               & `start_15'               \\
\quad Age \textless 19				           & `age_12'                 & `age_13'                 & `age_14'                 & `age_15'                 \\
\quad Permit      					           & `res_12'                 & `res_13'                 & `res_14'                 & `res_15'                 \\
\quad No household link				           & `hhl_12'                 & `hhl_13'                 & `hhl_14'                 & `hhl_15'                 \\
\quad No building ID 					       & `mhi_12'                 & `mhi_13'                 & `mhi_14'                 & 0                 \\
\quad Excluded building 				       & `fbd_12'                 & `fbd_13'                 & `fbd_14'                 & `fbd_15'                 \\
\hline
\multicolumn{1}{l}{\textbf{End}}               & `end_12'                 & `end_13'                 & `end_14'                 & `end_15'                 \\
\hline
\end{tabular}
\end{table}

The explanation of substantial amount of individuals not linked to households came from BfS: \\

\emph{The reference person has to fill out a form for all household members. As the FSO "calibrate" the structural survey using the information from STATPOP they decided to not include the information for the additional household members if the household structure (number of hh members, gender information) given on the SE household form didn’t match the household information in STATPOP. This always applies for around 14\% of the SE reference persons.} \\ 

\subsubsection{Exclusions: multiple SE}

In cases when one person participated in more than one SE only newer records were kept.  
***/

texdoc s , cmdstrip // nodo

qui u "data/SE_dupli", clear
duplicates report sncid
qui rm "data/SE_dupli.dta"

texdoc s c


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Results}
Distribution of SE individuals over years:
***/

texdoc s , cmdstrip

u "data/SE", clear
fre SE

texdoc s c

/***
Note the distinction between individuals, households, buildings and \texttt{gisid}, ie. individual and two spatial resolutions:
***/

texdoc s , cmdstrip

distinct sncid hhyid buildid gisid

texdoc s c

* ***************************************************
* DATA FOR GIS 

texdoc s , nolog nodo 

u "data/SE", clear
bysort gisid: keep if _n == 1
keep gisid geox geoy rent35

export delim using "$sp/DESTINATIONS.csv", delim(",")  replace

keep if rent35

export delim using "$sp/DESTINATIONS_RENT.csv", delim(",")  replace

texdoc s c

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Limitations}

\begin{enumerate}

	\item Major limitation is that, compared to SEP 1.0, there is no way to define \textbf{head of the household} - 
		all respondents (see exclusions) of the SE are then used, irrespectively of their position in household.
		
	\item 2014 SE dataset is \textbf{missing information on \textit{'Sozioprofessionelle Kategorie'}} (variable \texttt{sopc}).  
		It has been also signalled by BfS that this variable was of poor quality in 2010-2013 years. 
		Therefore, it is not possible to identify individuals in manual and unskilled occupations in the same way as during 
		construction of original index. That was mitigated by using the 
		\href{http://www.ilo.org/public/english/bureau/stat/isco/isco08/index.htm}{\textbf{ISCO-08 codes}} of occupations 
		to define manual and unskilled workers and farmers.
		Individuals whose occupations belong to one of the major groups 7, 8 \& 9 (for manual and unskilled) and 6 (farmers) were selected.\footnote{Additionally, 
		sensitivity analyses were done with more strict selection of ISCO codes (major groups 8 \& 9 only) as well as 	
		by converting ISCO-08 codes to \href{http://www.harryganzeboom.nl/isco08/qa-isei-08.htm}{\textbf{ISEI-08 codes}} 
		to obtain continuous measure of 'International Socio-Economic Index of occupational status'and calculating summary of these vlaues in n'hood} 				
		Note that occupation codes are available only for people in \textbf{paid employment} so the denominator 
		for calculating 'employment' domain was adapted and all individuals that were not in paid employment were excluded.	
		Also - small proportion of people eligible for calculations based on ISCO codes had them missing. Again, they were included in the study
		but had their profession information replaced to missing and again the denominator was adjusted to reflect that.
		
	\item There is significant amount of individuals in SE data with \textbf{no link to household SE file} and all these records were excluded. 
	
\end{enumerate}
***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Road network}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Setup}

\begin{enumerate}

	\item Network analyses were done using updated version of \textbf{swissTLM3D} data 
		(1.5 version as compared to 1.0 in the previous edition).
	
	\item Network analyses were done using ArcGIS 10.5 (previously - ArcGIS 10.2).
	
	\item Network analyses took all SNC buildings as \texttt{ORIGINS} and calculated 
		50 closest \texttt{DESTINATIONS} from the SE dataset.
		\footnote{In that logic, the n'hood is either constructed from one SE household and 49 SE neighbours 
		OR 50 SE neighbours if the n'hood centre is not the SE household}		
	
	\item Treshold for n'hood construction was set up to be maximum 20 km (measured along the road network).\footnote{That was based 
		on preliminary checks with data, results of previous analyses \& common sense rationale (hard to say it's n'hood if households are more than 20km apart\ldots}
	
	\item As in the 1.0 index, separate n'hoods were created using rented, 3-5 bedroom flats as \texttt{DESTINATIONS}. 

\end{enumerate}

Schematic representation of n'hood 'search' comparing the use of all buildings to use of sample buildings could be visualized as follows: 

\begin{center}
\includegraphics[width=.45\textwidth]{gr-ext/all.png}
\includegraphics[width=.45\textwidth]{gr-ext/sample.png} 
\end{center}

Small \textit{ad hoc} corrections of the \textbf{swissTLM3D} dataset were necessary in cases where unconnected segments of the road network were found. These features were then removed: 

\begin{center}
\includegraphics[width=.5\textwidth]{gr-ext/nw_edits_4.png}
\end{center}

***/

texdoc s , nolog nodo 

* !!! ATTENTION !!! 
* !!! UNZIP 'data-raw\neighb.zip' TO ORIG DATA FOLDER BEFORE ATTEMPTING THAT !!! 
* unzipfile data-raw\neighb.zip, replace
* (same) backup data stored on SNC drive Y:\SNC\SSEP\2_0_connectivity.zip

forv PART = 1/6 {
	* import delim using "data-raw/neighb/SE_101_neighb_20km_`PART'.txt", varn(1) clear 
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
		sa "data/NEIGHB", replace
	}
	else {
		append using "data/NEIGHB"
		sa "data/NEIGHB", replace
	}

}

* RENT
forv PART = 1/6 {
	* import delim using "data-raw/neighb/SE_101_neighb_rent_20km_`PART'.txt", varn(1) clear 
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
		sa "data/NEIGHB_RENT", replace
	}
	else {
		append using "data/NEIGHB_RENT"
		sa "data/NEIGHB_RENT", replace
	}
	
}

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Results - buildings}

Vast majority of the SNC buildings (\texttt{ORIGINS}) have network connections to 50 SE buildings (\texttt{DESTINATIONS})
\footnote{Keep in mind this results will get even better when we move from buildings to households}: 
***/

texdoc s , nolog // nodo 

* EXPLORING SMALL NUMBERS
u "data/NEIGHB", clear
sort gisid_orig destinationrank
by gisid_orig: keep if _n == 1

texdoc s c 

texdoc s , nocmdlog // nodo 

fre b_maxdest

texdoc s c 

/*
* landolt 30
list if gisid_orig == 392823

* legitimate no neighb <> Ufenau Island, Lake Zurich <> 47.216893093 8.778432040 
list if gisid_orig == 1182865

* legitimate no neighb <> Next to Thunersee,  <> 46.659942070 7.792093576 
list if gisid_orig == 644959
*/

/***
The two cases of buildings with no neighbours are legitimate and really have no neighbours on the (highway restricted) road network: 
	one of the buildings is located on \href{https://goo.gl/maps/L5sLmrMXZap}{Ufenau Island}, Lake Zurich; 
	and the other - right next to highway,  \href{https://goo.gl/maps/fxPCBS5TmEQ2}{on the shore of Thunersee}. 
	These two buildings were excluded from the analyses and have no index. \\
	
\begin{center}
\includegraphics[width=.6\textwidth]{gr-ext/ufenau.png} 
\end{center}

Similarly, buildings with n'hoods not meeting the 50 households treshold size will be flagged. \\

Few areas where less than 50 buildings were found in the n'hood (respecting 20km road network distance) were located in sparesly populated areas such as:
	\href{https://goo.gl/maps/BXbgyCYtuGU2}{Gondo} (close to Simplon Pass) or \href{https://goo.gl/maps/mg15ptJPVTJ2}{Avers} (Grisons) villages. \\

Building with the biggest (89!) number of SE households is located in \href{https://goo.gl/maps/oFeag8mQFdS2}{Lausanne} and is in fact pretty big.
***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Results - households}

The n'hood structure of connectivity between SNC buildings \& SE households changes (for better! ;)
when we move from buildings to households. 
Keep in mind - there might be more than one SE household in a certain building and if we take that into account 
household n'hoods can get smaller than building n'hoods. 
***/


texdoc s , nolog  // nodo

u "data/NEIGHB", clear
ren destinationrank dest_rank_bb
drop b_totdist b_maxdest part 

* BRING SE DATA
mmerge gisid_dest using "data/SE", ukeep(sncid ppr num_ocu? mis_ocu_isco den_ocu? num_edu hhpers) umatch(gisid) 
assert _merge == 3
drop _merge

* TWO EXCLUSIONS >> SEE ABOVE
* br if inlist(gisid_orig, 644959, 1182865)
drop if inlist(gisid_orig, 644959, 1182865)

* 50 HOUSEHOLDS + !ALL HOUSEHOLDS FROM LAST BUILDING!
sort gisid_orig dest_rank_bb gisid_dest, stable
by   gisid_orig (dest_rank_bb gisid_dest): gen dest_rank_hh = _n

by   gisid_orig:  gen temp = gisid_dest if dest_rank_hh ==  50
by   gisid_orig: egen h_50 = max(temp)

* not needed really since we do not have complicated cases any longer
* count if !missing(temp) & !missing(temp[_n+1])
* no observations to drop in this case but still preserved from original index calculations where it was needed

* gen exclu = 1 if dest_rank_hh > 50 & gisid_dest != h_50
drop if dest_rank_hh > 50 & gisid_dest != h_50
drop h_50 temp 

* br if inlist(gisid_orig, 32, 23181)

* TOTAL PERSONS
by gisid_orig: egen tot_pp = total(hhpers)

* TOTAL HOUSEHOLDS
by gisid_orig: egen tot_hh = max(dest_rank_hh)

* TOTAL BUILDINGS 
sort gisid_orig gisid_dest, stable

by gisid_orig gisid_dest: gen tot_bb = _n == 1 
by gisid_orig: replace tot_bb = sum(tot_bb)
by gisid_orig: replace tot_bb = tot_bb[_N] 

* FURTHEST BUILDING DISTANCE
by gisid_orig: egen max_dist = max(total_length)
by gisid_orig: egen mean_dist = mean(total_length)
ren total_length ind_dist

* br if inlist(gisid_orig, 94802)

sort gisid_orig dest_rank_bb gisid_dest, stable

la da "SSEP 2.0 - household n'hood structure"
note drop _all
note: Last changes: $S_DATE $S_TIME

compress
sa "data/NEIGHB_PREP", replace

* AGGREGATING
drop sncid

by gisid_orig: egen tot_ocu1 = total(den_ocu1)
*by gisid_orig: egen tot_ocu2 = total(den_ocu2)
*assert tot_ocu2 <= tot_ocu1

by gisid_orig: egen mis_ocu = total(mis_ocu_isco)
*assert tot_ocu1 == tot_ocu2 + mis_ocu

by gisid_orig: egen ocu1 = total(num_ocu1)

/*
by gisid_orig: egen ocu2 = total(num_ocu2)
assert ocu2 <= ocu1
by gisid_orig: egen ocu3 = total(num_ocu3)
assert ocu3 <= ocu2
by gisid_orig: egen ocu4p = mean(num_ocu4) // ! achtung >> not counts !!
*/

* edu0 = tot_hh
by gisid_orig: egen edu1 = total(num_edu)
by gisid_orig: egen ppr1 = mean(ppr) // ! achtung >> not counts !!

keep if dest_rank_hh == 1 

drop gisid_dest dest_rank_bb ind_dist num_ocu? den_ocu? num_edu ppr dest_rank_hh mis_ocu_isco hhpers

gen ocu1p = ocu1/tot_ocu1
*gen ocu2p = ocu2/tot_ocu1
*gen ocu3p = ocu3/tot_ocu1
gen mis_ocu_pr = mis_ocu / (tot_ocu1)

*gen ocu1p2 = ocu1/tot_ocu2
*gen ocu2p2 = ocu2/tot_ocu2
*gen ocu3p2 = ocu3/tot_ocu2

drop ocu1 /*ocu2 ocu3 */

/*
corr ocu1p ocu1p2
gen temp = ocu1p - ocu1p2
univar temp
drop temp

univar tot_hh
univar tot_ocu?			// should not have small numbers o_O
* br if tot_ocu <= 10
univar ocu1p-ocu3p 		// should be nicely <= 1 :>
univar ocu1p2-ocu3p2 		// should be nicely <= 1 :>
univar mis_ocu_pr 		// few places with half n'hood missing; but median is 7% :>
* br if mis_ocu_pr > 0.5
*/

gen edu1p = edu1/tot_hh
* univar edu1p
drop edu1

*order gisid_orig tot_hh tot_bb max_dist ocu1p* ocu2p* ocu3p* ocu4p tot_ocu? mis_ocu mis_ocu_pr edu1p ppr1 
order gisid_orig tot_pp tot_hh tot_bb max_dist ocu1p* tot_ocu? mis_ocu mis_ocu_pr edu1p ppr1 

la var tot_pp		"Total no of SE individuals in n'hood"
la var tot_hh		"Total no of SE households in n'hood"

la var ocu1p 		"Percent low occupation 1"

*la var ocu2p 		"Percent low occupation 2"
*la var ocu3p 		"Percent low occupation 3"
*la var ocu4p 		"Low occupation - mean ISEI"

*la var ocu1p2 		"Percent low occupation 1 (mis!)"
*la var ocu2p2 		"Percent low occupation 2 (mis!)"
*la var ocu3p2 		"Percent low occupation 3 (mis!)"

la var mis_ocu		"Individuals with missing ISCO"
la var mis_ocu_pr	"Share with missing ISCO"
la var tot_ocu1		"Denominator for ISCO"
*la var tot_ocu2		"Denominator for ISCO (mis!)"

la var edu1p 		"Percent low education"

la var ppr1			"Mean no of people per room"

la var tot_bb		"Total no of buildings in n'hood"
la var max_dist		"Distance to furthest building"

la da "SSEP 2.0 - household n'hood aggregated stats"
note drop _all
note: Last changes: $S_DATE $S_TIME

* drop tot_ocu? mis_ocu*

compress
sa "data/NEIGHB_PREP_AGG", replace

texdoc s c 


/***
Number of buildings (within 20km):
***/
texdoc s , cmdstrip 

u "data/NEIGHB_PREP_AGG", clear

univar tot_bb, dec(0)
* su tot_bb, d
* ta tot_bb, m

texdoc s c 


/***
Number of households (within 20km):
***/

texdoc s , cmdstrip 

univar tot_hh, dec(0)
* su tot_hh, d
* ta tot_hh, m

texdoc s c 


/***
Number of individuals:
***/

texdoc s , cmdstrip 

by gisid_orig: egen tot_hhpers = total(hhpers)
univar tot_hhpers 
drop tot_hhpers

texdoc s c 


/***
Average distance [in meters] to the building where furthest SE household is located (within 20km):
***/

texdoc s , cmdstrip 

* univar max_dist, dec(0) 
univar mean_dist, dec(0) 
* su max_dist, d f

texdoc s c 


texdoc s , nolog  nodo 

u "data/NEIGHB_RENT", clear
sort gisid_orig destinationrank
by gisid_orig: keep if _n == 1

fre b_maxdest

texdoc s c 


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Results - households, rent}

As expected, results are slightly worse when we limit network analyses to 3-5 bedroom rented flats only. \\
\\
***/

texdoc s , nolog // nodo

u "data\NEIGHB_RENT", clear
ren destinationrank dest_rank_bb_rnt
drop b_totdist b_maxdest part 

* BRING SE DATA
mmerge gisid_dest using data\SE, ukeep(sncid rent35 rentnet) umatch(gisid) 
assert _merge != 1
keep if _merge == 3
drop _merge

* TWO EXCLUSIONS >> SEE ABOVE
drop if inlist(gisid_orig, 644959, 1182865)

* EXCLUDING NON RENTED
drop if !rent35
drop rent35

* 50 HOUSEHOLDS + ALL HOUSEHOLDS FROM LAST BUILDING
sort gisid_orig dest_rank_bb gisid_dest, stable
by   gisid_orig (dest_rank_bb gisid_dest): gen dest_rank_hh_rnt = _n

by   gisid_orig:  gen temp = gisid_dest if dest_rank_hh_rnt ==  50
by   gisid_orig: egen h_50 = max(temp)

* count if !missing(temp) & !missing(temp[_n+1])

* gen exclu = 1 if dest_rank_hh_rnt > 50 & gisid_dest != h_50
drop if dest_rank_hh_rnt > 50 & gisid_dest != h_50
drop h_50 temp 

* br if inlist(gisid_orig, 32, 23181)

* TOTAL HOUSEHOLDS
by gisid_orig: egen tot_hh_rnt = max(dest_rank_hh_rnt)

* TOTAL BUILDINGS 
sort gisid_orig gisid_dest // , stable

by gisid_orig gisid_dest: gen tot_bb_rnt = _n == 1 
by gisid_orig: replace tot_bb_rnt = sum(tot_bb)
by gisid_orig: replace tot_bb_rnt = tot_bb[_N] 

* FURTHEST BUILDING DISTANCE
by gisid_orig: egen max_dist_rnt = max(total_length)
ren total_length ind_dist_rnt

sort gisid_orig dest_rank_bb_rnt gisid_dest, stable

la da "SSEP 2.0 - household n'hood structure"
note drop _all
note: Last changes: $S_DATE $S_TIME

compress
sa "data\NEIGHB_RENT_PREP", replace

* AGGREGATING
by gisid_orig: egen rent = mean(rentnet) 

by gisid_orig: keep if _n == 1 

isid gisid_orig

drop gisid_dest dest_rank_bb_rnt ind_dist_rnt rentnet dest_rank_hh_rnt sncid 

order gisid_orig tot_hh_rnt tot_bb_rnt max_dist_rnt rent  

la var rent			"Mean rent per m2 (3-5 rooms)"

la var tot_hh_rnt	"Total no of households in n'hood (rent)"
la var tot_bb_rnt	"Total no of buildings in n'hood (rent)"
la var max_dist_rnt	"Distance to furthest building (rent)"

la da "SSEP 2.0 - household n'hood aggregated stats - rent"
note drop _all
note: Last changes: $S_DATE $S_TIME

compress
sa "data\NEIGHB_RENT_PREP_AGG", replace

texdoc s c 


/***
Number of rented buildings (within 20km):
***/

texdoc s , cmdstrip 

u "data\NEIGHB_RENT_PREP_AGG", clear

univar tot_bb_rnt, dec(0)
* su tot_bb_rnt, d
* ta tot_bb_rnt, m

texdoc s c


/***
Number of rented households (within 20km):
***/

texdoc s , cmdstrip 

univar tot_hh_rnt, dec(0)
* su tot_hh_rnt, d
* ta tot_hh_rnt, m

texdoc s c 


/***
Average distance [in meters] to the building where furthest rented SE household is located (within 20km):
***/

texdoc s , cmdstrip 

univar max_dist_rnt, dec(0)
* su max_dist_rnt, d f

texdoc s c 


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Swiss Household Panel}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Setup}

Combined samples I, II and III of the Swiss Household Panel (SHP) dataset were used to validate the index

\begin{enumerate}

	\item SHP households were included if: 

	\begin{enumerate}	
		\item they provided questionnaire in 2014 
		\item had complete information regarding the address
		\item address was successfully geocoded\footnote{Geocoding was done using map.geo.admin.ch service.}
	\end{enumerate}	
		
	\item Same variables that were used in Table 2 of original publication are extracted
		\footnote{Note that 'Savings min. 500 SFrs monthly' has changed - it used to refer to '100 CHF'}	
		
	\item Each geocoded household was spatially linked to the closest building from the ORIGINS dataset 
\end{enumerate}
***/

texdoc s , nolog // nodo

* ********
* fixed income data 
u "$od/SHP/imputed_income_hh_long_shp.dta", clear
keep if year == 2014
drop year filter20
rename idhous idhous14

gen eq_ihtyni = ihtyni / eqoecd
replace eq_ihtyni = round(eq_ihtyni)
order eq_ihtyni, a(ihtyni)
la var eq_ihtyni "Equivalised yearly household income, net"

gen eq_idispyi = idispyi / eqoecd
replace eq_idispyi = round(eq_idispyi)
order eq_idispyi, a(idispyi)
la var eq_idispyi "Equivalised disposable household income"

drop eqoecd ihtyni idispyi ihtaxi
* order ihtaxi, last

compress
sa "$dd/SHP_imputed_income_14.dta", replace

* ********
* 2014 ONLY 
u idhous14 filter14 nbpers14 stathh14 ///
	h14i20ac h14i21ac h14i22 h14i23 h14i76 h14i50 h14i50 h14i51 ///
	wh14css ///
	using "$od/SHP/SHP-Data-W1-W17-STATA/W16_2014/shp14_h_user.dta", clear

fre filter14
fre stathh14
* count if !stathh14
drop  if !stathh14
drop stathh14 

mmerge idhous14 using "$dd/SHP_imputed_income_14.dta", t(1:1) 
drop if _merge == 2
drop _merge

* ********
* GEOCODES 
* prepared in geocoder_SHP_14.xlsx & 98_geocodes.R script and 
mmerge idhous14 using "data/SHP_adresses_14_final", t(1:1) ukeep(gisid)
drop if _merge == 2
recode _merge (1=0) (3=1)
ren _merge geocoded 
la de geocoded 0 "no" 1 "yes"
la val geocoded geocoded
la var geocoded "Geocoding status" 
fre geocoded

* ********
* YEARLY HOUSEHOLD INCOME EQUIVALISED, OECD, NET

* all samples
univar eq_ihtyni if geocoded, d(0)
* excluding imputed
univar eq_ihtyni if geocoded & !imphtyn, d(0)

* YEARLY DISPOSABLE HOUSEHOLD INCOME EQUIVALISED, OECD

* all samples
univar eq_idispyi if geocoded, d(0)
* excluding imputed
univar eq_idispyi if geocoded & !imphtyn, d(0)

* ********
* SAVINGS MIN. 500 SFRS MONTHLY
* fre h14i20ac
recode h14i20ac (-2=-1)
la de H13I20AC -1 "no answer / doesn't know", modify
fre h14i20ac if geocoded

* REASON WHY NO SAVINGS MIN. 500 SFRS MONTHLY
* fre h14i20ac
ta  h14i20ac h14i20ac, m
recode h14i20ac (-2=-1)
la de H13I21AC -1 "no answer / doesn't know", modify
ta h14i20ac if h14i20ac == 2, m
fre h14i20ac if geocoded


* ********
* SAVINGS INTO 3RD PILLAR
* fre h14i22
recode h14i22 (-2=-1)
la de H13I22N -1 "no answer / doesn't know", modify
fre h14i22 if geocoded

* REASON WHY NO SAVINGS INTO 3RD PILLAR
* fre h14i23
ta  h14i23 h14i22, m
recode h14i23 (-2=-1)
la de H13I23 -1 "no answer / doesn't know", modify
ta h14i23 if h14i22 == 2, m
fre h14i23 if geocoded


* ********
* FINANCIAL HELP: HEALTH INSURANCE
* fre h14i76a
recode h14i76a (-3=-1)
recode h14i76a (-2=-1)
la de H13I76A -1 "inaplicable / no answer / doesn't know", modify
fre h14i76a if geocoded


* ********
* ASSESSMENT OF INCOME AND EXPENSES
* fre h14i50
recode h14i50 (-3=-1)
recode h14i50 (-2=-1)
la de H13I50 -1 "inaplicable / no answer / doesn't know", modify
fre h14i50  if geocoded


* ********
* FINANCIAL SITUATION MANAGEABLE
* fre h14i51
mvdecode h14i51, mv(-8/-1)
fre h14i50
univar h14i51 if geocoded


* ********
note drop _all
la da "SSEP 2.0 - SHP '14 data for validation"
note: Last changes: $S_DATE $S_TIME
compress
sa "data/SHP", replace

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Variables}
***/
texdoc s , cmdstrip  
u "data/SHP", clear
drop geocoded gisid
d
texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Geocoding status across surveys}
***/

texdoc s , cmdstrip  

u "data/SHP", clear
ta filter14 geocoded, m row col nokey 

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{SNC - mortality}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Setup}

Association of Swiss-SEP with mortality will be assessed using two models based on complete SNC: 
'age \& sex' and 'semi adjusted'  
(additionally taking into account: nationality, civil status, language region \& level of urbanization). Setup for the analyses in this scenario: 
\begin{enumerate}

	\item Individuals who are recorded in (at least one of the) 2012 - 2018 Censuses are included
	\item Individuals below age 30 on the 1.1.2012 are excluded
	\item Date of entry is either 1.1.2012 or earliest census if individual was not recorded in 2012
	\item Individuals who died on or before 12.31.2011 are excluded (unless the death was cancelled in the dataset)
	\item For individuals having information on one of the covariates recorded in several censuses the latest one is used
	\item Individuals with missing civil status were excluded
	\item Rhaeto-Romansch language region was merged to German
	\item Individuals with no link to the index were excluded
	
\end{enumerate}

***/

texdoc s , nolog // nodo   

u "$co/data-raw/SNC/snc4_90_00_18_full_vs2", clear 

ren v0_buildid buildid // temp rename to keep

* VARS NOT NEEDED
drop v9* v0* *_geox *_geoy *_flatid *_hhid shs92 *_hhpers *_dch_arriv *_permit *_nat *_dseparation *_dcivil *_dmar *_civil_old *_canton dswiss zar natbirth *_comm2006 *_comm *_dmove *_canton2006 *_lang2006 *_urban2006 dis_conc1_icd8* dis_conc2_icd8* dis_init_icd8* dis_init_icd10* dis_cons_icd10* dis_conc1_icd10* dis_conc2_icd10*  *_mo_flag se10_flag r11_commyears r11_commsincebirth m_nat_bin // r10_* 

ren buildid v0_buildid

* NO IMPUTED FOR THE MOMENT 
* fre imputed
drop imputed *_imputed 

* DROPPING: link == 9 >> 'Only census 1990'
* fre link
drop if inlist(link, 9)

* KEEPING ONLY THOSE AVAILABLE IN CENSUSES 2012+
keep if r12_pe_flag == 1 | r13_pe_flag == 1 | r14_pe_flag == 1 | r15_pe_flag == 1 | r16_pe_flag == 1 | r17_pe_flag == 1 | r18_pe_flag == 1
* fre last_census_seen
drop r??_pe_flag

* DOD DISCREPANCIES ???
su dod, f d 
* br if dod <= mdy(12, 31, 2011) & !cancelled_death
drop if dod <= mdy(12, 31, 2011) & !cancelled_death

* AGE ON 1.1.2012; KEEP ONLY 30YEARS AND OLDER
gen age = (mdy(1, 1, 2012) - dob ) / 365.25
* su age
* su dob if age < 0, f 
drop if age < 30 

* FIXING `dstart' VARIABLE >> CANNOT BE LOWER THAN 1.1.2012
* su dstart, f
replace dstart = mdy(1, 1, 2012) if dstart < mdy(1, 1, 2012)

* distinct *buildid

* UPDATE TO LATES AVAILABLE INFORMATION
foreach VAR in nat_bin urban lang civil buildid {
	
	gen long `VAR' = .
	replace  `VAR'  = r18_`VAR' if !mi(r18_`VAR')
	replace  `VAR'  = r17_`VAR' if  mi(`VAR') & !mi(r17_`VAR')
	replace  `VAR'  = r16_`VAR' if  mi(`VAR') & !mi(r16_`VAR')
	replace  `VAR'  = r15_`VAR' if  mi(`VAR') & !mi(r15_`VAR')
	replace  `VAR'  = r14_`VAR' if  mi(`VAR') & !mi(r14_`VAR')
	replace  `VAR'  = r13_`VAR' if  mi(`VAR') & !mi(r13_`VAR')
	replace  `VAR'  = r12_`VAR' if  mi(`VAR') & !mi(r12_`VAR')
	replace  `VAR'  = r11_`VAR' if  mi(`VAR') & !mi(r11_`VAR')
	replace  `VAR'  = r10_`VAR' if  mi(`VAR') & !mi(r10_`VAR')
	
	if "`VAR'" !=  "buildid" {
		la val `VAR' `VAR'_l
	}
	drop r??_`VAR'
}

* RHAETO-ROMANSCH 
* fre lang
recode lang (4=1)

* MISSING CIVIL
* fre civil
drop if mi(civil)

* MISSING buildid
* mdesc buildid
drop if mi(buildid)

* distinct buildid

* EXCLUDE THOSE FROM BUILDINGS WITHOUT SEP
mmerge buildid using data/ORIGINS, t(n:1)
keep if _merge == 3
drop _merge 
isid sncid 
* distinct sncid buildid gisid

* ALL DEATHS >> LATER CASUE SPECIFIC WILL BE ADDED
* fre stopcode
gen d_all = (inlist(stopcode, 5, 15)) // what was 15? o_O

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

note drop _all
la da "SSEP 2.0 - full SNC 4.0 2012-2018 data for mortality analyses"

note: 			SNC: people 30 and over; linked to building with index; covariates calculated using latest available info.
note civil: 	Missing data excluded
note lang: 		Rhaeto-romansch to German langreg 
note: 			Last changes: $S_DATE $S_TIME
compress
sa "data/SNC_ALL", replace

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Individuals \& deaths included}
***/

texdoc s , cmdstrip  

u "data/SNC_ALL", clear

distinct mortid gisid

* tabstat d_*, statistics( sum ) labelwidth(8) varwidth(18) columns(statistics) longstub format(%9.0fc)

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Causes of deaths}
***/

texdoc s , cmdstrip  

tabstat d_*, statistics( sum ) labelwidth(8) varwidth(18) columns(statistics) longstub format(%9.0fc)

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Variables}
***/

texdoc s , cmdstrip  

d

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsection{Last census seen}
***/

texdoc s , cmdstrip

fre last_census_seen

texdoc s c 


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Data analysis}
\subsection{PCA on n'hood aggregated characteristics}
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
screeplot
screeplot, mean ci
loadingplot
scoreplot
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
\subsection{Building construction period}

Construction period of the building is retrived from \texttt{STATPOP 2018} dataset. Detailed typology is recoded to binary indicator flagging buildings constructed on or after 2001. Buidlings with missing information about age are treated as 'old' ones. 

In case of small amount of buildings with same gisid but different buildid 
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
\subsection{Hybrid version of SEP}

This solution is mixing versions 1.0 \& 2.0. First the new buildings have value of index 1.0 assigned using the closest (linear distance) neighbour. 

Then, construction period of the building is retrived from \texttt{STATPOP 2018} dataset and then buildings built before year 2000 have the values of 1.0 index assigned and buildings constructed after 2000 have new values assigned. Buildings without the defined period of construction keep values 1.0 also. 
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
order mean_dist, b(max_dist)
la var mean_dist	"Average distance between buildings in n'hood"

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

note drop _all

note gisid: "Unique ID groupping small amount of GWR buildings with the same coordinates. Use for geographical analyses and geovisualization!"

note buildper2: "Buildings with missing period treated as old ones"

la da "SSEP 3.0 - user dataset of index and coordinates with variables used for PCA"

compress
note: Last changes: $S_DATE $S_TIME
sa "FINAL/DTA/ssep3_full.dta", replace

drop tot_pp tot_hh ocu?p edu1p ppr1 tot_bb max_dist mean_dist tot_hh_rnt tot_bb_rnt max_dist_rnt rent tot_ocu? mis_ocu* buildper

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
... This is expected behaviour since SNC dataset includes few more buildings (with different BfS IDs but same coordinates). 
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
\subsection{Tables}
***/

* rscript using "R/21_table1.R"

/***
\newpage
\subsubsection{Old index}
\begin{landscape}
\begin{footnotesize}
\input(table-1)
\end{footnotesize}
\end{landscape}

\newpage
\subsubsection{New index}
\begin{landscape}
\begin{footnotesize}
\input(table-2)
\end{footnotesize}
\end{landscape}

\newpage
\subsubsection{Hybrid index}
\begin{landscape}
\begin{footnotesize}
\input(table-3)
\end{footnotesize}
\end{landscape}

***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{Maps}
***/

/***
\subsubsection{Original map}
***/

/***
\begin{center}
\includegraphics[width=\textwidth]{gr/sep-old.png} 
\end{center}
***/

* rscript using "R/22_grid.R"

/***
\newpage 
\subsubsection{SEP 2 \& 3 index}

Using hexagonal grid 500m size.  
***/

/***
\begin{center}
\includegraphics[width=\textwidth]{C:/projects/SNC_Swiss-SEP2/analyses/Figure_1.png} 
\end{center}
***/

/***
\newpage
\subsubsection{Differences}
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
\subsection{Validation - SHP data}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Income graph - original}

\begin{center}
\includegraphics[width=.75\textwidth]{gr-orig/orig_income.png} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Income graph - new indices}
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
table ssep3_d [pweight = wh14css] if imphtyn == 0, c(med eq_ihtyni) row f(%9.0fc)

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

* excluding imputed
preserve 

	keep idhous14 imphtyn eq_ihtyni wh14css ssep?_d 
	
	keep if imphtyn == 0

	drop if mi(eq_ihtyni)

	reshape long ssep, i(idhous14 eq_ihtyni) j(sep_version) string

	graph box eq_ihtyni ///
	[pweight = wh14css], ///
		over(sep_version, relabel(1 "Old" 2 "New" 3 "Hybrid") label(nolabel)) ///
		over(ssep) asyvars nooutsides ///
		ytitle(Household income [CHF]) ylabel(0(50000)200000, format(%9,0gc)) ymtick(##2, grid) ///
		title(Equivalised yearly household income - no imputed, ring(0)) ///
		subtitle(Across deciles of three versions of the indes, size(small) ring(0) margin(medlarge)) ///
		note("") legend(title(Index version)) ///
		scheme(plotplainblind) graphregion(margin(zero))

	gr export $td/gr/shp_income_imp.pdf, replace
	gr export $td/gr/shp_income_imp.png, replace

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

\newpage
\begin{center}
\includegraphics[width=.75\textwidth]{gr/shp_income_imp.pdf} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsubsection{Financial variables table - original}

\begin{center}
\includegraphics[width=.95\textwidth]{gr-orig/orig_shp_table.png} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsubsection{Financial variables table - 1.0}
***/

texdoc s , cmdstrip

* tabstat eq_ihtyni if inlist(ssep1_d, 1, 5, 10), s( mean sd ) by(ssep1_d) f(%4.1f) not 
table ssep1_d if inlist(ssep1_d, 1, 5, 10) [pweight = wh14css], c(m eq_ihtyni) row f(%9.0fc)

table ssep1_d if inlist(ssep1_d, 1, 5, 10) & imphtyn == 0 [pweight = wh14css], c(m eq_ihtyni) row f(%9.0fc)

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
\subsubsection{Financial variables table - 2.0}
***/

texdoc s , cmdstrip

* tabstat eq_ihtyni if inlist(ssep2_d, 1, 5, 10), s( mean sd ) by(ssep2_d) f(%4.1f) not 
table ssep2_d if inlist(ssep2_d, 1, 5, 10) [pweight = wh14css], c(m eq_ihtyni) row f(%9.0fc)

table ssep2_d if inlist(ssep2_d, 1, 5, 10) & imphtyn == 0 [pweight = wh14css], c(m eq_ihtyni) row f(%9.0fc)

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
\subsubsection{Financial variables table - 3.0}
***/

texdoc s , cmdstrip

* tabstat eq_ihtyni if inlist(ssep3_d, 1, 5, 10), s( mean sd ) by(ssep3_d) f(%4.1f) not 
table ssep3_d if inlist(ssep3_d, 1, 5, 10) [pweight = wh14css], c(m eq_ihtyni) row f(%9.0fc)

table ssep3_d if inlist(ssep3_d, 1, 5, 10) & imphtyn == 0 [pweight = wh14css], c(m eq_ihtyni) row f(%9.0fc)

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
\subsection{Validation - SNC mortality}

\subsubsection{All cause mortality - original}

\begin{center}
\includegraphics[width=.50\textwidth, angle = 270]{gr-orig/orig_hr_all.png} 
\end{center}

Note: 	Calculations from 'old' SNC data from the \textbf{2001 - 2008 period}, as described in original paper!

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{All cause mortality - new indices}
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
		This is not the same adjustment as in adjusted models in original papers since we are missing some crucial variables. 
***/


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsubsection{Cause specific mortality - original}

\begin{center}
\includegraphics[width=.60\textwidth]{gr-orig/orig_hr_spec.png} 
\end{center}

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsubsection{Cause specific mortality - 1.0}
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
\subsubsection{Cause specific mortality - 2.0 results}
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
\subsubsection{Cause specific mortality - 3.0 results}
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
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Appendix}

\subsection{Non-residential buildings}

'Non-residential' buildings that were excluded from calculation of the index.
***/

texdoc s , cmdstrip

u "data/buclassfloor/gwrgws_buclassfloor_excluded", clear
ta org_bu_class, m sort

texdoc s c 

/***
\end{document}
***/

* clean graphs
! del "C:\projects\EOLC\Stata\*.gph"