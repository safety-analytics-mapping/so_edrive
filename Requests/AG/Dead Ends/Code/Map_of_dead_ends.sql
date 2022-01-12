select tot.nodeid, n2.geom from (
	select coalesce(nodeidto, nodeidfrom) nodeid from ( 
		select distinct l.nodeidfrom --nodeidfrom table
		from lion l
		join node n on
		n.nodeid = l.nodeidfrom::int
		where l.rb_layer in ('R', 'B', 'N') and l.featuretyp not in ('1', '2', '3', '7', 'A', 'F')
		and n.vintersect is null
		) f
		full join
		(
		select distinct l.nodeidto --nodeidto table
		from lion l
		join node n on
		n.nodeid = l.nodeidto::int
		where l.rb_layer in ('R', 'B', 'N') and l.featuretyp not in ('1', '2', '3', '7', 'A', 'F')
		and n.vintersect is null
		) t 
	on f.nodeidfrom=t.nodeidto
	where f.nodeidfrom is null or t.nodeidto is null) tot
join node n2
on tot.nodeid::int=n2.nodeid

