__author__ = 'SHostetter'
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




# TODO: add in allway stops (from exclusion [?])-get from DOT55SQL01 | LION_CURRENT.GISADMIN.V_ALL_WAYS_STOP (view)
# [LION_CURRENT].[GISADMIN].[v_AWS_TEST] (view)
# get all signalized intersections MSQL
@timeit
def get_signalized_int(db, pg, nodes):
    cur = db.conn.cursor()
    cur.execute("""SELECT [PSGM_ID],[CONTRTYPE],[NODEID], POINT_X, POINT_Y
                FROM [GISGRID].[gisadmin].[SIGNAL_CONTROLLER] where NormalizedType != 'Z'""")
    for row in cur .fetchall():
        psgm_id, contrtype, nodeid, x, y = row
        nodeid = get_node_from_signal_coords(pg, x, y)
        if nodeid:
            nodes[int(nodeid)].append('Signal')
    del cur
    return nodes

def get_node_from_signal_coords(pg, x, y):
    cur = pg.conn.cursor()
    cur.execute("""select nodeid, st_distance(geom, 'SRID=2263;POINT(%i %i)') as distance
                    from node where st_distance(geom, 'SRID=2263;POINT(%i %i)') < 1000
                    and is_int = -1
                    order by geom <#> 'SRID=2263;POINT(%i %i)' limit 1
                """ % (x, y, x, y, x, y)
                )
    row = cur.fetchone()
    del cur
    if row:
        return int(row[0])
    else:
        return None

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


# get crashes at unsignalized masters
@timeit
def get_all_crashes_nypd(db2):
    # test speed of doing 1 query and iterating in python memory
    cur = db2.conn.cursor()
    cur.execute("""SELECT distinct c.[ANUM_PCT]+c.[ANUM_YY]+c.[ANUM_SEQ] as crashid ,
                    c.[NODEID], cast(c.[OCCURRENCE_DATETIME] as DATE) as accd_date,
                    c.[INJURED_COUNT],c.[KILLED_COUNT],
                    case when vic.ped_nonped = 'P' then 1
                    when vic.PED_NONPED = 'B' then 2 else 3 end as inj_mode,
                    c.[ACCIDENT_DIAGRAM]  AS [COLLISION_TYP],
                    null as ext_of_inj, 0 as pre_action, 0 as direction, 0 as contrib
                    FROM [DataWarehouse].[dbo].[AIS_PD_Core_F] AS c
                    LEFT OUTER JOIN (
                        SELECT [ANUM_PCT], [ANUM_YY], [ANUM_SEQ],
                        MAX(CASE WHEN PRE_ACDNT_ACTION = '10' THEN 1
                        WHEN PRE_ACDNT_ACTION in ('15', '08', '09', '14', '04') THEN 1 -- removes other non-preventable
                        ELSE 0 END) AS PK
                        FROM [DataWarehouse].dbo.AIS_PD_Vehicle_F
                        GROUP BY [ANUM_PCT], [ANUM_YY], [ANUM_SEQ]
                    )AS v -- parked vehicles
                    ON c.[ANUM_PCT] = v.ANUM_PCT AND c.[ANUM_YY] = v.ANUM_YY AND c.[ANUM_SEQ] = v.ANUM_SEQ
                    LEFT OUTER JOIN DataWarehouse.dbo.AIS_PD_Pedestrian_F AS P
                    ON c.[ANUM_PCT] = P.ANUM_PCT AND c.[ANUM_YY] = P.ANUM_YY AND c.[ANUM_SEQ] = P.ANUM_SEQ
                    LEFT OUTER JOIN DataWarehouse.dbo.AIS_PD_Victim_F as vic
                    ON c.ANUM_PCT = vic.ANUM_PCT and c.ANUM_SEQ = vic.ANUM_SEQ and c.ANUM_YY = vic.ANUM_YY
                    WHERE C.OCCURRENCE_DATETIME > (select dateadd(week, -3, dateadd(year, -3, getdate())))
                    AND C.NODEID != 0
                    and v.PK != 1
                """)
    data = cur.fetchall()
    del cur
    # clean up dates
    for row in data:
        d = row[2]  # date field
        row[2] = datetime.datetime.strptime(d, "%Y-%m-%d").date()
    assert isinstance(data, object)
    return data


@timeit
def get_all_dir_right_angle_crashes_nypd(db2):
    cur = db2.conn.cursor()
    # cur.execute("""-- north / south
    #                 select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
    #                 --n.*, o.DIRECTION_OF_TRAVEL
    #                 from (
    #                     SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    #                     FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    #                     where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    #                     and [DIRECTION_OF_TRAVEL] in (1, 5)
    #                     and PRE_ACDNT_ACTION not in ('09', '10', '14', '15')
    #                 ) as n
    #                 join (
    #                     SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    #                     FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    #                     where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    #                     and [DIRECTION_OF_TRAVEL] not in (1, 5)
    #                     and PRE_ACDNT_ACTION not in ('09', '10', '14', '15')
    #                 ) as o
    #                 on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
    #                     and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER
    #
    #                 union
    #                 -- east / west
    #                 select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
    #                 --n.*, o.DIRECTION_OF_TRAVEL
    #                 from (
    #                     SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    #                     FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    #                     where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    #                     and [DIRECTION_OF_TRAVEL] in (3,7)
    #                     and PRE_ACDNT_ACTION not in ('09', '10', '14', '15')
    #                 ) as n
    #                 join (
    #                     SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    #                     FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    #                     where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    #                     and [DIRECTION_OF_TRAVEL] not in (3,7)
    #                     and PRE_ACDNT_ACTION not in ('09', '10', '14', '15')
    #                 ) as o
    #                 on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
    #                     and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER
    #
    #                 union
    #                 -- northeast / southwest
    #                 select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
    #                 --n.*, o.DIRECTION_OF_TRAVEL
    #                 from (
    #                     SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    #                     FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    #                     where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    #                     and [DIRECTION_OF_TRAVEL] in (2, 6)
    #                     and PRE_ACDNT_ACTION not in ('09', '10', '14', '15')
    #                 ) as n
    #                 join (
    #                     SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    #                     FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    #                     where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    #                     and [DIRECTION_OF_TRAVEL] not in (2, 6)
    #                     and PRE_ACDNT_ACTION not in ('09', '10', '14', '15')
    #                 ) as o
    #                 on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
    #                     and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER
    #
    #                 union
    #                 -- northwest / southeast
    #                 select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
    #                 --n.*, o.DIRECTION_OF_TRAVEL
    #                 from (
    #                     SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    #                     FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    #                     where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    #                     and [DIRECTION_OF_TRAVEL] in (4, 8)
    #                     and PRE_ACDNT_ACTION not in ('09', '10', '14', '15')
    #                 ) as n
    #                 join (
    #                     SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
    #                     FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
    #                     where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
    #                     and [DIRECTION_OF_TRAVEL] not in (4, 8)
    #                     and PRE_ACDNT_ACTION not in ('09', '10', '14', '15')
    #                 ) as o
    #                 on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
    #                     and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER""")
    cur.execute("""/* conservative */
                    -- north / south
                    select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
                    --n.*, o.DIRECTION_OF_TRAVEL
                    from (
                        SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
                        FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
                        where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
                        and [DIRECTION_OF_TRAVEL] in (1, 5)
                        and PRE_ACDNT_ACTION != '10'
                    ) as n
                    join (
                        SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
                        FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
                        where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
                        and [DIRECTION_OF_TRAVEL] in (3, 7)
                    ) as o
                    on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
                        and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER

                    union
                    -- east / west
                    select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
                    --n.*, o.DIRECTION_OF_TRAVEL
                    from (
                        SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
                        FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
                        where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
                        and [DIRECTION_OF_TRAVEL] in (3,7)
                    ) as n
                    join (
                        SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
                        FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
                        where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
                        and [DIRECTION_OF_TRAVEL] in (1, 5)
                    ) as o
                    on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
                        and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER

                    union
                    -- northeast / southwest
                    select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
                    --n.*, o.DIRECTION_OF_TRAVEL
                    from (
                        SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
                        FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
                        where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
                        and [DIRECTION_OF_TRAVEL] in (2, 6)
                    ) as n
                    join (
                        SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
                        FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
                        where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
                        and [DIRECTION_OF_TRAVEL] in (4, 8)
                    ) as o
                    on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
                        and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER

                    union
                    -- northwest / southeast
                    select distinct n.ANUM_PCT+ n.[ANUM_YY]+ n.[ANUM_SEQ] as crashid
                    --n.*, o.DIRECTION_OF_TRAVEL
                    from (
                        SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
                        FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
                        where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
                        and [DIRECTION_OF_TRAVEL] in (4, 8)
                    ) as n
                    join (
                        SELECT ANUM_PCT, ANUM_YY, ANUM_SEQ, VEHICLE_NUMBER, DIRECTION_OF_TRAVEL
                        FROM [DataWarehouse].[dbo].[AIS_PD_Vehicle_F]
                        where [DIRECTION_OF_TRAVEL] is not null and [DIRECTION_OF_TRAVEL] != ' '
                        and [DIRECTION_OF_TRAVEL] in (2, 6)
                    ) as o
                    on n.ANUM_PCT = o.ANUM_PCT and n.ANUM_SEQ = o.ANUM_SEQ and n.ANUM_YY = o.ANUM_YY
                        and n.VEHICLE_NUMBER != o.VEHICLE_NUMBER""")
    ra = cur.fetchall()
    del cur
    return set([i[0] for i in ra])

# TODO: add right angles bases on dir of travel
class Crash:
    def __init__(self, crashid, nodeid, ac_date, inj, fat, mode, col_typ, sev, pre_actions, directions, contrib_fac):
        """
        :param crashid:
        :param nodeid:
        :param ac_date:
        :param inj:
        :param fat:
        :param mode:
        :param col_typ:
        :param sev:
        :param pre_actions:
        :param directions:
        :param contrib_fac:
        :return:
        """
        self.crashid = crashid
        self.nodeid = nodeid
        self.inj = inj
        self.fat = fat
        self.mode = mode
        self.col_typ = str(col_typ)
        self.pre_actions = pre_actions
        self.directions = directions
        self.ac_date = ac_date
        self.sev = sev
        self.contib_fac = contrib_fac
        self.right_angle()
        self.ped_bike()
        self.preventable()

    def right_angle(self):
        """
        includes: right angle (4), left turn with (0), and right turn with (5)
        :return: Boolean
        """
        if self.col_typ in ('4', '0', '5'):  # NYPD
            return True
        elif self.col_typ in ('04', '10', '05'):  # NYSDOT
            return True
        else:
            return False

    def ped_bike(self):
        if self.mode in (1, 2):
            return True
        else:
            return False

    def directions_prevent(self):
        if self.directions:
            return True
        else:
            return False

    def preventable(self):
        if self.right_angle() or self.ped_bike() or self.directions_prevent():
            if self.directions_prevent() and not self.right_angle():
                print '%s RA (%s), PB (%s), DIR(%s)' % (str(self.crashid),
                                                    str(self.right_angle()),
                                                    str(self.ped_bike()),
                                                    str(self.directions_prevent())
                                                    )
            return True
        else:
            return False


class Intersection:
    def __init__(self, masterid, nodeid_list, crashes_list):
        self.masterid = masterid
        self.nodeid_list = nodeid_list
        self.crashes = crashes_list
        self.one_year_crashes = dict()
        self.twelve_month_period()
        self.warrant()
        self.get_12_month_crashes()

    def five_or_more(self):
        count = 0
        for c in self.crashes:
            if c.preventable():
                count += 1
        if count > 4:
            return True
        else:
            return False

    def twelve_month_period(self):
        cl = [[c.crashid, c.ac_date] for c in self.crashes if c.preventable()]
        cl = sorted(cl, key=operator.itemgetter(1), reverse=True)
        while len(cl) > 1:
            if (cl[0][1] - cl[-1][1]).days / 365.0 > 1:
                cl.pop()
            else:
                break
        return cl

    def warrant(self):
        if len(self.twelve_month_period()) > 4:
            return True
        else:
            return False

    def get_12_month_crashes(self):
        crashes = dict((c[0], None) for c in self.twelve_month_period())
        for crash in self.crashes:
            if crash.crashid in crashes.keys():
                crashes[crash.crashid] = crash
        return crashes


@timeit
def add_intersection_objects_to_master_dict(mids):
    for m in mids:
        mids[m].append(Intersection(m, mids[m], list()))
        if isinstance(mids[m][-1].nodeid_list[-1], Intersection):
            mids[m][-1].nodeid_list = mids[m][-1].nodeid_list[:-1]


@timeit
def add_crashes_to_intersections(nodes, mids, crashes, drac):
    for crash in crashes:
        crashid, nodeid, ac_date, inj, fat, mode, col_typ, sev, pre_actions, directions, contrib_fac = crash
        if crashid in drac:
            directions = True
        else:
            directions = False
        if nodes[int(nodeid)]:
            master = nodes[int(nodeid)][0]
            if master in mids.keys():  # check for unsignalized
                mids[master][-1].crashes.append(Crash(crashid, nodeid, ac_date, inj, fat, mode,
                                                      col_typ, sev, pre_actions, directions, contrib_fac))
 n

@timeit
def approved_intersections(md):
    ints_w_warrant_met = dict()
    for master in md.keys():
        if md[master][-1].warrant():
            ints_w_warrant_met[master] = md[master][-1].get_12_month_crashes()
            # print master, len(md[master][-1].twelve_month_period())
    return ints_w_warrant_met


@timeit
def intersection_summaries(approved, mids, nds):
    summary = list()
    for m in approved.keys():
        crashes = len([c for c in approved[m]])
        ped_inj = sum([approved[m][c].inj for c in approved[m] if approved[m][c].mode == 1])
        bike_inj = sum([approved[m][c].inj for c in approved[m] if approved[m][c].mode == 2])
        mvo_inj = sum([approved[m][c].inj for c in approved[m] if approved[m][c].mode == 3])
        right_angles = len([approved[m][c].crashid for c in approved[m] if approved[m][c].col_typ in ('4', '04')])
        date_ranges = [min([approved[m][c].ac_date for c in approved[m]]),
                       max([approved[m][c].ac_date for c in approved[m]])]
        print 'Master %i (%s - %s):\n\tNodes %s \n\t%i crashes\n\t%i ped injuries\n\t%i bike' \
              'injuries\n\t%i mvo injuries\n\t%i right angle crashes' % (m, date_ranges[0].strftime('%m/%d/%Y'),
                                                                         date_ranges[1].strftime('%m/%d/%Y'),
                                                                         str(mids[m][-1].nodeid_list),
                                                                         crashes, ped_inj, bike_inj, mvo_inj,
                                                                         right_angles)
        if len(mids[m]) > 2:
            for node in mids[m][:-1]:
                if node in nds.keys():
                    s1, s2, x, y = nds[node]
                else:
                    s1, s2, x, y = '', '', 0, 0
                summary.append([m, node, crashes, ped_inj, bike_inj, mvo_inj, ped_inj+bike_inj+mvo_inj,
                                right_angles, date_ranges[0], date_ranges[1], s1, s2, x, y])
        else:
            if mids[m][0] in nds.keys():
                s1, s2, x, y = nds[mids[m][0]]
            else:
                s1, s2, x, y = '', '', 0, 0
            summary.append([m, mids[m][0], crashes, ped_inj, bike_inj, mvo_inj, ped_inj+bike_inj+mvo_inj,
                            right_angles, date_ranges[0], date_ranges[1], s1, s2, x, y])
    return ['MasterID', 'NodeID', 'Crashes', 'Ped_Injs', 'Bike_Injs', 'MVO_Injs', 'Total_Injs',
            'Right_Angle_Crashes', 'Earliest_Date', 'Latest_Date', 'Street1', 'Street2', 'X', 'Y'], summary


@timeit
def get_node_details(pg):
    data = dict()
    cur = pg.conn.cursor()
    cur.execute("""select  nodeid, masterid, st1, st2, st_x(geom) as x, st_y(geom) as y
                    from node n
                    join (
                        select nodeidfrom, min(st1) as st1, max(st2) as st2
                        from(
                            select s1.nodeidfrom, s1.street as st1, s2.street  as st2
                            from lion as s1 join lion as s2
                            on s1.nodeidfrom = s2.nodeidto
                            where s1.street != s2.street
                            and s1.featuretyp not in ('1', '2', '3', '7')
                            and s2.featuretyp not in ('1', '2', '3', '7')
                        ) as names_ group by nodeidfrom
                    ) as st_names on n.nodeid::int = st_names.nodeidfrom::int
                """)
    for row in cur.fetchall():
        nodeid, masterid, st1, st2, x, y = row
        data[nodeid] = [st1, st2, x, y]
    del cur
    return data


def write(out_file, data_to_write, header=[]):
    row_cnt = 0
    with open(out_file, 'wb') as csvfile:
        writer = csv.writer(csvfile, delimiter=',')
        if header:
            writer.writerow(header)
        for row in data_to_write:
            writer.writerow(row)
            row_cnt += 1
    print str(row_cnt)+" rows were written to "+str(out_file)

pgo = Dc.PGConnection('CRASHDATA', 'shostetter')  #Database Connection
dbo = Dc.DBConnection('dotgissql01', 'gisgrid', 'GISUSER', 'GISUSER') #Database Connection
# dbo = Dc.DBConnection('DOTQA55SQL01', 'LION_CURRENT', 'arcgis', 'arcgis')
# dbo2 = Dc.DBConnection('DOT55SQL01', 'DataWarehouse', 'arcgis', 'arcgis')
dbo2 = Dc.DBConnection('DOT55SQL02', 'DataWarehouse', 'SHostetter', 'shostetter') #Database Connection
node_dict = get_intersection_universe(pgo)                #gathers all nodes selecting nodeid, masterid and is_int = true
# node_dict = get_signalized_int(dbo, pgo, node_dict)
node_dict = alt_get_signalized_int(dbo, pgo, node_dict)   #Signals are mapped to latitude longitude not nodes
masters = get_unsignalized_masterids(node_dict)
# crash_list = get_all_crashes(pgo)  # NYSDOT data
crash_list = get_all_crashes_nypd(dbo2)  # NYPD data
drac = get_all_dir_right_angle_crashes_nypd(dbo2)  # NYPD data
add_intersection_objects_to_master_dict(masters) #Adding unsignalized Master IDs
add_crashes_to_intersections(node_dict, masters, crash_list, drac) #Adding Crashes to unsignalized MAster Ids
approved_masters = approved_intersections(masters)
node_data = get_node_details(pgo)
headers, crash_data = intersection_summaries(approved_masters, masters, node_data)
# write('NYPD_Signal_Summary_%s.csv' % datetime.datetime.now().strftime('%Y%m%d'), crash_data, headers)
