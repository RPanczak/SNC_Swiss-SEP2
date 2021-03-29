u "data-raw/gwr_extract_210225/gwr_extract_210225", clear
isid egid_snc
rename egid_snc egid
drop gbauj gabbj gastw ggdenr

/*
list if egid == 899170556 
* Château de Rolle https://goo.gl/maps/pUK1QCa33KL2

list if egid == 899909336 
* Old windmill Brüngger Wyla https://goo.gl/maps/SRxGAKyF5982

list if egid == 898986979 
* Eglise Saint Boniface https://goo.gl/maps/k23r9ZEspXr 
* different?

list if egid == 709548512 
* Camping Arolla https://goo.gl/maps/7obNv6U2ZHm6aAhy5 

list if egid == 899544547 
* Gefängnis Bässlergut https://goo.gl/maps/nu3ydKtJENK2

list if egid == 890985601 
* César Ritz hotel school https://goo.gl/maps/G4squepw5pQ2
*/

ren gkode geox_new
ren gkodn geoy_new

ta gstat, m
/*
1001	Gebäude projektiert
1002	Bewilligt
1003	Gebäude im Bau
1004	Gebäude bestehend
1005	Nicht nutzbar
1007	Gebäude abgebrochen
1008	Nicht realisiert
*/

keep if gstat == 1004
drop gstat

ta gkat, m

/*
1010	Provisorische Unterkunft
1020	Gebäude ausschließlich für Wohnnutzung
1030	Wohngebäude mit Nebennutzung
1040	Gebäude mit teilweiser Wohnnutzung
1060	Gebäude ohne Wohnnutzung
1080	Sonderbau
*/

keep if inrange(gkat, 1020, 1040)

ta gklas, m

/*
1110	Gebäude mit einer Wohnung
1121	Gebäude mit zwei  Wohnungen
1122	Gebäude mit drei oder mehr Wohnungen
1130	Wohngebäude für Gemeinschaften
1211	Hotelgebäude
1212	Andere Gebäude für kurzfristige Beherbergung
1220	Bürogebäude
1230	Gross-und Einzelhandelsgebäude
1231	Restaurants und Bars in Gebäuden ohne Wohnnutzung
1241	Gebäude des Verkehrs- und Nachrichtenswesens ohne Garagen
1242	Garagengebäude
1251	Industriegebäude
1252	Behälter, Silos und Lagergebäude
1261	Gebäude für Kultur- und Freizeitzwecke
1262	Museen und Bibliotheken
1263	Schul- und Hochschulgebäude, Forschungseinrichtungen
1264	Krankenhäuser und Facheinrichtungen des Gesundheitswesens
1265	Sporthallen
1271	Landwirtschaftliche Betriebsgebäude
1272	Kirchen und sonstige Kultgebäude
1273	Denkmäler oder unter Denkmalschutz stehende Bauwerke
1274	Sonstige Hochbauten, anderweitig nicht genannt
1275	Andere Gebäude für die kollektive Unterkunft
1276	Gebäude für die Tierhaltung
1277	Gebäude für den Pflanzenbau
1278	Andere landwirtschaftliche Gebäude
*/

drop if mi(gklas)

ta gbaup, m

drop if mi(gbaup)

/*
8011	Vor 1919
8012	1919-1945
8013	1946-1960
8014	1961-1970
8015	1971-1980
8016	1981-1985
8017	1986-1990
8018	1991-1995
8019	1996-2000
8020	2001-2005
8021	2006-2010
8022	2011-2015
8023	Nach 2015
*/

gen buildper = (gbaup >= 8020)

compress
note drop _all
la da "Updated GWR dataset"
sa "data/gwr_extract_210225/gwr_extract_210225", replace
