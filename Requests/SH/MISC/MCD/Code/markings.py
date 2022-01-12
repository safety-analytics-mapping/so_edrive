from ris import db2
from datetime import datetime

import os

# Creating Crash and Victim Test Tables...

"""
def get_victim_data(sql, db):

    qry = """
select
accident_id, ped_nonped, inj_killed, victim_num, person_role_code, accident_dt, victim_age
from forms.dbo.WC_ACCIDENT_VICTIM_F where

year(accident_dt) > 2016
and INJ_KILLED = 'Injured'
"""
dest_schema = 'public'
dest_table = 'wc_accident_victim_f_test'
table = db2.d2d.get_table_fromsql_query(sql, qry)
db2.d2d.add_table_to_pgsql(db, dest_schema, dest_table, table, True, True)


from ris import db2, csvIO
sql = db2.SqlDb('DOT55SQL01', 'FORMS', user='arcgis', db_pass='arcgis')
db = db2.PostgresDb('dotdevpgsql02', 'vzv', user='vzv_updater', db_pass='DB@u$er2017')
qry = """
select
accident_id, ped_nonped, inj_killed, victim_num, person_role_code, accident_dt, victim_age
from forms.dbo.WC_ACCIDENT_VICTIM_F where

year(accident_dt) > 2016
and INJ_KILLED = 'Injured'
"""
dest_schema = 'public'
dest_table = 'wc_accident_victim_f_test'
table = db2.d2d.get_table_fromsql_query(sql, qry)
db2.d2d.add_table_to_pgsql(db, dest_schema, dest_table, table, True, True)





from ris import db2, csvIO
sql = db2.SqlDb('DOT55SQL01', 'FORMS', user='arcgis', db_pass='arcgis')
db = db2.PostgresDb('dotdevpgsql02', 'vzv', user='vzv_updater', db_pass='DB@u$er2017')
qry = """
select
integration_id, cast(accident_dt as varchar(50)) as accident_dt, accident_time_wid,
src_address_type, src_street_name, src_on_street, src_cross_street, src_street_num, injured_cnt,
src_off_street,
nodeid, latitude, longitude, x_coord, y_coord, VOID_STATUS_CD, NONMV
from forms.dbo.WC_ACCIDENT_F where

year(accident_dt) > 2016
and (NONMV is null or NONMV = 0)
and (VOID_STATUS_CD is null or VOID_STATUS_CD = 'N')
"""
dest_schema = 'public'
dest_table = 'wc_accident_f_test'
table = db2.d2d.get_table_fromsql_query(sql, qry)
db2.d2d.add_table_to_pgsql(db, dest_schema, dest_table, table, True, True)

""







"""

from ris import db2
from datetime import datetime


def markings_crash_data_view(pg):
    pg.query("""
    drop view if exists v_markings_crash;
    create view v_markings_crash as 
    SELECT 
        nodeid, M,Y,  
        sum(Pedestrian) Pedestrian, sum(Bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
        sum(Ped_School_Aged) School_Aged, sum(Ped_Seniors)  Seniors, sum(Ped_Adult) Adult
    FROM

        (select M, Y, nodeid, 
                max(Pedestrian) Pedestrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) Veh_Occupant, 
                max(School_Aged) Ped_School_Aged, max(Seniors) Ped_Seniors, max(Adult) Ped_Adult
        FROM
                (SELECT 
                    extract(month from c.ACCIDENT_DT::date) M , extract(year from c.ACCIDENT_DT::date) Y, 
                    c.NODEID,
                    (case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
                    (case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
                    (case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
                    (case when i.victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
                    then 1 else 0 end) School_Aged,
                    (case when i.victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') 
                    then 1 else 0 end) Seniors,
                    (case when i.victim_age between 18 and 64 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
                    then 1 else 0 end) Adult,
                    c.INTEGRATION_ID
                FROM public.wc_accident_f_test as c
                join  public.wc_accident_victim_f_test  as i
                on c.INTEGRATION_ID::int=i.ACCIDENT_ID::int
                where c.nodeid is not null 
                  and i.INJ_KILLED = 'Injured' 
                  and coalesce(c.VOID_STATUS_CD , 'N') ='N'
                  and coalesce(c.NONMV::int , 0) = 0) z
                  --and ACCIDENT_ID in (727118109,734418109)) z

            group by integration_id, M, Y, nodeid) x

    group by nodeid, M, Y;

    grant all on v_markings_crash to public;
    """)


pg_dbo = db2.PostgresDb('Dotdevpgsql02.dot.nycnet', 'vzv',
                        user='vzv_updater', db_pass='DB@u$er2017', quiet=True)
markings_crash_data_view(pg_dbo)

from ris import db2
from datetime import datetime


def markings_crash_data_view_datetime(pg):
    pg.query("""
    drop view if exists v_markings_crash_datetime;
    create view v_markings_crash_datetime as 
    SELECT 
        nodeid, M,Y,  
        sum(Pedestrian) Pedestrian, sum(Bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
        sum(Ped_School_Aged) School_Aged, sum(Ped_Seniors)  Seniors, sum(Ped_Adult) Adult,
        '{datetime}'::timestamp date_created
    FROM

        (select M, Y, nodeid, 
                max(Pedestrian) Pedestrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) Veh_Occupant, 
                max(School_Aged) Ped_School_Aged, max(Seniors) Ped_Seniors, max(Adult) Ped_Adult
        FROM
                (SELECT 
                    extract(month from c.ACCIDENT_DT::date) M , extract(year from c.ACCIDENT_DT::date) Y, 
                    c.NODEID,
                    (case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
                    (case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
                    (case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
                    (case when i.victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
                    then 1 else 0 end) School_Aged,
                    (case when i.victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') 
                    then 1 else 0 end) Seniors,
                    (case when i.victim_age between 18 and 64 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
                    then 1 else 0 end) Adult,
                    c.INTEGRATION_ID
                FROM public.wc_accident_f_test as c
                join  public.wc_accident_victim_f_test  as i
                on c.INTEGRATION_ID::int=i.ACCIDENT_ID::int
                where c.nodeid is not null 
                  and i.INJ_KILLED = 'Injured' 
                  and coalesce(c.VOID_STATUS_CD , 'N') ='N'
                  and coalesce(c.NONMV::int , 0) = 0) z
                  --and ACCIDENT_ID in (727118109,734418109)) z

            group by integration_id, M, Y, nodeid) x

    group by nodeid, M, Y,date_created;

    grant all on v_markings_crash_datetime to public;
    """.format(datetime=datetime.now()))


pg_dbo = db2.PostgresDb('Dotdevpgsql02.dot.nycnet', 'vzv',
                        user='vzv_updater', db_pass='DB@u$er2017', quiet=True)
markings_crash_data_view_datetime(pg_dbo)

d = pg_dbo.query("""Select * from v_markings_crash_datetime limit 5""")
for row in d.data:
    print row

import os

os.getcwd()

from ris import db2
from datetime import datetime

pg_dbo = db2.PostgresDb('Dotdevpgsql02.dot.nycnet', 'vzv',
                        user='vzv_updater', db_pass='DB@u$er2017', quiet=True)

q = """SELECT v.*, ST_X(n.geom), ST_Y(n.geom)
from v_markings_crash v
join public.node n
on v.nodeid = n.nodeid"""

db2.pg_shp.export_pg_table_to_shp('E:\RIS\Staff Folders\Samuel\shps',
                                  pg_dbo, 'public.v_markings_crash_datetime'
                                  )

from ris import db2
from datetime import datetime


def mcd_view(pg):
    pg.query("""
    drop view if exists v_mcd;
    create view v_mcd as 
    SELECT view.*, ST_X(n.geom), ST_Y(n.geom), n.geom
    FROM
        (SELECT 
            nodeid, M,Y,  
            sum(Pedestrian) Pedestrian, sum(Bicyclists) Bicyclists, sum(Veh_Occupant) Veh_Occupant, 
            sum(Ped_School_Aged) School_Aged, sum(Ped_Seniors)  Seniors, sum(Ped_Adult) Adult,
            '{datetime}'::timestamp date_created
        FROM

            (select M, Y, nodeid, 
                    max(Pedestrian) Pedestrian, max(Bicyclists) Bicyclists, max(Veh_Occupant) Veh_Occupant, 
                    max(School_Aged) Ped_School_Aged, max(Seniors) Ped_Seniors, max(Adult) Ped_Adult
            FROM
                    (SELECT 
                        extract(month from c.ACCIDENT_DT::date) M , extract(year from c.ACCIDENT_DT::date) Y, 
                        c.NODEID,
                        (case when PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater' then 1 else 0 end) Pedestrian,
                        (case when PED_NONPED = 'Bicyclist' then 1 else 0 end) Bicyclists,
                        (case when PED_NONPED  In ('OCCUPANT') and PERSON_ROLE_CODE In ('Driver','Passenger') then 1 else 0 end) Veh_Occupant,
                        (case when i.victim_age between 1 and 17 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
                        then 1 else 0 end) School_Aged,
                        (case when i.victim_age between 65 and 100 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater') 
                        then 1 else 0 end) Seniors,
                        (case when i.victim_age between 18 and 64 and (PERSON_ROLE_CODE = 'Pedestrian' or PERSON_ROLE_CODE = 'In-Line Skater')
                        then 1 else 0 end) Adult,
                        c.INTEGRATION_ID
                    FROM public.wc_accident_f_test as c
                    join  public.wc_accident_victim_f_test  as i
                    on c.INTEGRATION_ID::int=i.ACCIDENT_ID::int
                    where c.nodeid is not null 
                      and i.INJ_KILLED = 'Injured' 
                      and coalesce(c.VOID_STATUS_CD , 'N') ='N'
                      and coalesce(c.NONMV::int , 0) = 0) z
                      --and ACCIDENT_ID in (727118109,734418109)) z

                group by integration_id, M, Y, nodeid) x

        group by nodeid, M, Y,date_created) view

    join public.node n
    on view.nodeid = n.nodeid;

    grant all on v_mcd to public;
    """.format(datetime=datetime.now()))


pg_dbo = db2.PostgresDb('Dotdevpgsql02.dot.nycnet', 'vzv',
                        user='vzv_updater', db_pass='DB@u$er2017', quiet=True)
mcd_view(pg_dbo)

d = pg_dbo.query("""Select * from v_mcd limit 5""")
for row in d.data:
    print row

from ris import db2
from datetime import datetime

pg_dbo = db2.PostgresDb('Dotdevpgsql02.dot.nycnet', 'vzv',
                        user='vzv_updater', db_pass='DB@u$er2017', quiet=True)

db2.pg_shp.export_pg_table_to_shp(r'\\Dot55fp05\Botplan\RIS\Staff Folders\Samuel\shps',
                                  pg_dbo, 'v_mcd'
                                  )

from datetime import datetime

datetime.now()

