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







select id_b, sum(tot_inj) from (

select id_b, sum(num_of_inj) tot_inj from(
--Selecting sum of all midblock injuries within study area grouped by id_b

--select id_b, sum(nys.num_of_inj) tot_inj

select distinct id_b, crashid, num_of_inj from (
select * from nysdot_all where case_yr between 2005 and 2014 and exclude = 0) nys
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

) ok
group by id_b

union all


--Selecting sum of all itx injuries within study area grouped by id_b
--select sum(tot_inj) from(
--select id_b, sum(nys.num_of_inj) tot_inj
select id_b, sum(num_of_inj) tot_inj from (
select distinct id_b, crashid, num_of_inj from (

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



