/*SIP intersection #s
2014-2021 + 2022 proposed study period

a.	# of intersection VZ SIPs by year (VZ = not none for VZ_status)
b.	# of intersections “touched” by all VZ SIPs per year (use distinct masterids)
c.	# of ped islands (same definition as treatment eval) per year (count distinct masterids with ped islands or median extensions)
d.	# of curb extensions/ neckdown/sidewalk extensions etc (same definition as treatment eval) per year (count numberof distinct masterids or mfts with any of these treatments)
*/


-- a. # of intersection VZ SIPs by year (VZ = not none for VZ_status)

SELECT sip_year, count(DISTINCT sp.pid)
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
WHERE segmentid=0 
AND vz_status != ''
AND vz_status != '23'
AND ((sip_year between 2014 and 2021 and status = '15') OR (sip_year = 2022 and status = '11'))
GROUP BY sip_year;


-- b. # of intersections “touched” by all VZ SIPs per year (use distinct masterids)

WITH data AS(
SELECT DISTINCT cl.masteridfr masterid, sp.sip_year
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN clion cl
ON spg.segmentid::int = cl.segmentid::int
WHERE spg.nodeid=0 
AND vz_status != ''
AND vz_status != '23'
AND ((sip_year between 2014 and 2021 and status = '15') OR (sip_year = 2022 and status = '11'))
	
UNION 
	
SELECT DISTINCT cl.masteridto masterid, sp.sip_year
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN clion cl
ON spg.segmentid::int = cl.segmentid::int
WHERE spg.nodeid=0 
AND vz_status != ''
AND vz_status != '23'
AND ((sip_year between 2014 and 2021 and status = '15') OR (sip_year = 2022 and status = '11'))
	
UNION 
	
SELECT DISTINCT cln.masterid, sp.sip_year
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN clion_node cln
ON spg.nodeid::int = cln.nodeid::int
WHERE spg.segmentid=0 
AND vz_status != ''
AND vz_status != '23'
AND ((sip_year between 2014 and 2021 and status = '15') OR (sip_year = 2022 and status = '11'))
)

SELECT sip_year, count(DISTINCT masterid)
FROM data
GROUP BY sip_year;


-- c. # of ped islands (same definition as treatment eval) per year (count distinct masterids with ped islands or median extensions)


WITH data AS (
SELECT tree.descendant AS qid,
	   array_to_string(array_agg(tree.concat), ' -> '::text) AS full_treatment,
	   array_to_string(array_agg(tree.ancestor), ' -> '::text) AS full_treatment_int
FROM ( SELECT p.descendant,
			  p.ancestor,
			  q.question,
			  p.depth,
			  concat(p.ancestor, ': ', q.question, ' (Depth:', p.depth, ')') AS concat
	   FROM sip_questions_path p
	   JOIN sip_questions q ON p.ancestor = q.qid
	   ORDER BY p.descendant, p.depth DESC) tree
GROUP BY tree.descendant
)

,sip_flattened_tree AS(
SELECT data.qid,
data.full_treatment,
data.full_treatment_int
FROM data)


SELECT sp.sip_year, count(DISTINCT cln.masterid)
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN clion_node cln
ON spg.nodeid::int = cln.nodeid::int
JOIN sip_treatments st
ON sp.pid = st.pid_fk 
JOIN sip_flattened_tree sft
ON st.breadcrumbid = sft.qid
WHERE spg.segmentid=0 
AND ((sp.sip_year between 2014 and 2021 and status = '15') OR (sp.sip_year = 2022 and status = '11'))
AND (sft.full_treatment like '%Median%Tips%' OR sft.full_treatment like '%Ped%Island%')
AND sft.full_treatment not like '%Removed%'
AND sft.full_treatment not like '%Modified%'
GROUP BY sp.sip_year;


-- d. # of curb extensions/ neckdown/sidewalk extensions etc (same definition as treatment eval) per year (count numberof distinct masterids or mfts with any of these treatments)

WITH data AS (
SELECT tree.descendant AS qid,
	   array_to_string(array_agg(tree.concat), ' -> '::text) AS full_treatment,
	   array_to_string(array_agg(tree.ancestor), ' -> '::text) AS full_treatment_int
FROM ( SELECT p.descendant,
			  p.ancestor,
			  q.question,
			  p.depth,
			  concat(p.ancestor, ': ', q.question, ' (Depth:', p.depth, ')') AS concat
	   FROM sip_questions_path p
	   JOIN sip_questions q ON p.ancestor = q.qid
	   ORDER BY p.descendant, p.depth DESC) tree
GROUP BY tree.descendant
)

,sip_flattened_tree AS(
SELECT data.qid,
data.full_treatment,
data.full_treatment_int
FROM data)

,data2 AS(
SELECT DISTINCT cl.mft geo, sp.sip_year
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN clion cl
ON spg.segmentid::int = cl.segmentid::int
JOIN sip_treatments st
ON sp.pid = st.pid_fk 
JOIN sip_flattened_tree sft
ON st.breadcrumbid = sft.qid
WHERE spg.nodeid=0 
AND ((sp.sip_year between 2014 and 2021 and status = '15') OR (sp.sip_year = 2022 and status = '11'))
AND (sft.full_treatment like '%Ped%Neckdown%' OR 
	 sft.full_treatment like '%Ped%Sidewalk Expansion%' OR
	 sft.full_treatment like '%Ped%Curb%' )
AND sft.full_treatment not like '%Removed%'
AND sft.full_treatment not like '%Modified%'

UNION

SELECT DISTINCT cln.masterid geo, sp.sip_year
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN clion_node cln
ON spg.nodeid::int = cln.nodeid::int
JOIN sip_treatments st
ON sp.pid = st.pid_fk 
JOIN sip_flattened_tree sft
ON st.breadcrumbid = sft.qid
WHERE spg.segmentid=0 
AND ((sp.sip_year between 2014 and 2021 and status = '15') OR (sp.sip_year = 2022 and status = '11'))
AND (sft.full_treatment like '%Ped%Neckdown%' OR 
	 sft.full_treatment like '%Ped%Sidewalk Expansion%' )
AND sft.full_treatment not like '%Removed%'
AND sft.full_treatment not like '%Modified%'
)

SELECT sip_year, count(DISTINCT geo)
FROM data2
GROUP by sip_year;
