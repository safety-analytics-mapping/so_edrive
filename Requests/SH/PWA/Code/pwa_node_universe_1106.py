
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



@db2.timeDec

def nodes(cdb):
    
    """    
    Function that creates dictionary containing all real intersections nodes 
    in crash database
   
    Args:
        cdb param: Database Connection Function for PostgreSQL 
        
    Returns:
        itx (dict): Dictionary Containing all nodes initialized to master nodes
    """
    
    itx = {}
    result = (cdb.query("""select distinct nodeid, masterid, geom  from node where is_int = true""" ))

    for i in result.data:
        
        itx[int(i[0])]=[int(i[0]),int(i[1]),i[2]]

    itx = pd.DataFrame(itx.values(),  columns=['nodeid', 'masterid', 'geom'])    
    
    return itx


if __name__ == "__main__":
    
    cdb = db2.PostgresDb('DOTDEVRHPGSQL01', 'CRASHDATA', quiet = True)
