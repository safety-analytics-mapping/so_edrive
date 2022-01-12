
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


