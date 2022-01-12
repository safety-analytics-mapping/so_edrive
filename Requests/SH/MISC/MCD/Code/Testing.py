__author__ = 'Soge'
import DataConnection as Dc
from collections import defaultdict
import time
import datetime
import operator
import csv



def timeit(method):
    def timed(*args, **kw):
        ts = time.time()  #Returns the time in seconds since the epoch as a floating point number
        result = method(*args, **kw)  #*args, **kw takes any extra arguments that are passed along with the method
        te = time.time()  #Return the time in seconds since the epoch as a floating point number
        print '%r %2.2f sec' % (method.__name__, te-ts) #String formatting
        return result
    return timed



# get all intersections - PG (nodes)
@timeit # Decorator running the timeit function for get_intersection_universe --> get_intersection_universe = timeit(get_intersection_universe)
def get_intersection_universe(pg):
    cur = pg.conn.cursor()
    #.conn.cursor() Handles the connection to a PostgreSQL database instance. It encapsulates a database session. Return a new cursor object using the connection.

    cur.execute("select nodeid, masterid, is_int  from node where is_int = true")#Execute a database operation (query or command)
    # dictionary of nodeid: [masterid, intersection]
    nodes = defaultdict(list, ((int(row[0]), [row[1], row[2]]) for row in cur.fetchall()))
    # cur.fetchall() Fetch all (remaining) rows of a query result, returning them as a list of tuples. An empty list is returned if there is no more record to fetch.
    del cur
    #deletes cur to reset the memory for a new query
    return nodes




#get all signalized intersections - SQL (gisgrid)
@timeit
def alt_get_signalized_int(db, pg, nodes):
    cur = db.conn.cursor()
    cur.execute("""SELECT [PSGM_ID],[ContrType],[NodeID],[Longitude],[Latitude]
                    FROM [GISGRID].[gisadmin].[SIGNAL_CONTROLLER]
                    --[LION_CURRENT].[GISADMIN].[SIG_TRpsgm] 
                    where NormalizedType != 'Z'
                    --and [Longitude] not in ('','S' ) and  [Latitude] not in ('')
                    and [Longitude] is not null
                    --and psgm_id in (41084, 41083)""")
    for row in cur .fetchall():
        psgm_id, contrtype, nodeid, x, y = row
        nodeid = alt_get_node_from_signal_coords(pg, str(x), str(y))
        if nodeid:
            nodes[int(nodeid)].append('Signal')
    del cur
    return nodes



#Selects nodes that are in the vicinity of signal coordinate
def alt_get_node_from_signal_coords(pg, x, y):
    cur = pg.conn.cursor()
    cur.execute("""select nodeid, st_distance(geom, st_transform(st_geomfromtext(
                        'SRID=4326;POINT(%s %s)'), 2263)) as distance
                    from node where st_distance(geom, st_transform(st_geomfromtext(
                        'SRID=4326;POINT(%s %s)'), 2263)) < 1000
                    and is_int = true
                    order by geom <#> st_transform(st_geomfromtext('SRID=4326;POINT(%s %s)'), 2263) limit 1
                """ % (x, y, x, y, x, y)
                )
    row = cur.fetchone()
    del cur
    if row:
        return int(row[0])
    else:
        return None




# make list of unsignalized masterids
@timeit
def  get_unsignalized_masterids(nodes):
    mids = defaultdict(list)
    to_remove = set()
    for node in nodes.keys():
        mids[nodes[node][0]].append(node)
        if nodes[node][-1] == 'Signal':
            to_remove.add(nodes[node][0])
    for m in to_remove:
        del(mids[m])
    return mids


# get crashes at unsignalized masters
@timeit
def get_all_crashes(pg):
    # test speed of doing 1 query and iterating in python memory
    cur = pg.conn.cursor()
    cur.execute("""select distinct c.crashid, c.nodeid, c.accd_dte, c.num_of_inj, c.num_of_fat, c.accd_type_int, c.collision_,
                    c.ext_of_inj, 0 as pre_action, 0 as direction, 0 as contrib
                    from nysdot_all c
                    --left outer join crashes_lookup_all l on c.crashid = l.crashid
                    where c.case_yr > (select max(c.case_yr)-3 from nysdot_all c) and c.loc = 'INT'
                    and c.nodeid is not null
                """)
    data = cur.fetchall()
    del cur
    return data
















