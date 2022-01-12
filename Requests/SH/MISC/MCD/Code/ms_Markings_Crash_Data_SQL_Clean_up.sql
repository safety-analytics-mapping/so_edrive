

with data as (
SELECT 

	datepart(mm,c.ACCIDENT_DT) M , datepart(yy,c.ACCIDENT_DT) Y, 
	c.NODEID,
	c.INTEGRATION_ID

    (case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
	(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
	(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
	(case when victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
	then 1 else 0 end) School_Aged,
	(case when victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') 
	then 1 else 0 end) Seniors,
	(case when victim_age between 18 and 64 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
	then 1 else 0 end) Adult, 

FROM FORMS.dbo.WC_ACCIDENT_F as c
join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
on c.INTEGRATION_ID=i.ACCIDENT_ID
where c.nodeid is not null 
and i.INJ_KILLED = 'Injured' 
and coalesce(c.VOID_STATUS_CD , 'N') ='N'
and coalesce(c.NONMV , 0) = 0
)

SELECT 
		M, Y, nodeid, 
		max(Pedestrian) Pedestrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) Veh_Occupant, 
		max(School_Aged) Ped_School_Aged, max(Seniors) Ped_Seniors, max(Adult) Ped_Adult

FROM Data