--Portal Cooridors

SELECT distinct * FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spl.description, spg.segmentid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl
on sp.vz_status::varchar = spl.lookupid::varchar
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spl.description != 'None'
and spg.nodeid=0
and sip_year > 2013
and sp.end_date<='2019-08-31'::date 
order by sp.end_date) sip_segs


--Portal Nodes
SELECT distinct * FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spl.description, spg.nodeid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl
on sp.vz_status::varchar = spl.lookupid::varchar
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spl.description != 'None'
and spg.segmentid=0
and sip_year > 2013
and sp.end_date<='2019-08-31'::date 
order by sp.end_date) sip_nodes



