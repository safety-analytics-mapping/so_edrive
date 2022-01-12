WITH data as(
SELECT referencenumber control_id, nodeid1,longitude, latitude, st_transform(ST_PointFromText('POINT(' || longitude || ' ' || latitude || ')', 4326), 2263) geom
FROM staging.ch_swots_stg
WHERE statusdescription = 'A/W Approval     (ICU)'
)

SELECT control_id, nodeid, masterid, distance, geom 
FROM(SELECT *, ROW_NUMBER () OVER (PARTITION BY control_id ORDER BY distance ) AS row_num
     FROM (SELECT data.control_id, n.nodeid, n.masterid, null segmentid, null mft, st_distance(st_setsrid(data.geom, 2263), n.geom) as distance, data.geom
	   FROM data
	   JOIN node n
	   ON st_dwithin(st_setsrid(data.geom, 2263),n.geom, 50)
	   ) x
) y

WHERE row_num = 1