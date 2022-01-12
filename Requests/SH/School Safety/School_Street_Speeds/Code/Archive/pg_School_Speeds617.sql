
select distinct(school), street, mx, SID, geom 

from(
select a.school, b.street, a.mx, b.geom, b.SID from 
(
select school, max(street_speed) mx
from 
	(select b.site_name School, a.street Street, a.avg_mx_speed Street_Speed, 
	b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, 
	a.geom) DIST, a.segmentid
	from speedcameras.disagg_speeds_20190528 a
	join speedcameras.raw_school_buildings b
	on st_dwithin(b.wkb_geometry, a.geom, 50)
	where b.ssschool_id is not null
	order by school) x
where length(school)>1
group by school
) a
join (
select school, max(street_speed) mx , street, street_geom geom, SID
from 
	(select b.site_name School, a.street Street, a.avg_mx_speed Street_Speed, 
	b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, 
	a.geom) DIST, a.segmentid SID
	from speedcameras.disagg_speeds_20190528 a
	join speedcameras.raw_school_buildings b
	on st_dwithin(b.wkb_geometry, a.geom, 50)
	where b.ssschool_id is not null
	order by school) x
where length(school)>1
group by school, street, street_geom, SID

) b 
on a.school=b.school and a.mx=b.mx
) e





select *
from speedcameras.raw_school_buildings
where ssschool_id is not null
order by site_name



CREATE TABLE working.school_street_speeds AS
select school, schid, max(street_speed) mx, street, School_Geom, street_geom, SID
from 
	(select b.site_name School, b.samschool_id schid, a.street Street, a.avg_mx_speed Street_Speed, 
	b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, 
	a.geom) DIST, a.segmentid sid
	from speedcameras.disagg_speeds_20190528 a
	join speedcameras.raw_school_buildings b
	on st_dwithin(b.wkb_geometry, a.geom, 50)
	--where b.ssschool_id is not null
	order by school) x
where length(school)>1
group by school, schid, sid, street, street_geom


--drop table public.school_street_speeds

-----------------------------------------


DROP TABLE if exists working.school_street_speeds;
CREATE TABLE working.school_street_speeds AS    --Table containing School name, School ID, Max Street Speeds, Street names, Street Geometires, Segment IDs

select school, schid, max(street_speed) mx, street, School_Geom,  street_geom, SID
from 
(--Subquery table containing School name, School id, Street name, Street Speeds, 
--School Geometries, Street Geometries, Distances from school to street and segment ids

select b.site_name School, b.samschool_id schid, 
a.street Street, a.avg_mx_speed Street_Speed, 
b.wkb_geometry School_Geom, a.geom Street_Geom, 
ST_Distance(b.wkb_geometry, a.geom) DIST, a.segmentid sid
from speedcameras.disagg_speeds_20190528 a --Table containing all street/segmment speeds, ids and geometries
join speedcameras.raw_school_buildings b   --Table containing all school ids and geometries
on st_dwithin(b.wkb_geometry, a.geom, 50)  --Selects street geometries that are within 50 ft of the location of the school
order by school) x

where length(school)>1
group by school, schid, sid, street,School_Geom, street_geom



-------------------------------------------

select distinct(school) 
from working.school_street_speeds
order by school asc

select * 
from working.school_street_speeds



select x.school, y.schid, x.st_speed, y.street, max((y.sid::integer))
from (
select school,max(mx) st_speed
from working.school_street_speeds
group by school
order by school asc
) x
join working.school_street_speeds y
on x.school = y.school
where x.school = 'A Childs Place Too'
group by x.school, y.schid, x.st_speed, y.street
order by x.school asc






select distinct(a.school), b.schid, a.st_speed, b.street, a.sid, b.School_Geom, b.street_geom
from(
select  x.school, x.st_speed, max((y.sid::integer)) SID
from ((
select school,max(mx) st_speed
from working.school_street_speeds
group by school
order by school asc
) x
join 
(select school, schid, street, sid
from working.school_street_speeds) y
on x.school = y.school
)
group by x.school, x.st_speed
order by x.school asc) a
join working.school_street_speeds b
on a.sid = (b.sid::integer)
order by a.school


