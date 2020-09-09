* qui do C:\projects\SNC_Swiss-SEP2\Stata\do\00_run_first.do

texdoc do C:\projects\SNC_Swiss-SEP2\Stata\do\02_data_prep.do

* COMPILE TEX 
! pdflatex -shell-escape -output-directory=$td $td/report_sep2 
! pdflatex -shell-escape -output-directory=$td $td/report_sep2
	
* RENAME COMPILED FILE WITH TODAY'S DATE
local date = subinstr("$S_DATE", " ", "", .)
* di "`date'"
! COPY $td\report_sep2.pdf $dd\FINAL\report_sep2_`date'.pdf

*
local acroread = cond(c(os)=="Unix", "acroread", "Acrobat")
! start `acroread' $dd\FINAL\report_sep2_`date'.pdf



