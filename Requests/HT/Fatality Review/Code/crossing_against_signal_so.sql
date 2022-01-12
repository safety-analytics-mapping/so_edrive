--This query selects Crossing against signal crashes between the 
--years 2017-2019 up to the end of September for each year. We are only interested
--in pedestrian injuries.

--Here the column [Track_PB_Signal] is specific for Crossing against signal
--crash cases and we are interested in cases when this equal to 1.

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