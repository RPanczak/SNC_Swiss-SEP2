*! version 1.0  13.07.2017
/*
Defines value labels for ISCO-08 4-digit occupational codes

derived from
https://ideas.repec.org/c/boc/bocode/s425802.html

Use "la val `varlist' isko" to assign value labels to a variable
*/

program define iskolab
	version 7

	#delimit ;
	capture label define isko
		 100 "Commissioned armed forces officers"
		 110 "Commissioned armed forces officers"
		 200 "Non-commissioned armed forces officers"
		 210 "Non-commissioned armed forces officers"
		 300 "Armed forces occupations, other ranks"
		 310 "Armed forces occupations, other ranks"
		1000 "Managers"
		1100 "Chief executives, senior officials and legislators"
		1110 "Legislators and senior officials"
		1111 "Legislators"
		1112 "Senior government officials"
		1113 "Traditional chiefs and heads of village"
		1114 "Senior officials of special-interest organizations"
		1120 "Managing directors and chief executives"
		1200 "Administrative and commercial managers"
		1210 "Business services and administration managers"
		1211 "Finance managers"
		1212 "Human resource managers"
		1213 "Policy and planning managers"
		1219 "Business services and administration managers nec"
		1220 "Sales, marketing and development managers"
		1221 "Sales and marketing managers"
		1222 "Advertising and public relations managers"
		1223 "Research and development managers"
		1300 "Production and specialized services managers"
		1310 "Production managers in agriculture, forestry and fisheries"
		1311 "Agricultural and forestry production managers"
		1312 "Aquaculture and fisheries production managers"
		1320 "Manufacture, mining, construction, distribution managers"
		1321 "Manufacturing managers"
		1322 "Mining managers"
		1323 "Construction managers"
		1324 "Supply, distribution and related managers"
		1330 "ICT service managers"
		1340 "Professional services managers"
		1341 "Child care services managers"
		1342 "Health services managers"
		1343 "Aged care services managers"
		1344 "Social welfare managers"
		1345 "Education managers"
		1346 "Financial and insurance services branch managers"
		1349 "Professional services managers nec"
		1400 "Hospitality, retail and other services managers"
		1410 "Hotel and restaurant managers"
		1411 "Hotel managers"
		1412 "Restaurant managers"
		1420 "Retail and wholesale trade managers"
		1430 "Other services managers"
		1431 "Sports, recreation and cultural centre managers"
		1439 "Services managers nec"
		2000 "Professionals"
		2100 "Science and engineering professionals"
		2110 "Physical and earth science professionals"
		2111 "Physicists and astronomers"
		2112 "Meteorologists"
		2113 "Chemists"
		2114 "Geologists and geophysicists"
		2120 "Mathematicians, actuaries and statisticians"
		2130 "Life science professionals"
		2131 "Biologists, botanists, zoologists and related professionals"
		2132 "Farming, forestry and fisheries advisers"
		2133 "Environmental protection professionals"
		2140 "Engineering professionals [excluding electrotechnology]"
		2141 "Industrial and production engineers"
		2142 "Civil engineers"
		2143 "Environmental engineers"
		2144 "Mechanical engineers"
		2145 "Chemical engineers"
		2146 "Mining engineers, metallurgists and related professionals"
		2149 "Engineering professionals nec"
		2150 "Electrotechnology engineers"
		2151 "Electrical engineers"
		2152 "Electronics engineers"
		2153 "Telecommunications engineers"
		2160 "Architects, planners, surveyors and designers"
		2161 "Building architects"
		2162 "Landscape architects"
		2163 "Product and garment designers"
		2164 "Town and traffic planners"
		2165 "Cartographers and surveyors"
		2166 "Graphic and multimedia designers"
		2200 "Health professionals"
		2210 "Medical doctors"
		2211 "Generalist medical practitioners"
		2212 "Specialist medical practitioners"
		2220 "Nursing and midwifery professionals"
		2221 "Nursing professionals"
		2222 "Midwifery professionals"
		2230 "Traditional and complementary medicine professionals"
		2240 "Paramedical practitioners"
		2250 "Veterinarians"
		2260 "Other health professionals"
		2261 "Dentists"
		2262 "Pharmacists"
		2263 "Environmental & occupational health-hygiene professionals"
		2264 "Physiotherapists"
		2265 "Dieticians and nutritionists"
		2266 "Audiologists and speech therapists"
		2267 "Optometrists and ophthalmic opticians"
		2269 "Health professionals nec"
		2300 "Teaching professionals"
		2310 "University and higher education teachers"
		2320 "Vocational education teachers"
		2330 "Secondary education teachers"
		2340 "Primary school and early childhood teachers"
		2341 "Primary school teachers"
		2342 "Early childhood educators"
		2350 "Other teaching professionals"
		2351 "Education methods specialists"
		2352 "Special needs teachers"
		2353 "Other language teachers"
		2354 "Other music teachers"
		2355 "Other arts teachers"
		2356 "Information technology trainers"
		2359 "Teaching professionals nec"
		2400 "Business and administration professionals"
		2410 "Finance professionals"
		2411 "Accountants"
		2412 "Financial and investment advisers"
		2413 "Financial analysts"
		2420 "Administration professionals"
		2421 "Management and organization analysts"
		2422 "Policy administration professionals"
		2423 "Personnel and careers professionals"
		2424 "Training and staff development professionals"
		2430 "Sales, marketing and public relations professionals"
		2431 "Advertising and marketing professionals"
		2432 "Public relations professionals"
		2433 "Technical and medical sales professionals [excluding ICT]"
		2434 "ICT sales professionals"
		2500 "ICT professionals"
		2510 "Software and applications developers and analysts"
		2511 "Systems analysts"
		2512 "Software developers"
		2513 "Web and multimedia developers"
		2514 "Applications programmers"
		2519 "Software and applications developers and analysts nec"
		2520 "Database and network professionals"
		2521 "Database designers and administrators"
		2522 "Systems administrators"
		2523 "Computer network professionals"
		2529 "Database and network professionals nec"
		2600 "Legal, social and cultural professionals"
		2610 "Legal professionals"
		2611 "Lawyers"
		2612 "Judges"
		2619 "Legal professionals nec"
		2620 "Librarians, archivists and curators"
		2621 "Archivists and curators"
		2622 "Librarians and related information professionals"
		2630 "Social and religious professionals"
		2631 "Economists"
		2632 "Sociologists, anthropologists and related professionals"
		2633 "Philosophers, historians and political scientists"
		2634 "Psychologists"
		2635 "Social work and counselling professionals"
		2636 "Religious professionals"
		2640 "Authors, journalists and linguists"
		2641 "Authors and related writers"
		2642 "Journalists"
		2643 "Translators, interpreters and other linguists"
		2650 "Creative and performing artists"
		2651 "Visual artists"
		2652 "Musicians, singers and composers"
		2653 "Dancers and choreographers"
		2654 "Film, stage and related directors and producers"
		2655 "Actors"
		2656 "Announcers on radio, television and other media"
		2659 "Creative and performing artists nec"
		3000 "Technicians and associate professionals"
		3100 "Science and engineering associate professionals"
		3110 "Physical and engineering science technicians"
		3111 "Chemical and physical science technicians"
		3112 "Civil engineering technicians"
		3113 "Electrical engineering technicians"
		3114 "Electronics engineering technicians"
		3115 "Mechanical engineering technicians"
		3116 "Chemical engineering technicians"
		3117 "Mining and metallurgical technicians"
		3118 "Draughtspersons"
		3119 "Physical and engineering science technicians nec"
		3120 "Mining, manufacturing and construction supervisors"
		3121 "Mining supervisors"
		3122 "Manufacturing supervisors"
		3123 "Construction supervisors"
		3130 "Process control technicians"
		3131 "Power production plant operators"
		3132 "Incinerator and water treatment plant operators"
		3133 "Chemical processing plant controllers"
		3134 "Petroleum and natural gas refining plant operators"
		3135 "Metal production process controllers"
		3139 "Process control technicians nec"
		3140 "Life science technicians and related associate professionals"
		3141 "Life science technicians [excluding medical]"
		3142 "Agricultural technicians"
		3143 "Forestry technicians"
		3150 "Ship and aircraft controllers and technicians"
		3151 "Ships engineers"
		3152 "Ships deck officers and pilots"
		3153 "Aircraft pilots and related associate professionals"
		3154 "Air traffic controllers"
		3155 "Air traffic safety electronics technicians"
		3200 "Health associate professionals"
		3210 "Medical and pharmaceutical technicians"
		3211 "Medical imaging and therapeutic equipment technicians"
		3212 "Medical and pathology laboratory technicians"
		3213 "Pharmaceutical technicians and assistants"
		3214 "Medical and dental prosthetic technicians"
		3220 "Nursing and midwifery associate professionals"
		3221 "Nursing associate professionals"
		3222 "Midwifery associate professionals"
		3230 "Traditional-complementary medicine assoc professionals"
		3240 "Veterinary technicians and assistants"
		3250 "Other health associate professionals"
		3251 "Dental assistants and therapists"
		3252 "Medical records and health information technicians"
		3253 "Community health workers"
		3254 "Dispensing opticians"
		3255 "Physiotherapy technicians and assistants"
		3256 "Medical assistants"
		3257 "Environmental-occupational health inspectors etc"
		3258 "Ambulance workers"
		3259 "Health associate professionals nec"
		3300 "Business and administration associate professionals"
		3310 "Financial and mathematical associate professionals"
		3311 "Securities and finance dealers and brokers"
		3312 "Credit and loans officers"
		3313 "Accounting associate professionals"
		3314 "Statistical, mathematical ar associate professionals"
		3315 "Valuers and loss assessors"
		3320 "Sales and purchasing agents and brokers"
		3321 "Insurance representatives"
		3322 "Commercial sales representatives"
		3323 "Buyers"
		3324 "Trade brokers"
		3330 "Business services agents"
		3331 "Clearing and forwarding agents"
		3332 "Conference and event planners"
		3333 "Employment agents and contractors"
		3334 "Real estate agents and property managers"
		3339 "Business services agents nec"
		3340 "Administrative and specialized secretaries"
		3341 "Office supervisors"
		3342 "Legal secretaries"
		3343 "Administrative and executive secretaries"
		3344 "Medical secretaries"
		3350 "Regulatory government associate professionals"
		3351 "Customs and border inspectors"
		3352 "Government tax and excise officials"
		3353 "Government social benefits officials"
		3354 "Government licensing officials"
		3355 "Police inspectors and detectives"
		3359 "Regulatory government associate professionals nec"
		3400 "Legal, social, cultural and related associate professionals"
		3410 "Legal, social and religious associate professionals"
		3411 "Legal and related associate professionals"
		3412 "Social work associate professionals"
		3413 "Religious associate professionals"
		3420 "Sports and fitness workers"
		3421 "Athletes and sports players"
		3422 "Sports coaches, instructors and officials"
		3423 "Fitness and recreation instructors and program leaders"
		3430 "Artistic, cultural and culinary associate professionals"
		3431 "Photographers"
		3432 "Interior designers and decorators"
		3433 "Gallery, museum and library technicians"
		3434 "Chefs"
		3435 "Other artistic and cultural associate professionals"
		3500 "Information and communications technicians"
		3510 "ICT operations and user support technicians"
		3511 "ICT operations technicians"
		3512 "ICT user support technicians"
		3513 "Computer network and systems technicians"
		3514 "Web technicians"
		3520 "Telecommunications and broadcasting technicians"
		3521 "Broadcasting and audio-visual technicians"
		3522 "Telecommunications engineering technicians"
		4000 "Clerical support workers"
		4100 "General and keyboard clerks"
		4110 "General office clerks"
		4120 "Secretaries [general]"
		4130 "Keyboard operators"
		4131 "Typists and word processing operators"
		4132 "Data entry clerks"
		4200 "Customer services clerks"
		4210 "Tellers, money collectors and related clerks"
		4211 "Bank tellers and related clerks"
		4212 "Bookmakers, croupiers and related gaming workers"
		4213 "Pawnbrokers and money-lenders"
		4214 "Debt-collectors arw"
		4220 "Client information workers"
		4221 "Travel consultants and clerks"
		4222 "Contact centre information clerks"
		4223 "Telephone switchboard operators"
		4224 "Hotel receptionists"
		4225 "Enquiry clerks"
		4226 "Receptionists [general]"
		4227 "Survey and market research interviewers"
		4229 "Client information workers nec"
		4300 "Numerical and material recording clerks"
		4310 "Numerical clerks"
		4311 "Accounting and bookkeeping clerks"
		4312 "Statistical, finance and insurance clerks"
		4313 "Payroll clerks"
		4320 "Material-recording and transport clerks"
		4321 "Stock clerks"
		4322 "Production clerks"
		4323 "Transport clerks"
		4400 "Other clerical support workers"
		4410 "Other clerical support workers"
		4411 "Library clerks"
		4412 "Mail carriers and sorting clerks"
		4413 "Coding, proof-reading and related clerks"
		4414 "Scribes arw"
		4415 "Filing and copying clerks"
		4416 "Personnel clerks"
		4419 "Clerical support workers nec"
		5000 "Service and sales workers"
		5100 "Personal service workers"
		5110 "Travel attendants, conductors and guides"
		5111 "Travel attendants and travel stewards"
		5112 "Transport conductors"
		5113 "Travel guides"
		5120 "Cooks"
		5130 "Waiters and bartenders"
		5131 "Waiters"
		5132 "Bartenders"
		5140 "Hairdressers, beauticians arw"
		5141 "Hairdressers"
		5142 "Beauticians arw"
		5150 "Building and housekeeping supervisors"
		5151 "Cleaning and housekeeping supervisors in offices, hotels etc"
		5152 "Domestic housekeepers"
		5153 "Building caretakers"
		5160 "Other personal services workers"
		5161 "Astrologers, fortune-tellers arw"
		5162 "Companions and valets"
		5163 "Undertakers and embalmers"
		5164 "Pet groomers and animal care workers"
		5165 "Driving instructors"
		5169 "Personal services workers nec"
		5200 "Sales workers"
		5210 "Street and market salespersons"
		5211 "Stall and market salespersons"
		5212 "Street food salespersons"
		5220 "Shop salespersons"
		5221 "Shop keepers"
		5222 "Shop supervisors"
		5223 "Shop sales assistants"
		5230 "Cashiers and ticket clerks"
		5240 "Other sales workers"
		5241 "Fashion and other models"
		5242 "Sales demonstrators"
		5243 "Door to door salespersons"
		5244 "Contact centre salespersons"
		5245 "Service station attendants"
		5246 "Food service counter attendants"
		5249 "Sales workers nec"
		5300 "Personal care workers"
		5310 "Child care workers and teachers aides"
		5311 "Child care workers"
		5312 "Teachers aides"
		5320 "Personal care workers in health services"
		5321 "Health care assistants"
		5322 "Home-based personal care workers"
		5329 "Personal care workers in health services nec"
		5400 "Protective services workers"
		5410 "Protective services workers"
		5411 "Fire-fighters"
		5412 "Police officers"
		5413 "Prison guards"
		5414 "Security guards"
		5419 "Protective services workers nec"
		6000 "Skilled agricultural, forestry and fishery workers"
		6100 "Market-oriented skilled agricultural workers"
		6110 "Market gardeners and crop growers"
		6111 "Field crop and vegetable growers"
		6112 "Tree and shrub crop growers"
		6113 "Gardeners, horticultural and nursery growers"
		6114 "Mixed crop growers"
		6120 "Animal producers"
		6121 "Livestock and dairy producers"
		6122 "Poultry producers"
		6123 "Apiarists and sericulturists"
		6129 "Animal producers nec"
		6130 "Mixed crop and animal producers"
		6200 "Market-oriented skilled forestry, fishery, hunting wrkrs"
		6210 "Forestry arw"
		6220 "Fishery workers, hunters and trappers"
		6221 "Aquaculture workers"
		6222 "Inland and coastal waters fishery workers"
		6223 "Deep-sea fishery workers"
		6224 "Hunters and trappers"
		6300 "Subsistence farmers, fishers, hunters and gatherers"
		6310 "Subsistence crop farmers"
		6320 "Subsistence livestock farmers"
		6330 "Subsistence mixed crop and livestock farmers"
		6340 "Subsistence fishers, hunters, trappers and gatherers"
		7000 "Craft ar trades wrkrs"
		7100 "Building ar trades wrkrs, excluding electricians"
		7110 "Building frame ar trades wrkrs"
		7111 "House builders"
		7112 "Bricklayers arw"
		7113 "Stonemasons, stone cutters, splitters and carvers"
		7114 "Concrete placers, concrete finishers arw"
		7115 "Carpenters and joiners"
		7119 "Building frame ar trades wrkrs nec"
		7120 "Building finishers ar trades wrkrs"
		7121 "Roofers"
		7122 "Floor layers and tile setters"
		7123 "Plasterers"
		7124 "Insulation workers"
		7125 "Glaziers"
		7126 "Plumbers and pipe fitters"
		7127 "Air conditioning and refrigeration mechanics"
		7130 "Painters, building structure cleaners ar trades wrkrs"
		7131 "Painters arw"
		7132 "Spray painters and varnishers"
		7133 "Building structure cleaners"
		7200 "Metal, machinery ar trades wrkrs"
		7210 "Sheet-structural metal wekrs, moulders and welders, arw"
		7211 "Metal moulders and coremakers"
		7212 "Welders and flamecutters"
		7213 "Sheet-metal workers"
		7214 "Structural-metal preparers and erectors"
		7215 "Riggers and cable splicers"
		7220 "Blacksmiths, toolmakers ar trades wrkrs"
		7221 "Blacksmiths, hammersmiths and forging press workers"
		7222 "Toolmakers arw"
		7223 "Metal working machine tool setters and operators"
		7224 "Metal polishers, wheel grinders and tool sharpeners"
		7230 "Machinery mechanics and repairers"
		7231 "Motor vehicle mechanics and repairers"
		7232 "Aircraft engine mechanics and repairers"
		7233 "Agricultural-industrial machinery mechanics & repairers"
		7234 "Bicycle and related repairers"
		7300 "Handicraft and printing workers"
		7310 "Handicraft workers"
		7311 "Precision-instrument makers and repairers"
		7312 "Musical instrument makers and tuners"
		7313 "Jewellery and precious-metal workers"
		7314 "Potters arw"
		7315 "Glass makers, cutters, grinders and finishers"
		7316 "Sign writers, decorative painters, engravers and etchers"
		7317 "Handicraft workers in wood, basketry and related materials"
		7318 "Handicraft workers in textile, leather and related materials"
		7319 "Handicraft workers nec"
		7320 "Printing trades workers"
		7321 "Pre-press technicians"
		7322 "Printers"
		7323 "Print finishing and binding workers"
		7400 "Electrical and electronic trades workers"
		7410 "Electrical equipment installers and repairers"
		7411 "Building and related electricians"
		7412 "Electrical mechanics and fitters"
		7413 "Electrical line installers and repairers"
		7420 "Electronics and telecommunications installers and repairers"
		7421 "Electronics mechanics and servicers"
		7422 "ICT installers and servicers"
		7500 "Food processing, wood working, garment ar craft-trades wrks"
		7510 "Food processing ar trades wrkrs"
		7511 "Butchers, fishmongers and related food preparers"
		7512 "Bakers, pastry-cooks and confectionery makers"
		7513 "Dairy-products makers"
		7514 "Fruit, vegetable and related preservers"
		7515 "Food and beverage tasters and graders"
		7516 "Tobacco preparers and tobacco products makers"
		7520 "Wood treaters, cabinet-makers ar trades wrkrs"
		7521 "Wood treaters"
		7522 "Cabinet-makers arw"
		7523 "Woodworking-machine tool setters and operators"
		7530 "Garment ar trades wrkrs"
		7531 "Tailors, dressmakers, furriers and hatters"
		7532 "Garment and related pattern-makers and cutters"
		7533 "Sewing, embroidery arw"
		7534 "Upholsterers arw"
		7535 "Pelt dressers, tanners and fellmongers"
		7536 "Shoemakers arw"
		7540 "Other craft arw"
		7541 "Underwater divers"
		7542 "Shotfirers and blasters"
		7543 "Product graders and testers [excluding foods and beverages]"
		7544 "Fumigators and other pest and weed controllers"
		7549 "Craft arw nec"
		8000 "Plant and machine operators, and assemblers"
		8100 "Stationary plant and machine operators"
		8110 "Mining and mineral processing plant operators"
		8111 "Miners and quarriers"
		8112 "Mineral and stone processing plant operators"
		8113 "Well drillers and borers arw"
		8114 "Cement, stone and other mineral products machine operators"
		8120 "Metal processing and finishing plant operators"
		8121 "Metal processing plant operators"
		8122 "Metal finishing, plating and coating machine operators"
		8130 "Chemical-photograph products plant and machine operators"
		8131 "Chemical products plant and machine operators"
		8132 "Photographic products machine operators"
		8140 "Rubber, plastic and paper products machine operators"
		8141 "Rubber products machine operators"
		8142 "Plastic products machine operators"
		8143 "Paper products machine operators"
		8150 "Textile, fur and leather products machine operators"
		8151 "Fibre preparing, spinning and winding machine operators"
		8152 "Weaving and knitting machine operators"
		8153 "Sewing machine operators"
		8154 "Bleaching, dyeing and fabric cleaning machine operators"
		8155 "Fur and leather preparing machine operators"
		8156 "Shoemaking and related machine operators"
		8157 "Laundry machine operators"
		8159 "Textile, fur and leather products machine operators nec"
		8160 "Food and related products machine operators"
		8170 "Wood processing and papermaking plant operators"
		8171 "Pulp and papermaking plant operators"
		8172 "Wood processing plant operators"
		8180 "Other stationary plant and machine operators"
		8181 "Glass and ceramics plant operators"
		8182 "Steam engine and boiler operators"
		8183 "Packing, bottling and labelling machine operators"
		8189 "Stationary plant and machine operators nec"
		8200 "Assemblers"
		8210 "Assemblers"
		8211 "Mechanical machinery assemblers"
		8212 "Electrical and electronic equipment assemblers"
		8219 "Assemblers nec"
		8300 "Drivers and mobile plant operators"
		8310 "Locomotive engine drivers arw"
		8311 "Locomotive engine drivers"
		8312 "Railway brake, signal and switch operators"
		8320 "Car, van and motorcycle drivers"
		8321 "Motorcycle drivers"
		8322 "Car, taxi and van drivers"
		8330 "Heavy truck and bus drivers"
		8331 "Bus and tram drivers"
		8332 "Heavy truck and lorry drivers"
		8340 "Mobile plant operators"
		8341 "Mobile farm and forestry plant operators"
		8342 "Earthmoving and related plant operators"
		8343 "Crane, hoist and related plant operators"
		8344 "Lifting truck operators"
		8350 "Ships deck crews arw"
		9000 "Elementary occupations"
		9100 "Cleaners and helpers"
		9110 "Domestic, hotel and office cleaners and helpers"
		9111 "Domestic cleaners and helpers"
		9112 "Cleaners and helpers in offices, hotels etc"
		9120 "Vehicle, window, laundry and other hand cleaning workers"
		9121 "Hand launderers and pressers"
		9122 "Vehicle cleaners"
		9123 "Window cleaners"
		9129 "Other cleaning workers"
		9200 "Agricultural, forestry and fishery labourers"
		9210 "Agricultural, forestry and fishery labourers"
		9211 "Crop farm labourers"
		9212 "Livestock farm labourers"
		9213 "Mixed crop and livestock farm labourers"
		9214 "Garden and horticultural labourers"
		9215 "Forestry labourers"
		9216 "Fishery and aquaculture labourers"
		9300 "Labourers mining, construction, manufactur & transport"
		9310 "Mining and construction labourers"
		9311 "Mining and quarrying labourers"
		9312 "Civil engineering labourers"
		9313 "Building construction labourers"
		9320 "Manufacturing labourers"
		9321 "Hand packers"
		9329 "Manufacturing labourers nec"
		9330 "Transport and storage labourers"
		9331 "Hand and pedal vehicle drivers"
		9332 "Drivers of animal-drawn vehicles and machinery"
		9333 "Freight handlers"
		9334 "Shelf fillers"
		9400 "Food preparation assistants"
		9410 "Food preparation assistants"
		9411 "Fast food preparers"
		9412 "Kitchen helpers"
		9500 "Street and related sales and service workers"
		9510 "Street and related service workers"
		9520 "Street vendors [excluding food]"
		9600 "Refuse workers and other elementary workers"
		9610 "Refuse workers"
		9611 "Garbage and recycling collectors"
		9612 "Refuse sorters"
		9613 "Sweepers and related labourers"
		9620 "Other elementary workers"
		9621 "Messengers, package deliverers and luggage porters"
		9622 "Odd job persons"
		9623 "Meter readers and vending-machine collectors"
		9624 "Water and firewood collectors"
		9629 "Elementary workers nec";
	#delimit cr 
end 