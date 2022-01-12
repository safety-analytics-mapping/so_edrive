--PG Signals Code

--2.
--get_intersection_universe(pg)
SELECT ogc_fid, objectid, nodeid, vintersect, geom, version, created, 
       masterid, is_int, manual_fix, is_cntrln_int
  FROM public.node 
  where is_int = 'true'
  limit 100;


select nodeid, masterid, is_int  
from node 
where is_int = true


--select st_transform(st_geomfromewkt('SRID=4326;POINT(-73.87027000 40.73372600)'),2263)
--select st_makepoint(1031726.098, 186224.4018) 


--3.5
--alt_get_node_from_signal_coords(pg, x, y)
select nodeid, st_distance(geom, st_transform(st_geomfromtext('SRID=4326;POINT(-73.87027000 40.73372600)'), 2263)) as distance
from public.node where st_distance(geom, st_transform(st_geomfromtext('SRID=4326;POINT(-73.87027000 40.73372600)'), 2263)) < 1000
and is_int = true
order by geom <#> st_transform(st_geomfromtext('SRID=4326;POINT(-73.87027000 40.73372600)'), 2263) limit 1

