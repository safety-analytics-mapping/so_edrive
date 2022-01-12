--cnty 6 secs
select  
case when c.SRC_COUNTY = 'NEW YORK' then 'MANHATTAN' else SRC_COUNTY end as boro, 
count(*) as inj_cnty
from [FORMS].[dbo].[WC_ACCIDENT_F] as c
join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
    on c.INTEGRATION_ID=i.ACCIDENT_ID
where year(c.ACCIDENT_DT) = 2018
    and i.INJ_KILLED = 'Injured'
    and PED_NONPED = 'Pedestrian'
    and coalesce(c.VOID_STATUS_CD , 'N') ='N'
    and c.NONMV is null
group by SRC_COUNTY 
order by SRC_COUNTY;



--cnty_city 10 secs
select coalesce(src_county, city_name) boro, count(distinct victim_num) as inj_cnty_city
from forms.dbo.wc_accident_f c
join forms.dbo.wc_accident_victim_f v
on c.integration_id = v.ACCIDENT_ID
where ped_nonped = 'Pedestrian' --and person_role_code = 'Pedestrian'
and year(c.accident_dt) = 2018
and coalesce(c.VOID_STATUS_CD , 'N') ='N'
and inj_killed = 'Injured'
--and injured_cnt > 0
group by coalesce(src_county, city_name)


--boro 7 secs
select count(v.accident_id) as inj_boro, acc.BOROUGH as boro
from [FORMS].[dbo].[WC_ACCIDENT_F] as acc
join [FORMS].[dbo].[WC_ACCIDENT_VICTIM_F] as v
on acc.integration_id=v.accident_id
where person_role_code='Pedestrian' 
and inj_killed='Injured' 
and year(acc.accident_dt)=2018
and coalesce(acc.VOID_STATUS_CD , 'N') ='N'--added 
group by acc.BOROUGH



--pct 7 secs
select CASE 
	WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 1 AND 34 THEN 'MANHATTAN'
	WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 40 AND 52 THEN 'BRONX'
	WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 60 AND 94 THEN 'BROOKLYN'
	WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 100 AND 115 THEN 'QUEENS'
	WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 120 AND 123 THEN 'STATEN ISLAND'
	else NULL end as boro, 
    count(*) as inj_pct
    from [FORMS].[dbo].[WC_ACCIDENT_F] as c
    join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
        on c.INTEGRATION_ID=i.ACCIDENT_ID
    where year(c.ACCIDENT_DT) = 2018
        and i.INJ_KILLED = 'Injured'
        and PED_NONPED = 'Pedestrian'
        and coalesce(c.VOID_STATUS_CD , 'N') ='N'
        and c.NONMV is null
   group by CASE 
	WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 1 AND 34 THEN 'MANHATTAN'
	WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 40 AND 52 THEN 'BRONX'
	WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 60 AND 94 THEN 'BROOKLYN'
	WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 100 AND 115 THEN 'QUEENS'
	WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 120 AND 123 THEN 'STATEN ISLAND'
	else NULL end


select top 100 *
from [FORMS].[dbo].[WC_ACCIDENT_F] as c 



