# -*- coding: utf-8 -*-
# ---------------------------------------------------------------------------
# 11_export_loop.py
# Created on: 2017-06-22
#
# Description: 
# 	Exporting GDB tables to ASCII
#	Using copy rows
# 	Using while loop to break data into chunks
# ---------------------------------------------------------------------------
try:

 	# timing command
	import time
	start = time.time()
	
	# arcpy modules
	import arcpy

	# allow overwriting
	arcpy.env.overwriteOutput = True
	
	PART = 1
	
	while PART <= 2:

		# local variables...
		export_ASCII = "H:\\RP\\projects\\sep2\\Stata\\orig\\neighb_snc\\SNC_101_neighb_20km_" + str(PART) +".txt"
		input_features = "H:\\RP\\projects\\sep2\\gis\\06_results_snc.gdb\\SNC_101_neighb_20km_" + str(PART)

		# execute copyrows
		arcpy.CopyRows_management(input_features, export_ASCII)
		
		print str(PART) + " part exported..."
		PART += 1
 
	PART = 3
	
	while PART <= 4:

		export_ASCII = "H:\\RP\\projects\\sep2\\Stata\\orig\\neighb_snc\\SNC_101_neighb_20km_" + str(PART) +".txt"
		input_features = "H:\\RP\\projects\\sep2\\gis\\06_results_snc_2.gdb\\SNC_101_neighb_20km_" + str(PART)

		arcpy.CopyRows_management(input_features, export_ASCII)
		
		print str(PART) + " part exported..."
		PART += 1
 
	PART = 5
	
	while PART <= 6:

		export_ASCII = "H:\\RP\\projects\\sep2\\Stata\\orig\\neighb_snc\\SNC_101_neighb_20km_" + str(PART) +".txt"
		input_features = "H:\\RP\\projects\\sep2\\gis\\06_results_snc_3.gdb\\SNC_101_neighb_20km_" + str(PART)

		arcpy.CopyRows_management(input_features, export_ASCII)
		
		print str(PART) + " part exported..."
		PART += 1
 
	print "Completed successfully, in ", (time.time()-start)/3600, " hours"

except Exception as e:

	import traceback, sys
	tb = sys.exc_info()[2]
	print "An error occured on line %i" % tb.tb_lineno
	print str(e)
