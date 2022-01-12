SELECT 
	nodeid, M,Y,  
	sum(Pedestrian) Pedestrian, sum(Bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
	sum(Ped_School_Aged) School_Aged, sum(Ped_Seniors)  Seniors, sum(Ped_Adult) Adult
FROM

	(select M, Y, nodeid, 
			max(Pedestrian) Pedestrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) Veh_Occupant, 
			max(School_Aged) Ped_School_Aged, max(Seniors) Ped_Seniors, max(Adult) Ped_Adult
	FROM
			(SELECT 
				extract(month from c.ACCIDENT_DT::date) M , extract(year from c.ACCIDENT_DT::date) Y, 
				c.NODEID,
				(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
				(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
				(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
				(case when i.victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
				then 1 else 0 end) School_Aged,
				(case when i.victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') 
				then 1 else 0 end) Seniors,
				(case when i.victim_age between 18 and 64 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
				then 1 else 0 end) Adult,
				c.INTEGRATION_ID
			FROM public.wc_accident_f as c
			join public.wc_accident_victim_f as i
			on c.INTEGRATION_ID::int=i.ACCIDENT_ID::int
			where c.nodeid is not null 
			  and i.INJ_KILLED = 'Injured' 
			  and coalesce(c.VOID_STATUS_CD , 'N') ='N'
			  and coalesce(c.NONMV , 0) = 0) z
			  --and ACCIDENT_ID in (727118109,734418109)) z

		group by integration_id, M, Y, nodeid) x

group by nodeid, M, Y


select extract (month from accd_dte) from public.nysdot_all limit 10
select extract (day from accd_dte) from nysdot_all limit 10

Select *
from  public.wc_accident_victim_f  limit 10


Select wc_accident_f.*, accident_dt
from  public.wc_accident_f  limit 10
