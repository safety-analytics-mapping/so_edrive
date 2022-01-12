SELECT objectid, psgm_id, police, policekey, boro, geo1, geo2, seqno, 
       gisgrid_gisadmin_sig_trpsgm_are, contrno, contrtype, contrsn, 
       rcotype, rco_sn, computer, st1_code, st1_name, st2_code, st2_name, 
       st3_code, st3_name, st4_code, st4_name, geokey1, on_line, mach, 
       sect, logical, cntrlpm, tsmp, psgm, normalizedtype, nodeid, segmentid, 
       atcs_cabinet_address_hex, contractor_reference_number, longitude, 
       latitude, signalinstalldate, point_x, point_y, last_updated, 
       url, geom
  FROM staging.stg_signal_controller
  limit 20;


WITH wnodes AS(
SELECT * FROM( SELECT *, ROW_NUMBER () OVER (PARTITION BY control_id ORDER BY distance ) AS row_num
       FROM (SELECT 'SIG' control_type, psgm_id control_id, signalinstalldate install_date, n.nodeid, n.masterid,
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
       FROM (SELECT 'SIG' control_type, psgm_id control_id, signalinstalldate install_date, null nodeid, null masterid, 
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
SELECT psgm_id control_id, signalinstalldate install_date, null nodeid, null masterid, null segmentid, null mft, 
0 distance, st_setsrid(geom, 2263) control_geom
FROM staging.stg_signal_controller
WHERE psgm_id not in (SELECT control_id 
	  FROM wnodes

	  union
	  
	  SELECT control_id 
	  FROM wsegs)
)

SELECT control_id, install_date, nodeid::varchar, masterid::varchar, segmentid, mft, distance, control_geom
FROM wnodes

union

SELECT control_id, install_date, nodeid, masterid, segmentid::varchar, mft::varchar, distance, control_geom
FROM wsegs

union 

SELECT *
FROM no_nodes_segs

ORDER BY control_id