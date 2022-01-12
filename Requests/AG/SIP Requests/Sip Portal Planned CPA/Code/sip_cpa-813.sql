SELECT pid, pjct_name, sip_year, start_date, end_date, geo_type, unit, 
       pm, mtp, capital, status, vz_status, date_created, date_updated, 
       updated_by, total_public_space, milestone_date, assignedto, temppid
  FROM public.sip_projects 
  where status = '11'
  limit 10

  select * from sip_lookup



                SELECT distinct* FROM(
                SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.status, spg.segmentid, st_setsrid(spg.geom,2263) geom
                FROM public.sip_projects sp
                join public.sip_projects_geo spg
                on sp.pid=spg.pid_fk
                where sp.status in ('11','15')
                and spg.nodeid=0
                and sip_year in (2019,2020)) x



                


                SELECT distinct* FROM(
                SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.status, spg.nodeid, st_setsrid(spg.geom,2263) geom
                FROM public.sip_projects sp
                join public.sip_projects_geo spg
                on sp.pid=spg.pid_fk
                where sp.status in ('11','15')
                and spg.segmentid=0
                and sip_year in (2019,2020)
                and sp.pid in (2050,
 1798,
 1549,
 1423,
 1297,
 4242,
 1812,
 1817,
 1690,
 1691,
 1818,
 1311,
 1696,
 1827,
 2054,
 1575,
 1576,
 1323,
 2093,
 1711,
 2742,
 1463,
 1467,
 1473,
 963,
 1732,
 1733,
 1480,
 1486,
 1874,
 1369,
 3802,
 1786,
 1761,
 1763,
 2023,
 1385,
 1770,
 1515,
 1773,
 4462,
 1393,
 1782,
 1783,
 1402,
 1407)) x










SELECT distinct* FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.status, spg.segmentid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
where sp.status= '11'
and spg.nodeid=0
and sip_year in (2019, 2020)
and sp.pid in (963,
 1297,
 1311,
 1323,
 1369,
 1385,
 1393,
 1402,
 1407,
 1423,
 1463,
 1467,
 1473,
 1480,
 1486,
 1515,
 1549,
 1575,
 1576,
 1690,
 1691,
 1696,
 1711,
 1732,
 1733,
 1761,
 1763,
 1770,
 1773,
 1782,
 1783,
 1786,
 1798,
 1812,
 1817,
 1818,
 1827,
 1874,
 2023,
 2050,
 2054,
 2093,
 2742,
 3802,
 4242,
 4462)) corrs















SELECT distinct* FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.status, spg.segmentid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
where spg.nodeid=0
and sip_year in (2019, 2020)
and sp.pid in (1423, 1297, 1323, 1463, 1575, 1770, 1817, 1818, 1827, 2054, 4242, 1915, 1771)) corrsimp
 



SELECT distinct* FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.status, spg.segmentid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
where spg.nodeid=0
and sip_year in (2019, 2020)
and sp.pid in (1369,
 1385,
 1393,
 1402,
 1407,
 1467,
 1473,
 1480,
 1486,
 1515,
 1549,
 1576,
 1690,
 1763,
 1696,
 1798,
 1732,
 1733,
 1761,
 1773,
 1782,
 1783,
 1812,
 1874,
 2023,
 2050,
 963,
 1311,
 1691,
 1711,
 1786,
 2093,
 2742,
 3802,
 4462,
 4522,
 4542,
 4622,
 4642,
 4322,
 4282,
 4922,
 4942,
 4962)) corrspl
 


                SELECT distinct* FROM(
                SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.status, spg.nodeid, st_setsrid(spg.geom,2263) geom
                FROM public.sip_projects sp
                join public.sip_projects_geo spg
                on sp.pid=spg.pid_fk
                where sp.status in ('11','15')
                and spg.segmentid=0
                and sip_year in (2019,2020)
                and sp.pid in (2050,
 1798,
 1549,
 1423,
 1297,
 4242,
 1812,
 1817,
 1690,
 1691,
 1818,
 1311,
 1696,
 1827,
 2054,
 1575,
 1576,
 1323,
 2093,
 1711,
 2742,
 1463,
 1467,
 1473,
 963,
 1732,
 1733,
 1480,
 1486,
 1874,
 1369,
 3802,
 1786,
 1761,
 1763,
 2023,
 1385,
 1770,
 1515,
 1773,
 4462,
 1393,
 1782,
 1783,
 1402,
 1407)) x




SELECT distinct* FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.status, spg.nodeid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
where spg.segmentid=0
and sip_year in (2019,2020)
and sp.pid in (4222, 1791, 1644, 1369)) impitx


SELECT distinct* FROM(
SELECT sp.pid, sp.pjct_name, sp.pm, sp.sip_year, sp.status, spg.nodeid, st_setsrid(spg.geom,2263) geom
FROM public.sip_projects sp
join public.sip_projects_geo spg
on sp.pid=spg.pid_fk
where spg.segmentid=0
and sip_year in (2019,2020)
and sp.pid in (1498, 1728, 1736, 1738, 1840, 1905, 1977, 2048, 2081, 920, 1994)) plitx



 
 