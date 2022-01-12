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