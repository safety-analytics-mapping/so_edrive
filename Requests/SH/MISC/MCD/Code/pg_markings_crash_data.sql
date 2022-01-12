
--Original View Query
SELECT  -- Selects Month, Year, Nodeid, And Injury Event occurene count by nodeid)
	nodeid, M,Y,  
	sum(Pedestrian) Pedestrian, sum(Bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
	sum(Ped_School_Aged) School_Aged, sum(Ped_Seniors)  Seniors, sum(Ped_Adult) Adult
FROM

	(SELECT		-- Selects Month, Year, Nodeid, And Injury Event occurene by Integration ID (Test Functionality with Node '21185')
			M, Y, nodeid, 
			max(Pedestrian) Pedestrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) Veh_Occupant, 
			max(School_Aged) Ped_School_Aged, max(Seniors) Ped_Seniors, max(Adult) Ped_Adult
	FROM
			(SELECT	--Selects Injury Month and Year, Nodeid, Injury Mode, Categorizes by Age (School_Aged/Adult/Senior) and Integration ID				
				extract(month from c.ACCIDENT_DT::date) M , extract(year from c.ACCIDENT_DT::date) Y, 
				c.NODEID, 
				(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
				(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
				(case when PED_NONPED  In ('Occupant') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
				(case when i.victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
				then 1 else 0 end) School_Aged,
				(case when i.victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') 
				then 1 else 0 end) Seniors,
				(case when i.victim_age between 18 and 64 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
				then 1 else 0 end) Adult,
				c.INTEGRATION_ID --i.VICTIM_AGE
				
			FROM public.wc_accident_f_test as c                 --Crash Data Table
			join public.wc_accident_victim_f_test  as i         --Victim Data Table
			on c.INTEGRATION_ID::int=i.ACCIDENT_ID::int         --Joins on Integration ID
			where c.nodeid is not null                          --Disregards Injury Crashes that are not at node
			  and i.INJ_KILLED = 'Injured'                      --Specifies Injured Events not Fatality Events
			  and coalesce(c.VOID_STATUS_CD , 'N') ='N'         --Considers void Statuses that are null
			  and coalesce(c.NONMV::int , 0) = 0                --Considers void Statuses that are null
			  and c.nodeid = '21185') z
			  --and ACCIDENT_ID in (727118109,734418109)) z 

		group by integration_id, M, Y, nodeid) x

group by nodeid, M, Y


--CHECKS TO SEE IF OFFICIAL CRASH DATA IS QUERY-ABLE
Select *
from  public.wc_accident_victim_f  limit 10

--CHECKS TO SEE IF TEST CRASH DATA IS QUERY-ABLE
Select *
FROM public.wc_accident_victim_f_test limit 10


--DROPS TEST TABLE
drop table public.wc_accident_victim_f_test


Select *
FROM public.node 
where nodeidfrom::int = 63


SELECT ST_X(geom), ST_Y(geom)
FROM public.node --limit 10
where nodeid = 63


SELECT v.*, ST_X(n.geom), ST_Y(n.geom)
from v_markings_crash v
join public.node n
on v.nodeid = n.nodeid
limit 10


select * 
from v_mcd
where nodeid = '21185'


select *
from public.wc_accident_victim_f_test
limit 1

select * 
from public.wc_accident_f_test c
join  public.wc_accident_victim_f_test i
on c.INTEGRATION_ID::int=i.ACCIDENT_ID::int
where nodeid = '21185'


SELECT 
	extract(month from c.ACCIDENT_DT::date) M , extract(year from c.ACCIDENT_DT::date) Y, 
	c.NODEID, 
	(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
	(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
	(case when PED_NONPED  In ('Occupant') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
	c.INTEGRATION_ID, i.VICTIM_AGE, PERSON_ROLE_CODE
FROM public.wc_accident_f_test as c
join public.wc_accident_victim_f_test  as i
on c.INTEGRATION_ID::int=i.ACCIDENT_ID::int
where c.nodeid is not null 
  and i.INJ_KILLED = 'Injured' 
  and coalesce(c.VOID_STATUS_CD , 'N') ='N'
  and coalesce(c.NONMV::int , 0) = 0 
  and c.nodeid = '21185'





--Revised View Query

--Markings Crash Data View
-- This View  Returns the Frequency of Injury Incidents Based on NodeID and Categorized by Mode

SELECT  -- Selects Frequency of Injury Events Based on Node
	nodeid, M, Y,
	Sum(Pedestrian) Pedestrian, sum(Bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
	sum(Ped_School_Aged) School_Aged, sum(Ped_Seniors)  Seniors
FROM

	(SELECT		-- Selects Month, Year, Nodeid, And Injury Event occurence by Integration ID (Test Functionality with Node '21185')
			M, Y, nodeid, 
			max(Pedestrian) Pedestrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) Veh_Occupant, 
			max(Ped_School_Aged) Ped_School_Aged, max(Ped_Senior) Ped_Seniors
	FROM
			(SELECT	--Selects Injury Month and Year, Nodeid, Injury Mode, Categorizes Pedestrians by Age (School_Aged/Senior) and Integration ID				
				extract(month from c.ACCIDENT_DT::date) M , extract(year from c.ACCIDENT_DT::date) Y, 
				c.NODEID, 
				(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 END) Pedestrian,
				(case when i.victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') then 1 else 0 END) Ped_School_Aged,
				(case when i.victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') then 1 else 0 END) Ped_Senior,
				(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
				(case when PED_NONPED  In ('Occupant') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
				
				c.INTEGRATION_ID, i.VICTIM_AGE
				
			FROM public.wc_accident_f_test as c                 --Crash Data Table
			join public.wc_accident_victim_f_test  as i         --Victim Data Table
			on c.INTEGRATION_ID::int=i.ACCIDENT_ID::int         --Joins on Integration ID
			where c.nodeid is not null                          --Disregards Injury Crashes that are not at node
			  and i.INJ_KILLED = 'Injured'                      --Specifies Injured Events not Fatality Events
			  and coalesce(c.VOID_STATUS_CD , 'N') ='N'         --Considers void Statuses that are null
			  and coalesce(c.NONMV::int , 0) = 0)z                --Considers void Statuses that are null
			  --and ((i.victim_age between 1 and 17) or (i.victim_age between 65 and 100)))z 
			  --and c.nodeid = '21185') z
			  --and ACCIDENT_ID in (727118109,734418109)) z 

	group by integration_id, M, Y, nodeid) x

group by nodeid, M,Y
--having sum(Veh_Occupant)>1


select distinct* 
from public.wc_accident_f_test c
join  public.wc_accident_victim_f_test i
on c.INTEGRATION_ID::int=i.ACCIDENT_ID::int
where nodeid = '36072'
and i.INJ_KILLED = 'Injured'



SELECT now() as Current_Date




--Updated 607
--Markings Crash Data View
-- This View  Returns the Frequency of Injury Incidents Based on NodeID and Categorized by Mode

SELECT  -- Selects Frequency of Injury Events Based on Node
	nodeid, M, Y,
	Sum(Pedestrian) Pedestrian, sum(Bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
	sum(Ped_School_Aged) School_Aged, sum(Ped_Seniors)  Seniors, now() as Current_Date
FROM

	(SELECT		-- Selects Month, Year, Nodeid, And Injury Event occurence by Integration ID (Test Functionality with Node '21185')
			M, Y, nodeid, 
			max(Pedestrian) Pedestrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) Veh_Occupant, 
			max(Ped_School_Aged) Ped_School_Aged, max(Ped_Senior) Ped_Seniors
	FROM
			(SELECT	--Selects Injury Month and Year, Nodeid, Injury Mode, Categorizes Pedestrians by Age (School_Aged/Senior) and Integration ID				
				extract(month from c.ACCIDENT_DT::date) M , extract(year from c.ACCIDENT_DT::date) Y, 
				c.NODEID, 
				(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 END) Pedestrian,
				(case when i.victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') then 1 else 0 END) Ped_School_Aged,
				(case when i.victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') then 1 else 0 END) Ped_Senior,
				(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
				(case when PED_NONPED  In ('Occupant') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
				
				c.INTEGRATION_ID, i.VICTIM_AGE
				
			FROM public.wc_accident_f as c                 --Crash Data Table
			join public.wc_accident_victim_f  as i         --Victim Data Table
			on c.INTEGRATION_ID::int=i.ACCIDENT_ID::int         --Joins on Integration ID
			where c.nodeid is not null                          --Disregards Injury Crashes that are not at node
			  and i.INJ_KILLED = 'Injured' )z                      --Specifies Injured Events not Fatality Events
			
	group by integration_id, M, Y, nodeid) x

group by nodeid, M,Y


select *
from public.v_mcd
