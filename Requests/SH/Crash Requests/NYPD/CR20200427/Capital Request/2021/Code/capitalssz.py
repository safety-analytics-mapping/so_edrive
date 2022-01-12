from ris import pysqldb
import datetime
import pandas as pd


timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
ts = datetime.datetime.now().strftime('%Y-%m-%d')


try:
    db.params['user']
except:
    db = pysqldb.DbConnect(type='PG', server='DOTDEVRHPGSQL01', database='ris')


# -- SHAPE SEVERITY ---------------------------------------------------------

db.query("""

--TEMP TABLE CREATION---------------------------------------------------

DROP TABLE IF EXISTS working.nys_dot_hwk; 
CREATE TABLE working.nys_dot_hwk AS 

WITH data AS(
SELECT DISTINCT hwk.fmsid, node.nodeid nid, node.masterid mid
FROM working.hwk100sbc hwk
JOIN node 
ON ST_DWithin(hwk.geom,node.geom, 5)
)

SELECT DISTINCT nys_a.*, d.fmsid, d.mid
FROM nysdot_all nys_a
JOIN (SELECT DISTINCT fmsid, nid, mid 
     FROM data) d 
ON nys_a.masterid::int = d.mid::int
WHERE exclude = 0
and case_yr between 2014 and 2018;

GRANT ALL ON working.nys_dot_hwk TO PUBLIC

""")


fmsid_sev_req.to_excel('C:\Users\soge\Desktop\GitHub\MiscRequests\Capital_SSZ\south brooklyn capital_{}.xlsx'.format(ts),index=False)




# -- SIP SEVERITY ---------------------------------------------------------

db.query("""

--SIP TEMP TABLE CREATION---------------------------------------------------

DROP TABLE IF EXISTS working.nys_dot_sip_hwk100sbc; 
CREATE TABLE working.nys_dot_sip_hwk100sbc AS 

WITH data AS(
SELECT DISTINCT pid, pjct_name, n.masterid mid
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
JOIN node n
ON n.nodeid::int = l.nodeidfrom::int or n.nodeid::int = l.nodeidto::int 
WHERE pid in (1397,1398,1399)
)

SELECT DISTINCT nys_a.*, d.*
FROM nysdot_all nys_a
JOIN (SELECT DISTINCT pid, pjct_name, mid 
     FROM data) d 
ON nys_a.masterid::int = d.mid::int
WHERE exclude = 0
and case_yr between 2014 and 2018;

GRANT ALL ON working.nys_dot_sip_hwk100sbc TO PUBLIC

""")


sev_req = db.dfquery("""

--SEVERITY Control by KABCO---------------------------------------------------



WITH data AS(

SELECT pid, pjct_name, mid, sum("ped_A") "ped_A", sum("ped_B") "ped_B", sum("ped_C") "ped_C", sum("ped_PDO") "ped_PDO", sum("ped_UNKNOWN") "ped_UNKNOWN", sum("ped_K") "ped_K", 
                   sum("bike_A") "bike_A", sum("bike_B") "bike_B", sum("bike_C") "bike_C", sum("bike_PDO") "bike_PDO", sum("bike_UNKNOWN") "bike_UNKNOWN", sum("bike_K") "bike_K", 
                   sum("mvo_A") "mvo_A", sum("mvo_B") "mvo_B", sum("mvo_C") "mvo_C", sum("mvo_PDO") "mvo_PDO", sum("mvo_UNKNOWN") "mvo_UNKNOWN", sum("mvo_K") "mvo_K"

FROM(   SELECT sip_hwk.pid, sip_hwk.pjct_name, sip_hwk.mid::int
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

        FROM working.nys_dot_sip_hwk100sbc sip_hwk
        GROUP BY sip_hwk.pid, sip_hwk.pjct_name, sip_hwk.mid

        UNION ALL

        SELECT sip_hwk.pid
              ,sip_hwk.pjct_name 
              ,sip_hwk.mid::int 
              ,0 as "ped_A",0 as "ped_B",0 as "ped_C", 0 as "ped_PDO", 0 as "ped_UNKNOWN"
              ,sum(CASE WHEN mode = 'PD' THEN 1 END) "ped_K"        
              ,0 as "bike_A",0 as "bike_B",0 as "bike_C", 0 as "bike_PDO", 0 as "bike_UNKNOWN"  
              ,sum(CASE WHEN mode = 'BI' THEN 1 END) "bike_K"
              ,0 as "mvo_A",0 as "mvo_B",0 as "mvo_C", 0 as "mvo_PDO", 0 as "mvo_UNKNOWN"		  
              ,sum(CASE WHEN mode in ('DR', 'PS', 'MO') THEN 1 END) "mvo_K"             
        FROM public.fatal_crash fc
        JOIN public.fatal_victim fv
        ON fc.fid = fv.fid
        JOIN (SELECT DISTINCT pid, pjct_name,mid FROM working.nys_dot_sip_hwk100sbc) sip_hwk
        ON fc.masterid = sip_hwk.mid
        AND left(ac_date,4)::int between 2014 and 2018
        GROUP BY sip_hwk.pid, sip_hwk.pjct_name, sip_hwk.mid, fc.fid, fv.mode) x
GROUP BY pid, pjct_name, mid
ORDER BY pid, pjct_name, mid
)


,data2 AS(
SELECT * FROM ( SELECT data.*, "ped_A" + "ped_B" + "ped_C" + "ped_UNKNOWN" + "ped_K" +
                               "bike_A" + "bike_B" + "bike_C" + "bike_UNKNOWN" + "bike_K" +
                               "mvo_A" + "mvo_B" + "mvo_C" + "mvo_UNKNOWN" + "mvo_K" as "Total (Injuries + Fatalities)"
                FROM data

                UNION 

                SELECT tot.*, "ped_A" + "ped_B" + "ped_C" + "ped_UNKNOWN" + "ped_K" + 
                              "bike_A" + "bike_B" + "bike_C" + "bike_UNKNOWN" + "bike_K" +
                              "mvo_A" + "mvo_B" + "mvo_C" + "mvo_UNKNOWN" + "mvo_K" "Total (Injuries + Fatalities)"
                FROM (SELECT 0 as pid
                      ,'total' as pjct_name
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

        )sip_sev
ORDER BY mid
)

SELECT d2.*, sn.all_streets[1] street1, sn.all_streets[2] street2
FROM data2 d2
LEFT JOIN (SELECT masterid, array_agg(distinct all_streets) all_streets
	   FROM(  SELECT masterid, unnest(all_streets) all_streets
		      FROM public.node_street_names sn
		      JOIN node n 
		      ON n.nodeid= sn.node) st
              GROUP BY masterid
	   ) sn
ON d2.mid = sn.masterid
ORDER BY pjct_name, mid

""")



sev_req.to_excel('C:\Users\soge\Desktop\GitHub\MiscRequests\Capital_SSZ\south brooklyn sip_{}.xlsx'.format(ts),index=False)
