/***
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