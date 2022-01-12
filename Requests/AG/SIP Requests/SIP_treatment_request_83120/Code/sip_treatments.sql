-- Grab treatment name, flattened tree treatment type, and project install dates, mileage of treatment, pm, and sip year
-- sip_treatments join to sip_projects on pid_fk
-- Join to sip geo to get the mileage

SELECT st.treatment, sp.sip_year, sp.start_date, st.start_date, st.treatmenttype, breadcrumbid, temptid, 
       tree_version_used
FROM public.sip_treatments st
JOIN public.sip_projects sp
ON st.pid_fk = sp.pid;


SELECT *
FROM public.sip_treatments;

SELECT *
FROM public.sip_projects;



WITH data AS(
SELECT tree.descendant AS qid, 
array_to_string(array_agg(tree.concat), ' -> '::text) AS full_treatment
FROM (  SELECT p.descendant, p.ancestor, q.question, p.depth, 
       pg_catalog.concat(p.ancestor, ': ', q.question, ' (Depth:', p.depth, ')') AS concat
    FROM sip_questions_path p
    JOIN sip_questions q ON p.ancestor = q.qid
    ORDER BY p.descendant, p.depth DESC) tree
GROUP BY tree.descendant
)


SELECT sp.pid, st.tid, st.treatment, data.full_treatment, sp.sip_year, sp.start_date project_start, 
       st.start_date treatment_start, sp.end_date project_end, st.end_date treatment_end, sl.description,
       sum(coalesce(st_length(cl.geom)/5280,0)) mileage, sp.pm
FROM public.sip_treatments st
LEFT JOIN data
ON data.qid = st.breadcrumbid
LEFT JOIN public.sip_projects sp
ON st.pid_fk = sp.pid
LEFT JOIN public.sip_treatments_geo stg
ON st.tid = stg.tid_fk
LEFT JOIN public.clion cl
ON stg.segmentid::int = cl.segmentid::int
JOIN sip_lookup sl
ON sp.status::int = sl.lookupid
WHERE (((sp.status::int = 15 or sp.status::int = 11) and sip_year = 2020) 
OR (sp.status::int = 11 and sip_year = 2021))
AND sp.unit = '24'
GROUP BY sp.pid, st.tid, st.treatment, data.full_treatment, sp.sip_year, sp.start_date, 
	 st.start_date, sp.end_date, st.end_date, sl.description, sp.pm




SELECT * 
FROM public.sip_treatments
limit 10


SELECT * 
FROM public.sip_projects
limit 10