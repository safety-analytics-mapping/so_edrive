
select distinct sip_pid, sip_pjct_name, sip_yr, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ
from working.sip_corridors_so vzv




SELECT sip_id, sip_yr, proj_name, pm, wkb_geometry
  FROM working.sip_corridors_so
  where sip_yr between 2009 and 2013;


SELECT sip_id, sip_yr, proj_name, pm, wkb_geometry, st_length(wkb_geometry)
  FROM working.sip_corridors_so 
  where sip_yr between 2009 and 2013;


  
select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_prjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(sip.geom, vzv.wkb_geometry, 10)
where st_length(st_intersection(ST_Buffer(wkb_geometry, 3),sip.geom))/st_length(vzv.wkb_geometry) > 0.8
and vzv.sip_yr between 2009 and 2013


select * from sip_itx

select * from working.sip_intersections_so limit 100
select * from working.sip_corridors_so limit 100


select *  
from sip_intersections vzv
join sip_itx sip
on st_dwithin(sip.geom, vzv.wkb_geometry, 10)
where st_length(st_intersection(ST_Buffer(vzv.wkb_geometry, 3),sip.geom))/st_length(sip.geom) > 0.8




SELECT *
FROM working.sip_corridors_so
where sip_yr between 2009 and 2013;


with overlap as (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ, sip.geom sip_geom, st_setsrid(vzv."geometry",2263) vzv_geom 
from working.sip_corridors vzv
join sip_corr sip  
on st_dwithin(sip.geom, st_setsrid(vzv."geometry",2263), 10)
where st_length(st_intersection(ST_Buffer(st_setsrid(vzv."geometry",2263), 10),sip.geom))/st_length(st_setsrid(vzv."geometry",2263)) > 0.2
and "SIP_YR" between 2009 and 2013
)

select distinct sip_pid, sip_pjct_name, sip_year, sip_pm, 
vzv_sip_id, vzv_pjct_name, vzv_sip_year, vzv_pm, typ
from overlap



select st_length(st_intersection(ST_Buffer(st_setsrid(vzv."geometry",2263), 10),sip.geom))/st_length(st_setsrid(vzv."geometry",2263)) > 0.6
from working.sip_corridors vzv
join sip_corr sip 
on st_dwithin(sip.geom, st_setsrid(vzv."geometry",2263), 10)
and "SIP_YR" between 2009 and 2013




-- Corridor Overlap 

select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ, sip.geom sip_geom, st_setsrid(vzv."geometry",2263) vzv_geom 
from working.sip_corridors vzv
join sip_corr sip  
on st_dwithin(sip.geom, st_setsrid(vzv."geometry",2263), 10)
where st_length(st_intersection(ST_Buffer(st_setsrid(vzv."geometry",2263), 10),sip.geom))/st_length(sip.geom) > 0.9
and "SIP_YR" between 2009 and 2013



--corridor overlap w mfts
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ, sip.geom sip_geom, st_setsrid(vzv."geometry",2263) vzv_geom 
from working.sip_corridors vzv
join 
	(select pid, pjct_name, sip_year, pm, l2.segmentid, l2.geom 
	from sip_corr sip
	join lion l
	on sip.segmentid::int = l.segmentid::int
	join lion as l2
	on l.mft = l2.mft
	) sip  
on st_dwithin(sip.geom, st_setsrid(vzv."geometry",2263), 10)
where st_length(st_intersection(ST_Buffer(st_setsrid(vzv."geometry",2263), 10),sip.geom))/st_length(sip.geom) > 0.9
and "SIP_YR" between 2009 and 2013


--corridor overlap w mfts
with overlap_1 as (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ, sip.geom sip_geom, st_setsrid(vzv."geometry",2263) vzv_geom 
from working.sip_corridors vzv
join 
	(select pid, pjct_name, sip_year, pm, l2.segmentid, l2.geom 
	from sip_corr sip
	join lion l
	on sip.segmentid::int = l.segmentid::int
	join lion as l2
	on l.mft = l2.mft
	) sip  
on st_dwithin(sip.geom, st_setsrid(vzv."geometry",2263), 10)
where st_length(st_intersection(ST_Buffer(st_setsrid(vzv."geometry",2263), 10),sip.geom))/st_length(sip.geom) > 0.9
and "SIP_YR" between 2009 and 2013
)

select distinct sip_pid, sip_pjct_name, sip_year, sip_pm, 
vzv_sip_id, vzv_pjct_name, vzv_sip_year, vzv_pm, typ
from overlap_1

select distinct 





--unmatched sips
with overlap_1 as (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ, sip.geom sip_geom, st_setsrid(vzv."geometry",2263) vzv_geom 
from working.sip_corridors vzv
join 
	(select pid, pjct_name, sip_year, pm, l2.segmentid, l2.geom 
	from sip_corr sip
	join lion l
	on sip.segmentid::int = l.segmentid::int
	join lion as l2
	on l.mft = l2.mft
	) sip  
on st_dwithin(sip.geom, st_setsrid(vzv."geometry",2263), 10)
where st_length(st_intersection(ST_Buffer(st_setsrid(vzv."geometry",2263), 10),sip.geom))/st_length(sip.geom) > 0.9
and "SIP_YR" between 2009 and 2013
)


select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year, sip.pm sip_pm, sip.geom sip_geom 
from sip_corr sip
where sip.pid not in (select distinct sip_pid from overlap_1)








--unmatched vzvs
with overlap_1 as (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ, sip.geom sip_geom, st_setsrid(vzv."geometry",2263) vzv_geom 
from working.sip_corridors vzv
join 
	(select pid, pjct_name, sip_year, pm, l2.segmentid, l2.geom 
	from sip_corr sip
	join lion l
	on sip.segmentid::int = l.segmentid::int
	join lion as l2
	on l.mft = l2.mft
	) sip  
on st_dwithin(sip.geom, st_setsrid(vzv."geometry",2263), 10)
where st_length(st_intersection(ST_Buffer(st_setsrid(vzv."geometry",2263), 10),sip.geom))/st_length(sip.geom) > 0.9
and "SIP_YR" between 2009 and 2013
)


select distinct "SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, st_setsrid("geometry",2263) vzv_geom
from working.sip_corridors
where "SIP_ID" not in (select distinct vzv_sip_id from overlap_1)
and "SIP_YR" between 2009 and 2013



select distinct "SIP_ID" from  working.sip_corridors
where "SIP_YR" between 2009 and 2013



--intersection overlaps



select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013


--overlaps
with itx_overlap as (
select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013
)

select distinct sip_pid, sip_pjct_name, sip_year, sip_pm, 
vzv_sip_id, vzv_pjct_name, vzv_sip_year, vzv_pm, typ
from itx_overlap

--unmatched sip itxs
with itx_overlap as (
select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013
)

select distinct sip.pid, sip.pjct_name, sip_year, sip.pm 
from sip_itx sip
where pid not in (select distinct sip_pid from itx_overlap)



--unmatched vzv itxs
with itx_overlap as (
select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013
)

select distinct vzv.sip_id, vzv.pjct_name, vzv.sip_yr, vzv.pm 
from sip_intersections vzv
where vzv.sip_id not in (select distinct vzv_sip_id from itx_overlap)
and vzv.sip_yr between 2009 and 2013









--COMPLETE OVERLAP
    
with itx_overlap as (
select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ, st_setsrid(vzv.wkb_geometry,2263) vzv_geom 
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013
)

select * from(
select distinct sip_pid, sip_pjct_name, sip_year, sip_pm, 
vzv_sip_id, vzv_pjct_name, vzv_sip_year, vzv_pm, typ --, vzv_geom
from itx_overlap) itxs

union all

select * from (
with corr_overlap as (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ, sip.geom sip_geom, st_setsrid(vzv."geometry",2263) vzv_geom 
from working.sip_corridors vzv
join 
    (select pid, pjct_name, sip_year, pm, l2.segmentid, l2.geom 
    from sip_corr sip
    join lion l
    on sip.segmentid::int = l.segmentid::int
    join lion as l2
    on l.mft = l2.mft
    ) sip  
on st_dwithin(sip.geom, st_setsrid(vzv."geometry",2263), 10)
where st_length(st_intersection(ST_Buffer(st_setsrid(vzv."geometry",2263), 10),sip.geom))/st_length(sip.geom) > 0.9
and "SIP_YR" between 2009 and 2013
)

select distinct sip_pid, sip_pjct_name, sip_year, sip_pm, 
vzv_sip_id, vzv_pjct_name, vzv_sip_year, vzv_pm, typ --,vzv_geom
from corr_overlap) corrs
