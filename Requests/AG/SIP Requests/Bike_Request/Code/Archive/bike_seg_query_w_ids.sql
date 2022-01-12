
-- Bike lanes by type by year
-- in_sip   | 'SIP', 'Completed SIP'
/*
select sip_year, 
sum(case when question = 'Protected' then ft else 0 end)/5280.0 as "Protected",
sum(case when question = 'Curbside' then ft else 0 end)/5280.0 as "Curbside",
sum(case when question = 'Buffered' then ft else 0 end)/5280.0 as "Buffered",
sum(case when question = 'Standard' then ft else 0 end)/5280.0 as "Standard",
sum(case when question = 'Sharrows' then ft else 0 end)/5280.0 as "Sharrows",
sum(case when question in ('Parking', 'Bike WPL') then ft else 0 end)/5280.0 as "Parking",
sum(ft) / 5280.0 as total_mi
*/

select distinct pid, pjct_name, sip_year, unit, description as  status, pm, ft, 
mod as lane_count, question as facility_type, segmentid, st_astext(geom) as lgeom

from (
                select distinct p.pid, p.pjct_name, p.sip_year, qp.question, type_qid, pid_fk, tid, st_length(l.geom) as ft --max(st_length(l.geom)*mod) as ft, sharrow_type
                , sl2.description as unit , sl.description, p.pm, mod, l.segmentid, l.geom
		from  (
                                select qt.question as question, qt3.qid as sharrow_type, 
                                case when (qt2.question like '%Adjacent 2-Directional%' OR qt2.question like  '%2 Lanes Opposite%' 
                                OR qt3.question like '%Adjacent 2-Directional%' OR qt3.question like  '%2 Lanes Opposite%') then 2 else 1 end as mod, 
                                qt2.question as q2, ftype.ancestor as type_qid, qp2.* 
                                from (select * from sip_questions_path where ancestor = 258 and depth= 1) as ftype-- new facility by top level type
                                join sip_questions_path as qp on ftype.descendant = qp.ancestor -- possible descendants on above's types
                                join sip_questions as qt on ftype.descendant = qt.qid -- new facility types' names
				join sip_questions_path as qp2 on qt.qid = qp2.ancestor 
                                join sip_questions as qt2 on qp2.descendant = qt2.qid -- names of possible descendants on above's types needed for 2-way modification
                                join sip_questions_path as qp3 on qt2.qid = qp3.ancestor -- possible additional descendants for shared types
                                join sip_questions as qt3 on qp3.descendant = qt3.qid -- names of possible descendants on above's types needed for 2-way modification
                ) as qp 
                join sip_treatments as t on descendant = t.breadcrumbid -- treatments with new bike facility
                join sip_treatments_geo as g on t.tid = g.tid_fk -- segmentids of treatments 
                join clion as l on g.segmentid = l.segmentid::int -- length of treatment segments
                join sip_projects p on t.pid_fk = p.pid -- project info (may not be needed)
		join sip_lookup sl on p.status = sl.lookupid::varchar
		left outer join sip_lookup sl2 on p.unit = sl2.lookupid::varchar
		join (select * from sip_treatments_attr where q_value not in ('FALSE', 'False')) ta on qp.sharrow_type = ta.qid_fk and t.tid = ta.tid_fk
		--group by p.pid, p.pjct_name, p.sip_year, qp.question, type_qid, pid_fk, tid, sharrow_type, geom, sl2.description, sl.description, p.pm, mod
	union --union with Bike WPL in Parking Markings
		select distinct pid, pjct_name, sip_year, question, qid, pid_fk, tid, st_length(l.geom) as ft --NOTE: not counting 2-sided WPL
		,sl2.description as unt, sl.description, p.pm, 1 as mod, l.segmentid, l.geom
		from (select * from sip_treatments_attr where qid_fk = 187 and q_value not in ('FALSE', 'False')) ta -- where attr is Bike WPL
		join sip_questions q on ta.qid_fk = q.qid
		join sip_treatments t on ta.tid_fk = t.tid
		join sip_treatments_geo g on t.tid = g.tid_fk
		join clion as l on g.segmentid = l.segmentid::int -- length of treatment segments
                join sip_projects p on t.pid_fk = p.pid -- project info (may not be needed)
		join sip_lookup sl on p.status = sl.lookupid::varchar
		left outer join sip_lookup sl2 on p.unit = sl2.lookupid::varchar
                --where sl.description in (%in_sip%) -- ADD %status%
) as bike_data order by pid

