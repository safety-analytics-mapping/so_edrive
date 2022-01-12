


SELECT distinct * FROM(




WITH data AS(
SELECT sp.pid, spg.segmentid, cl.mft, masteridfr, masteridto
FROM public.sip_projects sp
JOIN public.sip_projects_geo spg
on sp.pid=spg.pid_fk
JOIN clion cl
on spg.segmentid = cl.segmentid::int
WHERE sp.pid in (1407, 1429)
)

SELECT DISTINCT nodeid 
FROM clion_node 
WHERE masterid in(SELECT DISTINCT masteridfr masterid
		FROM data

		UNION

		SELECT DISTINCT masteridto masterid
		FROM data)
AND featuretyp in ('0', '6', 'C') 




WITH data AS(
SELECT sp.pid, spg.segmentid, cl.mft, masteridfr, masteridto
FROM public.sip_projects sp
JOIN public.sip_projects_geo spg
on sp.pid=spg.pid_fk
JOIN clion cl
on spg.segmentid = cl.segmentid::int
WHERE sp.pid in (1407, 1429)
)

SELECT DISTINCT masteridfr masterid
FROM data

UNION

SELECT DISTINCT masteridto masterid
FROM data




                



