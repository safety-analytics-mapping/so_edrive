
--SIP 702----------------------------------------------------------------------------------------------------------

drop table if exists sam_crashes_702; 

create table sam_crashes_702 as 

select nys_a.*
from archive."2019_11_13_nysdot_all" nys_a
join archive."18d.2019-11-13_lion" lion
on nys_a.mft = lion.mft
where nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and lion.segmentid::int in (70923,70925,70927,70951,70953,70957,71088,71121,111044,111222,111226,111227,111228,173841,173842,173843,173862,173863,173864)


union


select nys_a.*
from archive."2019_11_13_nysdot_all" nys_a
where masterid in (
		select masteridfrom mid
		from archive."18d.2019-11-13_lion" lion
		where mft in (
		select mft
		from archive."18d.2019-11-13_lion" lion
		where lion.segmentid::int in (70923,70925,70927,70951,70953,70957,71088,71121,111044,111222,111226,111227,111228,173841,173842,173843,173862,173863,173864)
		)


		union 

		select masteridto mid
		from archive."18d.2019-11-13_lion" lion
		where mft in (
		select mft
		from archive."18d.2019-11-13_lion" lion
		where lion.segmentid::int in (70923,70925,70927,70951,70953,70957,71088,71121,111044,111222,111226,111227,111228,173841,173842,173843,173862,173863,173864)
		)
)
and  nys_a.case_yr>= 2013 and nys_a.case_yr<=2017;

grant all on sam_crashes_702 to public;

select distinct 
case when accd_type_int = 1 then 'ped'
     when accd_type_int = 2 then 'bicycle'
     when accd_type_int = 3 then 'mvo' end
from sam_crashes_702  


--Fatals---------------------------
drop table if exists sam_fatalities_702; 

create table sam_fatalities_702 as 

select segmentid, nodeidfrom, nodeidto 
from archive."18d.2019-11-13_lion" lion
where lion.mft in (
		select mft
		from archive."18d.2019-11-13_lion" 
		where segmentid::int in (70923,70925,70927,70951,70953,70957,71088,71121,111044,111222,111226,111227,111228,173841,173842,173843,173862,173863,173864)
		 )	
-----------------------------------------------------------------





--Injury Summary------------------------------------------------------------------------------------------------------------------

with data as(
select "Type", sum("Total Injuries") "Total Injuries", sum("Severe Injuries") "Severe Injuries", sum("Fatalities") "Fatalities", sum("Severe Injuries"  + "Fatalities") as "KSI"
from (
	select * from (
	--Injuries/Severity By Mode
	select  case when accd_type_int = 1 then '1. ped'
		     when accd_type_int = 2 then '2. bicycle'
		     when accd_type_int = 3 then '3. mvo' end as "Type"
		,sum(num_of_inj) as "Total Injuries"
		,sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) as "Severe Injuries"
		,0 as "Fatalities"
	from sam_crashes_702
	group by  accd_type_int
	order by  accd_type_int
	) x

	union 


	-- All fatalities on corridors of stretch
	select case when pos = 'PD' then '1. ped'
		    when pos = 'BI' then '2. bicycle'
		    when pos in ('MO','PS','DR') then '3. mvo' end as "Type"
	       ,0 as "Total Injuries"
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	from public.fatality_nycdot_current fat
	where fat.segmentid in (select segmentid from sam_fatalities_702)
	and date_part('year',acdate) between 2013 and 2017
	group by pos

	union 

	-- All fatalities on intersections of stretch
	select case when pos = 'PD' then '1. ped'
		    when pos = 'BI' then '2. bicycle'
		    when pos in ('MO','PS','DR') then '3. mvo' end as "Type"
	       ,0 as "Total Injuries"
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	from public.fatality_nycdot_current fat
	where fat.nodeid::int in ( select distinct nodeid::int from(
						select nodeidfrom nodeid from sam_fatalities_702 
						union
						select nodeidto nodeid from sam_fatalities_702) x)
	and date_part('year',acdate) between 2013 and 2017
	group by pos
) inj_sum
group by "Type"
)

select * from (
select *
from data

union

select 'Total' as "Type", "Total Injuries","Severe Injuries", "Fatalities", "KSI" 
from (select 'Total' as Year, 
      sum(data."Total Injuries") "Total Injuries",
      sum(data."Severe Injuries") "Severe Injuries",
      sum(data."Fatalities") "Fatalities",
      sum(data."KSI") "KSI"
      from data
      ) tot
)inj_summary
order by "Type"



--Fatalities-------------------------------------------------------------


select case when pos = 'PD' then 'ped'
	    when pos = 'BI' then 'bicycle'
	    when pos in ('MO','PS','DR') then 'mvo' end as "Type"
      ,count(case when date_part('year',acdate) between 2013 and 2017 then id_ end) as "2013-2017 (5 Years)"
      ,count(case when date_part('year',acdate)>=2013 and acdate < '07-07-2019'::date then id_ end) as "2013-07/07/2019 (7 Years)"
from public.fatality_nycdot_current fat
where fat.segmentid in (select segmentid from sam_fatalities_702)
group by pos

union 



select case when pos = 'PD' then 'ped'
	    when pos = 'BI' then 'bicycle'
	    when pos in ('MO','PS','DR') then 'mvo' end as "Type"
      ,count(case when date_part('year',acdate) between 2013 and 2017 then id_ end) as "2013-2017 (5 Years)"
      ,count(case when date_part('year',acdate)>=2013 and acdate < '07-07-2019'::date then id_ end) as "2013-07/07/2019 (7 Years)"
from public.fatality_nycdot_current fat
where fat.nodeid::int in (select distinct nodeid::int from(
					select nodeidfrom nodeid from sam_fatalities_702 
					union
					select nodeidto nodeid from sam_fatalities_950) x)
group by pos


--NON-FATAL INJURIES BY SEVERITY---------------------------------------------------


with data as(
select * from (
select 
'1. A' as Severity,
sum(case when accd_type_int = 1 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) end) Pedestrian,
sum(case when accd_type_int = 2 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) end) Bicyclist,
sum(case when accd_type_int = 3 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) end) "Motor Vehicle",
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) as "Total"
FROM sam_crashes_702

union

select 
'2. B' as Severity,
sum(case when accd_type_int = 1 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) end) Pedestrian,
sum(case when accd_type_int = 2 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) end) Bicyclist,
sum(case when accd_type_int = 3 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) end) "Motor Vehicle",
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) as "Total"
FROM sam_crashes_702

union

select 
'3. C' as Severity,
sum(case when accd_type_int = 1 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) end) Pedestrian,
sum(case when accd_type_int = 2 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) end) Bicyclist,
sum(case when accd_type_int = 3 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) end) "Motor Vehicle",
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) as "Total"
FROM sam_crashes_702

union

select 
'4. Unknown' as Severity,
sum(case when accd_type_int = 1 and coalesce(length(ext_of_inj::text),0) != num_of_inj then (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0) end) Pedestrian,
sum(case when accd_type_int = 2 and coalesce(length(ext_of_inj::text),0) != num_of_inj then (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0)  end) Bicyclist,
sum(case when accd_type_int = 3 and coalesce(length(ext_of_inj::text),0) != num_of_inj then (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0)  end) "Motor Vehicle",
sum(num_of_inj - coalesce(length(ext_of_inj::text),0)) as "Total"
FROM sam_crashes_702

)sev
order by severity
)


select * from (
select * 
from data

union 

select '5. Total' as Severity, Pedestrian, Bicyclist, "Motor Vehicle", "Total"
from (select 'Total' as Year, 
      sum(data.Pedestrian) Pedestrian,
      sum(data.Bicyclist) Bicyclist,
      sum(data."Motor Vehicle") "Motor Vehicle",
      sum(data."Total") "Total"
      from data
      ) tot
)non_fat_inj
order by severity


--Injuries by year---------------------------------------------------


select * from (
with data as (
select 
case_yr::text as Year,
coalesce(sum(case when accd_type_int = 1 then num_of_inj end),0) "Pedestrian", 
coalesce(sum(case when accd_type_int = 2 then num_of_inj end),0) "Bicyclist",
coalesce(sum(case when accd_type_int = 3 then num_of_inj end),0) "Motor Vehicle"
from sam_crashes_702
group by case_yr
order by case_yr
)

select data.*, "Pedestrian"+"Bicyclist"+"Motor Vehicle" Total
from data

union 

select tot.*, "Pedestrian"+"Bicyclist"+"Motor Vehicle" Total
from (select 'Total' as Year, 
      sum(data."Pedestrian") "Pedestrian",
      sum(data."Bicyclist") "Bicyclist",
      sum(data."Motor Vehicle") "Motor Vehicle"
      from data
	) tot
)inj_year
order by year



--Injuries by time of day by type---------------------------------------------------



with data as (
select 
case when date_part('hour',accd_tme) = 0 and date_part('minute',accd_tme) = 0 then '9. Unknown'
     when date_part('hour',accd_tme) between 0 and 2 then '1. 00:00-03:00' 
     when date_part('hour',accd_tme) between 3 and 5 then '2. 03:00-06:00' 
     when date_part('hour',accd_tme) between 6 and 8 then '3. 06:00-09:00' 
     when date_part('hour',accd_tme) between 9 and 11 then '4. 09:00-12:00' 
     when date_part('hour',accd_tme) between 12 and 14 then '5. 12:00-15:00' 
     when date_part('hour',accd_tme) between 15 and 17 then '6. 15:00-18:00' 
     when date_part('hour',accd_tme) between 18 and 20 then '7. 18:00-21:00' 
     when date_part('hour',accd_tme) between 21 and 23 then '8. 21:00-24:00' end as Time,
coalesce(sum(case when accd_type_int = 1 then num_of_inj end),0) "Pedestrian", 
coalesce(sum(case when accd_type_int = 2 then num_of_inj end),0) "Bicyclist",
coalesce(sum(case when accd_type_int = 3 then num_of_inj end),0) "Motor Vehicle"
from sam_crashes_702
group by case when date_part('hour',accd_tme) = 0 and date_part('minute',accd_tme) = 0 then '9. Unknown'
     when date_part('hour',accd_tme) between 0 and 2 then '1. 00:00-03:00' 
     when date_part('hour',accd_tme) between 3 and 5 then '2. 03:00-06:00' 
     when date_part('hour',accd_tme) between 6 and 8 then '3. 06:00-09:00' 
     when date_part('hour',accd_tme) between 9 and 11 then '4. 09:00-12:00' 
     when date_part('hour',accd_tme) between 12 and 14 then '5. 12:00-15:00' 
     when date_part('hour',accd_tme) between 15 and 17 then '6. 15:00-18:00' 
     when date_part('hour',accd_tme) between 18 and 20 then '7. 18:00-21:00' 
     when date_part('hour',accd_tme) between 21 and 23 then '8. 21:00-24:00' end
 order by case when date_part('hour',accd_tme) = 0 and date_part('minute',accd_tme) = 0 then '9. Unknown'
     when date_part('hour',accd_tme) between 0 and 2 then '1. 00:00-03:00' 
     when date_part('hour',accd_tme) between 3 and 5 then '2. 03:00-06:00' 
     when date_part('hour',accd_tme) between 6 and 8 then '3. 06:00-09:00' 
     when date_part('hour',accd_tme) between 9 and 11 then '4. 09:00-12:00' 
     when date_part('hour',accd_tme) between 12 and 14 then '5. 12:00-15:00' 
     when date_part('hour',accd_tme) between 15 and 17 then '6. 15:00-18:00' 
     when date_part('hour',accd_tme) between 18 and 20 then '7. 18:00-21:00' 
     when date_part('hour',accd_tme) between 21 and 23 then '8. 21:00-24:00' end)

select * from (
select data.*, 
"Pedestrian"+"Bicyclist"+"Motor Vehicle" Total,
(round((("Pedestrian"+"Bicyclist"+"Motor Vehicle")::float/(select sum(num_of_inj) from sam_crashes_702)::float)::numeric, 3)*100.0)::text as "Percent of Known Crashes"
from data

union 

select tot.*, "Pedestrian"+"Bicyclist"+"Motor Vehicle" Total, 'N/A' as "Percent of Known Crashes"
from (select 'Total' as Time, 
      sum(data."Pedestrian") "Pedestrian",
      sum(data."Bicyclist") "Bicyclist",
      sum(data."Motor Vehicle") "Motor Vehicle"
      from data
      ) tot
)inj_tod
order by time




--Pedestrian Injuries By Control and Pedestrian Action---------------------------------------------------

with data as (
select 
CASE WHEN TRAF_CNTL = '02' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '1. Signalized Intersection: Crossing With Signal'
     WHEN TRAF_CNTL = '02' AND PED_ACTN = '02' AND PED_LOC = '1' THEN '2. Signalized Intersection: Crossing Against Signal'
     WHEN TRAF_CNTL = '03' AND PED_LOC = '1' THEN '3. Stop-Controlled Intersection / Crosswalk'
     WHEN TRAF_CNTL = '01' AND PED_LOC = '1' THEN '4. Other Actions/Uncontrolled Intersection'
     WHEN PED_LOC = '2' THEN '5. Midblock'
     WHEN TRAF_CNTL = '20' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '6. Other Control Types'
     ELSE '8. Unknown/Indeterminate' END as " ", 
coalesce(sum(num_of_inj),0) "Number of Injuries"
from sam_crashes_702
where accd_type_int = 1
group by CASE WHEN TRAF_CNTL = '02' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '1. Signalized Intersection: Crossing With Signal'
     WHEN TRAF_CNTL = '02' AND PED_ACTN = '02' AND PED_LOC = '1' THEN '2. Signalized Intersection: Crossing Against Signal'
     WHEN TRAF_CNTL = '03' AND PED_LOC = '1' THEN '3. Stop-Controlled Intersection / Crosswalk'
     WHEN TRAF_CNTL = '01' AND PED_LOC = '1' THEN '4. Other Actions/Uncontrolled Intersection'
     WHEN PED_LOC = '2' THEN '5. Midblock'
     WHEN TRAF_CNTL = '20' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '6. Other Control Types'
     ELSE '8. Unknown/Indeterminate' END

)

select * from (
select data.*, 
(round((("Number of Injuries")/(select sum("Number of Injuries") from data where data." " != '8. Unknown/Indeterminate')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
from data
where data." " != '8. Unknown/Indeterminate'

union

select data.*, 'N/A' as "Percent of Known Injuries"
from data
where data." " = '8. Unknown/Indeterminate'

union

select 
'7. Total Known' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, (round((sum("Number of Injuries")/(select sum("Number of Injuries") from data where data." " != '8. Unknown/Indeterminate')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
from data
where data." " != '8. Unknown/Indeterminate'

union


select 
'Total' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, 'N/A' as "Percent of Known Injuries"
from data
) ped_inj_con
order by " "


--Bicycle Injuries By Intersection Control and Bicyclist Action---------------------------------------------------


with data as (
select 
CASE WHEN TRAF_CNTL = '02' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '1. Signalized Intersection: Crossing With Signal'
     WHEN TRAF_CNTL = '02' AND PED_ACTN = '02' AND PED_LOC = '1' THEN '2. Signalized Intersection: Crossing Against Signal'
     WHEN TRAF_CNTL = '03' AND PED_LOC = '1' THEN '3. Stop-Controlled Intersection / Crosswalk'
     WHEN TRAF_CNTL = '01' AND PED_LOC = '1' THEN '4. Other Actions/Uncontrolled Intersection'
     WHEN PED_LOC = '2' THEN '5. Midblock'
     WHEN TRAF_CNTL = '20' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '6. Other Control Types'
     ELSE '8. Unknown/Indeterminate' END as " ", 
coalesce(sum(num_of_inj),0) "Number of Injuries"
from sam_crashes_702
where accd_type_int = 2
group by CASE WHEN TRAF_CNTL = '02' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '1. Signalized Intersection: Crossing With Signal'
     WHEN TRAF_CNTL = '02' AND PED_ACTN = '02' AND PED_LOC = '1' THEN '2. Signalized Intersection: Crossing Against Signal'
     WHEN TRAF_CNTL = '03' AND PED_LOC = '1' THEN '3. Stop-Controlled Intersection / Crosswalk'
     WHEN TRAF_CNTL = '01' AND PED_LOC = '1' THEN '4. Other Actions/Uncontrolled Intersection'
     WHEN PED_LOC = '2' THEN '5. Midblock'
     WHEN TRAF_CNTL = '20' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '6. Other Control Types'
     ELSE '8. Unknown/Indeterminate' END

)

select * from (
select data.*, 
(round((("Number of Injuries")/(select sum("Number of Injuries") from data where data." " != '8. Unknown/Indeterminate')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
from data
where data." " != '8. Unknown/Indeterminate'

union

select data.*, 'N/A' as "Percent of Known Injuries"
from data
where data." " = '8. Unknown/Indeterminate'

union

select 
'7. Total Known' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, (round((sum("Number of Injuries")/(select sum("Number of Injuries") from data where data." " != '8. Unknown/Indeterminate')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
from data
where data." " != '8. Unknown/Indeterminate'

union


select 
'Total' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, 'N/A' as "Percent of Known Injuries"
from data
) ped_inj_con
order by " " 




--Motor Vehicle Injuries By Collision Type---------------------------------------------------

with data as(
select 
CASE WHEN collision_ in ('03','10') THEN '1. Left Turn'
     WHEN collision_ in ('05','06') THEN '2. Right Turn'
     WHEN collision_ = '01' THEN '3. Rear-End'
     WHEN collision_ = '04' THEN '4. Right-Angle'
     WHEN collision_ = '02' THEN '5. Sideswipe(Same Direction)'
     WHEN collision_ = '07' THEN '6. Head-on'
     WHEN collision_ = '08' THEN '7. Sideswipe(Opposite Direction)'
     WHEN collision_ = '09' THEN '8. Other Known'
     WHEN collision_ in ('00','ZZ') THEN 'Unknown' END as " ",
sum(num_of_inj) as "Number of Injuries"--, crashid
from sam_crashes_702
where accd_type_int = 3
group by CASE WHEN collision_ in ('03','10') THEN '1. Left Turn'
     WHEN collision_ in ('05','06') THEN '2. Right Turn'
     WHEN collision_ = '01' THEN '3. Rear-End'
     WHEN collision_ = '04' THEN '4. Right-Angle'
     WHEN collision_ = '02' THEN '5. Sideswipe(Same Direction)'
     WHEN collision_ = '07' THEN '6. Head-on'
     WHEN collision_ = '08' THEN '7. Sideswipe(Opposite Direction)'
     WHEN collision_ = '09' THEN '8. Other Known'
     WHEN collision_ in ('00','ZZ') THEN 'Unknown' END--, crashid
order by " "
)

select * from (
select data.*, 
(round((("Number of Injuries")/(select sum("Number of Injuries") from data where data." " != 'Unknown')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
from data
where data." " != 'Unknown'

union

select data.*, 'N/A' as "Percent of Known Injuries"
from data
where data." " = 'Unknown'

union

select 
'9. Total Known' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, (round((sum("Number of Injuries")/(select sum("Number of Injuries") from data where data." " != 'Unknown')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
from data
where data." " != 'Unknown'

union

select 
'Total' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, 'N/A' as "Percent of Known Injuries"
from data
) ped_inj_con
order by " " 



--Injuries By Age Group---------------------------------------------------


with data as(
select 
CASE WHEN ages.age::int between 1 and 17 and num_of_inj = 1 THEN '1. Children(1-17)'
     WHEN ages.age::int between 18 and 29 and num_of_inj = 1 THEN '2. Young Adults(18-29)'
     WHEN ages.age::int between 30 and 64 and num_of_inj = 1 THEN '3. Adults(30-64)'
     WHEN ages.age::int between 65 and 120 and num_of_inj = 1 THEN '4. Seniors(65-120)'
     WHEN ages.age is null or num_of_inj!=1 THEN '5. Unknown' End "Age Group",
coalesce(sum(case when accd_type_int = 1 then num_of_inj end),0) "Pedestrian", 
coalesce(sum(case when accd_type_int = 2 then num_of_inj end),0) "Bicyclist" 
from sam_crashes_702
left join (select nys_v.crashid, age 
	   from (select distinct crashid
		 from archive."2019_11_13_nysdot_vehicle"
		 where age between 1 and 120
		 and veh_typ in ('5','6')
		 group by crashid
		 having count(crashid) =1
		 ) nys_v
	         join archive."2019_11_13_nysdot_vehicle" nys_v_age
		 on nys_v.crashid = nys_v_age.crashid
		 where veh_typ in ('5','6')
	  ) ages
on sam_crashes_702.crashid = ages.crashid
group by CASE WHEN ages.age::int between 1 and 17 and num_of_inj = 1 THEN '1. Children(1-17)'
     WHEN ages.age::int between 18 and 29 and num_of_inj = 1 THEN '2. Young Adults(18-29)'
     WHEN ages.age::int between 30 and 64 and num_of_inj = 1 THEN '3. Adults(30-64)'
     WHEN ages.age::int between 65 and 120 and num_of_inj = 1 THEN '4. Seniors(65-120)'
     WHEN ages.age is null or num_of_inj!=1 THEN '5. Unknown' End
order by "Age Group"
)

select * from (
select data.*, "Pedestrian"+"Bicyclist" Total
from data

union 

select tot.*, "Pedestrian"+"Bicyclist" Total
from (select 'Total' as Year, 
      sum(data."Pedestrian") "Pedestrian",
      sum(data."Bicyclist") "Bicyclist"
      from data
	) tot

) inj_age
order by "Age Group"



















--Ped Injuries By Veh Action And Pre Action---------------------------------------------------

with data as(
select 
CASE WHEN pre_accd_actn = '03' THEN '1. Left Turn'
     WHEN pre_accd_actn = '02' THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') THEN '6. Other'   
     WHEN pre_accd_actn = 'ZZ' or single_veh.crashid is null THEN '7. Unknown' END as " ",
coalesce(sum(case when ped_actn = '01' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing With Signal",
coalesce(sum(case when ped_actn = '02' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing Against Signal",
coalesce(sum(case when ped_actn = '03' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing No Signal Marked Crosswalk",
coalesce(sum(case when ped_actn = '04' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing No Signal or Crosswalk",
coalesce(sum(case when ped_actn not in ('01','02','03','04','??','YY','XX','ZZ') and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Others",
coalesce(sum(case when ped_actn = 'ZZ' or single_ped.crashid is null or (num_of_inj>1 and single_ped.crashid is not null) THEN num_of_inj END),0) as "UnKnown"
from sam_crashes_702
left join (select distinct crashid
		 from archive."2019_11_13_nysdot_vehicle"
		 where veh_typ = '6'
		 group by crashid
		 having count(crashid) = 1) single_ped
    on sam_crashes_702.crashid = single_ped.crashid
left join (select sv.crashid, sv2.pre_accd_actn
	   from (select distinct crashid--, pre_accd_actn
				 from archive."2019_11_13_nysdot_vehicle"
				 where veh_typ not in ('5','6')		
				 group by crashid--, pre_accd_actn
				 having count(crashid) = 1)sv
		 left join (select distinct crashid, pre_accd_actn
			   from archive."2019_11_13_nysdot_vehicle"
			   where pre_accd_actn not in ('??','YY','XX')) sv2
		    on sv.crashid = sv2.crashid) single_veh
    on sam_crashes_702.crashid = single_veh.crashid
where accd_type_int = 1
group by CASE WHEN pre_accd_actn = '03' THEN '1. Left Turn'
     WHEN pre_accd_actn = '02' THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') THEN '6. Other'     
     WHEN pre_accd_actn = 'ZZ' or single_veh.crashid is null THEN '7. Unknown' END
limit  7
)


SELECT * FROM (
select data.*, "Crossing With Signal" + "Crossing Against Signal" + "Crossing No Signal Marked Crosswalk" + "Crossing No Signal or Crosswalk" +  "Others" + "UnKnown" Total
from data

union 

select tot.*, "Crossing With Signal" + "Crossing Against Signal" + "Crossing No Signal Marked Crosswalk" + "Crossing No Signal or Crosswalk" +  "Others" + "UnKnown" Total
from (select 'Total' as " ", 
      sum(data."Crossing With Signal") "Crossing With Signal",
      sum(data."Crossing Against Signal") "Crossing Against Signal",
      sum(data."Crossing No Signal Marked Crosswalk") "Crossing No Signal Marked Crosswalk",
      sum(data."Crossing No Signal or Crosswalk") "Crossing No Signal or Crosswalk",
      sum(data."Others") "Others",
      sum(data."UnKnown") "UnKnown"
      from data
	) tot

) ped_veh_actn
order by " "




--SUB QUERY FOR UNKNOWNS
select 
CASE WHEN pre_accd_actn = '03' THEN '1. Left Turn'
     WHEN pre_accd_actn = '02' THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') THEN '6. Other'   
     WHEN pre_accd_actn = 'ZZ' or single_veh.crashid is null THEN '7. Unknown' END as " ",
coalesce(sum(case when ped_actn = 'ZZ' or single_ped.crashid is null or (num_of_inj>1 and single_ped.crashid is not null) THEN num_of_inj END),0) as "UnKnown"
,sam_crashes_702.crashid
from sam_crashes_702
left join (select distinct crashid
		 from archive."2019_11_13_nysdot_vehicle"
		 where veh_typ = '6'
		 group by crashid
		 having count(crashid) = 1) single_ped
    on sam_crashes_702.crashid = single_ped.crashid
left join (select sv.crashid, sv2.pre_accd_actn
	   from (select distinct crashid--, pre_accd_actn
				 from archive."2019_11_13_nysdot_vehicle"
				 where veh_typ not in ('5','6')		
				 group by crashid--, pre_accd_actn
				 having count(crashid) = 1)sv
		 left join (select distinct crashid, pre_accd_actn
			   from archive."2019_11_13_nysdot_vehicle"
			   where pre_accd_actn not in ('??','YY','XX')) sv2
		    on sv.crashid = sv2.crashid) single_veh
    on sam_crashes_702.crashid = single_veh.crashid
where accd_type_int = 1
group by CASE WHEN pre_accd_actn = '03' THEN '1. Left Turn'
     WHEN pre_accd_actn = '02' THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') THEN '6. Other'     
     WHEN pre_accd_actn = 'ZZ' or single_veh.crashid is null THEN '7. Unknown' END,sam_crashes_702.crashid




select * 
from sam_crashes_702 s
left join (select distinct crashid
		 from archive."2019_11_13_nysdot_vehicle"
		 where veh_typ = '6'
		 group by crashid
		 having count(crashid) = 1) single_ped
    on s.crashid = single_ped.crashid
left join (select sv.crashid, sv2.pre_accd_actn
	   from (select distinct crashid--, pre_accd_actn
				 from archive."2019_11_13_nysdot_vehicle"
				 where veh_typ not in ('5','6')		
				 group by crashid--, pre_accd_actn
				 having count(crashid) = 1)sv
		 left join (select distinct crashid, pre_accd_actn
			   from archive."2019_11_13_nysdot_vehicle"
			   where pre_accd_actn not in ('??','YY','XX')) sv2
		    on sv.crashid = sv2.crashid) single_vehicle
    on s.crashid = single_vehicle.crashid
where s.crashid = '350861042013'


