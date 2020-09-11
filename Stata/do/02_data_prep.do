* ***************************************************
/*
  ___ ___ ___ ___   __  
 / __| __| _ \_  ) /  \ 
 \__ \ _||  _// / | () |
 |___/___|_| /___(_)__/ 

Version 01:~Created. 
Version 02:~New SNC dataset 207. SE processing in loop.
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
				
*/

* ***************************************************

qui do C:\projects\SNC_Swiss-SEP2\Stata\do\00_run_first.do

texdoc init $td\report_sep2_prep.tex, replace logdir(log) grdir(gr) prefix("ol_") cmdstrip lbstrip gtstrip linesize(120)
	
clear

/***
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REPORT FOR SWISS-SEP 2.0 DATA PREP
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

\title{\textbf{Swiss-SEP 2.0 index \endgraf 
Report 1.06 - data prep}}

\author{Radoslaw Panczak \textit{et al.}}

\begin{document}

\maketitle
\tableofcontents

***/


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\section{Data sources}
\subsection{SNC - buildings}
***/

* ***************************************************
* DATA PREP  // TAKES A BIT OF TIME !!!
texdoc s , nolog // nodo 

* *****
* BU_CLASS >> DATA FROM KS
u "$od\buclassfloor\gwrgws_buclassfloor_prep" , clear 

ta org_bu_class, m
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
sa "$dd\buclass" , replace 

* CHECKING AGAINST FULL SNC WITH 2014 AS TEST
u "$od\snc2_std_pers_90_00_14_all_207_full.dta", clear 

keep if r14_pe_flag == 1

mmerge r14_buildid using "$dd\buclass" , t(n:1) umatch(egid)

ta org_bu_class, m sort

keep if _merge == 3

sort r14_buildid
by r14_buildid: gen pop = _N
by r14_buildid: keep if _n == 1

keep r14_buildid r14_geo? org_bu_class pop 

ta org_bu_class, m sort

list if org_bu_class == 1273
* r14_buildid 899170556 >> Château de Rolle https://goo.gl/maps/pUK1QCa33KL2

list if org_bu_class == 1262
* r14_buildid 899909336 >> Old windmill Brüngger Wyla https://goo.gl/maps/SRxGAKyF5982

list if org_bu_class == 1272
* r14_buildid 898986979 >> Eglise Saint Boniface https://goo.gl/maps/k23r9ZEspXr 

list if org_bu_class == 1212
* r14_buildid 709548512 >> Camping Arolla https://goo.gl/maps/7obNv6U2ZHm6aAhy5 

list if org_bu_class == 1274
* r14_buildid 899544547 >> Gefängnis Bässlergut https://goo.gl/maps/nu3ydKtJENK2

list if org_bu_class == 1220
* r14_buildid 890985601 >> César Ritz hotel school https://goo.gl/maps/G4squepw5pQ2


* *****
* COLLECT ALL YEARS <> 15 STILL NOT AVIALABLE
forv year = 10/14 {

	u r`year'_buildid r`year'_geox r`year'_geoy  ///
		using "$od\snc2_std_pers_90_00_14_all_207_full.dta", clear 

	ren (r`year'_buildid r`year'_geox r`year'_geoy) (buildid geox geoy)
	
	drop if mi(geox)  
	drop if mi(geoy)  

	drop if mi(buildid) // ??? 

	duplicates drop

	isid buildid

	gen year = `year'
	
	if `year' == 10 {	
		sa $dd\ORIGINS, replace
	}
	else {
		append using $dd\ORIGINS
		sa $dd\ORIGINS, replace
	}
}


* *****
* 1M PRECISION IS FINE
replace geox = round(geox)
replace geoy = round(geoy)

* *****
* KEEP NEWEST RECORD IF ALL IS MATCHING
duplicates t buildid geox geoy, gen(dupli)
ta dupli, m
* distinct buildid if dupli == 0
* distinct buildid if dupli >  0

bysort buildid geox geoy (year): gen n = _n
bysort buildid geox geoy (year): gen N = _N

* sort buildid year, stable 
drop if dupli > 0 & n < N
drop dupli n N

* *****
* KEEP LATEST YEAR IF SAME ID BUT DIFFERENT COORDINATES
duplicates t buildid, gen(dupli)
ta dupli
* distinct buildid if dupli == 0
* distinct buildid if dupli >  0

bysort buildid (year): gen n = _n
bysort buildid (year): gen N = _N

* sort buildid year, stable 
drop if dupli > 0 & n < N
drop dupli n N

* HAS TO BE UNIQUE NOW
isid buildid

* *****
* BUILDING TYPE
mmerge buildid using "$dd\buclass" , t(n:1) umatch(egid) ukeep(org_bu_class)
drop if _merge == 2

* ta org_bu_class _merge, m row

drop if _merge == 3 // 1.31% funky buildings
drop _merge org_bu_class

* *****
* REMOVE DUPLICATED COORDS
* 1.47% of buildings
duplicates t geox geoy, gen(dupli)
ta dupli, m

* 153 is a camping! 
* 2602700 1123700 <> 46.264721251 7.473664256 <> https://goo.gl/maps/eC8fDZtEboP2

* 70 probably imprecise
* 2568900 1113700 <> 46.174048609 7.035939244 <> https://goo.gl/maps/JD5AnuyeACS2 

* 56 caravans
* 2581575 1176360 <> 46.738176735 7.197558855 <> https://goo.gl/maps/tqR5NcbmLMR2 

* 33 caravans
* 2581575 1176360 <> 47.052499592 7.072425038 <> https://goo.gl/maps/EKWKJuS7SCk 

egen gisid = group(geox geoy)
distinct buildid gisid
order gisid, a(buildid)

* *****
* UNSOLVED <> HECTAR COORDS ???
generate round_x = ((int(geox/100)*100) == geox) if geox != .
generate round_y = ((int(geoy/100)*100) == geoy) if geoy != .
count if round_x & round_y
* br if round_x & round_y
gen hec = (round_x & round_y)
drop round_?
tab hec, m

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
sa $dd\ORIGINS, replace

bysort gisid: keep if _n == 1
drop buildid hec dupli

xtile part = gisid, nq(6) // around 250k chunks of data
* ta part, m

* export delim using "$sp\ORIGINS.csv", delim(",")  replace

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
	
	\item Buildings having different ID but \textbf{same cordinates} are groupped together using synthetic 'GIS ID'
		(for instance 153 (sic!) different buidling IDs pointing to the same coordinates \href{https://goo.gl/maps/eC8fDZtEboP2}{on a caravan site?})
		
\end{enumerate}

These coordinates become \textbf{n'hood centres} for network analysis and construction of an index.  

***/

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Results}

Distribution of years from which coordinates of a building are taken: 
***/

texdoc s , cmdstrip

u $dd\ORIGINS, clear
ta year, m

texdoc s c 

/***
Note the distinction between IDs (ie. small amount of buildings with different ID but same coordinates):
***/

texdoc s , cmdstrip

distinct buildid gisid

texdoc s c 


* *****
* SOME CHECKS OF 

texdoc s , nolog  nodo

u "$od\snc2_std_pers_90_00_14_all_207_full", clear 
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
* mmerge r10_buildid using $dd\ORIGINS, t(n:1) umatch(buildid)

* CHECKING COVERAGE <> VICE VERSA
* mmerge buildid using "$od\snc2_std_pers_90_00_14_all_207_full", t(1:n) umatch(r14_buildid)

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

	\item \texttt{sncid, hhyid, age, educ\_agg, educ\_curr, occup\_isco, workstatus} from the 
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
	(Cross-border commuter (G), Short stay (L), Asylum seeker (N), People in need of protection (S), Person required to notify (Meldepflichtige), 
	Diplomat/internat. official with diplomatic immunity, Internat. official without diplomatic immunity, Not classified elsewhere)	
	
	\item If individual participated in more than one SE, the latest record is kept.

\end{enumerate}

For remaining individuals and their households, the following data are prepared:

\begin{enumerate}
	
	\item Individuals are flagged if they work in \textbf{manual or unskilled occupations} 
		(BUT only if they are in \textbf{paid employment} at the time of SE; see below).
	\item Individuals are flagged if they have \textbf{no formal or have only compulsory education} 
		AND are not currently pursuing any further education.
	\item Households have their \textbf{crowding} (number of persons per room) calculated.
	\item Households are flaged if they have \textbf{three to five rooms and are rented}.
	
\end{enumerate}

***/



* ***************************************************
* DATA PREP 

texdoc s , nolog // nodo 

forv YR = 12/15 { 

	u sncid age hhyid educ_agg educ_curr occup_isco workstatus resiperm using $od\SE\SE`YR'_pers_full.dta, clear

	order hhyid, a(sncid)
	isid sncid
	isid hhyid
	sort hhyid, stable

	gen num_ocu1 = 0
	gen num_ocu2 = 0
	gen num_ocu3 = 0
	* gen num_ocu4 = 0 // ISEI
	* gen num_ocu5 = 0 // SIOPS
	gen den_ocu = 1 // !!! change below !!!
	
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

	0 "Swiss" 
	1 "Seasonal residence permit (A)" 
	2 "Annual residence permit (B)" 
	3 "Permanent residence permit (C)" 
	4 "Permit with gainful employment (Ci)" 
	5 "Provisionally admitted foreigners (F)" 
	6 "Cross-border commuter permit (G)" 
	7 "Short stay (L)" 
	8 "Asylum seeker (N)" 
	9 "People in need of protection (S)" 
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
	replace den_ocu = 0 if workstatus >= 6

	* MISSING INDICATOR
	gen mis_ocu_isco = mi(occup_isco)
	replace mis_ocu_isco = 0 if workstatus >= 6
	replace den_ocu = . if mis_ocu_isco // also removed from denominator
	
	* FARMERS >> inrange(occup_isco, 9200, 9299) IS IN UNSKILLED OCCUP!
	* UNSKILLED & MANUAL WORKERS >> BROADEST DEFINITION

	replace num_ocu1 = 1 if inrange(occup_isco, 6000, 6399) & den_ocu
	replace num_ocu1 = 1 if inrange(occup_isco, 7000, 9999) & den_ocu
	replace num_ocu1 = . if mis_ocu_isco

	* UNSKILLED & MANUAL WORKERS >> NARROWER DEFINITION
	replace num_ocu2 = 1 if inrange(occup_isco, 6000, 6399) & den_ocu
	replace num_ocu2 = 1 if inrange(occup_isco, 8000, 9999) & den_ocu
	replace num_ocu2 = . if mis_ocu_isco
	
	* UNSKILLED & MANUAL WORKERS >> NARROW DEFINITION >> NO FARMERS!
	replace num_ocu3 = 1 if inrange(occup_isco, 8000, 9999) & den_ocu
	replace num_ocu3 = . if mis_ocu_isco

	* ISEI 
	if `YR' == 12 { 
		qui do $dod\isco08\iskoisei08.do // only once needed to define
	}
	iskoisei08 num_ocu4, isko(occup_isco) 

	/*
	ta den_ocu, m
	ta mis_ocu_isco, m
	ta num_ocu1, m 
	ta num_ocu2, m 
	ta num_ocu3, m 
	
	univar num_ocu4
	* hist num_ocu4, w(5) start(0)
	*/

	* *****
	/* EDUCATION 
	fre educ_curr

				No formal education       0
			   Compulsory education       1
	Upper secondary level education       2
		   Tertiary level education       3

	fre educ_agg 

		Compulsory education or less       1
	 Upper secondary level education       2
			Tertiary level education       3

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
	
	compress 
	sa $dd\SE`YR'_pers_full, replace


	* ***************************************************
	* DATA PREP HOUSEHOLDS
	
	* AREA AND RENT
	* flatarea NOT AVAILABLE IN 10 & 11 !!! :/
	
	u sncid hhyid hhtype hhpos hhpers flatrooms typeowner rentnet flatarea using "$od\SE\SE`YR'_hh_full.dta", clear

	sort hhyid
	order hhyid, a(sncid)
	
	* ACHTUNG THIS WAS ONLY SPOTTED AND ADDED AFTER ALL CALCULATIONS WERE ALMOST DONE
	* SMALL MISTAKE AFFECTING 0.15% OF RENTED 3-5 HOUSEHOLDS WHICH ARE PART OR RENT N'HOODS BUT SHOULDN'T HAVE BEEN
	* CORRECT AT NEXT STAGE? SORRY! 
	* gen rent35 = ( inrange(flatrooms, 3, 5) & !mi(rentnet) ) // OLD >> INCORRECT!!!
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
	sa $dd\SE`YR'_hh_full, replace


	* ***************************************************
	* START FROM PERSONAL
	u $dd\SE`YR'_pers_full, clear
	
	count 
	texdoc local start_`YR' = `r(N)'	
	
	* ADD HH
	mmerge sncid using $dd\SE`YR'_hh_full

	count if _merge == 1
	texdoc local hhl_`YR' = `r(N)'	
	
	drop if _merge == 1 // no link to hh ???
	drop if _merge == 2 // hh data of not used 
	drop _merge

	* BRING BUILDID FROM FULL SNC DATASET
	
	if `YR' <= 14 { 
	
		mmerge sncid using "$od\snc2_std_pers_90_00_14_all_207_full", t(1:1) ukeep(r`YR'_buildid) // r`YR'_hhid) 

		assert _merge != 1 // no snc data ???
		drop if _merge == 2 // no SE data available
		drop _merge

		count if mi(r`YR'_buildid) // no building ID
		texdoc local mhi_`YR' = `r(N)'	
		drop if mi(r`YR'_buildid) 
	}
	
	if `YR' == 15 { 
	
		mmerge sncid using "$od\SE\SE15_hh_full", t(1:1) ukeep(egid)

		assert _merge != 1 // no snc data ???
		drop if _merge == 2 // no SE data available
		drop _merge
		
		ren egid r`YR'_buildid

		count if mi(r`YR'_buildid) | r`YR'_buildid == -9 // no building ID
		texdoc local mhi_`YR' = `r(N)'	
		drop if mi(r`YR'_buildid) | r`YR'_buildid == -9
	}
	

	* ELIGIBLE BUILDINGS, BRING COORDINATES
	ren r`YR'_buildid buildid
	mmerge buildid using $dd\ORIGINS, t(n:1) ukeep(gisid geox geoy year)

	count if _merge == 1
	texdoc local fbd_`YR' = `r(N)'	

	drop if _merge == 1  // no coords or funky building
	drop if _merge == 2 // no SE data available
	drop _merge

	order buildid gisid geox geoy year, a(hhyid)
	gen SE = 2000 + `YR'
	la var SE "Survey year"
	order SE, first

	distinct buildid gisid

	count 
	texdoc local end_`YR' = `r(N)'	

	if `YR' == 12 {
		sa $dd\SE, replace
	}
	else {
		append using $dd\SE
		sa $dd\SE, replace
	}
	
	rm $dd\SE`YR'_hh_full.dta
	rm $dd\SE`YR'_pers_full.dta
}

sa $dd\SE_dupli, replace

sort sncid SE, stable 
by sncid: keep if _n == _N 

la da "SSEP 2.0 - 'destination' SE 2012-15 data for SwissSEP 2.0"
note drop _all
note: Last changes: $S_DATE $S_TIME

compress
sa $dd\SE, replace

texdoc s c



/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsubsection{Exclusions}

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
\quad No building ID 					       & `mhi_12'                 & `mhi_13'                 & `mhi_14'                 & `mhi_15'                 \\
\quad Excluded building 				       & `fbd_12'                 & `fbd_13'                 & `fbd_14'                 & `fbd_15'                 \\
\hline
\multicolumn{1}{l}{\textbf{End}}               & `end_12'                 & `end_13'                 & `end_14'                 & `end_15'                 \\
\hline
\end{tabular}
\end{table}

Note: Additionally older records of persons that participated in more than one SE were excluded.

***/

texdoc s , cmdstrip // nodo

qui u $dd\SE_dupli, replace
duplicates report sncid
* qui rm $dd\SE_dupli.dta

texdoc s c


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Results}
Distribution of SE individuals over years:
***/

texdoc s , cmdstrip

u $dd\SE, clear
ta SE, m

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

u $dd\SE, clear
bysort gisid: keep if _n == 1
keep gisid geox geoy rent35

export delim using "$sp\DESTINATIONS.csv", delim(",")  replace

keep if rent35

export delim using "$sp\DESTINATIONS_RENT.csv", delim(",")  replace

texdoc s c

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Limitations}
\begin{enumerate}

	\item Major limitation is that, compared to SEP 1.0, there is no way to define \textbf{head of the household} - 
		all respondents (see exclusions) of the SE are then used, irrespectively of their position in household.
		
	\item 2014 SE dataset is \textbf{missing infomration on \textit{'Sozioprofessionelle Kategorie'}} (variable \texttt{sopc}).  
		It has been also signalled by BfS that this variable was of poor quality in 2010-2013 years. 
		Therefore, it is not possible to identify individuals in manual and uskilled occupations in the same way as during 
		construction of original index. That was mitigated by using the 
		\href{http://www.ilo.org/public/english/bureau/stat/isco/isco08/index.htm}{\textbf{ISCO-08 codes}} of occupations 
		to define manual and uskilled workers and farmers.
		Individuals whose occupations belong to one of the major groups 7, 8 \& 9 (for manual and unskilled) and 6 (farmers) were selected.\footnote{Additionally, 
		sensitivity analyses were done with more strict selection of ISCO codes (major groups 8 \& 9 only) as well as 	
		by converting ISCO-08 codes to \href{http://www.harryganzeboom.nl/isco08/qa-isei-08.htm}{\textbf{ISEI-08 codes}} 
		to obtain continuous measure of 'International Socio-Economic Index of occupational status'and calculating summary of these vlaues in n'hood} 				
		Note that occupation codes are available only for people in \textbf{paid employment} so the denomintor 
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
		(1.5 version as compared to 1.0 vesrsion in the previous edition).
	
	\item Network analyses were done using ArcGIS 10.5 (previously - ArcGIS 10.2).
	
	\item Network analyses took all SNC buildings as \texttt{ORIGINS} and calculated 
		50 closest \texttt{DESTINATIONS} from the SE dataset.
		\footnote{In that logic, the n'hood is either constructed from one SE household and 49 SE neighbours 
		OR 50 SE neighbours if the n'hood centre is not the SE household}		
	
	\item Treshold for n'hood construction was set up to be maximum 20 km (measured along the road network).\footnote{That was based 
		on preliminary checks with data, results of previous analyses \& common sense rationale (hard to say it's n'hood if households are more than 20km apart\ldots}
	
	\item As in the 1.0 index, separate n'hoods were created using rented, 3-5 bedroom flats as \texttt{DESTINATIONS}. 

	
\end{enumerate}
***/

texdoc s , nolog nodo 

* !!! ATTENTION !!! 
* !!! UNZIP '$od\neighb.zip' TO ORIG DATA FOLDER BEFORE ATTEMPTING THAT !!! 
* unzipfile $od\neighb.zip, replace
* (same) backup data stored on SNC drive Y:\SNC\SSEP\2_0_connectivity.zip

forv PART = 1/6 {
	* import delim using "$od\neighb\SE_101_neighb_20km_`PART'.txt", varn(1) clear 
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
		sa $dd\NEIGHB, replace
	}
	else {
		append using $dd\NEIGHB
		sa $dd\NEIGHB, replace
	}

}

* RENT
forv PART = 1/6 {
	* import delim using "$od\neighb\SE_101_neighb_rent_20km_`PART'.txt", varn(1) clear 
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
		sa $dd\NEIGHB_RENT, replace
	}
	else {
		append using $dd\NEIGHB_RENT
		sa $dd\NEIGHB_RENT, replace
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
u $dd\NEIGHB, clear
sort gisid_orig destinationrank
by gisid_orig: keep if _n == 1

texdoc s c 

texdoc s , nocmdlog // nodo 

ta b_maxdest, m 

texdoc s c 

/*
* landolt 30
list if gisid_orig == 392823

* legitimate no neighb <> Ufenau Island, Lake Zurich <> 47.216893093 8.778432040 
list if gisid_orig == 1182865

* legitimate no neighb <> Next to Thunersee,  <> 46.659942070 7.792093576 
list if gisid_orig == 644959

* 89 SE households in one building
list if gisid_orig == 94802
*/

/***
The two cases of buildings with no neighbours are legitimate and really have no neighbours on the (highway restricted) road network: 
	one of the buildings is located on \href{https://goo.gl/maps/L5sLmrMXZap}{Ufenau Island}, Lake Zurich; 
	and the other - right next to highway,  \href{https://goo.gl/maps/fxPCBS5TmEQ2}{on the shore of Thunersee}. 
	These two buildings were excluded from the analyses and have no index. 
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

u $dd\NEIGHB, clear
ren destinationrank dest_rank_bb
drop b_totdist b_maxdest part 

* BRING SE DATA
mmerge gisid_dest using $dd\SE, ukeep(sncid ppr num_ocu? mis_ocu_isco den_ocu num_edu) umatch(gisid) 
assert _merge == 3
drop _merge

* TWO EXCLUSIONS >> SEE ABOVE
drop if inlist(gisid_orig, 644959, 1182865)

* 50 HOUSEHOLDS + !ALL HOUSEHOLDS FROM LAST BUILDING!
sort gisid_orig dest_rank_bb gisid_dest, stable
by   gisid_orig (dest_rank_bb gisid_dest): gen dest_rank_hh = _n

by   gisid_orig:  gen temp = gisid_dest if dest_rank_hh ==  50
by   gisid_orig: egen h_50 = max(temp)

* gen exclu = 1 if dest_rank_hh > 50 & gisid_dest != h_50
drop if dest_rank_hh > 50 & gisid_dest != h_50
drop h_50 temp 

* br if inlist(gisid_orig, 32, 23181)

* TOTAL HOUSEHOLDS
by gisid_orig: egen tot_hh = max(dest_rank_hh)

* TOTAL BUILDINGS 
sort gisid_orig gisid_dest, stable

by gisid_orig gisid_dest: gen tot_bb = _n == 1 
by gisid_orig: replace tot_bb = sum(tot_bb)
by gisid_orig: replace tot_bb = tot_bb[_N] 

* FURTHEST BUILDING DISTANCE
by gisid_orig: egen max_dist = max(total_length)
ren total_length ind_dist

* br if inlist(gisid_orig, 94802)

sort gisid_orig dest_rank_bb gisid_dest, stable

la da "SSEP 2.0 - household n'hood structure"
note drop _all
note: Last changes: $S_DATE $S_TIME

compress
sa $dd\NEIGHB_PREP, replace

* u $dd\NEIGHB_PREP, clear

* AGGREGATING
by gisid_orig: egen tot_ocu = total(den_ocu)
by gisid_orig: egen mis_ocu = total(mis_ocu_isco)
by gisid_orig: egen ocu1 = total(num_ocu1)
by gisid_orig: egen ocu2 = total(num_ocu2)
by gisid_orig: egen ocu3 = total(num_ocu3)
by gisid_orig: egen ocu4p = mean(num_ocu4) // ! achtung >> not counts !!

* edu0 = tot_hh
by gisid_orig: egen edu1 = total(num_edu)
by gisid_orig: egen ppr1 = mean(ppr) // ! achtung >> not counts !!

keep if dest_rank_hh == 1 

drop gisid_dest dest_rank_bb ind_dist num_ocu? den_ocu num_edu ppr dest_rank_hh

gen ocu1p = ocu1/tot_ocu
gen ocu2p = ocu2/tot_ocu
gen ocu3p = ocu3/tot_ocu
gen mis_ocu_pr = mis_ocu / (tot_ocu + mis_ocu)
drop ocu1 ocu2 ocu3 

univar tot_hh
univar tot_ocu			// should not have small numbers o_O
* br if tot_ocu <= 10
univar ocu1p-ocu3p 		// should be nicely <= 1 :>
univar mis_ocu_pr 		// few places with half n'hood missing; but median is 7% :>
* br if mis_ocu_pr > 0.5

gen edu1p = edu1/tot_hh
univar edu1p
drop edu1

* drop mis_ocu_isco mis_ocu tot_ocu 

order gisid_orig tot_hh tot_bb max_dist ocu1p ocu2p ocu3p ocu4p tot_ocu mis_ocu mis_ocu_pr edu1p ppr1 

la var tot_hh		"Total no of households in n'hood"
la var ocu1p 		"Percent low occupation 1"
la var ocu2p 		"Percent low occupation 2"
la var ocu3p 		"Percent low occupation 3"
la var ocu4p 		"Low occupation - mean ISEI"
la var edu1p 		"Percent low education"
la var ppr1			"Mean no of people per room"

la var mis_ocu		"Individuals with missing ISCO"
la var mis_ocu_pr	"Share with missing ISCO"
la var tot_ocu		"Denominator for ISCO"

la var tot_bb		"Total no of buildings in n'hood"
la var max_dist		"Distance to furthest building"

la da "SSEP 2.0 - household n'hood aggregated stats"
note drop _all
note: Last changes: $S_DATE $S_TIME

compress
sa $dd\NEIGHB_PREP_AGG, replace

texdoc s c 


/***
Number of buildings (within 20km):
***/
texdoc s , cmdstrip 

u $dd\NEIGHB_PREP_AGG, clear

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
Average distance [in meters] to the building where furthest SE household is located (within 20km):
***/

texdoc s , cmdstrip 

univar max_dist, dec(0) 
* su max_dist, d f

texdoc s c 


texdoc s , nolog  nodo 

u $dd\NEIGHB_RENT, clear
sort gisid_orig destinationrank
by gisid_orig: keep if _n == 1

ta b_maxdest, m 

texdoc s c 


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Results - households, rent}
As expected, results are slightly worse when we limit network analyses to 3-5 bedroom rented flats only. \\
\\
***/

texdoc s , nolog // nodo

u $dd\NEIGHB_RENT, clear
ren destinationrank dest_rank_bb_rnt
drop b_totdist b_maxdest part 

* BRING SE DATA
mmerge gisid_dest using $dd\SE, ukeep(sncid rent35 rentnet) umatch(gisid) 
assert _merge != 1
keep if _merge == 3
drop _merge

* TWO EXCLUSIONS >> SEE ABOVE
drop if inlist(gisid_orig, 644959, 1182865)

* EXCLUDING NON RENTED
drop if !rent35
drop rent35

* ERROR >> SE SE DATA PREP ABOVE !!!
drop if mi(rentnet)

* 50 HOUSEHOLDS + ALL HOUSEHOLDS FROM LAST BUILDING
sort gisid_orig dest_rank_bb gisid_dest, stable
by   gisid_orig (dest_rank_bb gisid_dest): gen dest_rank_hh_rnt = _n

by   gisid_orig:  gen temp = gisid_dest if dest_rank_hh_rnt ==  50
by   gisid_orig: egen h_50 = max(temp)

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
sa $dd\NEIGHB_RENT_PREP, replace

* AGGREGATING
by gisid_orig: egen rent = mean(rentnet) 

keep if dest_rank_hh_rnt == 1 

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
sa $dd\NEIGHB_RENT_PREP_AGG, replace

texdoc s c 


/***
Number of rented buildings (within 20km):
***/

texdoc s , cmdstrip 

u $dd\NEIGHB_RENT_PREP_AGG, clear

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

Combined waves I, II and III of the Swiss Household Panel (SHP) dataset were used to validate the index

\begin{enumerate}

	\item SHP households were included if: 

	\begin{enumerate}	
		\item they provided questionarie in 2013 
		\item had complete information regarding the address
		\item address was sucessflly geocoded\footnote{Geocoding 
			was primarlily done using Google Maps; unsecessful attempts were checked against HERE maps and map.geo.admin.ch.}
	\end{enumerate}	
		
	\item Same variables that were used in Table 2 of original publication are extracted
		\footnote{Note that 'Savings min. 500 SFrs monthly' has changed - it used to refer to '100 CHF'}	
		
	\item Each geocoded household was spatially linked to the colsest building from the ORIGINS dataset 
\end{enumerate}
***/

texdoc s , nolog // nodo

* 2013 ONLY 
u idhous13 filter13 nbpers13 stathh13 i13eqon h13i20ac h13i20ac h13i21ac h13i22 h13i23 h13i76 h13i50 h13i50 h13i51 using ///
	"$od\SHP\SHP-Data-W1-W17-STATA\W15_2013\shp13_h_user.dta", clear

ta filter13, m 
ta stathh13, m 
count if !stathh13
drop  if !stathh13
drop stathh13 // filter13

* ********
* YEARLY HOUSEHOLD INCOME EQUIVALISED, OECD, NET
mvdecode i13eqon, mv(-8/-1)
univar i13eqon, d(0)


* ********
* SAVINGS MIN. 500 SFRS MONTHLY
fre h13i20ac
recode h13i20ac (-2=-1)
la de H13I20AC -1 "no answer / doesn't know", modify
ta h13i20ac, m

* REASON WHY NO SAVINGS MIN. 500 SFRS MONTHLY
fre h13i20ac
ta  h13i20ac h13i20ac, m
recode h13i20ac (-2=-1)
la de H13I21AC -1 "no answer / doesn't know", modify
ta h13i20ac if h13i20ac == 2, m
ta h13i20ac, m


* ********
* SAVINGS INTO 3RD PILLAR
fre h13i22
recode h13i22 (-2=-1)
la de H13I22N -1 "no answer / doesn't know", modify
ta h13i22, m

* REASON WHY NO SAVINGS INTO 3RD PILLAR
fre h13i23
ta  h13i23 h13i22, m
recode h13i23 (-2=-1)
la de H13I23 -1 "no answer / doesn't know", modify
ta h13i23 if h13i22 == 2, m
ta h13i23, m


* ********
* FINANCIAL HELP: HEALTH INSURANCE
fre h13i76a
recode h13i76a (-3=-1)
recode h13i76a (-2=-1)
la de H13I76A -1 "inaplicable / no answer / doesn't know", modify
ta h13i76a, m


* ********
* ASSESSMENT OF INCOME AND EXPENSES
fre h13i50
recode h13i50 (-3=-1)
recode h13i50 (-2=-1)
la de H13I50 -1 "inaplicable / no answer / doesn't know", modify
ta h13i50, m


* ********
* FINANCIAL SITUATION MANAGEABLE
fre h13i51
mvdecode h13i51, mv(-8/-1)
ta h13i50, m
univar h13i51


* ********
* GEOCODES 
mmerge idhous13 using $dd\SHP_adresses_13_FINAL, t(1:1) ukeep(latitude longitude)
drop if _merge == 2
recode _merge (1=0) (3=1)
ren _merge geocoded 
la de geocoded 0 "no" 1 "yes"
la val geocoded geocoded
la var geocoded "Geocoding status" 


* ********
* NEAR of ORIGINS >> FOR SEP LINKAGE 
preserve
	import delim using "$od\SHP\SHP_near_ORIGINS_linked.csv", varn(1) clear
	keep idhous13 gisid
	compress
	sa "$dd\SHP_near_ORIGINS", replace
restore

mmerge idhous13 using $dd\SHP_near_ORIGINS, t(1:1) 
assert _merge != 2
ta _merge geocoded, m 
drop _merge

* ********
note drop _all
la da "SSEP 2.0 - SHP '13 data for validation"
note: Last changes: $S_DATE $S_TIME
compress
sa $dd\SHP, replace

/*
keep if geocoded
keep idhous13 latitude longitude
export delim using "$sp\SHP_EXTRACT.csv", delim(",")  replace
*/

texdoc s c 


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Variables}
***/

texdoc s , cmdstrip  

u $dd\SHP, clear
drop latitude longitude geocoded gisid
d

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Surveys \& geocoding status}
***/

texdoc s , cmdstrip  

u $dd\SHP, clear
ta filter13 geocoded, m row col nokey 

texdoc s c 


/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newpage
\subsection{SNC - mortality}
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Dataset - SNC complete}

Firstly, association of Swiss-SEP with mortality will be assessed using two models based on complete SNC: 
'age \& sex' and 'semi adjusted'  
(additionally taking into account: nationality, civil status, language region \& level of urbanization). Setup for the analyses in this scenario: 
\begin{enumerate}

	\item Individuals who are recorded in (at least one of the) 2012, 2013 or 2014 Censuses are included
	\item Individuals below age 30 on the 1.1.2012 are excluded
	\item Date of entry is either 1.1.2012 or earliest census if individual was not recorderd in 2012
	\item Individuals who died on or before 12.31.2011 are excluded (unless the death was cancelled in the dataset)
	\item For individuals having information on one of the covariates recorded inseveral censuses the latest one is used
	\item Individuals with missing civil status were excluded
	\item Rhaeto-Romansch language region was merged to German
	\item Individuals with no link to the index were excluded
	
\end{enumerate}

***/

texdoc s , nolog // nodo   

u "$od\snc2_std_pers_90_00_14_all_207_full", clear 

* VARS NOT NEEDED
drop v9* v0* *_geox *_geoy *_flatid *_hhid shs92 *_hhpers *_dch_arriv *_permit *_nat *_dseparation *_dcivil *_ddiv_dod_p *_dmar *_civil_old *_canton dswiss zarflag zar natbirth *_comm2006 *_comm *_dmove *_canton2006 *_lang2006 *_urban2006 dis_conc1_icd8* dis_conc2_icd8* dis_init_icd8* dis_init_icd10* dis_cons_icd10* dis_conc1_icd10* dis_conc2_icd10*  *_mo_flag
drop r10_* se10_flag r11_commyears r11_commsincebirth m_nat_bin

* NO IMPUTED FOR THE MOMENT 
drop imputed *_imputed 

* DROPPING: link == 9 >> 'Only census 1990'
drop if inlist(link, 9)

* KEEPING ONLY THOSE AVAILABLE IN CENSUSES 2012+
keep if r11_pe_flag | r12_pe_flag | r13_pe_flag | r14_pe_flag
* ta last_census_seen, m 
drop r??_pe_flag

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

	gen `VAR' = r14_`VAR' if 	!mi(r14_`VAR')
	replace `VAR' = r13_`VAR' if mi(r14_`VAR') & !mi(r13_`VAR')
	replace `VAR' = r12_`VAR' if mi(r14_`VAR') &  mi(r13_`VAR') & !mi(r12_`VAR')
	replace `VAR' = r11_`VAR' if mi(r14_`VAR') &  mi(r13_`VAR') &  mi(r12_`VAR') & !mi(r11_`VAR')
	
	if "`VAR'" !=  "buildid" {
		la val `VAR' `VAR'_l
	}
	drop r??_`VAR'
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

note drop _all
la da "SSEP 2.0 - full SNC 2012-2014 data for mortality analyses"

note: 			SNC: people 30 and over; linked to building with index; covariates calculated using latest available info.
note civil: 	Missing data excluded
note lang: 		Rhaeto-romansch to German langreg 
note: 			Last changes: $S_DATE $S_TIME
compress
sa $dd\SNC_ALL, replace

texdoc s c 

texdoc s , nolog

u $dd\SNC_ALL, clear

texdoc s c 

texdoc s , cmdstrip

ta last_census_seen, m
* tabstat d_*, statistics( sum ) labelwidth(8) varwidth(18) columns(statistics) longstub format(%9.0fc)
distinct mortid gisid

texdoc s c 

/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\subsubsection{Dataset - SNC SE}

Secondly, only individuals who participated in one of the SE surveys (2012-14) will be used in order to develop 'fully adjusted' model 
taking into account additionally education and occupation (note the details provided in the SE section!).

***/

texdoc s , nolog // nodo   

u $dd\SNC_ALL, clear
drop recid yod m_civil geox geoy year dupli hec

* LIMIT TO SE DATA
mmerge sncid using $dd\SE, t(1:1) ukeep(educ_agg educ_curr occup_isco den_ocu SE)
/*
ta _merge se11_flag, m 
ta _merge se12_flag, m 
ta _merge se13_flag, m 
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
replace ocu = 4 if den_ocu == 0 
drop occup_isco den_ocu 

la de ocu 1 "High occup" 2 "Medium occup" 3 "Low occup " 4 "Not in paid employ" 5 "Missing", modify 

* UPDATE TO LATEST SURVEY ???
replace dstart = mdy(1, 1, SE) if dstart < mdy(1, 1, SE)

la da "SSEP 2.0 - SNC 2012-2014 data for mortality analyses - SE overlap"

note: 			Including people from SE used to calculate index
note: 			Last changes: $S_DATE $S_TIME
compress
sa $dd\SNC_SE, replace

texdoc s c 


texdoc s , cmdstrip

u $dd\SNC_SE, clear

ta SE, m 
* tabstat d_*, statistics( sum ) labelwidth(8) varwidth(18) columns(statistics) longstub format(%9.0fc)

texdoc s c 

/***
\end{document}
***/
