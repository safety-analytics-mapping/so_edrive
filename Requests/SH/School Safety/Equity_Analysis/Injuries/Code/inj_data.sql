
-- Raw # of student ped annd bike injuries at the NTA level  -----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS sse_student_pb_inj;
CREATE TEMP TABLE sse_student_pb_inj AS 

WITH inj AS(
    SELECT DISTINCT
        nta.ntacode
        , nys_a.crashid
        , num_of_inj
        , boro             
    FROM nysdot_all nys_a
    JOIN (
        SELECT nys_v.crashid, age 
        FROM (
            SELECT distinct crashid
            FROM nysdot_vehicle
            WHERE veh_typ in ('5','6')
            GROUP by crashid
            HAVING count(crashid) = 1
        ) nys_v
        JOIN nysdot_vehicle nys_v_age
        on nys_v.crashid = nys_v_age.crashid
        WHERE veh_typ in ('5','6')
        AND age between 1 and 17
    ) ages
    on nys_a.crashid = ages.crashid
    JOIN lion l
    on nys_a.mft = l.mft
    JOIN public.districts_neighborhood_tabulation_areas nta
    ON nta.ntacode in (l.rntacode, l.lntacode) 
    WHERE  nys_a.case_yr>= 2014 and nys_a.case_yr<=2018
    AND accd_type_int in (1,2)
    AND nys_a.exclude = 0

    UNION 

    SELECT DISTINCT
        nta.ntacode
        , nys_a.crashid
        , num_of_inj
        , boro          
    FROM nysdot_all nys_a
    JOIN (
        SELECT nys_v.crashid, age 
        FROM (
            SELECT distinct crashid
            FROM nysdot_vehicle
            WHERE veh_typ in ('5','6')
            GROUP by crashid
            HAVING count(crashid) = 1
        ) nys_v
        JOIN nysdot_vehicle nys_v_age
        on nys_v.crashid = nys_v_age.crashid
        WHERE veh_typ in ('5','6')
        AND age between 1 and 17
    ) ages
    on nys_a.crashid = ages.crashid
    JOIN nta_node nta
    ON nys_a.masterid = nta.masterid
    WHERE  nys_a.case_yr>= 2014 and nys_a.case_yr<=2018
    AND accd_type_int in (1,2)
    AND nys_a.exclude = 0

)

SELECT DISTINCT 
    _inj_.ntacode, 
    boro, 
    sum(injuries) inj, 
    nta.geom
FROM (
	SELECT 
        inj.ntacode,
        inj.boro, 
        coalesce(sum(num_of_inj),0) injuries 
	FROM inj
	GROUP BY inj.ntacode, inj.boro
) _inj_
LEFT JOIN public.districts_neighborhood_tabulation_areas nta
ON _inj_.ntacode =  nta.ntacode
GROUP BY _inj_.ntacode, boro, nta.geom
ORDER BY _inj_.ntacode;





-- Raw # of all ped and bike injuries  at the NTA level ---------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS sse_pb_inj;
CREATE TEMP TABLE sse_pb_inj AS 

WITH inj AS(
SELECT DISTINCT   
    nta.ntacode
    , crashid
    , num_of_inj
    , 0 as "Fatalities"
    , boro             
FROM nysdot_all nys_a
JOIN lion l
on nys_a.mft = l.mft
JOIN public.districts_neighborhood_tabulation_areas nta
ON nta.ntacode in (l.rntacode, l.lntacode) 
WHERE  nys_a.case_yr>= 2014 and nys_a.case_yr<=2018
AND accd_type_int in (1,2)
AND nys_a.exclude = 0 


UNION 

SELECT DISTINCT   
    nta.ntacode
    , crashid
    , num_of_inj
    , 0 as "Fatalities"
    , boro          
FROM nysdot_all nys_a
JOIN nta_node nta
ON nys_a.masterid = nta.masterid
WHERE  nys_a.case_yr>= 2014 and nys_a.case_yr<=2018
AND accd_type_int in (1,2)
AND nys_a.exclude = 0

)




SELECT DISTINCT 
    _inj_.ntacode, 
    boro, 
    sum(injuries) inj, 
    nta.geom
FROM (
	SELECT 
        inj.ntacode, 
        inj.boro, 
        coalesce(sum(num_of_inj),0) injuries
	FROM inj
	GROUP BY inj.ntacode, inj.boro
	
) _inj_
LEFT JOIN public.districts_neighborhood_tabulation_areas nta
ON _inj_.ntacode =  nta.ntacode
GROUP BY _inj_.ntacode, boro, nta.geom
ORDER BY _inj_.ntacode;





-- 1. Youth injuries per adult injuries at the NTA level ---------------------------------------------------------------

DROP TABLE IF EXISTS sse_pb_inj_rate;
CREATE TEMP TABLE sse_pb_inj_rate AS

SELECT spb.ntacode, spb.inj::decimal/pb.inj * 100 inj_rate, spb.geom
FROM sse_student_pb_inj spb
JOIN sse_pb_inj pb
ON spb.ntacode = pb.ntacode
ORDER BY ntacode;





-- 2. Youth injuries per student enrollment at the NTA level -----------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS site_nta;
CREATE TEMP TABLE site_nta as
WITH site_enr AS(
SELECT  beds -- school branch
       ,count(distinct oem_id) AS site_ct -- school site count
       ,enrollment
       -- school branch can have different sites but enrollment is total branch enrollment
       -- so total enrollment here is averaged by sites
       ,enrollment/count(distinct oem_id) AS site_enr
       ,up_date 
from  working.ss_schools
where (ss_flag!= 'Closed')
group by beds, enrollment, up_date
order by site_ct desc),
school_nta as(
-- grabs school branch enrollment averaged by site and for each nta
SELECT  DISTINCT nta.ntacode
                  ,ss.oem_id
                  ,ss.beds
                  ,site_enr.site_enr
FROM working.ss_schools ss
LEFT JOIN public.districts_neighborhood_tabulation_areas nta
ON st_intersects(ss.geom, nta.geom)
LEFT JOIN site_enr 
ON ss.beds=site_enr.beds
WHERE ss_flag!='Closed')
SELECT * FROM school_nta;



DROP TABLE IF EXISTS sse_student_inj_enroll;
CREATE TEMP TABLE sse_student_inj_enroll AS 

SELECT spb.ntacode, spb.inj, (spb.inj::decimal)/sum(site_enr)*100 "inj/enrollment", spb.boro, spb.geom
FROM sse_student_pb_inj spb
JOIN site_nta snta
ON spb.ntacode = snta.ntacode
GROUP BY spb.ntacode,spb.inj,spb.boro,spb.geom 


-- 3. Youth injuries per sq mi at the NTA level -----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS sse_student_pb_inj_sqm;
CREATE TEMP TABLE sse_student_pb_inj_sqm AS 

WITH inj AS(
    SELECT DISTINCT
        nta.ntacode
        , nys_a.crashid
        , num_of_inj
        , boro             
    FROM nysdot_all nys_a
    JOIN (
        SELECT nys_v.crashid, age 
        FROM (
            SELECT distinct crashid
            FROM nysdot_vehicle
            WHERE veh_typ in ('5','6')
            GROUP by crashid
            HAVING count(crashid) = 1
        ) nys_v
        JOIN nysdot_vehicle nys_v_age
        on nys_v.crashid = nys_v_age.crashid
        WHERE veh_typ in ('5','6')
        AND age between 1 and 17
    ) ages
    on nys_a.crashid = ages.crashid
    JOIN lion l
    on nys_a.mft = l.mft
    JOIN public.districts_neighborhood_tabulation_areas nta
    ON nta.ntacode in (l.rntacode, l.lntacode) 
    WHERE  nys_a.case_yr>= 2014 and nys_a.case_yr<=2018
    AND accd_type_int in (1,2)
    AND nys_a.exclude = 0

    UNION 

    SELECT DISTINCT
        nta.ntacode
        , nys_a.crashid
        , num_of_inj
        , boro          
    FROM nysdot_all nys_a
    JOIN (
        SELECT nys_v.crashid, age 
        FROM (
            SELECT distinct crashid
            FROM nysdot_vehicle
            WHERE veh_typ in ('5','6')
            GROUP by crashid
            HAVING count(crashid) = 1
        ) nys_v
        JOIN nysdot_vehicle nys_v_age
        on nys_v.crashid = nys_v_age.crashid
        WHERE veh_typ in ('5','6')
        AND age between 1 and 17
    ) ages
    on nys_a.crashid = ages.crashid
    JOIN nta_node nta
    ON nys_a.masterid = nta.masterid
    WHERE  nys_a.case_yr>= 2014 and nys_a.case_yr<=2018
    AND accd_type_int in (1,2)
    AND nys_a.exclude = 0

)


SELECT DISTINCT 
    _inj_.ntacode,
    boro, 
    (sum(injuries))/(ST_AREA(nta.geom)/5280^2) "inj/sqm",
    nta.geom
FROM (
	SELECT 
        inj.ntacode,
        inj.boro, 
        coalesce(sum(num_of_inj),0) injuries 
	FROM inj
	GROUP BY inj.ntacode, inj.boro
) _inj_
LEFT JOIN public.districts_neighborhood_tabulation_areas nta
ON _inj_.ntacode =  nta.ntacode
GROUP BY _inj_.ntacode, boro, nta.geom
ORDER BY ntacode;















-- Creating Tables for mapping -----------------------------------------------------------------------------------------------------


DROP TABLE IF EXISTS working.sse_student_pb_inj;
CREATE TABLE working.sse_student_pb_inj AS

SELECT * FROM sse_student_pb_inj;

GRANT ALL ON working.sse_student_pb_inj TO PUBLIC;



DROP TABLE IF EXISTS working.sse_pb_inj;
CREATE TABLE working.sse_pb_inj AS

SELECT * FROM sse_pb_inj;

GRANT ALL ON working.sse_pb_inj TO PUBLIC;


DROP TABLE IF EXISTS working.sse_pb_inj_rate;
CREATE TABLE working.sse_pb_inj_rate AS

SELECT * FROM sse_pb_inj_rate;

GRANT ALL ON working.sse_pb_inj_rate TO PUBLIC;


DROP TABLE IF EXISTS working.sse_student_pb_inj_sqm;
CREATE TABLE working.sse_student_pb_inj_sqm AS

SELECT * FROM sse_student_pb_inj_sqm;

GRANT ALL ON working.sse_student_pb_inj_sqm TO PUBLIC;


DROP TABLE IF EXISTS working.sse_student_inj_enroll;
CREATE TABLE working.sse_student_inj_enroll AS

SELECT * FROM sse_student_inj_enroll;

GRANT ALL ON working.sse_student_inj_enroll TO PUBLIC; 

insert into working.__temp_log_table_soge__
    (table_owner, table_schema, table_name, created_on, expires)
values 
    ('soge', 'working', 'sse_pb_inj_rate', '2021-06-11', '2021-06-30'),  
    ('soge', 'working', 'sse_pb_inj', '2021-06-11', '2021-06-30'),
    ('soge', 'working', 'sse_student_pb_inj', '2021-06-11', '2021-06-30'),
    ('soge', 'working', 'sse_student_pb_inj_sqm', '2021-06-11', '2021-06-30');












