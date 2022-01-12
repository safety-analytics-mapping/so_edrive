from ris import db2  #library designed for SQL database connection and querying
from IPython.display import clear_output
from collections import defaultdict
from collections import defaultdict, namedtuple
import datetime 
import pandas as pd
import numpy as np
import os
from sqlalchemy import create_engine
import pwa_control_1119 as control
from Df_to_PG import* 
import preventable_crash_1028 as pc
import pwa_node_universe_1106 as nu

clear_output()
timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
ts = datetime.datetime.now().strftime('%Y-%m-%d')
print 'Notebook run: {}'.format(timestamp)
print os.getcwd()
# %load_ext sql 


# In[2]:


cdb = db2.PostgresDb('DOTDEVRHPGSQL01', 'CRASHDATA', quiet = True)
gdb = db2.SqlDb('dotgissql01', 'gisgrid', user='GISUSER', db_pass='GISUSER') #Database Connection
msdb = db2.SqlDb('DOT55SQL01', 'DataWarehouse', user='arcgis', db_pass='arcgis') #Database Connection


# In[3]:


def pwa(cdb,gdb,msdb):
    
    c1 = control.given_control(cdb,gdb,msdb)
    c2 = c1.copy(deep=True)   
    pc_data = pc.run()
    
    raw_data = c1.merge(pc_data[0], how='left', on='nodeid')
    summary_data = c2.merge(pc_data[1], how='left', on='nodeid')
    final = summary_data.loc[summary_data.preventable_crashes.notnull() & summary_data.control_type.isnull()]
    
    raw_data.to_csv('raw_data_{}.csv'.format(ts), encoding = 'UTF-8',index=False)
    final.to_csv('final_data_{}.csv'.format(ts), encoding = 'UTF-8',index=False)
    
    return [raw_data,summary_data,final]


# In[4]:


#pwa data is a list that contain all the raw data for signalized and unsignalized intersections with all crashes,
#the summary data that filters out intersections with less than 5 preventable crashes, and 
#the final data which is all the intersections which have 5 preventable crashes within a year

pwa_data = pwa(cdb,gdb,msdb)


# ### Check #1: Top 5 Unsignalized nodes with most crashes 
# 
# #### Node 41808 does not make it to the summary output because the distribution of its preventable crahses fall outside of the range of 1 year

# In[5]:


pwa_data[0].loc[(pwa_data[0].control_type.isnull())].nodeid.value_counts().head()


# In[6]:


top5_nodes = [52651, 40759, 41808, 49100, 105003]


# In[7]:


#Are the 5 Unsignalized nodes with most crashes  in the summary output?
pwa_data[2].loc[pwa_data[2].nodeid.isin(top5_nodes)]


# In[8]:


top5_all_crashes = pwa_data[0].loc[(pwa_data[0].nodeid.isin(top5_nodes))]


# In[9]:


top5_all_crashes.to_csv('top5_all_crashes.csv', encoding = 'UTF-8')


# ### Check 2: Unsignalized nodes that have preventable crashes that are filtered from the 5 preventables list. 

# In[10]:


#unsignalized_preventables is the df that contains all the preventable crashes that have unsignalized nodes. 

unsignalized_preventables = pwa_data[0].loc[(pwa_data[0].preventable >= 1) & (pwa_data[0].control_type.isnull())].groupby(pwa_data[0].nodeid).count()
#unsignalized_preventables 


# In[11]:


#nodes

preventables_5 = map(int,list(unsignalized_preventables.loc[unsignalized_preventables.nodeid>=5].index))


# In[13]:


out_of_year_range = set(preventables_5) - set(map(int, list(pwa_data[2].nodeid)))


# In[14]:


len(out_of_year_range)


# In[15]:


ooyr_nodes = pwa_data[0].loc[(pwa_data[0].nodeid.isin(out_of_year_range)) & (pwa_data[0].preventable >= 1)]


# In[16]:


ooyr_nodes .to_csv('out_of_year_range.csv', encoding = 'UTF-8')


# ### Check 3: Bottom 2 unsignalized nodes that are on summary list

# In[17]:


#This query grabs total crashes by node above the year 2017 

raw_forms_data = db2.query_to_table(msdb,""" 
                            select coalesce(nodeid, lion_node_number) nodeid 
                            , count(integration_id) all_crashes
                            from forms.dbo.wc_accident_f c
                            where year(ACCIDENT_DT)>=2017
                            and coalesce(c.nodeid, c.lion_node_number) is not null
                            group by coalesce(nodeid, lion_node_number)
                            
                             """) 


# In[18]:


uncontrolled = pd.read_csv('g_raw_uncntrl_data_{}.csv'.format(ts))


# In[19]:


all_crashes_uncontrolled =  uncontrolled[['nodeid']].merge(raw_forms_data, on = 'nodeid')


# In[20]:


bottom_2 = all_crashes_uncontrolled.merge(pwa_data[2], on='nodeid',how = 'right').sort_values(by=['all_crashes'], ascending= True).head(2)


# In[21]:


bottom_2 


# In[22]:


#This query return the total amount of crashes for those bottom 2 nodes

for i in bottom_2.values:

    print(db2.query_to_table(msdb,"""    
           select coalesce(nodeid, lion_node_number) nodeid 
           , count(distinct(integration_id)) cases
           from forms.dbo.wc_accident_f c
           where  year(accident_dt) >= 2017
           and coalesce(VOID_STATUS_CD, 'N') = 'N' 
           and (
             coalesce(NODEID, [LION_NODE_NUMBER]) = {node}
             or (
                   SRC_ON_STREET in ({st_name})
                   and SRC_CROSS_STREET in ({st_name})
                   )
                   )
           group by coalesce(nodeid, lion_node_number)
           """.format(node= int(i[0]), st_name = "{}".format(str(i[8]).strip('[]'))
                     )))


# In[23]:


#This is to match crash cases for summary output

for i in bottom_2.values:
    
    print(db2.query_to_table(msdb,"""    
           select coalesce(nodeid, lion_node_number) nodeid 
           , count(distinct(integration_id)) cases
           from forms.dbo.wc_accident_f c
           where cast(accident_dt as date) between '{start}' and '{end}'
           and coalesce(VOID_STATUS_CD, 'N') = 'N' 
           and (
             coalesce(NODEID, [LION_NODE_NUMBER]) = {node}
             or (
                   SRC_ON_STREET in ({st_name})
                   and SRC_CROSS_STREET in ({st_name})
                   )
                   )
           group by coalesce(nodeid, lion_node_number)
           """.format(node= int(i[0]), start = i[11], end = i[10],
                      st_name = "{}".format(str(i[8]).strip('[]')))
                            ))


# In[24]:


# This is match crash case statistics for bike, ped, mv injuries to summary output

for i in bottom_2.values:    
    y= db2.query_to_table(msdb,"""    
           select coalesce(nodeid, lion_node_number) nodeid, integration_id cases
           from forms.dbo.wc_accident_f c
           where cast(accident_dt as date) between '{start}' and '{end}'
           and coalesce(VOID_STATUS_CD, 'N') = 'N' 
           and (
             coalesce(NODEID, [LION_NODE_NUMBER]) = {node}
             or (
                   SRC_ON_STREET in ({st_name})
                   and SRC_CROSS_STREET in ({st_name})
                   )
                   )
           """.format(node= int(i[0]), start = i[11], end = i[10],
                      st_name = "{}".format(str(i[8]).strip('[]'))))
                            
    
    print(db2.query_to_table(msdb,"""    
           select accident_id, sum(case when inj_killed = 'Killed' then 1 else 0 end) fatal
           , sum(case when ped_nonped = 'Bicyclist' then 1 else 0 end) bike_inj
           , sum(case when person_role_code in ('Pedestrian', 'In-Line Skater') then 1 else 0 end) ped_inj
           , sum(case when ped_nonped = 'Occupant' and person_role_code in ('Driver','Passenger') then 1 else 0 end) mv_inj
           from forms.dbo.wc_accident_victim_f v
           where inj_killed in ('Injured', 'Killed')
           and cast(accident_dt as date) between '{start}' and '{end}'
           and ACCIDENT_ID in {y}
           group by accident_id
           """.format(start = i[11], end = i[10], y = tuple(map(int,list(y.cases))))))


# ### Check 4: Top 3 unsignalized nodes that are on raw crash list that are not on summary output

# In[25]:


#grabs the top 3 unsingalized nodes with most crashes

top3_nodes = all_crashes_uncontrolled[['nodeid']].drop_duplicates().merge(raw_forms_data, on= 'nodeid', how = 'left').sort_values(by=['all_crashes'], ascending= False)


# In[26]:


#checks if top 3 crashes are on summary output
result = top3_nodes.merge(pwa_data[2], on='nodeid', how = 'left')


# In[27]:


result.loc[result.st_names.isnull()].sort_values(by=['all_crashes'], ascending = False).head(3)


# In[28]:


n = [41808,41448,34229]


# In[29]:


top3_all_crashes = pwa_data[0].loc[(pwa_data[0].nodeid.isin(n))]


# In[30]:


top3_all_crashes.to_csv('top3_all_crashes.csv')

