from ris import pysqldb
import datetime
import re
import configparser
config = configparser.ConfigParser()
config.read('db.cfg')

# DATABASE
SERVER = config['DB']['SERVER']
DATABASE = config['DB']['DB_NAME']
USER = config['DB']['DB_USER']
PASSWORD = config['DB']['DB_PASSWORD']

# RAW DATA INPUT FILES
SPEED_CAMERA_XLS_FILE = config['DATA']['SPEED_CAMERA_XLS_FILE']


def record_update(db, table):
    """
    Updates the update log table for last update timestamp. This should be called after move from stg to prod.
    :param db: pysqldb DbConnect object 
    :param table: table name that was updated
    :return: None
    """
    # TODO: turn this into a SQL function ?
    # TODO: chnage to upsert?
    db.query("""UPDATE _tbl_updates_ SET last_updated = now() WHERE table_name = '{}'""".format(table))


def copy_table_pg(src_pg, src_schema, dest_pg, tbl):
    """
    Standardized copy pg-to-pg function. 
    
    Calls pysqdb.pg_to_pg and copies source table to staging schema, sets permissions and gets all indexes that existed
     on origninal table. 
    :param src_pg: pysqldb DbConnect object or the data source
    :param src_schema: schema of the data source
    :param dest_pg: pysqldb DbConnect object for the destination 
    :param tbl: table name
    :return: Dictionary of {column name: index query} based on idexes at source
    """
    
    # copy data from source to staging
    staging_name = 'stg_{}'.format(tbl)
    pysqldb.pg_to_pg(src_pg, dest_pg, tbl, org_schema=src_schema, dest_schema='staging', dest_name=staging_name)

    # override teh default permissions
    set_permissions(dest_pg, staging_name, 'staging', dest_pg.database)

    # copy all indexes on original table
    # stores the indexes with the field they are indexing to be used later
    # may need to replace the target table name if name changes
    indecies = get_indecies_pg(src_pg, src_schema, tbl)

    # returning dict for now not sure where/when it will be used
    return indecies
    

def copy_table_ms_to_pg(src_pg, src_schema, dest_pg, tbl):
    """
    Standardized copy pg-to-pg function. 
    
    Calls pysqdb.sql_to_pg and copies source table to staging schema, sets permissions and gets all indexes that existed
     on origninal table. 
    :param src_pg: pysqldb DbConnect object or the data source
    :param src_schema: schema of the data source
    :param dest_pg: pysqldb DbConnect object for the destination 
    :param tbl: table name
    :return: Dictionary of {column name: index query} based on idexes at source
    """
    
    #TODO: **FIX TABLE NAME ISSUE HERE**

    # copy data from source to staging
    staging_name = 'stg_{}'.format(tbl)
    pysqldb.sql_to_pg(src_pg, dest_pg, tbl, org_schema=src_schema, dest_schema='staging', dest_name=staging_name, print_cmd =True)

    # override teh default permissions
    set_permissions(dest_pg, staging_name, 'staging', dest_pg.database)

    print 'complete'
    return 
    
    
    
def get_indecies_pg(src_pg, src_schema, tbl):
    """
    Gets all indexes of a table in PostgreSQL
    :param src_pg: pysqldb DbConnect object at data source
    :param src_schema: schema at data source
    :param tbl: table name
    :return: Dictionary of {column name: index query} based on idexes at source
    """
    # query all indexes of origin table
    src_pg.query("""SELECT indexdef
                    FROM pg_indexes
                    WHERE
                        schemaname = '{s}'
                        and tablename = '{t}' 
                    ORDER BY tablename;
                    """.format(s=src_schema, t=tbl))
    # For each colunm with an index add to a dict
    indecies = dict()
    for _ in src_pg.data:
        idx = _[0]
        name, column = extract_field_from_idx_pg(idx)
        indecies[column] = idx
    return indecies


def extract_field_from_idx_pg(idx):
    """
    Finds and extracts the name of the column referenced in an index query in PostgreSQL 
    :param idx: Query string of index
    :return: index name, index column name
    """
    # sample = "CREATE INDEX master_idx ON public.node USING btree (masterid)"
    parse_idx = r'(CREATE[\s+\w+]* INDEX\s+)(\w+)(\s+ON\s+)(\w+\.\w+\s+)(USING\s+[\w+]*\s+)\((\w+)\)'
    matches = re.findall(parse_idx, idx)
    idx_name = matches[0][1]
    idx_column = matches[0][-1]
    return idx_name, idx_column


def set_permissions(db, tbl, schema, src):
    """
    Overrides default permission behaviours. Grants select to public. 
    Adds a comment on the table with timestamp, and source info
    :param db: pysqldb DbConnect object
    :param tbl: table name
    :param schema: schema name
    :param src: Name of origin database or source description 
    :return: None 
    """
    db.query("""
        REVOKE ALL ON {sch}.{t} FROM PUBLIC;
        GRANT SELECT ON {sch}.{t} TO ris_read_only;
        
        COMMENT ON TABLE {sch}.{t} IS 'Transfered from {s} DB on {dt}';""".format(
        t=tbl, s=src, dt=datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'), sch=schema
    ), timeme=False)



    
