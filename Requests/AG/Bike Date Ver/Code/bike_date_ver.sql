select n.instdate new_instdate, n.segmentid::int new_segmentid,
o.instdate old_instdate,  n.geom from working.proximity_bike_facility n
join working.proximity_bike_facility2 o 
on n.segmentid::int = o.segmentid::int
where n.instdate != o.instdate
and extract(year from o.instdate) < 2017
and extract(year from n.instdate) < 2017
and extract(year from o.moddate) < 2017
and n.segmentid != '0' 
order by n.segmentid::int
