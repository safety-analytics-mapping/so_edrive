/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [ANUM_PCT]
      ,[ANUM_YY]
      ,[ANUM_SEQ]
      ,[INV_NUMBER]
      ,[INV_VEH_NUMBER]
      ,[INV_PED_NUMBER]
      ,[INV_VICTIM_NUMBER]
      ,[NODEID]
      ,[INV_SAFETY_EQUIPMENT]
      ,[INV_AGE]
      ,[INV_SEX]
      ,[INV_COMPLAINT_LOCATE]
      ,[INV_COMPLAINT_TYPE]
      ,[INV_VICTIM_STATUS]
      ,[INV_INJ_TAKEN_BY]
      ,[INV_INJ_TAKEN_TO]
      ,[CREATEDON]
      ,[UPDATEDON]
  FROM [DataWarehouse].[dbo].[AIS_PD_CrashAllInv_F]


SELECT TOP 10 [INV_SAFETY_EQUIPMENT]
      ,[INV_SEX]
      ,[INV_COMPLAINT_LOCATE]
      ,[INV_COMPLAINT_TYPE]
      ,[INV_VICTIM_STATUS] 
FROM ais_pd_victim_f v
JOIN AIS_PD_CrashAllInv_F vi
ON v.anum_pct = vi.anum_pct and v.anum_yy = vi.anum_yy and v.anum_seq = vi.anum_seq 
AND v.VICTIM_NUMBER = vi.INV_VICTIM_NUMBER 
AND v.VEH_OCCUPIED = vi.INV_VEH_NUMBER



select 
(anum_seq || anum_yy || anum_pct)::numeric(10) crashid,
('MV-' || 
case when anum_yy in ('98', '99') then 1900 + anum_yy::int
else 2000 + anum_yy::int end::varchar(4) 
|| '-' || anum_pct || '-' || anum_seq)::citext mv104_id
   ,[INV_SAFETY_EQUIPMENT]::citext
   ,[INV_SEX]::citext
   ,[INV_COMPLAINT_LOCATE]::citext
   ,[INV_COMPLAINT_TYPE]::citext
   ,[INV_VICTIM_STATUS] ::citext
    from {s}.stg_{t}::citext



SELECT count(*)
FROM ais_pd_victim_f v
JOIN AIS_PD_CrashAllInv_F vi
ON v.anum_pct = vi.anum_pct and v.anum_yy = vi.anum_yy and v.anum_seq = vi.anum_seq 
AND v.VICTIM_NUMBER = vi.INV_VICTIM_NUMBER 
AND v.VEH_OCCUPIED = vi.INV_VEH_NUMBER






SELECT TOP 10 *
FROM ais_pd_victim_f v
JOIN AIS_PD_CrashAllInv_F vi
ON v.anum_pct = vi.anum_pct and v.anum_yy = vi.anum_yy and v.anum_seq = vi.anum_seq 
AND v.VICTIM_NUMBER = vi.INV_VICTIM_NUMBER 
AND v.VEH_OCCUPIED = vi.INV_VEH_NUMBER







with data as(
      select 
	  injured_count
	 ,killed_count
	 ,v.createdon
	 ,inv_sex
     ,case when inv_safety_equipment = '1' then 'None'
           when inv_safety_equipment = '2' then 'Lap Belt'
           when inv_safety_equipment = '3' then 'Harness'
           when inv_safety_equipment = '4' then 'Lap Belt/Harness'
           when inv_safety_equipment = '5' then 'Child Restraint Only'
           when inv_safety_equipment = '6' then 'Helmet'
           when inv_safety_equipment = '7' then 'Air Bag Deployed'
           when inv_safety_equipment = '8' then 'Air Bag Deployed/Lap Belt'
           when inv_safety_equipment = 'A' then 'Air Bag Deployed/Lap Belt/Harness'
           when inv_safety_equipment = 'B' then 'Air Bag Deployed/Child Restraint'
           else null end inv_safety_equipment
    , case when inv_complaint_locate = '01' then 'Head'
           when inv_complaint_locate = '02' then 'Face'
           when inv_complaint_locate = '03' then 'Eye'
           when inv_complaint_locate = '04' then 'Neck'
           when inv_complaint_locate = '05' then 'Chest'
           when inv_complaint_locate = '06' then 'Back'
           when inv_complaint_locate = '07' then 'Shoulder-Upper Arm'
           when inv_complaint_locate = '08' then 'Elbow-Lower Arm-Hand'
           when inv_complaint_locate = '09' then 'Abdomen - Pelvis'
           when inv_complaint_locate = '10' then 'Hip-Upper Leg'
           when inv_complaint_locate = '11' then 'Knee-Lower Leg-Foot'
           when inv_complaint_locate = '12' then 'Entire Body'
           else null end inv_complaint_locate
    , case when inv_victim_status = '1' then 'Apparent Death'
           when inv_victim_status = '2' then 'Unconscious'
           when inv_victim_status = '3' then 'Semiconscious'
           when inv_victim_status = '4' then 'Incoherent'
           when inv_victim_status = '5' then 'Shock'
           when inv_victim_status = '6' then 'Conscious'
           else null end inv_victim_status
    , case when inv_complaint_type = '01' then 'Amputation'
           when inv_complaint_type = '02' then 'Concussion'
           when inv_complaint_type = '03' then 'Internal'
           when inv_complaint_type = '04' then 'Minor Bleeding'
           when inv_complaint_type = '05' then 'Severe Bleeding'
           when inv_complaint_type = '06' then 'Minor Burn'
           when inv_complaint_type = '07' then 'Moderate Burn'
           when inv_complaint_type = '08' then 'Severe Burn'
           when inv_complaint_type = '09' then 'Fracture - Dislocation'
           when inv_complaint_type = '10' then 'Contusion - Bruise'
           when inv_complaint_type = '11' then 'Abrasion'
           when inv_complaint_type = '12' then 'Complaint of Pain'
           when inv_complaint_type = '13' then 'None Visible'
           when inv_complaint_type = '14' then 'Whiplash'
           else null end inv_complaint_type           
    FROM ais_pd_victim_f v
	JOIN AIS_PD_CrashAllInv_F vi
	ON v.anum_pct = vi.anum_pct and v.anum_yy = vi.anum_yy and v.anum_seq = vi.anum_seq 
	AND v.VICTIM_NUMBER = vi.INV_VICTIM_NUMBER 
	AND v.VEH_OCCUPIED = vi.INV_VEH_NUMBER)
    
      SELECT 
      case when killed_count != 0 then 'k'
           when inv_victim_status = 'Apparent Death' and injured_count > 0 then 'u' -- Hisa confirmed these are not fatals 
           when inv_victim_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
                                    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation',
                                    'Crush Injuries','Paralysis','Severe Lacerations') then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and year(createdon) >= 2019 then 'b' 
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and year(createdon) < 2019 then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Contusion - Bruise','Abrasion') then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Minor Bleeding','Minor Burn') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'c'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('', 'None Visible', 'Whiplash') then 'c'            
           when inv_victim_status = 'Shock' and inv_complaint_type in ('', 'None Visible', 'Whiplash') and inv_complaint_type = '' then 'c'
           when inv_victim_status = 'Conscious' and inv_complaint_type in ('', 'None Visible') and inv_complaint_type = '' then 'u'
           else 'u' end--severity
    , case when killed_count != 0 then 'k'
           when inv_victim_status = 'Apparent Death' and  injured_count > 0 then 'u' -- Hisa confirmed these are not fatals 
           when inv_victim_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
                                    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation'
                                    --,'Crush Injuries','Paralysis','Severe Lacerations'
                                    ) then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and year(createdon) >= 2019 then 'b' 
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and year(createdon) < 2019 then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Contusion - Bruise','Abrasion') then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Minor Bleeding','Minor Burn') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'c'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('', 'None Visible', 'Whiplash') then 'c'            
           when inv_victim_status = 'Shock' and inv_complaint_type in ('', 'None Visible', 'Whiplash') and inv_complaint_type = '' then 'c'
           when inv_victim_status = 'Conscious' and inv_complaint_type in ('', 'None Visible') and inv_complaint_type = '' then 'u'
           else 'u' end --::citext pre_change_severity
    , data.*
    from data





	createdon



	SELECT DISTINCT inv_complaint_locate
    FROM ais_pd_victim_f v
	JOIN AIS_PD_CrashAllInv_F vi
	ON v.anum_pct = vi.anum_pct and v.anum_yy = vi.anum_yy and v.anum_seq = vi.anum_seq 
	AND v.VICTIM_NUMBER = vi.INV_VICTIM_NUMBER 
	AND v.VEH_OCCUPIED = vi.INV_VEH_NUMBER


	SELECT TOP 1 *
    FROM ais_pd_victim_f v
	


select top 1 current_version from ais_pd_core_f




    with data as(
    select 
    (anum_seq || anum_yy || anum_pct)::numeric(10) crashid,
    ('MV-' || 
    case when anum_yy in ('98', '99') then 1900 + anum_yy::int
    else 2000 + anum_yy::int end::varchar(4) 
    || '-' || anum_pct || '-' || anum_seq)::citext mv104_id
    ,injured_count
    ,killed_count
	,v.createdon
	,inv_sex
	, inv_sex
    , case when inv_safety_equipment = '1' then 'None'
           when inv_safety_equipment = '2' then 'Lap Belt'
           when inv_safety_equipment = '3' then 'Harness'
           when inv_safety_equipment = '4' then 'Lap Belt/Harness'
           when inv_safety_equipment = '5' then 'Child Restraint Only'
           when inv_safety_equipment = '6' then 'Helmet'
           when inv_safety_equipment = '7' then 'Air Bag Deployed'
           when inv_safety_equipment = '8' then 'Air Bag Deployed/Lap Belt'
           when inv_safety_equipment = 'A' then 'Air Bag Deployed/Lap Belt/Harness'
           when inv_safety_equipment = 'B' then 'Air Bag Deployed/Child Restraint'
           else null end::citext inv_safety_equipment
    , case when inv_complaint_locate = '01' then 'Head'
           when inv_complaint_locate = '02' then 'Face'
           when inv_complaint_locate = '03' then 'Eye'
           when inv_complaint_locate = '04' then 'Neck'
           when inv_complaint_locate = '05' then 'Chest'
           when inv_complaint_locate = '06' then 'Back'
           when inv_complaint_locate = '07' then 'Shoulder-Upper Arm'
           when inv_complaint_locate = '08' then 'Elbow-Lower Arm-Hand'
           when inv_complaint_locate = '09' then 'Abdomen - Pelvis'
           when inv_complaint_locate = '10' then 'Hip-Upper Leg'
           when inv_complaint_locate = '11' then 'Knee-Lower Leg-Foot'
           when inv_complaint_locate = '12' then 'Entire Body'
           else null end::citext inv_complaint_locate
    , case when inv_victim_status = '1' then 'Apparent Death'
           when inv_victim_status = '2' then 'Unconscious'
           when inv_victim_status = '3' then 'Semiconscious'
           when inv_victim_status = '4' then 'Incoherent'
           when inv_victim_status = '5' then 'Shock'
           when inv_victim_status = '6' then 'Conscious'
           else null end::citext inv_victim_status
    , case when inv_complaint_type = '01' then 'Amputation'
           when inv_complaint_type = '02' then 'Concussion'
           when inv_complaint_type = '03' then 'Internal'
           when inv_complaint_type = '04' then 'Minor Bleeding'
           when inv_complaint_type = '05' then 'Severe Bleeding'
           when inv_complaint_type = '06' then 'Minor Burn'
           when inv_complaint_type = '07' then 'Moderate Burn'
           when inv_complaint_type = '08' then 'Severe Burn'
           when inv_complaint_type = '09' then 'Fracture - Dislocation'
           when inv_complaint_type = '10' then 'Contusion - Bruise'
           when inv_complaint_type = '11' then 'Abrasion'
           when inv_complaint_type = '12' then 'Complaint of Pain'
           when inv_complaint_type = '13' then 'None Visible'
           when inv_complaint_type = '14' then 'Whiplash'
           else null end::citext inv_complaint_type           
    from staging.stg_ais_pd_crashallinv_f allinv)
    
    SELECT 
      case when killed_count !=0 is  then 'k'
           when inv_victim_status = 'Apparent Death' and injured_count > 0 then 'u' -- Hisa confirmed these are not fatals 
           when inv_victim_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
                                    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation',
                                    'Crush Injuries','Paralysis','Severe Lacerations') then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(accident_dt, 'yyyy-mm-dd')) >= 2019 then 'b' 
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(accident_dt, 'yyyy-mm-dd')) < 2019 then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Contusion - Bruise','Abrasion') then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Minor Bleeding','Minor Burn') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'c'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('', 'None Visible', 'Whiplash') then 'c'            
           when inv_victim_status = 'Shock' and inv_complaint_type in ('', 'None Visible', 'Whiplash') and inv_complaint_type = '' then 'c'
           when inv_victim_status = 'Conscious' and inv_complaint_type in ('', 'None Visible') and inv_complaint_type = '' then 'u'
           else 'u' end::citext severity
    , case when killed_count != 0 then 'k'
           when inv_victim_status = 'Apparent Death' and injured_count > 0 then 'u' -- Hisa confirmed these are not fatals 
           when inv_victim_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
                                    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation'
                                    --,'Crush Injuries','Paralysis','Severe Lacerations'
                                    ) then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(accident_dt, 'yyyy-mm-dd')) >= 2019 then 'b' 
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(accident_dt, 'yyyy-mm-dd')) < 2019 then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Contusion - Bruise','Abrasion') then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Minor Bleeding','Minor Burn') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'c'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('', 'None Visible', 'Whiplash') then 'c'            
           when inv_victim_status = 'Shock' and inv_complaint_type in ('', 'None Visible', 'Whiplash') and inv_complaint_type = '' then 'c'
           when inv_victim_status = 'Conscious' and inv_complaint_type in ('', 'None Visible') and inv_complaint_type = '' then 'u'
           else 'u' end::citext pre_change_severity
    , data.*
    from data













