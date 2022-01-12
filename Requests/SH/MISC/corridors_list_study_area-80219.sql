SELECT distinct id_b
FROM working.study_area sa
order by id_b ASC
--where id_b = '14ABX'
limit 100
join lion
on 



join nysdot_all nys
on
where nys.case_yr>2004 and nys.case_yr<2015
and 


select * from nysdot_all
limit 10

select * from working.study_area limit 10


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
SELECT sa.id_b,case_num, case_yr, accd_dte, num_of_fat, num_of_inj
FROM working.study_area sa
join nysdot_all nys
on sa.segmentid = nys.segmentid
where nys.nodeid is null
and nys.case_yr>2004 and nys.case_yr<2015
and id_b = '14ABK') x
where id_b = '14ABK'




select id_b, count(case_num) tot_crashes, sum(num_of_fat) tot_fat, sum(num_of_inj) tot_inj from (
SELECT sa.id_b,nys.case_num, nys.case_yr, nys.accd_dte, nys.num_of_fat, nys.num_of_inj
FROM working.study_area sa
join nysdot_all nys
on sa.segmentid = nys.segmentid
where nys.nodeid is null
and nys.case_yr>2004 and nys.case_yr<2015) x
group by x.id_b
--and num_of_fat !=0




select * FROM working.study_area sa limit 100
join 