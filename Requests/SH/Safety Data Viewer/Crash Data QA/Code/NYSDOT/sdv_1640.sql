
--SIP 1640----------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS advanced_crashes_1640; 

CREATE TEMPORARY TABLE advanced_crashes_1640 AS 

SELECT distinct nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
JOIN archive."18d.2019-11-13_lion" lion
ON nys_a.mft = lion.mft
WHERE nys_a.case_yr>= 2013 and nys_a.case_yr<=2017
and lion.segmentid::int in (45405,45409,48545,48549,48553,48560,48566,48707,48714,48717,48720,48869,48876,48879,48880,49002,49009,49010,115539,115540,168653,168654)

UNION

SELECT nys_a.*
FROM archive."2019_11_13_nysdot_all" nys_a
WHERE masterid in (
		SELECT masteridFROM mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (45405,45409,48545,48549,48553,48560,48566,48707,48714,48717,48720,48869,48876,48879,48880,49002,49009,49010,115539,115540,168653,168654)
		
		)


		union 

		SELECT masteridto mid
		FROM archive."18d.2019-11-13_lion" lion
		WHERE mft in (
		SELECT mft
		FROM archive."18d.2019-11-13_lion" lion
		WHERE lion.segmentid::int in (45405,45409,48545,48549,48553,48560,48566,48707,48714,48717,48720,48869,48876,48879,48880,49002,49009,49010,115539,115540,168653,168654)
		)
)
and  nys_a.case_yr>= 2013 and nys_a.case_yr<=2017;

GRANT ALL on advanced_crashes_1640 to public;

SELECT sum(num_of_inj)
FROM advanced_crashes_1640
WHERE accd_type_int = 2 


select * 
FROM advanced_crashes_1640
limit 1

SELECT sum(2)




--Injuries by Year---------------------------------------------------
WITH data AS (
SELECT CASE WHEN case_yr = 2013 THEN '2013'
	    WHEN case_yr = 2014 THEN '2014'
	    WHEN case_yr = 2015 THEN '2015'
	    WHEN case_yr = 2016 THEN '2016'
	    WHEN case_yr = 2017 THEN '2017' END "Year"
 ,coalesce(sum(CASE WHEN accd_type_int = 1 then num_of_inj END),0) "Pedestrian"
 ,coalesce(sum(CASE WHEN accd_type_int = 2 then num_of_inj END),0) "Bicyclist"
 ,coalesce(sum(CASE WHEN accd_type_int = 3 then num_of_inj END),0) "Motor Vehicle"
FROM advanced_crashes_1640 
GROUP BY CASE WHEN case_yr = 2013 THEN '2013'
	    WHEN case_yr = 2014 THEN '2014'
	    WHEN case_yr = 2015 THEN '2015'
	    WHEN case_yr = 2016 THEN '2016'
	    WHEN case_yr = 2017 THEN '2017' END
ORDER BY "Year"
)



SELECT * FROM (
		SELECT data.*,  "Pedestrian" + "Bicyclist" + "Motor Vehicle" TOTAL
		FROM data

		union

		SELECT tot.*, "Pedestrian" + "Bicyclist" + "Motor Vehicle" TOTAL
 		FROM (SELECT 'Total' as "Year" 
		      ,sum(data."Pedestrian") "Pedestrian"
		      ,sum(data."Bicyclist") "Bicyclist"
		      ,sum(data."Motor Vehicle") "Motor Vehicle"
		      FROM data
		      ) tot
		)inj_year
ORDER BY "Year"




--Traffic Control by Year---------------------------------------------------
WITH data as(
SELECT CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END as " "
,coalesce(sum(CASE WHEN case_yr = 2013 THEN num_of_inj END),0) "2013"
,coalesce(sum(CASE WHEN case_yr = 2014 THEN num_of_inj END),0) "2014"
,coalesce(sum(CASE WHEN case_yr = 2015 THEN num_of_inj END),0) "2015"
,coalesce(sum(CASE WHEN case_yr = 2016 THEN num_of_inj END),0) "2016"
,coalesce(sum(CASE WHEN case_yr = 2017 THEN num_of_inj END),0) "2017"
FROM advanced_crashes_1640 
GROUP BY CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END
ORDER BY " ")



SELECT * FROM (
		SELECT data.*, "2013"+"2014"+"2015"+"2016"+"2017" TOTAL
		FROM data

		union

		SELECT tot.*, "2013" + "2014" + "2015" + "2016" + "2017"  TOTAL
 		FROM (SELECT 'Total' as Year
		      ,sum(data."2013") "2013"
		      ,sum(data."2014") "2014"
		      ,sum(data."2015") "2015"
		      ,sum(data."2016") "2016"
		      ,sum(data."2017") "2017"
		      FROM data
		      ) tot
		)traf_year
ORDER BY " "





--Traffic Control by Time of Day---------------------------------------------------
WITH data as(
SELECT CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END as " "
,coalesce(sum(CASE WHEN (date_part('hour',accd_tme) between 0 and 2) and right(accd_tme::text,8)!= '00:00:00'  THEN num_of_inj END),0) AS "00:00-03:00" 
,coalesce(sum(CASE WHEN date_part('hour',accd_tme) between 3 and 5 THEN num_of_inj END),0) AS "03:00-06:00" 
,coalesce(sum(CASE WHEN date_part('hour',accd_tme) between 6 and 8 THEN num_of_inj END),0) AS "06:00-09:00" 
,coalesce(sum(CASE WHEN date_part('hour',accd_tme) between 9 and 11 THEN num_of_inj END),0) AS "09:00-12:00" 
,coalesce(sum(CASE WHEN date_part('hour',accd_tme) between 12 and 14 THEN num_of_inj END),0) AS "12:00-15:00" 
,coalesce(sum(CASE WHEN date_part('hour',accd_tme) between 15 and 17 THEN num_of_inj END),0) AS "15:00-18:00" 
,coalesce(sum(CASE WHEN date_part('hour',accd_tme) between 18 and 20 THEN num_of_inj END),0) AS "18:00-21:00" 
,coalesce(sum(CASE WHEN date_part('hour',accd_tme) between 21 and 23 THEN num_of_inj END),0) AS "21:00-24:00" 
,coalesce(sum(CASE WHEN date_part('hour',accd_tme) = 0 and date_part('minute',accd_tme) = 0 THEN num_of_inj END),0) AS "Unknown"
FROM advanced_crashes_1640 
GROUP BY CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END
ORDER BY " ")


SELECT * FROM ( SELECT data.*, "00:00-03:00" + "03:00-06:00"  + "06:00-09:00"  + "09:00-12:00"  +  "12:00-15:00"  + "15:00-18:00" + "18:00-21:00" + "21:00-24:00" + "Unknown" Total
                FROM data

                UNION 

                SELECT tot.*, "00:00-03:00" + "03:00-06:00"  + "06:00-09:00"  + "09:00-12:00"  +  "12:00-15:00"  + "15:00-18:00" + "18:00-21:00" + "21:00-24:00" + "Unknown" Total
                FROM (SELECT 'Total' as " " 
                      ,sum(data."00:00-03:00") "00:00-03:00"
                      ,sum(data."03:00-06:00") "03:00-06:00"
                      ,sum(data."06:00-09:00") "06:00-09:00"
                      ,sum(data."09:00-12:00") "09:00-12:00"
                      ,sum(data."12:00-15:00") "12:00-15:00"
                      ,sum(data."15:00-18:00") "15:00-18:00"
                      ,sum(data."18:00-21:00") "18:00-21:00"
                      ,sum(data."21:00-24:00") "21:00-24:00"
                      ,sum(data."Unknown") "Unknown"
                      FROM data
                    ) tot

		)traf_time_of_day
ORDER BY " "









--Traffic Control by Ped Action---------------------------------------------------
WITH data as(
SELECT CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END as " "
,coalesce(sum(CASE WHEN ped_actn = '01' and accd_type_int = 1 THEN num_of_inj END),0) as "Crossing WITH Signal"
,coalesce(sum(CASE WHEN ped_actn = '02' and accd_type_int = 1 THEN num_of_inj END),0) as "Crossing Against Signal"
,coalesce(sum(CASE WHEN ped_actn = '03' and accd_type_int = 1 THEN num_of_inj END),0) as "Crossing No Signal Marked Crosswalk"
,coalesce(sum(CASE WHEN ped_actn = '04' and accd_type_int = 1 THEN num_of_inj END),0) as "Crossing No Signal or Crosswalk"
,coalesce(sum(CASE WHEN ped_actn not in ('01','02','03','04','??','YY','XX','ZZ') and accd_type_int = 1 THEN num_of_inj END),0) as "Others"
,coalesce(sum(CASE WHEN ped_actn in ('??','YY','XX', 'ZZ') and accd_type_int = 1  THEN num_of_inj END),0) as "UnKnown"
,coalesce(sum(CASE WHEN accd_type_int != 1  THEN num_of_inj END),0) as "NA"
FROM advanced_crashes_1640 
GROUP BY CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END
ORDER BY " ")


SELECT * FROM ( SELECT data.*, "Crossing WITH Signal" + "Crossing Against Signal" + "Crossing No Signal Marked Crosswalk" + "Crossing No Signal or Crosswalk" +  "Others" + "UnKnown" + "NA"Total
                FROM data

                UNION 

                SELECT tot.*, "Crossing WITH Signal" + "Crossing Against Signal" + "Crossing No Signal Marked Crosswalk" + "Crossing No Signal or Crosswalk" +  "Others" + "UnKnown" + "NA" Total
                FROM (SELECT 'Total' as " "
                      ,sum(data."Crossing WITH Signal") "Crossing WITH Signal"
                      ,sum(data."Crossing Against Signal") "Crossing Against Signal"
                      ,sum(data."Crossing No Signal Marked Crosswalk") "Crossing No Signal Marked Crosswalk"
                      ,sum(data."Crossing No Signal or Crosswalk") "Crossing No Signal or Crosswalk"
                      ,sum(data."Others") "Others"
                      ,sum(data."UnKnown") "UnKnown"
                      ,sum(data."NA") "NA"
                      FROM data
                    ) tot

		)traf_ped_action
ORDER BY " "





--Traffic Control by Severity---------------------------------------------------



WITH data AS(
SELECT CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END as " "
,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%A%' THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text)) END),0) AS "A"
,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%B%' THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'B'::text, ''::text)) END),0) AS"B"
,coalesce(sum(CASE WHEN (ext_of_inj::text) like '%C%' THEN length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'C'::text, ''::text)) END),0) AS "C"
,coalesce(sum(CASE WHEN coalesce(length(ext_of_inj::text),0) != num_of_inj THEN (num_of_inj + num_of_fat) - coalesce(length(ext_of_inj::text),0) END),0) AS "UNKNOWN"
FROM advanced_crashes_1640 
GROUP BY CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END
ORDER BY " ")


SELECT * FROM ( SELECT data.*, "A" + "B" + "C" + "UNKNOWN" Total
                FROM data

                UNION 

                SELECT tot.*, "A" + "B" + "C" + "UNKNOWN" Total
                FROM (SELECT 'Total' as " " 
                      ,sum(data."A") "A"
                      ,sum(data."B") "B"
                      ,sum(data."C") "C"
                      ,sum(data."UNKNOWN") "UNKNOWN"
                      FROM data
                    ) tot

		)traf_sev
ORDER BY " "






--Traffic Control by Loc---------------------------------------------------

WITH data as(
SELECT CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN'  
	    ELSE '001. NONE' END as " "
,coalesce(sum(CASE WHEN loc = 'MID' then num_of_inj END),0) "MID"
,coalesce(sum(CASE WHEN loc = 'INT' then num_of_inj END),0) "INT"
,coalesce(sum(CASE WHEN loc = 'H' then num_of_inj END),0) "H"
FROM advanced_crashes_1640 
GROUP BY CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END
ORDER BY " ")


SELECT * FROM ( SELECT data.*, "MID" + "INT" + "H" Total
                FROM data

                UNION 

                SELECT tot.*, "MID" + "INT" + "H" Total
                FROM (SELECT 'Total' as " " 
                      ,sum(data."MID") "MID"
                      ,sum(data."INT") "INT" 
                      ,sum(data."H") "H"
                      FROM data
                    ) tot

		)traf_loc	
ORDER BY " "









--Traffic Control by Mode---------------------------------------------------

WITH data as(
SELECT CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN'  
	    ELSE '001. NONE' END as " "
,coalesce(sum(CASE WHEN accd_type_int = 1 then num_of_inj END),0) "PEDESTRIAN"
,coalesce(sum(CASE WHEN accd_type_int = 2 then num_of_inj END),0) "BICYCLIST"
,coalesce(sum(CASE WHEN accd_type_int = 3 then num_of_inj END),0) "MOTOR VEHICLE"
FROM advanced_crashes_1640 
GROUP BY CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END
ORDER BY " ")


SELECT * FROM ( SELECT data.*, "PEDESTRIAN" + "BICYCLIST" + "MOTOR VEHICLE" Total
                FROM data

                UNION 

                SELECT tot.*, "PEDESTRIAN" + "BICYCLIST" + "MOTOR VEHICLE" Total
                FROM (SELECT 'Total' as " " 
                      ,sum(data."PEDESTRIAN") "PEDESTRIAN"
                      ,sum(data."BICYCLIST") "BICYCLIST"
                      ,sum(data."MOTOR VEHICLE") "MOTOR VEHICLE"
                      FROM data
                    ) tot

		)traf_mode
ORDER BY " "










--Traffic Control by TAXI/LIVERY---------------------------------------------------



WITH data as(
SELECT CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN'  
	    ELSE '001. NONE' END as " "
,coalesce(sum(CASE WHEN nys_v2.crashid1 is not null and nys_v2.crashid2 is null then num_of_inj END),0) "OTHERS"
,coalesce(sum(CASE WHEN nys_v1.crashid is not null then num_of_inj END),0) "TAXI/LIVERY"
FROM advanced_crashes_1640 
--This join to nys_v1 is included to retrieve all the crashids with a vehicle type of taxi/livery
LEFT JOIN (SELECT DISTINCT crashid
           FROM archive."2019_11_13_nysdot_vehicle"
           WHERE case_yr BETWEEN 2013 and 2017
           and rgst_typ in ('54','55')
           ) nys_v1
     on advanced_crashes_1640.crashid = nys_v1.crashid
--This join to nys_v2 is included because if a crash has at least one vehicle typed as taxi/livery, it is not included
LEFT JOIN (SELECT DISTINCT n1.crashid crashid1, n2.crashid crashid2 
           FROM archive."2019_11_13_nysdot_vehicle" n1
           LEFT JOIN (SELECT distinct crashid
		      FROM archive."2019_11_13_nysdot_vehicle"
		      WHERE case_yr BETWEEN 2013 and 2017
		      and rgst_typ in ('54','55')) n2
	   on n1.crashid = n2.crashid
           WHERE case_yr BETWEEN 2013 and 2017          
	   ) nys_v2
    on advanced_crashes_1640.crashid = nys_v2.crashid1
GROUP BY CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END 
ORDER BY " ")


SELECT * FROM ( SELECT data.*, "OTHERS" + "TAXI/LIVERY" Total
                FROM data

                UNION 

                SELECT tot.*, "OTHERS" + "TAXI/LIVERY" Total
                FROM (SELECT 'Total' as " " 
                      ,sum(data."OTHERS") "OTHERS"
                      ,sum(data."TAXI/LIVERY") "TAXI/LIVERY"
                      FROM data
                    ) tot

		)traf_taxi_livery
ORDER BY " "




--Traffic Control by Vehicle Type---------------------------------------------------




WITH data AS (
SELECT CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END as " "
,coalesce(sum(CASE WHEN veh_typ = '1' and accd_typ != '01' THEN num_of_inj END),0) "MOTORCYCLE"
,coalesce(sum(CASE WHEN veh_typ = '2' and accd_typ != '01' THEN num_of_inj END),0) "CAR/VAN/PICKUP"
,coalesce(sum(CASE WHEN veh_typ = '3' and accd_typ != '01' THEN num_of_inj END),0) "TRUCK"
,coalesce(sum(CASE WHEN veh_typ = '4' and accd_typ != '01' THEN num_of_inj END),0) "BUS"
,coalesce(sum(CASE WHEN accd_typ = '01' or veh_typ = '0' THEN num_of_inj END),0) "Unknown"
FROM advanced_crashes_1640
LEFT JOIN (SELECT distinct crashid
			  ,count(CASE WHEN veh_typ not in ('5','6') THEN 1 END) veh_count
			  ,STRING_AGG(veh_typ,' ') veh_typ
           FROM archive."2019_11_13_nysdot_vehicle"
           WHERE case_yr BETWEEN 2013 and 2017
           and veh_typ not in ('5','6')
           GROUP BY crashid
           ) nys_v
     on advanced_crashes_1640.crashid = nys_v.crashid  
GROUP BY CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END 
ORDER BY " ")



SELECT * FROM ( SELECT data.*, "MOTORCYCLE" + "CAR/VAN/PICKUP" + "TRUCK" + "BUS" + "Unknown" Total
                FROM data

                UNION 

                SELECT tot.*,  "MOTORCYCLE" + "CAR/VAN/PICKUP" + "TRUCK" + "BUS" + "Unknown" Total
                FROM (SELECT 'Total' as " "
                      ,sum(data."MOTORCYCLE") "MOTORCYCLE"
                      ,sum(data."CAR/VAN/PICKUP") "CAR/VAN/PICKUP"
                      ,sum(data."TRUCK") "TRUCK"
                      ,sum(data."BUS") "BUS"
                      ,sum(data."Unknown") "Unknown"
                      FROM data
                    ) tot

		)traf_veh_type
ORDER BY " "


--Traffic Control by MVO Pre Action---------------------------------------------------


--METHOD 1
WITH data AS (
SELECT CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END as " "
,coalesce(sum(CASE WHEN pre_accd_actn = '03' and veh_count = 1 THEN num_of_inj END),0) "Left Turn"
,coalesce(sum(CASE WHEN pre_accd_actn = '02' and veh_count = 1 THEN num_of_inj END),0) "Right Turn"
,coalesce(sum(CASE WHEN pre_accd_actn = '01' and veh_count = 1 THEN num_of_inj END),0) "Going Straight"
,coalesce(sum(CASE WHEN pre_accd_actn = '04' and veh_count = 1 THEN num_of_inj END),0) "Making U Turn"
,coalesce(sum(CASE WHEN pre_accd_actn = '15' and veh_count = 1 THEN num_of_inj END),0) "Backing"
,coalesce(sum(CASE WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') and veh_count = 1 THEN num_of_inj END),0) "Other"  
,coalesce(sum(CASE WHEN pre_accd_actn in ('??','YY','XX', 'ZZ') or veh_count >1 THEN num_of_inj END),0) "Unknown"
FROM advanced_crashes_1640
LEFT JOIN (SELECT distinct crashid
			  ,count(CASE WHEN veh_typ not in ('5','6') THEN 1 END) veh_count
			  ,STRING_AGG(pre_accd_actn,' ') pre_accd_actn
           FROM archive."2019_11_13_nysdot_vehicle"
           WHERE case_yr BETWEEN 2013 and 2017
           and veh_typ not in ('5','6')
           GROUP BY crashid
           ) nys_v
      on advanced_crashes_1640.crashid = nys_v.crashid
GROUP BY CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END
ORDER BY " ")


SELECT * FROM ( SELECT data.*, "Left Turn" + "Right Turn" + "Going Straight" + "Making U Turn" + "Backing" + "Other" + "Unknown" Total
                FROM data

                UNION 

                SELECT tot.*,  "Left Turn" + "Right Turn" + "Going Straight" + "Making U Turn" + "Backing" + "Other" + "Unknown" Total
                FROM (SELECT 'Total' as " " 
                      ,sum(data."Left Turn") "Left Turn"
                      ,sum(data."Right Turn") "Right Turn"
                      ,sum(data."Going Straight") "Going Straight"
                      ,sum(data."Making U Turn") "Making U Turn"
                      ,sum(data."Backing") "Backing"
                      ,sum(data."Other" ) "Other" 
                      ,sum(data."Unknown") "Unknown"
                      FROM data
                    ) tot

		)traf_mvo_pre_action
ORDER BY " "





-- METHOD 2
WITH data1 AS (

--Getting All Unknowns:
--Unknowns are either when pre_accd_actn is in ('??','YY','XX', 'ZZ') or when accd_typ_int= 01
--We dont want any double counts so we distinct on crashid and num_of_inj
SELECT CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END as " "
	    ,sum(t1.num_of_inj) "Unknown"
FROM advanced_crashes_1640
RIGHT JOIN(SELECT distinct advanced_crashes_1640.crashid, num_of_inj
	   FROM advanced_crashes_1640 
	   LEFT JOIN (SELECT distinct crashid, pre_accd_actn
		      FROM archive."2019_11_13_nysdot_vehicle"
		      WHERE case_yr BETWEEN 2013 and 2017
		      and veh_typ not in ('5','6')
		      ) nys_v
	   on advanced_crashes_1640.crashid = nys_v.crashid
	   WHERE (accd_typ = '01' or pre_accd_actn in ('??','YY','XX', 'ZZ'))
	   and num_of_inj != 0) t1
on advanced_crashes_1640.crashid = t1.crashid 
GROUP BY CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END 
ORDER BY " ")



,data2 AS(
--All known data
SELECT x.*, coalesce(data1."Unknown",0) "Unknown" FROM (
SELECT CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END as " "
,coalesce(sum(CASE WHEN pre_accd_actn = '03' and accd_typ != '01' THEN num_of_inj END),0) "Left Turn"
,coalesce(sum(CASE WHEN pre_accd_actn = '02' and accd_typ != '01' THEN num_of_inj END),0) "Right Turn"
,coalesce(sum(CASE WHEN pre_accd_actn = '01' and accd_typ != '01' THEN num_of_inj END),0) "Going Straight"
,coalesce(sum(CASE WHEN pre_accd_actn = '04' and accd_typ != '01' THEN num_of_inj END),0) "Making U Turn"
,coalesce(sum(CASE WHEN pre_accd_actn = '15' and accd_typ != '01' THEN num_of_inj END),0) "Backing"
,coalesce(sum(CASE WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') and accd_typ != '01' THEN num_of_inj END),0) "Other"  
FROM advanced_crashes_1640
LEFT JOIN (SELECT distinct crashid, pre_accd_actn
           FROM archive."2019_11_13_nysdot_vehicle"
           WHERE case_yr BETWEEN 2013 and 2017
           and veh_typ not in ('5','6')
           ) nys_v
     on advanced_crashes_1640.crashid = nys_v.crashid
GROUP BY CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END

) x
LEFT JOIN data1 
on x." " = data1." "
ORDER BY x." ")


SELECT * FROM ( SELECT data2.*, "Left Turn" + "Right Turn" + "Going Straight" + "Making U Turn" + "Backing" + "Other" + "Unknown" Total
                FROM data2

                UNION 

                SELECT tot.*,  "Left Turn" + "Right Turn" + "Going Straight" + "Making U Turn" + "Backing" + "Other" + "Unknown" Total
                FROM (SELECT 'Total' as " "
                      ,sum(data2."Left Turn") "Left Turn"
                      ,sum(data2."Right Turn") "Right Turn"
                      ,sum(data2."Going Straight") "Going Straight"
                      ,sum(data2."Making U Turn") "Making U Turn"
                      ,sum(data2."Backing") "Backing"
                      ,sum(data2."Other" ) "Other" 
                      ,sum(data2."Unknown") "Unknown"
                      FROM data2
                    ) tot

		)traf_mvo_pre_action
ORDER BY " "








--Traffic Control by Bike Pre Action---------------------------------------------------


WITH data as(
SELECT CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN'  
	    ELSE '001. NONE' END as " "
,coalesce(sum(CASE WHEN pre_accd_actn = '03' and accd_type_int = 2 THEN num_of_inj END),0) "Left Turn"
,coalesce(sum(CASE WHEN pre_accd_actn = '02' and accd_type_int = 2 THEN num_of_inj END),0) "Right Turn"
,coalesce(sum(CASE WHEN pre_accd_actn = '01' and accd_type_int = 2 THEN num_of_inj END),0) "Going Straight"
,coalesce(sum(CASE WHEN pre_accd_actn = '04' and accd_type_int = 2 THEN num_of_inj END),0) "Making U Turn"
,coalesce(sum(CASE WHEN pre_accd_actn = '15' and accd_type_int = 2 THEN num_of_inj END),0) "Backing"
,coalesce(sum(CASE WHEN pre_accd_actn not in ('01','02','03','04','15','??','YY','ZZ') and accd_type_int = 2 THEN num_of_inj END),0) "Other"  
,coalesce(sum(CASE WHEN pre_accd_actn in ('??','YY','XX', 'ZZ') and accd_type_int = 2 THEN num_of_inj END),0) "Unknown"
,coalesce(sum(CASE WHEN accd_type_int != 2  THEN num_of_inj END),0) as "NA"
FROM advanced_crashes_1640 
LEFT JOIN (SELECT distinct crashid, pre_accd_actn
           FROM archive."2019_11_13_nysdot_vehicle"
           WHERE case_yr BETWEEN 2013 and 2017
           and veh_typ = '5'
           ) nys_v
     on advanced_crashes_1640.crashid = nys_v.crashid
GROUP BY CASE WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' 
	    ELSE '001. NONE' END 
ORDER BY " ")


SELECT * FROM ( SELECT data.*, "Left Turn" + "Right Turn" + "Going Straight" + "Making U Turn" + "Backing" + "Other" + "Unknown" + "NA" Total
                FROM data

                UNION 

                SELECT tot.*,  "Left Turn" + "Right Turn" + "Going Straight" + "Making U Turn" + "Backing" + "Other" + "Unknown" + "NA" Total
                FROM (SELECT 'Total' as " "
                      ,sum(data."Left Turn") "Left Turn"
                      ,sum(data."Right Turn") "Right Turn"
                      ,sum(data."Going Straight") "Going Straight"
                      ,sum(data."Making U Turn") "Making U Turn"
                      ,sum(data."Backing") "Backing"
                      ,sum(data."Other" ) "Other" 
                      ,sum(data."Unknown") "Unknown"
                      ,sum(data."NA") "NA"
                      FROM data
                    ) tot

		)traf_bike_pre_action
ORDER BY " "










--Traffic Control by Age---------------------------------------------------

WITH data as(

SELECT " "
,coalesce(sum(CASE WHEN ages = 'Children(1-17)' THEN num_of_inj END),0) "Children(1-17)"
,coalesce(sum(CASE WHEN ages = 'Young Adults(18-29)' THEN num_of_inj END),0) "Young Adults(18-29)"
,coalesce(sum(CASE WHEN ages = 'Adults(30-64)' THEN num_of_inj END),0) "Adults(30-64)"
,coalesce(sum(CASE WHEN ages = 'Seniors(65-120)' THEN num_of_inj END),0) "Seniors(65-120)"
,coalesce(sum(CASE WHEN ages = 'Unknown' THEN num_of_inj END),0) "Unknown"
,coalesce(sum(CASE WHEN ages = 'NA' THEN num_of_inj END),0) "NA"
FROM(
SELECT CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END as " "
,CASE WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 1 and 17 and num_of_inj = 1 and ped_count=1 THEN 'Children(1-17)'
     WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 1 and 17 and num_of_inj = 1 and bike_count=1 THEN 'Children(1-17)' 
     WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 18 and 29 and num_of_inj = 1 and ped_count=1 THEN 'Young Adults(18-29)'
     WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 18 and 29 and num_of_inj = 1 and bike_count=1 THEN 'Young Adults(18-29)'
     WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 30 and 64 and num_of_inj = 1 and ped_count=1 THEN 'Adults(30-64)'
     WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 30 and 64 and num_of_inj = 1 and bike_count=1 THEN 'Adults(30-64)'
     WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 65 and 120 and num_of_inj = 1 and ped_count=1 THEN 'Seniors(65-120)'
     WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 65 and 120 and num_of_inj = 1 and bike_count=1 THEN 'Seniors(65-120)'
     WHEN accd_type_int = 3 THEN 'NA'
     ELSE 'Unknown' END "ages"
,advanced_crashes_1640.crashid
,advanced_crashes_1640.num_of_inj
FROM advanced_crashes_1640 
LEFT JOIN (SELECT distinct crashid
			  ,count(CASE WHEN veh_typ = '5' THEN 1 END) bike_count
			  ,count(CASE WHEN veh_typ = '6' THEN 1 END) ped_count
			  ,sum(CASE WHEN veh_typ = '5' THEN age END) bike_age
			  ,sum(CASE WHEN veh_typ = '6' THEN age END) ped_age
           FROM archive."2019_11_13_nysdot_vehicle"
           WHERE case_yr BETWEEN 2013 and 2017
           and veh_typ in ('5','6') 
           GROUP BY crashid
           ) nys_v_age
     on advanced_crashes_1640.crashid = nys_v_age.crashid   
GROUP BY CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END
      ,CASE WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 1 and 17 and num_of_inj = 1 and ped_count=1 THEN 'Children(1-17)'
            WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 1 and 17 and num_of_inj = 1 and bike_count=1 THEN 'Children(1-17)' 
            WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 18 and 29 and num_of_inj = 1 and ped_count=1 THEN 'Young Adults(18-29)'
            WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 18 and 29 and num_of_inj = 1 and bike_count=1 THEN 'Young Adults(18-29)'
            WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 30 and 64 and num_of_inj = 1 and ped_count=1 THEN 'Adults(30-64)'
            WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 30 and 64 and num_of_inj = 1 and bike_count=1 THEN 'Adults(30-64)'
            WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 65 and 120 and num_of_inj = 1 and ped_count=1 THEN 'Seniors(65-120)'
            WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 65 and 120 and num_of_inj = 1 and bike_count=1 THEN 'Seniors(65-120)'
            WHEN accd_type_int = 3 THEN 'NA'
            ELSE 'Unknown' END 
      ,advanced_crashes_1640.crashid
      ,advanced_crashes_1640.num_of_inj
ORDER BY " "
) sub_age
GROUP BY " "

)



SELECT * FROM ( SELECT data.*, "Children(1-17)" + "Young Adults(18-29)" + "Adults(30-64)" + "Seniors(65-120)" + "Unknown" + "NA" Total
                FROM data

                UNION 

                SELECT tot.*, "Children(1-17)" + "Young Adults(18-29)" + "Adults(30-64)" + "Seniors(65-120)" + "Unknown" + "NA" Total
                FROM (SELECT 'Total' as " " 
                      ,sum(data."Children(1-17)") "Children(1-17)"
                      ,sum(data."Young Adults(18-29)") "Young Adults(18-29)"
                      ,sum(data."Adults(30-64)") "Adults(30-64)"
                      ,sum(data."Seniors(65-120)") "Seniors(65-120)"
                      ,sum(data."Unknown") "Unknown"
                      ,sum(data."NA") "NA" 
                      FROM data
                    ) tot

		)traf_age
ORDER BY " "

















SELECT CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END as " "
,coalesce(sum(CASE WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 1 and 17 and num_of_inj = 1 and ped_count=1 THEN 1 
		   WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 1 and 17 and num_of_inj = 1 and bike_count=1 THEN 1 
	 	   END),0) "Children(1-17)"
,coalesce(sum(CASE WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 18 and 29 and num_of_inj = 1 and ped_count=1 THEN 1 
	           WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 18 and 29 and num_of_inj = 1 and bike_count=1 THEN 1 
		   END),0) "Young Adults(18-29)"
,coalesce(sum(CASE WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 30 and 64 and num_of_inj = 1 and ped_count=1 THEN 1 
	           WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 30 and 64 and num_of_inj = 1 and bike_count=1 THEN 1 
		   END),0) "Seniors(65-120)"
,coalesce(sum(CASE WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 65 and 120 and num_of_inj = 1 and ped_count=1 THEN 1 
	           WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 65 and 120 and num_of_inj = 1 and bike_count=1 THEN 1 
		   END),0) "Seniors(65-120)"
--,coalesce(sum(CASE WHEN (nys_v_age.age is null or nys_v_age.age = 0 or num_of_inj>1 or nys_v_age.bike_count > 1 or nys_v_age.ped_count > 1)  and accd_type_int != 3 THEN num_of_inj END),0) "Unknown" 
,coalesce(sum(CASE WHEN (num_of_inj>1 or nys_v_age.bike_count > 1 or nys_v_age.ped_count > 1)  and accd_type_int != 3 THEN num_of_inj END),0) "Unknown" 
,coalesce(sum(CASE WHEN accd_type_int = 3 THEN num_of_inj END),0) "NA"
FROM advanced_crashes_1640 
LEFT JOIN (SELECT distinct crashid
			  ,count(CASE WHEN veh_typ = '5' THEN 1 END) bike_count
			  ,count(CASE WHEN veh_typ = '6' THEN 1 END) ped_count
			  ,sum(CASE WHEN veh_typ = '5' THEN age END) bike_age
			  ,sum(CASE WHEN veh_typ = '6' THEN age END) ped_age
           FROM archive."2019_11_13_nysdot_vehicle"
           WHERE case_yr BETWEEN 2013 and 2017
           and veh_typ in ('5','6') 
           GROUP BY crashid
           ) nys_v_age
     on advanced_crashes_1640.crashid = nys_v_age.crashid   
GROUP BY CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END
ORDER BY " "












SELECT " "
,coalesce(sum(CASE WHEN ages = 'Children(1-17)' THEN num_of_inj END),0) "Children(1-17)"
,coalesce(sum(CASE WHEN ages = 'Young Adults(18-29)' THEN num_of_inj END),0) "Young Adults(18-29)"
,coalesce(sum(CASE WHEN ages = 'Adults(30-64)' THEN num_of_inj END),0) "Children(1-17)"
,coalesce(sum(CASE WHEN ages = 'Seniors(65-120)' THEN num_of_inj END),0) "Seniors(65-120)"
,coalesce(sum(CASE WHEN ages = 'Unknown' THEN num_of_inj END),0) "Unknown"
,coalesce(sum(CASE WHEN ages = 'NA' THEN num_of_inj END),0) "NA"
FROM(
SELECT CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END as " "
,CASE WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 1 and 17 and num_of_inj = 1 and ped_count=1 THEN 'Children(1-17)'
     WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 1 and 17 and num_of_inj = 1 and bike_count=1 THEN 'Children(1-17)' 
     WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 18 and 29 and num_of_inj = 1 and ped_count=1 THEN 'Young Adults(18-29)'
     WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 18 and 29 and num_of_inj = 1 and bike_count=1 THEN 'Young Adults(18-29)'
     WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 30 and 64 and num_of_inj = 1 and ped_count=1 THEN 'Adults(30-64)'
     WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 30 and 64 and num_of_inj = 1 and bike_count=1 THEN 'Adults(30-64)'
     WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 65 and 120 and num_of_inj = 1 and ped_count=1 THEN 'Seniors(65-120)'
     WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 65 and 120 and num_of_inj = 1 and bike_count=1 THEN 'Seniors(65-120)'
     WHEN accd_type_int = 3 THEN 'NA'
     ELSE 'Unknown' END "ages"
,advanced_crashes_1640.crashid
,advanced_crashes_1640.num_of_inj
FROM advanced_crashes_1640 
LEFT JOIN (SELECT distinct crashid
			  ,count(CASE WHEN veh_typ = '5' THEN 1 END) bike_count
			  ,count(CASE WHEN veh_typ = '6' THEN 1 END) ped_count
			  ,sum(CASE WHEN veh_typ = '5' THEN age END) bike_age
			  ,sum(CASE WHEN veh_typ = '6' THEN age END) ped_age
           FROM archive."2019_11_13_nysdot_vehicle"
           WHERE case_yr BETWEEN 2013 and 2017
           and veh_typ in ('5','6') 
           GROUP BY crashid
           ) nys_v_age
     on advanced_crashes_1640.crashid = nys_v_age.crashid   
GROUP BY CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END
      ,CASE WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 1 and 17 and num_of_inj = 1 and ped_count=1 THEN 'Children(1-17)'
            WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 1 and 17 and num_of_inj = 1 and bike_count=1 THEN 'Children(1-17)' 
            WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 18 and 29 and num_of_inj = 1 and ped_count=1 THEN 'Young Adults(18-29)'
            WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 18 and 29 and num_of_inj = 1 and bike_count=1 THEN 'Young Adults(18-29)'
            WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 30 and 64 and num_of_inj = 1 and ped_count=1 THEN 'Adults(30-64)'
            WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 30 and 64 and num_of_inj = 1 and bike_count=1 THEN 'Adults(30-64)'
            WHEN accd_type_int = 1 and nys_v_age.ped_age::int between 65 and 120 and num_of_inj = 1 and ped_count=1 THEN 'Seniors(65-120)'
            WHEN accd_type_int = 2 and nys_v_age.bike_age::int between 65 and 120 and num_of_inj = 1 and bike_count=1 THEN 'Seniors(65-120)'
            WHEN accd_type_int = 3 THEN 'NA'
            ELSE 'Unknown' END 
      ,advanced_crashes_1640.crashid
      ,advanced_crashes_1640.num_of_inj
ORDER BY " "
) sub_age
GROUP BY " "



--Traffic Control by Sex---------------------------------------------------

WITH data as(
SELECT " "
,coalesce(sum(CASE WHEN sex = 'F' THEN num_of_inj END),0) "FEMALE"
,coalesce(sum(CASE WHEN sex = 'M' THEN num_of_inj END),0) "MALE"
,coalesce(sum(CASE WHEN sex = 'Unknown' THEN num_of_inj END),0) "Unknown"
,coalesce(sum(CASE WHEN sex = 'NA' THEN num_of_inj END),0) "NA"
FROM(
SELECT CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END as " "
,CASE WHEN accd_type_int = 1 and nys_v_sex.ped_sex = 'M' and ped_count=1 and num_of_inj = 1 THEN 'M'
      WHEN accd_type_int = 2 and nys_v_sex.bike_sex = 'M' and bike_count=1 and num_of_inj = 1 THEN 'M' 
      WHEN accd_type_int = 1 and nys_v_sex.ped_sex = 'F' and ped_count=1 and num_of_inj = 1 THEN 'F'
      WHEN accd_type_int = 2 and nys_v_sex.bike_sex = 'F' and bike_count=1 and num_of_inj = 1 THEN 'F'
      WHEN accd_type_int = 3 THEN 'NA'  
      ELSE 'Unknown' END "sex"     
,advanced_crashes_1640.crashid
,advanced_crashes_1640.num_of_inj
FROM advanced_crashes_1640 
LEFT JOIN (SELECT distinct crashid
			  ,count(CASE WHEN veh_typ = '5' THEN 1 END) bike_count
			  ,count(CASE WHEN veh_typ = '6' THEN 1 END) ped_count
			  ,STRING_AGG(CASE WHEN veh_typ = '5' THEN sex END,' ') bike_sex
			  ,STRING_AGG(CASE WHEN veh_typ = '6' THEN sex END,' ') ped_sex
           FROM archive."2019_11_13_nysdot_vehicle"
           WHERE case_yr BETWEEN 2013 and 2017
           and veh_typ in ('5','6') 
           GROUP BY crashid
           ) nys_v_sex
     on advanced_crashes_1640.crashid = nys_v_sex.crashid  
GROUP BY CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	      WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	      WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	      WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	      WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	      WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	      WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	      WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	      WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	      WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	      WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	      WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	      WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	      WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	      WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	      WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	      WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	      WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	      WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	      WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	      WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END
	,CASE WHEN accd_type_int = 1 and nys_v_sex.ped_sex = 'M' and ped_count=1 and num_of_inj = 1 THEN 'M'
              WHEN accd_type_int = 2 and nys_v_sex.bike_sex = 'M' and bike_count=1 and num_of_inj = 1 THEN 'M' 
              WHEN accd_type_int = 1 and nys_v_sex.ped_sex = 'F' and ped_count=1 and num_of_inj = 1 THEN 'F'
              WHEN accd_type_int = 2 and nys_v_sex.bike_sex = 'F' and bike_count=1 and num_of_inj = 1 THEN 'F'
              WHEN accd_type_int = 3 THEN 'NA'
              ELSE 'Unknown' END 
        ,advanced_crashes_1640.crashid
	,advanced_crashes_1640.num_of_inj

ORDER BY " "
) sub_sex
GROUP BY " "
)

SELECT * FROM ( SELECT data.*, "FEMALE" + "MALE" + "Unknown" + "NA" Total
                FROM data

                UNION 

                SELECT tot.*, "FEMALE" + "MALE" + "Unknown" + "NA" Total
                FROM (SELECT 'Total' as " "
                      ,sum(data."FEMALE" ) "FEMALE"
                      ,sum(data."MALE") "MALE"
                      ,sum(data."Unknown") "Unknown"
                      ,sum(data."NA") "NA" 
                      FROM data
                    ) tot
		)traf_sex
ORDER BY " "
































WITH data as(
SELECT CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END as " "
,coalesce(sum(CASE WHEN nys_v_sex.sex = 'F' and num_of_inj = 1 and accd_type_int != 3 THEN num_of_inj END),0) "Female"
,coalesce(sum(CASE WHEN nys_v_sex.sex = 'M' and num_of_inj = 1 and accd_type_int != 3 THEN num_of_inj END),0) "Male"
,coalesce(sum(CASE WHEN (coalesce(nys_v_sex.sex,'u') not in ('M','F') or num_of_inj>1 or (m_count = 1 and f_count = 1) ) 
and accd_type_int != 3 THEN num_of_inj END),0) "Unknown" 
,coalesce(sum(CASE WHEN accd_type_int = 3 THEN num_of_inj END),0) "NA"--, nys_v_sex.crashid
FROM advanced_crashes_1640 
LEFT JOIN (SELECT distinct crashid
			  ,count(CASE WHEN sex = 'M' THEN 1 END) m_count
			  ,STRING_AGG(sex,' ') sex
			  ,count(CASE WHEN sex = 'F' THEN 1 END) f_count
           FROM archive."2019_11_13_nysdot_vehicle"
           WHERE case_yr BETWEEN 2013 and 2017
           and veh_typ in ('5','6')
           --and crashid ='361660362015'
           GROUP BY crashid
           ) nys_v_sex
     on advanced_crashes_1640.crashid = nys_v_sex.crashid   
GROUP BY CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END--, nys_v_sex.crashid
ORDER BY " "
)



SELECT * FROM ( SELECT data.*, "Female" + "Male" + "Unknown" + "NA" Total
                FROM data

                UNION 

                SELECT tot.*, "Female" + "Male" + "Unknown" + "NA" Total
                FROM (SELECT 'Total' as " "
                      ,sum(data."Female" ) "Female"
                      ,sum(data."Male") "Male"
                      ,sum(data."Unknown") "Unknown"
                      ,sum(data."NA") "NA" 
                      FROM data
                    ) tot

		)traf_sex
ORDER BY " "








SELECT CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END as " "
,coalesce(sum(CASE WHEN nys_v_sex.sex = 'F' and num_of_inj = 1 and accd_type_int != 3 THEN num_of_inj END),0) "Female"
,coalesce(sum(CASE WHEN nys_v_sex.sex = 'M' and num_of_inj = 1 and accd_type_int != 3 THEN num_of_inj END),0) "Male"
,coalesce(sum(CASE WHEN (coalesce(nys_v_sex.sex,'u') not in ('M','F') or num_of_inj>1 or (m_count = 1 and f_count = 1) ) 
and accd_type_int != 3 THEN num_of_inj END),0) "Unknown" 
,coalesce(sum(CASE WHEN accd_type_int = 3 THEN num_of_inj END),0) "NA"--, nys_v_sex.crashid
FROM advanced_crashes_1640 
LEFT JOIN (SELECT distinct crashid
			  ,count(CASE WHEN sex = 'M' THEN 1 END) m_count
			  ,STRING_AGG(sex,' ') sex
			  ,count(CASE WHEN sex = 'F' THEN 1 END) f_count
           FROM archive."2019_11_13_nysdot_vehicle"
           WHERE case_yr BETWEEN 2013 and 2017
           and veh_typ in ('5','6')
           --and crashid ='361660362015'
           GROUP BY crashid
           ) nys_v_sex
     on advanced_crashes_1640.crashid = nys_v_sex.crashid   
GROUP BY CASE WHEN TRAF_CNTL = '01' THEN '001. NONE'
	    WHEN TRAF_CNTL = '02' THEN '002. TRAFFIC SIGNAL'
	    WHEN TRAF_CNTL = '03' THEN '003. STOP SIGN'
	    WHEN TRAF_CNTL = '04' THEN '004. FLASHING LIGHT'
	    WHEN TRAF_CNTL = '05' THEN '005. YIELD SIGN'
	    WHEN TRAF_CNTL = '06' THEN '006. OFFICER/FLAGMAN/GUARD'
	    WHEN TRAF_CNTL = '07' THEN '007. NO PASSING ZONE'
	    WHEN TRAF_CNTL = '08' THEN '008. RR CROSSING SIGN'
	    WHEN TRAF_CNTL = '09' THEN '009. RR CROSSING FLASH LIGHT'
	    WHEN TRAF_CNTL = '10' THEN '010. RR CROSSING GATES'
	    WHEN TRAF_CNTL = '11' THEN '011. STOPPED SCHOOL BUS W/RED LIGHT FLASHING'
	    WHEN TRAF_CNTL = '12' THEN '012. HIGHWAY WORK AREA (CONSTRUCTION)'
	    WHEN TRAF_CNTL = '13' THEN '013. MAINTENANCE WORK AREA'
	    WHEN TRAF_CNTL = '14' THEN '014. UTILITY WORK AREA'
	    WHEN TRAF_CNTL = '15' THEN '015. POLICE/FIRE EMERGENCY'
	    WHEN TRAF_CNTL = '16' THEN '016. SCHOOL ZONE'
	    WHEN TRAF_CNTL = '20' THEN '017. OTHER'
	    WHEN TRAF_CNTL = '??' THEN '018. INVALID CODE'
	    WHEN TRAF_CNTL = 'XX' THEN '019. NOT ENTERED'
	    WHEN TRAF_CNTL = 'YY' THEN '020. NOT APPLICABLE'
	    WHEN TRAF_CNTL = 'ZZ' or TRAF_CNTL = '00'  THEN '021. UNKNOWN' END--, nys_v_sex.crashid
ORDER BY " "