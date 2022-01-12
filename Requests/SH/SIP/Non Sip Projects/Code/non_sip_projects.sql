--ALL Corridors Without SIP-------------------------------------------
SELECT *
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
WHERE status_desc not in ('SIP','Completed SIP','Pre-SIP','On Hold') 
AND spg.nodeid = 0


--ALL Intersections Without SIP-------------------------------------------
SELECT *
FROM sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
WHERE status_desc not in ('SIP','Completed SIP','Pre-SIP','On Hold') 
AND spg.segmentid = 0