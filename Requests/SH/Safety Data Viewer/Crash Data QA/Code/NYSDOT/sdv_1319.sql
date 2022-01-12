
--SIP 1319----------------------------------------------------------------------------------------------------------

drop table if exists sam_crashes_1319; 

create table sam_crashes_1319 as 

select distinct nys_a.*
from archive."2019_11_13_nysdot_all" nys_a
join archive."18d.2019-11-13_node" lion
on nys_a.nodeid::int = lion.nodeid::int
where nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and lion.nodeid::int in (select nodeid 
			 from archive."18d.2019-11-13_node" 
			 where masterid in (
					    select masterid
					    from archive."18d.2019-11-13_node" 
					    where nodeid::int in (47444,100531,9031585,9031837)));


grant all on sam_crashes_1319 to public;

select sum(num_of_inj)
from sam_crashes_1319
where accd_type_int = 1 

 


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
	from sam_crashes_1319
	group by  accd_type_int
	order by  accd_type_int
	)injuries
	
	union 

	select * from (
	select case when pos = 'PD' then '1. ped'
		    when pos = 'BI' then '2. bicycle'
		    when pos in ('MO','PS','DR') then '3. mvo' end as "Type"
	       ,0 as "Total Injuries"
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	from public.fatality_nycdot_current fat
	where fat.nodeid::int in ( select * from sam_fatalities_1319)
	and date_part('year',acdate) between 2013 and 2017
	group by pos
	)fatalities

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


drop table if exists sam_fatalities_1319; 

create table sam_fatalities_1319 as 

select distinct nodeid 
from archive."18d.2019-11-13_node" 
where masterid in (
		    select masterid
		    from archive."18d.2019-11-13_node" 
		    where nodeid::int in (47444,100531,9031585,9031837))

select case when pos = 'PD' then 'ped'
	    when pos = 'BI' then 'bicycle'
	    when pos in ('MO','PS','DR') then 'mvo' end as "Type"
      ,count(case when date_part('year',acdate) between 2013 and 2017 then id_ end) as "2013-2017 (5 Years)"
      ,count(case when date_part('year',acdate)>=2013 and acdate < '07-07-2019'::date then id_ end) as "2013-07/07/2019 (7 Years)"
from public.fatality_nycdot_current fat
where  fat.nodeid::int in (select nodeid from sam_fatalities_1319)
group by pos



/*select * 
from public.fatality_nycdot_current fat
where pct = 41
and date_part('year',acdate) between 2013 and 2017*/


--NON-FATAL INJURIES BY SEVERITY---------------------------------------------------

with data as(
select * from (
select 
'1. A' as Severity,
sum(case when accd_type_int = 1 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) end) Pedestrian,
sum(case when accd_type_int = 2 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) end) Bicyclist,
sum(case when accd_type_int = 3 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) end) "Motor Vehicle",
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) as "Total"
FROM sam_crashes_1319

union

select 
'2. B' as Severity,
sum(case when accd_type_int = 1 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) end) Pedestrian,
sum(case when accd_type_int = 2 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) end) Bicyclist,
sum(case when accd_type_int = 3 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) end) "Motor Vehicle",
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) as "Total"
FROM sam_crashes_1319

union

select 
'3. C' as Severity,
sum(case when accd_type_int = 1 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) end) Pedestrian,
sum(case when accd_type_int = 2 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) end) Bicyclist,
sum(case when accd_type_int = 3 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) end) "Motor Vehicle",
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) as "Total"
FROM sam_crashes_1319

union

select 
'4. Unknown' as Severity,
sum(case when accd_type_int = 1 and coalesce(length(ext_of_inj::text),0) != num_of_inj then (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0) end) Pedestrian,
sum(case when accd_type_int = 2 and coalesce(length(ext_of_inj::text),0) != num_of_inj then (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0)  end) Bicyclist,
sum(case when accd_type_int = 3 and coalesce(length(ext_of_inj::text),0) != num_of_inj then (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0)  end) "Motor Vehicle",
sum((num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0)) as "Total"
FROM sam_crashes_1319

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



with data as (
select 
case_yr::text as Year,
coalesce(sum(case when accd_type_int = 1 then num_of_inj end),0) "Pedestrian", 
coalesce(sum(case when accd_type_int = 2 then num_of_inj end),0) "Bicyclist",
coalesce(sum(case when accd_type_int = 3 then num_of_inj end),0) "Motor Vehicle"
from sam_crashes_1319
group by case_yr
order by case_yr
)

select * from (
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


select * from (
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
from sam_crashes_1319
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


select data.*, 
"Pedestrian"+"Bicyclist"+"Motor Vehicle" Total,
(round((("Pedestrian"+"Bicyclist"+"Motor Vehicle")::float/(select sum(num_of_inj) from sam_crashes_950)::float)::numeric, 3)*100.0)::text as "Percent of Known Crashes"
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
from sam_crashes_1319
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
from sam_crashes_1319
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
select * from (
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
from sam_crashes_1319
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
--,' ' crashid
from data
where data." " != 'Unknown'

union

select 
'Total' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, 'N/A' as "Percent of Known Injuries"
--,' ' crashid
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
from sam_crashes_1319
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
on sam_crashes_1319.crashid = ages.crashid
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

