# Swiss-SEP2

Development and validation of new release of Swiss-SEP index. Code and supplemental data for publication:  

> Panczak R, Berlin C, Voorpostel M, Zwahlen M, Egger M, The Swiss Neighbourhood Index of Socioeconomic Position: Update and Re-validation (2023) *Swiss Med Wkly* 153:40028. doi: [10.57187/smw.2023.40028](https://doi.org/10.57187/smw.2023.40028)

**Access to the index** via  [BORIS Portal](https://doi.org/10.48620/110) or [OSF project](https://osf.io/r8hz7/).  

Based on and extending the original publication:

> Panczak R, Galobardes B, Voorpostel M, et al A Swiss neighbourhood index of socioeconomic position: development and association with mortality (2012) *J Epidemiol Community Health* 66:1129-1136. doi: [10.1136/jech-2011-200699](http://dx.doi.org/10.1136/jech-2011-200699)

Updated using 2012-2015 [Structural Survey](https://www.bfs.admin.ch/bfs/en/home/statistics/population/surveys/se.html) data linked to [Federal Register of Buildings and Dwellings](https://www.bfs.admin.ch/bfs/en/home/registers/federal-register-buildings-dwellings.html) and updated definitions of n'hoods. 

**Datasets** needed to reproduce the results:  

- folder `Python` stores six scripts used to calculate and export datasets of neighbourhood connectivity needed for further analyses - ArGIS software (version 10.5) with Network Analyst extension is needed to run these scripts
- folders `data-raw` and `data` contain ancillary datasets that can be shared openly; these mostly include various geographic boundaries  
- main datasets used in the analyses can be obtained from Swiss Federal Statistical Office  

**Code** needed to reproduce the results:  

- `Stata/00_run_first.do` file need to be updated specifying correct paths    
- `Stata/01_texdoc.do` file also needs path updates and can be used to process `analyses/SEP2_supplement.do` Stata (version 15) script using the [`texdoc`](http://repec.sowi.unibe.ch/stata/texdoc/) command; running this script will generate all main outputs of the paper (figures and tables generated ar in the same folder) as well pdf report with all supplementary information   
- the script runs (or points to) a set of five helper R scripts in `R` folder that are used for various data conversions, data management, spatial operations as well as generation of table 1 and the main map  

Code archived on [![DOI](https://zenodo.org/badge/293476145.svg)](https://zenodo.org/badge/latestdoi/293476145)  

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
