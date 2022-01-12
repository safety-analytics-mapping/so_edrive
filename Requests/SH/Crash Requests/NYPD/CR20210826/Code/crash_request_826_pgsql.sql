-- Full Years------------------------------------------------------------------------------
WITH data AS(

SELECT DISTINCT coalesce(l.l_cd::int,0) cd,
		sum(coalesce(CASE WHEN core.yr = 2017 THEN 1 END, 0)) "2017",
		sum(coalesce(CASE WHEN core.yr = 2018 THEN 1 END, 0)) "2018",
		sum(coalesce(CASE WHEN core.yr = 2019 THEN 1 END, 0)) "2019",
		sum(coalesce(CASE WHEN core.yr = 2020 THEN 1 END, 0)) "2020"
FROM public.wc_accident_f core
JOIN public.wc_accident_victim_f vic
ON core.crashid = vic.crashid
JOIN lion l
ON core.masterid in (l.masteridfrom, l.masteridto)
WHERE PERSON_ROLE_CODE = 'Pedestrian'
AND inj_killed = 'injured'
AND core.yr between 2017 and 2020
AND core.borough = 'bronx'
GROUP BY l.l_cd

UNION ALL

SELECT DISTINCT coalesce(l.r_cd::int,0) cd,
		sum(coalesce(CASE WHEN core.yr = 2017 THEN 1 END, 0)) "2017",
		sum(coalesce(CASE WHEN core.yr = 2018 THEN 1 END, 0)) "2018",
		sum(coalesce(CASE WHEN core.yr = 2019 THEN 1 END, 0)) "2019",
		sum(coalesce(CASE WHEN core.yr = 2020 THEN 1 END, 0)) "2020"
FROM public.wc_accident_f core
JOIN public.wc_accident_victim_f vic
ON core.crashid = vic.crashid
JOIN lion l
ON core.masterid in (l.masteridfrom, l.masteridto)
WHERE PERSON_ROLE_CODE = 'Pedestrian'
AND inj_killed = 'injured'
AND core.yr between 2017 and 2020
AND core.borough = 'bronx'
GROUP BY l.r_cd)

SELECT  cd,
	sum("2017") "2017",
	sum("2018") "2018",
	sum("2019") "2019",
	sum("2020") "2020"
FROM data
GROUP BY cd




-- Jan-7/31 ------------------------------------------------------------------------------
WITH data AS(

SELECT DISTINCT coalesce(l.l_cd::int,0) cd,
		sum(coalesce(CASE WHEN core.yr = 2017 THEN 1 END, 0)) "2017",
		sum(coalesce(CASE WHEN core.yr = 2018 THEN 1 END, 0)) "2018",
		sum(coalesce(CASE WHEN core.yr = 2019 THEN 1 END, 0)) "2019",
		sum(coalesce(CASE WHEN core.yr = 2020 THEN 1 END, 0)) "2020"
FROM public.wc_accident_f core
JOIN public.wc_accident_victim_f vic
ON core.crashid = vic.crashid
JOIN lion l
ON core.masterid in (l.masteridfrom, l.masteridto)
WHERE PERSON_ROLE_CODE = 'Pedestrian'
AND inj_killed = 'injured'
AND core.yr between 2017 and 2020
AND core.borough = 'bronx'
AND extract(month from core.crash_date) <8
GROUP BY l.l_cd

UNION ALL

SELECT DISTINCT coalesce(l.r_cd::int,0) cd,
		sum(coalesce(CASE WHEN core.yr = 2017 THEN 1 END, 0)) "2017",
		sum(coalesce(CASE WHEN core.yr = 2018 THEN 1 END, 0)) "2018",
		sum(coalesce(CASE WHEN core.yr = 2019 THEN 1 END, 0)) "2019",
		sum(coalesce(CASE WHEN core.yr = 2020 THEN 1 END, 0)) "2020"
FROM public.wc_accident_f core
JOIN public.wc_accident_victim_f vic
ON core.crashid = vic.crashid
JOIN lion l
ON core.masterid in (l.masteridfrom, l.masteridto)
WHERE PERSON_ROLE_CODE = 'Pedestrian'
AND inj_killed = 'injured'
AND core.yr between 2017 and 2020
AND core.borough = 'bronx'
AND extract(month from core.crash_date) <8
GROUP BY l.r_cd)

SELECT  cd,
	sum("2017") "2017",
	sum("2018") "2018",
	sum("2019") "2019",
	sum("2020") "2020"
FROM data
GROUP BY cd



SELECT DISTINCT 
FROM public.wc_accident_f core
limit 100

