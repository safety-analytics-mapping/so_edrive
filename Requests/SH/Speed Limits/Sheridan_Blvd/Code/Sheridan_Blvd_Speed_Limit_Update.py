from ris import pysqldb
from datetime import datetime
import os
import configparser
import pandas as pd
p = os.getcwd()
timestamp = datetime.now().strftime('%Y-%m-%d %H:%M')
ts = datetime.now().strftime('%Y%m%d')


# REQUEST:
# SPEED LIMITS UPDATE - Sheridan Blvd From Bruckner Boulevard to 177 Street

# PREP STEPS:
# a. LOAD TWO speed_limits_xd FILES ON QGIS
# b. ON THE UNDERLYING SL LAYER, LOAD ALL OF THE STREET NAMES WITH A RENDERING OF 2000
# c. ON THE TOP SL LAYER, FILTER THE SHAPE TO ONLY STREETS WITH THE CORRIDOR NAME
# d. PRODUCE A MAP WITH LAYOUT MANAGER AND CONFIRM THAT THE CORRIDOR SELECTION IS CORRECT.
#    - IF CORRIDOR SELECTION IS INCORRECT, REPEAT STEPS a-d WITH THE CORRECT CORRIDOR EXTENTS
# d. ON THE TOP SL LAYER, SELECT ALL OF THE SEGMENTS OF THE CORRIDOR WITHIN THE CONFINES OF THE EXTENTS
# e. EXPORT SELECTION TO CSV
# f. CONTINUE TO SCRIPT


# SCRIPT FLOW

# 1. FUNCTIONS
# 2. BACK UP SPEED LIMITS FILE
# 3. IMPORT LIST OF CORRIDOR SEGMENTIDS
# 4. CREATE A TABLE WITH SPEED LIMITS DATA AND TODAY'S DATE WITH UPDATED SPEED LIMITS
# 5. i.e Archive Copy


# POST STEPS:

# a. LOAD NEWLY UPDATED speed_limits_xd ON QGIS WITHOUT ANY FILTER.
# b. EXPORT SHAPEFILE TO speed_limits_{date}.shp WITH {date} FORMATTED AS 'YYYYMMDD'


# 1. FUNCTIONS
def connect(src):
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

    # DATABASE
    CRASH_SERVER = config.get('DB', 'CRASH_SERVER')
    CRASH_DATABASE = config.get('DB', 'CRASH_NAME')
    CRASH_USER = config.get('DB', 'CRASH_USER')
    CRASH_PASSWORD = config.get('DB', 'CRASH_PASSWORD')

    # SQL LION DATABASE
    FORMS_SERVER = config.get('DB', 'FORMS_SERVER')
    FORMS_DATABASE = config.get('DB', 'FORMS_DATABASE')
    FORMS_USER = config.get('DB', 'FORMS_USER')
    FORMS_PASSWORD = config.get('DB', 'FORMS_PASSWORD')

    if src == 'ris':

        return pysqldb.DbConnect(type='PG', server=SERVER, database=DATABASE, user=USER
                      , password=PASSWORD, allow_temp_tables=True)

    if src == 'crash':

        return pysqldb.DbConnect(type='PG', server=CRASH_SERVER, database=CRASH_DATABASE, user=CRASH_USER
                      , password=CRASH_PASSWORD, allow_temp_tables=True)

    if src == 'forms':

        return  pysqldb.DbConnect(type='ms', server=FORMS_SERVER, database=FORMS_DATABASE, user=FORMS_USER
                                ,password=FORMS_PASSWORD,allow_temp_tables=True)

    return


def archive_speed_limits(db,version,ts):
    """
    Creates a copy of current speed limits in archive schema.

    :param db: pysqldb DbConnect object
    :param version (str): Speed limits file version
    :param ts (str): Current times stamp in YYYYMMDD
    :return:
    """

    db.query("""
    DROP TABLE IF EXISTS archive.archive_speed_limit_{v}_{dt};
    CREATE TABLE archive.archive_speed_limit_{v}_{dt} AS

    SELECT * FROM speed_limit_{v};

    GRANT ALL ON archive.archive_speed_limit_{v}_{dt} TO PUBLIC;
    """.format(v=version, dt=ts), temp=False)


def insert_speed_limit_streets(db,version,segments):

    """
    Inserts missing segmentids from lion into current speed limits file

    :param db: pysqldb DbConnect object
    :param version (str): Speed limits file version
    :param segments (tuple): List of missing corridor segments in speed limits file
    :return: boolean
    """

    db.query("""
    INSERT INTO speed_limit_{v} (segmentid, street, postvz_sl, postvz_sg, prevz_sl, prevz_sg, version, geom)
    SELECT segmentid::int , 
           street, 
           0 postvz_sl, 
           'NO'::varchar postvz_sg, 
           0 prevz_sl, 
           'NO'::varchar _prevz_sg, 
           version, 
           geom
    FROM LION
    WHERE segmentid ::int IN  {s}
    """.format(v=version,s=segments))

    return True


def update_speed_limits(db,version,speed_limit,segments):

    """
    Updates current speed limits file with with new speed limits for selected segments.

    :param db: pysqldb DbConnect object
    :param version (str): Speed limits file version
    :param speed_limit (int): Speed limit value for current speed limits to be updated to
    :param segments (tuple): List of corridor segments to be updated.
    :return: boolean
    """

    db.query("""

    UPDATE public.speed_limit_{v}
    SET postvz_sl = {sl}
    WHERE segmentid in {s}

    """.format(v=version,sl=speed_limit, s=segments))

    return True


def check_speed_limits(db,version,segments):

    """
    Updates current speed limits file with with new speed limits for selected segments.

    :param db: pysqldb DbConnect object
    :param version (str): Speed limits file version
    :param segments (tuple): List of corridor segments
    :return: dataframe
    """

    return db.dfquery("""

    SELECT segmentid, street, postvz_sl, postvz_sg, prevz_sl, prevz_sg, version, geom
    FROM public.speed_limit_{v}
    WHERE segmentid ::int IN  {s}

    """.format(v=version,s=segments))



# 2. BACK UP SPEED LIMITS FILE

# WORKFLOW:
# a. CREATE COPY OF CURRENT SPEED LIMITS IN ARCHIVE SCHEMA WITH DATE AS YYYYDDMM
#    i.e archive.archive_speed_limit_20d_20211015

# a.
db = connect('crash')
version = '20d'

archive_speed_limits(db,version,ts)



# 3. IMPORT LIST OF CORRIDOR SEGMENTIDS

# WORKFLOW:
# a. READ IN CORRIDOR CSV FILE AND LOAD SEGMENTIDS INTO MEMORY
# b. INSERT MISSING SEGMENTS FROM LION INTO CURRENT SPEED LIMITS FILE IF NECESSARY

# a.
corridor = map(int,list(pd.read_csv('sheridan_blvd_corridor.csv').segmentid))
total = tuple(corridor)

# b.
#segments = ('0312733', '0312802', '0312769')
#insert_speed_limit_streets(db,segments)



# 4. UPDATE SPEED LIMITS TABLE WITH UPDATED SPEED LIMITS
previous = check_speed_limits(db,version,total)

update_speed_limits(db,speed_limit,total)

post = check_speed_limits(db,version,total)


# QA

previous
post

