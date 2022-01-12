from ris import pysqldb, __version__ as v
from IPython.display import clear_output
from collections import defaultdict
from collections import defaultdict, namedtuple
import datetime 
import pandas as pd
import numpy as np
import os
from sqlalchemy import create_engine

clear_output()
timestamp = datetime.datetime.now().strftime('%Y-%m-%d_%H:%M')
ts = datetime.datetime.now().strftime('%Y-%m-%d')

print 'Notebook run: {}'.format(timestamp)
print os.getcwd()
print v

cdb = pysqldb.DbConnect(server='DOTDEVRHPGSQL01', database='CRASHDATA', type='PG')

cdb.connect()

cdb.shp_to_table(path=r'E:\RIS\Staff Folders\Samuel\Requests\SH\Speed Humps\Installations_2018toJan2020',shp_name='Installations_2018toJan2020.shp',schema='working',  overwrite=True)

raw_input()
