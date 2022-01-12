select count(distinct case when person_role_code = 'Witness' then i.row_wid end) witness_count
from staging.stg_wc_accident_f c
left join staging.stg_wc_accident_victim_f i
on c.integration_id::int = i.accident_id
group by c.integration_id
limit 1000

DROP TABLE staging.cleaned_wc_accident_f, staging.cleaned_wc_accident_vehicle_f, staging.stg_wc_accident_f, staging.stg_wc_accident_vehicle_f, staging.stg_wc_accident_victim_f

SELECT
    tablename, tableowner
FROM
    pg_catalog.pg_tables
WHERE
    schemaname ='staging'
    AND tablename like '%wc_accident%'
ORDER BY 
    tablename


GRANT ALL ON staging.stg_wc_accident_victim_f to public

"archive_stg_wc_accident_f"
"archive_stg_wc_accident_vehicle_f"
"archive_stg_wc_accident_victim_f"
"cleaned_wc_accident_f"
"cleaned_wc_accident_vehicle_f"
"cleaned_wc_accident_victim_f"
"stg_wc_accident_f"
"stg_wc_accident_vehicle_f"
"stg_wc_accident_victim_f"




SELECT
    integration_id::numeric crashid, 
    (
    'MV-' || 
    2000 + substring(integration_id, 6, 2)::int ||
    '-' ||
    right(integration_id, 3) ||
    '-' ||
    lpad(left(integration_id, 5), 6, '0')
    )::citext mv104_id,
    to_date(accident_dt, 'yyyy-mm-dd') crash_date, 
    (to_timestamp(left(lpad(accident_time_wid::varchar(6), 6, '0'), 2) || ':'
     || right(left(lpad(accident_time_wid::varchar(6), 6, '0'), 4), 2), 'hh24:mi'))::time crash_time,
    left(lpad(accident_time_wid::varchar(6), 6, '0'), 2)::int hr,
    extract(year from to_date(accident_dt, 'yyyy-mm-dd')) yr,
    lower(ltrim(rtrim(off_street)))::citext ref_marker,
    x_coord x, y_coord y, latitude, longitude, 
    src_police_precinct::int precinct,
    (case when src_police_precinct::int BETWEEN 1 AND 34 THEN 'manhattan'
          when src_police_precinct::int BETWEEN 40 AND 52 THEN 'bronx'
          when src_police_precinct::int BETWEEN 60 AND 94 THEN 'brooklyn'
          when src_police_precinct::int BETWEEN 100 AND 115 THEN 'queens'
          when src_police_precinct::int BETWEEN 120 AND 123 THEN 'staten island'
          end)::citext borough,
    case when src_address_type = 'I' then 'int'
         when src_address_type = 'A' then 'mid'
    else lower(src_address_type)
    end::citext loc, 
    case when lower(is_tlc_inv) = 'y' then True
         when lower(is_tlc_inv) = 'n' then False
         end::boolean _is_tlc_inv, --make our own
    case when lower(traffic_control) = 'yeild sign' then 'yield sign'
         else lower(traffic_control)
         end::citext as traffic_control,  
    lower(accident_diagram)::citext collision_type, --since other exists in tams,
    lower(ltrim(rtrim(light_conditions)))::citext lighting,
    accident_desc::citext narrative, 
    createdon, --might be unnecessary 
    updatedon, --might be unnecessary 
    nodeid, 
    masterid,
    case when coalesce(nonmv::int, 0) = 0 then False
         when coalesce(nonmv::int, 0) = 1 then True
         end::boolean nonmv,
    '19d' lion_version,
    lower(ltrim(rtrim(src_on_street)))::citext street1, 
    lower(ltrim(rtrim(src_cross_street)))::citext street2,
    lower(ltrim(rtrim(src_off_street)))::citext address, 
    lower(ltrim(rtrim(src_street_name)))::citext address_street
    , 'forms' source
 FROM staging.stg_wc_accident_f c 
 WHERE 
    coalesce(void_status_cd, 'N') = 'N'
    and to_date(accident_dt, 'yyyy-mm-dd') < '2021-02-01'
    and extract(year from to_date(accident_dt, 'yyyy-mm-dd')) >= 2017











ALTER TABLE staging.cleaned_wc_accident_f ADD COLUMN IF NOT EXISTS vehicle_count_strict int;
ALTER TABLE staging.cleaned_wc_accident_f ADD COLUMN IF NOT EXISTS vehicle_count_total int;
ALTER TABLE staging.cleaned_wc_accident_f ADD COLUMN IF NOT EXISTS injured_count int;
ALTER TABLE staging.cleaned_wc_accident_f ADD COLUMN IF NOT EXISTS witness_count int;

UPDATE staging.cleaned_wc_accident_f a
SET 

vehicle_count_strict = v.vcs

from   ( 
select
count(distinct case when lower(ltrim(rtrim(coalesce(vehicle_type_code,'')))) not like '%horse%' 
and lower(ltrim(rtrim(coalesce(vehicle_type_code,'')))) not like '%bike%' 
and lower(ltrim(rtrim(coalesce(vehicle_type_code_addl,'')))) != 'bike'
then v.row_wid end) vcs
from staging.stg_wc_accident_f c
left join staging.stg_wc_accident_vehicle_f v
on c.integration_id = v.accident_id
where property_damaged_desc is null
and coalesce(pre_acdnt_action,'') != 'Parked'
group by c.integration_id) v

    
,vehicle_count_total = v.vct

from   ( 
select
count(distinct v.row_wid) vct
from staging.stg_wc_accident_f c
left join staging.stg_wc_accident_vehicle_f v
on c.integration_id = v.accident_id
where property_damaged_desc is null
and coalesce(pre_acdnt_action,'') != 'Parked'
group by c.integration_id) v

 
,injured_count = i.inj

FROM   ( 
select 
count(distinct case when i.inj_killed = 'Injured' then i.row_wid end) inj
from staging.stg_wc_accident_f c
left join staging.stg_wc_accident_victim_f i
on c.integration_id::int = i.accident_id
group by c.integration_id) i

    
,witness_count = w.wit

from   ( 
select
count(distinct case when person_role_code = 'Witness' then i.row_wid end) wit
from staging.stg_wc_accident_f c
left join staging.stg_wc_accident_victim_f i
on c.integration_id::int = i.accident_id
group by c.integration_id) w










ALTER TABLE staging.cleaned_wc_accident_f ADD COLUMN IF NOT EXISTS vehicle_count_strict int;
ALTER TABLE staging.cleaned_wc_accident_f ADD COLUMN IF NOT EXISTS vehicle_count_total int;
ALTER TABLE staging.cleaned_wc_accident_f ADD COLUMN IF NOT EXISTS injured_count int;
ALTER TABLE staging.cleaned_wc_accident_f ADD COLUMN IF NOT EXISTS witness_count int;

UPDATE staging.cleaned_wc_accident_f a
SET 

vehicle_count_strict =   
count(distinct case when lower(ltrim(rtrim(coalesce(vehicle_type_code,'')))) not like '%horse%' 
and lower(ltrim(rtrim(coalesce(vehicle_type_code,'')))) not like '%bike%' 
and lower(ltrim(rtrim(coalesce(vehicle_type_code_addl,'')))) != 'bike'
then v.row_wid end) 
from staging.stg_wc_accident_f c
left join staging.stg_wc_accident_vehicle_f v
on c.integration_id = v.accident_id
where property_damaged_desc is null
and coalesce(pre_acdnt_action,'') != 'Parked'
group by c.integration_id    
    
,vehicle_count_total=
count(distinct v.row_wid) 
from staging.stg_wc_accident_f c
left join staging.stg_wc_accident_vehicle_f v
on c.integration_id = v.accident_id
where property_damaged_desc is null
and coalesce(pre_acdnt_action,'') != 'Parked'
group by c.integration_id 
 
,injured_count=  
count(distinct case when i.inj_killed = 'Injured' then i.row_wid end) 
from staging.stg_wc_accident_f c
left join staging.stg_wc_accident_victim_f i
on c.integration_id::int = i.accident_id
group by c.integration_id    
    
,witness_count=   
count(distinct case when person_role_code = 'Witness' then i.row_wid end) 
from staging.stg_wc_accident_f c
left join staging.stg_wc_accident_victim_f i
on c.integration_id::int = i.accident_id
group by c.integration_id




[3:52 PM] Oge, Samuel
    
ALTER TABLE {​​​​​​​cleaned_schema}​​​​​​​.{​​​​​​​cleaned_table}​​​​​​​ ADD COLUMN IF NOT EXISTS vehicle_count_strict int;
ALTER TABLE {​​​​​​​cleaned_schema}​​​​​​​.{​​​​​​​cleaned_table}​​​​​​​ ADD COLUMN IF NOT EXISTS vehicle_count_total int;
ALTER TABLE {​​​​​​​cleaned_schema}​​​​​​​.{​​​​​​​cleaned_table}​​​​​​​ ADD COLUMN IF NOT EXISTS injured_count int;
ALTER TABLE {​​​​​​​cleaned_schema}​​​​​​​.{​​​​​​​cleaned_table}​​​​​​​ ADD COLUMN IF NOT EXISTS witness_count int;


UPDATE {​​​​​​​cleaned_schema}​​​​​​​.{​​​​​​​cleaned_table}​​​​​​​ a
SET 
    vehicle_count_strict = summary.vehicle_count_strict, 
    vehicle_count_total=summary.vehicle_count_total, 
    injured_count=summary.injured_count, 
    witness_count=summary.witness_count
FROM (
     select coalesce(i.crashid, v.crashid) crashid, coalesce(injured_count, 0) injured_count, 
     coalesce(witness_count, 0) witness_count ,coalesce(vehicle_count_total, 0) vehicle_count_total,
     coalesce(vehicle_count_strict, 0) vehicle_count_strict
    from
    (
        select c.integration_id crashid,
        count(distinct case when i.inj_killed = 'Injured' then i.row_wid end) injured_count,
        count(distinct case when person_role_code = 'Witness' then i.row_wid end) witness_count
        from staging.stg_wc_accident_f c
        left join staging.stg_wc_accident_victim_f i
        on c.integration_id::int = i.accident_id
        group by c.integration_id
    ) i
    full join
    (
        select c.integration_id crashid,
        count(distinct v.row_wid) vehicle_count_total,
        count(distinct case when lower(ltrim(rtrim(coalesce(vehicle_type_code,'')))) not like '%horse%' 
        and lower(ltrim(rtrim(coalesce(vehicle_type_code,'')))) not like '%bike%' 
        and lower(ltrim(rtrim(coalesce(vehicle_type_code_addl,'')))) != 'bike'
        then v.row_wid end) vehicle_count_strict
        from staging.stg_wc_accident_f c
        left join staging.stg_wc_accident_vehicle_f v
        on c.integration_id = v.accident_id
        where property_damaged_desc is null
        and coalesce(pre_acdnt_action,'') != 'Parked'
        group by c.integration_id
    ) v
    on i.crashid = v.crashid
) summary                                     
WHERE a.crashid::numeric = summary.crashid::numeric



