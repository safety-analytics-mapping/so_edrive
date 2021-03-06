/****** Script for SelectTopNRows command from SSMS  ******/
/* Single Veh*/
Select F.YR,Sum(F.Victim_invlved)As 'Single veh'
From
(
Select C.YR,C.[FID],COUNT(Veh.VehicleID) As 'Veh_involved',Count(C.[VictimID]) As 'Victim_invlved'
 From
(SELECT  [FID],[CIS_ID],[AC_Date],[YR],[CrashType],[VictimID],[Mode]
  FROM [Fatality].[dbo].[v_crash_victim_nonFR] ) AS C
  Left Join
  (Select FID,VehicleID
  from [Fatality].[dbo].Fatal_Vehicle )As Veh
  on C.[FID]=Veh.FID
  Where (Year(AC_Date) in(2017,2018,2019) and datepart(month,AC_Date)<10) And Mode in('DR','PS','MO')and [CrashType]='VO' 
  group by  C.YR,C.[FID]
  ) AS F
  where Veh_involved=1
  group by  F.YR