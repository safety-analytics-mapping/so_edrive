SELECT street, masterid, signal_type, 
       "Provide RT Ped & Bike Injuries", 
       "Provide LT Ped & Bike Injuries"
  FROM working."LTRT";



with data as(
select distinct nodeid, nys_a.crashid, nys_a.case_num, nys_a.case_yr, num_of_inj from public.nysdot_all nys_a
join public.nysdot_vehicle nys_v
on nys_a.crashid = nys_v.crashid
where accd_type_int in (1,2)
and masterid::bigint in (SELECT masterid FROM working."LTRT")
and nys_v.pre_accd_actn in ('02', '03')
and nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and nys_v.veh_typ::int not in (5,6)) 

select nodeid, sum(num_of_inj) from data
group by nodeid


with data as(
select distinct nodeid, nys_a.crashid, nys_a.case_num, nys_a.case_yr, num_of_inj from public.nysdot_all nys_a
join public.nysdot_vehicle nys_v
on nys_a.crashid = nys_v.crashid
where accd_type_int in (1,2)
and masterid::bigint in (SELECT masterid FROM working."LTRT")
and nys_v.pre_accd_actn in ('02', '03')
and nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and nys_v.veh_typ::int not in (5,6)) 

select data.nodeid, (ltrt.street1, ltrt.street2) as streets, case_num, case_yr from data
join working."LTRT" ltrt
on data.nodeid::integer = ltrt.nodeid::integer
where data.nodeid::integer in (78715, 48694, 27317, 17923, 19789, 42344, 35238, 22190, 19819)


select * from public.nysdot_all
limit 100


select * from public.nysdot_vehicle
limit 100



with data as(
select distinct nodeid, nys_a.crashid, nys_a.case_num, nys_a.case_yr, num_of_inj from public.nysdot_all nys_a
join public.nysdot_vehicle nys_v
on nys_a.crashid = nys_v.crashid
where accd_type_int in (1,2)
and masterid::bigint in (SELECT masterid FROM working."LTRT")
and nys_v.pre_accd_actn in ('02', '03')
and nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and nys_v.veh_typ::int not in (5,6)) 

select data.nodeid, (ltrt.street1, ltrt.street2) as streets, case_num, case_yr from data
join working."LTRT" ltrt
on data.nodeid::integer = ltrt.nodeid::integer
where data.nodeid in ( select nodeid from 
		(select nodeid, sum(num_of_inj) inj_count from data
		group by nodeid
		having sum(num_of_inj)  >= 2) gt2
		)

with data as(
select distinct nodeid, nys_a.crashid, num_of_inj, accd_type_int from public.nysdot_all nys_a
join public.nysdot_vehicle nys_v
on nys_a.crashid = nys_v.crashid
where accd_type_int in (1,2)
and masterid::bigint in (SELECT masterid FROM working."LTRT")
and nys_v.pre_accd_actn in ('02', '03') -- ped/bike collision
and nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and nys_v.veh_typ::int not in (5,6)) -- vehicle type ped/bike

select d.nodeid, sum(num_of_inj) inj_count,
"Provide RT Ped & Bike Injuries" RT,
"Provide LT Ped & Bike Injuries" LT 
from data d
join working."LTRT" ltrt
on d.nodeid::int = ltrt.nodeid::int
group by d.nodeid,
RT, 
LT






with data as(
select distinct nodeid, nys_a.crashid, num_of_inj, accd_type_int, pre_accd_actn from archive."2019_11_13_nysdot_all" nys_a
join archive."2019_11_13_nysdot_vehicle" nys_v
on nys_a.crashid = nys_v.crashid
where accd_type_int in (1,2) -- ped/bike collision
and nodeid::bigint in (SELECT nodeid::bigint FROM working."LTRT")
and nys_v.pre_accd_actn in ('02', '03') -- 02 making a right turn, 03 making a left turn
and nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and nys_v.veh_typ::int not in (5,6)) -- vehicle type ped/bike



select d.nodeid, num_of_inj,pre_accd_actn,
"Provide RT Ped & Bike Injuries" RT,
"Provide LT Ped & Bike Injuries" LT 
from data d
join working."LTRT" ltrt
on d.nodeid::int = ltrt.nodeid::int





with data as(
select distinct nodeid, nys_a.crashid, num_of_inj, accd_type_int, pre_accd_actn from archive."2019_11_13_nysdot_all" nys_a
join archive."2019_11_13_nysdot_vehicle" nys_v
on nys_a.crashid = nys_v.crashid
where accd_type_int in (1,2) -- ped/bike collision
and nodeid::bigint in (SELECT nodeid::bigint FROM working."LTRT")
and nys_v.pre_accd_actn in ('02', '03') -- 02 making a right turn, 03 making a left turn
and nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and nys_v.veh_typ::int not in (5,6)) -- vehicle type ped/bike

select nodeid, rt, lt, (rt_inj + lt_inj + ltrt_inj) tot_inj  from(
select nodeid, rt, lt,  
coalesce(sum(case when (rt = 'Yes' and lt = 'No' and pre_accd_actn::text = '02') then num_of_inj end),0) rt_inj,
coalesce(sum(case when (rt = 'No' and lt = 'Yes' and pre_accd_actn::text = '03') then num_of_inj end),0) lt_inj,
coalesce(sum(case when (rt = 'Yes' and lt = 'Yes') then num_of_inj end),0) ltrt_inj from(
select d.nodeid, num_of_inj,pre_accd_actn,
"Provide RT Ped & Bike Injuries" RT,
"Provide LT Ped & Bike Injuries" LT 
from data d
join working."LTRT" ltrt
on d.nodeid::int = ltrt.nodeid::int)x 
group by nodeid, rt, lt) y



with data as(
select distinct nodeid, nys_a.crashid, nys_a.case_num, nys_a.case_yr, num_of_inj, accd_type_int, pre_accd_actn from archive."2019_11_13_nysdot_all" nys_a
join archive."2019_11_13_nysdot_vehicle" nys_v
on nys_a.crashid = nys_v.crashid
where accd_type_int in (1,2) -- ped/bike collision
and nodeid::bigint in (SELECT nodeid::bigint FROM working."LTRT")
and nys_v.pre_accd_actn in ('02', '03') -- 02 making a right turn, 03 making a left turn
and nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and nys_v.veh_typ::int not in (5,6)) -- vehicle type ped/bike


select z.nodeid, (ltrt2.street1, ltrt2.street2) as streets, data.case_num, data.case_yr  from( 
select nodeid, rt, lt, (rt_inj + lt_inj + ltrt_inj) tot_inj  from(
select nodeid, rt, lt,  
coalesce(sum(case when (rt = 'Yes' and lt = 'No' and pre_accd_actn::text = '02') then num_of_inj end),0) rt_inj,
coalesce(sum(case when (rt = 'No' and lt = 'Yes' and pre_accd_actn::text = '03') then num_of_inj end),0) lt_inj,
coalesce(sum(case when (rt = 'Yes' and lt = 'Yes') then num_of_inj end),0) ltrt_inj from(
select d.nodeid, num_of_inj,pre_accd_actn,
"Provide RT Ped & Bike Injuries" RT,
"Provide LT Ped & Bike Injuries" LT 
from data d
join working."LTRT" ltrt
on d.nodeid::int = ltrt.nodeid::int)x 
group by nodeid, rt, lt)y ) z
left join data on
z.nodeid = data.nodeid
left join working."LTRT" ltrt2
on z.nodeid::int = ltrt2.nodeid::int
where tot_inj >=2



select * FROM pg_stat_activity where usename = ‘soge'

SELECT pg_terminate_backend(30265);



DOCUMENTATION
with data as(

--Here, we select all crashes and the number of injuries between the years 2013 through 2017 where the vehicle 
--was either making a left turn or a right turn and hit a bicyclist or pedestrian. All nodeids that are not 
--selected in the working."LTRT" table

select distinct 
	nodeid, nys_a.crashid, nys_a.case_num, nys_a.case_yr, num_of_inj, accd_type_int, pre_accd_actn 
from archive."2019_11_13_nysdot_all" nys_a
join archive."2019_11_13_nysdot_vehicle" nys_v 
	on nys_a.crashid = nys_v.crashid
where accd_type_int in (1,2) -- ped/bike collision
	and nodeid::bigint in (SELECT nodeid::bigint FROM working."LTRT")
	and nys_v.pre_accd_actn in ('02', '03') -- 02 making a right turn, 03 making a left turn
	and nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
	and nys_v.veh_typ::int not in (5,6) -- vehicle type ped/bike
) 

--This query sums up the total number of valid injuries for every node 
	select nodeid, rt, lt, (rt_inj + lt_inj + ltrt_inj) tot_inj  
	from(
		-- This subquery sums up all the valid injuries and groups them by nodeid.
		select nodeid, rt, lt,  
		
			-- sum of all the right turn injuries where the request at the intersection was for right turns
			coalesce(sum(case when (rt = 'Yes' and lt = 'No' and pre_accd_actn::text = '02') then num_of_inj end),0) rt_inj,
			
			-- sum of all the left turn injuries where the request at the intersection was for left turns
			coalesce(sum(case when (rt = 'No' and lt = 'Yes' and pre_accd_actn::text = '03') then num_of_inj end),0) lt_inj,

			-- sum of all the left turn and right turn injuries where the request at the intersection was for both left and right turns 
			coalesce(sum(case when (rt = 'Yes' and lt = 'Yes') then num_of_inj end),0) ltrt_inj 
			from(
				-- This subquery selects all the crashes for the nodes in the working."LTRT" table and 
				-- incicates the right turn/left turn request
				 
				select data.nodeid, num_of_inj,pre_accd_actn,
					"Provide RT Ped & Bike Injuries" RT,
					"Provide LT Ped & Bike Injuries" LT 
				from data 
				join working."LTRT" ltrt
					on data.nodeid::int = ltrt.nodeid::int
		) valid_injuries 
		group by nodeid, rt, lt
	)total_injuries



with data as(

--Here, we select all crashes and the number of injuries between the years 2013 through 2017 where the vehicle 
--was either making a left turn or a right turn and hit a bicyclist or pedestrian. All nodeids that are not 
--selected in the working."LTRT" table

select distinct 
	nodeid, nys_a.crashid, nys_a.case_num, nys_a.case_yr, num_of_inj, accd_type_int, pre_accd_actn 
from archive."2019_11_13_nysdot_all" nys_a
join archive."2019_11_13_nysdot_vehicle" nys_v 
	on nys_a.crashid = nys_v.crashid
where accd_type_int in (1,2) -- ped/bike collision
	and nodeid::bigint in (SELECT nodeid::bigint FROM working."LTRT")
	and nys_v.pre_accd_actn in ('02', '03') -- 02 making a right turn, 03 making a left turn
	and nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
	and nys_v.veh_typ::int not in (5,6) -- vehicle type ped/bike
) 


--Here, we select all crashes and the number of injuries between the years 2013 through 2017 where the vehicle 
--was either making a left turn or a right turn and hit a bicyclist or pedestrian. 

select data.nodeid, (ltrt2.street1, ltrt2.street2) as streets, data.case_num, data.case_yr  
from( 
	--This query sums up the total number of valid injuries for every node 
	select nodeid, rt, lt, (rt_inj + lt_inj + ltrt_inj) tot_inj  
	from(
		-- This subquery sums up all the valid injuries and groups them by nodeid.
		select nodeid, rt, lt,  
		
			-- sum of all the right turn injuries where the request at the intersection was for right turns
			coalesce(sum(case when (rt = 'Yes' and lt = 'No' and pre_accd_actn::text = '02') then num_of_inj end),0) rt_inj,
			
			-- sum of all the left turn injuries where the request at the intersection was for left turns
			coalesce(sum(case when (rt = 'No' and lt = 'Yes' and pre_accd_actn::text = '03') then num_of_inj end),0) lt_inj,

			-- sum of all the left turn and right turn injuries where the request at the intersection was for both left and right turns 
			coalesce(sum(case when (rt = 'Yes' and lt = 'Yes') then num_of_inj end),0) ltrt_inj 
			from(
				-- This subquery selects all the crashes for the nodes in the working."LTRT" table and 
				-- incicates the right turn/left turn request
				 
				select data.nodeid, num_of_inj,pre_accd_actn,
					"Provide RT Ped & Bike Injuries" RT,
					"Provide LT Ped & Bike Injuries" LT 
				from data 
				join working."LTRT" ltrt
					on data.nodeid::int = ltrt.nodeid::int
		) valid_injuries 
				group by nodeid, rt, lt
	)total_injuries 
)ltrt_injuries
left join data on -- joining back to data to retrieve the case_numbers and case years for each case.
ltrt_injuries.nodeid = data.nodeid
left join working."LTRT" ltrt2 -- joining with working."LTRT" table once more to grab the street names for each resultant node
on ltrt_injuries.nodeid::int = ltrt2.nodeid::int
where tot_inj >=2 -- selecting locations where total number of injuries is greater or equal to 2


























