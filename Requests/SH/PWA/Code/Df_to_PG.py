
import ris
from ris import db2  #library designed for SQL database connection and querying
from IPython.display import clear_output
from collections import defaultdict
from collections import defaultdict, namedtuple
import datetime 
import pandas as pd
import numpy as np
import os
from sqlalchemy import create_engine

clear_output()
timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
print 'Notebook run: {}'.format(timestamp)
print os.getcwd()



def df_to_sql(df,tbl_name,db): 
    
    """ (df,tbl,name) """
    
    engine = create_engine('postgresql://{user}:{pw}@10.243.154.88:5432/CRASHDATA'.format(user=db.params['user'],
                                                                                          pw=db.params['password']),
                                                                                          echo=False)
    
    df.to_sql(name='{}'.format(tbl_name), con= engine, if_exists = 'replace', index=False)

    return "Complete"


def change_geom(tbl_name,geom_name):

    db.query("""ALTER TABLE {tbl}
                ALTER COLUMN {geom} TYPE Geometry USING {geom}::Geometry;
                
                grant all on {tbl} to public;""".format(tbl=tbl_name, geom=geom_name))
    
    return tbl_name, "Complete"



if __name__ == "__main__":

    cdb = db2.PostgresDb('DOTDEVRHPGSQL01', 'CRASHDATA', quiet = True)
    
    

