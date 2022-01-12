# HBKBQE Request

Task: Raw data request 
- Provide the full tables for crash, vehicle and contributing factors (1 table containing crash, vehicle and contributing factors data) 
- Compare and verify that all nodes provided are in node table
- Perfom a visual QA of selection and provided maps


Planning Steps:
a.	Prep
	i.	Make sure all nodeids provided as valid
	1.	If not figure out what to do about nodes that don’t join – find best node in current data, mark as unknown location, something else? 
	ii.	Make sure map of 19d nodes matches the locations in request map
	iii.	Make sure all reference markers are valid 
	1.	If not figure out what to do about ref markers that don’t join – find best ref marker in current data, mark as unknown location, something else? 
	iv.	Make sure map of ref markers matches request map
b.	Retrieval 
	i.	Select all nysdot data (crashes) in time period at nodes or ref markers
	ii.	Export all associated records (meaning have a crashid identified in #1) in vehicle table 
	iii.	Export all associated records (meaning have a crashid identified in #1) in contributing factor table 
	iv.	Export all records in crash table (#1) without any of our added fields (apart from crashid) 
c.	Wrap up
	i.	Do some data checks on the outptus 
		1.	make sure the record counts match the results in section b 
		2.	make sure data looks reasonable (ex. if you only find 10 crashes that is definitely wrong, or if you have 10 million that is wrong) 
		3.	make sure the data looks correct (no fields being distorted) 
	ii.	make sure your code, notes, input files, request info and outputs are all in a folder together 
	iii.	send me the folder path and maybe the crash counts for the full request 



6/16/21
UPDATE: Highway crashes don’t use segments or nodes; the reference markers must be used directly in the crash data