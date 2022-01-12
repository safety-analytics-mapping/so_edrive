SELECT distinct coalesce(lion.mft,0)::text mft, coalesce(masteridfr,0)::text masteridfrom, coalesce(masteridto,0)::text masteridto, lion.geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join clion liont
on spg.segmentid::int = lion.segmentid::int
where sp.status= '15'
and spg.nodeid=0
and left(sip_year::text,4)::int between 2014 and 2018
and left(end_date::text,4)::int between 2014 and 2018



SELECT *
FROM sip_treatments st
JOIN sip_treatments_geo stg
on st.tid = stg.tid_fk
JOIN sip_treatments_attr sta
on st.tid = sta.tid_fk
WHERE tid in (4578, 3805,  2798, 3613)


select * 
from sip_questions
WHERE question like '%Neck%'
or question like '%Sidewalk%'
or question like '%Plaza%'
or question like '%New%'
or question like '%Refuge%'
or question like '%Ped Space%'



SELECT * 
FROM sip_projects sp
limit 10

--method 1
WITH data as (
SELECT sq.qid, sq.question, sqp.*
FROM sip_questions sq
JOIN sip_questions_path sqp
ON sq.qid = sqp.ancestor
WHERE sq.question in ('New Crossings', 'Sidewalk Expansions', 'Ped Plaza', 'Neckdown', 'Ped Refuge Islands', 'Other Ped Space')
)

--you need pid, tid, pjct_name, sip_year, start_date, end_date, pm, unit

,data2 as(
SELECT  distinct st.tid, st.pid_fk, sp.pjct_name, sp.sip_year, st.start_date, st.end_date, sp.pm, sp.unit, segmentid::int, nodeid::int
FROM sip_treatments st
JOIN sip_projects sp
ON st.pid_fk=sp.pid
JOIN public.sip_treatments_geo stg
ON st.tid=stg.tid_fk
WHERE breadcrumbid in (SELECT descendant FROM data)
)


SELECT * 
FROM data2
WHERE nodeid = 0

UNION

SELECT * FROM (
SELECT tid, pid_fk, pjct_name, sip_year, start_date, end_date, pm, unit, cl.segmentid::int,nodeid
FROM data2 d2
JOIN clion cl
ON d2.nodeid = cl.nodeidto::int
WHERE d2.nodeid != 0

UNION

SELECT tid, pid_fk, pjct_name, sip_year, start_date, end_date, pm, unit, cl.segmentid::int,nodeid
FROM data2 d2
JOIN clion cl
ON d2.nodeid = cl.nodeidfrom::int
WHERE d2.nodeid != 0
)nodes_to_segments
ORDER BY segmentid




select * from sip_treatments_geo
limit 10








--method2

WITH data as (
SELECT sq.qid, sq.question, sqp.*
FROM sip_questions sq
JOIN sip_questions_path sqp
ON sq.qid = sqp.ancestor
WHERE sq.question in ('New Crossings', 'Sidewalk Expansions', 'Ped Plaza', 'Neckdown', 'Ped Refuge Islands', 'Other Ped Space', 'Sidewalk Stamps')
)

,data2 as(
SELECT distinct st.tid, st.pid_fk, segmentid, nodeid
FROM sip_treatments st
JOIN public.sip_projects_geo spg
ON st.pid_fk=spg.pid_fk
WHERE breadcrumbid in (SELECT descendant FROM data)
)

SELECT segmentid
FROM clion
WHERE nodeidfrom::int in (SELECT nodeid 
			  FROM data2
			  WHERE nodeid != 0)

UNION 

SELECT segmentid
FROM clion
WHERE nodeidto::int in (SELECT nodeid 
			FROM data2
			WHERE nodeid != 0)





--official


-- Querying questions table to get qid's for specific treatments
-- Querying questions path table to get all descendants of desired treatments

WITH data as (
SELECT sq.qid, sq.question, sqp.*
FROM sip_questions sq
JOIN sip_questions_path sqp
ON sq.qid = sqp.ancestor
WHERE sq.question in ('New Crossings', 'Sidewalk Expansions', 'Ped Plaza', 'Neckdown', 'Ped Refuge Islands', 'Other Ped Space')
)

-- Needed: pid, tid, pjct_name, sip_year, start_date, end_date, pm, unit
-- Also grabbing segmentids and nodeids
-- Joining to lookup table (sl) to get status description
-- Joining to lookup table (su) to get unit description

,data2 as(

SELECT tid, pid_fk, pjct_name, sip_year, start_date, end_date, pm, unit, su.description, sl.description status_desc, segmentid::int, nodeid::int 
FROM( SELECT  distinct st.tid, st.pid_fk, sp.pjct_name, sp.sip_year, sp.start_date, sp.end_date, sp.pm, sp.unit, sp.status::int, segmentid::int, nodeid::int
      FROM sip_treatments st
      JOIN sip_projects sp
      ON st.pid_fk=sp.pid
      JOIN public.sip_treatments_geo stg
      ON st.tid=stg.tid_fk
      WHERE breadcrumbid in (SELECT descendant FROM data)
      and sp.status::int = 15
) sips
JOIN sip_lookup sl
ON sips.status = sl.lookupid
JOIN sip_lookup su
ON sips.unit = su.lookupid::varchar
)

SELECT * 
FROM data2
WHERE nodeid = 0

UNION

-- Grabbing all segments from clion ending in treatment nodeids

SELECT * FROM (
SELECT tid, pid_fk, pjct_name, sip_year, start_date, end_date, pm, unit, description, status_desc, cl.segmentid::int, nodeid 
FROM data2 d2
JOIN clion cl
ON d2.nodeid = cl.nodeidto::int
WHERE d2.nodeid != 0

UNION

SELECT tid, pid_fk, pjct_name, sip_year, start_date, end_date, pm, unit, description, status_desc, cl.segmentid::int, nodeid
FROM data2 d2
JOIN clion cl
ON d2.nodeid = cl.nodeidfrom::int
WHERE d2.nodeid != 0
)nodes_to_segments
ORDER BY segmentid



select * from sip_projects limit 10


select * FROM clion limit 10

select * FROM sip_treatments_geo limit 10










--official 2


-- Querying questions table to get qid's for specific treatments
-- Querying questions path table to get all descendants of desired treatments

WITH data as (
SELECT sq.qid, sq.question, sqp.*
FROM sip_questions sq
JOIN sip_questions_path sqp
ON sq.qid = sqp.ancestor
WHERE sq.question in ('New Crossings', 'Sidewalk Expansions', 'Ped Plaza', 'Neckdown', 'Ped Refuge Islands', 'Other Ped Space')
)

-- Needed: pid, tid, pjct_name, sip_year, start_date, end_date, pm, unit
-- Also grabbing segmentids and nodeids
-- Joining to lookup table (sl) to get status description
-- Joining to lookup table (su) to get unit description

,data2 as(

SELECT tid, question, pid_fk, pjct_name, sip_year, start_date, end_date, pm, unit, su.description, sl.description status_desc, segmentid::int, nodeid::int 
FROM( SELECT  distinct st.tid, data.question, st.pid_fk, sp.pjct_name, sp.sip_year, sp.start_date, sp.end_date, sp.pm, sp.unit, sp.status::int, segmentid::int, nodeid::int
      FROM sip_treatments st
      JOIN sip_projects sp
      ON st.pid_fk=sp.pid
      JOIN public.sip_treatments_geo stg
      ON st.tid=stg.tid_fk
      JOIN data 
      ON st.breadcrumbid = data.descendant
      and sp.status::int = 15
) sips
JOIN sip_lookup sl
ON sips.status = sl.lookupid
JOIN sip_lookup su
ON sips.unit = su.lookupid::varchar
)

SELECT * 
FROM data2
WHERE nodeid = 0

UNION

-- Grabbing all segments from clion ending in treatment nodeids

SELECT * FROM (
SELECT tid, question, pid_fk, pjct_name, sip_year, start_date, end_date, pm, unit, description, status_desc, cl.segmentid::int, nodeid 
FROM data2 d2
JOIN clion cl
ON d2.nodeid = cl.nodeidto::int
WHERE d2.nodeid != 0

UNION

SELECT tid, question, pid_fk, pjct_name, sip_year, start_date, end_date, pm, unit, description, status_desc, cl.segmentid::int, nodeid
FROM data2 d2
JOIN clion cl
ON d2.nodeid = cl.nodeidfrom::int
WHERE d2.nodeid != 0
)nodes_to_segments
ORDER BY segmentid

