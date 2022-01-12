
from ris import db2
from datetime import datetime
import os

def mcd_view(pg):
    pg.query("""
    drop view if exists v_mcd;
    create view v_mcd as 
    SELECT view.*, ST_X(n.geom), ST_Y(n.geom), n.geom, now() as Current_Date
    FROM
    (SELECT  -- Selects Frequency of Injury Events Based on Node
        nodeid, M, Y,
        Sum(Pedestrian) Pedestrian, sum(Bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
        sum(Ped_School_Aged) School_Aged, sum(Ped_Seniors)  Seniors
    FROM
    
        (SELECT		-- Selects Month, Year, Nodeid, And Injury Event occurence by Integration ID (Test Functionality with Node '21185')
                M, Y, nodeid, 
                max(Pedestrian) Pedestrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) Veh_Occupant, 
                max(Ped_School_Aged) Ped_School_Aged, max(Ped_Senior) Ped_Seniors
        FROM
                (SELECT	--Selects Injury Month and Year, Nodeid, Injury Mode, Categorizes Pedestrians by Age (School_Aged/Senior) and Integration ID				
                    extract(month from c.ACCIDENT_DT::date) M , extract(year from c.ACCIDENT_DT::date) Y, 
                    c.NODEID, 
                    (case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 END) Pedestrian,
                    (case when i.victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') then 1 else 0 END) Ped_School_Aged,
                    (case when i.victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') then 1 else 0 END) Ped_Senior,
                    (case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
                    (case when PED_NONPED  In ('Occupant') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
                    
                    c.INTEGRATION_ID, i.VICTIM_AGE
                    
                FROM public.wc_accident_f as c                 --Crash Data Table
                join public.wc_accident_victim_f  as i         --Victim Data Table
                on c.INTEGRATION_ID::int=i.ACCIDENT_ID::int         --Joins on Integration ID
                where c.nodeid is not null                          --Disregards Injury Crashes that are not at node
                  and i.INJ_KILLED = 'Injured' )z                      --Specifies Injured Events not Fatality Events
                  
        group by integration_id, M, Y, nodeid) x
    
    group by nodeid, M,Y) view
        
    join public.node n
    on view.nodeid = n.nodeid;

    grant all on v_mcd to public;
    """.format(datetime = datetime.now()))

pg_dbo = db2.PostgresDb('Dotdevpgsql02.dot.nycnet', 'vzv',
                        user='vzv_updater', db_pass='DB@u$er2017', quiet=True)
mcd_view(pg_dbo)



