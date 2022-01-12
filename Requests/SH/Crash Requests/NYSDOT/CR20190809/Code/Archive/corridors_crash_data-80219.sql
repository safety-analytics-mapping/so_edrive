SELECT distinct id_b
FROM working.study_area sa
order by id_b ASC
--where id_b = '14ABX'
limit 100
join lion
on 


SELECT *
FROM working.study_area limit 100


select * from lion limit 10

where id_b = '14ABK'

join nysdot_all nys
on
where nys.case_yr>2004 and nys.case_yr<2015
and 


select distinct ped_actn from nysdot_all

limit 10

select * from working.study_area limit 10


select distinct loc from nysdot_all


limit 10


select * from nysdot_all nys  
where nys.segmentid = '0078205'
--where nys.segmentid = 0055979


st_setsrid(corr.geom,2263)

select * from lion limit 1

select geom from nysdot_all
limit 1


select * from nysdot_all
where nodeid is null
limit 1

select geom from lion
limit 1

Select count(case_num),sum(num_of_inj), sum(num_of_fat) from(
SELECT sa.id_b, case_num, case_yr, accd_dte, num_of_inj, nys.ext_of_inj
FROM working.study_area sa
join nysdot_all nys
on sa.segmentid = nys.segmentid
where nys.nodeid is null
--and nys.case_yr>2004 and nys.case_yr<2015
and id_b = '14ABX') x
where id_b = '14ABK'



--CRASH INFO
select id_b, count(case_num) tot_crashes, sum(num_of_fat) tot_fat, sum(num_of_inj) tot_inj from (
SELECT sa.id_b,nys.case_num, nys.case_yr, nys.accd_dte, nys.num_of_fat, nys.num_of_inj
FROM working.study_area sa
join nysdot_all nys
on sa.segmentid = nys.segmentid
and nys.case_yr>2004 and nys.case_yr<2015) x
group by x.id_b
having sum(num_of_fat)>0
--and num_of_fat !=0


select id_b, count(nys.case_num) tot_crashes, sum(num_of_inj) tot_inj 
FROM working.study_area sa
join nysdot_all nys
on sa.segmentid = nys.segmentid
and nys.case_yr>2004 and nys.case_yr<2015
group by id_b
having sum(num_of_fat)>0



--TEST
select * from fatality_nycdot_current where segmentid is not null limit 10


--FATALITY

select id_b, sum(inj) FROM working.study_area sa
join fatality_nycdot_current f
on sa.segmentid = f.segmentid
where f.yr>2004 and f.yr<2015
group by id_b




--SEVERITY

SELECT id_b, 
sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(nys.ext_of_inj::text)) AS KSI,
ABS(sum(length(TRIM(nys.ext_of_inj::text))-(nys.num_of_fat + nys.num_of_inj))) UNK
FROM working.study_area sa
join public.nysdot_all nys
on sa.segmentid = nys.segmentid
where nys.ext_of_inj is not null
and nys.case_yr>2004 and nys.case_yr<2015
group by id_b


SELECT  sum(length(nys.ext_of_inj::text)-(nys.num_of_fat + nys.num_of_inj)) UNK


select(5+9)




select distinct ext_of_inj from nysdot_all
limit 10




SELECT sa.id_b,
sum(case when nys.accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when nys.accd_type_int= 2 then num_of_inj else 0 end) as Bike,
sum(case when nys.accd_type_int= 3 then num_of_inj else 0 end) as MVO
FROM working.study_area sa
join nysdot_all nys
on sa.segmentid = nys.segmentid
where nys.nodeid is null
and nys.case_yr>2004 and nys.case_yr<2015
and nys.accd_type_int = 1
and id_b = '14CSI'
group by sa.id_b


SELECT  length(TRIM(nys.ext_of_inj::text)), num_of_fat, num_of_inj, nys.ext_of_inj
FROM working.study_area sa
join nysdot_all nys
on sa.segmentid = nys.segmentid
where nys.case_yr>2004 and nys.case_yr<2015
and id_b = '14CSI'


select sa.id_b,case_num, case_yr, accd_dte, num_of_inj, nys.ext_of_inj
FROM working.study_area sa
join nysdot_all nys
on sa.segmentid = nys.segmentid

select * from nysdot_all nys where nys.mft is not null limit 10





sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(nys.ext_of_inj::text)) AS KSI,
ABS(sum(length(TRIM(nys.ext_of_inj::text))-(nys.num_of_fat + nys.num_of_inj))) UNK,


select id_b, 
coalesce(sum(tot_crashes),0) tot_crashes, 
coalesce(sum(tot_fat),0) tot_fat, 
coalesce(sum(tot_inj),0) tot_inj, 
coalesce(sum(a),0) a,
coalesce(sum(b),0) b,
coalesce(sum(c),0) c,
coalesce(sum(ksi),0) ksi,
coalesce(sum(unk),0) unk,
coalesce(sum(ped),0) ped,
coalesce(sum(bike),0) bike

from( 

(--Corridors
select id_b,
count(nys.case_num) tot_crashes,
sum(f.inj) tot_fat,
sum(nys.num_of_inj) tot_inj, 
sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(nys.ext_of_inj::text)) AS KSI,
ABS(sum((nys.num_of_fat + nys.num_of_inj)-length(TRIM(nys.ext_of_inj::text)))) UNK,
sum(case when nys.accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when nys.accd_type_int= 2 then num_of_inj else 0 end) as Bike
FROM working.study_area sa
left join (select * from nysdot_all where case_yr>2004 and case_yr<2015) nys
on sa.segmentid = nys.segmentid
left join (select * from fatality_nycdot_current where yr>2004 and yr<2015) f
on sa.segmentid = f.segmentid
group by id_b
order by id_b
)

union

(--Intersections
select id_b,
count(nys.case_num) tot_crashes,
sum(f.inj) tot_fat,
sum(nys.num_of_inj) tot_inj, 
sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(nys.ext_of_inj::text) - length(replace(nys.ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(nys.ext_of_inj::text)) AS KSI,
ABS(sum((nys.num_of_fat + nys.num_of_inj)-length(TRIM(nys.ext_of_inj::text)))) UNK,
sum(case when nys.accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when nys.accd_type_int= 2 then num_of_inj else 0 end) as Bike
from (
SELECT id_b, nodeidfrom nodeid
FROM working.study_area sa 
join lion l
on sa.segmentid = l.segmentid 
union
SELECT id_b, nodeidto nodeid
FROM working.study_area sa 
join lion l
on sa.segmentid = l.segmentid ) x
left join (select * from nysdot_all where case_yr>2004 and case_yr<2015) nys
on x.nodeid = nys.nodeid
left join (select * from fatality_nycdot_current where yr>2004 and yr<2015) f
on x.nodeid = f.nodeid
group by id_b
order by id_b
 )) tbl
group by id_b


