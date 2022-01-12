from ris import db2
from datetime import datetime


pg_dbo = db2.PostgresDb('DOTDEVRHPGSQL01.DOT.NYCNET', 'vzv',
                        user='vzv_updater', db_pass='DB@u$er2017', quiet=True)


db2.pg_shp.export_pg_table_to_shp(r'\\Dot55fp05\Botplan\RIS\Staff Folders\Samuel\Shps_tmp',
    pg_dbo,'v_forms_inj'
    )


