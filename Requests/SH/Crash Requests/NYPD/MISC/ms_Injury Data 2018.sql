Select top 10 t1.INJURED_CNT, t1.INTEGRATION_ID 
From Forms.[dbo].[WC_ACCIDENT_F] t1  join WC_ACCIDENT_VICTIM_F t2
on t1.INTEGRATION_ID = ACCIDENT_ID
Where INJURED_CNT != 0 



Select Top 100 *
From WC_ACCIDENT_VICTIM_F
Where INJ_KILLED not in ('Unspecified') 

select distinct inj_killed from forms.dbo.WC_ACCIDENT_VICTIM_F

Select Top 100 PED_NONPED
From forms.dbo.WC_ACCIDENT_VICTIM_F


Select Top 100 PERSON_ROLE_CODE,PED_NONPED
From forms.dbo.WC_ACCIDENT_VICTIM_F

Select t2.VICTIM_AGE as Pedestrian_Age, t2.ACCIDENT_ID, t2.INJ_KILLED  --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where VICTIM_AGE >= 5 and VICTIM_AGE <= 17 and Year(t1.ACCIDENT_DT) = 2018 
and Inj_killed = 'Injured' and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
and coalesce(VOID_STATUS_CD, 'N') = 'N'


/*Select count(t2.INJ_KILLED ) as School_Aged  --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where VICTIM_AGE >= 5 and VICTIM_AGE <= 17 and Year(t1.ACCIDENT_DT) = 2018 
and Inj_killed = 'Injured' and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
and coalesce(VOID_STATUS_CD, 'N') = 'N'
*/

Select t2.VICTIM_AGE, t2.ACCIDENT_ID, t2.INJ_KILLED  --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where Year(t1.ACCIDENT_DT) = 2018 and Inj_killed = 'Injured' and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
and coalesce(VOID_STATUS_CD, 'N') = 'N'

/*Select count(t2.INJ_KILLED) --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where Year(t1.ACCIDENT_DT) = 2018 and Inj_killed = 'Injured' and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
and coalesce(VOID_STATUS_CD, 'N') = 'N'
*/


Select t2.VICTIM_AGE as Pedestrian_Age, t2.ACCIDENT_ID, t2.INJ_KILLED  --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where VICTIM_AGE >= 65 and Year(t1.ACCIDENT_DT) = 2018 
and Inj_killed = 'Injured' and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
and coalesce(VOID_STATUS_CD, 'N') = 'N'


/*Select count(t2.INJ_KILLED ) as Seniors --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where VICTIM_AGE >= 65 and Year(t1.ACCIDENT_DT) = 2018 
and Inj_killed = 'Injured' and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
and coalesce(VOID_STATUS_CD, 'N') = 'N'
*/



Select t2.ACCIDENT_ID, t2.INJ_KILLED  --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where Year(t1.ACCIDENT_DT) = 2018 and Inj_killed = 'Injured' and (PED_NONPED = 'Bicyclist') 
and coalesce(VOID_STATUS_CD, 'N') = 'N'


/*Select count(t2.INJ_KILLED)  --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where Year(t1.ACCIDENT_DT) = 2018 and Inj_killed = 'Injured' and (PED_NONPED = 'Bicyclist') 
and coalesce(VOID_STATUS_CD, 'N') = 'N'
*/



Select t2.ACCIDENT_ID, t2.INJ_KILLED  --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where Year(t1.ACCIDENT_DT) = 2018 and Inj_killed = 'Injured' and (PED_NONPED = 'Occupant') 
and coalesce(VOID_STATUS_CD, 'N') = 'N'


/*Select count(t2.INJ_KILLED)  --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where Year(t1.ACCIDENT_DT) = 2018 and Inj_killed = 'Injured' and (PED_NONPED = 'Occupant') 
and coalesce(VOID_STATUS_CD, 'N') = 'N'
*/


Select TOP 1000 PED_NONPED, PERSON_ROLE_CODE
From WC_ACCIDENT_VICTIM_F

Select Distinct PED_NONPED
From WC_ACCIDENT_VICTIM_F

Select Distinct PERSON_ROLE_CODE
From  WC_ACCIDENT_VICTIM_F
 

 /*Select count(t2.INJ_KILLED ) as School_Aged  --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where VICTIM_AGE >= 5 and VICTIM_AGE <= 17 and Year(t1.ACCIDENT_DT) = 2018 
and Inj_killed = 'Injured' and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
and coalesce(VOID_STATUS_CD, 'N') = 'N'
*/



/*Select count(t2.INJ_KILLED) --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where Year(t1.ACCIDENT_DT) = 2018 and Inj_killed = 'Injured' and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
and coalesce(VOID_STATUS_CD, 'N') = 'N'
*/


/*Select count(t2.INJ_KILLED ) as Seniors --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where VICTIM_AGE >= 65 and Year(t1.ACCIDENT_DT) = 2018 
and Inj_killed = 'Injured' and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
and coalesce(VOID_STATUS_CD, 'N') = 'N'
*/



/*Select count(t2.INJ_KILLED)  --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where Year(t1.ACCIDENT_DT) = 2018 and Inj_killed = 'Injured' and (PED_NONPED = 'Bicyclist') 
and coalesce(VOID_STATUS_CD, 'N') = 'N'
*/




/*Select count(t2.INJ_KILLED)  --count( INJ_KILLED)
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where Year(t1.ACCIDENT_DT) = 2018 and Inj_killed = 'Injured' and (PED_NONPED = 'Occupant') 
and coalesce(VOID_STATUS_CD, 'N') = 'N'
*/

select ped_nonped, person_role_code, count(*) from WC_ACCIDENT_VICTIM_F
where year(accident_dt) = 2018
and inj_killed = 'Injured'
group by PED_NONPED, PERSON_ROLE_CODE

Select Year(t1.accident_dt) as Yr,
count ((case when victim_age between 5 and 17  
and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') then t1.integration_id end)) School_Aged,
count ((case when victim_age between 65 and 100
and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') then t1.integration_id end)) Seniors,
count (case when (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') then t2.integration_id end) Total,
count (case when PED_NONPED = 'Bicyclist' then t1.integration_id end) Bicyclists,
count (case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE NOT In ('In-line Skater','Other') then t1.integration_id end) Occupant
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where Year(t1.ACCIDENT_DT) = 2018 and t2.Inj_killed = 'Injured' and coalesce(VOID_STATUS_CD, 'N') = 'N'
group by Year(t1.ACCIDENT_DT)


Select count(case when (ped_nonped = 'Occupant' and person_role_code in ('In-Line Skater')) 
or (ped_nonped = 'Pedestrian' and person_role_code in ('Pedestrian')) then T2.integration_id end) all_ped,
count (case when (PERSON_ROLE_CODE in	('Pedestrian', 'In-Line Skater')) then t2.integration_id end) Total/*,
count (case when PED_NONPED = 'Bicyclist' then t1.integration_id end) Bicyclists,
count (case when PED_NONPED = 'Occupant' then t1.integration_id end) Occupant*/
From forms.dbo.WC_ACCIDENT_VICTIM_F t2 join Forms.[dbo].[WC_ACCIDENT_F] t1
on t1.INTEGRATION_ID = t2.ACCIDENT_ID
where Year(t1.ACCIDENT_DT) = 2018 and t2.Inj_killed = 'Injured' and coalesce(VOID_STATUS_CD, 'N') = 'N'
group by Year(t1.ACCIDENT_DT) 

