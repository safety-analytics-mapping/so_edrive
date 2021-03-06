/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) 
      [OFF_STREET]
  FROM [FORMS].[dbo].[WC_ACCIDENT_F]
  where  [OFF_STREET] is not null


with data as(
SELECT distinct core.OFF_STREET
,core.SRC_CROSS_STREET
,core.SRC_ON_STREET
,core.SRC_DIST_FROM_X_STREET_MILES
,core.SRC_DIRECTION_FROM_X_STREET
,core.ACCIDENT_DT
,core.INJURED_CNT
,core.INTEGRATION_ID
,core.VEHICLE_INVOLVED_CNT
,core.ACCIDENT_TYPE
,core.TRAFFIC_CONTROL
,core.ACCIDENT_DIAGRAM
,core.ROADWAY_SURFACE_COND
,core.ROADWAY_CHARACTER
,core.LIGHT_CONDITIONS
,core.CONTRIBUTING_FACTOR1
,veh.[ST_OF_REG]
,veh.[VEH_OCCUPANTS]
,veh.[DRIVER_DOB]
,veh.[DRIVER_SEX]
,veh.[VIOLATION]
,veh.[DIRECTION_OF_TRAVEL]
,veh.[PROPERTY_DAMAGED_DESC]
,veh.[CONTRIBUTING_FACTOR]
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
JOIN FORMS.dbo.WC_ACCIDENT_VEHICLE_F veh
on core.integration_id = veh.accident_id
WHERE OFF_STREET in ('907AX5M21121', '907AX5M21122', '907AX5M21123', '907AX5M21124')
and YEAR(core.ACCIDENT_DT) between 2017 and 2019 
--order by core.ACCIDENT_DT
)

SELECT DISTINCT INTEGRATION_ID
FROM data


WC_ACCIDENT_VICTIM_F







-- Vehicle Information
SELECT distinct
core.integration_id
,core.VEHICLE_INVOLVED_CNT
,veh.[ST_OF_REG]
,veh.VEHICLE_TYPE_CODE
,veh.[VEH_OCCUPANTS]
,veh.[DRIVER_DOB]
,veh.[DRIVER_SEX]
,veh.[VIOLATION]
,veh.[DIRECTION_OF_TRAVEL]
,veh.[PROPERTY_DAMAGED_DESC]
,veh.[CONTRIBUTING_FACTOR]
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
JOIN FORMS.dbo.WC_ACCIDENT_VEHICLE_F veh
on core.integration_id = veh.accident_id
WHERE OFF_STREET in ('907AX5M21121', '907AX5M21122', '907AX5M21123', '907AX5M21124')




   (907AX5M22121, 907AX5M22122, 907AX5M22123, 907AX5M22124)


select distinct PROPERTY_DAMAGED_DESC from WC_ACCIDENT_VEHICLE_F

('907AX5M21121', '907AX5M21122', '907AX5M21123', '907AX5M21124', '907AX5M22121', '907AX5M22122', '907AX5M22123', '907AX5M22124')

SELECT distinct core.OFF_STREET
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
WHERE OFF_STREET = '907AX5M21121'



Select 
core.ACCIDENT_DT
,core.CROSS_STREET1
,core.CROSS_STREET2
,core.INJURED_CNT
,core.INTEGRATION_ID
,core.VEHICLE_INVOLVED_CNT
,core.ACCIDENT_TYPE
,core.TRAFFIC_CONTROL
,core.ACCIDENT_DIAGRAM
,core.ROADWAY_SURFACE_COND
,core.ROADWAY_CHARACTER
,core.LIGHT_CONDITIONS
,core.CONTRIBUTING_FACTOR1
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
WHERE OFF_STREET = '907AX5M21121'
and YEAR(core.ACCIDENT_DT) between 2017 and 2019 
order by ACCIDENT_DT






 select dealer_id, sales, emp_name,row_number() over (partition by dealer_id order by sales) as `row`,avg(sales) over (partition by dealer_id) as avgsales from q1_sales;

 
Select 
row_number() over (partition by core.INTEGRATION_ID order by core.ACCIDENT_DT) as row
,core.ACCIDENT_DT
,core.CROSS_STREET1
,core.CROSS_STREET2
,core.INJURED_CNT
,core.INTEGRATION_ID
,core.VEHICLE_INVOLVED_CNT
,core.ACCIDENT_TYPE
,core.TRAFFIC_CONTROL
,core.ACCIDENT_DIAGRAM
,core.ROADWAY_SURFACE_COND
,core.ROADWAY_CHARACTER
,core.LIGHT_CONDITIONS
,core.CONTRIBUTING_FACTOR1
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
WHERE OFF_STREET = '907AX5M21121'
and YEAR(core.ACCIDENT_DT) between 2017 and 2019 
order by ACCIDENT_DT








-----------Working Code----------------------------------------------------------------------------------------------------------------

WITH data AS(
--Retrieving all vehicle level data (Vehicle Type, State of registration, Number of Occupants, Drivers Age, Sex, 
--Direction of Travel, Public Property Damage, Pre-Accident Action and Apparent Factors. 
Select core.OFF_STREET
	  ,core.integration_id
	  ,core.ACCIDENT_DT 
	  ,row_number() OVER (PARTITION BY core.INTEGRATION_ID ORDER BY core.ACCIDENT_DT) AS VEH -- Assigning a row number for vehicle per crash
	  ,veh.[ST_OF_REG]
	  ,veh.VEHICLE_TYPE_CODE
	  ,veh.[VEH_OCCUPANTS]
   	  ,veh.VICTIM_AGE DRIVER_AGE
	  ,veh.[DRIVER_SEX]
	  ,veh.[VIOLATION]
	  ,veh.[DIRECTION_OF_TRAVEL]
	  ,veh.[PROPERTY_DAMAGED_DESC]
	  ,veh.[CONTRIBUTING_FACTOR]
	  ,veh.[CONTRIBUTING_FACTOR_2]
	  ,veh.[PRE_ACDNT_ACTION]
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
JOIN (SELECT DISTINCT veh.*,vic.VICTIM_AGE 
	  FROM FORMS.dbo.WC_ACCIDENT_VEHICLE_F veh 
	  --Joining to Victim Table to retrieve victim ages
	  LEFT JOIN (SELECT ACCIDENT_ID, VEHICLE_NUM, VICTIM_AGE   
				 FROM WC_ACCIDENT_VICTIM_F vic
				 WHERE PERSON_ROLE_CODE = 'Driver' -- Only interested in injured driver's age
				) vic
	  ON veh.ACCIDENT_ID = vic.ACCIDENT_ID and veh.VEHICLE_NUM = vic.VEHICLE_NUM) veh
ON core.integration_id = veh.accident_id
WHERE core.OFF_STREET in( '907AX5M21121', '907AX5M21122', '907AX5M21123', '907AX5M21124', '907AX5M22121', '907AX5M22122', '907AX5M22123', '907AX5M22124') --Reference marker study area
and YEAR(core.ACCIDENT_DT) between 2017 and 2019 
)

SELECT core_data.*
	  ,veh_data.INTEGRATION_ID
	  ,veh_data.VEH
	  ,veh_data.[ST_OF_REG]
	  ,veh_data.[VEHICLE_TYPE_CODE]
	  ,veh_data.[VEH_OCCUPANTS]
	  ,veh_data.DRIVER_AGE
	  ,veh_data.[DRIVER_SEX]
	  ,veh_data.[VIOLATION]
	  ,veh_data.[DIRECTION_OF_TRAVEL]
	  ,veh_data.[PROPERTY_DAMAGED_DESC]
	  ,veh_data.[CONTRIBUTING_FACTOR]
	  ,veh_data.[CONTRIBUTING_FACTOR_2]
	  ,veh_data.[PRE_ACDNT_ACTION]
FROM (--Retrieving all crash level data (Reference Marker, Street, Accident Date, Time, Injured count, Accident Class, Number of Vehicles, Manner of Collision, Traffic Control   
	  --Road Surface Condition, Road Character, Light Condition. 
	  SELECT core.OFF_STREET
			,core.integration_id
			,row_number() OVER (PARTITION BY core.OFF_STREET ORDER BY core.integration_id) AS case_num -- Giving a row number to each distinct integration id 
			,core.ACCIDENT_DT
			,left(stuff(STUFF(right('000000'+cast(core.ACCIDENT_TIME_WID AS VARCHAR),6),5,0,':'),3,0,':'), 5) ACCIDENT_TIME -- Converting Accident Time field to proper time format
			,core.SRC_CROSS_STREET
			,core.SRC_ON_STREET
			,core.SRC_DISTANCE_FROM_CROSS_STREET 
			,core.SRC_NEAREST_LANDMARK
			,core.SRC_DIRECTION_FROM_X_STREET
			,CASE WHEN INJURED_CNT = 0 THEN 'Propetry Damage' ELSE 'Injury' END ACCIDENT_CLASS
			,core.INJURED_CNT
			,core.VEHICLE_INVOLVED_CNT
			,core.FIRST_EVENT_TYPE
			,core.TRAFFIC_CONTROL
			,core.ACCIDENT_DIAGRAM
			,core.ROADWAY_SURFACE_COND
			,core.ROADWAY_CHARACTER
			,core.LIGHT_CONDITIONS
			,core.WEATHER
			,core.ACCIDENT_DESC
	  FROM [FORMS].[dbo].[WC_ACCIDENT_F] core 
	  WHERE core.OFF_STREET in( '907AX5M21121', '907AX5M21122', '907AX5M21123', '907AX5M21124', '907AX5M22121', '907AX5M22122', '907AX5M22123', '907AX5M22124') --Reference marker study area
	  and YEAR(core.ACCIDENT_DT) between 2017 and 2019
	  ) core_data
JOIN (SELECT * FROM data) veh_data
ON core_data.INTEGRATION_ID = veh_data.integration_id
ORDER BY core_data.OFF_STREET, case_num







SELECT FIRST_EVENT_TYPE
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core 
WHERE core.OFF_STREET in( '907AX5M21121', '907AX5M21122', '907AX5M21123', '907AX5M21124', '907AX5M22121', '907AX5M22122', '907AX5M22123', '907AX5M22124') --Reference marker study area
	  and YEAR(core.ACCIDENT_DT) between 2017 and 2019







select left(stuff(STUFF(right('000000'+cast(core.ACCIDENT_TIME_WID as varchar),6),5,0,':'),3,0,':'), 5) ACCIDENT_TIME
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core




select count(SRC_DIST_FROM_X_STREET_MILES) as float)
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
where SRC_DIST_FROM_X_STREET_MILES is not null


select max(SRC_DIST_FROM_X_STREET_MILES)
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core



select count(coalesce(SRC_DIST_FROM_X_STREET_MILES,'0'))
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
where SRC_DIST_FROM_X_STREET_MILES  is null


select AVG(cast(SRC_DIST_FROM_X_STREET_MILES as float))
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
where SRC_DIST_FROM_X_STREET_MILES  is not null


Select top 1 SRC_DIST_FROM_X_STREET_MILES
from [FORMS].[dbo].[WC_ACCIDENT_F] core
where SRC_DIST_FROM_X_STREET_MILES  is not null
group by SRC_DIST_FROM_X_STREET_MILES
order by count(*) desc







select min(SRC_DISTANCE_FROM_CROSS_STREET)
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core



select count(coalesce(SRC_DISTANCE_FROM_CROSS_STREET,0))
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
where SRC_DISTANCE_FROM_CROSS_STREET  is null


select AVG(cast(SRC_DISTANCE_FROM_CROSS_STREET as int))
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
where SRC_DISTANCE_FROM_CROSS_STREET  is not null
and SRC_DISTANCE_FROM_CROSS_STREET  != 99999

Select top 1 SRC_DISTANCE_FROM_CROSS_STREET
from [FORMS].[dbo].[WC_ACCIDENT_F] core
where SRC_DISTANCE_FROM_CROSS_STREET  is not null
group by SRC_DISTANCE_FROM_CROSS_STREET
order by count(*) desc






SELECT FIRST_EVENT_TYPE, vic.PED_NONPED
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core 
JOIN  [FORMS].[dbo].[WC_ACCIDENT_VICTIM_F] vic
ON core.integration_id = vic.ACCIDENT_ID
WHERE YEAR(core.ACCIDENT_DT) between 2017 and 2019





SELECT CASE WHEN vic.PED_NONPED = 'Pedestrian' THEN '1. Pedestrian'
			WHEN vic.PED_NONPED = 'Bicyclist' THEN '2. Bicyclist'
			WHEN vic.PED_NONPED = 'Occupant' THEN '3. Motor Vehicle' END AS Mode
,sum(CASE WHEN FIRST_EVENT_TYPE = 'Pedestrian' THEN 1 END) FIRST_PED
,sum(CASE WHEN FIRST_EVENT_TYPE = 'Bicyclist' THEN 1 END) FIRST_BI
,sum(CASE WHEN FIRST_EVENT_TYPE not in ('Pedestrian','Bicyclist', '0') or FIRST_EVENT_TYPE is not null THEN 1 END) FIRST_OTHER
,coalesce(sum(CASE WHEN FIRST_EVENT_TYPE is null or FIRST_EVENT_TYPE = '0' THEN 1 END),0) FIRST_UNKNOWN
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core 
JOIN  [FORMS].[dbo].[WC_ACCIDENT_VICTIM_F] vic
ON core.integration_id = vic.ACCIDENT_ID
WHERE YEAR(core.ACCIDENT_DT) between 2017 and 2019
GROUP BY CASE WHEN vic.PED_NONPED = 'Pedestrian' THEN '1. Pedestrian'
			  WHEN vic.PED_NONPED = 'Bicyclist' THEN '2. Bicyclist'
			  WHEN vic.PED_NONPED = 'Occupant' THEN '3. Motor Vehicle' END





SELECT vic.PED_NONPED, FIRST_EVENT_TYPE 
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core 
JOIN  [FORMS].[dbo].[WC_ACCIDENT_VICTIM_F] vic
ON core.integration_id = vic.ACCIDENT_ID
WHERE YEAR(core.ACCIDENT_DT) between 2017 and 2019
and (FIRST_EVENT_TYPE not in ('Pedestrian','Bicyclist', '0') or FIRST_EVENT_TYPE is not null)
and vic.PED_NONPED = 'Pedestrian'





select distinct PED_NONPED
FROM [FORMS].[dbo].[WC_ACCIDENT_VICTIM_F] vic


SELECT count(SRC_DIST_FROM_X_STREET_MILES) 
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core 
WHERE SRC_DISTANCE_FROM_CROSS_STREET is null



SELECT count(SRC_DIST_FROM_X_STREET_MILES) 
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core 
WHERE SRC_DISTANCE_FROM_CROSS_STREET is null


SELECT TOP 2 CASE WHEN SRC_DIST_FROM_X_STREET_MILES is not null THEN '1. SRC_DIST_FROM_X_STREET_MILES'
				  WHEN SRC_DISTANCE_FROM_CROSS_STREET is not null THEN '2. SRC_DISTANCE_FROM_CROSS_STREET'
				  ELSE '3. ' END AS " " 

,coalesce(sum(CASE WHEN SRC_DIST_FROM_X_STREET_MILES is null THEN 1 END),0) SRC_DIST_FROM_X_STREET_MILES_NULL
,coalesce(sum(CASE WHEN SRC_DISTANCE_FROM_CROSS_STREET is null THEN 1 END),0) SRC_DISTANCE_FROM_CROSS_STREET_NULL
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core 
GROUP BY CASE WHEN SRC_DIST_FROM_X_STREET_MILES is not null THEN '1. SRC_DIST_FROM_X_STREET_MILES'
			  WHEN SRC_DISTANCE_FROM_CROSS_STREET is not null THEN '2. SRC_DISTANCE_FROM_CROSS_STREET' 
			  ELSE '3. ' END 


select count(SRC_DIST_FROM_X_STREET_MILES)
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core 
where SRC_DIST_FROM_X_STREET_MILES is not null

select count(SRC_DISTANCE_FROM_CROSS_STREET)
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core 
where SRC_DISTANCE_FROM_CROSS_STREET is not null
