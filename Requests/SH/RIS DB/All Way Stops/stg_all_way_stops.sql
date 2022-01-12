SELECT * FROM(
SELECT nodeid, count(nodeid) cnt
  FROM staging.stg_all_way_stops
  GROUP BY nodeid
  
)x
Where cnt >1



SELECT * 
FROM staging.stg_all_way_stops
WHERE nodeid in (50556,38912,20872,34415)



"CM00-1275"
"CM13-2309"
"CQ96-1269"
"CQ97-0124"
"CQ97-0127"
"CQ97-0152"
"CQ97-0253"
"CQ99-1490"


20872
20872
34415
38912
50556
38912
50556
34415


SELECT * FROM staging.ch_swots_stg
WHERE nodeid1::int in  (20872,34415,38912,50556,38912,50556)
ORDER BY NODEID1

referencenumber:
"CM00-1275"
"CM13-2309"


oldreferencenumber
""
"CM09-1583"

externalreferencenumber
"98-2487"
"DOT-217739-M3K9, PCT. ID #2013-00055"


daterequested
"2000-07-27 00:00:00"
"2013-12-16 00:00:00"


daterequested; statusdescription
"2000-10-12 00:00:00";"All-Way Stop"
"2014-03-18 00:00:00";"Traffic Signal"




SELECT * 
FROM staging.stg_all_way_stops


SELECT *  
FROM signal_controller sc


SELECT sc.nodeid, aws.nodeid, sc.control_id, aws.control_id  
FROM signal_controller sc
JOIN staging.stg_all_way_stops aws
ON sc.nodeid::int = aws.nodeid::int







WITH data as(
SELECT referencenumber control_id, nodeid1,longitude, latitude, st_transform(ST_PointFromText('POINT(' || longitude || ' ' || latitude || ')', 4326), 2263) geom
FROM staging.ch_swots_stg
WHERE statusdescription = 'A/W Approval     (ICU)'
)


,data2 as(
SELECT control_id, nodeid, masterid, distance, geom 
FROM(SELECT *, ROW_NUMBER () OVER (PARTITION BY control_id ORDER BY distance ) AS row_num
     FROM (SELECT data.control_id, n.nodeid, n.masterid, null segmentid, null mft, st_distance(st_setsrid(data.geom, 2263), n.geom) as distance, data.geom
	   FROM data
	   JOIN node n
	   ON st_dwithin(st_setsrid(data.geom, 2263),n.geom, 50)
	   ) x
) y

WHERE row_num = 1
)


SELECT d2.*, sc.control_id traf_control_id
FROM data2 d2
LEFT JOIN public.signal_controller sc
ON d2.nodeid::int = sc.nodeid::int









 CREATE TABLE staging.sip_projects (                     "pid" bigint, "pjct_name" varchar (500), "sip_year" bigint, "start_date" varchar (500), "end_date" varchar (500), "geo_type" varchar (500), "unit" varchar (500), "pm" varchar (500), "mtp" varchar (500), "capital" varchar (500), "status" varchar (500), "vz_status" varchar (500), "date_created" varchar (500), "date_updated" varchar (500), "updated_by" varchar (500), "total_public_space" varchar (500), "milestone_date" varchar (500), "assignedto" varchar (500), "temppid" varchar (500), "approved_date" varchar (500)       )






WITH data as(
SELECT referencenumber control_id, statusdate, nodeid1,  longitude, latitude, st_transform(ST_PointFromText('POINT(' || longitude || ' ' || latitude || ')', 4326), 2263) geom
FROM staging.ch_swots_stg
WHERE statusdescription = 'A/W Approval     (ICU)'
)


,data2 as(
SELECT control_id, statusdate, nodeid, masterid, distance, geom 
FROM(SELECT *, ROW_NUMBER () OVER (PARTITION BY control_id ORDER BY distance ) AS row_num
     FROM (SELECT data.control_id, data.statusdate, n.nodeid, n.masterid, null segmentid, null mft, st_distance(st_setsrid(data.geom, 2263), n.geom) as distance, data.geom
           FROM data
           LEFT JOIN node n
           ON st_dwithin(st_setsrid(data.geom, 2263),n.geom, 50)
           ) x
) y

WHERE row_num = 1
)

,data3 as(
SELECT d2.*, sc.control_id traf_control_id
FROM data2 d2
LEFT JOIN public.signal_controller sc
ON d2.nodeid::int = sc.nodeid::int
WHERE d2.nodeid is null
)

SELECT *
FROM data3 d3
LEFT JOIN staging.ch_swots_stg ch
ON referencenumber = d3.control_id

