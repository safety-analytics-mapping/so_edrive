SELECT distinct sip_yr
  FROM public.sip_intersections;



SELECT distinct sip_year
  FROM public.sip_corr;





SELECT wkb_geometry
  FROM public.sip_intersections;


select pid, itx.pjct_name, sip_year, itx.pm
from sip_intersections ints
join sip_itx itx
on st_dwithin(st_setsrid(ints.wkb_geometry,2263), st_setsrid(itx.geom,2263),300)


select * from working.sip_corridors limit 0



select pid, corr.pjct_name, sip_year, corr.pm, corr.geom
from working.sip_corridors crds
join sip_corr corr
on st_dwithin(st_setsrid(crds."geometry",2263), st_setsrid(corr.geom,2263),300)

select * from 
sip_corr
limit 10

select * from 
working.sip_corridors 
limit 10


--SIP and VZV Corr Overlaps
select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ
from working.sip_corridors vzv
join sip_corr sip
on st_dwithin(st_setsrid(vzv."geometry",2263), st_setsrid(sip.geom,2263),300)



select * from 
sip_itx 
limit 100


select * from 
public.sip_intersections
limit 100

--SIP and VZV itx Overlaps
select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ, sip.geom
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013





--COMPLETE OVERLAP Including geom

select * from (
select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ
from working.sip_corridors vzv
join sip_corr sip
on st_dwithin(st_setsrid(vzv."geometry",2263), st_setsrid(sip.geom,2263),300)


union all

select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013

)x





--COMPLETE OVERLAP 

select * from (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
'CORR' typ
from working.sip_corridors vzv
join sip_corr sip
on st_dwithin(st_setsrid(vzv."geometry",2263), st_setsrid(sip.geom,2263),300)


union 

select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm,
'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013

)corr_itx




--Sip PIDS that don't have a VZV match


select distinct x.pid sip_pid, x.pjct_name sip_pjct_name, x.sip_year sip_year, x.pm sip_pm, 
vzv_sip_id, vzv_pjct_name, vzv_sip_year, vzv_pm,typ 
from sip_corr x
left join 
(


select * from (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
'CORR' typ
from working.sip_corridors vzv
join sip_corr sip
on st_dwithin(st_setsrid(vzv."geometry",2263), st_setsrid(sip.geom,2263),300)


union 

select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm,
'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013

)corr_itx
) y
on x.pid = y.sip_pid




select * from sip_corr limit 10


select distinct pjct_name
from sip_corr x























--ACTUAL COMPLETE OVERLAP Including geom

select * from (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ
from working.sip_corridors vzv
join sip_corr sip
on st_dwithin(st_setsrid(vzv."geometry",2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013


union all

select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013

)corr_itx




--Sip CORR PIDS that don't have a VZV match
select * from (select distinct pid sip_pid, pjct_name sip_pjct_name, sip_year sip_year, pm sip_pm, 
segmentid sip_geomid, 'CORR' typ
from sip_corr) x
left join (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ
from working.sip_corridors vzv
join sip_corr sip
on st_dwithin(st_setsrid(vzv."geometry",2263), st_setsrid(sip.geom,2263),65) 
where "SIP_YR" between 2009 and 2013) y
on x.sip_geomid = y.sip_geomid
where vzv_sip_id is null
--where x.sip_pid = 1150
order by x.sip_pjct_name


--VZV CORR PIDS that don't have a SIP match
select * from (select distinct "SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm,  'CORR' typ, st_setsrid("geometry",2263) geom
from working.sip_corridors
where "SIP_YR" between 2009 and 2013) x
left join (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ, st_setsrid(vzv."geometry",2263) vzv_geom
from working.sip_corridors vzv
join sip_corr sip 
on st_dwithin(st_setsrid(vzv."geometry",2263), st_setsrid(sip.geom,2263),65) 
where "SIP_YR" between 2009 and 2013) y
on x.geom = y.vzv_geom
--where vzv_sip_id is null
--where x.sip_pid = 1150
order by x.vzv_sip_id





--Sip ITX PIDS that don't have a VZV match
select * from (select pid sip_pid, pjct_name sip_pjct_name, sip_year sip_year, pm sip_pm, 
nodeid sip_geomid, 'ITX' typ
from sip_itx) x
left join (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013) y
on x.sip_geomid = y.sip_geomid
--where vzv_sip_id is null
--where x.sip_pid = 1150
order by x.sip_pjct_name



--VZV ITX  PIDS that don't have a SIP match
select x.vzv_sip_id, x.vzv_pjct_name, x.vzv_sip_year, x.vzv_pm, x.geom, sip_pid, sip_pjct_name, sip_year,sip_pm  
from   (select distinct sip_id vzv_sip_id, pjct_name vzv_pjct_name, sip_yr vzv_sip_year, pm vzv_pm, nodeid_1 geom
	from sip_intersections 
	where sip_yr between 2009 and 2013) x
	left join (
	select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
	vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
	sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
	from sip_intersections vzv
	join sip_itx sip
	on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
	where vzv.sip_yr between 2009 and 2013) y
on x.geom = y.vzv_geomid
--where y.sip_id is null
--where x.sip_pid = 1150
order by x.vzv_sip_id






















--Final Queries


--ACTUAL COMPLETE OVERLAP Including geom

select distinct sip_pid, sip_pjct_name, sip_year, sip_pm, vzv_sip_id, vzv_pjct_name, vzv_sip_year, vzv_pm, typ
from (
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ
from working.sip_corridors vzv
join sip_corr sip
on st_dwithin(st_setsrid(vzv."geometry",2263), st_setsrid(sip.geom,2263),300)
where  "SIP_YR" between 2009 and 2013


union all

select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013

)corr_itx




--SIP CORR OVERLAP
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
"SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ
from working.sip_corridors vzv
join sip_corr sip 
on st_dwithin(st_setsrid(vzv."geometry",2263), st_setsrid(sip.geom,2263),65) 
where "SIP_YR" between 2009 and 2013


--SIP ITX OVERLAP
select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
from sip_intersections vzv
join sip_itx sip
on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
where vzv.sip_yr between 2009 and 2013



-- SIP PROJECTS THAT DON'T HAVE A VZV MATCH

select * from (
--Sip CORR PIDS that don't have a VZV match
select distinct x.sip_pid, x.sip_pjct_name, x.sip_year, x.sip_pm, x.typ  
from (select distinct pid sip_pid, pjct_name sip_pjct_name, sip_year sip_year, pm sip_pm, segmentid sip_geomid, 'CORR' typ from sip_corr) x

left join (select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
	   "SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
	   sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ
	   from working.sip_corridors vzv
	   join sip_corr sip 
	   on st_dwithin(st_setsrid(vzv."geometry",2263), st_setsrid(sip.geom,2263),65) 
	   where "SIP_YR" between 2009 and 2013) y
	   
on x.sip_geomid = y.sip_geomid
where vzv_sip_id is null
order by x.sip_pjct_name
) corrs

union 

select * from (
--Sip ITX PIDS that don't have a VZV match
select x.sip_pid, x.sip_pjct_name, x.sip_year, x.sip_pm, x.typ
from (select distinct pid sip_pid, pjct_name sip_pjct_name, sip_year sip_year, pm sip_pm, nodeid sip_geomid, 'ITX' typ from sip_itx) x

left join (select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
	   vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
	   sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
	   from sip_intersections vzv
	   join sip_itx sip
	   on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
	   where vzv.sip_yr between 2009 and 2013) y
	   on x.sip_geomid = y.sip_geomid
where vzv_sip_id is null
order by x.sip_pjct_name
) itxs







--VZV PIDS that don't have a SIP match

--VZV CORR PIDS that don't have a SIP match
select * from (
select distinct x.vzv_sip_id, x.vzv_pjct_name, x.vzv_sip_year, x.vzv_pm, x.typ
from (select distinct "SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm,  'CORR' typ, st_setsrid("geometry",2263) vzv_geom 
      from working.sip_corridors where "SIP_YR" between 2009 and 2013) x

left join (select distinct sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
           "SIP_ID" vzv_sip_id, "Proj_Name" vzv_pjct_name, "SIP_YR" vzv_sip_year, "PM" vzv_pm, 
	   sip.segmentid sip_geomid, 'null' vzv_geomid, 'CORR' typ, st_setsrid(vzv."geometry",2263) vzv_geom
	   from working.sip_corridors vzv
	   join sip_corr sip 
	   on st_dwithin(st_setsrid(vzv."geometry",2263), st_setsrid(sip.geom,2263),65) 
	   where "SIP_YR" between 2009 and 2013) y
on x.vzv_geom = y.vzv_geom
where y.sip_pid is null
order by x.vzv_sip_id
) corrs

union 

--VZV ITX  PIDS that don't have a SIP match
select * from (
select distinct x.vzv_sip_id, x.vzv_pjct_name, x.vzv_sip_year, x.vzv_pm, x.typ
from (select distinct sip_id vzv_sip_id, pjct_name vzv_pjct_name, sip_yr vzv_sip_year, pm vzv_pm, 'ITX' typ, nodeid_1 geom
      from sip_intersections where sip_yr between 2009 and 2013) x

left join (select sip.pid sip_pid, sip.pjct_name sip_pjct_name, sip_year sip_year, sip.pm sip_pm, 
	   vzv.sip_id vzv_sip_id, vzv.pjct_name vzv_pjct_name, vzv.sip_yr vzv_sip_year, vzv.pm vzv_pm, 
	   sip.nodeid sip_geomid, vzv.nodeid_1 vzv_geomid, 'ITX' typ
	   from sip_intersections vzv
	   join sip_itx sip
	   on st_dwithin(st_setsrid(vzv.wkb_geometry,2263), st_setsrid(sip.geom,2263),300)
	   where vzv.sip_yr between 2009 and 2013) y
on x.geom = y.vzv_geomid
where y.sip_pid is null
order by x.vzv_sip_id
) itxs


