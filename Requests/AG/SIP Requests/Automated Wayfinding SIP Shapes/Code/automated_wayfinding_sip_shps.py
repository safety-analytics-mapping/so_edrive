import datetime
import os
import configparser

from ris import pysqldb

timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
ts = datetime.datetime.now().strftime('%Y-%m-%d')

LOC = r'C:\Users\soge\Desktop\GitHub\MiscRequests\Automated_Wayfinding_SIP_shps'
config = configparser.ConfigParser()
config.read(os.path.join(LOC, 'db.cfg'))
print config.keys()

# DATABASE
SERVER = config.get('DB', 'SERVER')
DATABASE = config.get('DB', 'DB_NAME')
USER = config.get('DB', 'DB_USER')
PASSWORD = config.get('DB', 'DB_PASSWORD')



#ALL Planned SIP Corridor Projects
corr_query = """

SELECT sp.pid, sp.sip_year, sp.unit, sp.pm, sp.status_desc, spg.geom
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
WHERE (sp.sip_year = date_part('year', CURRENT_DATE) or sp.sip_year = (date_part('year', CURRENT_DATE)+1))
and sp.status_desc = 'SIP'
and nodeid = 0
"""

#ALL Planned SIP Intersection Projects
ints_query = """

SELECT sp.pid, sp.sip_year, sp.unit, sp.pm, sp.status_desc, spg.geom
FROM public.sip_projects sp
JOIN sip_projects_geo spg
ON sp.pid = spg.pid_fk
WHERE (sp.sip_year = date_part('year', CURRENT_DATE) or sp.sip_year = (date_part('year', CURRENT_DATE)+1))
and sp.status_desc = 'SIP'
and segmentid = 0
"""

complete = False

def log_updates(complete):

    with open(os.path.join(LOC,'wayfinding_sip_shps_update.txt'), 'w') as f:
              
        if complete == True:
            f.write('UPDATED:\n')  
            f.write('Automated_Wayfinding_SIP_shps  {}\n'.format(timestamp))
        else:            
            f.write('\n\nFAILED:\n')
            f.write('Automated_Wayfinding_SIP_shps  {}\n'.format(timestamp))
           
    os.startfile(os.path.join(LOC,'wayfinding_sip_shps_update.txt'))


def sip_shps(p):
    
    """
    Function that takes pass in folder path will return boolean 
    determining wheter shapefile has been written.

    :param p: folder path
    :return: boolean
    """


    db.query_to_shp(corr_query, path=p, shp_name='proposed_sip_lines.shp')
    db.query_to_shp(ints_query, path=p, shp_name='proposed_sip_points.shp')
    
    return True
    


def run(*args):

    if len(args) == 0:
        p = 'Y:\\'
    else:
        p = args[0]
    print 'Writing shapefile to: ', p
    
    complete = sip_shps(p) #Complete returns true if shapefile has been written
    log_updates(complete)

if __name__ == "__main__":

    db = pysqldb.DbConnect(type='PG', server=SERVER, database=DATABASE,
                           user=USER, password=PASSWORD)

    run()