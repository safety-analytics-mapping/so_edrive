Select * from archive."17d_clion" limit 10;

Select * from working.tims_nyc_rf_est_apr2019_5yr limit 10;

Select * 
from working.speed_data_test
limit 10


Select segmentid 
from working.speed_data_test
order by segmentid desc 
limit 100

Select * from public.nysdot_all_old 
where segmentid is not null
limit 10

Select * from public.nysdot_all_old 
limit 10


Select t1.gid 
from archive."17d_clion" t1 join public.nysdot_all_old t2
on t1.gid = t2.gid
limit 10


Select t1.segmentid
from archive."17d_clion" t1 join working.tims_nyc_rf_est_apr2019_5yr t2
on cast(t1.segmentid as int) = cast(t2.segmentid as int)
limit 10

Select t1.segmentid
from archive."17d_clion" t1 join working.speed_data_test t2
on cast(t1.segmentid as int) = cast(t2.segmentid as int)
limit 10


select segmentid from public.nysdot_all_old limit 100
select segmentid from working.tims_nyc_rf_est_apr2019_5yr limit 100
select segmentid from working.speed_data_test limit 100


Select   t1.rf_est, t2.avg_mx_speed, t3.crashid
From working.tims_nyc_rf_est_apr2019_5yr t1 join working.speed_data_test t2
on t1.segmentid = t2.segmentid
join public.nysdot_all_old
on t3.segmentid = t2.segmentid
limit 10


select segmentid from archive."17d_clion" where 
nodeidfrom::int = 47913
union
select segmentid from archive."17d_clion" where 
nodeidto::int = 47913







----------------------------------------------------------------------------------------------------

--2636206
--45995 distinct



select nodeid
from public.nysdot_all_old 
where segmentid is null and nodeid is not null

/*select *
from public.nysdot_all_old 
limit 100000
*/

select segmentid
from public.nysdot_all_old 
where nodeid is null
limit 10



select segmentid
from public.nysdot_all_old
where nodeid is null and segmentid is not null and num_of_inj>0
limit 10

select *
from public.nysdot_all_old
where segmentid::int = 0127412

select *
from public.nysdot_all_old
order by case_yr asc 
limit 10

---------------------------------------------------------------------------------



select distinct l.segmentid from archive."17d_clion" l
join public.nysdot_all_old c
on c.nodeid::int = l.nodeidto::int
where c.segmentid is null and c.nodeid is not null
--and c.nodeid::int = 47913
limit 10
union
select distinct l.segmentid from archive."17d_clion" l
join public.nysdot_all_old c
on c.nodeid::int = l.nodeid ::int
where c.segmentid is null and c.nodeid is not null
--and c.nodeid::int = 47913
limit 10



-------------------------------------------------------------------------------------------------

--runtime 1:26 mins
select distinct l.segmentid from archive."17d_clion" l
join (select nodeid, segmentid 
      from public.nysdot_all_old 
      where segmentid is null and nodeid is not null 
      /*limit 10*/) c
on c.nodeid::int = l.nodeidto::int
union
select distinct l.segmentid from archive."17d_clion" l
join (select nodeid, segmentid 
      from public.nysdot_all_old 
      where segmentid is null and nodeid is not null 
      /*limit 10*/) c
on c.nodeid::int = l.nodeidfrom::int

--------------------------------------------------------------------------------------------------------


select segmentid from archive."17d_clion" where 
nodeidfrom::int = 47913
union
select segmentid from archive."17d_clion" where 
nodeidto::int = 47913
 
select nodeid
from public.nysdot_all_old 
where segmentid is null
limit 1000


(select nodeid
from public.nysdot_all_old 
where segmentid is null) as nodes


select 
Case 
    when t1.segmentid is null then t2.segmentid where t2.nodenum_of_inj,segment 
from public.nysdot_all_old t1 join archive."17d_clion" t2
on cast(t1.segmentid as int) = cast(t2.segmentid as int)
