 create table archive.stg_signal_controller as select * from  staging.archive_stg_signal_controller

 Drop table if exists archive.stg_signal_controller



SELECT * FROM pg_stat_activity where usename = 'soge'


SELECT pg_terminate_backend(25435);
SELECT pg_terminate_backend(26306);
SELECT pg_terminate_backend(13018);
SELECT pg_terminate_backend(20678);
SELECT pg_terminate_backend(15329);
SELECT pg_terminate_backend(15349);
SELECT pg_terminate_backend(15352);
SELECT pg_terminate_backend(18395);
SELECT pg_terminate_backend(24331);
SELECT pg_terminate_backend(16144);
SELECT pg_terminate_backend(25479);
SELECT pg_terminate_backend(26011);
