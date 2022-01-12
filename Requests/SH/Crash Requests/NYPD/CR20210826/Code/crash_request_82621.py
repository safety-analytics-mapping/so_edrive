from ris import pysqldb
import datetime
import os
import configparser
import pandas as pd
p = os.getcwd()
timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
ts = datetime.datetime.now().strftime('%Y-%m-%d')

def connect(typ):
    """
    Creates database connection object.
    :param typ: Server type to connect to
    :return: database object
    """

    LOC = os.getcwd()
    config = configparser.ConfigParser()
    # config.read('db.cfg')
    config.read(os.path.join(LOC, 'db.cfg'))
    print config.keys()

    # DATABASE
    SERVER = config.get('DB', 'SERVER')
    DATABASE = config.get('DB', 'DB_NAME')
    USER = config.get('DB', 'DB_USER')
    PASSWORD = config.get('DB', 'DB_PASSWORD')

    # SQL LION DATABASE
    FORMS_SERVER = config.get('DB', 'FORMS_SERVER')
    FORMS_DATABASE = config.get('DB', 'FORMS_DATABASE')
    FORMS_USER = config.get('DB', 'FORMS_USER')
    FORMS_PASSWORD = config.get('DB', 'FORMS_PASSWORD')

    if typ == 'db':

        return pysqldb.DbConnect(type='PG', server=SERVER, database=DATABASE, user=USER
                      , password=PASSWORD, allow_temp_tables=True)
    if typ == 'forms':

        return  pysqldb.DbConnect(type='ms', server=FORMS_SERVER, database=FORMS_DATABASE, user=FORMS_USER
                                ,password=FORMS_PASSWORD,allow_temp_tables=True)


db = connect('db')

full = db.dfquery("""


-- Full Years------------------------------------------------------------------------------
WITH vic AS(

SELECT DISTINCT crashid, victim_num
FROM public.wc_accident_victim_f vic
WHERE PERSON_ROLE_CODE = 'Pedestrian'
AND inj_killed = 'injured'
AND yr between 2017 and 2020
) 

,data AS(
SELECT DISTINCT coalesce(l.l_cd::int,0) cd,
		core.yr,
		vic.victim_num
FROM public.wc_accident_f core
JOIN vic
ON core.crashid = vic.crashid
JOIN lion l
ON core.masterid in (l.masteridfrom, l.masteridto)
AND core.yr between 2017 and 2020
AND core.borough = 'bronx'

UNION ALL

SELECT DISTINCT coalesce(l.r_cd::int,0) cd,
		core.yr,
		vic.victim_num
FROM public.wc_accident_f core
JOIN vic
ON core.crashid = vic.crashid
JOIN lion l
ON core.masterid in (l.masteridfrom, l.masteridto)
AND core.yr between 2017 and 2020
AND core.borough = 'bronx'
)

SELECT  coalesce(cd,0) cd,
	count(DISTINCT coalesce(CASE WHEN data.yr = 2017 THEN data.victim_num END, 0)) "2017",
	count(DISTINCT coalesce(CASE WHEN data.yr = 2018 THEN data.victim_num END, 0)) "2018",
	count(DISTINCT coalesce(CASE WHEN data.yr = 2019 THEN data.victim_num END, 0)) "2019",
	count(DISTINCT coalesce(CASE WHEN data.yr = 2020 THEN data.victim_num END, 0)) "2020"
FROM data
GROUP BY cd

""")




ytd = db.dfquery("""

-- Jan-7/31 ------------------------------------------------------------------------------
WITH vic AS(

SELECT DISTINCT crashid, victim_num
FROM public.wc_accident_victim_f vic
WHERE PERSON_ROLE_CODE = 'Pedestrian'
AND inj_killed = 'injured'
AND yr between 2017 and 2020
AND extract(month from crash_date) <8
) 

,data AS(
SELECT DISTINCT coalesce(l.l_cd::int,0) cd,
		core.yr,
		vic.victim_num
FROM public.wc_accident_f core
JOIN vic
ON core.crashid = vic.crashid
JOIN lion l
ON core.masterid in (l.masteridfrom, l.masteridto)
AND core.yr between 2017 and 2020
AND extract(month from crash_date) <8
AND core.borough = 'bronx'

UNION ALL

SELECT DISTINCT coalesce(l.r_cd::int,0) cd,
		core.yr,
		vic.victim_num
FROM public.wc_accident_f core
JOIN vic
ON core.crashid = vic.crashid
JOIN lion l
ON core.masterid in (l.masteridfrom, l.masteridto)
AND core.yr between 2017 and 2020
AND extract(month from crash_date) <8
AND core.borough = 'bronx'
)

SELECT  coalesce(cd,0) cd,
	count(DISTINCT coalesce(CASE WHEN data.yr = 2017 THEN data.victim_num END, 0)) "2017",
	count(DISTINCT coalesce(CASE WHEN data.yr = 2018 THEN data.victim_num END, 0)) "2018",
	count(DISTINCT coalesce(CASE WHEN data.yr = 2019 THEN data.victim_num END, 0)) "2019",
	count(DISTINCT coalesce(CASE WHEN data.yr = 2020 THEN data.victim_num END, 0)) "2020"
FROM data
GROUP BY cd

""")




full.to_csv('full_data.csv', index = False)
ytd.to_csv('ytd_data.csv', index = False)