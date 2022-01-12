DROP TABLE IF EXISTS nys_dot_sscp; 
CREATE TABLE nys_dot_sscp AS 

WITH data AS(
SELECT sscp.fmsid, nodeid, masterid mid
FROM working."20200401_Active_School_Safety_Capital_Intersections" sscp
LEFT JOIN archive."18d.2019-11-13_node" node
ON ST_DWithin(sscp.geom,node.geom, 1)

UNION

--Manually overriding this project at this location

--Node selected for the project was not a real intersection 
--and had no near nodes that were real and were in the project

--Manually inserted a real intersection with an actual masterid 
--that was at the location 

SELECT 'HWCSCH4D'fmsid, 43877 nodeid, 43877 mid
)

SELECT DISTINCT nys_a.*, d.fmsid, d.mid
FROM archive."2019_11_13_nysdot_all" nys_a
JOIN (SELECT DISTINCT fmsid, mid 
     FROM data) d 
ON nys_a.masterid::int = d.mid::int
WHERE exclude = 0
AND case_yr between 2013 and 2017
AND nys_a.masterid::int = 48682;

GRANT ALL on nys_dot_sscp to public;







WITH data AS(

SELECT fmsid, mid, sum("ped_A") "ped_A", sum("ped_B") "ped_B", sum("ped_C") "ped_C", sum("ped_PDO") "ped_PDO", sum("ped_UNKNOWN") "ped_UNKNOWN", sum("ped_K") "ped_K", 
                   sum("bike_A") "bike_A", sum("bike_B") "bike_B", sum("bike_C") "bike_C", sum("bike_PDO") "bike_PDO", sum("bike_UNKNOWN") "bike_UNKNOWN", sum("bike_K") "bike_K", 
                   sum("mvo_A") "mvo_A", sum("mvo_B") "mvo_B", sum("mvo_C") "mvo_C", sum("mvo_PDO") "mvo_PDO", sum("mvo_UNKNOWN") "mvo_UNKNOWN", sum("mvo_K") "mvo_K"

FROM(   SELECT fmsid, mid::int
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' and accd_type_int = 1 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "ped_A"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%B%' and accd_type_int = 1 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) END),0) AS"ped_B"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%C%' and accd_type_int = 1 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) END),0) AS "ped_C"
        ,coalesce(sum(CASE WHEN (coalesce(length(ext_of_inj::text),0) != num_of_inj + num_of_fat) and accd_type_int = 1 THEN (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0) END),0) AS "ped_UNKNOWN"
        ,coalesce(sum(CASE WHEN (num_of_inj + num_of_fat=0) and accd_type_int = 1 THEN 1 END),0) AS "ped_PDO"
        ,0 as "ped_K"

        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' and accd_type_int = 2 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "bike_A"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%B%' and accd_type_int = 2 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) END),0) AS"bike_B"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%C%' and accd_type_int = 2 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) END),0) AS "bike_C"    
        ,coalesce(sum(CASE WHEN (coalesce(length(ext_of_inj::text),0) != num_of_inj + num_of_fat) and accd_type_int = 2 THEN (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0) END),0) AS "bike_UNKNOWN"
        ,coalesce(sum(CASE WHEN (num_of_inj + num_of_fat=0) and accd_type_int = 2 THEN 1 END),0) AS "bike_PDO"
        ,0 as "bike_K"

        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' and accd_type_int = 3 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "mvo_A"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%B%' and accd_type_int = 3 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) END),0) AS"mvo_B"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%C%' and accd_type_int = 3 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) END),0) AS "mvo_C"
        ,coalesce(sum(CASE WHEN (coalesce(length(ext_of_inj::text),0) != num_of_inj + num_of_fat) and accd_type_int = 3 THEN (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0) END),0) AS "mvo_UNKNOWN"
        ,coalesce(sum(CASE WHEN (num_of_inj + num_of_fat=0) and accd_type_int = 3 THEN 1 END),0) AS "mvo_PDO"
        ,0 as "mvo_K"

        FROM nys_dot_sscp
        WHERE fmsid in('HWCSCH98')
        GROUP BY fmsid, mid

        Union ALL

        SELECT sscp.fmsid 
              ,mid::int 
              ,0 as "ped_A",0 as "ped_B",0 as "ped_C", 0 as "ped_PDO", 0 as "ped_UNKNOWN"
              ,sum(CASE WHEN pos = 'PD' THEN 1 END) "ped_K"        
              ,0 as "bike_A",0 as "bike_B",0 as "bike_C", 0 as "bike_PDO", 0 as "bike_UNKNOWN"  
              ,sum(CASE WHEN pos = 'BI' THEN 1 END) "bike_K"
              ,0 as "mvo_A",0 as "mvo_B",0 as "mvo_C", 0 as "mvo_PDO", 0 as "mvo_UNKNOWN"		  
              ,sum(CASE WHEN pos in ('DR', 'PS', 'MO') THEN 1 END) "mvo_K"

        FROM fatality_nycdot_current fat
        JOIN (SELECT distinct mid, fmsid
              FROM nys_dot_sscp) sscp
        ON fat.masterid = sscp.mid
        and date_part('year',acdate) between 2013 and 2017
        WHERE fmsid in ('HWCSCH98')
        GROUP BY sscp.fmsid, mid) x
GROUP BY fmsid, mid
ORDER BY mid
)

SELECT * FROM ( SELECT data.*, "ped_A" + "ped_B" + "ped_C" + "ped_UNKNOWN" + "ped_K" +
                               "bike_A" + "bike_B" + "bike_C" + "bike_UNKNOWN" + "bike_K" +
                               "mvo_A" + "mvo_B" + "mvo_C" + "mvo_UNKNOWN" + "mvo_K" as "Total (Injuries + Fatalities)"
                FROM data

                UNION 

                SELECT tot.*, "ped_A" + "ped_B" + "ped_C" + "ped_UNKNOWN" + "ped_K" + 
                              "bike_A" + "bike_B" + "bike_C" + "bike_UNKNOWN" + "bike_K" +
                              "mvo_A" + "mvo_B" + "mvo_C" + "mvo_UNKNOWN" + "mvo_K" "Total (Injuries + Fatalities)"
                FROM (SELECT 'Total' as "fmsid" 
                      ,0 as mid
                      ,sum(data."ped_A") "ped_A"
                      ,sum(data."ped_B") "ped_B"
                      ,sum(data."ped_C") "ped_C"
                      ,sum(data."ped_PDO") "ped_PDO"
                      ,sum(data."ped_UNKNOWN") "ped_UNKNOWN"
                      ,sum(data."ped_K") "ped_K"

                      ,sum(data."bike_A") "bike_A"
                      ,sum(data."bike_B") "bike_B"
                      ,sum(data."bike_C") "bike_C"
                      ,sum(data."bike_PDO") "bike_PDO"
                      ,sum(data."bike_UNKNOWN") "bike_UNKNOWN"
                      ,sum(data."bike_K") "bike_K"

                      ,sum(data."mvo_A") "mvo_A"
                      ,sum(data."mvo_B") "mvo_B"
                      ,sum(data."mvo_C") "mvo_C"
                      ,sum(data."mvo_PDO") "mvo_PDO"
                      ,sum(data."mvo_UNKNOWN") "mvo_UNKNOWN"
                      ,sum(data."mvo_K") "mvo_K"
                      FROM data
                    ) tot

        )fmsid_sev
ORDER BY "fmsid"

















--FMSID Control by KABCO---------------------------------------------------


WITH data AS(

SELECT masterid::text, sum("ped_A") "ped_A", sum("ped_B") "ped_B", sum("ped_C") "ped_C", sum("ped_PDO") "ped_PDO", sum("ped_UNKNOWN") "ped_UNKNOWN", sum("ped_K") "ped_K", 
                   sum("bike_A") "bike_A", sum("bike_B") "bike_B", sum("bike_C") "bike_C", sum("bike_PDO") "bike_PDO", sum("bike_UNKNOWN") "bike_UNKNOWN", sum("bike_K") "bike_K", 
                   sum("mvo_A") "mvo_A", sum("mvo_B") "mvo_B", sum("mvo_C") "mvo_C", sum("mvo_PDO") "mvo_PDO", sum("mvo_UNKNOWN") "mvo_UNKNOWN", sum("mvo_K") "mvo_K"

FROM(   SELECT masterid
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' and accd_type_int = 1 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "ped_A"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%B%' and accd_type_int = 1 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) END),0) AS"ped_B"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%C%' and accd_type_int = 1 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) END),0) AS "ped_C"
        ,coalesce(sum(CASE WHEN (coalesce(length(ext_of_inj::text),0) != num_of_inj + num_of_fat) and accd_type_int = 1 THEN (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0) END),0) AS "ped_UNKNOWN"
        ,coalesce(sum(CASE WHEN (num_of_inj + num_of_fat=0) and accd_type_int = 1 THEN 1 END),0) AS "ped_PDO"
        ,0 as "ped_K"

        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' and accd_type_int = 2 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "bike_A"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%B%' and accd_type_int = 2 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) END),0) AS"bike_B"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%C%' and accd_type_int = 2 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) END),0) AS "bike_C"    
        ,coalesce(sum(CASE WHEN (coalesce(length(ext_of_inj::text),0) != num_of_inj + num_of_fat) and accd_type_int = 2 THEN (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0) END),0) AS "bike_UNKNOWN"
        ,coalesce(sum(CASE WHEN (num_of_inj + num_of_fat=0) and accd_type_int = 2 THEN 1 END),0) AS "bike_PDO"
        ,0 as "bike_K"

        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' and accd_type_int = 3 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "mvo_A"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%B%' and accd_type_int = 3 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) END),0) AS"mvo_B"
        ,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%C%' and accd_type_int = 3 THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) END),0) AS "mvo_C"
        ,coalesce(sum(CASE WHEN (coalesce(length(ext_of_inj::text),0) != num_of_inj + num_of_fat) and accd_type_int = 3 THEN (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0) END),0) AS "mvo_UNKNOWN"
        ,coalesce(sum(CASE WHEN (num_of_inj + num_of_fat=0) and accd_type_int = 3 THEN 1 END),0) AS "mvo_PDO"
        ,0 as "mvo_K"

        FROM archive."2019_11_13_nysdot_all" nys_a
	WHERE exclude = 0
	AND case_yr between 2013 and 2017
	AND nys_a.masterid::int = 48682
	GROUP BY masterid
       
        Union ALL

        SELECT masterid::int 
              ,0 as "ped_A",0 as "ped_B",0 as "ped_C", 0 as "ped_PDO", 0 as "ped_UNKNOWN"
              ,sum(CASE WHEN pos = 'PD' THEN 1 END) "ped_K"        
              ,0 as "bike_A",0 as "bike_B",0 as "bike_C", 0 as "bike_PDO", 0 as "bike_UNKNOWN"  
              ,sum(CASE WHEN pos = 'BI' THEN 1 END) "bike_K"
              ,0 as "mvo_A",0 as "mvo_B",0 as "mvo_C", 0 as "mvo_PDO", 0 as "mvo_UNKNOWN"		  
              ,sum(CASE WHEN pos in ('DR', 'PS', 'MO') THEN 1 END) "mvo_K"

        FROM fatality_nycdot_current fat
        WHERE masterid::int = 48682
        and date_part('year',acdate) between 2013 and 2017
        GROUP BY masterid) x
GROUP BY masterid
--ORDER BY mid
)

SELECT * FROM ( SELECT data.*, "ped_A" + "ped_B" + "ped_C" + "ped_UNKNOWN" + "ped_K" +
                               "bike_A" + "bike_B" + "bike_C" + "bike_UNKNOWN" + "bike_K" +
                               "mvo_A" + "mvo_B" + "mvo_C" + "mvo_UNKNOWN" + "mvo_K" as "Total (Injuries + Fatalities)"
                FROM data

                UNION 

                SELECT tot.*, "ped_A" + "ped_B" + "ped_C" + "ped_UNKNOWN" + "ped_K" + 
                              "bike_A" + "bike_B" + "bike_C" + "bike_UNKNOWN" + "bike_K" +
                              "mvo_A" + "mvo_B" + "mvo_C" + "mvo_UNKNOWN" + "mvo_K" "Total (Injuries + Fatalities)"
                FROM (SELECT 'Total' as masterid
                      ,sum(data."ped_A") "ped_A"
                      ,sum(data."ped_B") "ped_B"
                      ,sum(data."ped_C") "ped_C"
                      ,sum(data."ped_PDO") "ped_PDO"
                      ,sum(data."ped_UNKNOWN") "ped_UNKNOWN"
                      ,sum(data."ped_K") "ped_K"

                      ,sum(data."bike_A") "bike_A"
                      ,sum(data."bike_B") "bike_B"
                      ,sum(data."bike_C") "bike_C"
                      ,sum(data."bike_PDO") "bike_PDO"
                      ,sum(data."bike_UNKNOWN") "bike_UNKNOWN"
                      ,sum(data."bike_K") "bike_K"

                      ,sum(data."mvo_A") "mvo_A"
                      ,sum(data."mvo_B") "mvo_B"
                      ,sum(data."mvo_C") "mvo_C"
                      ,sum(data."mvo_PDO") "mvo_PDO"
                      ,sum(data."mvo_UNKNOWN") "mvo_UNKNOWN"
                      ,sum(data."mvo_K") "mvo_K"
                      FROM data
                    ) tot

        )cap



