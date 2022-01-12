SELECT control_type, control_id, nodeid, masterid, segmentid, mft, distance, 
       control_lon_lat, node_lon_lat, segment_lon_lat, control_geom, 
       node_geom, segment_geom
  FROM stg.signal_controller;




WITH data as(
SELECT 'SIG' control_type, psgm_id control_id, node.nodeid, node.masterid, st_distance(st_setsrid(shape, 2263), geom) as distance, geom
FROM staging.stg_signal_controller
JOIN node
ON st_dwithin(st_setsrid(shape, 2263),geom, 50)
)


,data2 AS(
SELECT d1.* 
FROM data d1
RIGHT JOIN (SELECT control_id, min(distance) distance
            FROM data
            GROUP BY control_id) d2
ON d1.control_id = d2.control_id
AND d1.distance = d2.distance
)

,data3 AS(
SELECT 'SIG' control_type, psgm_id control_id, lion.segmentid, lion.mft, st_distance(st_setsrid(shape, 2263), geom) as distance, geom
FROM staging.stg_signal_controller
JOIN lion
ON st_dwithin(st_setsrid(shape, 2263),geom, 50)
WHERE psgm_id not in (SELECT control_id FROM data2)
)


,data4 AS(
SELECT 'SIG' control_type, psgm_id control_id, shape
FROM staging.stg_signal_controller
WHERE psgm_id not in (SELECT control_id 
		      FROM data2

		      union
		      
		      SELECT control_id 
		      FROM data3
		      )
)

SELECT * FROM data3

SELECT * FROM staging.stg_signal_controller






DROP table if exists staging.cleaned_signal_controller

CREATE table staging.cleaned_signal_controller AS

WITH wnodes AS(
SELECT * FROM( SELECT *, ROW_NUMBER () OVER (PARTITION BY control_id ORDER BY distance ) AS row_num
	       FROM (SELECT 'SIG' control_type, psgm_id control_id, node.nodeid, node.masterid,' ' segmentid, ' ' mft, st_distance(st_setsrid(shape, 2263), geom) as distance, st_setsrid(shape, 2263) control_geom
		     FROM staging.stg_signal_controller
		     JOIN node
		     ON st_dwithin(st_setsrid(shape, 2263),geom, 50)
		    ) x
	      )y
WHERE row_num = 1
)


,wsegs AS(
SELECT * FROM( SELECT *, ROW_NUMBER () OVER (PARTITION BY control_id ORDER BY distance ) AS row_num
	       FROM (SELECT 'SIG' control_type, psgm_id control_id, ' ' nodeid, ' ' masterid, lion.segmentid, lion.mft, st_distance(st_setsrid(shape, 2263), geom) as distance, st_setsrid(shape, 2263) control_geom
	             FROM staging.stg_signal_controller
	             JOIN lion
	             ON st_dwithin(st_setsrid(shape, 2263),geom, 50)
	             WHERE psgm_id not in (SELECT control_id FROM wnodes)) x
	             )y
WHERE row_num = 1
)

,no_nodes_segs AS(
SELECT 'SIG' control_type, psgm_id control_id, ' ' nodeid, ' ' masterid, ' ' segmentid, ' ' mft, 0 distance, st_setsrid(shape, 2263) control_geom
FROM staging.stg_signal_controller
WHERE psgm_id not in (SELECT control_id 
		      FROM wnodes

		      union
		      
		      SELECT control_id 
		      FROM wsegs)
)

SELECT control_type, control_id, nodeid::varchar, masterid::varchar, segmentid, mft, distance, control_geom
FROM wnodes

union

SELECT control_type, control_id, nodeid, masterid, segmentid::varchar, mft::varchar, distance, control_geom
FROM wsegs

union 

SELECT *
FROM no_nodes_segs

ORDER BY control_id