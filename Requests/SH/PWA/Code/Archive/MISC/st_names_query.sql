select nodeid::int, array_agg(street) from(
select distinct nodeidto nodeid, street
from lion 
where nodeidto::int in (9043971)

union

select distinct nodeidfrom nodeid, street
from lion 
where nodeidfrom::int in (9043971)
) st_names
group by nodeid