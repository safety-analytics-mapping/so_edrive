SELECT sh.segmentid, ft_facilit, tf_facilit, 
       case when ((streetwidt - (8*(number_par::int)))/number_tra::int)>=13 then 'moving lane >= 13' else 'moving lane < 13' end st_width, sh.geom 
FROM "2019_05_03_bike_network_18d" sh
join c_lion_18d cl
on sh.segmentid::int = cl.segmentid::int
where ft_facilit = 'Sharrows'
or tf_facilit = 'Sharrows'




select segmentid, streetwidt, (8*(number_par::int)), number_tra, geom
from c_lion_18d
limit 10  



select * FROM pg_stat_activity where usename = 'soge'



SELECT pg_terminate_backend(3576);
SELECT pg_terminate_backend(4233);
SELECT pg_terminate_backend(28299);
SELECT pg_terminate_backend(4033);
SELECT pg_terminate_backend(29743);
SELECT pg_terminate_backend(16447);
