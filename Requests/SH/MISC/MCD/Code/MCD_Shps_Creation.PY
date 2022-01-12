from ris import db2
from datetime import datetime


pg_dbo = db2.PostgresDb('Dotdevpgsql02.dot.nycnet', 'vzv',
                        user='vzv_updater', db_pass='DB@u$er2017', quiet=True)


db2.pg_shp.export_pg_table_to_shp(r'\\Dot55fp05\Botplan\RIS\Staff Folders\Samuel\shps',
    pg_dbo,'v_mcd'
    )


