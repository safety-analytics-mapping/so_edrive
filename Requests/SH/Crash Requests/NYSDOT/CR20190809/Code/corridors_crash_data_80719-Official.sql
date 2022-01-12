select sum(c.num_of_inj) 
from nysdot_all as c
join working.study_area s
on st_dwithin(c.geom, s.wkb_geometry, 50)

where c.case_yr between 2005 and 2014 and c.exclude = 0
and s.id_b = '14ABK'



select * from working.study_area sa
where id_b = '14ABK'


select l.street, l.segmentid, l.nodeidfrom, l.nodeidto, l.mft, l.masteridfrom, l.masteridto, l.mft, st_length(l.geom) AS leng
from lion l
where mft = (select mft from lion where segmentid = '0228790')


select sum(num_of_inj) from (

select * from (
select l.street, l.segmentid,  l.mft, st_setsrid(l.geom,2263) 
from lion l
where mft = (select mft from lion where segmentid = '0228790'))x

join (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
on x.segmentid = nys.segmentid) y



--Selecting all midblock injuries from nysdot at segment 0040936

select sum(num_of_inj) from (

select * from (
select l.street, l.segmentid,  l.mft, st_setsrid(l.geom,2263) 
from lion l
where mft = (select mft from lion where segmentid = '0040936'))x

join (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
on x.segmentid = nys.segmentid) y



--Selecting all intersection injuries from nysdot at segment 0040936

select sum(num_of_inj) from (

select * from (
select  l.masteridfrom, l.masteridto, l.mft, st_setsrid(l.geom,2263) 
from lion l
where mft = (select mft from lion where segmentid = '0040936'))x

join (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
on x.masteridfrom = nys.nodeid::int

union  

select * from (
select  l.masteridfrom, l.masteridto, l.mft, st_setsrid(l.geom,2263) 
from lion l
where mft = (select mft from lion where segmentid = '0040936'))x

join (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys2
on x.masteridto = nys2.nodeid::int )y


--type check
select masteridfrom from lion where masteridfrom is not null limit 10
--type check
select nodeid::int from nysdot_all where nodeid is not null limit 10


--Selecting all mfts within idb = 14ABK

select mft, geom from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid where id_b = '14ABK')


--Selecting all masterids within idb = 14ABK

select n.nodeid, geom  from (
select masteridfrom mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid where id_b = '14ABK')


union 

select masteridto mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid where id_b = '14ABK')) t
join node n  
on t.mid = n.nodeid



--Selecting all mfts within study area
select mft, geom from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)




--Selecting all segmentids within study area grouped by id_b


select id_b, geom from(
select segmentid, mft, geom from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
) ll
join (select sa.id_b, l.mft 
      from lion l join working.study_area sa
      on l.segmentid = sa.segmentid 
      group by id_b, l.mft) id
on ll.mft = id.mft
where id_b is not null


--Selecting sum of all midblock injuries within study area grouped by id_b
select id_b, sum(nys.num_of_inj) 

from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join 

(select id_b, segmentid from(
select mft,segmentid, geom from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
) ll
join (select sa.id_b, l.mft 
      from lion l join working.study_area sa
      on l.segmentid = sa.segmentid 
      group by id_b, l.mft) id
on ll.mft = id.mft) d
on nys.segmentid = d.segmentid
where id_b is not null
group by id_b




--Selecting all masterids within study area

select n.nodeid, geom  from (
select masteridfrom mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)


union 

select masteridto mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
join node n  
on t.mid = n.nodeid



--Selecting all masterids within study area grouped by id_b


select mids.id_b,n.nodeid, geom  from (


select masteridfrom mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)

union 

select masteridto mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
join node n  
on t.mid = n.nodeid

join 
(
select id_b, l.masteridfrom mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid

union

select id_b, l.masteridto mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid
) mids
on t.mid = mids.mid







--Selecting sum of all itx injuries within study area grouped by id_b

select id_b, sum(nys.num_of_inj) 

from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join 

(select mids.id_b,n.nodeid from (
select masteridfrom mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)

union 

select masteridto mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
join node n  
on t.mid = n.nodeid
join 
(
select id_b, l.masteridfrom mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid

union

select id_b, l.masteridto mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid
) mids
on t.mid = mids.mid) mm
on nys.nodeid::int = mm.nodeid
where id_b is not null
group by mm.id_b





--Selecting sum of all injuries within study area grouped by id_b

select id_b, sum(tot_inj) from (



--Selecting sum of all midblock injuries within study area grouped by id_b
select id_b, sum(nys.num_of_inj) tot_inj

from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join 

(select id_b, segmentid from(
select mft,segmentid, geom from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
) ll
join (select sa.id_b, l.mft 
      from lion l join working.study_area sa
      on l.segmentid = sa.segmentid 
      group by id_b, l.mft) id
on ll.mft = id.mft) d
on nys.segmentid = d.segmentid
where id_b is not null
group by id_b

union all


--Selecting sum of all itx injuries within study area grouped by id_b

select id_b, sum(nys.num_of_inj) tot_inj

from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join 

(select mids.id_b,n.nodeid from (
select masteridfrom mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)

union 

select masteridto mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
join node n  
on t.mid = n.nodeid
join 
(
select id_b, l.masteridfrom mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid

union

select id_b, l.masteridto mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid
) mids
on t.mid = mids.mid) mm
on nys.masterid::int = mm.nodeid
where id_b is not null
group by mm.id_b

) g

group by id_b








--Test for 19BSI
select id_b ,sum(num_of_inj) from (
select * from (

--Selecting sum of all midblock injuries within study area grouped by id_b
select id_b, crashid, num_of_inj, nys.loc, nys.geom--sum(nys.num_of_inj) tot_inj

from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join 

(select id_b, ll.segmentid from(
select mft,segmentid, geom from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
) ll
join (select sa.id_b, l.mft 
      from lion l join working.study_area sa
      on l.segmentid = sa.segmentid 
      group by id_b, l.mft) id
on ll.mft = id.mft) d
on nys.segmentid = d.segmentid
where id_b is not null
group by id_b, crashid, num_of_inj, nys.loc, nys.geom

union all


--Selecting sum of all itx injuries within study area grouped by id_b

select id_b, crashid, num_of_inj, nys.loc, nys.geom

from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join 

(select mids.id_b,n.nodeid from (
select masteridfrom mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)

union 

select masteridto mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
join node n  
on t.mid = n.nodeid
join 
(
select id_b, l.masteridfrom mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid

union

select id_b, l.masteridto mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid
) mids
on t.mid = mids.mid) mm
on nys.masterid::int = mm.nodeid
where id_b is not null
group by mm.id_b, crashid,  num_of_inj, nys.loc, nys.geom

) g

where id_b= '17AQ'
group by id_b, crashid,  num_of_inj, loc, geom

)  h
group by id_b






select * from nysdot_all nys
where crashid in (
'342203382011',
 '314075952005',
 '326075542008',
 '325967182008',
 '353288662014', --
 '314060612005',
 '314693782005',
 '315358732005',
 '316720672005',
 '316738642005'
 )



select * from nysdot_all nys
where crashid in (
'315782512005',
 '318743922006',
 '335588252010',
 '350278642013',
 '348817732013',
 '344990952012',
 '351546302013',
 '344267742012',
 '318020402006',
 '317123182006',
 '321284382007',
 '326673952008',
 '331388302009',
 '324282352007',
 '317252952005',
 '319085202006',
 '342756112011',
 '315854032005',
 '336465172010',
 '341879682011',
 '350786652013',
 '322483872007',
 '336071262010',
 '317284842005',
 '346571572012',
 '329534942009',
 '323663512007',
 '322884522007',
 '337238482010',
 '319538402006',
 '319691102006',
 '331032012009',
 '316277012005',
 '324566762007',
 '318098062006',
 '352156592014',
 '322122362007',
 '321331522007',
 '352278732014',
 '327664712008',
 '317534182006',
 '316370452005',
 '319754262006',
 '322877342007',
 '347023682012',
 '345650132012',
 '329354612008',
 '314541722005',
 '330203272009',
 '318521472006',
 '330958132009',
 '351494002013',
 '318975752006',
 '329354462008',
 '341813982011',
 '332325482009',
 '327063032008',
 '319483762006',
 '339634262011',
 '346323002012',
 '318331402006',
 '353494122014',
 '319618022006',
 '322884292007',
 '321284502007',
 '326066262008',
 '344280682012',
 '348796152013',
 '321282812007',
 '344149022012',
 '348796092013',
 '321580272007',
 '333822112010',
 '336165812010',
 '351560562013',
 '333839912010',
 '344222492012',
 '321769102007',
 '323007342007',
 '347497602013',
 '331034902009',
 '334385992010',
 '341360772011',
 '314354602005',
 '355879062014',
 '348849802013',
 '349352062013',
 '339090472011',
 '356478632014',
 '322250822007',
 '326399972008',
 '314785032005',
 '345652042012',
 '315491322005',
 '335146972010',
 '346303172012',
 '352225022014',
 '331586182009',
 '336507882010',
 '334361432010',
 '352984282014',
 '324687022007',
 '322199232007',
 '314108692005',
 '322732202007',
 '352056482014',
 '353493892014',
 '348198092013')


select * from nysdot_all
where case_yr between 2005 and 2014
and nodeid::int = 46668




--1st Query that WORKS


select id_b, sum(tot_inj) from (

select id_b, sum(num_of_inj) tot_inj from(

--Selecting sum of all midblock injuries within study area grouped by id_b

select distinct id_b, case_num, ext_of_inj, crashid, num_of_inj from (
select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join 
(select id_b, segmentid from(
 select mft,segmentid, geom from lion 
 where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
) ll
join 
(select sa.id_b, l.mft 
 from lion l join working.study_area sa
 on l.segmentid = sa.segmentid 
 group by id_b, l.mft) id
 
on ll.mft = id.mft) d
on nys.segmentid = d.segmentid
where id_b is not null

) ok
group by id_b

union all


--Selecting sum of all itx injuries within study area grouped by id_b
--select sum(tot_inj) from(
--select id_b, sum(nys.num_of_inj) tot_inj
select id_b, sum(num_of_inj) tot_inj from (
select distinct id_b, case_num, ext_of_inj, crashid, num_of_inj  from (

select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join 

(select mids.id_b,n.nodeid from (
select masteridfrom mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)

union 

select masteridto mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
join node n  
on t.mid = n.nodeid
join 
(
select id_b, l.masteridfrom mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid

union

select id_b, l.masteridto mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid
) mids
on t.mid = mids.mid) mm
on nys.masterid::int = mm.nodeid
where id_b is not null) ok
group by id_b


) g
--where id_b = '17AM'
group by id_b








--Query 2 including all data except fatality 

select id_b, 
coalesce(sum(tot_crashes),0) tot_crashes, 
coalesce(sum(tot_inj),0) tot_inj, 
coalesce(sum(a),0) a,
coalesce(sum(b),0) b,
coalesce(sum(c),0) c,
coalesce(sum(ksi),0) ksi,
coalesce(sum(ped),0) ped,
coalesce(sum(bike),0) bike
 from (

select id_b, 
count(case_num) tot_crashes, 
sum(num_of_inj) tot_inj ,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(ext_of_inj::text)) AS KSI,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(

--Selecting sum of all midblock injuries within study area grouped by id_b

select distinct id_b, case_num, ext_of_inj, crashid, num_of_inj, accd_type_int, loc from (
select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join 
(select id_b, segmentid from(
 select mft,segmentid, geom from lion 
 where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
) ll
join 
(select sa.id_b, l.mft 
 from lion l join working.study_area sa
 on l.segmentid = sa.segmentid 
 group by id_b, l.mft) id
 
on ll.mft = id.mft) d
on nys.segmentid = d.segmentid
where id_b is not null

) ok
group by id_b

union all


--Selecting sum of all itx injuries within study area grouped by id_b
--select sum(tot_inj) from(
--select id_b, sum(nys.num_of_inj) tot_inj

select id_b, 
count(case_num) tot_crashes, 
sum(num_of_inj) tot_inj ,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(ext_of_inj::text)) AS KSI,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(

--Selecting sum of all midblock injuries within study area grouped by id_b

select distinct id_b, case_num, ext_of_inj, crashid, num_of_inj, accd_type_int, loc from (

select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join 
(select mids.id_b,n.nodeid from (
select masteridfrom mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)

union 

select masteridto mid from lion 
where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
join node n  
on t.mid = n.nodeid
join 
(select id_b, l.masteridfrom mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid

union

select id_b, l.masteridto mid
from lion l 
join working.study_area sa on l.segmentid = sa.segmentid
) mids
on t.mid = mids.mid) mm
on nys.masterid::int = mm.nodeid
where id_b is not null) ok
group by id_b


) g
--where id_b = '17AM'
group by id_b











--2. Query 2 including all data except fatality Edited  

select id_b, 
sum(tot_crashes) tot_crashes, 
sum(tot_inj) tot_inj, 
sum(a) a,
sum(b) b,
sum(c) c,
sum(ksi) ksi,
sum(ped) ped,
sum(bike) bike 



from (

--Selecting sum of all midblock injuries within study area grouped by id_b

select id_b, 
count(case_num) tot_crashes, 
sum(num_of_inj) tot_inj ,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(ext_of_inj::text)) AS KSI,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(

select distinct id_b, case_num, ext_of_inj, crashid, num_of_inj, accd_type_int, loc from (
select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join(
	select id_b, segmentid 
	from(select mft,segmentid, geom from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) ll
	     
	join(select sa.id_b, l.mft 
	     from lion l join working.study_area sa
	     on l.segmentid = sa.segmentid 
	     group by id_b, l.mft) id
	     on ll.mft = id.mft) d
	     
on nys.segmentid = d.segmentid
where id_b is not null
)corr
group by id_b


union all

--Selecting sum of all itx injuries within study area grouped by id_b

select id_b, 
count(case_num) tot_crashes, 
sum(num_of_inj) tot_inj ,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(ext_of_inj::text)) AS KSI,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(

select distinct id_b, case_num, ext_of_inj, crashid, num_of_inj, accd_type_int, loc 
from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join (
	select mids.id_b,t.mid 
	from(select masteridfrom mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
	     union 
	     select masteridto mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
	     
	join(select id_b, l.masteridfrom mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid
	     union
	     select id_b, l.masteridto mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid) mids	
        on t.mid = mids.mid) mm
        
on nys.masterid::int = mm.mid
where id_b is not null
) itx
group by id_b

) corr_itx
--where id_b = '17AM'
group by id_b



--Fatalities

select id_b,count(id_) from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
join(
	select id_b, segmentid 
	from(select mft,segmentid, geom from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) ll
	     
	join(select sa.id_b, l.mft 
	     from lion l join working.study_area sa
	     on l.segmentid = sa.segmentid 
	     group by id_b, l.mft) id
	     on ll.mft = id.mft) d
on f.segmentid = d.segmentid
group by id_b


select id_b,count(id_) from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
join (
	select mids.id_b,t.mid 
	from(select masteridfrom mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
	     union 
	     select masteridto mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
	     
	join(select id_b, l.masteridfrom mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid
	     union
	     select id_b, l.masteridto mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid) mids	
        on t.mid = mids.mid) mm
        
on f.segmentid::int = mm.mid
group by id_b



--3. 


select id_b, 
sum(tot_crashes) tot_crashes, 
sum(tot_inj) tot_inj, 
sum(a) a,
sum(b) b,
sum(c) c,
sum(ksi) ksi,
sum(ped) ped,
sum(bike) bike 


from (

--Selecting sum of all midblock injuries within study area grouped by id_b

select id_b, 
count(case_num) tot_crashes, 
count(id_) tot_fat,
sum(num_of_inj) tot_inj ,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(ext_of_inj::text)) AS KSI,
ABS(sum((num_of_fat + num_of_inj)-length(TRIM(ext_of_inj::text)))) UNK,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(

select distinct id_b, case_num, f.id_,num_of_fat, ext_of_inj, crashid, num_of_inj, accd_type_int, nys.loc from (
select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join(
	select id_b, segmentid 
	from(select mft,segmentid, geom from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) ll
	     
	join(select sa.id_b, l.mft 
	     from lion l join working.study_area sa
	     on l.segmentid = sa.segmentid 
	     group by id_b, l.mft) id
	     on ll.mft = id.mft) d
	     
on nys.segmentid = d.segmentid
left join (select * from fatality_nycdot_current where yr>2004 and yr<2014) f
on d.segmentid = f.segmentid
where id_b is not null
)corr
group by id_b


union all

--Selecting sum of all itx injuries within study area grouped by id_b

select id_b, 
count(case_num) tot_crashes,
coalesce(id_,0) tot_fat,
sum(num_of_inj) tot_inj,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(ext_of_inj::text)) AS KSI,
ABS(sum((num_of_fat + num_of_inj)-length(TRIM(ext_of_inj::text)))) UNK,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(
select test1.id_b, case_num, id_ , ext_of_inj, crashid, num_of_inj, num_of_fat, accd_type_int, loc from (
select distinct id_b, case_num, ext_of_inj, crashid, num_of_inj, num_of_fat, accd_type_int, nys.loc 
from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join (
	select mids.id_b,t.mid 
	from(select masteridfrom mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
	     union 
	     select masteridto mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
	     
	join(select id_b, l.masteridfrom mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid
	     union
	     select id_b, l.masteridto mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid) mids	
        on t.mid = mids.mid) mm
        
on nys.masterid::int = mm.mid
where id_b is not null) test1
left join
(select id_b, count(id_) id_ from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
join (
	select mids.id_b,t.mid 
	from(select masteridfrom mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
	     union 
	     select masteridto mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
	     
	join(select id_b, l.masteridfrom mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid
	     union
	     select id_b, l.masteridto mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid) mids	
        on t.mid = mids.mid) mm
        
on f.segmentid::int = mm.mid
group by id_b) test2
on test1.id_b = test2.id_b
) itx
group by id_b, id_

) corr_itx
--where id_b = '17AM'
group by id_b






--WORKING CODE FOR CORR CRASH DETAILS & ITX CRASH DETAILS ( OFF ON THE FATALITY COUNTS



--WORKING CONCISE CODE FOR ALL DETAILS FOR Segments 

select id_b, 
sum(tot_crashes) tot_crashes,
sum(tot_fat) tot_fat, 
sum(tot_inj) tot_inj, 
sum(a) a,
sum(b) b,
sum(c) c,
sum(ksi) ksi,
sum(ped) ped,
sum(bike) bike 


from (
select * from (
with data as(	
select id_b, segmentid 
from(select mft,segmentid, geom from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) ll
     
join(select sa.id_b, l.mft 
     from lion l join working.study_area sa
     on l.segmentid = sa.segmentid 
     group by id_b, l.mft) id
     on ll.mft = id.mft)


select x.id_b, 
count(case_num) tot_crashes, 
coalesce(id_,0) tot_fat,
sum(num_of_inj) tot_inj ,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
ABS(sum((num_of_fat + num_of_inj)-length(TRIM(ext_of_inj::text)))) UNK,
coalesce(id_,0) + sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS KSI,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(

select distinct id_b, case_num, ext_of_inj, crashid, num_of_fat, num_of_inj, accd_type_int, nys.loc 
from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
      join data on nys.segmentid = data.segmentid)x

left join(select id_b,count(id_) id_ from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
	  join data on f.segmentid = data.segmentid group by id_b)y
on x.id_b = y.id_b
where x.id_b is not null
group by x.id_b, id_
) corr

union 

--WORKING CONCISE CODE FOR ALL DETAILS FOR ITX
select * from (
with data as(	

select mids.id_b,t.mid 
from(select masteridfrom mid from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
     union 
     select masteridto mid from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
     
join(select id_b, l.masteridfrom mid
     from lion l 
     join working.study_area sa on l.segmentid = sa.segmentid
     union
     select id_b, l.masteridto mid
     from lion l 
     join working.study_area sa on l.segmentid = sa.segmentid) mids	
on t.mid = mids.mid)

select x.id_b, 
count(crashid) tot_crashes,
coalesce(id_,0) tot_fat,
sum(num_of_inj) tot_inj,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
coalesce(id_,0) + sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS KSI,
ABS(sum((num_of_fat + num_of_inj)-length(TRIM(ext_of_inj::text)))) UNK,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(
select distinct id_b, case_num, ext_of_inj, crashid, num_of_inj, num_of_fat, accd_type_int, nys.loc 
from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
      join data on nys.masterid::int = data.mid) x
left join(select id_b,count(id_) id_ from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
          join data on f.nodeid::int = data.mid group by id_b)y
on x.id_b = y.id_b
where x.id_b is not null
group by x.id_b, id_
)itx
) corr_itx
group by id_b




--FIXED FOR CORRECT FATALITY COUNT
select id_b, count (id_) from (
select distinct id_b, id_ from (
select mids.id_b,t.mid, t.nodeid
from(select nodeidfrom::int nodeid, masteridfrom mid from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
     union 
     select nodeidto::int nodeidto, masteridto mid from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
     
join(select id_b, l.masteridfrom mid
     from lion l 
     join working.study_area sa on l.segmentid = sa.segmentid
     union
     select id_b, l.masteridto mid
     from lion l 
     join working.study_area sa on l.segmentid = sa.segmentid) mids	
on t.mid = mids.mid
--where mids.mid::int=43069
) data
join(select * from fatality_nycdot_current where yr between 2005 and 2014) f
on f.nodeid::int = data.nodeid) x --where id_b = '14CBX') 
group by id_b







--THIS CODE FINALLY COMPLETELY WORKS


select id_b, 
sum(tot_crashes) tot_crashes,
sum(tot_fat) tot_fat, 
sum(tot_inj) tot_inj, 
sum(a) a,
sum(b) b,
sum(c) c,
sum(ksi) ksi,
sum(unk) unk,
sum(ped) ped,
sum(bike) bike 


from (
select * from (
with data as(	
select id_b, segmentid 
from(select mft,segmentid, geom from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) ll
     
join(select sa.id_b, l.mft 
     from lion l join working.study_area sa
     on l.segmentid = sa.segmentid 
     group by id_b, l.mft) id
     on ll.mft = id.mft)


select x.id_b, 
count(crashid,) tot_crashes, 
coalesce(id_,0) tot_fat,
sum(num_of_inj) tot_inj ,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
ABS(sum((num_of_fat + num_of_inj)-length(TRIM(ext_of_inj::text)))) UNK,
coalesce(id_,0) + sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS KSI,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(

select distinct id_b, crashid, ext_of_inj, num_of_fat, num_of_inj, accd_type_int, nys.loc 
from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
      join data on nys.segmentid = data.segmentid)x

left join(select id_b,count(id_) id_ from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
	  join data on f.segmentid = data.segmentid group by id_b)y
on x.id_b = y.id_b
where x.id_b is not null
group by x.id_b, id_
) corr

union 

--WORKING CONCISE CODE FOR ALL DETAILS FOR ITX
select * from (
with data as(	

select mids.id_b,t.mid, t.nodeid
from(select nodeidfrom::int nodeid, masteridfrom mid from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
     union 
     select nodeidto::int nodeid, masteridto mid from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
     
join(select id_b, l.masteridfrom mid
     from lion l 
     join working.study_area sa on l.segmentid = sa.segmentid
     union
     select id_b, l.masteridto mid
     from lion l 
     join working.study_area sa on l.segmentid = sa.segmentid) mids	
on t.mid = mids.mid)

select x.id_b, 
count(crashid) tot_crashes,
coalesce (id_,0) tot_fat,
sum(num_of_inj) tot_inj,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
coalesce(id_,0) + sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS KSI,
ABS(sum((num_of_fat + num_of_inj)-length(TRIM(ext_of_inj::text)))) UNK,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(
select distinct id_b, crashid, ext_of_inj, num_of_inj, num_of_fat, accd_type_int, nys.loc 
from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
      join data on nys.masterid::int = data.mid) x
left join(select id_b, count(id_) id_ from (
	  select distinct id_b, id_ from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
          join data on f.nodeid::int = data.nodeid)ok group by id_b)y
on x.id_b = y.id_b
where x.id_b is not null
group by x.id_b, id_
)itx
) corr_itx
group by id_b








--ALL ITX AND SEGMENT INJURIES AND FATALITIES

--SEG INJ

with data as(	
select id_b, segmentid 
from(select mft,segmentid, geom from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) ll
     
join(select sa.id_b, l.mft 
     from lion l join working.study_area sa
     on l.segmentid = sa.segmentid 
     group by id_b, l.mft) id
     on ll.mft = id.mft)

select distinct id_b, crashid, ext_of_inj, num_of_fat, num_of_inj, accd_type_int, nys.loc , geom
from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
      join data on nys.segmentid = data.segmentid


--SEG FAT

with data as(	
select id_b, segmentid 
from(select mft,segmentid, geom from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) ll
     
join(select sa.id_b, l.mft 
     from lion l join working.study_area sa
     on l.segmentid = sa.segmentid 
     group by id_b, l.mft) id
     on ll.mft = id.mft)

select id_b, id_, geom from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
	  join data on f.segmentid = data.segmentid group by id_b



--ITX INJ

with data as(	

select mids.id_b,t.mid, t.nodeid
from(select nodeidfrom::int nodeid, masteridfrom mid from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
     union 
     select nodeidto::int nodeid, masteridto mid from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
     
join(select id_b, l.masteridfrom mid
     from lion l 
     join working.study_area sa on l.segmentid = sa.segmentid
     union
     select id_b, l.masteridto mid
     from lion l 
     join working.study_area sa on l.segmentid = sa.segmentid) mids	
on t.mid = mids.mid)


select distinct id_b, case_num, ext_of_inj, crashid, num_of_inj, num_of_fat, accd_type_int, nys.loc, geom
from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
      join data on nys.masterid::int = data.mid


--ITX FAT

with data as(	

select mids.id_b,t.mid, t.nodeid
from(select nodeidfrom::int nodeid, masteridfrom mid from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
     union 
     select nodeidto::int nodeid, masteridto mid from lion 
     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
     
join(select id_b, l.masteridfrom mid
     from lion l 
     join working.study_area sa on l.segmentid = sa.segmentid
     union
     select id_b, l.masteridto mid
     from lion l 
     join working.study_area sa on l.segmentid = sa.segmentid) mids	
on t.mid = mids.mid)


	  select distinct id_b, id_,geom from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
          join data on f.nodeid::int = data.nodeid










































--INCORRECT BELOW



select id_b, 
count(case_num) tot_crashes,
coalesce(id_,0) tot_fat,
sum(num_of_inj) tot_inj,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(ext_of_inj::text)) AS KSI,
ABS(sum((num_of_fat + num_of_inj)-length(TRIM(ext_of_inj::text)))) UNK,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(
select test1.id_b, case_num, id_ , ext_of_inj, crashid, num_of_inj, num_of_fat, accd_type_int, loc from (
select distinct id_b, case_num, ext_of_inj, crashid, num_of_inj, num_of_fat, accd_type_int, nys.loc 
from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join 
        
on nys.masterid::int = mm.mid
where id_b is not null) test1
left join
(select id_b, count(id_) id_ from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
join (
	select mids.id_b,t.mid 
	from(select masteridfrom mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
	     union 
	     select masteridto mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
	     
	join(select id_b, l.masteridfrom mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid
	     union
	     select id_b, l.masteridto mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid) mids	
        on t.mid = mids.mid) mm
        
on f.segmentid::int = mm.mid
group by id_b) test2
on test1.id_b = test2.id_b
) itx
group by id_b, id_









--Test

select id_b, 
count(case_num) tot_crashes,
coalesce(id_,0) tot_fat,
sum(num_of_inj) tot_inj,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(ext_of_inj::text)) AS KSI,
ABS(sum((num_of_fat + num_of_inj)-length(TRIM(ext_of_inj::text)))) UNK,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(
select test1.id_b, case_num, id_ , ext_of_inj, crashid, num_of_inj, num_of_fat, accd_type_int, loc from (
select distinct id_b, case_num, ext_of_inj, crashid, num_of_inj, num_of_fat, accd_type_int, nys.loc 
from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join (
	select mids.id_b,t.mid 
	from(select masteridfrom mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
	     union 
	     select masteridto mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
	     
	join(select id_b, l.masteridfrom mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid
	     union
	     select id_b, l.masteridto mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid) mids	
        on t.mid = mids.mid) mm
        
on nys.masterid::int = mm.mid
where id_b is not null) test1
left join
select id_b, count(id_) id_ from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
join (
	select mids.id_b,t.mid 
	from(select masteridfrom mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
	     union 
	     select masteridto mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
	     
	join(select id_b, l.masteridfrom mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid
	     union
	     select id_b, l.masteridto mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid) mids	
        on t.mid = mids.mid) mm
        
on f.segmentid::int = mm.mid
group by id_b) test2
on test1.id_b = test2.id_b
) itx
group by id_b, id_


-- COMPLETE WORKNG CODE FOR ALL CRASH DATA AND FATALITIES

select id_b, 
crashid tot_crashes, 
id_ tot_fat,
sum(num_of_inj) tot_inj ,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) AS A,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text))) AS B,
sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text))) AS C,
sum(length(ext_of_inj::text)) AS KSI,
sum(case when accd_type_int= 1 then num_of_inj else 0 end) as Ped,
sum(case when accd_type_int= 2 then num_of_inj else 0 end) as Bike

from(

select distinct id_b, crashid, mid, id_, ext_of_inj,  num_of_inj, accd_type_int, loc 
from (select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
join (	select id_b, mid, count(id_) id_ from (
	select mids.id_b,t.mid 
	from(select masteridfrom mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
	     union 
	     select masteridto mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
	     
	join(select id_b, l.masteridfrom mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid
	     union
	     select id_b, l.masteridto mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid) mids	
        on t.mid = mids.mid) t1 
        left join(select id_, segmentid from (select * from fatality_nycdot_current where yr between 2005 and 2014) x) t2
	on t2.segmentid::int = t1.mid
	--where id_b = '14AM'
	group by id_b,mid
	order by id_b,mid )mm
on nys.masterid::int = mm.mid
where id_b is not null
and id_b = '14AM'
and id_=1
) itx
group by id_b,crashid,id_







select id_b, id_ from (select * from fatality_nycdot_current where yr between 2005 and 2014) f
join (
	select mids.id_b,t.mid 
	from(select masteridfrom mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)
	     union 
	     select masteridto mid from lion 
	     where mft in (select l.mft from lion l join working.study_area sa on l.segmentid = sa.segmentid)) t
	     
	join(select id_b, l.masteridfrom mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid
	     union
	     select id_b, l.masteridto mid
	     from lion l 
	     join working.study_area sa on l.segmentid = sa.segmentid) mids	
        on t.mid = mids.mid) mm
        
on f.segmentid::int = mm.mid
where id_b = '14AM'
group by id_b, id_

