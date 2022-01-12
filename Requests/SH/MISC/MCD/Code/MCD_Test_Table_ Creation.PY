from ris import db2
from datetime import datetime

import os



#Creating Crash and Victim Test Tables...


def get_victim_data(sql, db):

    qry = """select accident_id, ped_nonped, inj_killed, victim_num, person_role_code, accident_dt,victim_age
            from forms.dbo.WC_ACCIDENT_VICTIM_F where year(accident_dt) > 2016
            and INJ_KILLED = 'Injured'
            """
    dest_schema = 'public'
    dest_table = 'wc_accident_victim_f_test'
    table = db2.d2d.get_table_fromsql_query(sql, qry)
    db2.d2d.add_table_to_pgsql(db, dest_schema, dest_table, table, True, True)


from ris import db2, csvIO
sql = db2.SqlDb('DOT55SQL01', 'FORMS', user='arcgis', db_pass='arcgis')
db = db2.PostgresDb('dotdevpgsql02', 'vzv', user='vzv_updater', db_pass='DB@u$er2017')
db.query("drop table if exists wc_accident_victim_f_test cascade")
qry = """select accident_id, ped_nonped, inj_killed, victim_num, person_role_code, accident_dt,victim_age
          from forms.dbo.WC_ACCIDENT_VICTIM_F where year(accident_dt) > 2016
          and INJ_KILLED = 'Injured'
          """
dest_schema = 'public'
dest_table = 'wc_accident_victim_f_test'
table = db2.d2d.get_table_fromsql_query(sql, qry)
db2.d2d.add_table_to_pgsql(db, dest_schema, dest_table, table, True, True)





from ris import db2, csvIO
sql = db2.SqlDb('DOT55SQL01', 'FORMS', user='arcgis', db_pass='arcgis')
db = db2.PostgresDb('dotdevpgsql02', 'vzv', user='vzv_updater', db_pass='DB@u$er2017')
db.query("drop table if exists wc_accident_f_test cascade")
qry = """select integration_id, cast(accident_dt as varchar(50)) as accident_dt, accident_time_wid,
            src_address_type, src_street_name, src_on_street, src_cross_street, src_street_num, injured_cnt,
            src_off_street,
            nodeid, latitude, longitude, x_coord, y_coord, VOID_STATUS_CD, NONMV
            from forms.dbo.WC_ACCIDENT_F where year(accident_dt) > 2016
            and (NONMV is null or NONMV = 0)
            and (VOID_STATUS_CD is null or VOID_STATUS_CD = 'N')
            """
dest_schema = 'public'
dest_table = 'wc_accident_f_test'
table = db2.d2d.get_table_fromsql_query(sql, qry)
db2.d2d.add_table_to_pgsql(db, dest_schema, dest_table, table, True, True)


