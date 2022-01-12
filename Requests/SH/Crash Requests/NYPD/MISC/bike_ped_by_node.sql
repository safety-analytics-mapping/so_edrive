

--Bike injuries by node (for the whole city) 2017-present

select count(VICTIM_NUM)
from forms.dbo.wc_accident_f c
join forms.dbo.wc_accident_victim_f v
on c.integration_id = v.ACCIDENT_ID
where ped_nonped = 'Bicyclist' 
and person_role_code in ('Passenger', 'Driver')
and v.INJ_KILLED = 'Injured'
and year(c.accident_dt) > 2016
and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
and coalesce(nonmv, 0) = 1

select distinct PERSON_ROLE_CODE
from forms.dbo.wc_accident_victim_f


select top 10 coalesce(NODEID,LION_NODE_NUMBER)
from forms.dbo.wc_accident_f 
where coalesce(NODEID,LION_NODE_NUMBER) is not null
order by coalesce(NODEID,LION_NODE_NUMBER)


select top 10 coalesce(c.NODEID,c.LION_NODE_NUMBER), count(VICTIM_NUM)
from forms.dbo.wc_accident_f c
join forms.dbo.wc_accident_victim_f v
on c.integration_id = v.ACCIDENT_ID
where ped_nonped = 'Bicyclist' 
and person_role_code in ('Passenger', 'Driver')
and v.INJ_KILLED = 'Injured'
and year(c.accident_dt) > 2016
and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
and coalesce(nonmv, 0) = 1
and coalesce(NODEID,LION_NODE_NUMBER) is not null
group by coalesce(c.NODEID,c.LION_NODE_NUMBER)


select sum(injury_cnt) bike_injuries from(
select coalesce(c.NODEID,c.LION_NODE_NUMBER) nodeid, count(VICTIM_NUM) injury_cnt
from forms.dbo.wc_accident_f c
join forms.dbo.wc_accident_victim_f v
on c.integration_id = v.ACCIDENT_ID
where ped_nonped = 'Bicyclist' 
and person_role_code in ('Passenger', 'Driver')
and v.INJ_KILLED = 'Injured'
and year(c.accident_dt) > 2016
and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
and coalesce(nonmv, 0) = 0
and coalesce(NODEID,LION_NODE_NUMBER) is not null
group by coalesce(c.NODEID,c.LION_NODE_NUMBER)
) x


select VICTIM_NUM 
from forms.dbo.wc_accident_f c
join forms.dbo.wc_accident_victim_f v
on c.integration_id = v.ACCIDENT_ID
where ped_nonped = 'Bicyclist' 
and person_role_code in ('Passenger', 'Driver')
and v.INJ_KILLED = 'Injured'
and year(c.accident_dt) > 2016
and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
and coalesce(nonmv, 0) = 1
and NODEID = 14137


select *
from forms.dbo.wc_accident_f c
join forms.dbo.wc_accident_victim_f v
on c.integration_id = v.ACCIDENT_ID
where ped_nonped = 'Bicyclist' 
and person_role_code in ('Passenger', 'Driver')
and v.INJ_KILLED = 'Injured'
and year(c.accident_dt) > 2016
and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
and coalesce(nonmv, 0) = 1
and NODEID = 14137