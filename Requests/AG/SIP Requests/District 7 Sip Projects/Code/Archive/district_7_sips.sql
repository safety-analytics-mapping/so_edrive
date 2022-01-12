SELECT ogc_fid, congdist, shape_leng, geom
  FROM public.districts_congressional
  where congdist = 7;


select inet_server_addr()

select inet_server_port()


Select * from d7_corr c
join (select * from districts_congressional where congdist = 7) d
on st_intersects(st_setsrid(c.geom,2263), st_setsrid(d.geom,2263))


