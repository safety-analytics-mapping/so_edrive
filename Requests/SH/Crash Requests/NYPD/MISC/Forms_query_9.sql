select sum(injury_cnt) bike_injuries from(




select coalesce(c.NODEID,c.LION_NODE_NUMBER) nodeid, count(VICTIM_NUM) injury_cnt
from forms.dbo.wc_accident_f c
join forms.dbo.wc_accident_victim_f v
on c.integration_id = v.ACCIDENT_ID
where ped_nonped = 'Pedestrian' 
and person_role_code in ('Prdestrian', 'In-Line Skater')
and v.INJ_KILLED = 'Injured'
and year(c.accident_dt) > 2016
and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
and coalesce(nonmv, 0) = 0
and coalesce(NODEID,LION_NODE_NUMBER) is not null
group by coalesce(c.NODEID,c.LION_NODE_NUMBER)

) x



select distinct PERSON_ROLE_CODE
from forms.dbo.wc_accident_victim_f


select distinct PED_NONPED
from forms.dbo.wc_accident_victim_f



with data as (
select distinct c.INTEGRATION_ID, coalesce(c.NODEID, c.LION_NODE_NUMBER) as node, 
c.ACCIDENT_DT, c.ACCIDENT_TIME_WID, i.VICTIM_NUM, i.PERSON_ROLE_CODE, i.PED_NONPED, i.INJ_KILLED, sev.kabco
, c.ACCIDENT_DIAGRAM, c.X_COORD, c.Y_COORD

from [FORMS].[dbo].[WC_ACCIDENT_F] as c
join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
on c.INTEGRATION_ID=i.ACCIDENT_ID
join (
      select ACCIDENT_ID, VICTIM_NUM, PED_NONPED, PERSON_ROLE_CODE,INJ_KILLED,
      case 
            when [EMOTIONAL_STATUS] = 'Apparent Death' then 'K' 
            when [EMOTIONAL_STATUS] in ('Unconscious','Semiconscious','Incoherent') then 'A'
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE IN 
                  ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn','Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation') then 'A'
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE IN ('Minor Bleeding','Minor Burn','Complaint of Pain') 
            --wiplash, severe laseration, paraysis 
                  and [LOC_PHYSICAL_COMPL_CODE] = 'Eye' then 'A' 
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE IN ('Contusion - Bruise','Abrasion') then 'B'
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE IN ('Minor Bleeding','Minor Burn') and [LOC_PHYSICAL_COMPL_CODE] != 'Eye' then 'B'
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
                  and [LOC_PHYSICAL_COMPL_CODE] != 'Eye' then 'C'
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE IN ('', 'None Visible', 'Whiplash') then 'C'            
            when [EMOTIONAL_STATUS] = 'Shock' and INV_COMPLAINT_TYPE in ('', 'None Visible', 'Whiplash') and [LOC_PHYSICAL_COMPL_CODE] = '' then 'C'
            when [EMOTIONAL_STATUS] = 'Conscious' and INV_COMPLAINT_TYPE in ('', 'None Visible') and [LOC_PHYSICAL_COMPL_CODE] = '' then 'U'
            else 'UNK' end as kabco
      from FORMS.dbo.WC_ACCIDENT_VICTIM_F 
) as sev
on c.INTEGRATION_ID=sev.ACCIDENT_ID
where 
coalesce(c.VOID_STATUS_CD, 'N') = 'N'
and coalesce(c.nonmv, 0) = 0
and i.person_role_code in ('Pedestrian', 'In-Line Skater')
and i.INJ_KILLED in ('Injured')
and year(c.ACCIDENT_DT) = 2018)

select kabco, count(distinct INTEGRATION_ID+VICTIM_NUM) cnt from data
group by kabco




with data as (
select distinct c.INTEGRATION_ID, coalesce(c.NODEID, c.LION_NODE_NUMBER) as node, 
c.ACCIDENT_DT, c.ACCIDENT_TIME_WID, i.VICTIM_NUM, i.PERSON_ROLE_CODE, i.PED_NONPED, i.INJ_KILLED, sev.kabco
, c.ACCIDENT_DIAGRAM, c.X_COORD, c.Y_COORD

from [FORMS].[dbo].[WC_ACCIDENT_F] as c
join FORMS.dbo.WC_ACCIDENT_VICTIM_F as i
on c.INTEGRATION_ID=i.ACCIDENT_ID
join (
      select ACCIDENT_ID, VICTIM_NUM, PED_NONPED, PERSON_ROLE_CODE,INJ_KILLED,
      case 
            when [EMOTIONAL_STATUS] = 'Apparent Death' then 'K' 
            when [EMOTIONAL_STATUS] in ('Unconscious','Semiconscious','Incoherent') then 'A'
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE IN 
                  ('Amputation','Concussion','Internal','Severe Bleeding','Moderate Burn','Severe Burn','Fracture - Dislocation', 'Fracture - Distorted - Dislocation') then 'A'
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE IN ('Minor Bleeding','Minor Burn','Complaint of Pain') 
            --wiplash, severe laseration, paraysis 
                  and [LOC_PHYSICAL_COMPL_CODE] = 'Eye' then 'A' 
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE IN ('Contusion - Bruise','Abrasion') then 'B'
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE IN ('Minor Bleeding','Minor Burn') and [LOC_PHYSICAL_COMPL_CODE] != 'Eye' then 'B'
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE in ('Complaint of Pain', 'Complaint of Pain or Nausea') 
                  and [LOC_PHYSICAL_COMPL_CODE] != 'Eye' then 'C'
            when [EMOTIONAL_STATUS] in ('Shock', 'Conscious') and INV_COMPLAINT_TYPE IN ('', 'None Visible', 'Whiplash') then 'C'            
            when [EMOTIONAL_STATUS] = 'Shock' and INV_COMPLAINT_TYPE in ('', 'None Visible', 'Whiplash') and [LOC_PHYSICAL_COMPL_CODE] = '' then 'C'
            when [EMOTIONAL_STATUS] = 'Conscious' and INV_COMPLAINT_TYPE in ('', 'None Visible') and [LOC_PHYSICAL_COMPL_CODE] = '' then 'U'
            else 'UNK' end as kabco
      from FORMS.dbo.WC_ACCIDENT_VICTIM_F 
) as sev
      on c.INTEGRATION_ID=sev.ACCIDENT_ID
where 
coalesce(c.VOID_STATUS_CD, 'N') = 'N'
and coalesce(c.nonmv, 0) = 0
and i.PED_NONPED = 'Bicyclist'
and i.INJ_KILLED in ('Injured', 'Killed')
and year(c.ACCIDENT_DT) between 2017 and 2019
) 
select count(distinct INTEGRATION_ID+VICTIM_NUM) from data
