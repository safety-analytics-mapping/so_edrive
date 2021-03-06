
select top 10 *
FROM FORMS.dbo.WC_ACCIDENT_F

select top 10 *
FROM FORMS.dbo.WC_ACCIDENT_F
where INJURED_CNT>0

select top 10 *
FROM FORMS.dbo.WC_ACCIDENT_F f
join (select distinct INTEGRATION_ID
	  from forms.dbo.WC_ACCIDENT_F) ID
on f.INTEGRATION_ID = ID.INTEGRATION_ID

---WC_ACCIDENT_VICTIM_F HAS NO DUPLICATE INTEGRATION ID's
select top 100 INTEGRATION_ID, Count(*)
FROM FORMS.dbo.WC_ACCIDENT_VICTIM_F
GROUP BY INTEGRATION_ID
having count(*)>=2


select top 10 *
FROM FORMS.dbo.WC_ACCIDENT_VICTIM_F

select top 100 ACCIDENT_ID, Count(*)
FROM FORMS.dbo.WC_ACCIDENT_VICTIM_F
GROUP BY ACCIDENT_ID

---WC_ACCIDENT_VICTIM_F HAS DUPLICATE INTEGRATION ID's
select top 100 ACCIDENT_ID, Count(*)
FROM FORMS.dbo.WC_ACCIDENT_VICTIM_F
GROUP BY ACCIDENT_ID
having count(*)>=2

select top 10 *
FROM FORMS.dbo.WC_ACCIDENT_VICTIM_F
where ACCIDENT_ID = 100026


SELECT Distinct Top 1000 ACCIDENT_DT --, NODEID 
FROM FORMS.dbo.WC_ACCIDENT_F
where nodeid is not null
order by ACCIDENT_DT asc

SELECT Top 100
cast((datepart(mm,c.ACCIDENT_DT)) as varchar(2)) + '/' + cast((datepart(yy,c.ACCIDENT_DT)) as varchar(4)) , 
c.NODEID,
(case when victim_age between 5 and 17 then 1 end) School_Aged,
(case when victim_age between 65 and 100 then 1 end) Seniors,
(case when victim_age between 18 and 64 then 1 end) School_Aged,
FROM FORMS.dbo.WC_ACCIDENT_F as c
join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
    on c.INTEGRATION_ID=i.ACCIDENT_ID
where c.nodeid is not null 
  and i.INJ_KILLED = 'Injured'
  



SELECT Top 100
cast((datepart(mm,c.ACCIDENT_DT)) as varchar(2)) + '/' + cast((datepart(yy,c.ACCIDENT_DT)) as varchar(4)) MM_YY, 
c.NODEID,
(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE NOT In ('In-line Skater','Other') then 1 else 0 end) Veh_Occupant,
(case when victim_age between 5 and 17 then 1 else 0 end) School_Aged,
(case when victim_age between 65 and 100 then 1 else 0 end) Seniors,
(case when victim_age between 18 and 64 then 1 else 0 end) Adult,
c.INTEGRATION_ID
FROM FORMS.dbo.WC_ACCIDENT_F as c
join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
    on c.INTEGRATION_ID=i.ACCIDENT_ID
where c.nodeid is not null 
  and i.INJ_KILLED = 'Injured'

select * from FORMS.dbo.WC_ACCIDENT_VICTIM_F where accident_id = 117014


SELECT Top 100
/*cast((datepart(mm,c.ACCIDENT_DT)) as varchar(2)) + '/' + cast((datepart(yy,c.ACCIDENT_DT)) as varchar(4)) MM_YY, 
c.NODEID,
(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE NOT In ('In-line Skater','Other') then 1 else 0 end) Veh_Occupant,
(case when victim_age between 5 and 17 then 1 else 0 end) School_Aged,
(case when victim_age between 65 and 100 then 1 else 0 end) Seniors,
(case when victim_age between 18 and 64 then 1 else 0 end) Adult,*/
c.INTEGRATION_ID, Count(*)
FROM FORMS.dbo.WC_ACCIDENT_F as c
join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
    on c.INTEGRATION_ID=i.ACCIDENT_ID
where c.nodeid is not null 
  and i.INJ_KILLED = 'Injured'
Group by c.INTEGRATION_ID


--Runtime 2 secs
SELECT 
integration_id, mm_yy, nodeid, 
sum(pedestrian) Pedestrian, sum(bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
sum(School_Aged) School_Aged, sum(Seniors)  Seniors, sum(Adult) Adult
FROM
	(SELECT 
		cast((datepart(mm,c.ACCIDENT_DT)) as varchar(2)) + '/' + cast((datepart(yy,c.ACCIDENT_DT)) as varchar(4)) MM_YY, 
		c.NODEID,
		(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
		(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
		(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE NOT In ('In-line Skater','Other') then 1 else 0 end) Veh_Occupant,
		(case when victim_age between 5 and 17 then 1 else 0 end) School_Aged,
		(case when victim_age between 65 and 100 then 1 else 0 end) Seniors,
		(case when victim_age between 18 and 64 then 1 else 0 end) Adult,
		c.INTEGRATION_ID
	FROM FORMS.dbo.WC_ACCIDENT_F as c
	join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
		on c.INTEGRATION_ID=i.ACCIDENT_ID
	where c.nodeid is not null 
	  and i.INJ_KILLED = 'Injured') z
group by integration_id, mm_yy, nodeid




/*
SELECT c.INTEGRATION_ID,
	cast((datepart(mm,c.ACCIDENT_DT)) as varchar(2)) + '/' + cast((datepart(yy,c.ACCIDENT_DT)) as varchar(4)) Dt, 
	c.NODEID,
	(sum(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end)) Pedestrian,
	(sum(case when PED_NONPED = 'Bicyclist' then 1 else 0 end)) Bicyclists,
	(sum(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE NOT In ('In-line Skater','Other') then 1 else 0 end)) Veh_Occupant,
	(sum(case when victim_age between 5 and 17 then 1 else 0 end)) School_Aged,
	(sum(case when victim_age between 65 and 100 then 1 else 0 end)) Seniors,
	(sum(case when victim_age between 18 and 64 then 1 else 0 end)) Adult
FROM FORMS.dbo.WC_ACCIDENT_F as c
join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
	on c.INTEGRATION_ID=i.ACCIDENT_ID
where c.nodeid is not null 
	and i.INJ_KILLED = 'Injured' 
group by c.INTEGRATION_ID, cast((datepart(mm,c.ACCIDENT_DT)) as varchar(2)) + '/' + cast((datepart(yy,c.ACCIDENT_DT)) as varchar(4)) , c.NODEID
*/


--TEST
select integration_id, mm_yy, nodeid, 
Pedestrian, Bicyclists, Veh_Occupant, 
School_Aged, Seniors,Adult
from
	(SELECT 
	cast((datepart(mm,c.ACCIDENT_DT)) as varchar(2)) + '/' + cast((datepart(yy,c.ACCIDENT_DT)) as varchar(4)) MM_YY, 
	c.NODEID,
	(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
	(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
	(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE NOT In ('In-line Skater','Other') then 1 else 0 end) Veh_Occupant,
	(case when victim_age between 5 and 17 then 1 else 0 end) School_Aged,
	(case when victim_age between 65 and 100 then 1 else 0 end) Seniors,
	(case when victim_age between 18 and 64 then 1 else 0 end) Adult,
	c.INTEGRATION_ID
	FROM FORMS.dbo.WC_ACCIDENT_F as c
	join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
		on c.INTEGRATION_ID=i.ACCIDENT_ID
	where c.nodeid is not null 
	  and i.INJ_KILLED = 'Injured') z


--Test 2
select integration_id, M, Y, nodeid, 
max(Pedestrian) Pedstrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) VEH_Occupants, 
max(School_Aged) SA, max(Seniors) Seniors, max(Adult) Adult
from
	(SELECT 
	datepart(mm,c.ACCIDENT_DT) M , datepart(yy,c.ACCIDENT_DT) Y, 
	c.NODEID,
	(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
	(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
	(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE NOT In ('In-line Skater','Other') then 1 else 0 end) Veh_Occupant,
	(case when victim_age between 5 and 17 then 1 else 0 end) School_Aged,
	(case when victim_age between 65 and 100 then 1 else 0 end) Seniors,
	(case when victim_age between 18 and 64 then 1 else 0 end) Adult,
	c.INTEGRATION_ID
	FROM FORMS.dbo.WC_ACCIDENT_F as c
	join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
		on c.INTEGRATION_ID=i.ACCIDENT_ID
	where c.nodeid is not null 
	  and i.INJ_KILLED = 'Injured'--) z
	  and c.integration_id =0007717044)z
group by integration_id, M, Y, nodeid


SELECT 
integration_id, M,Y, nodeid, 
sum(pedestrian) Pedestrian, sum(bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
sum(School_Aged) School_Aged, sum(Seniors)  Seniors, sum(Adult) Adult
FROM
	(SELECT 
		datepart(mm,c.ACCIDENT_DT) M , datepart(yy,c.ACCIDENT_DT) Y, 
		c.NODEID,
		(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
		(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
		(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
		(case when victim_age between 1 and 17 then 1 else 0 end) School_Aged,
		(case when victim_age between 65 and 100 then 1 else 0 end) Seniors,
		(case when victim_age between 18 and 64 then 1 else 0 end) Adult,
		c.INTEGRATION_ID
	FROM FORMS.dbo.WC_ACCIDENT_F as c
	join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
		on c.INTEGRATION_ID=i.ACCIDENT_ID
	where c.nodeid is not null 
	  and i.INJ_KILLED = 'Injured' 
	  and coalesce(c.VOID_STATUS_CD , 'N') ='N') z
group by integration_id, M, Y, nodeid




select distinct i.PERSON_ROLE_CODE
FROM FORMS.dbo.WC_ACCIDENT_F as c
	join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
	on c.INTEGRATION_ID=i.ACCIDENT_ID
	where c.nodeid is not null and i.INJ_KILLED = 'Injured' and PED_NONPED in ('OCCUPANT') and coalesce(c.VOID_STATUS_CD , 'N') ='N'
	group by i.PERSON_ROLE_CODE 






SELECT 
integration_id, M,Y, nodeid, 
sum(pedestrian) Pedestrian, sum(bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
sum(School_Aged) School_Aged, sum(Seniors)  Seniors, sum(Adult) Adult
FROM
	(SELECT 
		datepart(mm,c.ACCIDENT_DT) M , datepart(yy,c.ACCIDENT_DT) Y, 
		c.NODEID,
		(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
		(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
		(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
		(case when victim_age between 1 and 17 then 1 else 0 end) School_Aged,
		(case when victim_age between 65 and 100 then 1 else 0 end) Seniors,
		(case when victim_age between 18 and 64 then 1 else 0 end) Adult,
		c.INTEGRATION_ID
	FROM FORMS.dbo.WC_ACCIDENT_F as c
	join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
		on c.INTEGRATION_ID=i.ACCIDENT_ID
	where c.nodeid is not null 
	  and i.INJ_KILLED = 'Injured' 
	  and coalesce(c.VOID_STATUS_CD , 'N') ='N'--) z 
	  and c.Integration_ID =  0007717044) z
group by integration_id, M, Y, nodeid







Select integration_id, M,Y, nodeid, 
	 Pedestrian,  Bicyclists, Veh_Occupant, 
	 School_Aged, Seniors,  Adult

From
	(SELECT 
	integration_id, M,Y, nodeid, 
	sum(pedestrian) Pedestrian, sum(bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
	sum(School_Aged) School_Aged, sum(Seniors)  Seniors, sum(Adult) Adult
	FROM
		(SELECT 
			datepart(mm,c.ACCIDENT_DT) M , datepart(yy,c.ACCIDENT_DT) Y, 
			c.NODEID,
			(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
			(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
			(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
			(case when victim_age between 1 and 17 then 1 else 0 end) School_Aged,
			(case when victim_age between 65 and 100 then 1 else 0 end) Seniors,
			(case when victim_age between 18 and 64 then 1 else 0 end) Adult,
			c.INTEGRATION_ID
		FROM FORMS.dbo.WC_ACCIDENT_F as c
		join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
			on c.INTEGRATION_ID=i.ACCIDENT_ID
		where c.nodeid is not null 
		  and i.INJ_KILLED = 'Injured' 
		  and coalesce(c.VOID_STATUS_CD , 'N') ='N') z 
		  --and c.Integration_ID =  0000117052) z
	group by integration_id, M, Y, nodeid) y
where Veh_Occupant >=2




--0007717044




select integration_id, M, Y, nodeid, 
max(Pedestrian) Pedstrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) VEH_Occupants, 
max(School_Aged) Ped_School_Aged, max(Seniors) Ped_Seniors, max(Adult) Ped_Adult
FROM
	(SELECT 
		datepart(mm,c.ACCIDENT_DT) M , datepart(yy,c.ACCIDENT_DT) Y, 
		c.NODEID,
		(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
		(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
		(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
		(case when victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
		then 1 else 0 end) School_Aged,
		(case when victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') 
		then 1 else 0 end) Seniors,
		(case when victim_age between 18 and 64 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
		then 1 else 0 end) Adult,
		c.INTEGRATION_ID
	FROM FORMS.dbo.WC_ACCIDENT_F as c
	join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
		on c.INTEGRATION_ID=i.ACCIDENT_ID
	where c.nodeid is not null 
	  and i.INJ_KILLED = 'Injured' 
	  and coalesce(c.VOID_STATUS_CD , 'N') ='N'--) z 
	  --and c.Integration_ID =  0007717044
	  and NONMV is not NULL and NONMV != 1) z
group by integration_id, M, Y, nodeid





select PED_NONPED, PERSON_ROLE_CODE, count(*)
FROM FORMS.dbo.WC_ACCIDENT_VICTIM_F 
group by PED_NONPED, PERSON_ROLE_CODE


select Top 100  NONMV
FROM FORMS.dbo.WC_ACCIDENT_F




--PER
select integration_id, M, Y, nodeid, 
max(Pedestrian) Pedstrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) VEH_Occupants, 
max(School_Aged) Ped_School_Aged, max(Seniors) Ped_Seniors, max(Adult) Ped_Adult
FROM
	(SELECT 
		datepart(mm,c.ACCIDENT_DT) M , datepart(yy,c.ACCIDENT_DT) Y, 
		c.NODEID,
		(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
		(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
		(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
		(case when victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
		then 1 else 0 end) School_Aged,
		(case when victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') 
		then 1 else 0 end) Seniors,
		(case when victim_age between 18 and 64 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
		then 1 else 0 end) Adult,
		c.INTEGRATION_ID
	FROM FORMS.dbo.WC_ACCIDENT_F as c
	join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
		on c.INTEGRATION_ID=i.ACCIDENT_ID
	where c.nodeid is not null 
	  and i.INJ_KILLED = 'Injured' 
	  and coalesce(c.VOID_STATUS_CD , 'N') ='N'
	  and NONMV is not NULL and NONMV != 1) z
group by integration_id, M, Y, nodeid



--PERFECT (Markings Crash DATA)

--Runtime 10 secs
select M, Y, nodeid, 
max(Pedestrian) Pedstrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) VEH_Occupants, 
max(School_Aged) Ped_School_Aged, max(Seniors) Ped_Seniors, max(Adult) Ped_Adult
FROM
	(SELECT 
		datepart(mm,c.ACCIDENT_DT) M , datepart(yy,c.ACCIDENT_DT) Y, 
		c.NODEID,
		(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
		(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
		(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
		(case when victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
		then 1 else 0 end) School_Aged,
		(case when victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') 
		then 1 else 0 end) Seniors,
		(case when victim_age between 18 and 64 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
		then 1 else 0 end) Adult,
		c.INTEGRATION_ID
	FROM FORMS.dbo.WC_ACCIDENT_F as c
	join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
		on c.INTEGRATION_ID=i.ACCIDENT_ID
	where c.nodeid is not null 
	  and i.INJ_KILLED = 'Injured' 
	  and coalesce(c.VOID_STATUS_CD , 'N') ='N'
	  and coalesce(c.NONMV , 0) = 0) z

group by integration_id, M, Y, nodeid



select M, Y, nodeid, 
max(Pedestrian) Pedstrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) VEH_Occupants, 
max(School_Aged) Ped_School_Aged, max(Seniors) Ped_Seniors, max(Adult) Ped_Adult
FROM
	(SELECT 
		datepart(mm,c.ACCIDENT_DT) M , datepart(yy,c.ACCIDENT_DT) Y, 
		c.NODEID,
		(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
		(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
		(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
		(case when victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
		then 1 else 0 end) School_Aged,
		(case when victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') 
		then 1 else 0 end) Seniors,
		(case when victim_age between 18 and 64 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
		then 1 else 0 end) Adult,
		c.INTEGRATION_ID
	FROM FORMS.dbo.WC_ACCIDENT_F as c
	join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
		on c.INTEGRATION_ID=i.ACCIDENT_ID
	where c.nodeid is not null 
	  and i.INJ_KILLED = 'Injured' 
	  and coalesce(c.VOID_STATUS_CD , 'N') ='N'
	  and coalesce(c.NONMV , 0) = 0
	  and ACCIDENT_ID in (727118109,734418109)) z

group by integration_id, M, Y, nodeid




-- Runtime 8 secs
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
				datepart(mm,c.ACCIDENT_DT) M , datepart(yy,c.ACCIDENT_DT) Y, 
				c.NODEID,
				(case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
				(case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
				(case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
				(case when victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
				then 1 else 0 end) School_Aged,
				(case when victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') 
				then 1 else 0 end) Seniors,
				(case when victim_age between 18 and 64 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
				then 1 else 0 end) Adult,
				c.INTEGRATION_ID
			FROM FORMS.dbo.WC_ACCIDENT_F as c
			join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
			on c.INTEGRATION_ID=i.ACCIDENT_ID
			where c.nodeid is not null 
			  and i.INJ_KILLED = 'Injured' 
			  and coalesce(c.VOID_STATUS_CD , 'N') ='N'
			  and coalesce(c.NONMV , 0) = 0) z
			  --and ACCIDENT_ID in (727118109,734418109)) z

		group by integration_id, M, Y, nodeid) x

group by nodeid, M, Y


