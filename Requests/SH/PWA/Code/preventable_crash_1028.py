import pandas as pd
import numpy as np
import datetime
from dateutil.relativedelta import relativedelta
import ris13
from ris13 import pysqldb



# grabbing all crashes with relevant details from victim and vehicle tables
def all_crashes(db,
                start = datetime.datetime.now(),
                end = datetime.datetime.now() - relativedelta(years=3)):
    crashes = db.dfquery("""with c as
    (--selecting all crashes within last 3 years 
        select coalesce(nodeid, lion_node_number) nodeid
        , integration_id
        , cast(accident_dt as date) accident_dt
        , accident_diagram
        , traffic_control
        , accident_desc
        from forms.dbo.wc_accident_f c
        where year(accident_dt) >= 2017
        and accident_dt between '{end}' and '{start}'
        and coalesce(c.nodeid, c.lion_node_number) is not null
        and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
        and coalesce(c.NONMV, 0) = 0
        union 
        select min(s.nodeid) nodeid 
        , c.integration_id
        , cast(c.accident_dt as date) accident_dt
        , accident_diagram
        , traffic_control
        , accident_desc
        from forms.dbo.wc_accident_f c
        join [FORMS].[dbo].[v_IntersectionStreetNames_Gen] s
        on lower(ltrim(rtrim(c.SRC_ON_STREET))) = lower(ltrim(rtrim(s.street_1))) 
        and
        lower(ltrim(rtrim(c.SRC_cross_STREET))) = lower(ltrim(rtrim(s.street_2)))
        and 
        case WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 1 AND 34 THEN 1
            WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 40 AND 52 THEN 2
            WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 60 AND 94 THEN 3
            WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 100 AND 115 THEN 4
            WHEN C.[SRC_POLICE_PRECINCT] BETWEEN 120 AND 123 THEN 5 end 
        in (left(b7sc_2, 1), left(b7sc_1, 1))
        where year(c.accident_dt) >= 2017
        and c.accident_dt between '{end}' and '{start}'
        and coalesce(c.nodeid, c.lion_node_number) is null
        and coalesce(c.VOID_STATUS_CD , 'N') = 'N'
        and coalesce(c.NONMV, 0) = 0
        group by c.integration_id
        , cast(c.accident_dt as date)
        , accident_diagram
        , accident_desc
        , traffic_control
    ),
    v as
    (--selecting all injuries/fatals
        select accident_id, sum(case when inj_killed = 'Killed' then 1 else 0 end) fatal
        , sum(case when ped_nonped = 'Bicyclist' then 1 else 0 end) bike_inj
        , sum(case when person_role_code in ('Pedestrian', 'In-Line Skater') then 1 else 0 end) ped_inj
        , sum(case when ped_nonped = 'Occupant' and person_role_code in ('Driver','Passenger') then 1 else 0 end) mv_inj
        from forms.dbo.wc_accident_victim_f v
        where inj_killed in ('Injured', 'Killed')
        group by accident_id
    ),
    veh as
    (--selecting all motor vehicles with valid vehicle actions
        select accident_id
        , count(distinct row_wid) veh_count
        , sum(case when direction_of_travel in ('North', 'N', 'South', 'S') then 1 else 0 end) north_south_axis
        , sum(case when direction_of_travel in ('West', 'W', 'East', 'E') then 1 else 0 end) east_west_axis
        , sum(case when direction_of_travel in ('Northeast', 'NE', 'Southwest', 'SW') then 1 else 0 end) ne_sw_axis
        , sum(case when direction_of_travel in ('Northwest', 'NW', 'Southeast', 'SE') then 1 else 0 end) nw_se_axis
        from forms.dbo.wc_accident_vehicle_f 
        where pre_acdnt_action not in ('Parked', 'Backing', 'Stopped in Traffic', 'Entering Parked Position', 'Merging',
        'Making U Turn')
        and lower(ltrim(rtrim(vehicle_type_code))) not in ('horse','hrse','hosre', 'bicycle','bike','pedicab', 'bicyc')
        and vehicle_type_code_addl != 'BIKE'
        group by accident_id
        )
    select c.*
    , fatal
    , bike_inj
    , ped_inj
    , mv_inj
    , veh_count
    , north_south_axis
    , east_west_axis
    , ne_sw_axis
    , nw_se_axis
    from c
    left join v
    on c.integration_id = v.accident_id
    left join veh
    on c.integration_id = veh.accident_id
    order by nodeid asc, accident_dt desc
    """.format(start=start, end=end), True)
    crashes.accident_dt = pd.to_datetime(crashes.accident_dt)
    return crashes



# preventable crashes fall under three categories
    # ped injuries
    # bike injuries
    # right angle crashes
        # direction of travel from cars
        # collision type

def crashes_with_prev(crashes):
    df = crashes.copy(deep=True)
    df.loc[(df.veh_count >= 2) &             (df.accident_diagram.isin(['LEFT_TURN', 'RIGHT_TURN', 'RIGHT_ANGLE'])), 'collision_type'] = 1
    df.loc[(df.veh_count >= 2) &             (((df.north_south_axis >= 1) & (df.east_west_axis >= 1)) |
             ((df.ne_sw_axis >= 1) & (df.nw_se_axis >= 1))), 'car_directions'] = 1
    df.loc[df.ped_inj >= 1, 'ped_inj_crash'] = 1 # temp boolean
    df.loc[df.bike_inj >= 1, 'bike_inj_crash'] = 1 # temp boolean
    for c in ['bike_inj_crash', 'ped_inj_crash', 'collision_type', 'car_directions']:
        df[c] = df[c].fillna(0) # can't add nan values
    df['preventable'] = df.collision_type + df.car_directions + df.ped_inj_crash + df.bike_inj_crash
    return df




def preventable_crashes(cwp):
    df = cwp.copy(deep=True)    
    df = df.loc[df.preventable >= 1] # keep only preventable crashes
    return df




# only nodes with 5+ crashes are considered
def crashes_5(preventables):
    df = preventables.copy(deep=True)
# count crashes by nodeid
    counts = df.groupby('nodeid', as_index = False).integration_id.count()
# rename count column for joining
    counts = counts.rename(index=str, columns = {'integration_id':'crashes'})
    df = df.merge(counts)
# take nodes with crash count >= 5
    df = df.loc[df.crashes >= 5]
# convert string to date
    df.accident_dt = pd.to_datetime(df.accident_dt)
#     del crashes['crashes'] # can keep if number of crashes is ever needed
    return df



# Find Date Ranges for 5-Preventable Crash Windows

# For each node, take the difference between current crash and 4th crash after it (total of 5 crashes).
def date_diff(preventables_5):
    df = preventables_5.copy(deep=True)
    # for each node, take difference between crash and 4th crash below it (5 total crashes) to get a difference in days
    df['dif'] = df.groupby('nodeid').accident_dt.diff(periods=-4)
    # convert date type to integer so dataframe can be filtered on it
    df['dif'] = df['dif'].dt.days
    return df




# generate one year window for each crash
def generate_window(preventables_5):
    df = preventables_5
    # generate windows for all crashes
    df['window_start'] = df.accident_dt
    df['window_end'] = df.window_start
    df.window_end = df.window_end.apply(lambda x: x - relativedelta(years = 1))
    return df




# If the difference in days in 365 days (366 days if 2/29/yy is within the timeframe), then it generates a window, with the current crash being the start of the window.
# The end of the window is one year before that crash, which is generated by decrementing the year.

def five_crash_window(preventables_5, leap_year = False):
    df = preventables_5.copy(deep=True)
    df = date_diff(df)
    df = generate_window(df)
    for i in range(datetime.datetime.now().year - 2, datetime.datetime.now().year + 1):
        if i % 4 == 0 and             datetime.datetime.now() >= datetime.datetime(i, 2, 29) >= datetime.datetime.now() - relativedelta(years=3):
            leap_year = i
    # The boolean indicates whether the crash is the latest crash in a one-year rolling window.
    df.loc[df.dif <= 365, 'five_yr'] = 1
    # allowance for leap year - if leap day would be within the window created by the crash, up to 366 days in window
    if leap_year:
        # check for 366 day difference if leap year between window start and window end
        df.loc[(df.dif == 366) & (df.accident_dt >= datetime.datetime(leap_year, 2, 29)) &
               (datetime.datetime(leap_year, 2, 29) >= df.window_end), 'five_yr'] = 1
    # if boolean is False, turn window start and end dates to null
    df.loc[df.five_yr.isna(), 'window_end'] = np.nan
    df.loc[df.five_yr.isna(), 'window_start'] = np.nan
    # dataframe returned is all the potential 5 crash windows
    # clean up unneeded columns
    del df['five_yr']
    return df



# Latest Window Crashes
# Find the latest window by taking the maximum window start date for every node and generate the end date for the window. If accident date within this window, mark it as True.

def last_window(preventables_5):
    df = preventables_5.copy(deep=True)
    # get max window date per node
    latest_start = df.groupby('nodeid', as_index = False).window_start.max()
    # rename column to prevent override while merging
    latest_start = latest_start.rename(index = str, columns = {'window_start':'latest_start'})
    # merge max window date onto each node
    df = df.merge(latest_start, how ='left')
    # generate window end for the latest window for each node
    df['latest_end'] = df.latest_start
    df.latest_end = df.latest_end.apply(lambda x: x - relativedelta(years=1))
    # cleanup unneeded columns
    del df['window_start']
    del df['window_end']
    return df


# In[15]:


def last_window_crashes(preventables_windows):
    df = preventables_windows.copy(deep=True)
    df = last_window(df)
    # boolean for if crash is within window for that node
    df = df.loc[(df.accident_dt <= df.latest_start) &                 (df.accident_dt >= df.latest_end)]
    df.loc[df.preventable >= 1, 'preventable_boolean'] = 1
    return df



def raw_crashes_window(crashes, valid_crashes):
    # raw crash detials within window
    df = crashes.copy(deep=True)
    df2 = valid_crashes.copy(deep=True)
    node_window = df2[['nodeid', 'latest_start', 'latest_end']].drop_duplicates()
    crashes_window = df.merge(node_window)
    crash_raw = crashes_window.loc[(crashes_window.accident_dt >= crashes_window.latest_end)     & (crashes_window.accident_dt <= crashes_window.latest_start)]
    return crash_raw



def raw_preventables_window(crash_raw, valid_crashes):
    # raw preventable crash details
    df2 = valid_crashes.copy(deep=True)
    preventable_raw = crash_raw.merge(df2[['integration_id']])
    return preventable_raw



def summary(crash_raw, preventable_raw, valid_crashes):
    df2 = valid_crashes.copy(deep=True)
    # summarize raw preventable crashes
    preventable_summary = preventable_raw.groupby('nodeid', as_index=False)['fatal', 'bike_inj', 'ped_inj', 'mv_inj'].sum()
    preventable_summary = preventable_summary.rename(index = str, columns = {
                                                                         'fatal':'prevent_fatal',
                                                                         'bike_inj':'prevent_bike_inj',
                                                                         'ped_inj':'prevent_ped_inj',
                                                                         'mv_inj':'prevent_mv_inj'})
    # summarize raw crashes
    crash_summary = crash_raw.groupby('nodeid', as_index=False).integration_id.count().merge(    crash_raw.groupby('nodeid', as_index=False)['fatal', 'bike_inj', 'ped_inj', 'mv_inj'].sum())
    crash_summary = crash_summary.rename(index=str, columns = {'integration_id':'crashes'})
    # summarize preventable conditions
    preventable_condition_summary = df2.groupby(['nodeid', 'latest_start', 'latest_end'], as_index=False)     [['nodeid', 'latest_start', 'latest_end', 'collision_type', 'ped_inj_crash', 'bike_inj_crash', 'car_directions',
    'preventable_boolean']].sum()
    preventable_condition_summary = preventable_condition_summary.rename(index=str, columns = {'preventable_boolean':'preventable_crashes'})
    out = crash_summary.merge(preventable_summary.merge(preventable_condition_summary))
    out = out[['nodeid', 'latest_start', 'latest_end','crashes', 'fatal', 'bike_inj', 'ped_inj', 'mv_inj', 'preventable_crashes',
               'prevent_fatal', 'prevent_bike_inj', 'prevent_ped_inj', 'prevent_mv_inj', 'bike_inj_crash',
               'ped_inj_crash', 'collision_type', 'car_directions']]
    return out

def run():
    sql_db = pysqldb.DbConnect(server='dot55sql01', database='forms', type='MS', user = 'arcgis', password = 'arcgis')
    crashes = all_crashes(sql_db)
    cwp = crashes_with_prev(crashes)
    preventables = preventable_crashes(cwp)
    preventables_5 = crashes_5(preventables)
    preventables_windows = five_crash_window(preventables_5)
    valid_crashes = last_window_crashes(preventables_windows)
    crash_raw = raw_crashes_window(crashes, valid_crashes)
    preventable_raw = raw_preventables_window(crash_raw, valid_crashes)
    output = summary(crash_raw, preventable_raw, valid_crashes)

    return [cwp,output]
    


if __name__ == '__main__':
    # put you function calls and db logings here

    sql_db = pysqldb.DbConnect(server='dot55sql01', database='forms', type='MS', user = 'arcgis', password = 'arcgis')
    crashes = all_crashes(sql_db)
    cwp = crashes_with_prev(crashes)
    preventables = preventable_crashes(cwp)
    preventables_5 = crashes_5(preventables)
    preventables_windows = five_crash_window(preventables_5)
    valid_crashes = last_window_crashes(preventables_windows)
    crash_raw = raw_crashes_window(crashes, valid_crashes)
    preventable_raw = raw_preventables_window(crash_raw, valid_crashes)
    output = summary(crash_raw, preventable_raw, valid_crashes)

