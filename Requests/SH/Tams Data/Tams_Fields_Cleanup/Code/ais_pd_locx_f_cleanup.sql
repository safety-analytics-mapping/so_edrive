
update public.ais_pd_locx_f
set
street1 = cleaned_up.street1
,street2 = cleaned_up.street2

FROM(SELECT replace(street1,'  ',' ') street1, replace(street2,'  ',' ') street2
     FROM(SELECT replace(street1,'  ',' ') street1, replace(street2,'  ',' ') street2
          FROM (SELECT replace(street1,'  ',' ') street1, replace(street2,'  ',' ') street2
                FROM(SELECT replace(street1,'  ',' ') street1, replace(street2,'  ',' ') street2
                     FROM public.ais_pd_locx_f
                     WHERE street1 not like '% %'
                     AND street2 not like '% %' ) fix1) fix2) fix3) cleaned_up
           


CREATE TABLE working.ais_pd_locx_f_test AS
SELECT * FROM public.ais_pd_locx_f




update working.ais_pd_locx_f_test
set
street1 = cleaned_up.street1
,street2 = cleaned_up.street2

FROM(SELECT replace(street1,'  ',' ') street1, replace(street2,'  ',' ') street2
     FROM(SELECT replace(street1,'  ',' ') street1, replace(street2,'  ',' ') street2
          FROM (SELECT replace(street1,'  ',' ') street1, replace(street2,'  ',' ') street2
                FROM(SELECT replace(street1,'  ',' ') street1, replace(street2,'  ',' ') street2
                     FROM working.ais_pd_locx_f_test
                     WHERE street1 not like '% %'
                     AND street2 not like '% %' ) fix1) fix2) fix3) cleaned_up



update working.ais_pd_locx_f_test
set
street1 = cleaned_up.street1
,street2 = cleaned_up.street2

FROM(SELECT replace((replace((replace(street1,'  ',' ')),'  ',' ')),'  ', ' ') street1, replace((replace((replace(street2,'  ',' ')),'  ',' ')),'  ', ' ') street2
     FROM working.ais_pd_locx_f_test
     WHERE street1 not like '% %'
     AND street2 not like '% %' ) cleaned_up




WITH data AS(
SELECT replace((replace((replace(street1,'  ',' ')),'  ',' ')),'  ', ' ') street1, replace((replace((replace(street2,'  ',' ')),'  ',' ')),'  ', ' ') street2
FROM working.ais_pd_locx_f_test             
                     )

SELECT * FROM data




update working.ais_pd_locx_f_test
set
street1 = cleaned_up.street1
,street2 = cleaned_up.street2

FROM( SELECT trim(regexp_replace(street1, '\s+', ' ', 'g')) street1, trim(regexp_replace(street2, '\s+', ' ', 'g')) street2
      FROM working.ais_pd_locx_f_test 
      WHERE trim(street1) like '%  %'
      OR trim(street2) like '%  %')  cleaned_up



CREATE TEMP TABLE ais_pd_locx_f_test_update AS 

SELECT trim(regexp_replace(street1, '\s+', ' ', 'g')) street1, trim(regexp_replace(street2, '\s+', ' ', 'g')) street2
FROM working.ais_pd_locx_f_test 
WHERE trim(street1) like '%  %'
OR trim(street2) like '%  %'

update working.ais_pd_locx_f_test
set
street1 = cleaned_up.street1
,street2 = cleaned_up.street2

FROM(SELECT * FROM ais_pd_locx_f_test_update) cleaned_up