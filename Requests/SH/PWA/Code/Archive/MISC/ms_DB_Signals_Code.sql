--DB Signals Code

--get_signalized_int(db, pg, nodes)
--get all signalized intersections MSQL

SELECT [PSGM_ID],[CONTRTYPE],[NODEID], POINT_X, POINT_Y
FROM [GISGRID].[gisadmin].[SIGNAL_CONTROLLER] 
where NormalizedType != 'Z'


--3.
--alt_get_signalized_int(dbo, pgo, node_dict)
SELECT [PSGM_ID],[ContrType],[NodeID],[Longitude],[Latitude]
FROM [GISGRID].[gisadmin].[SIGNAL_CONTROLLER]   --All nodes in question for signalization
--[LION_CURRENT].[GISADMIN].[SIG_TRpsgm] 
where NormalizedType != 'Z' --Z is a planned signal
--and [Longitude] not in ('','S' ) and  [Latitude] not in ('')
and [Longitude] is not null
and psgm_id in (41084, 41083)

SELECT *
FROM [GISGRID].[gisadmin].[SIGNAL_CONTROLLER]


--5.
--get_all_crashes_nypd(db2)

--selects crashid, nodeid, accident datetime, injured count, killed count and 
--specifies cases where victims are pedestrians or bikers or not, 
--the accident diagram (
--						1 - Rear End
--						2 - Overtaking
--						3 - Left Turn
--						4 - Right Angle
--						5 - Right Turn ->->
--						6 - Right Turn <-->
--						7 - Head On
--						8 - Sideswipe
--						9 - 
-- extra filler columns

SELECT distinct c.[ANUM_PCT]+c.[ANUM_YY]+c.[ANUM_SEQ] as crashid ,
				c.[NODEID], cast(c.[OCCURRENCE_DATETIME] as DATE) as accd_date,
				c.[INJURED_COUNT],c.[KILLED_COUNT],  
				case when vic.ped_nonped = 'P' then 1
				when vic.PED_NONPED = 'B' then 2 else 3 end as inj_mode,
				c.[ACCIDENT_DIAGRAM]  AS [COLLISION_TYP],
				null as ext_of_inj, 0 as pre_action, 0 as direction, 0 as contrib --These are placeholders for function calls later in signals code.
FROM [DataWarehouse].[dbo].[AIS_PD_Core_F] AS c
LEFT OUTER JOIN (
		--selects crashid breakdown, and non preventable accident actions 
		SELECT [ANUM_PCT], [ANUM_YY], [ANUM_SEQ],
				MAX(CASE WHEN PRE_ACDNT_ACTION = '10' THEN 1
						 WHEN PRE_ACDNT_ACTION in ('15', '08', '09', '14', '04') THEN 1 -- removes other non-preventable
						 ELSE 0 END) AS PK
		FROM [DataWarehouse].dbo.AIS_PD_Vehicle_F
		GROUP BY [ANUM_PCT], [ANUM_YY], [ANUM_SEQ]
		)AS v -- parked vehicles
		ON c.[ANUM_PCT] = v.ANUM_PCT AND c.[ANUM_YY] = v.ANUM_YY AND c.[ANUM_SEQ] = v.ANUM_SEQ
LEFT OUTER JOIN DataWarehouse.dbo.AIS_PD_Pedestrian_F AS P	 -- ??	
		ON c.[ANUM_PCT] = P.ANUM_PCT AND c.[ANUM_YY] = P.ANUM_YY AND c.[ANUM_SEQ] = P.ANUM_SEQ
LEFT OUTER JOIN DataWarehouse.dbo.AIS_PD_Victim_F as vic --Victim Table
		ON c.ANUM_PCT = vic.ANUM_PCT and c.ANUM_SEQ = vic.ANUM_SEQ and c.ANUM_YY = vic.ANUM_YY
WHERE C.OCCURRENCE_DATETIME > (select dateadd(week, -3, dateadd(year, -3, getdate())))
AND C.NODEID != 0
and v.PK != 1 



--6.
--get_all_dir_right_angle_crashes_nypd(db2)

/* conservative */
-- north / south
select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
--n.*, o.DIRECTION_OF_TRAVEL
from (
    SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    and [DIRECTION_OF_TRAVEL] in (1, 5)
    and PRE_ACDNT_ACTION != '10'
) as n
join (
    SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    and [DIRECTION_OF_TRAVEL] in (3, 7)
) as o
on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
    and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER

union
-- east / west
select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
--n.*, o.DIRECTION_OF_TRAVEL
from (
    SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    and [DIRECTION_OF_TRAVEL] in (3,7)
) as n
join (
    SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    and [DIRECTION_OF_TRAVEL] in (1, 5)
) as o
on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
    and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER

union
-- northeast / southwest
select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
--n.*, o.DIRECTION_OF_TRAVEL
from (
    SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    and [DIRECTION_OF_TRAVEL] in (2, 6)
) as n
join (
    SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    and [DIRECTION_OF_TRAVEL] in (4, 8)
) as o
on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
    and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER

union
-- northwest / southeast
select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
--n.*, o.DIRECTION_OF_TRAVEL
from (
    SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    and [DIRECTION_OF_TRAVEL] in (4, 8)
) as n
join (
    SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    and [DIRECTION_OF_TRAVEL] in (2, 6)
) as o
on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
    and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER





--5. Test Case for node 33755
SELECT distinct c.[ANUM_PCT]+c.[ANUM_YY]+c.[ANUM_SEQ] as crashid ,
				c.[NODEID], cast(c.[OCCURRENCE_DATETIME] as DATE) as accd_date,
				c.[INJURED_COUNT],c.[KILLED_COUNT],  
				case when vic.ped_nonped = 'P' then 1
				when vic.PED_NONPED = 'B' then 2 else 3 end as inj_mode,
				c.[ACCIDENT_DIAGRAM]  AS [COLLISION_TYP],
				null as ext_of_inj, 0 as pre_action, 0 as direction, 0 as contrib
FROM [DataWarehouse].[dbo].[AIS_PD_Core_F] AS c
LEFT OUTER JOIN (
		--selects crashid breakdown, and non preventable accident actions 
		SELECT [ANUM_PCT], [ANUM_YY], [ANUM_SEQ],
				MAX(CASE WHEN PRE_ACDNT_ACTION = '10' THEN 1
						 WHEN PRE_ACDNT_ACTION in ('15', '08', '09', '14', '04') THEN 1 -- removes other non-preventable
						 ELSE 0 END) AS PK
		FROM [DataWarehouse].dbo.AIS_PD_Vehicle_F
		GROUP BY [ANUM_PCT], [ANUM_YY], [ANUM_SEQ]
		)AS v -- parked vehicles
		ON c.[ANUM_PCT] = v.ANUM_PCT AND c.[ANUM_YY] = v.ANUM_YY AND c.[ANUM_SEQ] = v.ANUM_SEQ
LEFT OUTER JOIN DataWarehouse.dbo.AIS_PD_Pedestrian_F AS P	 -- ??	
		ON c.[ANUM_PCT] = P.ANUM_PCT AND c.[ANUM_YY] = P.ANUM_YY AND c.[ANUM_SEQ] = P.ANUM_SEQ
LEFT OUTER JOIN DataWarehouse.dbo.AIS_PD_Victim_F as vic --Victim Table
		ON c.ANUM_PCT = vic.ANUM_PCT and c.ANUM_SEQ = vic.ANUM_SEQ and c.ANUM_YY = vic.ANUM_YY
WHERE C.OCCURRENCE_DATETIME between '3/24/2016' and '10/20/2016'
--and C.NODEID != 0
and v.PK != 1 
and c.NODEID = 33755



select distinct c.ANUM_PCT+c.ANUM_YY+c.ANUM_SEQ as crashid, c.nodeid, i.VICTIM_NUMBER ,i.PED_NONPED, i.INJURED_COUNT,  cast(c.[OCCURRENCE_DATETIME] as DATE) as accd_date
from DataWarehouse.dbo.AIS_PD_Core_F c
join DataWarehouse.dbo.AIS_PD_Vehicle_F v
      on c.ANUM_PCT=v.ANUM_PCT and c.ANUM_SEQ=v.ANUM_SEQ and c.ANUM_YY=v.ANUM_YY
left outer join DataWarehouse.dbo.AIS_PD_Victim_F i
      on c.ANUM_PCT=i.ANUM_PCT and c.ANUM_SEQ=i.ANUM_SEQ and c.ANUM_YY=i.ANUM_YY
left outer join DataWarehouse.dbo.AIS_PD_Locx_F l
      on c.ANUM_PCT=l.ANUM_PCT and c.ANUM_SEQ=l.ANUM_SEQ and c.ANUM_YY=l.ANUM_YY
left outer join DataWarehouse.dbo.AIS_PD_Geox_F g
      on c.ANUM_PCT=g.ANUM_PCT and c.ANUM_SEQ=g.ANUM_SEQ and c.ANUM_YY=g.ANUM_YY
where c.NODEID = 33755
      and c.OCCURRENCE_DATETIME between '3/24/2016' and '10/20/2016'
     -- and c.ACCIDENT_DIAGRAM in ('4', '0', '5') 
      and i.INJURED_COUNT >0




--No nonpreventable crash filter
select distinct crashid, inj_mode,COLLISION_TYP
from(
SELECT distinct c.[ANUM_PCT]+c.[ANUM_YY]+c.[ANUM_SEQ] as crashid ,
				c.[NODEID],  vic.VICTIM_NUMBER,  cast(c.[OCCURRENCE_DATETIME] as DATE) as accd_date,
				c.[INJURED_COUNT],c.[KILLED_COUNT],  
				case when vic.ped_nonped = 'P' then 1
				when vic.PED_NONPED = 'B' then 2 else 3 end as inj_mode,
				c.[ACCIDENT_DIAGRAM]  AS [COLLISION_TYP],
				null as ext_of_inj, 0 as pre_action, 0 as direction, 0 as contrib
FROM [DataWarehouse].[dbo].[AIS_PD_Core_F] AS c
join DataWarehouse.dbo.AIS_PD_Vehicle_F v
      on c.ANUM_PCT=v.ANUM_PCT and c.ANUM_SEQ=v.ANUM_SEQ and c.ANUM_YY=v.ANUM_YY
LEFT OUTER JOIN DataWarehouse.dbo.AIS_PD_Victim_F as vic --Victim Table
		ON c.ANUM_PCT = vic.ANUM_PCT and c.ANUM_SEQ = vic.ANUM_SEQ and c.ANUM_YY = vic.ANUM_YY
WHERE C.OCCURRENCE_DATETIME  between '3/24/2016' and '10/20/2016'
--and C.NODEID != 0
and c.NODEID = 33755
--and c.[ACCIDENT_DIAGRAM] = 4
--and vic.INJURED_COUNT >0
)v
where COLLISION_TYP = 4
and inj_mode = 3

--No nonpreventable crash filter with injuries>0
SELECT distinct c.[ANUM_PCT]+c.[ANUM_YY]+c.[ANUM_SEQ] as crashid ,
				c.[NODEID],  vic.VICTIM_NUMBER,  cast(c.[OCCURRENCE_DATETIME] as DATE) as accd_date,
				c.[INJURED_COUNT],c.[KILLED_COUNT],  
				case when vic.ped_nonped = 'P' then 1
				when vic.PED_NONPED = 'B' then 2 else 3 end as inj_mode,
				c.[ACCIDENT_DIAGRAM]  AS [COLLISION_TYP],
				null as ext_of_inj, 0 as pre_action, 0 as direction, 0 as contrib
FROM [DataWarehouse].[dbo].[AIS_PD_Core_F] AS c
join DataWarehouse.dbo.AIS_PD_Vehicle_F v
      on c.ANUM_PCT=v.ANUM_PCT and c.ANUM_SEQ=v.ANUM_SEQ and c.ANUM_YY=v.ANUM_YY
LEFT OUTER JOIN DataWarehouse.dbo.AIS_PD_Victim_F as vic --Victim Table
		ON c.ANUM_PCT = vic.ANUM_PCT and c.ANUM_SEQ = vic.ANUM_SEQ and c.ANUM_YY = vic.ANUM_YY
WHERE C.OCCURRENCE_DATETIME  between '3/24/2016' and '10/20/2016'
--and C.NODEID != 0
and c.NODEID = 33755
and vic.INJURED_COUNT >0




--With nonpreventable crash filter
SELECT distinct c.[ANUM_PCT]+c.[ANUM_YY]+c.[ANUM_SEQ] as crashid ,
				c.[NODEID],  cast(c.[OCCURRENCE_DATETIME] as DATE) as accd_date,  vic.VICTIM_NUMBER,
				c.[INJURED_COUNT],c.[KILLED_COUNT],  
				case when vic.ped_nonped = 'P' then 1
				when vic.PED_NONPED = 'B' then 2 else 3 end as inj_mode,
				c.[ACCIDENT_DIAGRAM]  AS [COLLISION_TYP],
				null as ext_of_inj, 0 as pre_action, 0 as direction, 0 as contrib
FROM [DataWarehouse].[dbo].[AIS_PD_Core_F] AS c
LEFT OUTER JOIN (
		--selects crashid breakdown, and non preventable accident actions 
		SELECT [ANUM_PCT], [ANUM_YY], [ANUM_SEQ],
				MAX(CASE WHEN PRE_ACDNT_ACTION = '10' THEN 1
						 WHEN PRE_ACDNT_ACTION in ('15', '08', '09', '14', '04') THEN 1 -- removes other non-preventable
						 ELSE 0 END) AS PK
		FROM [DataWarehouse].dbo.AIS_PD_Vehicle_F
		GROUP BY [ANUM_PCT], [ANUM_YY], [ANUM_SEQ]
		)AS v -- parked vehicles
		ON c.[ANUM_PCT] = v.ANUM_PCT AND c.[ANUM_YY] = v.ANUM_YY AND c.[ANUM_SEQ] = v.ANUM_SEQ
LEFT OUTER JOIN DataWarehouse.dbo.AIS_PD_Victim_F as vic --Victim Table
		ON c.ANUM_PCT = vic.ANUM_PCT and c.ANUM_SEQ = vic.ANUM_SEQ and c.ANUM_YY = vic.ANUM_YY
WHERE C.OCCURRENCE_DATETIME between '3/24/2016' and '10/20/2016'
--and C.NODEID != 0
and c.NODEID = 33755
and v.PK != 1
and c.[ACCIDENT_DIAGRAM] = 4
--and vic.INJURED_COUNT >0

--With nonpreventable crash filter with injuries>0
SELECT distinct c.[ANUM_PCT]+c.[ANUM_YY]+c.[ANUM_SEQ] as crashid ,
				c.[NODEID],  vic.VICTIM_NUMBER,  cast(c.[OCCURRENCE_DATETIME] as DATE) as accd_date,
				c.[INJURED_COUNT],c.[KILLED_COUNT],  
				case when vic.ped_nonped = 'P' then 1
				when vic.PED_NONPED = 'B' then 2 else 3 end as inj_mode,
				c.[ACCIDENT_DIAGRAM]  AS [COLLISION_TYP],
				null as ext_of_inj, 0 as pre_action, 0 as direction, 0 as contrib
FROM [DataWarehouse].[dbo].[AIS_PD_Core_F] AS c
LEFT OUTER JOIN (
		--selects crashid breakdown, and non preventable accident actions 
		SELECT [ANUM_PCT], [ANUM_YY], [ANUM_SEQ],
				MAX(CASE WHEN PRE_ACDNT_ACTION = '10' THEN 1
						 WHEN PRE_ACDNT_ACTION in ('15', '08', '09', '14', '04') THEN 1 -- removes other non-preventable
						 ELSE 0 END) AS PK
		FROM [DataWarehouse].dbo.AIS_PD_Vehicle_F
		GROUP BY [ANUM_PCT], [ANUM_YY], [ANUM_SEQ]
		)AS v -- parked vehicles
		ON c.[ANUM_PCT] = v.ANUM_PCT AND c.[ANUM_YY] = v.ANUM_YY AND c.[ANUM_SEQ] = v.ANUM_SEQ
LEFT OUTER JOIN DataWarehouse.dbo.AIS_PD_Victim_F as vic --Victim Table
		ON c.ANUM_PCT = vic.ANUM_PCT and c.ANUM_SEQ = vic.ANUM_SEQ and c.ANUM_YY = vic.ANUM_YY
WHERE C.OCCURRENCE_DATETIME between '3/24/2016' and '10/20/2016'
--and C.NODEID != 0
and c.NODEID = 33755
and v.PK != 1
and vic.INJURED_COUNT >0