WITH corrs AS(
-- All Corridor Projects
SELECT DISTINCT sp.pid
	      , sp.unit_desc
	      , sp.sip_year
	      , l.mft
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN lion l
ON spg.segmentid::int = l.segmentid::int
WHERE sp.status_desc = 'Completed SIP'
AND nodeid = 0
)

,ints AS(
-- All Intersection Projects
SELECT DISTINCT sp.pid
              , sp.unit_desc
              , sp.sip_year
              , n.masterid
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
JOIN node n  
ON spg.nodeid = n.nodeid
WHERE sp.status_desc = 'Completed SIP'
AND segmentid = 0
)


,total AS(

--Grabbing  mileages for SIP corridor projects
SELECT DISTINCT c.pid, c.unit_desc, c.sip_year, sum(coalesce((st_length(l.geom)::decimal/5280),0)) miles --length of sip project in miles
FROM corrs c
JOIN lion l
ON c.mft::int = l.mft::int
WHERE l.rb_layer in ('G','B')
GROUP BY c.pid, c.unit_desc, c.sip_year


UNION


--Grabbing centerline mileages for SIP intersection projects
SELECT DISTINCT i.pid, i.unit_desc, i.sip_year, sum(coalesce((st_length(l.geom)::decimal/5280),0)) miles --length of sip project in miles
FROM ints i
JOIN lion l
on i.masterid = l.masteridfrom 
or i.masterid = l.masteridto
WHERE l.rb_layer in ('G','B')
GROUP BY i.pid, i.unit_desc, i.sip_year

)


SELECT  sip_year "SIP Year"
      ,	round(coalesce(sum(CASE WHEN unit_desc = 'Bikes and Greenways' THEN miles END),0),2) "Bikes and Greenways Mileage" 
      , round(coalesce(sum(CASE WHEN unit_desc = 'Transit Development' THEN miles END),0),2) "Transit Development Mileage"
      , round(coalesce(sum(CASE WHEN unit_desc = 'Ped Unit' THEN miles END),0),2) "Ped Unit Mileage" 
      , round(coalesce(sum(CASE WHEN unit_desc = 'School Safety' THEN miles END),0),2) "School Safety Mileage" 
      , round(coalesce(sum(CASE WHEN unit_desc = 'Public Space' THEN miles END),0),2) "Public Space Mileage" 
      , round(coalesce(sum(CASE WHEN unit_desc = 'Traffic Engineering and Planning' THEN miles END),0),2) "Traffic Engineering and Planning Mileage"
      , round(coalesce(sum(CASE WHEN unit_desc = 'BC''s Office' THEN miles END),0),2) "BC's Office Mileage" 
      , round(coalesce(sum(CASE WHEN unit_desc = 'RIS' THEN miles END),0),2) "RIS Mileage"
      , round(coalesce(sum(CASE WHEN unit_desc = 'Freight' THEN miles END),0),2) "Freight Mileage"
      , round(coalesce(sum(CASE WHEN unit_desc = 'Special Projects' THEN miles END),0),2) "Special Projects Mileage"
      , round(coalesce(sum(CASE WHEN unit_desc is null THEN miles END),0),2) "Unknown Unit Mileage Mileage"
FROM total
GROUP BY sip_year
ORDER BY sip_year ASC

