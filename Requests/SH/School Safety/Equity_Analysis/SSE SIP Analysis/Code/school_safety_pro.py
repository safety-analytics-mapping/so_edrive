import datetime

from ris import pysqldb

timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
ts = datetime.datetime.now().strftime('%Y-%m-%d')

db = pysqldb.DbConnect(user='soge', type='PG', server='dotdevrhpgsql01', database='ris', allow_temp_tables='True')


# Creating temp table for nta mileage
db.query("""

--NTA MILEAGE
DROP TABLE IF EXISTS lion_nta;
CREATE TEMP TABLE lion_nta AS
SELECT nta_code, sum(coalesce((st_length(geom)::decimal/5280),0)) miles
FROM ( SELECT distinct l.geom, l.lntacode nta_code
       FROM lion l
       WHERE mft is not null
       AND rb_layer in ('G','B')

       UNION 

       SELECT distinct l.geom, l.rntacode nta_code
       FROM lion l
       WHERE mft is not null
       AND rb_layer in ('G','B')   
       ) t
       group by nta_code
       
""")


# Creating temp table for sip mileage
db.query("""

--SIP MILEAGE BY NTA
DROP TABLE IF EXISTS sip_nta;
CREATE TEMP TABLE sip_nta AS

SELECT nta.ntacode nta_code, sum(coalesce((st_length(l.geom)::decimal/5280),0)) miles
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
JOIN public.districts_neighborhood_tabulation_areas nta
ON nta.ntacode in (l.rntacode, l.lntacode)  
WHERE unit_desc like 'School Safety'
group by ntacode

""")



#Main table for querying
db.query_to_csv("""


--MAIN TABLE AT NTA LEVEL
WITH data AS(
SELECT DISTINCT lnta.nta_code 
               ,snta.miles sip_miles
               ,lnta.miles nta_miles
               ,nta_summary."white quintile"
               ,nta_summary."black quintile"
               ,nta_summary."asian quintile"
               ,nta_summary."hispanic quintile"
               ,nta_summary."other quintile"
FROM lion_nta lnta
LEFT JOIN working.v_nta_summary_map nta_summary
ON lnta.nta_code = nta_summary.ntacode
LEFT JOIN sip_nta snta
ON lnta.nta_code = snta.nta_code
)

,d2 AS (
SELECT "white quintile" Quintile, sum(sip_miles) w_tot_sip_miles, sum(nta_miles) w_tot_nta_miles
FROM data
GROUP BY "white quintile"
)

,d3 AS (
SELECT "black quintile" Quintile, sum(sip_miles) b_tot_sip_miles, sum(nta_miles) b_tot_nta_miles
FROM data
GROUP BY "black quintile"
)

,d4 AS (
SELECT "asian quintile" Quintile, sum(sip_miles) a_tot_sip_miles, sum(nta_miles) a_tot_nta_miles
FROM data
GROUP BY "asian quintile"
)

,d5 AS (
SELECT "hispanic quintile" Quintile, sum(sip_miles) h_tot_sip_miles, sum(nta_miles) h_tot_nta_miles
FROM data
GROUP BY "hispanic quintile"
)

,d6 AS (
SELECT "other quintile" Quintile, sum(sip_miles) o_tot_sip_miles, sum(nta_miles) o_tot_nta_miles
FROM data
GROUP BY "other quintile"
)


SELECT CASE WHEN d2.quintile = 1 THEN '0 - 20%'
	    WHEN d2.quintile = 2 THEN '20 - 40%'
	    WHEN d2.quintile = 3 THEN '40 - 60%'
	    WHEN d2.quintile = 4 THEN '60 - 80%'
	    WHEN d2.quintile = 5 THEN '80 - 100%' END AS "% Population" 
	  , w_tot_sip_miles 
	  , w_tot_nta_miles 
	  , b_tot_sip_miles 
	  , b_tot_nta_miles 	  
	  , a_tot_sip_miles 
	  , a_tot_nta_miles 	  
	  , h_tot_sip_miles
	  , h_tot_nta_miles 	   
	  , o_tot_sip_miles 
	  , o_tot_nta_miles 
FROM d2
JOIN d3
ON d2.quintile = d3.quintile
JOIN d4
ON d2.quintile = d4.quintile
JOIN d5
ON d2.quintile = d5.quintile
JOIN d6
ON d2.quintile = d6.quintile
ORDER BY d2.quintile

           
""")


#UPDATE