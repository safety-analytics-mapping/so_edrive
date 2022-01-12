

--Draft 1
5056
--Single Vehichle Crahses
SELECT 'Single Vehicle Crashes' Type, YR, count(VictimID) Inj FROM (
SELECT distinct YR, VictimID FROM (
SELECT distinct veh.FID
      ,veh.[VehicleType]
	  ,VehicleRegistrationtype
	  ,v.AC_Date
	  ,v.YR
	  ,vic.Mode
	  ,vic.VictimID
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v
LEFT JOIN [Fatality].[dbo].[Fatal_Vehicle] veh
ON v.FID = veh.FID
LEFT JOIN [Fatality].[dbo].[Fatal_Victim] vic
ON v.VictimID = vic.VictimID
WHERE v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
and v.Mode in ('DR','MO','PS')
and veh.FID not in (SELECT [FID]
					FROM [Fatality].[dbo].[Fatal_Vehicle]
					WHERE VehicleType not in (FixedObjectType) 
					and VehicleRegistrationtype not in ('Parked')
					--and VehicleType = 'Bicycle'
					GROUP BY [FID]
					HAVING count([VehicleType]) > 1
					
					UNION

					SELECT [FID]
					FROM [Fatality].[dbo].[Fatal_Vehicle]
					WHERE VehicleType = 'Bicycle'
					and VehicleRegistrationtype not in ('Parked')
					GROUP BY [FID])
)stats
) tot 
GROUP BY YR
ORDER BY YR


--Draft 2

--Single Vehichle Crahses
SELECT 'Single Vehicle Crashes' Type, YR, count(FID) Inj FROM (
SELECT distinct YR, FID FROM (
SELECT distinct veh.FID
      ,veh.[VehicleType]
	  ,VehicleRegistrationtype
	  ,v.AC_Date
	  ,v.YR
	  ,vic.Mode
	  ,vic.VictimID
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v
LEFT JOIN [Fatality].[dbo].[Fatal_Vehicle] veh
ON v.FID = veh.FID
LEFT JOIN [Fatality].[dbo].[Fatal_Victim] vic
ON v.VictimID = vic.VictimID
WHERE v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
and v.Mode in ('DR','MO','PS')
and veh.FID not in (SELECT  veh.[FID]
					FROM [Fatality].[dbo].[Fatal_Vehicle] veh
					left join [Fatality].[dbo].[v_crash_victim_nonFR] v
					on  veh.FID = v.FID
					WHERE VehicleType not in (FixedObjectType) 
					and VehicleRegistrationtype not in ('Parked')
					--and v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
					--and VehicleType = 'Bicycle'
					GROUP BY veh.[FID]
					HAVING count([VehicleType]) > 1
					
					UNION

					SELECT  veh.[FID]
					FROM [Fatality].[dbo].[Fatal_Vehicle] veh
					left join [Fatality].[dbo].[v_crash_victim_nonFR] v
					on  veh.FID = v.FID
					WHERE VehicleType = 'Bicycle'
					and VehicleRegistrationtype not in ('Parked')
					--and v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
					GROUP BY veh.[FID])
)stats
) tot 
GROUP BY YR
ORDER BY YR



--Draft 3
--Single Vehichle Crahses
SELECT 'Single Vehicle Crashes' Type, YR, count(VictimID) Inj FROM (
SELECT distinct YR, VictimID FROM (
SELECT distinct veh.FID
      ,veh.[VehicleType]
	  ,VehicleRegistrationtype
	  ,v.AC_Date
	  ,v.YR
	  ,vic.Mode
	  ,vic.VictimID
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v
LEFT JOIN [Fatality].[dbo].[Fatal_Vehicle] veh
ON v.FID = veh.FID
LEFT JOIN [Fatality].[dbo].[Fatal_Victim] vic
ON v.VictimID = vic.VictimID
WHERE v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
and v.Mode in ('DR','MO','PS')
and veh.FID 



--Single Vehichle Crashes 3
SELECT 'Single Vehicle Crashes' Type, YR, sum(VID) Inj FROM (
--This sub query selects the count of victim fatalities by FID
SELECT YR, FID, CIS_ID, count(distinct(VictimID)) VID FROM (
--This sub query selects single vehicle crashes between the 
--years 2017-2019 up to the end of october for each year
SELECT distinct veh.FID
      ,veh.[VehicleType]
	  ,VehicleRegistrationtype
	  ,v.AC_Date
	  ,v.YR
	  ,vic.Mode
	  ,vic.VictimID
	  ,v.CIS_ID
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v
LEFT JOIN [Fatality].[dbo].[Fatal_Vehicle] veh
ON v.FID = veh.FID
LEFT JOIN [Fatality].[dbo].[Fatal_Victim] vic
ON v.VictimID = vic.VictimID
WHERE v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
and v.Mode in ('DR','MO','PS')
and veh.FID not in (--This subquery excludes all the cases where there 
					--are more than one vehicle by use of the HAVING clause
					SELECT veh.FID
					FROM [Fatality].[dbo].[Fatal_Vehicle] veh
					left join [Fatality].[dbo].[v_crash_victim_nonFR] v
					on  veh.FID = v.FID
					WHERE VehicleType not in ('FIXED OBJECT') 
					and VehicleRegistrationtype not in ('PARKED')
					GROUP BY veh.[FID]
					HAVING count(distinct(VehicleID)) > 1)
) cases 
group by YR, FID, CIS_ID
) result
GROUP BY YR
ORDER BY YR









/* End of Year Fatality _ single vehicle*/
/* Single vehicale crash means the crash involved only single moveable vehicle and the crash results killed motorcyclist or killed motor vehicle occupants */ 
 
 Select F.YR, Count([VictimID]) As '#killed_single_veh'
 From
  (
   Select A.YR,A.[AC_Date], A.[CIS_ID],A.[VictimID],(A.#Veh-A.Fixed-A.Parked)As 'Single_veh'
   From
       (
       Select YR,[AC_Date],[CIS_ID],[VictimID],Count ([VehicleID]) As '#Veh',
       COUNT(Case When [VehicleRegistrationtype] in ('Parked') then [VehicleID] end ) As 'Parked',
       COUNT(Case When [VehicleType] in ('FIXED OBJECT') then [VehicleID] end) as 'Fixed'
       From
       (SELECT 
       [FID],[CIS_ID],[AC_Date],[YR],[VictimID],[Mode]
        FROM [Fatality].[dbo].[v_crash_victim_nonFR]) As C
     Left Join 
     (SELECT 
      [FID],[VehicleID],[VehicleType],[VehicleRegistrationtype],[FixedObjectType]
      FROM [Fatality].[dbo].[Fatal_Vehicle]) As Veh
      on C.FID = Veh.FID
      Where (YR >=2017 and datepart(month,AC_Date)<10)and Mode in('DR','PS','MO')
      group by YR,[AC_Date],[CIS_ID],[VictimID]
      ) AS A
      Where (A.#Veh-A.Fixed-A.Parked)=1
      --order by A.[AC_Date] DESC, A.[CIS_ID]ASC
 ) As F
      group by 
      F.YR




/* End of Year Fatality _ single vehicle*/
/* Single vehicale crash means the crash involved only single moveable vehicle and the crash results killed motorcyclist or killed motor vehicle occupants */ 
 
 Select F.YR, Count([VictimID]) As '#killed_single_veh'
 From
  (
   Select FID, A.YR,A.[AC_Date], A.[CIS_ID],A.[VictimID],(A.#Veh-A.Fixed-A.Parked)As 'Single_veh'
   From
       (
       Select c.FID,YR,[AC_Date],[CIS_ID],[VictimID],Count ([VehicleID]) As '#Veh',
       COUNT(Case When [VehicleRegistrationtype] in ('Parked') then [VehicleID] end ) As 'Parked',
       COUNT(Case When [VehicleType] in ('FIXED OBJECT') then [VehicleID] end) as 'Fixed'
       From
       (SELECT 
       [FID],[CIS_ID],[AC_Date],[YR],[VictimID],[Mode]
        FROM [Fatality].[dbo].[v_crash_victim_nonFR]) As C
     Left Join 
     (SELECT 
      [FID],[VehicleID],[VehicleType],[VehicleRegistrationtype],[FixedObjectType]
      FROM [Fatality].[dbo].[Fatal_Vehicle]) As Veh
      on C.FID = Veh.FID
      Where (YR >=2017 and datepart(month,AC_Date)<10)and Mode in('DR','PS','MO')
      group by c.FID,YR,[AC_Date],[CIS_ID],[VictimID]
      ) AS A
      Where (A.#Veh-A.Fixed-A.Parked)=1
      --order by A.[AC_Date] DESC, A.[CIS_ID]ASC
 ) As F
      group by 
      F.YR



/* End of Year Fatality _ single vehicle*/
/* Single vehicale crash means the crash involved only single moveable vehicle and the crash results killed motorcyclist or killed motor vehicle occupants */ 
 
 Select F.YR, Count([VictimID]) As '#killed_single_veh'
 From
  (
   Select A.YR,A.[AC_Date], A.[CIS_ID],A.[VictimID],(A.#Veh-A.Fixed-A.Parked)As 'Single_veh'
   From
       (
       Select YR,[AC_Date],[CIS_ID],[VictimID],Count ([VehicleID]) As '#Veh',
       COUNT(Case When [VehicleRegistrationtype] in ('Parked') then [VehicleID] end ) As 'Parked',
       COUNT(Case When [VehicleType] in ('FIXED OBJECT') then [VehicleID] end) as 'Fixed'
       From
       (SELECT 
       [FID],[CIS_ID],[AC_Date],[YR],[VictimID],[Mode]
        FROM [Fatality].[dbo].[v_crash_victim_nonFR]) As C
     Left Join 
     (SELECT 
      [FID],[VehicleID],[VehicleType],[VehicleRegistrationtype],[FixedObjectType]
      FROM [Fatality].[dbo].[Fatal_Vehicle]) As Veh
      on C.FID = Veh.FID
      Where (YR >=2017 and datepart(month,AC_Date)<10)and Mode in('DR','PS','MO')
      group by YR,[AC_Date],[CIS_ID],[VictimID]
      ) AS A
      Where (A.#Veh-A.Fixed-A.Parked)=1
      --order by A.[AC_Date] DESC, A.[CIS_ID]ASC
 ) As F
      group by 
      F.YR




