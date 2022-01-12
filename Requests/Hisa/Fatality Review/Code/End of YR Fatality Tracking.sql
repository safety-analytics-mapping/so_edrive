/****** Script for SelectTopNRows command from SSMS  ******/

/* End of Year Fatality Review*/


/* Pedestrian cause join Motoristist cause */
---------------------------------------------
Select * From
   (
/* V_Crash_Victim_nonFR join Fatal_Victim_Table*/
-------------------------------------------------
Select F.YR,
Sum( PB_crossmidblock) As 'PB_Cross_midblock',
Sum(PB_against_signal) As 'PB_Against_signal',
Sum(Ped_on_sidewalk) As 'Ped_On_Sidewalk'
From
  (
   Select  C.YR,C.VictimID,
   Sum(Case When C.[Track_PB_CrossMidBlock]=1 then 1 else 0 end)As'PB_crossmidblock',
   Sum(Case When C.[Track_PB_Signal]=1 then 1 else 0 end ) as 'PB_against_signal',
   Sum(Case When V.[Track_PED_OnSidewalk]=1 then 1 else 0 end) as'Ped_on_sidewalk'
   From
      (
      SELECT [FID]
      --,[ACNO]
      ,[AC_Date]
      ,[YR]
      ,[Mode]
      ,[VictimID] 
      ,[Track_PB_CrossMidBlock]
      ,[Track_PB_Signal]
      FROM [Fatality].[dbo].[v_crash_victim_nonFR]) As C
      Left Join
      (SELECT [FID]
      ,[VictimID]
      ,[Track_PED_OnSidewalk]
      FROM [Fatality].[dbo].[Fatal_Victim]) as V
      on C.[VictimID] =V.[VictimID] 
      Where Year(C.[AC_Date]) in(2017,2018,2019) and datepart(month,C.[AC_Date])<10 and C.Mode='PD'
  Group by C.YR,C.VictimID
  )As F
Group by F.YR
   ) As A
     Join
 /* V_Crash_Victim_nonFR join Fatal_Vehicle_Table*/
-------------------------------------------------   
  (
Select T.YR,
Sum(Single_Veh)As 'Single_veh',
Sum(DR_Disregard_Traffic) As 'Disregard_Traffic_Control',
Sum(DR_Speed) As 'Speed',
Sum(DR_Backing) As 'Backing',
Sum(DR_FY) As ' FTY'
  From
  (
  Select C.YR,C.[VictimID],
  Sum(Case When C.[NumberVehicle]=1 then 1 else 0 end ) As 'Single_Veh',
  Sum(Case When Veh.[Track_DisregardTrafficDevice]in('SIGNAL','STOP','1') then 1 else 0 end) as 'DR_Disregard_Traffic',
  Sum(Case When Veh.[Track_Speeding]=1 then 1 else 0 end) as 'DR_Speed',
  Sum(Case When Veh.[Track_Backing]=1 then 1 else 0 end) as 'DR_Backing',
  Sum(Case When Veh.[Track_FY_PedBike]=1 then 1 else 0 end) as 'DR_FY'
  From
     (
     SELECT [FID]
    --,[ACNO]
      ,[YR]
      ,[AC_Date]
      ,[Mode]
      ,[VictimID]
      ,[NumberVehicle]
       FROM [Fatality].[dbo].[v_crash_victim_nonFR]) As C
      Left join
     (SELECT [FID]
       -- ,[ACNO]
      ,[VehicleID]
      
      ,[Track_DisregardTrafficDevice]
      ,[Track_Speeding]
      ,[Track_Backing]
      ,[Track_FY_PedBike]
       FROM [Fatality].[dbo].[Fatal_Vehicle]) As Veh
       on C.FID=Veh.FID
       Where  Year(C.[AC_Date]) in(2017,2018,2019) and datepart(month,C.[AC_Date])<10 and C.Mode='PD' 
   Group by C.YR,C.[VictimID]
  ) As T
Group by T.YR
      ) As B
      On A.YR=B.YR
      
     /* Number vehicle VS count Veh ID*/
     --------------------------------------
     Select K.VictimID,K.[NumberVehicle],Count(K.[VehicleID]) as 'Veh_Cal'
From(

SELECT C.[FID]
      ,C.[CIS_ID]
      ,C.[ACNO]
      ,C.[AC_Date]
      ,C.[NumberVehicle]
      ,C.[Mode]
      ,C.VictimID
      ,Veh.[VehicleID]
  FROM [Fatality].[dbo].[v_crash_victim_nonFR] As C
  Left join[Fatality].[dbo].[Fatal_Vehicle] As Veh
  ON C.[FID]=Veh.[FID]
  Where   Year(C.[AC_Date]) in(2017,2018,2019) and datepart(month,C.[AC_Date])<10 and C.Mode='PD' 
  )As K
  group by K.VictimID,K.[NumberVehicle]
  