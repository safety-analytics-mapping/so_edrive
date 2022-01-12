SELECT left(date_installed::text,4) as year, count(distinct new_id)
  FROM public.speed_humps
  where left(date_installed::text,4)::int between 2008 and 2014
  group by year
  order by year


  select mft from 


  SELECT *
  FROM public.speed_humps
  where on_st = 'VAN SICLEN AVENUE'	


select segmentid, street from archive."17d_clion"
where mft in (select distinct mft from working.lion_18d l
join working.selected_segment_lion ssl
on ssl.segmentid=l.segmentid
where mft is not null)
and rb_layer in ('G','B')



select distinct mft, left(date_installed::text,4) as year -- count(newid)
FROM public.speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid
where lion.segmentid in (SELECT distinct segmentid 
		    FROM public.speed_humps)

group by mft 		   




select distinct
segmentid,borough,
fy,cb,on_st,from_st,to_st,new_humps,near_schools_parks,
other_locs,date_installed,re_installed ,date_re_installed,
school_park_name,order_num,order_approval_date,
order_completion_date
from speed_humps
where segmentid = '119079'


select distinct sh.segmentid, lion.mft, date_installed, on_st,from_st, to_st 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where sh.segmentid in (


select segmentid from(
select distinct segmentid, date_installed, on_st,from_st, to_st from v_clean_speed_humps 
order by on_st) x 
group by segmentid
having count(distinct left(date_installed::text,4)) > 1


)
order by on_st





select distinct lion.mft, date_installed, on_st,from_st, to_st 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where lion.mft in (


select mft from(
select distinct lion.mft, sh.segmentid, date_installed, on_st,from_st, to_st 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
order by on_st) x 
group by mft
having count(distinct left(date_installed::text,4)) > 1


)

and left(date_installed::text, 4) = '2014'

order by on_st









--selecting all the mfts  

select distinct lion.mft, date_installed, on_st,from_st, to_st 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where lion.mft not in (

--selecting all the distinct mfts that have more than one date_installed associated with it
select coalesce(mft,0) from(

--selecting all the distinct mfts in speedhumps data
select distinct lion.mft, sh.segmentid, date_installed, on_st,from_st, to_st 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
order by on_st) x 
group by mft
having count(distinct left(date_installed::text,4)) > 1


)

and left(date_installed::text, 4) = '2014'







--selecting all the mfts  
select distinct lion.mft, lion.masteridfrom, lion.masteridto, date_installed, on_st,from_st, to_st
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where lion.mft not in (

--selecting all the distinct mfts that have more than one date_installed associated with it
select coalesce(mft,0) from(

--selecting all the distinct mfts in speedhumps data
select distinct lion.mft, sh.segmentid, date_installed, on_st,from_st, to_st 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
order by on_st) x 
group by mft
having count(distinct left(date_installed::text,4)) > 1


)

and left(date_installed::text, 4) = '2014'












with data as(
--selecting all the mfts  
select distinct lion.mft, lion.masteridfrom, lion.masteridto, date_installed, on_st,from_st, to_st, lion.geom
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where lion.mft not in (

--selecting all the distinct mfts that have more than one date_installed associated with it
select coalesce(mft,0) from(

--selecting all the distinct mfts in speedhumps data
select distinct lion.mft, sh.segmentid, date_installed, on_st,from_st, to_st 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
order by on_st) x 
group by mft
having count(distinct left(date_installed::text,4)) > 1

)

and left(date_installed::text, 4) = '2014'

)


-- Selecting mft, masteridfrom, masteridto, date_installed, intrsct.date2, on_st,from_st, to_st that dont intersect with other years
select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st from data 
where mft not in (select mft from (select mft, masteridfrom, masteridto, date_installed, intrsct.date2, on_st,from_st, to_st from data
				   join   (

					-- All geometries from speed hump data that is within the study year range but 
					-- excluded from the year that we are focused on. So every year between 2011 and 2017
					-- except for 2014. 
					select distinct lion.geom, left(sh.date_installed::text,4) date2
					from v_clean_speed_humps sh
					join archive."18d.2019-11-13_lion" lion
					on sh.segmentid = lion.segmentid 
					where left(date_installed::text, 4)::int between 2011 and 2017
					and left(date_installed::text, 4)::int != 2014) intrsct
				   on  ST_Intersects(intrsct.geom, data.geom) -- Retrieving all geometries of multiple years that intersect with geometries of 2014. 
				   )final )





---TEST 1
select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st 
from v_clean_speed_humps sh
left join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where mft not in (
select mft from (

with data as(
-- All geometries from speed hump data that is within the study year range but 
-- excluded from the year that we are focused on. So every year between 2011 and 2017
-- except for 2014. 
select distinct lion.geom, left(sh.date_installed::text,4) date2
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text, 4)::int between 2011 and 2017
and left(date_installed::text, 4)::int != 2014
)


select 


select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
join data 
on  ST_Intersects(data.geom, lion.geom) -- Retrieving all geometries of multiple years that intersect with geometries of 2014. 
where left(date_installed::text,4)::int = 2014






--Test 2
with data as(

--selecting all speed hump data from 2014

select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st, lion.geom, lion.segmentid 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text,4)::int = 2014
) 


--selecting all data that does not intersect with any other data of other years. 
select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st 
from data where mft not in(
select mft from(
select mft, masteridfrom, masteridto, date_installed, intrsct.date2, on_st,from_st, to_st from data
join   (
	-- All geometries from speed hump data that is within the study year range but 
	-- excluded from the year that we are focused on. So every year between 2011 and 2017
	-- except for 2014. 
	select distinct lion.geom, left(sh.date_installed::text,4) date2
	from v_clean_speed_humps sh
	join archive."18d.2019-11-13_lion" lion
	on sh.segmentid = lion.segmentid 
	where left(date_installed::text, 4)::int between 2011 and 2017
	and left(date_installed::text, 4)::int != 2014) intrsct
on  ST_dwithin(intrsct.geom, data.geom, 5)
) mfts
)










--Difference 1

select * from (




--Test 2
with data as(

--selecting all speed hump data from 2014

select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st, lion.geom, lion.segmentid
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text,4)::int = 2014
) 


--selecting all data that does not intersect with any other data of other years. 
select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st
from data where mft not in(
select mft from(
select mft, masteridfrom, masteridto, date_installed, intrsct.date2, on_st,from_st, to_st from data
join   (
	-- All geometries from speed hump data that is within the study year range but 
	-- excluded from the year that we are focused on. So every year between 2011 and 2017
	-- except for 2014. 
	select distinct lion.geom, left(sh.date_installed::text,4) date2
	from v_clean_speed_humps sh
	join archive."18d.2019-11-13_lion" lion
	on sh.segmentid = lion.segmentid 
	where left(date_installed::text, 4)::int between 2011 and 2017
	and left(date_installed::text, 4)::int != 2014) intrsct
on  ST_dwithin(intrsct.geom, data.geom, 5)
) mfts
)

) x

where mft not in 

(

select * from (

with data as(
--selecting all the mfts  
select distinct lion.mft, lion.masteridfrom, lion.masteridto, date_installed, on_st,from_st, to_st, lion.geom
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where lion.mft not in (

--selecting all the distinct mfts that have more than one date_installed associated with it
select coalesce(mft,0) from(

--selecting all the distinct mfts in speedhumps data
select distinct lion.mft, sh.segmentid, date_installed, on_st,from_st, to_st 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
order by on_st) x 
group by mft
having count(distinct left(date_installed::text,4)) > 1

)

and left(date_installed::text, 4) = '2014'

)


-- Selecting mft, masteridfrom, masteridto, date_installed, intrsct.date2, on_st,from_st, to_st that dont intersect with other years
select distinct mft--, masteridfrom, masteridto, date_installed, on_st,from_st, to_st 
from data 
where mft not in (select mft from (select mft, masteridfrom, masteridto, date_installed, intrsct.date2, on_st,from_st, to_st from data
				   join   (

					-- All geometries from speed hump data that is within the study year range but 
					-- excluded from the year that we are focused on. So every year between 2011 and 2017
					-- except for 2014. 
					select distinct lion.geom, left(sh.date_installed::text,4) date2
					from v_clean_speed_humps sh
					join archive."18d.2019-11-13_lion" lion
					on sh.segmentid = lion.segmentid 
					where left(date_installed::text, 4)::int between 2011 and 2017
					and left(date_installed::text, 4)::int != 2014) intrsct
				   on  ST_Intersects(intrsct.geom, data.geom) -- Retrieving all geometries of multiple years that intersect with geometries of 2014. 
				   )final )
)x

)



















--Difference 2


select * from (


with data as(
--selecting all the mfts  
select distinct lion.mft, lion.masteridfrom, lion.masteridto, date_installed, on_st,from_st, to_st, lion.geom
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where lion.mft not in (

--selecting all the distinct mfts that have more than one date_installed associated with it
select coalesce(mft,0) from(

--selecting all the distinct mfts in speedhumps data
select distinct lion.mft, sh.segmentid, date_installed, on_st,from_st, to_st 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
order by on_st) x 
group by mft
having count(distinct left(date_installed::text,4)) > 1

)

and left(date_installed::text, 4) = '2014'

)


-- Selecting mft, masteridfrom, masteridto, date_installed, intrsct.date2, on_st,from_st, to_st that dont intersect with other years
select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st 
from data 
where mft not in (select mft from (select mft, masteridfrom, masteridto, date_installed, intrsct.date2, on_st,from_st, to_st from data
				   join   (

					-- All geometries from speed hump data that is within the study year range but 
					-- excluded from the year that we are focused on. So every year between 2011 and 2017
					-- except for 2014. 
					select distinct lion.geom, left(sh.date_installed::text,4) date2
					from v_clean_speed_humps sh
					join archive."18d.2019-11-13_lion" lion
					on sh.segmentid = lion.segmentid 
					where left(date_installed::text, 4)::int between 2011 and 2017
					and left(date_installed::text, 4)::int != 2014) intrsct
				   on  ST_Intersects(intrsct.geom, data.geom) -- Retrieving all geometries of multiple years that intersect with geometries of 2014. 
				   )final )
)x



where mft not in 


(select * from (

--Test 2
with data as(

--selecting all speed hump data from 2014

select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st, lion.geom 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text,4)::int = 2014
) 


--selecting all data that does not intersect with any other data of other years. 
select distinct mft--, masteridfrom, masteridto, date_installed, on_st,from_st, to_st 
from data where mft not in(
select mft from(
select mft, masteridfrom, masteridto, date_installed, intrsct.date2, on_st,from_st, to_st from data
join   (
	-- All geometries from speed hump data that is within the study year range but 
	-- excluded from the year that we are focused on. So every year between 2011 and 2017
	-- except for 2014. 
	select distinct lion.geom, left(sh.date_installed::text,4) date2
	from v_clean_speed_humps sh
	join archive."18d.2019-11-13_lion" lion
	on sh.segmentid = lion.segmentid 
	where left(date_installed::text, 4)::int between 2011 and 2017
	and left(date_installed::text, 4)::int != 2014) intrsct
on  ST_Intersects(intrsct.geom, data.geom)
) mfts
)

) x

)


















--Control Group
select distinct lion.mft
from archive."18d.2019-11-13_lion" lion
join working.sip_projs y
on ST_intersects(lion.geom, y.geom)
where lion.mft not in (select distinct coalesce(mft,0)
		  from v_clean_speed_humps sh
		  join archive."18d.2019-11-13_lion" lion
		  on  ST_intersects(sh.geom, lion.geom)
		  where left(date_installed::text, 4)::int between 2011 and 2017)








with data as(

--selecting all speed hump data from 2014

select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st, lion.geom, lion.segmentid 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text,4)::int = 2014
) 

select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st 
from data 
where mft not in (
select distinct x.mft from(

--selecting all data that does not intersect with any other data of other years. 
select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st, geom 
from data where mft not in(
select mft from(
select mft, masteridfrom, masteridto, date_installed, intrsct.date2, on_st,from_st, to_st from data
join   (
	-- All geometries from speed hump data that is within the study year range but 
	-- excluded from the year that we are focused on. So every year between 2011 and 2017
	-- except for 2014. 
	select distinct lion.geom, left(sh.date_installed::text,4) date2
	from v_clean_speed_humps sh
	join archive."18d.2019-11-13_lion" lion
	on sh.segmentid = lion.segmentid 
	where left(date_installed::text, 4)::int between 2011 and 2017
	and left(date_installed::text, 4)::int != 2014) intrsct
on  ST_dwithin(intrsct.geom, data.geom, 5)
) mfts
)
) x 
join working.sip_projs y
on ST_intersects(x.geom, y.geom))











--12/26
---------------------------------------------------------------------------------------------------------------





--control
with data as (


select distinct coalesce(lion.mft,0) mft, coalesce(lion.masteridfrom,0) masteridfrom, coalesce(lion.masteridto,0) masteridto, lion.geom
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text, 4)::int between 2011 and 2017

)


select distinct mft, geom
from archive."18d.2019-11-13_lion" lion
where mft not in (select mft from data)
  and masteridfrom not in ((select masteridfrom mid from data)
			    union 
			   (select masteridto mid from data))
  and masteridto not in   ((select masteridfrom mid from data)
			    union 
			   (select masteridto mid from data))




					
--no sip control group
drop table if exists working.speed_hump_control_group; 

create table working.speed_hump_control_group as 

with data as (


select distinct coalesce(lion.mft,0) mft, coalesce(lion.masteridfrom,0) masteridfrom, coalesce(lion.masteridto,0) masteridto, lion.geom
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text, 4)::int between 2011 and 2017

)


select distinct mft, masteridfrom, masteridto, segmentid::int, nodeidfrom::int, nodeidto::int
from archive."18d.2019-11-13_lion" lion
where mft not in (select mft from data)
  and masteridfrom not in ((select masteridfrom mid from data)
			    union 
			   (select masteridto mid from data))
  and masteridto not in   ((select masteridfrom mid from data)
			    union 
			   (select masteridto mid from data))
  and mft not in (select mft::int from working.sip_projs)
  and masteridfrom not in ((select masteridfrom::int from working.sip_projs)
			    union 
			   (select masteridto::int from working.sip_projs))
  and masteridto not in ((select masteridfrom::int from working.sip_projs)
			    union 
			   (select masteridto::int from working.sip_projs))




select distinct nodeidfrom from working.speed_hump_control_group

union 

select distinct nodeidto from working.speed_hump_control_group





--All Data


with data as(

--selecting all speed hump data from 2014

select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st, lion.geom, lion.segmentid 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text,4)::int = 2014
) 


--selecting all data that does not intersect with any other data of other years. 
select distinct mft, masteridfrom, masteridto, on_st,from_st, to_st 
from data where mft not in(
				select coalesce(mft,0) from data
				join   (
					-- All geometries from speed hump data that is within the study year range but 
					-- excluded from the year that we are focused on. So every year between 2011 and 2017
					-- except for 2014. 
					select distinct lion.geom
					from v_clean_speed_humps sh
					join archive."18d.2019-11-13_lion" lion
					on sh.segmentid = lion.segmentid 
					where left(date_installed::text, 4)::int between 2011 and 2017
					and left(date_installed::text, 4)::int != 2014) intrsct
				on  ST_dwithin(intrsct.geom, data.geom, 5))
		and mft in (66602, 113129)



--All data 2

with data1 as(

--selecting all speed hump data from 2014

select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st, lion.geom, lion.segmentid 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text,4)::int = 2014
)

, data2 as(

select distinct coalesce(lion.mft,0) mft, coalesce(lion.masteridfrom,0) masteridfrom, coalesce(lion.masteridto,0) masteridto, lion.geom
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text, 4)::int between 2011 and 2017
and left(date_installed::text, 4)::int != 2014
)

--selecting all data that does not intersect with any other data of other years. 
select distinct mft, masteridfrom, masteridto, on_st,from_st, to_st 
from data1 where mft not in(select mft from data2)
		and masteridfrom not in ((select masteridfrom mid from data2)
					  union 
					 (select masteridto mid from data2))
		and masteridto not in   ((select masteridfrom mid from data2)
					  union 
					 (select masteridto mid from data2))




--All no sip 2014 Data
with data as(

--selecting all speed hump data from 2014

select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st, lion.geom, lion.segmentid 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text,4)::int = 2014
) 


--selecting all data that does not intersect with any other data of other years. 
select distinct mft, masteridfrom, masteridto, on_st,from_st, to_st 
from data where mft not in(
				select coalesce(mft,0) from data
				join   (
					-- All geometries from speed hump data that is within the study year range but 
					-- excluded from the year that we are focused on. So every year between 2011 and 2017
					-- except for 2014. 
					select distinct lion.geom
					from v_clean_speed_humps sh
					join archive."18d.2019-11-13_lion" lion
					on sh.segmentid = lion.segmentid 
					where left(date_installed::text, 4)::int between 2011 and 2017
					and left(date_installed::text, 4)::int != 2014) intrsct
				on  ST_dwithin(intrsct.geom, data.geom, 5))
		and mft not in (select mft::int from working.sip_projs)
		and masteridfrom not in ((select masteridfrom::int from working.sip_projs)
					  union 
					  (select masteridto::int from working.sip_projs))
		and masteridto not in   ((select masteridfrom::int from working.sip_projs)
					  union 
					  (select masteridto::int from working.sip_projs))









--All no sip 2014 Data

drop table if exists working.speed_hump_study_group; 

create table working.speed_hump_study_group as 

with data1 as(

--selecting all speed hump data from 2014

select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st, lion.geom, lion.segmentid 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text,4)::int = 2014
)

, data2 as(

select distinct coalesce(lion.mft,0) mft, coalesce(lion.masteridfrom,0) masteridfrom, coalesce(lion.masteridto,0) masteridto, lion.geom
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text, 4)::int between 2011 and 2017
and left(date_installed::text, 4)::int != 2014
)

--selecting all data that does not intersect with any other data of other years. 
select distinct data1.mft, data1.masteridfrom, data1.masteridto, lion.segmentid::int, lion.nodeidfrom::int, lion.nodeidto::int, on_st,from_st, to_st 
from data1 
join archive."18d.2019-11-13_lion" lion
on data1.segmentid = lion.segmentid 
where data1.mft not in(select mft from data2)
		and data1.masteridfrom not in ((select masteridfrom mid from data2)
					  union 
					 (select masteridto mid from data2))
		and data1.masteridto not in   ((select masteridfrom mid from data2)
					  union 
					 (select masteridto mid from data2))
		and data1.mft not in (select mft::int from working.sip_projs)
		and data1.masteridfrom not in ((select masteridfrom::int from working.sip_projs)
					  union 
					  (select masteridto::int from working.sip_projs))
		and data1.masteridto not in   ((select masteridfrom::int from working.sip_projs)
					  union 
					  (select masteridto::int from working.sip_projs));

select * from working.speed_hump_focus_group; 










--Difference

select * from (
select mft from (


with data as(

--selecting all speed hump data from 2014

select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st, lion.geom, lion.segmentid 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text,4)::int = 2014
) 


--selecting all data that does not intersect with any other data of other years. 
select distinct mft, masteridfrom, masteridto, on_st,from_st, to_st 
from data where mft not in(
				select coalesce(mft,0) from data
				join   (
					-- All geometries from speed hump data that is within the study year range but 
					-- excluded from the year that we are focused on. So every year between 2011 and 2017
					-- except for 2014. 
					select distinct lion.geom
					from v_clean_speed_humps sh
					join archive."18d.2019-11-13_lion" lion
					on sh.segmentid = lion.segmentid 
					where left(date_installed::text, 4)::int between 2011 and 2017
					and left(date_installed::text, 4)::int != 2014) intrsct
				on  ST_dwithin(intrsct.geom, data.geom, 5))
)x
)y
where mft not in (

select mft from (



--All 2014 Data
with data1 as(

--selecting all speed hump data from 2014

select distinct mft, masteridfrom, masteridto, date_installed, on_st,from_st, to_st, lion.geom, lion.segmentid 
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text,4)::int = 2014
)

, data2 as(

select distinct coalesce(lion.mft,0) mft, coalesce(lion.masteridfrom,0) masteridfrom, coalesce(lion.masteridto,0) masteridto, lion.geom
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text, 4)::int between 2011 and 2017
and left(date_installed::text, 4)::int != 2014
)

--selecting all data that does not intersect with any other data of other years. 
select distinct mft, masteridfrom, masteridto, on_st,from_st, to_st 
from data1 where mft not in(select mft from data2)
		and masteridfrom not in ((select masteridfrom mid from data2)
					  union 
					 (select masteridto mid from data2))
		and masteridto not in   ((select masteridfrom mid from data2)
					  union 
					 (select masteridto mid from data2))


)t

)



















--INJURIES
select * from speed_hump_focus_group




with data as(

select nys_a.*
from archive."2019_11_13_nysdot_all" nys_a
join archive."18d.2019-11-13_lion" lion
on nys_a.mft = lion.mft
where nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
	and nys_a.case_yr != 2014
	and (nys_a.mft in (select mft from speed_hump_focus_group)
        or  nys_a.masterid in (select masteridfrom from speed_hump_focus_group)
        or nys_a.masterid in (select mft from speed_hump_focus_group))

)


--Injuries/Severity By Mode
select  case when case_yr between 2011 and 2013 then 'Before' 
	     when case_yr between 2015 and 2017 then 'After' end,
sum(case when accd_type_int = 1 then num_of_inj end) as ped,
sum(case when accd_type_int = 2 then num_of_inj end) as bicycle,
sum(case when accd_type_int = 3 then num_of_inj end) as mvo
--sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS si
from data
group by case when case_yr between 2011 and 2013 then 'Before' 
	     when case_yr between 2015 and 2017 then 'After' end

select * from working.sip_projs




----------------------------------------------------------

drop table if exists inclusive_group; 

create table inclusive_group as 


with data as (


select distinct coalesce(lion.mft,0) mft, coalesce(lion.masteridfrom,0) masteridfrom, coalesce(lion.masteridto,0) masteridto, lion.geom
from v_clean_speed_humps sh
join archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid 
where left(date_installed::text, 4)::int between 2011 and 2017

)



select distinct mft, masteridfrom, masteridto, segmentid::int, nodeidfrom::int, nodeidto::int
from archive."18d.2019-11-13_lion" lion
where mft in (select mft from data)
  or masteridfrom in ((select masteridfrom mid from data)
                            union 
                           (select masteridto mid from data))
  or masteridto in   ((select masteridfrom mid from data)
                            union 
                           (select masteridto mid from data))
  or mft in (select mft::int from working.sip_projs)
  or masteridfrom in ((select masteridfrom::int from working.sip_projs)
                            union 
                           (select masteridto::int from working.sip_projs))
  or masteridto in ((select masteridfrom::int from working.sip_projs)
                            union 
                           (select masteridto::int from working.sip_projs));


select distinct nodeidfrom from inclusive_group

union 

select distinct nodeidto from inclusive_group






                           
with data as(

select nys_a.*
from archive."2019_11_13_nysdot_all" nys_a
join archive."18d.2019-11-13_lion" lion
on nys_a.mft = lion.mft
where nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
	and (nys_a.mft in (select mft from speed_hump_focus_group)
        or  nys_a.masterid in (select masteridfrom from speed_hump_focus_group)
        or nys_a.masterid in (select mft from speed_hump_control_group))

)


--Injuries/Severity By Mode
select  case when accd_type_int = 1 then 'ped'
     when accd_type_int = 2 then 'bicycle'
     when accd_type_int = 3 then 'mvo' end, 
sum(num_of_inj), 
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS si
from data
group by  accd_type_int
order by  accd_type_int







select * from working.speed_hump_study_group
