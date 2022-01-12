--This query selects Motoristists Disregard of Traffic Control crashes between the 
--years 2017-2019 up to the end of September for each year. We are only interested
--in pedestrian injuries.

--Here the column [Track_DisregardTrafficDevice] is specific for Disregard 
--of Traffic Controls crash cases and we are interested in cases when this 
--column is in ('SIGNAL','STOP')

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
and [Track_DisregardTrafficDevice] in ('SIGNAL','STOP')
and vic.Mode = 'PD'
) cases 
group by YR
order by YR