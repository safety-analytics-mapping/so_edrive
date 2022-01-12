

SELECT sp.pid, sp.pjct_name, st.tid, sq.question as treatment, sp.sip_year, sp.end_date, stg.segmentid, st_setsrid(stg.geom,2263) geom
FROM public.sip_projects sp
join sip_treatments st
on sp.pid = st.pid_fk
join sip_questions sq
on st.breadcrumbid = sq.qid
join sip_treatments_geo stg
on st.tid = stg.tid_fk
where sp.status= '15'
and stg.nodeid=0
and sq.question like '%Closure%'
order by sp.end_date



select st.tid, st.treatment, st.treatmenttype, sq.question, st.breadcrumbid, sq_breadcrumb.question
from sip_treatments st
join sip_questions sq
on st.treatmenttype::int = sq.qid
join sip_questions sq_breadcrumb
on st.breadcrumbid::int = sq_breadcrumb.qid
limit 15

select *
from sip_treatments_geo limit 10

--- Check that breadcrumb is the correct thing (it's ancestor is the right path)
select sqp.descendant, sq.question, sqp.ancestor, sq_ancestor.question, depth 
from sip_questions sq 
join sip_questions_path sqp
on sq.qid = sqp.descendant
join sip_questions sq_ancestor
on sqp.ancestor = sq_ancestor.qid 
where sq.question like '%Curbside%'
and depth = 1
order by descendant

select * from sip_questions_path limit 10

