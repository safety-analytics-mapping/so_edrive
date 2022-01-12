DROP TABLE IF EXISTS working.ch_speed_humps;

CREATE TABLE working.ch_speed_humps AS

WITH data AS(

SELECT DISTINCT ch_sh.*, lion.*
FROM working.SRTS_30620 ch_sh
LEFT JOIN (SELECT l.segmentid, l.masteridfrom, l.masteridto, l.geom segment_geom, nlu.*
	   FROM archive."18d.2019-11-13_lion" l
	   JOIN public.ch_schools_mft_node_lookup nlu
	   on l.mft = nlu.mft) lion 
ON ch_sh.segmentid::int = lion.segmentid::int
WHERE SegmentStatus = 1
ORDER BY lion.mft, speed_hump_id, dist
)

,data2 AS(
SELECT * FROM(
SELECT speed_hump_id, min(dist) dist
FROM data 
GROUP BY speed_hump_id
) d1
JOIN data 
on  data.speed_hump_id = d1.speed_hump_id and data.dist = d1.dist
)

,data3 AS(
SELECT DISTINCT  data2.masterid, nlu.nodeid, ST_DISTANCE(nlu.geom,data.segment_geom) treat_dist
FROM data2
LEFT JOIN public.ch_schools_mft_node_lookup nlu
ON data2.masterid = nlu.masterid
LEFT JOIN data
ON data2.masterid = data.masterid
--where data2.masterid != nlu.nodeid
)



,data4 AS (
SELECT d1.speed_hump_id, d1.CBAcceptedProposalDate::date speed_hump_approval, d1.numsrproposed number_humps, d3.*, d1.dist, d1.on_st on_street, d1.cross_st cross_street, d1.school_list, d1.school_id_list, d1.address_list  
FROM (
SELECT masterid, sum(nodeid) nodeid, min(treat_dist) t_dist
FROM data3 
GROUP BY (masterid)
) d3
JOIN data d1
ON d3.masterid = d1.masterid and d3.nodeid = d1.nodeid
)


SELECT * FROM data4






select * from working.ch_speed_humps




INSERT INTO public.ch_schools_output (nodeid, dist, on_street, cross_street, school_list, school_id_list, address_list, speed_hump_id, speed_hump_approval, number_humps)
SELECT nodeid,dist,on_street, cross_street, school_list, school_id_list, address_list, speed_hump_id, speed_hump_approval, number_humps
FROM working.ch_speed_humps cs
ON CONFLICT (nodeid)
DO UPDATE 
	SET speed_hump_id = excluded.speed_hump_id, speed_hump_approval = excluded.speed_hump_approval, number_humps = excluded.number_humps
        WHERE cs.speed_hump_id is null


SELECT speed_hump_id, approvaldate, nodeid, dist, school_list, school_id_list, address_list
FROM ch_speed_humps ch_sh
LEFT OUTER JOIN public.ch_schools_output so
ON ch_sh.nodeid = so.nodeid


--SELECT d4.nodeid, d4.school_list, so.*
--FROM data4 d4
--FULL OUTER JOIN public.ch_schools_output so 
--ON d4.nodeid = so.nodeid