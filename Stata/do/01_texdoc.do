* qui do H:\RP\projects\sep2\Stata\do\00_run_first.do

texdoc do H:\RP\projects\sep2\Stata\do\02_data_prep_05.do

* COMPILE TEX 
! pdflatex -shell-escape -output-directory=$td $td/report_sep2_01_05 
! pdflatex -shell-escape -output-directory=$td $td/report_sep2_01_05
	
* RENAME COMPILED FILE WITH TODAY'S DATE
local date = subinstr("$S_DATE", " ", "", .)
* di "`date'"
! COPY $td\report_sep2_01_05.pdf $dd\FINAL\report_sep2_final_`date'.pdf

*
local acroread = cond(c(os)=="Unix", "acroread", "Acrobat")
! start `acroread' $dd\FINAL\report_sep2_final_`date'.pdf



