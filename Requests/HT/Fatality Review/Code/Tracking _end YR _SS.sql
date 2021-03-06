/****** Script for SelectTopNRows command from SSMS  ******/
/* Ped Crossing mid-block*/
Select A.YR, COUNT(A.[VictimID]) As 'Pd_mid_block'
From
(
SELECT 
      [YR]
      ,[VictimID]
      ,[Track_PB_CrossMidBlock]
     
  FROM [Fatality].[dbo].[v_crash_victim_nonFR]
  Where [YR]>=2017 and Mode ='PD' and [Track_PB_CrossMidBlock]=1
  group by [YR] ,[VictimID] ,[Track_PB_CrossMidBlock]
   ) As A
   Group by A.YR
   
    /* Ped against signal*/
Select A.YR, Count ([VictimID])As 'Pd_against signal'
From
(
SELECT 
      YR
      ,[AC_Date]
      ,[VictimID]
      ,[Track_PB_Signal]
  FROM [Fatality].[dbo].[v_crash_victim_nonFR]
  Where Year ((AC_Date))>=2017 and Mode ='PD' and [Track_PB_Signal]=1
  ) AS A
  Group By A.YR 
  /* Single veh*/
  /* Single veh*/
Select A. YR, Count (A.[VictimID]) As 'Single veh'
From
(
SELECT  C.[FID]
      ,C.[YR]
      ,Count(veh.VehicleID) AS 'VEH_Nu'
      ,C.[VictimID]
      ,C.[Mode]
     
  FROM [Fatality].[dbo].[v_crash_victim_nonFR] As C Left Join [Fatality].[dbo].[Fatal_Vehicle] veh
  On C.FID=veh.FID
  Where C.YR>=2017 and C.Mode='PD' 
  Group by C.[FID]
      
      ,C.[YR],C.[VictimID] ,C.[Mode]
      ) As A
      Where A.VEH_Nu=1
      group by A.YR
  
     
      
     