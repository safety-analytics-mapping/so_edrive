
from ris import db2  #library designed for SQL database connection and querying
from IPython.display import clear_output
from collections import defaultdict
from collections import defaultdict, namedtuple
import datetime 
import pandas as pd
import numpy as np
import os
from sqlalchemy import create_engine
import pwa_node_universe_1106 as nu
from Df_to_PG import* 

clear_output()
timestamp = datetime.datetime.now().strftime('%Y-%m-%d_%H:%M')
ts = datetime.datetime.now().strftime('%Y-%m-%d')
print 'Notebook run: {}'.format(timestamp)
print os.getcwd()



def xy_to_geom(cdb,*args): 
    
    """
    Function that generates the hexidecimal geomteric string 
    of every input coordinate. 
   
    Args:
        cdb param: Database Connection Function for PostgreSQL 
        
    *args
        xy arg: X,Y coordinates 
                format: [[x,y][x,y]] or xy=[x,y] or input x=x,y=y

    Returns:
        geom (str): Hexidecimal geomteric string 
        
    
    e.g.
    
    Input:
    
    xy_to_geom(cdb,[[1000245.0, 202806.0],[1000537.9999999995, 186726.9999999482],[1002334.9999999987, 250597.99999993874]])
    
    Returns:
    
    ['0101000020D7080000000000006A862E4100000000B0C10841',
     '0101000020D708000000000000B4882E410000000038CB0641']
    """
    
   
    
    try:
        
        if any(isinstance(item, list) for item in args[0]):  #args is a tuple 
            print('TRUE')
            count=0
            geom =[None]*len(args[0])
            for i in args[0]:
                g=cdb.query("select ST_GeomFROMText('POINT(' || {x}::text || ' ' ||  {y}::text || ')', 2263) geom ".format(x=i[0],y=i[1]))
                #print(g)
                geom[count]=g[0][0][0]
                count+=1

        else:
            #print(args[0])
            if isinstance(args[0], list):
                g = cdb.query("select ST_GeomFROMText('POINT(' || {x}::text || ' ' ||  {y}::text || ')', 2263) geom".format(x=args[0][0],y=args[0][1]))
                geom = g[0][0][0]

    except:
    
        xy = list(args)
        #print(lon_lat)
        g = cdb.query("select ST_GeomFROMText('POINT(' || {x}::text || ' ' ||  {y}::text || ')', 2263) geom".format(x=xy[0],y=xy[1]))
        geom = g[0][0][0]

    return geom



def lon_lat_to_geom(cdb,*args): #input either list of list [[lon,lat][lon,lat]] or list lon_lat=[lon,lat] or input lon=lon,lat=lat 
    
    """
    Function that generates the hexidecimal geomteric string 
    of every input coordinate. 
   
    Args:
        cdb param: Database Connection Function for PostgreSQL 
        
    *args
        lon_lat arg (float): Longitude,Latitude coordinates 
                             format: [[lon,lat][lon,lat]] or [lon,lat] or input lon=lon,lat=lat

    Returns:
        geom (str): Hexidecimal geomteric string 
        
    
    e.g.
    
    Input:
    
    lon_lat_to_geom(cdb,[[-73.99247600,40.71507200],[-73.99247600,40.71507200]])
    
    Returns:
    
    ['0101000020D7080000D5011E94BF192E41347ACDE4A4630841',
     '0101000020D7080000D5011E94BF192E41347ACDE4A4630841']
    """
    
    
  
   
    try:
        if any(isinstance(item, list) for item in args[0]): 
            #print('TRUE')
            count=0
            geom =[None]*len(args[0])
            for i in args[0]:
                #print(i)
                g= cdb.query("select st_transform(ST_PointFromText('POINT(' || {lon} || ' ' || {lat} || ')', 4326), 2263) geom ".format(lon=i[0],lat=i[1]))
                #print(g)
                geom[count]=g[0][0][0]
                count+=1

        else:
            #print(args[0])
            if isinstance(args[0], list):
                g = cdb.query("select st_transform(ST_PointFromText('POINT(' || {lon} || ' ' || {lat} || ')', 4326), 2263) geom ".format(lon=args[0][0],lat=args[0][1]))
                geom = g[0][0][0]

    except:
        lon_lat = list(args)
        #print(lon_lat)
        g = cdb.query("select st_transform(ST_PointFromText('POINT(' || {lon} || ' ' || {lat} || ')', 4326), 2263) geom ".format(lon=lon_lat[0],lat=lon_lat[1]))
        geom = g[0][0][0]

    return geom



def geom_to_lonlat(geom,cdb):
    
    result = cdb.query("""    
                       select ST_AsText(st_transform('{}'::text,4326))
                       """.format(geom))
    
    return result.data[0][0].strip('POINT()').split()




def dist(geom1, geom2):
    
    result =  cdb.query("""select st_distance('{geom1}'::geometry, '{geom2}'::geometry) as distance""")
                       



def to_itx(cdb,**args): 
    
    """
    Function that retrieves nearest intersection from the location
    of input control signal
   
    Args:
        cdb param: Database Connection Function for PostgreSQL
        
    *args:
        rad (int, optional): Search radius for locating nearest node from all way stop
        xy arg (optional if geom given): X,Y coordinates of all way stop
                                         format: [[x,y][x,y]] or xy=[x,y] or input x=x,y=y
        lon_lat arg (optional if geom given): Longitude,Latitude coordinates 
                                              format: [[lon,lat][lon,lat]] or [lon,lat] or input lon=lon, lat=lat
        geom arg (str, optional if xy or lon_lat given): Hexidecimal geomteric string X,Y coordinates of all way stop
        
    Returns:
        result (dataFrame): Nodeid, Distance between Nodeid and Control Signal, Nodeid Geometry, Control geometry, Coordinates
        val (int): 0 if no args given`    
        
    e.g.
    
    Input:
    
    to_itx(cdb,xy=[1000537.9999999995, 186726.9999999482],geom='0101000020D708000000000000B4882E410000000038CB0641')
    
    Returns:
    
    nodeid  distance    node_geom                   control_geom                xy
    26723   0.0340567   0101000020D7080000009...    0101000020D7080000000...    [1000538.0, 186727.0]
    """  
    
    db= cdb
    rad = args.get('rad', 50)  
    geom = args.get('geom', 0)
    xy = args.get('xy', 0)
    lon_lat= args.get('lon_lat', 0)
    coor = lambda x: map(float,x.replace('[','').replace(']','').split(','))  
    
         
    if len(args)==0:
            return 0
    
    if geom==0:
        if xy:
            geom = xy_to_geom(db,xy)
        else:
            geom = lon_lat_to_geom(db,lon_lat)

    
    if xy:
        
        query = """select nodeid,  masterid, st_distance(geom, '{geom}'::geometry) as distance,
                            geom as node_geom, '{geom}'::geometry as control_geom,
                            '{xy}' as xy,  ST_AsText(st_transform(geom::text,4326)) node_lon_lat,
                            ST_AsText(st_transform('{geom}'::text,4326)) control_lon_lat
               from node where st_dwithin('{geom}'::geometry,geom, {rad})
                        and is_int = true
               order by st_distance(geom, '{geom}'::geometry) ASC limit 1
               """.format(geom=geom, rad=rad, xy=xy)
        
        r = db.query(query)[0][0]
        x=list(r[0:7])
        x.append(coor(r[4]))
        
        data=x
        #data = pd.DataFrame(x,index=['nodeid','distance','node_geom','control_geom','xy']).T
        
    elif lon_lat:

        query = """
                   select *, ST_AsText(st_transform(node_geom::text,4326)) node_lon_lat, ST_AsText(st_transform('{geom}'::text,4326)) control_lon_lat
                   from(
                   select nodeid,  masterid, st_distance(geom, '{geom}'::geometry) as distance,
                                geom as node_geom,
                                '{geom}'::geometry as sig_geom  
                   from node where st_dwithin('{geom}'::geometry,geom, {rad})
                            and is_int = true 
                   order by st_distance(geom, '{geom}'::geometry) ASC limit 1) x 
                   """.format(geom=geom, rad=rad, lon_lat=lon_lat)

        r = db.query(query)[0][0]
        x=list(r[0:7])
        #x.append(coor(r[4]))

        data=x
        #data = pd.DataFrame(x,index=['nodeid','distance','node_geom','control_geom','lon_lat']).T     
            
    else:
        
        query = """select nodeid, masterid, st_distance(geom, '{geom}'::geometry) as distance,
                                geom as node_geom, '{geom}'::geometry as control_geom,
                                ST_AsText(st_transform(geom::text,4326)) node_lon_lat,
                                ST_AsText(st_transform('{geom}'::text,4326)) control_lon_lat
                   from node where st_dwithin('{geom}'::geometry,geom, {rad})
                            and is_int = true
                   order by st_distance(geom, '{geom}'::geometry) ASC limit 1
                   """.format(geom=geom, rad=rad)
            
        r = list(db.query(query)[0][0])
        data = pd.DataFrame(r,index=['nodeid','distance','node_geom','control_geom', 'node_lon_lat', 'control_lon_lat']).T
    


    return data



def st_names(nodes,cdb):
    
    result = cdb.query("""    
                        select nodeid::int, array_agg(street) from(
                        select distinct nodeidto nodeid, street
                        from lion 
                        where nodeidto::int in {nodes}

                        union

                        select distinct nodeidfrom nodeid, street
                        from lion 
                        where nodeidfrom::int in {nodes}
                        ) st_names
                        group by nodeid
                        """.format(nodes=nodes))
    
    return pd.DataFrame(result.data, columns = ["nodeid","st_names"])



def google(geom,cdb):
    
    lon_lat = geom_to_lonlat(geom,cdb)
    
    return 'https://www.google.com/maps/@{lon},{lat},19z'.format(lat = lon_lat[0], lon=lon_lat[1])



def all_aws(msdb,cdb,rad=50):

    """
    Function that creates dataframe of all aws x & y coordinates with nearest intersections and details

    
    Args:
        msdb param: Database Connection Function for MS SQL server
        cdb param: Database Connection Function for PostgreSQL
        rad (int,optional): Search radius for locating nearest node from all way stop. Defaults to rad = 1000.
        
    Returns:
        aws_data (List of 2 DataFrames): aws_data[0] - Control Signals with node matches within search radius
                                                     - Nodeid, Distance between Nodeid and All Way Stop, Nodeid Geometry, 
                                                       All Way Stop geometry, All Way Stop X&Y
                                                       
                                         aws_data[1] - Contorl Signals that don't have nodes within search radius
                                                     - control_geom,  xy
    
    e.g.
    
    Input:
    
    aws_data = all_aws(msdb,cdb,50)
    
    Returns:
    
    aws_data[0] - 
    
    nodeid   distance     node_geom                                    control_geom                             xy
    26723    0.0340567    0101000020D7080000009215F0B3882E4100EA8...   0101000020D708000000000000B4882E4100...  [1000538.0, 186727.0]
    44332    0.370932     0101000020D7080000000C4B64BD962E4100200...   0101000020D708000000000000BE962E4100...  [1002335.0, 250598.0]
    27734    0.449713     0101000020D708000000859788F1AB2E4100728...   0101000020D708000000000000F2AB2E4100...  [1005049.0, 192440.0] 
    
    
    aws_data[1] - 
    
    control_geom                                        xy
    0101000020D7080000000000006A862E4100000000B0C1...   [1000245.0, 202806.0]
    0101000020D70800000000000064A72E41000000007830...   [1004466.0, 255503.0]
    0101000020D70800000000000002BA2E4100000000400D...   [1006849.0, 197032.0]
    
    """
    

    result = msdb.query("""    
    
                        SELECT Distinct 
                        'AWS' typ, a.[SRP_Order], a.[SRP_Seq], a.SR_Dsf, a.SR_Date_Last_Faced, a.X, a.Y
                        FROM dot55sql01.datawarehouse.dbo.STATUS_SGNS a 
                        JOIN dot55sql01.datawarehouse.dbo.STATUS_SIGNS b 
                                on SIR_KEY = SR_Mutcd_Code
                        WHERE a.SRP_Type=1
                                and b.MAIN_CATEGORY='Regulatory Sign' --remove parking Signs                                                                                 
                                and b.SUB_CATEGORY='All Way' -- ONLY ALL-WAYS (will only include locations labeled as all-ways) 
                                and x is not null and y is not null

                         """)
    

    aws_data = pd.DataFrame()
    fix = lambda x: float(str(x).strip())
    failed = pd.DataFrame()

    
    for i in result.data:
        try:
            ad1 = [i[0],str(i[1]).strip() + '-' + str(i[2]),str(i[3]).strip()]
            ad2 = to_itx(cdb,rad=50,xy=[fix(i[5]),fix(i[6])])
            ad1.extend(ad2)
            aws_data= aws_data.append(pd.DataFrame(ad1,index=['control_type','control_id', 'sr_dsf',
                                                              'nodeid','distance','node_geom',
                                                              'control_geom','xy']).T,ignore_index = True)
            
        except:
            f=[i[0],str(i[1]).strip() + '-' + str(i[2]),str(i[3]).strip(),fix(i[5]),fix(i[6])]
            f.extend([xy_to_geom(cdb,f[3::])])
            failed=failed.append(pd.DataFrame(f, index = ['control_type','control_id', 'SR_DSF',
                                                          'control_geom','xy','geom']).T,ignore_index = True)    
    
    aws_data['gmaps']= map(lambda x: google(x,cdb), aws_data['control_geom'])
    
    return [aws_data, failed]



def given_aws(cdb):
    
    result = cdb.query("""
                    select *, ST_AsText(st_transform(node_geom::text,4326)), ST_AsText(st_transform(control_geom::text,4326)), st_distance(node_geom, control_geom) from (
                    SELECT distinct 'AWS' control_type, "Order No.", " Sequence No. ", "Last Work Date", "From Node ID" nodeid, masterid, 
                    geom node_geom, ST_GeomFROMText('POINT(' || "X Coord"::text || ' ' ||  "Y Coord"::text || ')', 2263) control_geom
                    FROM working.all_way_stops_data aws
                    left join node n
                    on (aws."From Node ID")::int = n.nodeid::int
                    WHERE "Type" = 'All Way'
                    and TRIM("From Node ID"::char) is not null
                    and TRIM("X Coord"::char) is not null
                    and TRIM("Y Coord"::char) is not null
                    ) x
                    """
                   )   
    aws=pd.DataFrame(result.data, columns=['control_type', 'order_no', 'seq_no','lwd', 'nodeid', 'masterid', 'node_geom','control_geom', 'node_lon_lat', 'control_lon_lat', 'distance'])
    aws['control_id']= aws['order_no'].map(str) + '-' + aws['seq_no'].map(str)
    aws['node_lon_lat'] = map(lambda x: map(float,x.strip('POINT()').split(' ')), aws['node_lon_lat'])
    aws['control_lon_lat'] = map(lambda x: map(float,x.strip('POINT()').split(' ')), aws['control_lon_lat'])
    aws = aws.reindex(columns=['nodeid', 'masterid','control_type', 'control_id', 'node_lon_lat', 'control_lon_lat', 'distance'])
    
    return aws



def all_sigs(gdb,cdb,rad=50):
    
    
    """
    Function that creates dataframe of all signal longitude & latitude coordinates with nearest intersections and details

    
    Args:
        gdb param: Database Connection Function for GISGRID Database
        cdb param: Database Connection Function for PostgreSQL
        rad (int,optional): Search radius for locating nearest node from signal. Defaults to rad = 300.
        
    Returns:
        sig_data (List of 2 DataFrames): sig_data[0] - Control Signals with node matches within search radius
                                                     - Nodeid, Distance between Nodeid and Signal, Nodeid Geometry, 
                                                       Signal geometry, Signal Longitude & Latitude
                                                       
                                         sig_data[1] - Control Signals that don't have nodes within search radius
                                                     - control_geom,  xy
    
    e.g.
    
    Input:
    
    sig_data = all_sigs(gdb,cdb,50)
    
    Returns:
    
    sig_data[0] - 
    
    nodeid   distance   node_geom                                 control_geom                                  lon_lat
    92892    5.06653    0101000020D708000000853B78B7192E4100...   0101000020D7080000D5011E94BF192E41347AC3...   [-73.992476, 40.715072]
    20243    15.4098    0101000020D708000080BECDD3F5FD2D4100...   0101000020D7080000F253F6F0E1FD2D4169633F...   [-74.005343, 40.721694]
    20216    27.9408    0101000020D708000000FB62772CFE2D4100...   0101000020D708000083DE03842AFE2D41A4B226...   [-74.005212, 40.720552]
    20215    0.545153   0101000020D708000080B210CF38FE2D4100...   0101000020D7080000E5AD4DCA37FE2D412DEDC0...   [-74.005188, 40.719838]
    .....    ........     ..........................................   .......................................  .....................
    
    control_geom                                        lon_lat
    0101000020D708000017E7AB2F7B302E41B94928811651...   [-73.98198, 40.713441]
    0101000020D70800008EBC932D40402E417BE2B7749798...   [-73.974688, 40.742205]
    0101000020D70800002A42A900A03C2E41F58695D20751...   [-73.976365, 40.73592]
    .................................................   .....................
    """
    
    
    """
    Function that creates a list of all signal locations in 
    the SIGNAL_CONTROLLER table of the Gisgrid database.
    
    Args:
        gdb param: Database Connection Function for GISGRID Database
        
    Returns:
        sig_data (list): List containing latitudes and longitues for all sgignals retrieved.
    
    e.g.
    
    Returns [[lat, lon]]:
    
    [[-73.992476, 40.715072],
     [-74.005343, 40.721694],
     [-74.005212, 40.720552],
     .......................]]  
    """    
    
   
    result = gdb.query("""

                    SELECT 'SIG' typ, [PSGM_ID], [Longitude] lon, [Latitude] lat
                    FROM [GISGRID].[gisadmin].[SIGNAL_CONTROLLER]
                    where NormalizedType != 'Z'
                    and [Longitude] is not null
                    
                        """)
    
  
    sig_data = pd.DataFrame()
    failed_data = pd.DataFrame()

    for i in result.data:

        try:
            s1 = [i[0],i[1]]
            s2 = to_itx(cdb,rad=50,lon_lat=[float(i[2]),float(i[3])])        
            s1.extend(s2)
            sig_data = sig_data.append(pd.DataFrame(s1,['control_type','control_id','nodeid','masterid','distance','node_geom',
                                                        'control_geom','node_lon_lat','control_lon_lat']).T, ignore_index = True)
        except:
            f = [i[0],i[1]]
            f1=lon_lat_to_geom(cdb,[float(i[2]),float(i[3])])
            f.extend([f1])
            failed_data=failed_data.append(pd.DataFrame(f,index = ['control_type','control_id','contol_geom']).T,ignore_index=True)
    
    sig_data['node_lon_lat'] = map(lambda x: map(float,x.strip('POINT()').split(' ')), sig_data['node_lon_lat'])
    sig_data['control_lon_lat'] = map(lambda x: map(float,x.strip('POINT()').split(' ')), sig_data['control_lon_lat'])
    sig_data = sig_data.reindex(columns=['nodeid', 'masterid','control_type', 'control_id', 'node_lon_lat', 'control_lon_lat', 'distance'])
    return [sig_data, failed_data]



@db2.timeDec
def has_control(df,column):
    
    """    
    Function that filters down control tables to one control
    per node. 
   
    Args:
        df (dataFrame): Dataframe containing all data for node matched to control signals
        
    Returns:
        df (dataFrame): Dataframe containing one to one data for node matched to control signals. 
            
    e.g.
    
    Input:
    
    control = has_control(all_aws(msdb,cdb,50)[0],'nodeid')
    
    Returns:
    
    control_type    control_id      sr_dsf   nodeid   distance   node_geom    control_geom   xy
    AWS             C-399142-4      N        724      21.847148  0101000....  0101000....    [925593.0, 128793.0]
    AWS             C-01275235-4    N        910       0.192036  0101000....  0101000....    [921705.0, 134970.0]
    AWS             C-399505-8      S        967      30.546254  0101000....  0101000....    [922068.0, 135049.0]
    ...             ..........      ..       ...      .........  ...........  ...........    ....................

    Input:
    
    control = has_control(sig_lon_lat_itx(gdb,cdb,50)[0],'nodeid')
    
    control_type    control_id   nodeid   distance   node_geom    control_geom   lon_lat
    SIG             50460        51       12.562571  010100....   010100....     [-74.25183, 40.502775]
    SIG             50266        129       0.649048  010100....   010100....     [-74.246901, 40.509044]
    SIG             50274        193       0.647779  010100....   010100....     [-74.24374, 40.509993]
    ...             .....        ..       .........  ..........   ..........     ........................
    """  
    
    data_dict = {}

    for i in df[column]:

        try:
            data_dict[i]
        except:
            data_dict[i] = df.loc[df.nodeid==i].iloc[0]

    data=pd.DataFrame.from_dict(data_dict,orient='index')
    data=data.reset_index(drop=True)
    
    return data



def run(cdb,gdb,msdb):
    
    """
    Function that exports necessary control tables to excel for quicker processing. 
    Writes out all single aws control signals matched to nodes and all single signal
    control signals matched to nodes.
    
    Args: None

    Returns: "Complete"
    
    """    
    
    aws_control = has_control(all_aws(msdb,cdb,50)[0],'nodeid')
    sig_control = has_control(all_sigs(gdb,cdb,50)[0],'nodeid')
    
    aws_control.to_csv('solo_aws_{}.csv'.format(ts),index=False)
    sig_control.to_csv('solo_sigs_{}.csv'.format(ts),index=False)
    
    return ['solo_aws_{}.csv'.format(ts), 'solo_sigs_{}.csv'.format(ts)]
    



def tbl_check(nodes,tbl):

    """
    Function that displays boolean of wether input nodes have a control signal
    
    Args: 

        nodes (int): Nodes 
        tbl (dataFrame): Table containing all node matched to control signal information

    Returns: 

        None: If no nodes are passed
        query (dict): Dictionary of node:boolean        
    """    

    query = {}
    df = tbl['nodeid']
    
    if len(nodes)==0:
        return
 
    for i in nodes:
        if any(df.isin([i])):
            query[i] = True 
        else:
            query[i] = False

    return query
    



def details(nodes,tbl):

    """
    Function that returns details of input nodes that do have a control signal

    Args: None

    Returns: 

        dtl (dict): Dictionary of node:[dist, node_geom, control_geom, xy]

    """     

    check = tbl_check(nodes,tbl)

    dtl = {i[0]:list(tbl.loc[tbl['nodeid']==i[0]].values[0]) for i in (filter(lambda elem: elem[1] == True, check.items()))}

    return dtl



def g_run(cdb,gdb,msdb):
    
    """
    Function that exports necessary control tables to excel for quicker processing. 
    Writes out all single aws control signals matched to nodes and all single signal
    control signals matched to nodes.
    
    Args: None

    Returns: "Complete"
    
    """    
    
    g_aws_control = has_control(given_aws(cdb),'nodeid')
    g_sig_control = has_control(all_sigs(gdb,cdb,50)[0],'nodeid')
    
    
    g_aws_control.to_csv('g_solo_aws_{}.csv'.format(ts),index=False)
    g_sig_control.to_csv('g_solo_sigs_{}.csv'.format(ts),index=False)
    
    
    return ['g_solo_aws_{}.csv'.format(ts), 'g_solo_sigs_{}.csv'.format(ts)]



def google(geom,cdb):
    
    lon_lat = geom_to_lonlat(geom,cdb)
    
    return 'https://www.google.com/maps/@{lon},{lat},19z'.format(lat = lon_lat[0], lon=lon_lat[1])




def cmids(df):
    c = df.copy(deep=True)
    return c[['masterid', 'geom', 'st_names', 'gmaps', 'control_type','control_id', 'node_lon_lat', 'control_lon_lat', 'distance']]            .loc[c['control_type'].notnull()==True]            .loc[c['masterid'].duplicated()==True]            .drop_duplicates(['masterid'],keep='first')



def controlled_mids(df):
    df1 = df.copy(deep=True)
    data = cmids(df1)
    for mid in data['masterid']:

        df1.loc[df1.masterid.isin([np.int64(mid)]) & df1.control_type.isnull(),              ['masterid', 'geom', 'st_names', 'gmaps', 'control_type',
               'control_id', 'node_lon_lat', 'control_lon_lat', 'distance']]\
       = data[['masterid', 'geom', 'st_names', 'gmaps', 'control_type',
               'control_id', 'node_lon_lat', 'control_lon_lat', 'distance']]\
              .loc[data['masterid']==np.int64(mid)].values
    return df1



def control(cdb,gdb,msdb):
    
    names = run(cdb,gdb,msdb)

    nodes = nu.nodes(cdb)
    nodes= pd.DataFrame(nodes.items(),  columns=['nodeid', 'masterid'])

    aws_data = pd.read_csv(names[0])
    sig_data = pd.read_csv(names[1])
    
    data = pd.concat([aws_data[['nodeid','control_type','control_id','gmaps']],sig_data[['nodeid','control_type','control_id','gmaps']]], ignore_index=True)
    cntrl1 = nodes.merge(data, how='left', on='nodeid')
    cntrl2= controlled_mids(cntrl1)
    
    nodes = tuple(cntrl2.loc[cntrl2.control_type.notnull()].nodeid.unique())
    stn = st_names(nodes,cdb)
    
    cntrl_final = cntrl2.merge(stn, on='nodeid', how='left')
    cntrl_final = cntrl_final.reindex(columns=['nodeid','control_type','control_id','st_names','gmaps'])
    cntrl_final.to_csv('g_raw_cntrl_data_{}.csv'.format(ts),index=False)
    
    return cntrl_final



def given_control(cdb,gdb,msdb):
    
    names = g_run(cdb,gdb,msdb)

    nodes = nu.nodes(cdb)
    stn = st_names(tuple(map(str,nodes.nodeid)),cdb)
    nodes = nodes.merge(stn,on='nodeid',how='left')
    nodes['gmaps']= map(lambda x: google(x,cdb), nodes['geom'])

    aws_data = pd.read_csv(names[0])
    sig_data = pd.read_csv(names[1])
    
    data = pd.concat([aws_data[['nodeid','control_type', 'control_id', 'node_lon_lat', 'control_lon_lat', 'distance']]                 ,sig_data[['nodeid','control_type', 'control_id', 'node_lon_lat', 'control_lon_lat', 'distance']]], ignore_index=True)
    cntrl = nodes.merge(data, how='left', on='nodeid')
    cntrlf = controlled_mids(cntrl)

    cntrlf = cntrlf.reindex(columns=['nodeid', 'masterid','control_type', 'control_id', 'node_lon_lat', 'control_lon_lat', 'distance', 'st_names','gmaps'])
    cntrlf.to_csv('g_raw_cntrl_data_{}.csv'.format(ts),index=False)
    uncntrl = cntrlf.loc[cntrlf.control_type.isnull()]
    uncntrl.to_csv('g_raw_uncntrl_data_{}.csv'.format(ts),index=False)
    
    return cntrlf




def call():
    
    """
    given_control(cdb,gdb,msdb)
    
    This function will output necessary tables for complete join
    
    """


if __name__ == "__main__":

    cdb = db2.PostgresDb('DOTDEVRHPGSQL01', 'CRASHDATA', quiet = True)
    gdb = db2.SqlDb('dotgissql01', 'gisgrid', user='GISUSER', db_pass='GISUSER') #Database Connection
    msdb = db2.SqlDb('DOT55SQL01', 'DataWarehouse', user='arcgis', db_pass='arcgis') #Database Connection


