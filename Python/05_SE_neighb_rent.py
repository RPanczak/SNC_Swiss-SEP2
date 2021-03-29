# -*- coding: utf-8 -*-
# ---------------------------------------------------------------------------
# 05_SE_neighb_rent.py
# Created on: 2017-06-22
#
# Description: 
# 	SE buildings network analysis
# 	All eligible SNC buildings as ORIGINS
# 	Rented 3-5 rooms SE flats as DESTINATIONS
# 	Searching for a max of 100 neighbours, with a limit of 20km, no lines
#	ATTENTION - ANALYSIS IS SPLIT ACROSS SIX ORIGINS 
#		THAT HELPS TO CREATE HUGE RESULTS DATASETS (HARD TO READ/EXPORT...)
# ---------------------------------------------------------------------------
try:

	# timing command
	import time
	start = time.time()

	# Import arcpy module
	import arcpy

	# Check out any necessary licenses
	arcpy.CheckOutExtension("Network")
	
	# allow overwriting
	arcpy.env.overwriteOutput = True

	# Local variables:
	NETWORK = "H:\\RP\\projects\\sep2\\gis\\01_network_corr.gdb\\TLM_STRASSEN\\TLM_STRASSEN_ND"
	OD_COST_MATRIX = "OD Cost Matrix"
	#ORIGINS = "H:\\RP\\projects\\sep2\\gis\\03_buildings_bfs.gdb\\ORIGINS_test"
	ORIGINS = "H:\\RP\\projects\\sep2\\gis\\03_buildings_bfs.gdb\\ORIGINS"
	#DESTINATIONS = "H:\\RP\\projects\\sep2\\gis\\03_buildings_bfs.gdb\\DESTINATIONS_test"
	DESTINATIONS = "H:\\RP\\projects\\sep2\\gis\\03_buildings_bfs.gdb\\DESTINATIONS_rent"
	LINES = "OD Cost Matrix\\Lines"
	TEMP = "H:\\RP\\projects\\sep2\\gis\\05_results_rent.gdb\\temp"

	# Process: Make OD Cost Matrix Layer
	arcpy.MakeODCostMatrixLayer_na(NETWORK, "OD Cost Matrix", "Length", "20000", "101", "", "ALLOW_UTURNS", "restriction", "NO_HIERARCHY", "", "NO_LINES", "")

	# Process: Add Destinations 
	arcpy.AddLocations_na(OD_COST_MATRIX, "Destinations", DESTINATIONS, "Name gisid #", "10000 Meters", "", "TLM_STRASSE SHAPE;TLM_STRASSEN_ND_Junctions NONE", "MATCH_TO_CLOSEST", "CLEAR", "NO_SNAP", "5 Meters", "EXCLUDE", "TLM_STRASSE #;TLM_STRASSEN_ND_Junctions #")

	# data is in six parts
	PART = 1
	
	while PART <= 3:
		
		RESULTS = "H:\\RP\\projects\\sep2\\gis\\05_results_rent.gdb\\SE_101_neighb_rent_20km_" + str(PART)
		WHERE_CLAUSE = "part =" + str(PART) 
		
		# Select: quantile of origins to temp file
		arcpy.Select_analysis(ORIGINS, TEMP, WHERE_CLAUSE)		
		
		# Process: Add Origins 
		arcpy.AddLocations_na(OD_COST_MATRIX, "Origins", TEMP, "Name gisid #", "10000 Meters", "", "TLM_STRASSE SHAPE;TLM_STRASSEN_ND_Junctions NONE", "MATCH_TO_CLOSEST", "CLEAR", "NO_SNAP", "5 Meters", "EXCLUDE", "TLM_STRASSE #;TLM_STRASSEN_ND_Junctions #")

		# Process: Solve
		arcpy.Solve_na(OD_COST_MATRIX, "SKIP", "TERMINATE", "", "")

		# Process: Select Data
		arcpy.SelectData_management(OD_COST_MATRIX, "Lines")

		# Process: Select
		arcpy.Select_analysis(LINES, RESULTS, "")
		
		print str(PART) + " part exported..."
		PART += 1

	# clean temp
	arcpy.DeleteFeatures_management(TEMP)

	print "Completed successfully, in ", (time.time()-start)/3600, " hours."

except Exception as e:

	import traceback, sys
	tb = sys.exc_info()[2]
	print "An error occured on line %i" % tb.tb_lineno
	print str(e)
