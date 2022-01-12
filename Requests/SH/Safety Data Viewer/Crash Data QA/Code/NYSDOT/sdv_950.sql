
--SIP 950----------------------------------------------------------------------------------------------------------

drop table if exists sam_crashes_950; 

create table sam_crashes_950 as 

SELECT distinct nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
JOIN archive."18d.2019-11-13_lion" lion
on nys_a.mft = lion.mft
WHERE nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and lion.segmentid::int in (82370,83437,83441,83525,83527,83529,83532,83533,83535,83537,83618,83620,83622,83624,111956,113871,145917,145918,145919,145920,148820,148821,148836,148837,148838,148839,148841,149046,149047,149048,149049,149050,149051,149053,149054,149056,149057,149058,149059,149060
			    ,149061,149062,149063,149064,149065,149066,149067,149068,149069,149070,149071,149072,149073,152926,153046,153132,153189,153829,153959,153986,154019,177087,177146,177148,177481,177531,177533,177535,177537,177539,177541,184774,234611,234612,239109,239110,9008651,9008652,9008661,9008665,9008666,9008668)

union


SELECT nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
WHERE masterid in (
		SELECT masteridFROM mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (82370,83437,83441,83525,83527,83529,83532,83533,83535,83537,83618,83620,83622,83624,111956,113871,145917,145918,145919,145920,148820,148821,148836,148837,148838,148839,148841,149046,149047,149048,149049,149050,149051,149053,149054,149056,149057,149058,149059,149060
					     ,149061,149062,149063,149064,149065,149066,149067,149068,149069,149070,149071,149072,149073,152926,153046,153132,153189,153829,153959,153986,154019,177087,177146,177148,177481,177531,177533,177535,177537,177539,177541,184774,234611,234612,239109,239110,9008651,9008652,9008661,9008665,9008666,9008668)
		
		)


		union 

		SELECT masteridto mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (82370,83437,83441,83525,83527,83529,83532,83533,83535,83537,83618,83620,83622,83624,111956,113871,145917,145918,145919,145920,148820,148821,148836,148837,148838,148839,148841,149046,149047,149048,149049,149050,149051,149053,149054,149056,149057,149058,149059,149060
					      ,149061,149062,149063,149064,149065,149066,149067,149068,149069,149070,149071,149072,149073,152926,153046,153132,153189,153829,153959,153986,154019,177087,177146,177148,177481,177531,177533,177535,177537,177539,177541,184774,234611,234612,239109,239110,9008651,9008652,9008661,9008665,9008666,9008668)
		)
)
and  nys_a.case_yr>= 2013 and nys_a.case_yr<=2017;

grant all on sam_crashes_950 to public;

SELECT sum(num_of_inj)
FROM sam_crashes_950 
WHERE accd_type_int = 1 


--Fatals---------------------------
drop table if exists sam_fatalities_950; 

create table sam_fatalities_950 as 

SELECT segmentid, nodeidFROM, nodeidto 
FROM archive."18d.2019-11-13_lion" lion
WHERE lion.mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" 
		WHERE segmentid::int in (82370,83437,83441,83525,83527,83529,83532,83533,83535,83537,83618,83620,83622,83624,111956,113871,145917,145918,145919,145920,148820,148821,148836,148837,148838,148839,148841,149046,149047,149048,149049,149050,149051,149053,149054,149056,149057,149058,149059,149060
					      ,149061,149062,149063,149064,149065,149066,149067,149068,149069,149070,149071,149072,149073,152926,153046,153132,153189,153829,153959,153986,154019,177087,177146,177148,177481,177531,177533,177535,177537,177539,177541,184774,234611,234612,239109,239110,9008651,9008652,9008661,9008665,9008666,9008668)
		  )




--Injury Summary------------------------------------------------------------------------------------------------------------------



WITH data as(
SELECT "Type", sum("Total Injuries") "Total Injuries", sum("Severe Injuries") "Severe Injuries", sum("Fatalities") "Fatalities", sum("Severe Injuries"  + "Fatalities") as "KSI"
FROM (
	SELECT * FROM (
	--Injuries/Severity By Mode
	SELECT  case when accd_type_int = 1 then '1. ped'
		     when accd_type_int = 2 then '2. bicycle'
		     when accd_type_int = 3 then '3. mvo' end as "Type"
		,sum(num_of_inj) as "Total Injuries"
		,sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) as "Severe Injuries"
		,0 as "Fatalities"
	FROM sam_crashes_950
	GROUP by  accd_type_int
	order by  accd_type_int
	) x

	union 


	-- All fatalities on corridors of stretch
	SELECT case when pos = 'PD' then '1. ped'
		    when pos = 'BI' then '2. bicycle'
		    when pos in ('MO','PS','DR') then '3. mvo' end as "Type"
	       ,0 as "Total Injuries"
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.segmentid in (SELECT segmentid FROM sam_fatalities_950)
	and date_part('year',acdate) between 2013 and 2017
	GROUP by pos

	union 

	-- All fatalities on intersections of stretch
	SELECT case when pos = 'PD' then '1. ped'
		    when pos = 'BI' then '2. bicycle'
		    when pos in ('MO','PS','DR') then '3. mvo' end as "Type"
	       ,0 as "Total Injuries"
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.nodeid::int in ( SELECT distinct nodeid::int FROM(
						SELECT nodeidFROM nodeid FROM sam_fatalities_950 
						union
						SELECT nodeidto nodeid FROM sam_fatalities_950) x)
	and date_part('year',acdate) between 2013 and 2017
	GROUP by pos
) inj_sum
GROUP by "Type"
)

SELECT * FROM (
SELECT *
FROM data

union

SELECT 'Total' as "Type", "Total Injuries","Severe Injuries", "Fatalities", "KSI" 
FROM (SELECT 'Total' as Year, 
      sum(data."Total Injuries") "Total Injuries",
      sum(data."Severe Injuries") "Severe Injuries",
      sum(data."Fatalities") "Fatalities",
      sum(data."KSI") "KSI"
      FROM data
      ) tot
)inj_summary
order by "Type"

--Most Dangerous-------------------------------------------------------

select nodeid, sum(num_of_inj)
from sam_crashes_950
GROUP BY nodeid

--KSI by Miles----------------------------------------------------------

with miles as(
select sum(len)/5280 len from (
SELECT segmentid, st_length(geom) len
FROM archive."18d.2019-11-13_lion" lion
WHERE lion.mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" 
		WHERE segmentid::int in (82370,83437,83441,83525,83527,83529,83532,83533,83535,83537,83618,83620,83622,83624,111956,113871,145917,145918,145919,145920,148820,148821,148836,148837,148838,148839,148841,149046,149047,149048,149049,149050,149051,149053,149054,149056,149057,149058,149059,149060
					      ,149061,149062,149063,149064,149065,149066,149067,149068,149069,149070,149071,149072,149073,152926,153046,153132,153189,153829,153959,153986,154019,177087,177146,177148,177481,177531,177533,177535,177537,177539,177541,184774,234611,234612,239109,239110,9008651,9008652,9008661,9008665,9008666,9008668)
		  )
and rb_layer in ('G','B')
) stretch
)

, ksi as(

Select sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) si

from sam_crashes_950 )

, fat as(
select (
	(SELECT count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.segmentid in (SELECT segmentid FROM sam_fatalities_950)
	and date_part('year',acdate) between 2013 and 2019) +

	-- All fatalities on intersections of stretch
	(SELECT count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.nodeid::int in ( SELECT distinct nodeid::int FROM(
						SELECT nodeidFROM nodeid FROM sam_fatalities_950 
						union
						SELECT nodeidto nodeid FROM sam_fatalities_950) x)
	and date_part('year',acdate) between 2013 and 2019) ) as k

	)

SELECT miles.len "LENGTH", (select si + k from ksi, fat)/len KSI
FROM miles



--Fatalities-------------------------------------------------------------


SELECT case when pos = 'PD' then 'ped'
	    when pos = 'BI' then 'bicycle'
	    when pos in ('MO','PS','DR') then 'mvo' end as "Type"
      ,count(case when date_part('year',acdate) between 2013 and 2017 then id_ end) as "2013-2017 (5 Years)"
      ,count(case when date_part('year',acdate)>=2013 and acdate < '07-07-2019'::date then id_ end) as "2013-07/07/2019 (7 Years)"
FROM public.fatality_nycdot_current fat
WHERE fat.segmentid in (SELECT segmentid FROM sam_fatalities_950)
GROUP by pos

union 



SELECT case when pos = 'PD' then 'ped'
	    when pos = 'BI' then 'bicycle'
	    when pos in ('MO','PS','DR') then 'mvo' end as "Type"
      ,count(case when date_part('year',acdate) between 2013 and 2017 then id_ end) as "2013-2017 (5 Years)"
      ,count(case when date_part('year',acdate)>=2013 and acdate < '07-07-2019'::date then id_ end) as "2013-07/07/2019 (7 Years)"
FROM public.fatality_nycdot_current fat
WHERE fat.nodeid::int in (SELECT distinct nodeid::int FROM(
					SELECT nodeidFROM nodeid FROM sam_fatalities_950 
					union
					SELECT nodeidto nodeid FROM sam_fatalities_950) x)
GROUP by pos


--NON-FATAL INJURIES BY SEVERITY---------------------------------------------------

WITH data as(
SELECT * FROM (
SELECT 
'1. A' as Severity,
sum(case when accd_type_int = 1 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) end) Pedestrian,
sum(case when accd_type_int = 2 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) end) Bicyclist,
sum(case when accd_type_int = 3 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) end) "Motor Vehicle",
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) as "Total"
FROM sam_crashes_950

union

SELECT 
'2. B' as Severity,
sum(case when accd_type_int = 1 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) end) Pedestrian,
sum(case when accd_type_int = 2 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) end) Bicyclist,
sum(case when accd_type_int = 3 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) end) "Motor Vehicle",
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) as "Total"
FROM sam_crashes_950

union

SELECT 
'3. C' as Severity,
sum(case when accd_type_int = 1 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) end) Pedestrian,
sum(case when accd_type_int = 2 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) end) Bicyclist,
sum(case when accd_type_int = 3 then length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) end) "Motor Vehicle",
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) as "Total"
FROM sam_crashes_950

union

SELECT 
'4. Unknown' as Severity,
sum(case when accd_type_int = 1 and coalesce(length(ext_of_inj::text),0) != num_of_inj then (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0) end) Pedestrian,
sum(case when accd_type_int = 2 and coalesce(length(ext_of_inj::text),0) != num_of_inj then (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0)  end) Bicyclist,
sum(case when accd_type_int = 3 and coalesce(length(ext_of_inj::text),0) != num_of_inj then (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0)  end) "Motor Vehicle",
sum(num_of_inj - coalesce(length(ext_of_inj::text),0)) as "Total"
FROM sam_crashes_950

)sev
order by severity
)


SELECT * FROM (
SELECT * 
FROM data

union 

SELECT '5. Total' as Severity, Pedestrian, Bicyclist, "Motor Vehicle", "Total"
FROM (SELECT 'Total' as Year, 
      sum(data.Pedestrian) Pedestrian,
      sum(data.Bicyclist) Bicyclist,
      sum(data."Motor Vehicle") "Motor Vehicle",
      sum(data."Total") "Total"
      FROM data
      ) tot
)non_fat_inj
order by severity




--Injuries by year---------------------------------------------------


SELECT * FROM (
WITH data as (
SELECT 
case_yr::text as Year,
coalesce(sum(case when accd_type_int = 1 then num_of_inj end),0) "Pedestrian", 
coalesce(sum(case when accd_type_int = 2 then num_of_inj end),0) "Bicyclist",
coalesce(sum(case when accd_type_int = 3 then num_of_inj end),0) "Motor Vehicle"
FROM sam_crashes_950
GROUP by case_yr
order by case_yr
)

SELECT data.*, "Pedestrian"+"Bicyclist"+"Motor Vehicle" Total
FROM data

union 

SELECT tot.*, "Pedestrian"+"Bicyclist"+"Motor Vehicle" Total
FROM (SELECT 'Total' as Year, 
      sum(data."Pedestrian") "Pedestrian",
      sum(data."Bicyclist") "Bicyclist",
      sum(data."Motor Vehicle") "Motor Vehicle"
      FROM data
	) tot
)inj_year
order by year





--Injuries by time of day by type---------------------------------------------------



WITH data as (
SELECT 
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
FROM sam_crashes_950
GROUP by case when date_part('hour',accd_tme) = 0 and date_part('minute',accd_tme) = 0 then '9. Unknown'
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

SELECT * FROM (
SELECT data.*, 
"Pedestrian"+"Bicyclist"+"Motor Vehicle" Total,
(round((("Pedestrian"+"Bicyclist"+"Motor Vehicle")::float/(SELECT sum(num_of_inj) FROM sam_crashes_950)::float)::numeric, 3)*100.0)::text as "Percent of Known Crashes"
FROM data

union 

SELECT tot.*, "Pedestrian"+"Bicyclist"+"Motor Vehicle" Total, 'N/A' as "Percent of Known Crashes"
FROM (SELECT 'Total' as Time, 
      sum(data."Pedestrian") "Pedestrian",
      sum(data."Bicyclist") "Bicyclist",
      sum(data."Motor Vehicle") "Motor Vehicle"
      FROM data
      ) tot
)inj_tod
order by time



--Pedestrian Injuries By Control and Pedestrian Action---------------------------------------------------


WITH data as (
SELECT 
CASE WHEN TRAF_CNTL = '02' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '1. Signalized Intersection: Crossing WITH Signal'
     WHEN TRAF_CNTL = '02' AND PED_ACTN = '02' AND PED_LOC = '1' THEN '2. Signalized Intersection: Crossing Against Signal'
     WHEN TRAF_CNTL = '03' AND PED_LOC = '1' THEN '3. Stop-Controlled Intersection / Crosswalk'
     WHEN TRAF_CNTL = '01' AND PED_LOC = '1' THEN '4. Other Actions/Uncontrolled Intersection'
     WHEN PED_LOC = '2' THEN '5. Midblock'
     WHEN TRAF_CNTL = '20' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '6. Other Control Types'
     ELSE '8. Unknown/Indeterminate' END as " ", 
coalesce(sum(num_of_inj),0) "Number of Injuries"
FROM sam_crashes_950
WHERE accd_type_int = 1
GROUP by CASE WHEN TRAF_CNTL = '02' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '1. Signalized Intersection: Crossing WITH Signal'
     WHEN TRAF_CNTL = '02' AND PED_ACTN = '02' AND PED_LOC = '1' THEN '2. Signalized Intersection: Crossing Against Signal'
     WHEN TRAF_CNTL = '03' AND PED_LOC = '1' THEN '3. Stop-Controlled Intersection / Crosswalk'
     WHEN TRAF_CNTL = '01' AND PED_LOC = '1' THEN '4. Other Actions/Uncontrolled Intersection'
     WHEN PED_LOC = '2' THEN '5. Midblock'
     WHEN TRAF_CNTL = '20' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '6. Other Control Types'
     ELSE '8. Unknown/Indeterminate' END

)

SELECT * FROM (
SELECT data.*, 
(round((("Number of Injuries")/(SELECT sum("Number of Injuries") FROM data WHERE data." " != '8. Unknown/Indeterminate')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
FROM data
WHERE data." " != '8. Unknown/Indeterminate'

union

SELECT data.*, 'N/A' as "Percent of Known Injuries"
FROM data
WHERE data." " = '8. Unknown/Indeterminate'

union

SELECT 
'7. Total Known' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, (round((sum("Number of Injuries")/(SELECT sum("Number of Injuries") FROM data WHERE data." " != '8. Unknown/Indeterminate')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
FROM data
WHERE data." " != '8. Unknown/Indeterminate'

union


SELECT 
'Total' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, 'N/A' as "Percent of Known Injuries"
FROM data
) ped_inj_con
order by " "



--Bicycle Injuries By Intersection Control and Bicyclist Action---------------------------------------------------


WITH data as (
SELECT 
CASE WHEN TRAF_CNTL = '02' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '1. Signalized Intersection: Crossing WITH Signal'
     WHEN TRAF_CNTL = '02' AND PED_ACTN = '02' AND PED_LOC = '1' THEN '2. Signalized Intersection: Crossing Against Signal'
     WHEN TRAF_CNTL = '03' AND PED_LOC = '1' THEN '3. Stop-Controlled Intersection / Crosswalk'
     WHEN TRAF_CNTL = '01' AND PED_LOC = '1' THEN '4. Other Actions/Uncontrolled Intersection'
     WHEN PED_LOC = '2' THEN '5. Midblock'
     WHEN TRAF_CNTL = '20' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '6. Other Control Types'
     ELSE '8. Unknown/Indeterminate' END as " ", 
coalesce(sum(num_of_inj),0) "Number of Injuries"
FROM sam_crashes_950
WHERE accd_type_int = 2
GROUP by CASE WHEN TRAF_CNTL = '02' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '1. Signalized Intersection: Crossing WITH Signal'
     WHEN TRAF_CNTL = '02' AND PED_ACTN = '02' AND PED_LOC = '1' THEN '2. Signalized Intersection: Crossing Against Signal'
     WHEN TRAF_CNTL = '03' AND PED_LOC = '1' THEN '3. Stop-Controlled Intersection / Crosswalk'
     WHEN TRAF_CNTL = '01' AND PED_LOC = '1' THEN '4. Other Actions/Uncontrolled Intersection'
     WHEN PED_LOC = '2' THEN '5. Midblock'
     WHEN TRAF_CNTL = '20' AND PED_ACTN = '01' AND PED_LOC = '1' THEN '6. Other Control Types'
     ELSE '8. Unknown/Indeterminate' END

)

SELECT * FROM (
SELECT data.*, 
(round((("Number of Injuries")/(SELECT sum("Number of Injuries") FROM data WHERE data." " != '8. Unknown/Indeterminate')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
FROM data
WHERE data." " != '8. Unknown/Indeterminate'

union

SELECT data.*, 'N/A' as "Percent of Known Injuries"
FROM data
WHERE data." " = '8. Unknown/Indeterminate'

union

SELECT 
'7. Total Known' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, (round((sum("Number of Injuries")/(SELECT sum("Number of Injuries") FROM data WHERE data." " != '8. Unknown/Indeterminate')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
FROM data
WHERE data." " != '8. Unknown/Indeterminate'

union


SELECT 
'Total' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, 'N/A' as "Percent of Known Injuries"
FROM data
) ped_inj_con
order by " " 


--Motor Vehicle Injuries By Collision Type---------------------------------------------------

WITH data as(
SELECT 
CASE WHEN collision_ in ('03','10') THEN '1. LEFT Turn'
     WHEN collision_ in ('05','06') THEN '2. Right Turn'
     WHEN collision_ = '01' THEN '3. Rear-End'
     WHEN collision_ = '04' THEN '4. Right-Angle'
     WHEN collision_ = '02' THEN '5. Sideswipe(Same Direction)'
     WHEN collision_ = '07' THEN '6. Head-on'
     WHEN collision_ = '08' THEN '7. Sideswipe(Opposite Direction)'
     WHEN collision_ = '09' THEN '8. Other Known'
     WHEN collision_ in ('00','ZZ') THEN 'Unknown' END as " ",
sum(num_of_inj) as "Number of Injuries"--, crashid
FROM sam_crashes_950
WHERE accd_type_int = 3
GROUP by CASE WHEN collision_ in ('03','10') THEN '1. LEFT Turn'
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

SELECT * FROM (
SELECT data.*, 
(round((("Number of Injuries")/(SELECT sum("Number of Injuries") FROM data WHERE data." " != 'Unknown')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
FROM data
WHERE data." " != 'Unknown'

union

SELECT data.*, 'N/A' as "Percent of Known Injuries"
FROM data
WHERE data." " = 'Unknown'

union

SELECT 
'9. Total Known' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, (round((sum("Number of Injuries")/(SELECT sum("Number of Injuries") FROM data WHERE data." " != 'Unknown')::float)::numeric, 3)*100.0)::text as "Percent of Known Injuries"
FROM data
WHERE data." " != 'Unknown'

union

SELECT 
'Total' as " " 
, sum("Number of Injuries") as "Number of Injuries"
, 'N/A' as "Percent of Known Injuries"
FROM data
) ped_inj_con
order by " " 


--Injuries By Age GROUP---------------------------------------------------

WITH data as(
SELECT 
CASE WHEN ages.age::int between 1 and 17 and num_of_inj = 1 THEN '1. Children(1-17)'
     WHEN ages.age::int between 18 and 29 and num_of_inj = 1 THEN '2. Young Adults(18-29)'
     WHEN ages.age::int between 30 and 64 and num_of_inj = 1 THEN '3. Adults(30-64)'
     WHEN ages.age::int between 65 and 120 and num_of_inj = 1 THEN '4. Seniors(65-120)'
     WHEN ages.age is null or num_of_inj!=1 THEN '5. Unknown' End "Age GROUP",
coalesce(sum(case when accd_type_int = 1 then num_of_inj end),0) "Pedestrian", 
coalesce(sum(case when accd_type_int = 2 then num_of_inj end),0) "Bicyclist" 
FROM sam_crashes_950
LEFT JOIN (SELECT nys_v.crashid, age 
	   FROM (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE age between 1 and 120
		 and veh_typ in ('5','6')
		 GROUP by crashid
		 HAVING count(crashid) =1
		 ) nys_v
	         JOIN archive."2019_11_13_nysdot_vehicle" nys_v_age
		 on nys_v.crashid = nys_v_age.crashid
		 WHERE veh_typ in ('5','6')
	  ) ages
on sam_crashes_950.crashid = ages.crashid
GROUP by CASE WHEN ages.age::int between 1 and 17 and num_of_inj = 1 THEN '1. Children(1-17)'
     WHEN ages.age::int between 18 and 29 and num_of_inj = 1 THEN '2. Young Adults(18-29)'
     WHEN ages.age::int between 30 and 64 and num_of_inj = 1 THEN '3. Adults(30-64)'
     WHEN ages.age::int between 65 and 120 and num_of_inj = 1 THEN '4. Seniors(65-120)'
     WHEN ages.age is null or num_of_inj!=1 THEN '5. Unknown' End
order by "Age GROUP"
)

SELECT * FROM (
SELECT data.*, "Pedestrian"+"Bicyclist" Total
FROM data

union 

SELECT tot.*, "Pedestrian"+"Bicyclist" Total
FROM (SELECT 'Total' as Year, 
      sum(data."Pedestrian") "Pedestrian",
      sum(data."Bicyclist") "Bicyclist"
      FROM data
	) tot

) inj_age
order by "Age GROUP"







--Ped Injuries By Veh Action And Pre Action---------------------------------------------------

WITH data as(
SELECT 
CASE WHEN pre_accd_actn = '03' THEN '1. Left Turn'
     WHEN pre_accd_actn = '02' THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') THEN '6. Other'   
     WHEN pre_accd_actn in ('??','YY','XX', 'ZZ') or single_veh.crashid is null THEN '7. Unknown' END as " ",
coalesce(sum(case when ped_actn = '01' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing WITH Signal",
coalesce(sum(case when ped_actn = '02' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing Against Signal",
coalesce(sum(case when ped_actn = '03' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing No Signal Marked Crosswalk",
coalesce(sum(case when ped_actn = '04' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing No Signal or Crosswalk",
coalesce(sum(case when ped_actn not in ('01','02','03','04','??','YY','XX','ZZ') and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Others",
coalesce(sum(case when ped_actn in ('??','YY','XX', 'ZZ') or single_ped.crashid is null or (num_of_inj>1 and single_ped.crashid is not null) THEN num_of_inj END),0) as "UnKnown"
FROM sam_crashes_950
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_ped
    on sam_crashes_950.crashid = single_ped.crashid
LEFT JOIN (SELECT sv.crashid, sv2.pre_accd_actn
	   FROM (SELECT distinct crashid--, pre_accd_actn
				 FROM archive."2019_11_13_nysdot_vehicle"
				 WHERE veh_typ not in ('5','6')		
				 GROUP by crashid--, pre_accd_actn
				 HAVING count(crashid) = 1)sv
		 LEFT JOIN (SELECT distinct crashid, pre_accd_actn
			   FROM archive."2019_11_13_nysdot_vehicle"
			   WHERE veh_typ not in ('5','6')
			   --WHERE pre_accd_actn not in ('??','YY','XX')
			   ) sv2
		    on sv.crashid = sv2.crashid) single_veh
    on sam_crashes_950.crashid = single_veh.crashid
WHERE accd_type_int = 1
GROUP by CASE WHEN pre_accd_actn = '03' THEN '1. Left Turn'
     WHEN pre_accd_actn = '02' THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') THEN '6. Other'     
     WHEN pre_accd_actn in ('??','YY','XX', 'ZZ') or single_veh.crashid is null THEN '7. Unknown' END
--limit  7
)


SELECT * FROM (
SELECT data.*, "Crossing WITH Signal" + "Crossing Against Signal" + "Crossing No Signal Marked Crosswalk" + "Crossing No Signal or Crosswalk" +  "Others" + "UnKnown" Total
FROM data

union 

SELECT tot.*, "Crossing WITH Signal" + "Crossing Against Signal" + "Crossing No Signal Marked Crosswalk" + "Crossing No Signal or Crosswalk" +  "Others" + "UnKnown" Total
FROM (SELECT 'Total' as " ", 
      sum(data."Crossing WITH Signal") "Crossing WITH Signal",
      sum(data."Crossing Against Signal") "Crossing Against Signal",
      sum(data."Crossing No Signal Marked Crosswalk") "Crossing No Signal Marked Crosswalk",
      sum(data."Crossing No Signal or Crosswalk") "Crossing No Signal or Crosswalk",
      sum(data."Others") "Others",
      sum(data."UnKnown") "UnKnown"
      FROM data
	) tot

) ped_veh_actn
order by " "




SELECT * FROM sam_crashes_950
LEFT JOIN archive."2019_11_13_nysdot_vehicle" nys_v
on sam_crashes_950.crashid = nys_v.crashid
WHERE pre_accd_actn in ('XX','??','YY')
and accd_type_int = 1 







-- CLOSE TO WORKING


WITH data as(
SELECT 
CASE WHEN pre_accd_actn = '03' and single_veh.crashid is not null THEN '1. LEFT Turn'
     WHEN pre_accd_actn = '02' and single_veh.crashid is not null THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' and single_veh.crashid is not null THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' and single_veh.crashid is not null THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' and single_veh.crashid is not null THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') and single_veh.crashid is not null THEN '6. Other'   
     WHEN pre_accd_actn = 'ZZ' or single_veh.crashid is null THEN '7. Unknown' END as " ",
coalesce(sum(case when ped_actn = 'ZZ' or single_ped.crashid is null THEN num_of_inj END),0) as "UnKnown"
--,sam_crashes_950.crashid
FROM sam_crashes_950
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_ped
    on sam_crashes_950.crashid = single_ped.crashid
LEFT JOIN (SELECT sv.crashid, sv2.pre_accd_actn
	   FROM (SELECT distinct crashid--, pre_accd_actn
				 FROM archive."2019_11_13_nysdot_vehicle"
				 WHERE veh_typ not in ('5','6')		
				 GROUP by crashid--, pre_accd_actn
				 HAVING count(crashid) = 1)sv
		 LEFT JOIN (SELECT distinct crashid, pre_accd_actn
			   FROM archive."2019_11_13_nysdot_vehicle"
			   WHERE pre_accd_actn not in ('??','YY','XX')) sv2
		    on sv.crashid = sv2.crashid) single_veh
    on sam_crashes_950.crashid = single_veh.crashid
WHERE accd_type_int = 1
GROUP by CASE WHEN pre_accd_actn = '03' and single_veh.crashid is not null THEN '1. LEFT Turn'
     WHEN pre_accd_actn = '02' and single_veh.crashid is not null THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' and single_veh.crashid is not null THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' and single_veh.crashid is not null THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' and single_veh.crashid is not null THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') and single_veh.crashid is not null THEN '6. Other'   
     WHEN pre_accd_actn = 'ZZ' or single_veh.crashid is null THEN '7. Unknown' END --, sam_crashes_950.crashid
limit  7
)

SELECT * FROM (
SELECT data.*,"UnKnown" Total
FROM data

union 

SELECT tot.*, "UnKnown" Total
FROM (SELECT 'Total' as " ", 
      sum(data."UnKnown") "UnKnown"
      FROM data
	) tot

) ped_veh_actn
order by " "











SELECT s.case_yr, s.accd_dte, num_of_inj, num_of_veh, collision_, accd_type_int, ped_actn, pre_accd_actn, s.crashid, veh_typ
FROM sam_crashes_950 s
JOIN archive."2019_11_13_nysdot_vehicle" nys_v 
    on s.crashid = nys_v.crashid 
    WHERE s.crashid = '354858232014';



SELECT s.case_yr, s.accd_dte, num_of_inj, num_of_veh, collision_, accd_type_int, ped_actn, pre_accd_actn, s.crashid, veh_typ
FROM sam_crashes_950 s
JOIN archive."2019_11_13_nysdot_vehicle" nys_v 
    on s.crashid = nys_v.crashid 
    WHERE s.crashid = '363982472016'




SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 and crashid = '363982472016'

		 
		 GROUP by crashid
		 HAVING count(crashid) = 1



SELECT distinct crashid, pre_accd_actn
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ not in ('5','6')
		 and crashid = '363982472016'

		 GROUP by crashid, pre_accd_actn
		 HAVING count(crashid) = 1





--SUB QUERY FOR UNKNOWNS

SELECT 
CASE WHEN single_veh.pre_accd_actn = 'ZZ' or single_veh.crashid is null THEN '7. Unknown' END as " ",
coalesce(sum(case when ped_actn = 'ZZ' or single_ped.crashid is null THEN num_of_inj END),0) as "UnKnown",
sam_crashes_950.crashid
FROM sam_crashes_950
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_ped
    on sam_crashes_950.crashid = single_ped.crashid
LEFT JOIN (SELECT sv.crashid, sv2.pre_accd_actn
	   FROM (SELECT distinct crashid--, pre_accd_actn
				 FROM archive."2019_11_13_nysdot_vehicle"
				 WHERE veh_typ not in ('5','6')		
				 GROUP by crashid--, pre_accd_actn
				 HAVING count(crashid) = 1)sv
		 LEFT JOIN (SELECT distinct crashid, pre_accd_actn
			   FROM archive."2019_11_13_nysdot_vehicle"
			   WHERE pre_accd_actn not in ('??','YY','XX')) sv2
		    on sv.crashid = sv2.crashid) single_veh
    on sam_crashes_950.crashid = single_veh.crashid
WHERE accd_type_int = 1
GROUP by CASE WHEN single_veh.pre_accd_actn = 'ZZ' or single_veh.crashid is null THEN '7. Unknown' END, sam_crashes_950.crashid










SELECT * 
FROM sam_crashes_950 s
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_ped
    on s.crashid = single_ped.crashid
LEFT JOIN (SELECT distinct crashid--, pre_accd_actn
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ not in ('5','6')		
		 GROUP by crashid--, pre_accd_actn
		 HAVING count(crashid) = 1) single_veh
    on s.crashid = single_veh.crashid
LEFT JOIN (SELECT distinct crashid, pre_accd_actn
	   FROM archive."2019_11_13_nysdot_vehicle"
	   WHERE pre_accd_actn not in ('??','YY','XX')) single_veh2
    on s.crashid = single_veh2.crashid
WHERE s.crashid = '363982472016'






1;"349697892013"
1;"353028722014"
2;"358918242015"
1;"359751692015"
0;"360489222015"
3;"363982472016"
1;"365496092016"






SELECT * 
FROM sam_crashes_950 s
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_ped
    on s.crashid = single_ped.crashid
LEFT JOIN (SELECT sv.crashid, sv2.pre_accd_actn
	   FROM (SELECT distinct crashid--, pre_accd_actn
				 FROM archive."2019_11_13_nysdot_vehicle"
				 WHERE veh_typ not in ('5','6')		
				 GROUP by crashid--, pre_accd_actn
				 HAVING count(crashid) = 1)sv
		 LEFT JOIN (SELECT distinct crashid, pre_accd_actn
			   FROM archive."2019_11_13_nysdot_vehicle"
			   WHERE pre_accd_actn not in ('??','YY','XX')) sv2
		    on sv.crashid = sv2.crashid) single_vehicle
    on s.crashid = single_vehicle.crashid
WHERE s.crashid = '363982472016'







SELECT sum(num_of_inj) FROM (

SELECT s.case_yr, s.accd_dte, num_of_inj, num_of_veh, collision_, accd_type_int, ped_actn, pre_accd_actn, s.crashid, single_ped.crashid
FROM sam_crashes_950 s
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_ped
    on s.crashid = single_ped.crashid
LEFT JOIN (SELECT distinct crashid, pre_accd_actn
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ not in ('5','6')
		 GROUP by crashid, pre_accd_actn
		 HAVING count(crashid) = 1) single_veh
    on s.crashid = single_veh.crashid
WHERE --s.crashid = '360235922015'
--and num_of_inj != 1
pre_accd_actn = '01'
and accd_type_int = 1
and (ped_actn = 'ZZ' or  single_ped.crashid is null)
)x


SELECT s.case_yr, s.accd_dte, num_of_inj, num_of_veh, collision_, accd_type_int, ped_actn, pre_accd_actn, s.crashid, single_ped.crashid
FROM sam_crashes_950 s
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_ped
    on s.crashid = single_ped.crashid
LEFT JOIN (SELECT distinct crashid--, pre_accd_actn
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ not in ('5','6')
		 GROUP by crashid, pre_accd_actn
		 HAVING count(crashid) = 1) single_veh
    on s.crashid = single_veh.crashid
WHERE s.crashid = '363982472016'


SELECT *, pre_accd_actn, single_ped.crashid, single_veh.crashid FROM sam_crashes_950
JOIN archive."2019_11_13_nysdot_vehicle" nys_v 
    on sam_crashes_950.crashid = nys_v.crashid 
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_ped
          on sam_crashes_950.crashid = single_ped.crashid
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ not in ('5','6')
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_veh
    on sam_crashes_950.crashid = single_veh.crashid
WHERE sam_crashes_950.crashid = '353774682014'
and (single_ped.crashid is null
or single_veh.crashid is not null)

single_ped.crashid is null
or single_veh.crashid is not null)

and ped_actn = 'ZZ'
and pre_accd_actn = '01'
and veh_typ = '2'












SELECT sum(num_of_inj) FROM sam_crashes_950
JOIN archive."2019_11_13_nysdot_vehicle" nys_v 
    on sam_crashes_950.crashid = nys_v.crashid
WHERE accd_type_int = 1
and ped_actn in ('ZZ') 
or num_of_inj>1
and pre_accd_actn = '03'



SELECT s.case_yr, s.accd_dte, num_of_inj, num_of_veh, collision_, accd_type_int, ped_actn, pre_accd_actn, s.crashid, veh_typ
FROM sam_crashes_950 s
JOIN archive."2019_11_13_nysdot_vehicle" nys_v 
    on s.crashid = nys_v.crashid
    WHERE accd_type_int = 1
    and ped_actn = 'ZZ'
    --or num_of_inj>1
    and veh_typ = '6'

--Case for multiple pedestrians and num_of_inj>1
--SELECT sum(num_of_inj)
SELECT s.case_yr, s.accd_dte, num_of_inj, num_of_veh, collision_, accd_type_int, ped_actn, pre_accd_actn, s.crashid, veh_typ
FROM sam_crashes_950 s
JOIN (SELECT multiple_ped.crashid, pre_accd_actn, veh_typ
	   FROM (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1
		 ) single_ped 
	         JOIN archive."2019_11_13_nysdot_vehicle" nys_v
		 on multiple_ped.crashid = nys_v.crashid
		 ) mp_crashes
    on s.crashid = mp_crashes.crashid
    WHERE accd_type_int = 1
    and veh_typ = '6'

    
    and ped_actn = 'ZZ'
    or num_of_inj>1
    




    SELECT multiple_ped.crashid, pre_accd_actn, veh_typ
	   FROM (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) > 1
		 ) multiple_ped 
	         JOIN archive."2019_11_13_nysdot_vehicle" nys_v
		 on multiple_ped.crashid = nys_v.crashid
































--Ped Injuries By Veh Action And Pre Action---------------------------------------------------

WITH data as(
SELECT 
CASE WHEN pre_accd_actn = '03' THEN '1. Left Turn'
     WHEN pre_accd_actn = '02' THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') THEN '6. Other'   
     WHEN pre_accd_actn in ('??','YY','XX', 'ZZ') or single_veh.crashid is null THEN '7. Unknown' END as " ",
coalesce(sum(case when ped_actn = '01' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing WITH Signal",
coalesce(sum(case when ped_actn = '02' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing Against Signal",
coalesce(sum(case when ped_actn = '03' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing No Signal Marked Crosswalk",
coalesce(sum(case when ped_actn = '04' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing No Signal or Crosswalk",
coalesce(sum(case when ped_actn not in ('01','02','03','04','??','YY','XX','ZZ') and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Others",
coalesce(sum(case when ped_actn in ('??','YY','XX', 'ZZ') or single_ped.crashid is null or (num_of_inj>1 and single_ped.crashid is not null) THEN num_of_inj END),0) as "UnKnown"
FROM sam_crashes_950
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_ped
    on sam_crashes_950.crashid = single_ped.crashid
LEFT JOIN (SELECT sv.crashid, sv2.pre_accd_actn
	   FROM (SELECT distinct crashid--, pre_accd_actn
				 FROM archive."2019_11_13_nysdot_vehicle"
				 WHERE veh_typ not in ('5','6')		
				 GROUP by crashid--, pre_accd_actn
				 HAVING count(crashid) = 1)sv
		 LEFT JOIN (SELECT distinct crashid, pre_accd_actn
			   FROM archive."2019_11_13_nysdot_vehicle"
			   WHERE veh_typ not in ('5','6')
			   --WHERE pre_accd_actn not in ('??','YY','XX')
			   ) sv2
		    on sv.crashid = sv2.crashid) single_veh
    on sam_crashes_950.crashid = single_veh.crashid
WHERE accd_type_int = 1
GROUP by CASE WHEN pre_accd_actn = '03' THEN '1. Left Turn'
     WHEN pre_accd_actn = '02' THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') THEN '6. Other'     
     WHEN pre_accd_actn in ('??','YY','XX', 'ZZ') or single_veh.crashid is null THEN '7. Unknown' END
--limit  7
)


SELECT * FROM (
SELECT data.*, "Crossing WITH Signal" + "Crossing Against Signal" + "Crossing No Signal Marked Crosswalk" + "Crossing No Signal or Crosswalk" +  "Others" + "UnKnown" Total
FROM data

union 

SELECT tot.*, "Crossing WITH Signal" + "Crossing Against Signal" + "Crossing No Signal Marked Crosswalk" + "Crossing No Signal or Crosswalk" +  "Others" + "UnKnown" Total
FROM (SELECT 'Total' as " ", 
      sum(data."Crossing WITH Signal") "Crossing WITH Signal",
      sum(data."Crossing Against Signal") "Crossing Against Signal",
      sum(data."Crossing No Signal Marked Crosswalk") "Crossing No Signal Marked Crosswalk",
      sum(data."Crossing No Signal or Crosswalk") "Crossing No Signal or Crosswalk",
      sum(data."Others") "Others",
      sum(data."UnKnown") "UnKnown"
      FROM data
	) tot

) ped_veh_actn
order by " "



select * sam_crashes_950

select * 
from sam_crashes_950
join archive."2019_11_13_nysdot_vehicle" nys_v
on sam_crashes_950.crashid = nys_v.crashid
	where sam_crashes_950.crashid = '348796022013'


with data as(
select sam_crashes_950.crashid, single_ped.crashid ped, single_veh.crashid veh, num_of_inj, pre_accd_actn, veh_typ
from sam_crashes_950
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_ped
    on sam_crashes_950.crashid = single_ped.crashid
LEFT JOIN (SELECT sv.crashid, sv2.pre_accd_actn, sv2.veh_typ
	   FROM (SELECT distinct crashid--, pre_accd_actn
				 FROM archive."2019_11_13_nysdot_vehicle"
				 WHERE veh_typ not in ('5','6')		
				 GROUP by crashid--, pre_accd_actn
				 HAVING count(crashid) = 1)sv
		 LEFT JOIN (SELECT distinct crashid, pre_accd_actn, veh_typ
			   FROM archive."2019_11_13_nysdot_vehicle"
			   WHERE veh_typ not in ('5','6')	
			   --WHERE pre_accd_actn not in ('??','YY','XX')
			   ) sv2
		    on sv.crashid = sv2.crashid) single_veh
    on sam_crashes_950.crashid = single_veh.crashid
where accd_type_int = 1
--and pre_accd_actn = 'YY'
) 

select data.crashid, data.ped, data.veh, data.num_of_inj, data.pre_accd_actn, veh_typ
from data
where data.crashid in 	(select data.crashid
			from data
			where data.pre_accd_actn = 'YY')




--Ped Injuries By Veh Action And Pre Action---------------------------------------------------

WITH data as(
SELECT 
CASE WHEN pre_accd_actn = '03' THEN '1. Left Turn'
     WHEN pre_accd_actn = '02' THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') THEN '6. Other'   
     WHEN pre_accd_actn in ('??','YY','XX', 'ZZ') or single_veh.crashid is null THEN '7. Unknown' END as " ",
coalesce(sum(case when ped_actn = '01' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing WITH Signal",
coalesce(sum(case when ped_actn = '02' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing Against Signal",
coalesce(sum(case when ped_actn = '03' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing No Signal Marked Crosswalk",
coalesce(sum(case when ped_actn = '04' and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Crossing No Signal or Crosswalk",
coalesce(sum(case when ped_actn not in ('01','02','03','04','??','YY','XX','ZZ') and num_of_inj = 1 and single_ped.crashid is not null THEN num_of_inj END),0) as "Others",
coalesce(sum(case when ped_actn = 'ZZ' or single_ped.crashid is null or (num_of_inj>1 and single_ped.crashid is not null) THEN num_of_inj END),0) as "UnKnown", sam_crashes_950.crashid, pre_accd_actn
FROM sam_crashes_950
LEFT JOIN (SELECT distinct crashid
		 FROM archive."2019_11_13_nysdot_vehicle"
		 WHERE veh_typ = '6'
		 GROUP by crashid
		 HAVING count(crashid) = 1) single_ped
    on sam_crashes_950.crashid = single_ped.crashid
LEFT JOIN (SELECT sv.crashid, sv2.pre_accd_actn
	   FROM (SELECT distinct crashid--, pre_accd_actn
				 FROM archive."2019_11_13_nysdot_vehicle"
				 WHERE veh_typ not in ('5','6')		
				 GROUP by crashid--, pre_accd_actn
				 HAVING count(crashid) = 1)sv
		 LEFT JOIN (SELECT distinct crashid, pre_accd_actn
			   FROM archive."2019_11_13_nysdot_vehicle"
			   --WHERE pre_accd_actn not in ('??','YY','XX')
			   ) sv2
		    on sv.crashid = sv2.crashid) single_veh
    on sam_crashes_950.crashid = single_veh.crashid
WHERE accd_type_int = 1
GROUP by CASE WHEN pre_accd_actn = '03' THEN '1. Left Turn'
     WHEN pre_accd_actn = '02' THEN '2. Right Turn'
     WHEN pre_accd_actn = '01' THEN '3. Going Straight'
     WHEN pre_accd_actn = '04' THEN '4. Making U Turn'
     WHEN pre_accd_actn = '15' THEN '5. Backing'
     WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') THEN '6. Other'   
     WHEN pre_accd_actn in ('??','YY','XX', 'ZZ') or single_veh.crashid is null THEN '7. Unknown' END, sam_crashes_950.crashid, pre_accd_actn
--limit  7
)


SELECT * FROM (
SELECT data.*, "Crossing WITH Signal" + "Crossing Against Signal" + "Crossing No Signal Marked Crosswalk" + "Crossing No Signal or Crosswalk" +  "Others" + "UnKnown" Total
FROM data

union 

SELECT tot.*, "Crossing WITH Signal" + "Crossing Against Signal" + "Crossing No Signal Marked Crosswalk" + "Crossing No Signal or Crosswalk" +  "Others" + "UnKnown" Total
FROM (SELECT 'Total' as " ", 
      sum(data."Crossing WITH Signal") "Crossing WITH Signal",
      sum(data."Crossing Against Signal") "Crossing Against Signal",
      sum(data."Crossing No Signal Marked Crosswalk") "Crossing No Signal Marked Crosswalk",
      sum(data."Crossing No Signal or Crosswalk") "Crossing No Signal or Crosswalk",
      sum(data."Others") "Others",
      sum(data."UnKnown") "UnKnown"
      FROM data
	) tot

) ped_veh_actn
order by " "

		 