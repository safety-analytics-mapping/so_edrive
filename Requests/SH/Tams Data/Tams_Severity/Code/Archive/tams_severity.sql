SELECT *
  FROM staging.cleaned_ais_pd_victim_f
  
  limit 100;
  
SELECT *
  FROM staging.stg_ais_pd_victim_f
  limit 100;
  


SELECT *
  FROM staging.stg_ais_pd_crashallinv_f
  limit 100;


SELECT *
  FROM staging.cleaned_ais_pd_crashallinv_f
  limit 1000;


select * from staging.stg_ais_pd_pedestrian_f

with data as(
    select 
          (anum_seq || anum_yy || anum_pct)::numeric(10) crashid,
          ('MV-' || 
          case when anum_yy in ('98', '99') then 1900 + anum_yy::int
          else 2000 + anum_yy::int end::varchar(4) 
          || '-' || anum_pct || '-' || anum_seq)::citext mv104_id
          ,anum_pct, anum_yy, anum_seq
          ,inv_sex
          ,inv_victim_number 
          ,inv_veh_number
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
    , case when inv_complaint_type in ('00','0X') then 'Unknown'
           when inv_complaint_type = '01' then 'Amputation'
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
      case when killed_count !=0 then 'k'
           when inv_victim_status = 'Apparent Death' and injured_count > 0 then 'u' -- Hisa confirmed these are not fatals 
           when inv_victim_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
                                    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation',
                                    'Crush Injuries','Paralysis','Severe Lacerations') then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) >= 2019 then 'b' 
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) < 2019 then 'a'
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
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) >= 2019 then 'b' 
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) < 2019 then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Contusion - Bruise','Abrasion') then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Minor Bleeding','Minor Burn') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'c'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('', 'None Visible', 'Whiplash') then 'c'            
           when inv_victim_status = 'Shock' and inv_complaint_type in ('', 'None Visible', 'Whiplash') and inv_complaint_type = '' then 'c'
           when inv_victim_status = 'Conscious' and inv_complaint_type in ('', 'None Visible') and inv_complaint_type = '' then 'u'
           else 'u' end::citext pre_change_severity
    , d.*
    from staging.stg_ais_pd_victim_f v
    join data d
    on v.anum_pct = d.anum_pct and v.anum_yy = d.anum_yy and v.anum_seq = d.anum_seq 
    and v.victim_number = d.inv_victim_number::numeric
    and v.veh_occupied = d.inv_veh_number::numeric

    



    select *
    from staging.stg_ais_pd_victim_f allinv
    limit 10







-------------------------------------------------------------------

select * from staging.cleaned_ais_pd_victim_f limit 1000

update staging.cleaned_ais_pd_victim_f v
set
sex = allinv.inv_sex
, safety_equipment = allinv.inv_safety_equipment
, injury_location  = allinv.inv_complaint_locate
, emotional_status = allinv.inv_victim_status
, injury_type = allinv.inv_complaint_type
, severity = allinv.severity
, pre_change_severity = allinv.pre_change_severity
from
(   
    with data as(
    select 
          (anum_seq || anum_yy || anum_pct)::numeric(10) crashid,
          ('MV-' || 
          case when anum_yy in ('98', '99') then 1900 + anum_yy::int
          else 2000 + anum_yy::int end::varchar(4) 
          || '-' || anum_pct || '-' || anum_seq)::citext mv104_id
          ,anum_pct, anum_yy, anum_seq
          ,inv_sex
          ,inv_victim_number 
          ,inv_veh_number
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
    , case when inv_complaint_type in ('00','0X') then 'Unknown'
           when inv_complaint_type = '01' then 'Amputation'
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
      case when killed_count !=0 then 'k'
           when inv_victim_status = 'Apparent Death' and injured_count > 0 then 'u' -- Hisa confirmed these are not fatals 
           when inv_victim_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
                                    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation',
                                    'Crush Injuries','Paralysis','Severe Lacerations') then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) >= 2019 then 'b' 
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) < 2019 then 'a'
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
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) >= 2019 then 'b' 
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) < 2019 then 'a'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Contusion - Bruise','Abrasion') then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Minor Bleeding','Minor Burn') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'b'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'c'
           when inv_victim_status in ('Shock', 'Conscious') and inv_complaint_type in ('', 'None Visible', 'Whiplash') then 'c'            
           when inv_victim_status = 'Shock' and inv_complaint_type in ('', 'None Visible', 'Whiplash') and inv_complaint_type = '' then 'c'
           when inv_victim_status = 'Conscious' and inv_complaint_type in ('', 'None Visible') and inv_complaint_type = '' then 'u'
           else 'u' end::citext pre_change_severity
    , d.*
    from staging.stg_ais_pd_victim_f v
    join data d
    on v.anum_pct = d.anum_pct and v.anum_yy = d.anum_yy and v.anum_seq = d.anum_seq 
    and v.victim_number = d.inv_victim_number::numeric
    and v.veh_occupied = d.inv_veh_number::numeric
) allinv
where v.crashid = allinv.crashid
and v.victim_num = allinv.inv_victim_number::numeric
and v.vehicle_num = allinv.inv_veh_number::numeric
























select allinv.crashid
, allinv.inv_victim_number 
, allinv.inv_veh_number
, allinv.inv_sex
, allinv.inv_safety_equipment
, allinv.inv_complaint_locate
, allinv.inv_victim_status
, allinv.inv_complaint_type
from 
(  
    select 
          (anum_seq || anum_yy || anum_pct)::numeric(10) crashid,
          ('MV-' || 
          case when anum_yy in ('98', '99') then 1900 + anum_yy::int
          else 2000 + anum_yy::int end::varchar(4) 
          || '-' || anum_pct || '-' || anum_seq)::citext mv104_id
          ,anum_pct, anum_yy, anum_seq
          ,inv_sex
          ,inv_victim_number 
          ,inv_veh_number
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
    , case when inv_complaint_type in ('00','0X') then 'Unknown'
           when inv_complaint_type = '01' then 'Amputation'
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
    from staging.stg_ais_pd_crashallinv_f allinv

) allinv

update staging.cleaned_ais_pd_victim_f v
set
sex = allinv.inv_sex
, safety_equipment = allinv.inv_safety_equipment
, injury_location  = allinv.inv_complaint_locate
, emotional_status = allinv.inv_victim_status
, injury_type = allinv.inv_complaint_type
--, severity = allinv.severity
--, pre_change_severity = allinv.pre_change_severity
from 
(  
    select 
          (anum_seq || anum_yy || anum_pct)::numeric(10) crashid,
          ('MV-' || 
          case when anum_yy in ('98', '99') then 1900 + anum_yy::int
          else 2000 + anum_yy::int end::varchar(4) 
          || '-' || anum_pct || '-' || anum_seq)::citext mv104_id
          ,anum_pct, anum_yy, anum_seq
          ,inv_sex
          ,inv_victim_number 
          ,inv_veh_number
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
    , case when inv_complaint_type in ('00','0X') then 'Unknown'
           when inv_complaint_type = '01' then 'Amputation'
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
    from staging.stg_ais_pd_crashallinv_f allinv

) allinv
where v.crashid = allinv.crashid
and v.victim_num = allinv.inv_victim_number::bigint
and v.vehicle_num = allinv.inv_veh_number::numeric








SELECT * 

#', 
    'AIS_PD_VICTIM_F' #,'AIS_PD_VEHICLE_F'
    #, 'AIS_PD_LOCX_F'
    #, 'AIS_PD_PEDESTRIAN_F'
    ,''


SELECT
    tablename, tableowner
FROM
    pg_catalog.pg_tables
WHERE
    tablename like '%ais_pd_core_f%'
    or tablename like '%ais_pd_victim_f%'
    or tablename like '%ais_pd_vehicle_f%'
    or tablename like '%ais_pd_locx_f%'
    or tablename like '%ais_pd_pedestrian_f%'
ORDER BY 
    tablename


GRANT ALL ON staging.cleaned_ais_pd_core_f TO PUBLIC;
GRANT ALL ON staging.cleaned_ais_pd_locx_f TO PUBLIC;
GRANT ALL ON staging. cleaned_ais_pd_pedestrian_f TO PUBLIC;
GRANT ALL ON staging.cleaned_ais_pd_vehicle_f TO PUBLIC;
GRANT ALL ON staging.stg_ais_pd_locx_f TO PUBLIC;
GRANT ALL ON staging.cleaned_ais_pd_vehicle_f TO PUBLIC;
GRANT ALL ON staging.stg_ais_pd_pedestrian_f TO PUBLIC;


 "archive_stg_ais_pd_core_f"
 "archive_stg_ais_pd_locx_f"
 "archive_stg_ais_pd_pedestrian_f"
 "archive_stg_ais_pd_victim_f"

 "cleaned_ais_pd_core_f"
 "cleaned_ais_pd_locx_f"
 "cleaned_ais_pd_pedestrian_f"
 "cleaned_ais_pd_vehicle_f"
 
 "stg_ais_pd_locx_f"
 "stg_ais_pd_pedestrian_f"





select * from staging.cleaned_ais_pd_crashallinv_f limit 1000

select 
(anum_seq || anum_yy || anum_pct)::numeric(10) crashid,
('MV-' || 
case when anum_yy in ('98', '99') then 1900 + anum_yy::int
else 2000 + anum_yy::int end::varchar(4) 
|| '-' || anum_pct || '-' || anum_seq)::citext mv104_id
    , ((anum_seq || anum_yy || anum_pct) || 0 || victim_number)::bigint victim_num
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
    from staging.stg_ais_pd_crashallinv_f


update staging.cleaned_ais_pd_victim_f v
set
--sex = allinv.inv_sex
safety_equipment = allinv.inv_safety_equipment
, injury_location  = allinv.inv_complaint_locate
, emotional_status = allinv.inv_victim_status
, injury_type = allinv.inv_complaint_type
from 
(    select crashid
           ,mv104_id
           ,victim_num
           ,inv_safety_equipment
           ,inv_complaint_locate
           ,inv_victim_status
           ,inv_complaint_type    
     from staging.cleaned_ais_pd_crashallinv_f) allinv
where v.crashid = allinv.crashid::numeric
and v.victim_num::numeric = allinv.victim_num::numeric



select * from
staging.stg_ais_pd_crashallinv_f
limit 1000

select v.victim_num, a.victim_num from 
staging.cleaned_ais_pd_victim_f v
join staging.cleaned_ais_pd_crashallinv_f a
on v.crashid = a.crashid::numeric
and v.victim_num::numeric = a.victim_num::numeric




select * from  staging.cleaned_ais_pd_victim_f limit 1000

select * from staging.cleaned_ais_pd_victim_f limit 1000









            
select 
(anum_seq || anum_yy || anum_pct)::numeric(10) crashid,
('MV-' || 
case when anum_yy in ('98', '99') then 1900 + anum_yy::int
else 2000 + anum_yy::int end::varchar(4) 
|| '-' || anum_pct || '-' || anum_seq)::citext mv104_id
    , ((anum_seq || anum_yy || anum_pct) || 0 || inv_victim_number)::bigint inv_victim_number
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
    from staging.stg_ais_pd_crashallinv_f


















    
update staging.cleaned_ais_pd_victim_f v
set
crash_date = core.crash_date
, crash_time = core.crash_time
, hr = core.hr
, yr = core.yr
from staging.cleaned_ais_pd_core_f core
where v.crashid = core.crashid;















update staging.cleaned_ais_pd_victim_f v
set
severity =   
    case when killed_count !=0 then 'k'
           when emotional_status = 'Apparent Death' and injured_count > 0 then 'u' -- Hisa confirmed these are not fatals 
           when emotional_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
                                    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation',
                                    'Crush Injuries','Paralysis','Severe Lacerations') then 'a'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) >= 2019 then 'b' 
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) < 2019 then 'a'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Contusion - Bruise','Abrasion') then 'b'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Minor Bleeding','Minor Burn') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'b'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'c'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('', 'None Visible', 'Whiplash') then 'c'            
           when emotional_status = 'Shock' and inv_complaint_type in ('', 'None Visible', 'Whiplash') and inv_complaint_type = '' then 'c'
           when emotional_status = 'Conscious' and inv_complaint_type in ('', 'None Visible') and inv_complaint_type = '' then 'u'
           else 'u' end
, pre_change_severity = 
case when killed_count != 0 then 'k'
   when emotional_status = 'Apparent Death' and injured_count > 0 then 'u' -- Hisa confirmed these are not fatals 
   when emotional_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
   when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
			    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
			    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation'
			    --,'Crush Injuries','Paralysis','Severe Lacerations'
			    ) then 'a'
   when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
			    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
   and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) >= 2019 then 'b' 
   when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
			    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
   and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) < 2019 then 'a'
   when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Contusion - Bruise','Abrasion') then 'b'
   when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Minor Bleeding','Minor Burn') 
   and coalesce(inv_complaint_type,'') != 'Eye' then 'b'
   when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
   and coalesce(inv_complaint_type,'') != 'Eye' then 'c'
   when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('', 'None Visible', 'Whiplash') then 'c'            
   when emotional_status = 'Shock' and inv_complaint_type in ('', 'None Visible', 'Whiplash') and inv_complaint_type = '' then 'c'
   when emotional_status = 'Conscious' and inv_complaint_type in ('', 'None Visible') and inv_complaint_type = '' then 'u'
   else 'u' end



update staging.cleaned_ais_pd_victim_f v
set
severity = stg_v.severity
,pre_change_severity = stg_v.pre_change_severity
from( SELECT 
      case when inj_killed = 'killed' then 'k'
           when emotional_status = 'Apparent Death' and inj_killed = 'killed' then 'u' -- Hisa confirmed these are not fatals 
           when emotional_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
                                    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation',
                                    'Crush Injuries','Paralysis','Severe Lacerations') then 'a'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) >= 2019 then 'b' 
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) < 2019 then 'a'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Contusion - Bruise','Abrasion') then 'b'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Minor Bleeding','Minor Burn') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'b'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'c'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('', 'None Visible', 'Whiplash') then 'c'            
           when emotional_status = 'Shock' and inv_complaint_type in ('', 'None Visible', 'Whiplash') and inv_complaint_type = '' then 'c'
           when emotional_status = 'Conscious' and inv_complaint_type in ('', 'None Visible') and inv_complaint_type = '' then 'u'
           else 'u' end::citext severity
    , case when inj_killed = 'killed' then 'k'
           when emotional_status = 'Apparent Death' and inj_killed = 'killed' then 'u' -- Hisa confirmed these are not fatals 
           when emotional_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
                                    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation'
                                    --,'Crush Injuries','Paralysis','Severe Lacerations'
                                    ) then 'a'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and injury_location = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) >= 2019 then 'b' 
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and inv_complaint_type = 'Eye' and extract(year from to_date(createdon, 'yyyy-mm-dd')) < 2019 then 'a'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Contusion - Bruise','Abrasion') then 'b'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Minor Bleeding','Minor Burn') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'b'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
           and coalesce(inv_complaint_type,'') != 'Eye' then 'c'
           when emotional_status in ('Shock', 'Conscious') and inv_complaint_type in ('', 'None Visible', 'Whiplash') then 'c'            
           when emotional_status = 'Shock' and inv_complaint_type in ('', 'None Visible', 'Whiplash') and inv_complaint_type = '' then 'c'
           when emotional_status = 'Conscious' and inv_complaint_type in ('', 'None Visible') and inv_complaint_type = '' then 'u'
           else 'u' end::citext pre_change_severity
    from staging.cleaned_ais_pd_victim_f) stg_v


select * from staging.cleaned_ais_pd_victim_f limit 100












update staging.cleaned_ais_pd_victim_f v
set
severity = 
case when inj_killed = 'killed' then 'k'
           when emotional_status = 'Apparent Death' and inj_killed = 'killed' then 'u' -- Hisa confirmed these are not fatals 
           when emotional_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
           when emotional_status in ('Shock', 'Conscious') and injury_type in 
                                    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
                                    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation',
                                    'Crush Injuries','Paralysis','Severe Lacerations') then 'a'
           when emotional_status in ('Shock', 'Conscious') and injury_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and injury_location = 'Eye' and yr >= 2019 then 'b' 
           when emotional_status in ('Shock', 'Conscious') and injury_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and injury_location = 'Eye' and yr < 2019 then 'a'
           when emotional_status in ('Shock', 'Conscious') and injury_type in ('Contusion - Bruise','Abrasion') then 'b'
           when emotional_status in ('Shock', 'Conscious') and injury_type in ('Minor Bleeding','Minor Burn') 
           and coalesce(injury_location,'') != 'Eye' then 'b'
           when emotional_status in ('Shock', 'Conscious') and injury_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
           and coalesce(injury_location,'') != 'Eye' then 'c'
           when emotional_status in ('Shock', 'Conscious') and injury_type in ('', 'None Visible', 'Whiplash') then 'c'            
           when emotional_status = 'Shock' and injury_type in ('', 'None Visible', 'Whiplash') and injury_location = '' then 'c'
           when emotional_status = 'Conscious' and injury_type in ('', 'None Visible') and injury_location = '' then 'u'
           else 'u' end::citext 
, pre_change_severity =     
case when inj_killed = 'killed' then 'k'
           when emotional_status = 'Apparent Death' and inj_killed = 'killed' then 'u' -- Hisa confirmed these are not fatals 
           when emotional_status in ('Unconscious','Semiconscious','Incoherent') then 'a'
           when emotional_status in ('Shock', 'Conscious') and injury_type in 
                                    ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn'
                                    ,'Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation'
                                    --,'Crush Injuries','Paralysis','Severe Lacerations'
                                    ) then 'a'
           when emotional_status in ('Shock', 'Conscious') and injury_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and injury_location = 'Eye' and yr >= 2019 then 'b' 
           when emotional_status in ('Shock', 'Conscious') and injury_type in 
                                    ('Minor Bleeding','Minor Burn','Complaint of Pain','Complaint of Pain or Nausea') 
           and injury_location = 'Eye' and yr < 2019 then 'a'
           when emotional_status in ('Shock', 'Conscious') and injury_type in ('Contusion - Bruise','Abrasion') then 'b'
           when emotional_status in ('Shock', 'Conscious') and injury_type in ('Minor Bleeding','Minor Burn') 
           and coalesce(injury_location,'') != 'Eye' then 'b'
           when emotional_status in ('Shock', 'Conscious') and injury_type in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
           and coalesce(injury_location,'') != 'Eye' then 'c'
           when emotional_status in ('Shock', 'Conscious') and injury_type in ('', 'None Visible', 'Whiplash') then 'c'            
           when emotional_status = 'Shock' and injury_type in ('', 'None Visible', 'Whiplash') and injury_location = '' then 'c'
           when emotional_status = 'Conscious' and injury_type in ('', 'None Visible') and injury_location = '' then 'u'
           else 'u' end::citext 
    


DROP TABLE IF EXISTS working.cleaned_ais_pd_core_f

"__temp_log_table_soge__"
"parks_roads_comparison"
"test_for_drop_table_func_2020_09_10_asjhfdjsfhdsk"
""
""
""
""
""
""
"__temp_log_table_soge__"



DROP TABLE IF EXISTS staging.archive_stg_ais_pd_core_f


drop TABLE IF EXISTS working.ais_pd_crashallinv_f


""""


SELECT
    tablename, tableowner, *
FROM
    pg_catalog.pg_tables
WHERE
    tableowner ='soge'




select * from cleaned_ais_pd_crashallinv_f