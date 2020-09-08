* GENERAL PROJECT SETTINGS

/* SET:
1. global np=...	=> the name of project in double quotes!
2. global pp=...	=> the path to of project omitting the drive letter
*/

* NAME OF PROJECT
global np = "SNC_Swiss-SEP2"

if "`c(os)'" == "Windows" {

	* PATH TO NEW PROJECT HERE WITHOUT DRIVE LETTER
	global pp="C:\projects\SNC_Swiss-SEP2"


	* PATH SETTINGS
	global dd  = "$pp\stata\data"
	global dod = "$pp\stata\do"
	global gd  = "$pp\stata\graphres"
	global ld  = "$pp\stata\log"
	global od  = "$pp\stata\orig"
	global td  = "$pp\stata\textres"
	global sp  = "$pp\stata\gis"
	global gis = "H:\RP\projects\sep2\gis"
	global T =   "T:\SNC"

	cd "$pp\Stata"
}

else if "`c(os)'" == "Unix"{

	global pp="/home/rdk/Code/..."

	* general project path settings
	global dd="$pp/Stata/data"
	global dod="$pp/Stata/do"
	global gd="$pp/Stata/graphres"
	global ld="$pp/Stata/log"
	global od="$pp/Stata/orig"
	global td="$pp/Stata/textres"

	cd $pp/Stata
}

noisily di in red "Settings ready for: $np project"
