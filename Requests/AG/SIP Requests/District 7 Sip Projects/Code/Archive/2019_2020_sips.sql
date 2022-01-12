SELECT *
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
where sip_year in (2019,2020)
and spg.nodeid=0
and sp.status = '11'
order by sip_year;



