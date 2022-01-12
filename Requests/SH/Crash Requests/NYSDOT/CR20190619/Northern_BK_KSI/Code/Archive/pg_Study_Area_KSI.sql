SELECT *
FROM working.study_area a 
join public.nysdot_all b
on st_intersects(a.wkb_geometry, b.geom)
limit 100



select * 
from public.nysdot_all
limit 10;



select ext_of_inj 
from public.nysdot_all
where ext_of_inj is not null
and length(ext_of_inj)>1;


SELECT *
FROM working.study_area a 
join public.nysdot_all b
on ST_Overlaps(a.wkb_geometry, b.geom)
limit 10


select inj as severity, count(inj)
from (
SELECT b.ext_of_inj inj, b.geom
FROM working.study_area a 
join public.nysdot_all b
on st_intersects(a.wkb_geometry, b.geom)
where ext_of_inj is not null
and length(ext_of_inj)>1
) c
group by inj



select inj as severity, count(inj) as cnt
from (
SELECT b.ext_of_inj inj, b.geom
FROM working.study_area a 
join public.nysdot_all b
on ST_DWithin(a.wkb_geometry, b.geom, 2)
where ext_of_inj is not null
and length(ext_of_inj)>1
and '%A%' in (ext_of_inj)
) c
group by inj



select inj as severity, count(inj) as cnt
from (
SELECT b.ext_of_inj inj, b.geom
FROM working.study_area a 
join public.nysdot_all b
on ST_DWithin(a.wkb_geometry, b.geom, 2)
where ext_of_inj is not null
and (ext_of_inj) like '%A%'
) c
group by inj




select inj as severity, count(inj) as cnt
from (
SELECT b.ext_of_inj inj, b.geom
FROM working.study_area a 
join public.nysdot_all b
on ST_DWithin(a.wkb_geometry, b.geom, 2)
where ext_of_inj is not null
and (ext_of_inj) like '%A%'
) c
group by inj


st_setsrid(a.wkb_geometry, 2263)




select inj as severity, count(inj) as cnt
from (
SELECT b.ext_of_inj inj, b.geom
FROM working.study_area a 
join public.nysdot_all b
on ST_DWithin(a.wkb_geometry, b.geom, 2)
where ext_of_inj is not null
and (ext_of_inj) like '%A%'
) c
group by inj

--st_setsrid(a.wkb_geometry, 2263)

select inj as severity, count(inj) as cnt
from (
SELECT b.ext_of_inj inj, b.geom
FROM working.study_area a 
join public.nysdot_all b
on ST_DWithin(st_setsrid(a.wkb_geometry, 2263), b.geom, 2)
where ext_of_inj is not null
and (ext_of_inj) like '%A%'
) c
group by inj


--SELECT ST_SetSRID(ST_MakePoint(-71.1043443253471, 42.3150676015829),4326)

select * 
from public.nysdot_all
where st_x is not null
and st_y is not null
limit 10;



select ST_SetSRID(ST_MakePoint(st_x, st_y),2263),* 
from public.nysdot_all
where st_x is not null
and st_y is not null
limit 10;

--------------------------------------------------------------------------------------------------------
select inj as severity, count(inj) as cnt
from (
SELECT b.ext_of_inj inj, b.geom
FROM working.study_area a 
join public.nysdot_all b
on ST_DWithin(st_setsrid(a.wkb_geometry, 2263), st_setsrid(ST_MakePoint(b.st_x, b.st_y),2263), 2)
where ext_of_inj is not null
and (ext_of_inj) like '%A%'
and b.st_x is not null
and b.st_y is not null
) c
group by inj
---------------------------------------------------------------------------------------------------------

SELECT *
FROM public.fatality_nycdot_current
where st_x is not null 
and st_y is not null
limit 10;



select inj as severity, count(inj) as cnt
from (
SELECT count(b.id_)
FROM working.study_area a 
join public.fatality_nycdot_current b
on ST_DWithin(st_setsrid(a.wkb_geometry, 2263), st_setsrid(ST_MakePoint(b.st_x, b.st_y),2263), 2)
where b.st_x is not null
and b.st_y is not null
) c
group by inj




select inj as severity, count(inj) as cnt
from (
SELECT b.ext_of_inj inj, b.geom
FROM working.study_area a 
join public.nysdot_all b
on ST_DWithin(st_setsrid(a.wkb_geometry, 2263), st_setsrid(ST_MakePoint(b.st_x, b.st_y),2263), 2)
where ext_of_inj is not null
and (ext_of_inj) like '%A%'
and b.st_x is not null
and b.st_y is not null
group by b.geom
) c
group by inj

union

SELECT count(b.id_), now()
FROM working.study_area a 
join public.fatality_nycdot_current b
on ST_DWithin(st_setsrid(a.wkb_geometry, 2263), st_setsrid(ST_MakePoint(b.st_x, b.st_y),2263), 2)
where b.st_x is not null
and b.st_y is not null



--drop table working.study_area


SELECT sum(length(b.ext_of_inj::text) - length(replace(b.ext_of_inj::text, 'A'::text, ''::text))) AS si, b.geom
FROM working.study_area a 
join public.nysdot_all b
on ST_DWithin(st_setsrid(a.wkb_geometry, 2263), st_setsrid(ST_MakePoint(b.st_x, b.st_y),2263), 2)
where ext_of_inj is not null
and (ext_of_inj) like '%A%'
and b.st_x is not null
and b.st_y is not null
group by b.geom

union 

SELECT case when (b.st_x is null and b.st_y is null) then 0 else 1 end K
FROM working.study_area a 
join public.fatality_nycdot_current b
on ST_DWithin(st_setsrid(a.wkb_geometry, 2263), st_setsrid(ST_MakePoint(b.st_x, b.st_y),2263), 2)






