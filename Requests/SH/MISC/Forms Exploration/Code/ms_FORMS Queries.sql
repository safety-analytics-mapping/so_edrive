

--Forms Queries
--MVO injuries at Flatbush Ave / Church Ave 2018

select top 0 *
from WC_ACCIDENT_F c 

Select top 10 CROSS_STREET1
CROSS_STREET2,
DIRECTION_FROM_X_STREET,
OFF_STREET,
STREET_SIDE,
STREET_NAME,
LOW_CROSS_STREETS,
HIGH_CROSS_STREETS,
STREET_CODE,
SRC_ON_STREET,
SRC_CROSS_STREET,
SRC_DIRECTION_FROM_X_STREET,
SRC_OFF_STREET,
SRC_STREET_NUM,
SRC_STREET_NAME,
SRC_DISTANCE_FROM_CROSS_STREET,
SRC_DIST_FROM_X_STREET_MILES
 from WC_ACCIDENT_F

Select count(INTEGRATION_ID)
from WC_ACCIDENT_F

select count(CROSS_STREET1) 
from WC_ACCIDENT_F
where CROSS_STREET1 is not null

select count(CROSS_STREET2) 
from WC_ACCIDENT_F
where CROSS_STREET2 is not null




select c.iNTEGRATION_ID, NODEID,LION_NODE_NUMBER, PED_NONPED, c.ACCIDENT_DT
from WC_ACCIDENT_F c
join WC_ACCIDENT_VICTIM_F i
on c.INTEGRATION_ID=ACCIDENT_ID
where (upper(c.SRC_ON_STREET) = 'FLATBUSH AVENUE' and  upper(c.SRC_CROSS_STREET)= 'CHURCH AVENUE') 
or (upper(c.SRC_ON_STREET) = 'CHURCH AVENUE' and  upper(c.SRC_CROSS_STREET)= 'FLATBUSH AVENUE')
and PED_NONPED = 'Occupant' 


select c.iNTEGRATION_ID, '0018243' as NODEID, 'Occupant' as PED_NONPED, c.ACCIDENT_DT
from WC_ACCIDENT_F c
join WC_ACCIDENT_VICTIM_F i
on c.INTEGRATION_ID=ACCIDENT_ID
where Year(c.ACCIDENT_DT) = 2018
and PED_NONPED = 'Occupant'
and INJ_KILLED = 'Injured'
and ((upper(c.SRC_ON_STREET) = 'FLATBUSH AVENUE' and  upper(c.SRC_CROSS_STREET)= 'CHURCH AVENUE') 
or (upper(c.SRC_ON_STREET) = 'CHURCH AVENUE' and  upper(c.SRC_CROSS_STREET)= 'FLATBUSH AVENUE'))

 

select 'FLATBUSH AVENUE' as SRC_ON_STREET, 'CHURCH AVENUE' as SRC_CROSS_STREET, count(c.iNTEGRATION_ID) as MV_ING_SG , '0018243' as NODEID, 'Occupant' as PED_NONPED, '2018' as ACCIDENT_DT
from WC_ACCIDENT_F c
join WC_ACCIDENT_VICTIM_F i
on c.INTEGRATION_ID=ACCIDENT_ID
where Year(c.ACCIDENT_DT) = 2018
and PED_NONPED = 'Occupant'
and INJ_KILLED = 'Injured'
and ((upper(c.SRC_ON_STREET) = 'FLATBUSH AVENUE' and  upper(c.SRC_CROSS_STREET)= 'CHURCH AVENUE') 
or (upper(c.SRC_ON_STREET) = 'CHURCH AVENUE' and  upper(c.SRC_CROSS_STREET)= 'FLATBUSH AVENUE'))