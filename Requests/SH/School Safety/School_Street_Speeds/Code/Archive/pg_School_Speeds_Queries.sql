select site_name school, wkb_geometry Geom 
from speedcameras.raw_school_buildings



select b.site_name School, a.street Street, a.avg_mx_speed Street_Speed, b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, a.geom) DIST, a.segmentid
from speedcameras.disagg_speeds_20190528 a
join speedcameras.raw_school_buildings b
on st_dwithin(b.wkb_geometry, a.geom, 50)




select street, segmentid, street_speed, street_geom
from 
	(select b.site_name School, a.street Street, a.avg_mx_speed Street_Speed, b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, a.geom) DIST, a.segmentid
	from speedcameras.disagg_speeds_20190528 a
	join speedcameras.raw_school_buildings b
	on st_dwithin(b.wkb_geometry, a.geom, 50)) x




select school, avg(street_speed), School_Geom
from 
	(select b.site_name School, a.street Street, a.avg_mx_speed Street_Speed, b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, a.geom) DIST, a.segmentid
	from speedcameras.disagg_speeds_20190528 a
	join speedcameras.raw_school_buildings b
	on st_dwithin(b.wkb_geometry, a.geom, 50)) x
where length(school)>1
group by school, school_geom


select * from 
(
select school, max(street_speed) mx
from 
	(select b.site_name School, a.street Street, a.avg_mx_speed Street_Speed, b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, a.geom) DIST, a.segmentid
	from speedcameras.disagg_speeds_20190528 a
	join speedcameras.raw_school_buildings b
	on st_dwithin(b.wkb_geometry, a.geom, 50)) x
where length(school)>1
group by school
) a
join (
select school, max(street_speed) mx , street
from 
	(select b.site_name School, a.street Street, a.avg_mx_speed Street_Speed, b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, a.geom) DIST, a.segmentid
	from speedcameras.disagg_speeds_20190528 a
	join speedcameras.raw_school_buildings b
	on st_dwithin(b.wkb_geometry, a.geom, 50)) x
where length(school)>1
group by school, street

) b 
on a.school=b.school and a.mx=b.mx







select school, street_speed, street
from 
	(select b.site_name School, a.street Street, a.avg_mx_speed Street_Speed, b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, a.geom) DIST, a.segmentid
	from speedcameras.disagg_speeds_20190528 a
	join speedcameras.raw_school_buildings b
	on st_dwithin(b.wkb_geometry, a.geom, 50)) x
where length(school)>1
--group by school
order by school








select a.school, b.street, a.mx, b.street_geom from 
(
select school, max(street_speed) mx
from 
	(select b.site_name School, a.street Street, a.avg_mx_speed Street_Speed, b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, a.geom) DIST, a.segmentid
	from speedcameras.disagg_speeds_20190528 a
	join speedcameras.raw_school_buildings b
	on st_dwithin(b.wkb_geometry, a.geom, 50)) x
where length(school)>1
group by school
) a
join (
select school, max(street_speed) mx , street, street_geom
from 
	(select b.site_name School, a.street Street, a.avg_mx_speed Street_Speed, b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, a.geom) DIST, a.segmentid
	from speedcameras.disagg_speeds_20190528 a
	join speedcameras.raw_school_buildings b
	on st_dwithin(b.wkb_geometry, a.geom, 50)) x
where length(school)>1
group by school, street, street_geom

) b 
on a.school=b.school and a.mx=b.mx









select y.*, z.street 
from (
select school, max(street_speed) Speed
from 
	(select b.site_name School, a.street Street, a.avg_mx_speed Street_Speed, b.wkb_geometry School_Geom, a.geom Street_Geom, ST_Distance(b.wkb_geometry, a.geom) DIST, a.segmentid
	from speedcameras.disagg_speeds_20190528 a
	join speedcameras.raw_school_buildings b
	on st_dwithin(b.wkb_geometry, a.geom, 50)) x
where length(school)>1
group by school) y
join speedcameras.disagg_speeds_20190528 z
on y.speed =  z.avg_mx_speed

