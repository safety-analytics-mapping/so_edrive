with data as(
SELECT distinct * FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spg.segmentid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spg.nodeid=0
and sip_year >= 2011
and sip_year <= 2017
order by sp.end_date) sip_segs
)

select distinct lion.mft, 'sip' from data
join clion lion
on data.segmentid::int = lion.segmentid::int




--Completed Sip mfts between 2011-2017
with data as(
SELECT distinct * FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spg.segmentid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spg.nodeid=0
and sip_year >= 2011
and sip_year <= 2017
order by sp.end_date) sip_segs
)

select distinct lion.mft, 'sip' sip from data
join clion lion
on data.segmentid::int = lion.segmentid::int





--Completed Sip mfts/geometries between 2011-2017
with data as(
SELECT distinct * FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spg.segmentid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spg.nodeid=0
and sip_year >= 2011
and sip_year <= 2017
order by sp.end_date) sip_segs
)

select distinct coalesce(lion.mft,0) mft, lion.geom from data
join clion lion
on data.segmentid::int = lion.segmentid::int







--Completed Sip masterids between 2011-2017
with data as(

SELECT distinct * FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spg.nodeid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spg.segmentid=0
and sip_year >= 2013
and left(sp.end_date::text,4)::int <= 2017
order by sp.end_date) sip_nodes
)


select distinct coalesce(lion.masterid,0), 'sip' sip from data
left join clion_node lion
on data.nodeid::int = lion.nodeid::int
join 







--Completed Sip masterids to mft/geometries between 2011-2017
with data as(

SELECT distinct * FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spg.nodeid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spg.segmentid=0
and sip_year >= 2013
and left(sp.end_date::text,4)::int <= 2017
order by sp.end_date) sip_nodes
)


select distinct coalesce(clfr.mft,0), clfr.geom, 'sip' sip from data
left join clion_node cln
on data.nodeid::int = cln.nodeid::int
left join  clion clfr
on cln.masterid = clfr.masteridfr

union 

select distinct coalesce(clto.mft,0) mft, clto.geom, 'sip' sip from data
left join clion_node cln
on data.nodeid::int = cln.nodeid::int
left join clion clto
on cln.masterid = clto.masteridto






--All mfts with either sip corridor or intersection projects of study year range

select * from (

--Completed Sip mfts/geometries between 2011-2017
with data as(
SELECT distinct * FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spg.segmentid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spg.nodeid=0
and sip_year >= 2011
and sip_year <= 2017
order by sp.end_date) sip_segs
)

select distinct coalesce(lion.mft,0) mft, lion.geom from data
join clion lion
on data.segmentid::int = lion.segmentid::int

) sip_corr_mfts

union all

select * from (


--Completed Sip masterids to mft/geometries between 2011-2017
with data as(

SELECT distinct * FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spg.nodeid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spg.segmentid=0
and sip_year >= 2011
and left(sp.end_date::text,4)::int <= 2017
order by sp.end_date) sip_nodes
)


select distinct coalesce(clfr.mft,0) mft, clfr.geom from data
left join clion_node cln
on data.nodeid::int = cln.nodeid::int
left join  clion clfr
on cln.masterid = clfr.masteridfr

union 

select distinct coalesce(clto.mft,0) mft, clto.geom from data
left join clion_node cln
on data.nodeid::int = cln.nodeid::int
left join clion clto
on cln.masterid = clto.masteridto


) sip_itx_mfts







select * from (

--Completed Sip mfts/geometries between 2011-2017
with data as(


SELECT distinct lion.mft, lion.geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
join clion lion
on ST_intersects(st_setsrid(spg.geom,2263), lion.geom)
where sp.status= '15'
and spg.nodeid=0
and left(sip_year::text,4)::int between 2011 and 2017
and left(end_date::text,4)::int between 2011 and 2017

)


select distinct coalesce(lion.mft,0) mft, lion.geom from data
join clion lion
on ST_intersects(data.geom, lion.geom)

) sip_corr_mfts

union all

select * from (


--Completed Sip masterids to mft/geometries between 2011-2017
with data as(


SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spg.nodeid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spg.segmentid=0
and left(sp.sip_year::text,4)::int between 2011 and 2017
and left(sp.end_date::text,4)::int between 2011 and 2017) 



select distinct coalesce(clfr.mft,0) mft, clfr.geom from data
left join clion_node cln
on data.nodeid::int = cln.nodeid::int
left join  clion clfr
on cln.masterid = clfr.masteridfr

union 

select distinct coalesce(clto.mft,0) mft, clto.geom from data
left join clion_node cln
on data.nodeid::int = cln.nodeid::int
left join clion clto
on cln.masterid = clto.masteridto


) sip_itx_mfts





SELECT distinct *
FROM public.sip_projects_geo spg
limit 10




select * from clion
limit 10


select * from clion_node 
limit 10

SELECT distinct *
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
limit 10


--12/26


--using intersection
select * from (

--All geometries that have mfts with completed sips between 2011-2017
SELECT distinct coalesce(lion.mft,0)::text mft, coalesce(masteridfr,0)::text masteridfrom, coalesce(masteridto,0)::text masteridto, lion.geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join clion lion
on spg.segmentid::int = lion.segmentid::int
where sp.status= '15'
and spg.nodeid=0
and left(sip_year::text,4)::int between 2011 and 2017
and left(end_date::text,4)::int between 2011 and 2017

) sip_corr_mfts


union 

select * from (


--Completed Sip masterids to mft/geometries between 2011-2017
with data as(


SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spg.nodeid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
where sp.status= '15'
and spg.segmentid=0
and left(sp.sip_year::text,4)::int between 2011 and 2017
and left(sp.end_date::text,4)::int between 2011 and 2017 
)


SELECT distinct coalesce(clfr.mft,0)::text mft, coalesce(masteridfr,0)::text masteridfrom, coalesce(masteridto,0)::text masteridto, clfr.geom from data
left join clion_node cln
on data.nodeid::int = cln.nodeid::int
left join  clion clfr
on cln.masterid = clfr.masteridfr

union 

SELECT distinct coalesce(clto.mft,0)::text mft, coalesce(masteridfr,0)::text masteridfrom, coalesce(masteridto,0)::text masteridto, clto.geom from data
left join clion_node cln
on data.nodeid::int = cln.nodeid::int
left join clion clto
on cln.masterid = clto.masteridto


) sip_itx_mfts














select * from (

--Completed Sip mfts/geometries between 2011-2017
with sip_segs as(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spg.segmentid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spg.nodeid=0
and sip_year >= {study_year_min}
and sip_year <= {study_year_max}
order by sp.end_date
)

select distinct coalesce(lion.mft,0) mft, lion.geom from sip_segs
join clion lion
on sip_segs.segmentid::int = lion.segmentid::int

) sip_corr_mfts

union all

select * from (


--Completed Sip masterids to mft/geometries between 2011-2017
with sip_nodes as(

SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.start_date, sp.end_date, spg.nodeid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
join public.sip_lookup spl2
on sp.unit::varchar = spl2.lookupid::varchar 
where sp.status= '15'
and spg.segmentid=0
and sip_year >= {study_year_min}
and left(sp.end_date::text,4)::int <= {study_year_max}
order by sp.end_date
)


select distinct coalesce(clfr.mft,0) mft, clfr.geom from sip_nodes
left join clion_node cln
on sip_nodes.nodeid::int = cln.nodeid::int
left join  clion clfr
on cln.masterid = clfr.masteridfr

union 

select distinct coalesce(clto.mft,0) mft, clto.geom from sip_nodes
left join clion_node cln
on sip_nodes.nodeid::int = cln.nodeid::int
left join clion clto
on cln.masterid = clto.masteridto


) sip_itx_mfts
