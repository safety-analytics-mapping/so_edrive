
--Grabbing array of full treatments by using question path
WITH data AS(
SELECT tree.descendant AS qid, 
array_to_string(array_agg(tree.concat), ' -> '::text) AS full_treatment,
array_to_string(array_agg(tree.ancestor), ' -> '::text) AS full_treatment_int
FROM (SELECT p.descendant, p.ancestor, q.question, p.depth, 
pg_catalog.concat(p.ancestor, ': ', q.question, ' (Depth:', p.depth, ')') AS concat
FROM sip_questions_path p
JOIN sip_questions q ON p.ancestor = q.qid
ORDER BY p.descendant, p.depth DESC) tree
GROUP BY tree.descendant
)
--Grabbing protection type for bike lanes
,data2 AS(
SELECT qid,CASE WHEN data.full_treatment like '%Parking%' THEN 'Parking' 
WHEN data.full_treatment like '%Jersey Barriers%' THEN 'Jersey Barriers'
WHEN data.full_treatment like '%Delineators%' THEN 'Delineators'
WHEN data.full_treatment like '%Curb Protected%' THEN 'Curb Protected' 
WHEN data.full_treatment like '%Sidewalk Stamps%' THEN 'Sidewalk Stamps'
WHEN data.full_treatment like '%Temporary Barrels%' THEN 'Temporary Barrels'
ELSE 'NA' END AS "Protected Type"
FROM data
WHERE data.full_treatment like '%5: Bike%'
AND data.full_treatment like '%258: New Facility%')

--Grabbing PID, project name, borough, project status, lgeom
SELECT DISTINCT sp.pid, sp.pjct_name, sl.description, stg.rboro, st_length(stg.geom) as ft, data2."Protected Type", stg.segmentid, stg.geom 
FROM data2
JOIN sip_treatments st --Joining to sip treatments on qid and breadcrumbid to join to sip projects and then sip treatment projects
ON data2.qid = st.breadcrumbid 
JOIN public.sip_projects sp
ON st.pid_fk = sp.pid
JOIN sip_lookup sl
ON sp.status::int = sl.lookupid
JOIN public.sip_treatments_geo stg
ON st.tid = stg.tid_fk
WHERE "Protected Type" != 'NA'
AND sp.status in ('11','15')
