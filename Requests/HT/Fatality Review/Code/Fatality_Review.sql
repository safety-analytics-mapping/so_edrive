
select * from (
--Stats for Year End Fatality Review

--Requested Stats (YTD=9/30: 2017-2019)
SELECT distinct mode
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v

SELECT distinct mode
FROM [Fatality].[dbo].[Fatal_Victim] 

SELECT distinct [VehicleType]
FROM [Fatality].[dbo].[Fatal_Vehicle]




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


union


--Disregard of Traffic Controls 
SELECT 'Disregard of Traffic Controls' Type, YR, count(FID) Inj from (
SELECT Distinct veh.FID
	  ,v.AC_Date
	  ,v.YR
	  ,vic.Mode
	  ,vic.VictimID
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v
LEFT JOIN [Fatality].[dbo].[Fatal_Vehicle] veh
on v.FID = veh.FID
LEFT JOIN [Fatality].[dbo].[Fatal_Victim] vic
on v.FID = vic.FID
WHERE v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
and [Track_DisregardTrafficDevice] in ('SIGNAL','STOP','1')
and vic.Mode = 'PD'
) cases 
group by YR
order by YR


union

 
--High Speed and/or loss control
SELECT 'High Speed' Type, YR, count(FID) Inj from (
SELECT Distinct veh.FID
	  ,v.AC_Date
	  ,v.YR
	  ,vic.Mode
	  ,vic.VictimID
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v
LEFT JOIN [Fatality].[dbo].[Fatal_Vehicle] veh
on v.FID = veh.FID
LEFT JOIN [Fatality].[dbo].[Fatal_Victim] vic
on v.FID = vic.FID
WHERE v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
and [Track_Speeding] = '1'
and vic.Mode = 'PD'
) cases 
group by YR
order by YR


union


--Driving in reverse/parking maneuver
SELECT 'Driving in Reverse' Type, YR, count(FID) Inj from (
SELECT veh.FID
	  ,v.AC_Date
	  ,v.YR
	  ,vic.Mode
	  ,vic.VictimID
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v
LEFT JOIN [Fatality].[dbo].[Fatal_Vehicle] veh
on v.FID = veh.FID
LEFT JOIN [Fatality].[dbo].[Fatal_Victim] vic
on v.FID = vic.FID
WHERE v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
and [Track_Backing]= '1'
and vic.Mode = 'PD'
) cases 
group by YR
order by YR


union


--Failure to yield
SELECT 'Failure to yield' Type, YR, count(FID) Inj from (
SELECT Distinct veh.FID
	  ,v.AC_Date
	  ,v.YR
	  ,vic.Mode
	  ,vic.VictimID
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v
LEFT JOIN [Fatality].[dbo].[Fatal_Vehicle] veh
on v.FID = veh.FID
LEFT JOIN [Fatality].[dbo].[Fatal_Victim] vic
on v.FID = vic.FID
WHERE v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
and vic.Mode = 'PD'
and [Track_FY_PedBike] = '1'
) cases 
group by YR
order by YR


union


--Crossing against signal 
SELECT 'Crossing against signal' Type,  YR, count(FID) Inj from (
SELECT Distinct veh.FID
	  ,v.AC_Date
	  ,v.YR
	  ,vic.Mode
	  ,vic.VictimID
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v
LEFT JOIN [Fatality].[dbo].[Fatal_Vehicle] veh
on v.FID = veh.FID
LEFT JOIN [Fatality].[dbo].[Fatal_Victim] vic
on v.FID = vic.FID
WHERE v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
and vic.Mode = 'PD'
and vic.[Track_PB_Signal] = '1'
) cases 
group by YR
order by YR


union


--Midblock crossing (ped)
SELECT 'Midblock Crossing (ped)' Type,  YR, count(FID) Inj from (
SELECT Distinct veh.FID
	  ,v.AC_Date
	  ,v.YR
	  ,vic.Mode
	  ,vic.VictimID
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v
LEFT JOIN [Fatality].[dbo].[Fatal_Vehicle] veh
on v.FID = veh.FID
LEFT JOIN [Fatality].[dbo].[Fatal_Victim] vic
on v.FID = vic.FID
WHERE v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
and vic.Mode = 'PD'
and vic.[Track_PB_CrossMidBlock] = '1'
) cases 
group by YR
order by YR


union 


--Mounting the sidewalk
SELECT 'Mounting the sidewalk' Type, YR, count(FID) Inj from (
SELECT Distinct veh.FID
	  ,v.AC_Date
	  ,v.YR
	  ,vic.Mode
	  ,vic.VictimID
FROM [Fatality].[dbo].[v_crash_victim_nonFR] v
LEFT JOIN [Fatality].[dbo].[Fatal_Vehicle] veh
on v.FID = veh.FID
LEFT JOIN [Fatality].[dbo].[Fatal_Victim] vic
on v.FID = vic.FID
WHERE v.YR in (2017,2018,2019) and datepart(month,v.[AC_Date])<10
and vic.Mode = 'PD'
and vic.[Track_PED_OnSidewalk] = '1'
) cases 
group by YR
order by YR








