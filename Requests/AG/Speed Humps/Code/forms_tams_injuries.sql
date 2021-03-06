
select * from (
select  
c.NODEID, 
cast(year(c.ACCIDENT_DT) as int) YR,
/*sum(case when PED_NONPED = 'P' then 1 else 0 end) as [PED],
sum(case when PED_NONPED = 'B' then 1 else 0 end) as [BIKE],
sum(case when PED_NONPED = 'N' then 1 else 0 end) as [MVO]*/
'after' as PERIOD,
case when PED_NONPED = 'Pedestrian' then 'ped'
	when PED_NONPED = 'Bicyclist' then 'bicycle'
	when PED_NONPED = 'Occupant' then 'mvo' end as Mode,
sum(case when i.INJ_KILLED = 'Injured' then 1 else 0 end) as INJ
from [FORMS].[dbo].[WC_ACCIDENT_F] as c
join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
	on c.INTEGRATION_ID=i.ACCIDENT_ID
where cast(year(c.ACCIDENT_DT) as int) = 2017
	and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
	and c.NONMV is null
group by c.NODEID, 
		 cast(year(c.ACCIDENT_DT) as int),
		 case when PED_NONPED = 'Pedestrian' then 'ped'
			  when PED_NONPED = 'Bicyclist' then 'bicycle'
			  when PED_NONPED = 'Occupant' then 'mvo' end 

union


Select 
NODEID,
year(OCCURRENCE_DATETIME) YR,
case when year(OCCURRENCE_DATETIME) between 2011 and 2013 then 'before'
when year(OCCURRENCE_DATETIME) between 2015 and 2017 then 'after' end as PERIOD,
case when PED_NONPED = 'P' then 'ped'
	when PED_NONPED = 'B' then 'bicycle'
	when PED_NONPED = 'N' then 'mvo' end as Mode,
/*sum(case when PED_NONPED = 'P' then 1 else 0 end) as [PED],
sum(case when PED_NONPED = 'B' then 1 else 0 end) as [BIKE],
sum(case when PED_NONPED = 'N' then 1 else 0 end) as [MVO],
year(OCCURRENCE_DATETIME) YR*/
sum(INJURED_COUNT) as INJ
From(
	SELECT  c.ANUM_PCT
	, c.ANUM_SEQ
	, c.ANUM_YY
	, c.OCCURRENCE_DATETIME
	, c.NODEID
	, c.INJURED_COUNT
	, c.KILLED_COUNT
	, v.PED_NONPED
	From DataWarehouse.dbo.AIS_PD_Core_F as c
	join DataWarehouse.dbo.AIS_PD_Victim_F as v
	on c.ANUM_PCT = v.ANUM_PCT and c.ANUM_SEQ = v.ANUM_SEQ and c.ANUM_YY = v.ANUM_YY
	join DataWarehouse.dbo.AIS_PD_Locx_F as l
	on c.ANUM_PCT=l.ANUM_PCT and c.ANUM_SEQ = l.ANUM_SEQ and c.ANUM_YY = l.ANUM_YY
	where year(c.OCCURRENCE_DATETIME) between 2011 and 2016
	and c.NODEID in (select distinct coalesce(Nodeid,0) from
					 DataWarehouse.dbo.AIS_PD_Core_F)
			)x
	group by NODEID, 
			 case when PED_NONPED = 'P' then 'ped'
				  when PED_NONPED = 'B' then 'bicycle'
				  when PED_NONPED = 'N' then 'mvo' end,
			 year(OCCURRENCE_DATETIME)
			 ) inj_data
where YR != 2014



	
	union 

	SELECT  c.ANUM_PCT
	, c.ANUM_SEQ
	, c.ANUM_YY
	, c.OCCURRENCE_DATETIME
	, c.NODEID
	, c.INJURED_COUNT
	, c.KILLED_COUNT
	, v.PED_NONPED
	FROM DataWarehouse.dbo.AIS_PD_CORE_F as c
	join DataWarehouse.dbo.AIS_PD_Victim_F as v
	on c.ANUM_PCT = v.ANUM_PCT and c.ANUM_SEQ = v.ANUM_SEQ and c.ANUM_YY = v.ANUM_YY
	join DataWarehouse.dbo.AIS_PD_Locx_F as l
	on c.ANUM_PCT = l.ANUM_PCT and c.ANUM_SEQ = l.ANUM_SEQ and c.ANUM_YY = l.ANUM_YY
	join  DataWarehouse.dbo.nypd_location_lookup_F as lu
	on c.ANUM_PCT = lu.ANUM_PCT and l.ON_STREET = lu.[ON_STREET] and l.CROSS_STREET = lu.CROSS_STREET
	where year(c.OCCURRENCE_DATETIME) between 2011 and 2016
		  and lu.NODEID in (select distinct coalesce(Nodeid,0) from DataWarehouse.dbo.AIS_PD_Core_F)
	
	--) as data











Select 
sum(case when PED_NONPED 'P' then 1 else 0 end) as [PED],
sum(case when PED_NONPED 'B' then 1 else 0 end) as BIKE],
sum(case when PED_NONPED 'N' then 1 else 0 end) as [MVO],
From(

SELECT  c.ANUM_PCT
	, c.ANUM_SEQ
	, c.ANUM_YY
	, c.OCCURRENCE_DATETIME
	, c.NODEID
	, c.INJURED_COUNT
	, c.KILLED_COUNT
	, v.PED_NONPED




select year(OCCURRENCE_DATETIME) as year, /*ON_STREET, CROSS_STREET, NODEID,*/ sum(INJURED_COUNT) as inj
from (
	select distinct  c.ANUM_PCT, c.ANUM_SEQ, l.ANUM_YY, i.VICTIM_NUMBER, i.INJURED_COUNT, l.ON_STREET, l.CROSS_STREET, c.NODEID, c.OCCURRENCE_DATETIME
	from DataWarehouse.dbo.AIS_PD_Core_F as c
	join DataWarehouse.dbo.AIS_PD_Victim_F as i 
		on c.ANUM_PCT=i.ANUM_PCT and c.ANUM_SEQ=i.ANUM_SEQ and c.ANUM_YY=i.ANUM_YY
	left outer join DataWarehouse.dbo.AIS_PD_Locx_F as l
		on c.ANUM_PCT=l.ANUM_PCT and c.ANUM_SEQ=l.ANUM_SEQ and c.ANUM_YY=l.ANUM_YY
	left outer join (
		SELECT * FROM [DataWarehouse].[dbo].[nypd_location_lookup_F]
		where NODEID in(9029844, 9029856)
	  ) as n on l.ANUM_PCT=n.ANUM_PCT and l.ON_STREET=n.ON_STREET and l.CROSS_STREET=n.CROSS_STREET
	where year(c.OCCURRENCE_DATETIME) between 2009 and 2016
	and i.INJURED_COUNT>0
	and (c.NODEID in(9029844, 9029856)
		or n.ANUM_PCT is not null)
) as t
group by year(OCCURRENCE_DATETIME)--, ON_STREET, CROSS_STREET, NODEID






---------1/15/2020------------------------------------------


select nodeid, 
case when yr between 2011 and 2013 then 'before' 
	 when  yr between 2015 and 2017 then 'after' else 'exclude' end as period, 
case when PED_NONPED = 'Pedestrian' then 'ped'
     when PED_NONPED = 'Bicyclist' then 'bicycle'
     when PED_NONPED = 'Occupant' then 'mvo' end as Mode,
sum(case when INJ_KILLED = 'Injured' then 1 else 0 end) as INJ
from (
       select coalesce(c.nodeid, lion_node_number) nodeid
       , year(c.accident_dt) yr, ped_nonped, inj_killed 
       from [FORMS].[dbo].wc_accident_f c
       left join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
       on c.INTEGRATION_ID=i.ACCIDENT_ID
       where year(c.ACCIDENT_DT) > 2016 
       and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
       and coalesce(nonmv, 0) = 0
       and coalesce(nodeid, lion_node_number) is not null 
       --unioning all crashes with null nodeid

       union

       select s.nodeid, year(c.accident_dt) yr, ped_nonped, inj_killed  
       from [FORMS].[dbo].wc_accident_f c
       join [FORMS].[dbo].[v_IntersectionStreetNames_Gen] s
       on lower(ltrim(rtrim(c.SRC_ON_STREET))) = lower(ltrim(rtrim(s.street_1))) 
       and
       lower(ltrim(rtrim(c.SRC_cross_STREET))) = lower(ltrim(rtrim(s.street_2)))
       and 
       case WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 1 AND 34 THEN 1
              WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 40 AND 52 THEN 2
              WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 60 AND 94 THEN 3
              WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 100 AND 115 THEN 4
              WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 120 AND 123 THEN 5 end 
       in (left(b7sc_2, 1), left(b7sc_1, 1))
       left join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
       on c.INTEGRATION_ID=i.ACCIDENT_ID
       where year(c.ACCIDENT_DT) > 2016
       and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
       and coalesce(nonmv, 0) = 0 
       and coalesce(c.nodeid, lion_node_number) is null
) all_forms
group by nodeid, 
case when yr between 2011 and 2013 then 'before' 
when  yr between 2015 and 2017 then 'after' else 'exclude' end, 
case when PED_NONPED = 'Pedestrian' then 'ped'
       when PED_NONPED = 'Bicyclist' then 'bicycle'
       when PED_NONPED = 'Occupant' then 'mvo' end





select crashes.nodeid,
case when yr between 2011 and 2013 then 'before' 
	 when  yr between 2015 and 2017 then 'after' else 'exclude' end as period, 
case when PED_NONPED = 'Pedestrian' then 'ped'
     when PED_NONPED = 'Bicyclist' then 'bicycle'
     when PED_NONPED = 'Occupant' then 'mvo' end as Mode,
sum(case when INJ_KILLED = 'Injured' then 1 else 0 end) as INJ


select crashes.nodeid, str(crashes.anum_pct)+str(crashes.anum_seq)+str(crashes.anum_yy) as crashid, crashes.yr, PED_NONPED, victim_number
from
(--selecting tams crashes
    SELECT distinct c.nodeid, c.anum_pct, c.anum_seq, c.anum_yy, yr
    FROM (
        select nodeid, anum_pct, anum_seq, anum_yy, year(occurrence_datetime) yr
        from DataWarehouse.dbo.AIS_PD_Core_F  
        where (year(occurrence_datetime) between 2011 and 2016)
              and year(occurrence_datetime) != 2014
        and nodeid > 0
    ) as c
    join DataWarehouse.dbo.AIS_PD_Locx_F as l
    on c.ANUM_PCT = l.ANUM_PCT and c.ANUM_SEQ = l.ANUM_SEQ and c.ANUM_YY = l.ANUM_YY
    union
    --unioning to account for tams crashes with nodeid = 0/street name combos with multiple potential nodes
    SELECT distinct lu.nodeid, c.anum_pct, c.anum_seq, c.anum_yy, yr
    from (
        select anum_pct, anum_seq, anum_yy, year(occurrence_datetime) yr 
        from DataWarehouse.dbo.AIS_PD_Core_F 
        where (year(occurrence_datetime) between 2011 and 2016)
              and year(occurrence_datetime) != 2014
    ) as c
    join DataWarehouse.dbo.AIS_PD_Locx_F as l
    on c.ANUM_PCT = l.ANUM_PCT and c.ANUM_SEQ = l.ANUM_SEQ and c.ANUM_YY = l.ANUM_YY
    join DataWarehouse.dbo.nypd_location_lookup_F as lu
    on c.ANUM_PCT = lu.ANUM_PCT and l.ON_STREET in (lu.[ON_STREET], lu.CROSS_STREET) and l.CROSS_STREET in (lu.[ON_STREET], lu.CROSS_STREET)
    ---AG changed above from: on c.ANUM_PCT = lu.ANUM_PCT and l.ON_STREET = lu.[ON_STREET] and l.CROSS_STREET = lu.CROSS_STREET
) crashes
left join DataWarehouse.dbo.AIS_PD_Victim_F as v
on crashes.ANUM_PCT = v.ANUM_PCT and crashes.ANUM_SEQ = v.ANUM_SEQ and crashes.ANUM_YY = v.ANUM_YY
WHERE crashes.NODEID = 15196 and INJURED_COUNT is not null


select Top 10 * from DataWarehouse.dbo.AIS_PD_Victim_F as v 
WHERE NODEID = 15196 
15196



select crashes.nodeid,
case when crashes.yr between 2011 and 2013 then 'before' 
	 when crashes.yr between 2015 and 2017 then 'after' else 'exclude' end as period, 
case when v.PED_NONPED = 'P' then 'ped'
     when v.PED_NONPED = 'B' then 'bicycle'
     when v.PED_NONPED = 'N' then 'mvo' end as Mode,
sum(v.INJ_COUNT='Injured') as INJ



select crashes.nodeid, 
       case when crashes.yr between 2011 and 2013 then 'before' 
			when crashes.yr between 2015 and 2017 then 'after' else 'exclude' end as period,
	   case when v.PED_NONPED = 'P' then 'ped'
			when v.PED_NONPED = 'B' then 'bicycle'
			when v.PED_NONPED = 'N' then 'mvo' 
			else 'Unknown' end as Mode, 
	   coalesce(sum(v.INJURED_COUNT),0) INJ
from
(--selecting tams crashes
    SELECT distinct c.nodeid, c.anum_pct, c.anum_seq, c.anum_yy, yr
    FROM (
        select nodeid, anum_pct, anum_seq, anum_yy, year(occurrence_datetime) yr
        from DataWarehouse.dbo.AIS_PD_Core_F  
        where (year(occurrence_datetime) between 2011 and 2016)
              and year(occurrence_datetime) != 2014
        and nodeid > 0
    ) as c
    join DataWarehouse.dbo.AIS_PD_Locx_F as l
    on c.ANUM_PCT = l.ANUM_PCT and c.ANUM_SEQ = l.ANUM_SEQ and c.ANUM_YY = l.ANUM_YY
    union
    --unioning to account for tams crashes with nodeid = 0/street name combos with multiple potential nodes
    SELECT distinct lu.nodeid, c.anum_pct, c.anum_seq, c.anum_yy, yr
    from (
        select anum_pct, anum_seq, anum_yy, year(occurrence_datetime) yr 
        from DataWarehouse.dbo.AIS_PD_Core_F 
        where (year(occurrence_datetime) between 2011 and 2016)
              and year(occurrence_datetime) != 2014
    ) as c
    join DataWarehouse.dbo.AIS_PD_Locx_F as l
    on c.ANUM_PCT = l.ANUM_PCT and c.ANUM_SEQ = l.ANUM_SEQ and c.ANUM_YY = l.ANUM_YY
    join DataWarehouse.dbo.nypd_location_lookup_F as lu
    on c.ANUM_PCT = lu.ANUM_PCT and l.ON_STREET in (lu.[ON_STREET], lu.CROSS_STREET) and l.CROSS_STREET in (lu.[ON_STREET], lu.CROSS_STREET)
    ---AG changed above from: on c.ANUM_PCT = lu.ANUM_PCT and l.ON_STREET = lu.[ON_STREET] and l.CROSS_STREET = lu.CROSS_STREET
) crashes
left join DataWarehouse.dbo.AIS_PD_Victim_F as v
on crashes.ANUM_PCT = v.ANUM_PCT and crashes.ANUM_SEQ = v.ANUM_SEQ and crashes.ANUM_YY = v.ANUM_YY
GROUP BY crashes.nodeid, 
case when crashes.yr between 2011 and 2013 then 'before' 
	 when crashes.yr between 2015 and 2017 then 'after' else 'exclude' end, 
case when v.PED_NONPED = 'P' then 'ped'
     when v.PED_NONPED = 'B' then 'bicycle'
     when v.PED_NONPED = 'N' then 'mvo' 
	 else 'Unknown' END 



----1/16/2020-------------------





SELECT NODEID
	  ,CASE WHEN yr between 2011 and 2013 THEN 'before' 
			WHEN yr between 2015 and 2017 THEN 'after' ELSE 'exclude' END AS PERIOD
	  ,sum(INJ) injuries 
FROM (  
		SELECT nodeid
			  ,yr
			  ,CASE WHEN PED_NONPED = 'Pedestrian' THEN 'ped'
				 WHEN PED_NONPED = 'Bicyclist' THEN 'bicycle'
				 WHEN PED_NONPED = 'Occupant' THEN 'mvo' END as Mode
			  ,sum(CASE WHEN INJ_KILLED = 'Injured' THEN 1 else 0 END) AS INJ
		FROM (SELECT coalesce(c.nodeid, lion_node_number) nodeid
					,year(c.accident_dt) yr
					,ped_nonped
					,inj_killed 
			  FROM [FORMS].[dbo].wc_accident_f c
			  LEFT JOIN FORMS.dbo.WC_ACCIDENT_VICTIM_F AS i
			  ON c.INTEGRATION_ID=i.ACCIDENT_ID
			  WHERE year(c.ACCIDENT_DT) > 2016 
				and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
			    and coalesce(nonmv, 0) = 0
				and coalesce(nodeid, lion_node_number) is not null 
			  --unioning all crashes with null nodeid

			  UNION

			  SELECT s.nodeid
					,year(c.accident_dt) yr
				  	,ped_nonped
					,inj_killed  
			  FROM [FORMS].[dbo].wc_accident_f c
			  JOIN [FORMS].[dbo].[v_IntersectionStreetNames_Gen] s
			  ON lower(ltrim(rtrim(c.SRC_ON_STREET))) = lower(ltrim(rtrim(s.street_1))) 
			  and
			  lower(ltrim(rtrim(c.SRC_cross_STREET))) = lower(ltrim(rtrim(s.street_2)))
			  and 
			  CASE WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 1 AND 34 THEN 1
				   WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 40 AND 52 THEN 2
				   WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 60 AND 94 THEN 3
				   WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 100 AND 115 THEN 4
				   WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 120 AND 123 THEN 5 END 
			  in (left(b7sc_2, 1), left(b7sc_1, 1))
			  LEFT JOIN FORMS.dbo.WC_ACCIDENT_VICTIM_F AS i
			  ON c.INTEGRATION_ID=i.ACCIDENT_ID
			  WHERE year(c.ACCIDENT_DT) > 2016
			    and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
			    and coalesce(nonmv, 0) = 0 
			    and coalesce(c.nodeid, lion_node_number) is null
		) all_forms
		GROUP BY nodeid, yr,
		CASE WHEN PED_NONPED = 'Pedestrian' THEN 'ped'
			 WHEN PED_NONPED = 'Bicyclist' THEN 'bicycle'
			 WHEN PED_NONPED = 'Occupant' THEN 'mvo' END

		UNION 

		SELECT crashes.nodeid
			  ,crashes.yr
			  ,CASE WHEN v.PED_NONPED = 'P' THEN 'ped'
					WHEN v.PED_NONPED = 'B' THEN 'bicycle'
					WHEN v.PED_NONPED = 'N' THEN 'mvo' 
					ELSE 'STUDY YEAR' END AS Mode 
			  ,coalesce(sum(v.INJURED_COUNT),0) INJ
		FROM(--selecting tams crashes
			 SELECT DISTINCT c.nodeid
							,c.anum_pct
							,c.anum_seq
							,c.anum_yy
							,yr
			 FROM (SELECT nodeid
						  ,anum_pct
						  ,anum_seq
						  ,anum_yy
						  ,year(occurrence_datetime) yr
					FROM DataWarehouse.dbo.AIS_PD_Core_F  
					WHERE (year(occurrence_datetime) between 2011 and 2016)
					   and year(occurrence_datetime) != 2014
					   and nodeid > 0
					) AS c
			JOIN DataWarehouse.dbo.AIS_PD_Locx_F AS l
			ON c.ANUM_PCT = l.ANUM_PCT and c.ANUM_SEQ = l.ANUM_SEQ and c.ANUM_YY = l.ANUM_YY
			
			UNION

			--unioning to account for tams crashes with nodeid = 0/street name combos with multiple potential nodes
			SELECT DISTINCT lu.nodeid, c.anum_pct, c.anum_seq, c.anum_yy, yr
			FROM (SELECT anum_pct, anum_seq, anum_yy, year(occurrence_datetime) yr 
				  FROM DataWarehouse.dbo.AIS_PD_Core_F 
				  WHERE (year(occurrence_datetime) between 2011 and 2016)
					 and year(occurrence_datetime) != 2014
				  ) AS c
			JOIN DataWarehouse.dbo.AIS_PD_Locx_F AS l
			ON c.ANUM_PCT = l.ANUM_PCT and c.ANUM_SEQ = l.ANUM_SEQ and c.ANUM_YY = l.ANUM_YY
			JOIN DataWarehouse.dbo.nypd_location_lookup_F AS lu
			ON c.ANUM_PCT = lu.ANUM_PCT and l.ON_STREET in (lu.[ON_STREET], lu.CROSS_STREET) and l.CROSS_STREET in (lu.[ON_STREET], lu.CROSS_STREET)
			---AG changed above from: on c.ANUM_PCT = lu.ANUM_PCT and l.ON_STREET = lu.[ON_STREET] and l.CROSS_STREET = lu.CROSS_STREET
		) crashes
		LEFT JOIN DataWarehouse.dbo.AIS_PD_Victim_F AS v
		on crashes.ANUM_PCT = v.ANUM_PCT and crashes.ANUM_SEQ = v.ANUM_SEQ and crashes.ANUM_YY = v.ANUM_YY
		GROUP BY crashes.nodeid
				,crashes.yr
				,CASE WHEN v.PED_NONPED = 'P' THEN 'ped'
					  WHEN v.PED_NONPED = 'B' THEN 'bicycle'
					  WHEN v.PED_NONPED = 'N' THEN 'mvo' 
					  ELSE 'STUDY YEAR' END 

		) data 

GROUP BY nodeid, 
	   CASE WHEN yr between 2011 and 2013 THEN 'before' 
			WHEN  yr between 2015 and 2017 THEN 'after' ELSE 'exclude' END


