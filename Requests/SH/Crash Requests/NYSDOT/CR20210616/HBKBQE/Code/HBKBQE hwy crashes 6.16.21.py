from ris import pysqldb
import datetime 
import pandas as pd
import numpy as np
import os
import requests

timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
ts = datetime.datetime.now().strftime('%Y-%m-%d')


try: 
    db.params['user']
except:
    db = pysqldb.DbConnect(type='PG', server='dotdevrhpgsql01', database='ris')


data =pd.read_excel('BQE Four Crossings Crash Data Request.xlsx')


# ### Reference Markers 
ref_mkr=pd.read_excel('BQE Four Crossings Crash Data Request.xlsx', sheet_name= 'Reference Marker')
markers = tuple(map(str,list(ref_mkr[ref_mkr.columns[6]][2:])))


# ### NYSDOT Data

raw_crashes = db.dfquery("""SELECT ogc_fid, gid, case_num, case_yr, ref_mrkr, accd_dte, road_sys, 
                               num_of_fat, num_of_inj, reportable, police_dep, intersect_, muni, 
                               precinct, num_of_veh, accd_typ, locn, traf_cntl, light_cond, 
                               weather, road_char, road_surf_, collision_, ped_loc, ped_actn, 
                               ext_of_inj, regn_cnty_, accd_tme, rpt_agcy, dmv_accd_c, traf_way, 
                               rdway_acc_, err_cde, comm_veh_a, highway_in, intersect1, utm_northi, 
                               utm_eastin, crashid  
                            FROM nysdot_all
                            WHERE ref_mrkr in {}
                            and case_yr::int between 2016 and 2018

                            """.format(markers))

#crashids
rc = tuple(list(raw_crashes.crashid))

raw_vehicle = db.dfquery("""SELECT *  
                            FROM nysdot_vehicle
                            WHERE crashid in {c}
                            and case_yr between 2016 and 2018
                            """.format(c=rc))
                            

raw_contributing = db.dfquery("""SELECT *  
                                 FROM nysdot_appfactor
                                 WHERE crashid in {c}
                                 and case_yr between 2016 and 2018
                                 """.format(c=rc))


raw_crashes.to_csv('hbkbqe_raw_crashes_{}.csv'.format(ts),index=False)
raw_vehicle.to_csv('hbkbqe_raw_vehicle_{}.csv'.format(ts),index=False)
raw_contributing.to_csv('hbkbqe_raw_contributing_{}.csv'.format(ts),index=False)

