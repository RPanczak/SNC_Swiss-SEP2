* qui do C:\projects\SNC_Swiss-SEP2\Stata\00_run_first.do  

/*
* PREPARATION
texdoc do C:\projects\SNC_Swiss-SEP2\analyses\02_data_prep.do

* COMPILE TEX 
! pdflatex -shell-escape -output-directory=$td $td/report_sep2_prep
! pdflatex -shell-escape -output-directory=$td $td/report_sep2_prep
	
* RENAME COMPILED FILE WITH TODAY'S DATE
local date : di %tdCCYY-NN-DD daily("$S_DATE", "DMY")
* di "`date'"
! COPY C:\projects\SNC_Swiss-SEP2\analyses\report_sep2_prep.pdf C:\projects\SNC_Swiss-SEP2\analyses\report_sep2_prep_`date'.pdf
! COPY C:\projects\SNC_Swiss-SEP2\analyses\report_sep2_prep.pdf C:\projects\SNC_Swiss-SEP2\FINAL\report_sep2_prep_`date'.pdf
! RM C:\projects\SNC_Swiss-SEP2\analyses\report_sep2_prep.*

* ANALYSIS
texdoc do C:\projects\SNC_Swiss-SEP2\analyses\03_data_analysis.do

* COMPILE TEX 
! pdflatex -shell-escape -output-directory=$td $td/report_sep2_analysis 
! pdflatex -shell-escape -output-directory=$td $td/report_sep2_analysis
	
* RENAME COMPILED FILE WITH TODAY'S DATE
local date : di %tdCCYY-NN-DD daily("$S_DATE", "DMY")
* di "`date'"
! COPY C:\projects\SNC_Swiss-SEP2\analyses\report_sep2_analysis.pdf C:\projects\SNC_Swiss-SEP2\analyses\report_sep2_analysis_`date'.pdf
! COPY C:\projects\SNC_Swiss-SEP2\analyses\report_sep2_analysis.pdf C:\projects\SNC_Swiss-SEP2\analyses\FINAL\report_sep2_analysis_`date'.pdf
*! RM C:\projects\SNC_Swiss-SEP2\analyses\report_sep2_analysis.*
*/


* COMBINED
texdoc do C:\projects\SNC_Swiss-SEP2\analyses\SEP2_supplement.do

* COMPILE TEX 
! pdflatex -shell-escape -output-directory=$td $td/SEP2_supplement 
! pdflatex -shell-escape -output-directory=$td $td/SEP2_supplement
	
* RENAME COMPILED FILE WITH TODAY'S DATE
local date : di %tdCCYY-NN-DD daily("$S_DATE", "DMY")
* di "`date'"
! COPY C:\projects\SNC_Swiss-SEP2\analyses\SEP2_supplement.pdf C:\projects\SNC_Swiss-SEP2\analyses\SEP2_supplement_`date'.pdf
! COPY C:\projects\SNC_Swiss-SEP2\analyses\SEP2_supplement.pdf C:\projects\SNC_Swiss-SEP2\analyses\FINAL\SEP2_supplement_`date'.pdf
*! RM C:\projects\SNC_Swiss-SEP2\analyses\SEP2_supplement.*

/*
local acroread = cond(c(os)=="Unix", "acroread", "Acrobat")
! start `acroread' $td/SEP2_supplement_`date'.pdf
*/

