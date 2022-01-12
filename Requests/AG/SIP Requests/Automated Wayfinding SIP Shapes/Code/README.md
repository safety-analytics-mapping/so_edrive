# Automated Wayfind SIP shps

Task:
Write a py script that outputs shps of planned SIPs for the current 
calendar and next (variabalized) calendar years and saves these shps 
in a specified folder (for the Wayfinding team) monthly.

Task (in personal words):
Create script for obtaining monthly planned SIP projects of the current and subsquent year and 
outputs shps to specific folder for Wayfinding team. 

Analysis steps:
a. Data Retrieval for Current Calendar year 
   i. Join sip projects table to sip projects geometry table
   ii. Select project id, sip year, unit, project manager, status description and geometry from sip projects table
   iii. Limit selection to current calendar year and subsequent year
   iv. Limit selection to projects with status description equal to 'SIP'
b. Output data to folder (\\dotfp\40Worth_GISData\BIKERACK_VIEWER\SIP_DATA) 
   i. Output corridor SIP projects to folder as shapefile using query_to_shp function in pysqldb 
   ii. Output intersection SIP projects to folder as shapefile using query_to_shp function in pysqldb
c. Autonomate monthly execution of script
   i. If shapefile exists, overwrite it


