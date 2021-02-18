* GENERAL PROJECT SETTINGS

/* SET:
1. global np=...	=> the name of project in double quotes!
2. global pp=...	=> the path to of project omitting the drive letter
*/

* rscript 
global RSCRIPT_PATH "C:/Program Files/R/R-4.0.3/bin/Rscript.exe"

* NAME OF PROJECT
global np = "SNC_Swiss-SEP2"

if "`c(os)'" == "Windows" {

	* PATH TO NEW PROJECT 
	global pp="C:/projects/SNC_Swiss-SEP2"

	* PATH SETTINGS
	global td  = "$pp/analyses"
	
	* CORE files
	global co  = "C:/projects/SNC_core"

	cd "$pp"
}

else if "`c(os)'" == "Unix"{

	global pp="/home/rdk/Code/..."

	* general project path settings
	global dd  = "$pp\data"
	global dod = "$pp\Stata"
	global od  = "$pp\data-raw"
	global td  = "$pp\analyses"

	cd $pp/Stata
}

set seed 12345

* set scheme plottig 
set scheme plotplain

noisily di in red "Settings ready for: $np project"
