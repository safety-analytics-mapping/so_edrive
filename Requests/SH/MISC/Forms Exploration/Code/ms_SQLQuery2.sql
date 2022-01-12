select year(ACCIDENT_DT) as year, 
      SUM(ped) as p, 
      sum(case when age between 5 and 17 then 1 else 0 end) as school_age,
      sum(case when age between 65 and 100 then 1 else 0 end) as senior,
      SUM(bike) as b, 
      SUM(mv) as mv
from 
(SELECT distinct 
c.INTEGRATION_ID, c.ACCIDENT_DT, i.VICTIM_NUM
, case when i.PERSON_ROLE_CODE = 'Pedestrian' then 1 else 0 end as ped
, case when i.PERSON_ROLE_CODE = 'Pedestrian' then i.VICTIM_AGE else null end as age
, case when i.PED_NONPED = 'Bicyclist' then 1 else 0 end as bike
, case when i.PED_NONPED = 'Occupant' and i.PERSON_ROLE_CODE in ('Passenger', 'Driver' ,'Other') then 1 else 0 end as mv

FROM [FORMS].[dbo].[WC_ACCIDENT_F] as c
join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
on c.INTEGRATION_ID=i.ACCIDENT_ID
where coalesce(c.VOID_STATUS_CD, 'N') = 'N'
and coalesce(c.NONMV, 0) = 0
and year(c.ACCIDENT_DT) in (2017, 2018)
and i.INJ_KILLED = 'Injured' 
)
data 
group by accident_dt

!= Y

Y - Y
N - N
null - N