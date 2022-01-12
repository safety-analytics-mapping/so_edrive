SELECT nodeid 
FROM working.hsq



--Hudson Square-----------------------
DROP TABLE IF EXISTS working.hudson_sq; 

CREATE TABLE working.hudson_sq AS 

SELECT distinct nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
JOIN archive."18d.2019-11-13_node" lion
on nys_a.nodeid::int = lion.nodeid::int
WHERE nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and nys_a.nodeid::int in(SELECT nodeid 
FROM working.hsq);

                        
GRANT ALL on working.hudson_sq to public;


SELECT * FROM hudson_sq


SELECT row_number() OVER (ORDER BY "All Inj" desc) "Inj Rank", inj.*, coalesce(fat."Fatalities",0) "Fatalities", inj."Severe Injuries" + coalesce(fat."Fatalities",0) KSI FROM (
--Hudson Square Injuries-----------------------
SELECT  masterid
       ,coalesce(sum(CASE WHEN accd_type_int = 1 THEN num_of_inj END),0) "Ped Inj"
       ,coalesce(sum(CASE WHEN accd_type_int = 2 THEN num_of_inj END),0) "Bike Inj"
       ,coalesce(sum(CASE WHEN accd_type_int = 3 THEN num_of_inj END),0) "Mvo Inj"
       ,coalesce(sum(num_of_inj),0) "All Inj"
       ,coalesce(sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))),0) as "Severe Injuries"
FROM working.hudson_sq
GROUP BY  masterid
) inj
LEFT JOIN (--Hudson Square Fatalities---------------------
	   SELECT masterid, count(case when date_part('year',acdate) between 2013 and 2017 then id_ end) as "Fatalities"
	   FROM public.fatality_nycdot_current fat
	   WHERE  fat.nodeid::int in (select nodeid::int from working.hudson_sq)
	   GROUP BY masterid) fat
on inj.masterid = fat.masterid





SELECT row_number() OVER (ORDER BY x."KSI" DESC, x."All Inj" DESC) "Ranking", x.*
FROM(   SELECT inj.*
	      , coalesce(fat."Fatalities",0) "Fatalities"
	      , inj."Severe Injuries" + coalesce(fat."Fatalities",0) "KSI" FROM (
	--Hudson Square Injuries-----------------------
	SELECT  masterid
	       ,coalesce(sum(CASE WHEN accd_type_int = 1 THEN num_of_inj END),0) "Ped Inj"
	       ,coalesce(sum(CASE WHEN accd_type_int = 2 THEN num_of_inj END),0) "Bike Inj"
	       ,coalesce(sum(CASE WHEN accd_type_int = 3 THEN num_of_inj END),0) "Mvo Inj"
	       ,coalesce(sum(num_of_inj),0) "All Inj"
	       ,coalesce(sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))),0) as "Severe Injuries"
	FROM working.hudson_sq
	GROUP BY  masterid
	) inj
	LEFT JOIN (--Hudson Square Fatalities---------------------
		   SELECT masterid, count(case when date_part('year',acdate) between 2013 and 2017 then id_ end) as "Fatalities"
		   FROM public.fatality_nycdot_current fat
		   WHERE  fat.nodeid::int in (select nodeid::int from working.hudson_sq)
		   GROUP BY masterid) fat
	on inj.masterid = fat.masterid) x







SELECT rank() OVER (ORDER BY x."KSI" DESC, x."All Inj" DESC) "Ranking", x.*
FROM(   SELECT inj.*
	      , coalesce(fat."Fatalities",0) "Fatalities"
	      , inj."Severe Injuries" + coalesce(fat."Fatalities",0) "KSI" FROM (
	--Hudson Square Injuries-----------------------
	SELECT  masterid
	       ,coalesce(sum(CASE WHEN accd_type_int = 1 THEN num_of_inj END),0) "Ped Inj"
	       ,coalesce(sum(CASE WHEN accd_type_int = 2 THEN num_of_inj END),0) "Bike Inj"
	       ,coalesce(sum(CASE WHEN accd_type_int = 3 THEN num_of_inj END),0) "Mvo Inj"
	       ,coalesce(sum(num_of_inj),0) "All Inj"
	       ,coalesce(sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))),0) as "Severe Injuries"
	FROM working.hudson_sq
	GROUP BY  masterid
	) inj
	LEFT JOIN (--Hudson Square Fatalities---------------------
		   SELECT masterid, count(case when date_part('year',acdate) between 2013 and 2017 then id_ end) as "Fatalities"
		   FROM public.fatality_nycdot_current fat
		   WHERE  fat.nodeid::int in (select nodeid::int from working.hudson_sq)
		   GROUP BY masterid) fat
	on inj.masterid = fat.masterid) x









SELECT Dense_Rank() OVER (ORDER BY x."KSI" DESC) "KSI Ranking"
      ,Dense_Rank() OVER (ORDER BY x."All Inj" DESC) "Inj Ranking" 
      ,x.*
FROM(   SELECT inj.*
	      , coalesce(fat."Fatalities",0) "Fatalities"
	      , inj."Severe Injuries" + coalesce(fat."Fatalities",0) "KSI" FROM (
	--Hudson Square Injuries-----------------------
	SELECT  masterid
	       ,coalesce(sum(CASE WHEN accd_type_int = 1 THEN num_of_inj END),0) "Ped Inj"
	       ,coalesce(sum(CASE WHEN accd_type_int = 2 THEN num_of_inj END),0) "Bike Inj"
	       ,coalesce(sum(CASE WHEN accd_type_int = 3 THEN num_of_inj END),0) "Mvo Inj"
	       ,coalesce(sum(num_of_inj),0) "All Inj"
	       ,coalesce(sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))),0) as "Severe Injuries"
	FROM working.hudson_sq
	GROUP BY  masterid
	) inj
	LEFT JOIN (--Hudson Square Fatalities---------------------
		   SELECT masterid, count(case when date_part('year',acdate) between 2013 and 2017 then id_ end) as "Fatalities"
		   FROM public.fatality_nycdot_current fat
		   WHERE  fat.nodeid::int in (select nodeid::int from working.hudson_sq)
		   GROUP BY masterid) fat
	on inj.masterid = fat.masterid) x





select masterid::int, array_agg(street) 
from(select distinct masteridto masterid, street
     from lion 
     where masteridto::int in (select masterid::int from working.hudson_sq)

     union

     select distinct masteridfrom masterid, street
     from lion 
     where masteridfrom::int in (select masterid::int from working.hudson_sq)
) st_names
group by masterid