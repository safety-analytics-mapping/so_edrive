# SIP Project Mileage Request

Task:
Generate the SIP project miles by unit by year and incorporate intersections 

Planning Steps:
- Grab all completed SIP projects
- Grab SIP project geometry mileages
- Group sip project mileages by project, unit and year 


Analysis steps:
1. Get SIP corridor project mileages
   - Subquery
   a. Join sip projects to sip projects geo on project id 
   b. Join to lion on segmentid
   c. Limit for a subset of completed corridor projects
   d. Select distinct project id, unit, year, mft
  
   e. Join resulting temp table of completed corridor projects to lion on mft
   f. Limit to centerline mfts 
   g. Select distinct project id, unit, year and sum of lion geometry length divided by 5280 (this is where the aggregation of lion geom length for mileage occurs)
   h. Group by project id, unit and year

2. Get SIP intersection project mileages 
   - Subquery
   a. Join sip projects to sip projects geo on project id 
   b. Join to node on nodeid
   c. Limit for a subset of completed intersection projects 
   d. Select distinct project id, unit, year, masterid

   f. Join resulting temp table of completed intersection projects to lion on masterid equals masteridfrom or masteridto  
   h. Limit to centerline mfts 
   i. Select distinct project id, unit, year and sum of lion geometry length divided by 5280 (this is where the aggregation of lion geom length for mileage occurs)
   j. Group by project id, unit and year
  
3. Union all SIP corridor project mileages and  SIP intersection project mileages

4. Aggregate combined SIP corridor and intersection mileages by unit and group by SIP year




