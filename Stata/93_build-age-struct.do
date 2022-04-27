/***
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%\newpage
%\subsection{All cause mortality - exploring  different building age structures of SEP 3}
***/

texdoc s , nolog  nodo   

* alternative solutions of 3 using n'hood age structure
mmerge buildid using FINAL/DTA/ssep3_user_snc, t(n:1) uk(ssep3_d_?)
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