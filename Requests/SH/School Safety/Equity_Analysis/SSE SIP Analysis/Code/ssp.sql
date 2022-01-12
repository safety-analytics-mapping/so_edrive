SELECT sp.pid, sum(coalesce(st_length(l.geom)/5280,0)) mileage, nta_summary.poverty_group
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
JOIN public.districts_neighborhood_tabulation_areas nta
ON nta.ntacode in (l.rntacode, l.lntacode) 
JOIN working.v_nta_summary_map nta_summary
ON nta.ntacode = nta_summary.ntacode
WHERE unit_desc like 'School Safety'
GROUP BY nta_summary.poverty_group

-- SELECT * FROM working.v_nta_summary_map limit 100

nta.ntacode in (l.rntacode, l.lntacode) 



SELECT sp.pid, sum(coalesce(st_length(l.geom)/5280,0)) mileage, "nta_summary.total pop from race"
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
JOIN public.districts_neighborhood_tabulation_areas nta
ON nta.ntacode in (l.rntacode, l.lntacode) 
JOIN working.v_nta_summary_map nta_summary
ON nta.ntacode = nta_summary.ntacode
WHERE unit_desc like 'School Safety'
GROUP BY sp.pid, "nta_summary.total pop from race"
ORDER BY sp.pid










--BY POVERTY 

WITH data AS(
SELECT CASE WHEN nta_summary.poverty_group like 'Very High Poverty (≥30% FPL)' THEN 4 
	    WHEN nta_summary.poverty_group like 'High Poverty (20% to <30% FPL)' THEN 3 
	    WHEN nta_summary.poverty_group like 'Medium Poverty (10% to <20% FPL)' THEN 2 
	    WHEN nta_summary.poverty_group like 'Low Poverty (<10% FPL)' THEN 1 END poverty
       , sum(coalesce(st_length(l.geom)/5280,0)) mileage    
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
JOIN public.districts_neighborhood_tabulation_areas nta
ON nta.ntacode in (l.rntacode, l.lntacode) 
JOIN working.v_nta_summary_map nta_summary
ON nta.ntacode = nta_summary.ntacode
WHERE unit_desc like 'School Safety'
GROUP BY CASE WHEN nta_summary.poverty_group like 'Very High Poverty (≥30% FPL)' THEN 4 
	    WHEN nta_summary.poverty_group like 'High Poverty (20% to <30% FPL)' THEN 3 
	    WHEN nta_summary.poverty_group like 'Medium Poverty (10% to <20% FPL)' THEN 2 
	    WHEN nta_summary.poverty_group like 'Low Poverty (<10% FPL)' THEN 1 END 
)

,data2 as(
SELECT sum(data.mileage) total_miles
FROM data
)

SELECT data.*, (data.mileage::decimal)/(sum(data2.total_miles)) "% of total sip mileage"
FROM data,data2
GROUP BY data.poverty, data.mileage
ORDER by data.poverty




--BY POVERTY OFF

WITH data AS(
SELECT nta_summary.poverty_group
       , sum(coalesce(st_length(l.geom)/5280,0)) mileage    
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
JOIN public.districts_neighborhood_tabulation_areas nta
ON nta.ntacode in (l.rntacode, l.lntacode) 
JOIN working.v_nta_summary_map nta_summary
ON nta.ntacode = nta_summary.ntacode
WHERE unit_desc like 'School Safety'
GROUP BY nta_summary.poverty_group
)

,data2 as(
SELECT sum(data.mileage) total_miles
FROM data
)

,data3 as(
SELECT sum(coalesce(st_length(l.geom)/5280,0)) total_miles   
FROM lion l
)

SELECT data.*, ((data.mileage::decimal)/(sum(data2.total_miles))) * 100 "% of total sip mileage", ((data.mileage::decimal)/(sum(data3.total_miles))) * 100 "% of total lion mileage"
FROM data,data2,data3
GROUP BY data.poverty_group, data.mileage
ORDER by data.poverty_group


DROP TABLE IF EXISTS lion_nta;
CREATE TEMP TABLE lion_nta AS

SELECT sum(coalesce(st_length(l.geom)/5280,0)) miles, l.lntacode nta_code
FROM lion l
WHERE mft is not null
AND rb_layer in ('G','B')
GROUP BY l.lntacode

UNION 

SELECT sum(coalesce(st_length(l.geom)/5280,0)), l.rntacode nta_code
FROM lion l
WHERE mft is not null
AND rb_layer in ('G','B')
GROUP BY l.rntacode

SELECT * FROM lion_nta


SELECT sum(coalesce(st_length(geom)/5280,0))
FROM lion
WHERE mft is not null
AND rb_layer in ('G','B')

-- BY WHITE POP

WITH data AS(
SELECT CASE WHEN nta_summary."white quintile" = 1 THEN '0 – 20%'
	    WHEN nta_summary."white quintile" = 2 THEN '20 – 40%'
	    WHEN nta_summary."white quintile" = 3 THEN '40 – 60%'
	    WHEN nta_summary."white quintile" = 4 THEN '60 – 80%'
	    WHEN nta_summary."white quintile" = 5 THEN '80 – 100%' END AS "White Population"
	    , sum(coalesce(st_length(l.geom)/5280,0)) mileage 
	    , sum(lion_nta.miles) nta_miles 
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
JOIN public.districts_neighborhood_tabulation_areas nta
ON nta.ntacode in (l.rntacode, l.lntacode) 
JOIN working.v_nta_summary_map nta_summary
ON nta.ntacode = nta_summary.ntacode
JOIN lion_nta 
ON nta.ntacode = lion_nta.nta_code
WHERE unit_desc like 'School Safety'
GROUP BY CASE WHEN nta_summary."white quintile" = 1 THEN '0 – 20%'
	      WHEN nta_summary."white quintile" = 2 THEN '20 – 40%'
	      WHEN nta_summary."white quintile" = 3 THEN '40 – 60%'
	      WHEN nta_summary."white quintile" = 4 THEN '60 – 80%'
	      WHEN nta_summary."white quintile" = 5 THEN '80 – 100%' END 
ORDER BY "White Population"
)

-- total sip miles
,data2 as(
SELECT sum(data.mileage) total_miles
FROM data
)

-- total lion miles
,data3 as(
SELECT sum(coalesce(st_length(l.geom)/5280,0)) total_miles   
FROM lion l
)

-- total lion miles by nta
,data4 as(
SELECT sum(coalesce(st_length(l.geom)/5280,0)) total_miles   
FROM lion l
WHERE mft is not null
AND rb_layer = 'R'
GROUP BY (l.rntacode, l.lntacode)
)

SELECT data.*, ((data.mileage::decimal)/(sum(data2.total_miles))) * 100 "% of total sip mileage"
             , ((data.mileage::decimal)/(sum(data3.total_miles))) * 100 "% of street covered"
             , (data4.total_miles)
FROM data, data2, data3, data4
GROUP BY data."White Population", data.mileage
ORDER by data."White Population"








--BY BLACK POP

WITH data AS(
SELECT CASE WHEN nta_summary."black quintile" = 1 THEN '0 – 20%'
	    WHEN nta_summary."black quintile" = 2 THEN '20 – 40%'
	    WHEN nta_summary."black quintile" = 3 THEN '40 – 60%'
	    WHEN nta_summary."black quintile" = 4 THEN '60 – 80%'
	    WHEN nta_summary."black quintile" = 5 THEN '80 – 100%' END AS "Black Population"
	    , sum(coalesce(st_length(l.geom)/5280,0)) mileage    
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
JOIN public.districts_neighborhood_tabulation_areas nta
ON nta.ntacode in (l.rntacode, l.lntacode) 
JOIN working.v_nta_summary_map nta_summary
ON nta.ntacode = nta_summary.ntacode
WHERE unit_desc like 'School Safety'
GROUP BY CASE WHEN nta_summary."black quintile" = 1 THEN '0 – 20%'
	    WHEN nta_summary."black quintile" = 2 THEN '20 – 40%'
	    WHEN nta_summary."black quintile" = 3 THEN '40 – 60%'
	    WHEN nta_summary."black quintile" = 4 THEN '60 – 80%'
	    WHEN nta_summary."black quintile" = 5 THEN '80 – 100%' END 
ORDER BY "Black Population"
)

,data2 as(
SELECT sum(data.mileage) total_miles
FROM data
)


,data3 as(
SELECT sum(coalesce(st_length(l.geom)/5280,0)) total_miles   
FROM lion l
)

SELECT data.*, ((data.mileage::decimal)/(sum(data2.total_miles))) * 100 "% of total sip mileage", ((data.mileage::decimal)/(sum(data3.total_miles))) * 100 "% of total lion mileage"
FROM data,data2,data3
GROUP BY data."Black Population", data.mileage
ORDER by data."Black Population"








--BY ASIAN POP

WITH data AS(
SELECT CASE WHEN nta_summary."asian quintile" = 1 THEN '0 – 20%'
	    WHEN nta_summary."asian quintile" = 2 THEN '20 – 40%'
	    WHEN nta_summary."asian quintile" = 3 THEN '40 – 60%'
	    WHEN nta_summary."asian quintile" = 4 THEN '60 – 80%'
	    WHEN nta_summary."asian quintile" = 5 THEN '80 – 100%' END AS "Asian Population"
	    , sum(coalesce(st_length(l.geom)/5280,0)) mileage    
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
JOIN public.districts_neighborhood_tabulation_areas nta
ON nta.ntacode in (l.rntacode, l.lntacode) 
JOIN working.v_nta_summary_map nta_summary
ON nta.ntacode = nta_summary.ntacode
WHERE unit_desc like 'School Safety'
GROUP BY CASE WHEN nta_summary."asian quintile" = 1 THEN '0 – 20%'
	    WHEN nta_summary."asian quintile" = 2 THEN '20 – 40%'
	    WHEN nta_summary."asian quintile" = 3 THEN '40 – 60%'
	    WHEN nta_summary."asian quintile" = 4 THEN '60 – 80%'
	    WHEN nta_summary."asian quintile" = 5 THEN '80 – 100%' END 
ORDER BY "Asian Population"
)

,data2 as(
SELECT sum(data.mileage) total_miles
FROM data
)

,data3 as(
SELECT sum(coalesce(st_length(l.geom)/5280,0)) total_miles   
FROM lion l
)

SELECT data.*, ((data.mileage::decimal)/(sum(data2.total_miles))) * 100 "% of total sip mileage", ((data.mileage::decimal)/(sum(data3.total_miles))) * 100 "% of total lion mileage"
FROM data,data2,data3
GROUP BY data."Asian Population", data.mileage
ORDER by data."Asian Population"








--BY HISPANIC POP

WITH data AS(
SELECT CASE WHEN nta_summary."hispanic quintile" = 1 THEN '0 – 20%'
	    WHEN nta_summary."hispanic quintile" = 2 THEN '20 – 40%'
	    WHEN nta_summary."hispanic quintile" = 3 THEN '40 – 60%'
	    WHEN nta_summary."hispanic quintile" = 4 THEN '60 – 80%'
	    WHEN nta_summary."hispanic quintile" = 5 THEN '80 – 100%' END AS "Hispanic Population"
	    , sum(coalesce(st_length(l.geom)/5280,0)) mileage    
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
JOIN public.districts_neighborhood_tabulation_areas nta
ON nta.ntacode in (l.rntacode, l.lntacode) 
JOIN working.v_nta_summary_map nta_summary
ON nta.ntacode = nta_summary.ntacode
WHERE unit_desc like 'School Safety'
GROUP BY CASE WHEN nta_summary."hispanic quintile" = 1 THEN '0 – 20%'
	    WHEN nta_summary."hispanic quintile" = 2 THEN '20 – 40%'
	    WHEN nta_summary."hispanic quintile" = 3 THEN '40 – 60%'
	    WHEN nta_summary."hispanic quintile" = 4 THEN '60 – 80%'
	    WHEN nta_summary."hispanic quintile" = 5 THEN '80 – 100%' END 
ORDER BY "Hispanic Population"
)

,data2 as(
SELECT sum(data.mileage) total_miles
FROM data
)

,data3 as(
SELECT sum(coalesce(st_length(l.geom)/5280,0)) total_miles   
FROM lion l
)

SELECT data.*, ((data.mileage::decimal)/(sum(data2.total_miles))) * 100 "% of total sip mileage", ((data.mileage::decimal)/(sum(data3.total_miles))) * 100 "% of total lion mileage"
FROM data,data2, data3
GROUP BY data."Hispanic Population", data.mileage
ORDER by data."Hispanic Population"









--BY OTHER POP

WITH data AS(
SELECT CASE WHEN nta_summary."other quintile" = 1 THEN '0 – 20%'
	    WHEN nta_summary."other quintile" = 2 THEN '20 – 40%'
	    WHEN nta_summary."other quintile" = 3 THEN '40 – 60%'
	    WHEN nta_summary."other quintile" = 4 THEN '60 – 80%'
	    WHEN nta_summary."other quintile" = 5 THEN '80 – 100%' END AS "Other Population"
	    , sum(coalesce(st_length(l.geom)/5280,0)) mileage    
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
JOIN public.districts_neighborhood_tabulation_areas nta
ON nta.ntacode in (l.rntacode, l.lntacode) 
JOIN working.v_nta_summary_map nta_summary
ON nta.ntacode = nta_summary.ntacode
WHERE unit_desc like 'School Safety'
GROUP BY CASE WHEN nta_summary."other quintile" = 1 THEN '0 – 20%'
	    WHEN nta_summary."other quintile" = 2 THEN '20 – 40%'
	    WHEN nta_summary."other quintile" = 3 THEN '40 – 60%'
	    WHEN nta_summary."other quintile" = 4 THEN '60 – 80%'
	    WHEN nta_summary."other quintile" = 5 THEN '80 – 100%' END 
ORDER BY "Other Population"
)

,data2 as(
SELECT sum(data.mileage) total_miles
FROM data
)

,data3 as(
SELECT sum(coalesce(st_length(l.geom)/5280,0)) total_miles   
FROM lion l
)

SELECT data.*, ((data.mileage::decimal)/(sum(data2.total_miles))) * 100 "% of total sip mileage", ((data.mileage::decimal)/(sum(data3.total_miles))) * 100 "% of total lion mileage"
FROM data,data2,data3
GROUP BY data."Other Population", data.mileage
ORDER by data."Other Population"



