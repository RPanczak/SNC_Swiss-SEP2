* qui do C:\projects\SNC_Swiss-SEP2\Stata\00_run_first.do


* PREPARATION
texdoc do C:\projects\SNC_Swiss-SEP2\Stata\02_data_prep.do

* COMPILE TEX 
! pdflatex -shell-escape -output-directory=$td $td\report_sep2_prep
! pdflatex -shell-escape -output-directory=$td $td\report_sep2_prep
	
* RENAME COMPILED FILE WITH TODAY'S DATE
local date : di %tdCCYY-NN-DD daily("$S_DATE", "DMY")
* di "`date'"
! COPY $td\report_sep2_prep.pdf $td\report_sep2_prep_`date'.pdf
! COPY $td\report_sep2_prep.pdf $dd\FINAL\report_sep2_prep_`date'.pdf
! RM $td\report_sep2_prep.*

/*
local acroread = cond(c(os)=="Unix", "acroread", "Acrobat")
! start `acroread' $td\report_sep2_prep_`date'.pdf
*/

* ANALYSIS
texdoc do C:\projects\SNC_Swiss-SEP2\Stata\do\03_data_analysis.do

* COMPILE TEX 
! pdflatex -shell-escape -output-directory=$td $td/report_sep2_analysis 
! pdflatex -shell-escape -output-directory=$td $td/report_sep2_analysis
	
* RENAME COMPILED FILE WITH TODAY'S DATE
local date : di %tdCCYY-NN-DD daily("$S_DATE", "DMY")
* di "`date'"
! COPY $td\report_sep2_analysis.pdf $td\report_sep2_analysis_`date'.pdf
! COPY $td\report_sep2_analysis.pdf $dd\FINAL\report_sep2_analysis_`date'.pdf
! RM $td\report_sep2_analysis.*

/*
local acroread = cond(c(os)=="Unix", "acroread", "Acrobat")
! start `acroread' $td\report_sep2_analysis_`date'.pdf
*/


