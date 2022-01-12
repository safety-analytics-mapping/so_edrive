SELECT referencenumber, studyunit, datecreated, oldreferencenumber, 
       externalreferencenumber, daterequested, statuscode, statusdescription, 
       studystatus, statusdate, requesttype, dateassigned, borough, 
       locationtype, mainstreet, crossstreet1, crossstreet2, compassdirectionone, 
       compassdirectiontwo, xcoordinate, ycoordinate, latitude, longitude, 
       nodeid1, nodeid2, communitydistrict, policeprecinct, assemblydistrict, 
       citycouncildistrict, schooldistrict, locationnotes, midblock, 
       removal, visionzero, seasonal, hurricanesandy, schoolhold, consultant, 
       schoolcrossing, schoolnumber, schoolname, targetdate, reevaluationdate, 
       am_count, am_count2, pm_count, pm_count2, midday_count, midday_count2, 
       schooldismissal, schooldismissal2, pedestriancount, pedestriancount2, 
       gap, gap2, speed, speed2, otherstudies, otherstudies2, atr_receivedate, 
       atr_requestdate, warrantdescription, warrantsstudytype, warrantssatisfieddate, 
       signalinstalldate, aw_installdate, findings, tentativesignalinstalldate
 FROM staging.ch_swots_stg
 WHERE requesttype = 'All-Way Stop'



SELECT control_id, nodeid, masterid, segmentid::varchar, mft::varchar, distance, control_geom
FROM staging.ch_swots_stg
WHERE requesttype = 'All-Way Stop'


WITH data as(
SELECT referencenumber control_id, nodeid1,longitude, latitude, st_transform(ST_PointFromText('POINT(' || longitude || ' ' || latitude || ')', 4326), 2263) geom
FROM staging.ch_swots_stg
WHERE requesttype = 'All-Way Stop'
)

SELECT * FROM(
SELECT *, ROW_NUMBER () OVER (PARTITION BY control_id ORDER BY distance ) AS row_num
FROM (SELECT data.control_id, data.nodeid1, n.nodeid, n.masterid, null segmentid, null mft, st_distance(st_setsrid(data.geom, 2263), n.geom) as distance, data.geom
      FROM data
      JOIN node n
      ON st_dwithin(st_setsrid(data.geom, 2263),n.geom, 50)
      ) x
) y

WHERE row_num = 1





select *
from staging.ch_swots_stg o
left outer join all_way_stops s
on o.referencenumber = s.control_id
where requesttype='All-Way Stop'
and s.control_id is null

















WITH wnodes AS(
                    SELECT * FROM( SELECT *, ROW_NUMBER () OVER (PARTITION BY control_id ORDER BY distance ) AS row_num
                               FROM (SELECT 'SIG' control_type, psgm_id control_id, n.nodeid, n.masterid,
                                    null segmentid, null mft, 
                                    st_distance(st_setsrid(s.geom, 2263), n.geom) as distance, st_setsrid(s.geom, 2263) control_geom
                                 FROM staging.stg_signal_controller s
                                 JOIN node n
                                 ON st_dwithin(st_setsrid(s.geom, 2263),n.geom, 50)
                                ) x
                              )y
                    WHERE row_num = 1
                    )


                    ,wsegs AS(
                    SELECT * FROM( SELECT *, ROW_NUMBER () OVER (PARTITION BY control_id ORDER BY distance ) AS row_num
                               FROM (SELECT 'SIG' control_type, psgm_id control_id, null nodeid, null masterid, 
                                    l.segmentid, l.mft, st_distance(st_setsrid(s.geom, 2263), l.geom) as distance, 
                                    st_setsrid(s.geom, 2263) control_geom
                                     FROM staging.stg_signal_controller s
                                     JOIN lion l
                                     ON st_dwithin(st_setsrid(s.geom, 2263), l.geom, 50)
                                     WHERE psgm_id not in (SELECT control_id FROM wnodes)) x
                                     )y
                    WHERE row_num = 1
                    )

                    ,no_nodes_segs AS(
                    SELECT 'SIG' control_type, psgm_id control_id, null nodeid, null masterid, null segmentid, null mft, 
                        0 distance, st_setsrid(geom, 2263) control_geom
                    FROM staging.stg_signal_controller
                    WHERE psgm_id not in (SELECT control_id 
                                  FROM wnodes

                                  union
                                  
                                  SELECT control_id 
                                  FROM wsegs)
                    )



                    ,aws AS(                
                    SELECT referencenumber control_id, nodeid1,longitude, latitude, st_transform(ST_PointFromText('POINT(' || longitude || ' ' || latitude || ')', 4326), 2263) geom
                    FROM staging.ch_swots_stg
                    WHERE requesttype = 'All-Way Stop'                    
                    )
                                   
                    ,all_way_stops AS(
                    
                    SELECT * FROM(SELECT *, ROW_NUMBER () OVER (PARTITION BY control_id ORDER BY distance ) AS row_num
                                  FROM (SELECT 'AWS' control_type, aws.control_id, aws.nodeid1, n.nodeid, n.masterid, null segmentid, null mft, st_distance(st_setsrid(aws.geom, 2263), n.geom) as distance, aws.geom
                                        FROM aws
                                        JOIN node n
                                        ON st_dwithin(st_setsrid(aws.geom, 2263),n.geom, 50)
                                        ) x
                                 ) y
                    WHERE row_num = 1
                    )
                    
                    
                    
                    SELECT control_type, control_id::varchar, nodeid::varchar, masterid::varchar, segmentid, mft, distance, control_geom
                    FROM wnodes

                    union

                    SELECT control_type, control_id::varchar, nodeid, masterid, segmentid::varchar, mft::varchar, distance, control_geom
                    FROM wsegs

                    union 

                    SELECT control_type, control_id::varchar, nodeid, masterid, segmentid, mft, distance, control_geom
                    FROM no_nodes_segs

                    union
               
                    SELECT control_type, control_id, nodeid::varchar, masterid::varchar, segmentid, mft, distance, geom 
                    FROM all_way_stops

                    ORDER BY control_id


