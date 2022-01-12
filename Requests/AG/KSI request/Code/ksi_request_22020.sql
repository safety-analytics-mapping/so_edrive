

DROP TABLE IF EXISTS park_ave; 

CREATE TEMPORARY TABLE park_ave AS 

WITH data AS (
SELECT distinct nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
JOIN archive."18d.2019-11-13_lion" lion
on nys_a.mft = lion.mft
WHERE nys_a.case_yr>= 2015 and nys_a.case_yr<=2017
and lion.segmentid::int in (30099, 30089, 30199, 29940, 30082, 30195, 256878, 256877, 248653, 248654, 
			    9008307, 234112, 234111, 215350, 215351, 30314, 30310, 30097, 30197, 30302, 
			    30187, 29945, 122058, 29949, 30091, 30191, 136115, 9008308, 30103, 30105, 
			    30312, 24650, 30203, 30319, 30304, 24646, 122059)

UNION

SELECT nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
WHERE masterid in (
		SELECT masteridFROM mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (30099, 30089, 30199, 29940, 30082, 30195, 256878, 256877, 248653, 248654, 
					      9008307, 234112, 234111, 215350, 215351, 30314, 30310, 30097, 30197, 30302, 
			    	              30187, 29945, 122058, 29949, 30091, 30191, 136115, 9008308, 30103, 30105, 
			    	              30312, 24650, 30203, 30319, 30304, 24646, 122059)

		
		)


		union 

		SELECT masteridto mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (30099, 30089, 30199, 29940, 30082, 30195, 256878, 256877, 248653, 248654, 
					      9008307, 234112, 234111, 215350, 215351, 30314, 30310, 30097, 30197, 30302, 
			    	              30187, 29945, 122058, 29949, 30091, 30191, 136115, 9008308, 30103, 30105, 
			    	              30312, 24650, 30203, 30319, 30304, 24646, 122059)

		)
)
and  nys_a.case_yr>= 2015 and nys_a.case_yr<=2017
)

SELECT * FROM data
WHERE exclude = 0;

GRANT ALL on park_ave to public;




--Fatals-------------------------------------
drop table if exists park_ave_fatalities; 

create TEMPORARY table park_ave_fatalities as 

SELECT segmentid, nodeidFROM, nodeidto 
FROM archive."18d.2019-11-13_lion" lion
WHERE lion.mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" 
		WHERE segmentid::int in (30099, 30089, 30199, 29940, 30082, 30195, 256878, 256877, 248653, 248654, 
					 9008307, 234112, 234111, 215350, 215351, 30314, 30310, 30097, 30197, 30302, 
			    	         30187, 29945, 122058, 29949, 30091, 30191, 136115, 9008308, 30103, 30105, 
			    	         30312, 24650, 30203, 30319, 30304, 24646, 122059)

		)



--Park Avenue KSI-----------------------------------------------------------------------------------------------------------------------


SELECT mode, sum("Severe Injuries") "Severe Injuries", sum("Fatalities") "Fatalities", sum("Severe Injuries"  + "Fatalities") as "KSI"
FROM (  SELECT * FROM (
	SELECT 	CASE WHEN accd_type_int = 1 then '1. PEDESTRIAN'
		     WHEN accd_type_int = 2 then '2. BICYCLIST'
		     WHEN accd_type_int = 3 then '3. MOTOR VEHICLE' END AS mode
	,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "Severe Injuries"
	,0 as "Fatalities"
	FROM park_ave
	GROUP BY CASE WHEN accd_type_int = 1 then '1. PEDESTRIAN'
		      WHEN accd_type_int = 2 then '2. BICYCLIST'
		      WHEN accd_type_int = 3 then '3. MOTOR VEHICLE' END
	ORDER BY mode) si 

	union 


	-- All fatalities on corridors of stretch
	SELECT case when pos = 'PD' then '1. PEDESTRIAN'
		    when pos = 'BI' then '2. BICYCLIST'
		    when pos in ('MO','PS','DR') then '3. MOTOR VEHICLE' end as mode
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.segmentid in (SELECT segmentid FROM park_ave_fatalities)
	and date_part('year',acdate) between 2015 and 2017
	GROUP by pos

	union 

	-- All fatalities on intersections of stretch
	SELECT case when pos = 'PD' then 'PEDESTRIAN'
		    when pos = 'BI' then 'BICYCLIST'
		    when pos in ('MO','PS','DR') then 'MOTOR VEHICLE' end as mode
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.nodeid::int in ( SELECT distinct nodeid::int FROM(
						SELECT nodeidFROM nodeid FROM park_ave_fatalities 
						union
						SELECT nodeidto nodeid FROM park_ave_fatalities) x)
	and date_part('year',acdate) between 2015 and 2017
	GROUP by pos
) inj_sum
GROUP by mode








--Williamsburg Street-----------------------------------------------------------------

DROP TABLE IF EXISTS williamsburg_st; 

CREATE TEMPORARY TABLE williamsburg_st AS 

WITH data AS (
SELECT distinct nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
JOIN archive."18d.2019-11-13_lion" lion
on nys_a.mft = lion.mft
WHERE nys_a.case_yr>= 2015 and nys_a.case_yr<=2017
and lion.segmentid::int in (30737, 30514, 30542, 30710, 163949, 30494, 30680, 163962, 290694, 
			    290693, 163961, 30712, 30727, 30521, 163948, 30734, 30684, 30708, 30704, 30675, 30546, 30730)

UNION

SELECT nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
WHERE masterid in (
		SELECT masteridFROM mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (30737, 30514, 30542, 30710, 163949, 30494, 30680, 163962, 290694, 
					      290693, 163961, 30712, 30727, 30521, 163948, 30734, 30684, 30708, 30704, 30675, 30546, 30730)
		
		)


		union 

		SELECT masteridto mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (30737, 30514, 30542, 30710, 163949, 30494, 30680, 163962, 290694, 
					      290693, 163961, 30712, 30727, 30521, 163948, 30734, 30684, 30708, 30704, 30675, 30546, 30730)
		)
)
and  nys_a.case_yr>= 2015 and nys_a.case_yr<=2017
)

select * from data
where exclude = 0;

GRANT ALL on williamsburg_st to public;




--Fatals-------------------------------------
drop table if exists williamsburg_st_fatalities; 

create TEMPORARY table williamsburg_st_fatalities as 

SELECT segmentid, nodeidFROM, nodeidto 
FROM archive."18d.2019-11-13_lion" lion
WHERE lion.mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" 
		WHERE segmentid::int in (30737, 30514, 30542, 30710, 163949, 30494, 30680, 163962, 290694, 
					 290693, 163961, 30712, 30727, 30521, 163948, 30734, 30684, 30708, 30704, 30675, 30546, 30730)
		)






--Williamsburg Street KSI-----------------------------------------------------------------------------------------------------------------------

SELECT mode, sum("Severe Injuries") "Severe Injuries", sum("Fatalities") "Fatalities", sum("Severe Injuries"  + "Fatalities") as "KSI"
FROM (  SELECT * FROM (
	SELECT 	CASE WHEN accd_type_int = 1 then '1. PEDESTRIAN'
		     WHEN accd_type_int = 2 then '2. BICYCLIST'
		     WHEN accd_type_int = 3 then '3. MOTOR VEHICLE' END AS mode
	,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "Severe Injuries"
	,0 as "Fatalities"
	FROM williamsburg_st
	GROUP BY CASE WHEN accd_type_int = 1 then '1. PEDESTRIAN'
		      WHEN accd_type_int = 2 then '2. BICYCLIST'
		      WHEN accd_type_int = 3 then '3. MOTOR VEHICLE' END
	ORDER BY mode) si 

	union 


	-- All fatalities on corridors of stretch
	SELECT case when pos = 'PD' then '1. PEDESTRIAN'
		    when pos = 'BI' then '2. BICYCLIST'
		    when pos in ('MO','PS','DR') then '3. MOTOR VEHICLE' end as mode
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.segmentid in (SELECT segmentid FROM williamsburg_st_fatalities)
	and date_part('year',acdate) between 2015 and 2017
	GROUP by pos

	union 

	-- All fatalities on intersections of stretch
	SELECT case when pos = 'PD' then 'PEDESTRIAN'
		    when pos = 'BI' then 'BICYCLIST'
		    when pos in ('MO','PS','DR') then 'MOTOR VEHICLE' end as mode
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.nodeid::int in ( SELECT distinct nodeid::int FROM(
						SELECT nodeidFROM nodeid FROM williamsburg_st_fatalities 
						union
						SELECT nodeidto nodeid FROM williamsburg_st_fatalities) x)
	and date_part('year',acdate) between 2015 and 2017
	GROUP by pos
) inj_sum
GROUP by mode







--Meeker Ave-----------------------------------------------------------------

DROP TABLE IF EXISTS meeker_ave; 

CREATE TEMPORARY TABLE meeker_ave AS 

WITH data AS (
SELECT distinct nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
JOIN archive."18d.2019-11-13_lion" lion
on nys_a.mft = lion.mft
WHERE nys_a.case_yr>= 2015 and nys_a.case_yr<=2017
and lion.segmentid::int in (65878, 35603, 31128, 31135, 35420, 172165, 172164, 165251, 
			    35235, 65874, 65890, 31137, 31130, 35617, 31145, 35431, 35619, 
			    31143, 257729, 257728, 65892, 65863, 35237, 65871, 35432, 35597, 
			    165257, 35438, 35456, 144186, 165252, 35443, 65835, 66006, 66012, 
			    35434, 31152, 35459, 35625, 65880, 165258, 35464, 66000, 35588, 
			    312802, 312769, 312733, 312732, 312695)

UNION

SELECT nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
WHERE masterid in (
		SELECT masteridFROM mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (65878, 35603, 31128, 31135, 35420, 172165, 172164, 165251, 
					      35235, 65874, 65890, 31137, 31130, 35617, 31145, 35431, 35619, 
					      31143, 257729, 257728, 65892, 65863, 35237, 65871, 35432, 35597, 
					      165257, 35438, 35456, 144186, 165252, 35443, 65835, 66006, 66012, 
					      35434, 31152, 35459, 35625, 65880, 165258, 35464, 66000, 35588, 
					      312802, 312769, 312733, 312732, 312695)
		)


		union 

		SELECT masteridto mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (65878, 35603, 31128, 31135, 35420, 172165, 172164, 165251, 
					      35235, 65874, 65890, 31137, 31130, 35617, 31145, 35431, 35619, 
					      31143, 257729, 257728, 65892, 65863, 35237, 65871, 35432, 35597, 
					      165257, 35438, 35456, 144186, 165252, 35443, 65835, 66006, 66012, 
					      35434, 31152, 35459, 35625, 65880, 165258, 35464, 66000, 35588, 
					      312802, 312769, 312733, 312732, 312695)
		)
)
and  nys_a.case_yr>= 2015 and nys_a.case_yr<=2017
)

select * from data
where exclude = 0;

GRANT ALL on meeker_ave to public;




--Fatals-------------------------------------
drop table if exists meeker_ave_fatalities; 

create TEMPORARY table meeker_ave_fatalities as 

SELECT segmentid, nodeidFROM, nodeidto 
FROM archive."18d.2019-11-13_lion" lion
WHERE lion.mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" 
		WHERE segmentid::int in (65878, 35603, 31128, 31135, 35420, 172165, 172164, 165251, 
					 35235, 65874, 65890, 31137, 31130, 35617, 31145, 35431, 35619, 
					 31143, 257729, 257728, 65892, 65863, 35237, 65871, 35432, 35597, 
					 165257, 35438, 35456, 144186, 165252, 35443, 65835, 66006, 66012, 
					 35434, 31152, 35459, 35625, 65880, 165258, 35464, 66000, 35588, 
					 312802, 312769, 312733, 312732, 312695)
		)






--Meeker Ave KSI-----------------------------------------------------------------------------------------------------------------------

SELECT mode, sum("Severe Injuries") "Severe Injuries", sum("Fatalities") "Fatalities", sum("Severe Injuries"  + "Fatalities") as "KSI"
FROM (  SELECT * FROM (
	SELECT 	CASE WHEN accd_type_int = 1 then '1. PEDESTRIAN'
		     WHEN accd_type_int = 2 then '2. BICYCLIST'
		     WHEN accd_type_int = 3 then '3. MOTOR VEHICLE' END AS mode
	,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "Severe Injuries"
	,0 as "Fatalities"
	FROM meeker_ave
	GROUP BY CASE WHEN accd_type_int = 1 then '1. PEDESTRIAN'
		      WHEN accd_type_int = 2 then '2. BICYCLIST'
		      WHEN accd_type_int = 3 then '3. MOTOR VEHICLE' END
	ORDER BY mode) si 

	union 


	-- All fatalities on corridors of stretch
	SELECT case when pos = 'PD' then '1. PEDESTRIAN'
		    when pos = 'BI' then '2. BICYCLIST'
		    when pos in ('MO','PS','DR') then '3. MOTOR VEHICLE' end as mode
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.segmentid in (SELECT segmentid FROM meeker_ave_fatalities)
	and date_part('year',acdate) between 2015 and 2017
	GROUP by pos

	union 

	-- All fatalities on intersections of stretch
	SELECT case when pos = 'PD' then 'PEDESTRIAN'
		    when pos = 'BI' then 'BICYCLIST'
		    when pos in ('MO','PS','DR') then 'MOTOR VEHICLE' end as mode
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.nodeid::int in ( SELECT distinct nodeid::int FROM(
						SELECT nodeidFROM nodeid FROM meeker_ave_fatalities 
						union
						SELECT nodeidto nodeid FROM meeker_ave_fatalities) x)
	and date_part('year',acdate) between 2015 and 2017
	GROUP by pos
) inj_sum
GROUP by mode























--Flatbush Ave-----------------------------------------------------------------

DROP TABLE IF EXISTS flastbush_ave; 

CREATE TEMPORARY TABLE flatbush_ave AS 

WITH data AS (
SELECT distinct nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
JOIN archive."18d.2019-11-13_lion" lion
on nys_a.mft = lion.mft
WHERE nys_a.case_yr>= 2015 and nys_a.case_yr<=2017
and lion.segmentid::int in (188022,188023,29283)

UNION

SELECT nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
WHERE masterid in (
		SELECT masteridFROM mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (188022,188023,29283)
		
		)


		union 

		SELECT masteridto mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (188022,188023,29283)
		)
)
and  nys_a.case_yr>= 2015 and nys_a.case_yr<=2017
)

select * from data
where exclude = 0;

GRANT ALL on flatbush_ave to public;




--Fatals-------------------------------------
drop table if exists flatbush_ave_fatalities; 

create TEMPORARY table flatbush_ave_fatalities as 

SELECT segmentid, nodeidFROM, nodeidto 
FROM archive."18d.2019-11-13_lion" lion
WHERE lion.mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" 
		WHERE segmentid::int in (188022,188023,29283)
		)






--Flatbush Ave KSI-----------------------------------------------------------------------------------------------------------------------

SELECT mode, sum("Severe Injuries") "Severe Injuries", sum("Fatalities") "Fatalities", sum("Severe Injuries"  + "Fatalities") as "KSI"
FROM (  SELECT * FROM (
	SELECT 	CASE WHEN accd_type_int = 1 then '1. PEDESTRIAN'
		     WHEN accd_type_int = 2 then '2. BICYCLIST'
		     WHEN accd_type_int = 3 then '3. MOTOR VEHICLE' END AS mode
	,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "Severe Injuries"
	,0 as "Fatalities"
	FROM flatbush_ave
	GROUP BY CASE WHEN accd_type_int = 1 then '1. PEDESTRIAN'
		      WHEN accd_type_int = 2 then '2. BICYCLIST'
		      WHEN accd_type_int = 3 then '3. MOTOR VEHICLE' END
	ORDER BY mode) si 

	union 


	-- All fatalities on corridors of stretch
	SELECT case when pos = 'PD' then '1. PEDESTRIAN'
		    when pos = 'BI' then '2. BICYCLIST'
		    when pos in ('MO','PS','DR') then '3. MOTOR VEHICLE' end as mode
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.segmentid in (SELECT segmentid FROM flatbush_ave_fatalities)
	and date_part('year',acdate) between 2015 and 2017
	GROUP by pos

	union 

	-- All fatalities on intersections of stretch
	SELECT case when pos = 'PD' then 'PEDESTRIAN'
		    when pos = 'BI' then 'BICYCLIST'
		    when pos in ('MO','PS','DR') then 'MOTOR VEHICLE' end as mode
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.nodeid::int in ( SELECT distinct nodeid::int FROM(
						SELECT nodeidFROM nodeid FROM flatbush_ave_fatalities 
						union
						SELECT nodeidto nodeid FROM flatbush_ave_fatalities) x)
	and date_part('year',acdate) between 2015 and 2017
	GROUP by pos
) inj_sum
GROUP by mode






--Riverside Drive-----------------------------------------------------------------

DROP TABLE IF EXISTS riverside_dr;

CREATE TEMPORARY TABLE riverside_dr AS 

WITH data AS (
SELECT distinct nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
JOIN archive."18d.2019-11-13_lion" lion
on nys_a.mft = lion.mft
WHERE nys_a.case_yr>= 2015 and nys_a.case_yr<=2017
and lion.segmentid::int in (138518, 194962, 173692, 183821, 194846, 39105, 
			    194963, 166693, 194847, 39118, 138520, 173693, 39102, 
			    242611, 242610, 242202, 242201, 302214, 302213, 138519, 
			    39069, 166694, 70805, 183820, 39124, 138517)

UNION

SELECT nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
WHERE masterid in (
		SELECT masteridFROM mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (138518, 194962, 173692, 183821, 194846, 39105, 
					      194963, 166693, 194847, 39118, 138520, 173693, 39102, 
					      242611, 242610, 242202, 242201, 302214, 302213, 138519, 
					      39069, 166694, 70805, 183820, 39124, 138517)
		
		)


		union 

		SELECT masteridto mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (138518, 194962, 173692, 183821, 194846, 39105, 
					      194963, 166693, 194847, 39118, 138520, 173693, 39102, 
					      242611, 242610, 242202, 242201, 302214, 302213, 138519, 
					      39069, 166694, 70805, 183820, 39124, 138517)
		)
)
and  nys_a.case_yr>= 2015 and nys_a.case_yr<=2017
)

select * from data
where exclude = 0;

GRANT ALL on riverside_dr to public;




--Fatals-------------------------------------
drop table if exists riverside_dr_fatalities; 

create TEMPORARY table riverside_dr_fatalities as 

SELECT segmentid, nodeidFROM, nodeidto 
FROM archive."18d.2019-11-13_lion" lion
WHERE lion.mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" 
		WHERE segmentid::int in (138518, 194962, 173692, 183821, 194846, 39105, 
					 194963, 166693, 194847, 39118, 138520, 173693, 39102, 
					 242611, 242610, 242202, 242201, 302214, 302213, 138519, 
					 39069, 166694, 70805, 183820, 39124, 138517)
		)






--Riverside Drive KSI-----------------------------------------------------------------------------------------------------------------------

SELECT mode, sum("Severe Injuries") "Severe Injuries", sum("Fatalities") "Fatalities", sum("Severe Injuries"  + "Fatalities") as "KSI"
FROM (  SELECT * FROM (
	SELECT 	CASE WHEN accd_type_int = 1 then '1. PEDESTRIAN'
		     WHEN accd_type_int = 2 then '2. BICYCLIST'
		     WHEN accd_type_int = 3 then '3. MOTOR VEHICLE' END AS mode
	,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "Severe Injuries"
	,0 as "Fatalities"
	FROM riverside_dr
	GROUP BY CASE WHEN accd_type_int = 1 then '1. PEDESTRIAN'
		      WHEN accd_type_int = 2 then '2. BICYCLIST'
		      WHEN accd_type_int = 3 then '3. MOTOR VEHICLE' END
	ORDER BY mode) si 

	union 


	-- All fatalities on corridors of stretch
	SELECT case when pos = 'PD' then '1. PEDESTRIAN'
		    when pos = 'BI' then '2. BICYCLIST'
		    when pos in ('MO','PS','DR') then '3. MOTOR VEHICLE' end as mode
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.segmentid in (SELECT segmentid FROM riverside_dr_fatalities)
	and date_part('year',acdate) between 2015 and 2017
	GROUP by pos

	union 

	-- All fatalities on intersections of stretch
	SELECT case when pos = 'PD' then 'PEDESTRIAN'
		    when pos = 'BI' then 'BICYCLIST'
		    when pos in ('MO','PS','DR') then 'MOTOR VEHICLE' end as mode
	       ,0 as "Severe Injuries"
	       ,count(id_) as "Fatalities"
	FROM public.fatality_nycdot_current fat
	WHERE fat.nodeid::int in ( SELECT distinct nodeid::int FROM(
						SELECT nodeidFROM nodeid FROM riverside_dr_fatalities 
						union
						SELECT nodeidto nodeid FROM riverside_dr_fatalities) x)
	and date_part('year',acdate) between 2015 and 2017
	GROUP by pos
) inj_sum
GROUP by mode

		