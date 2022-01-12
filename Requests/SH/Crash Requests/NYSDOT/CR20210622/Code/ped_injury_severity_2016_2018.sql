


-- 1. a table of the number of mid-block ped injuries and severe injuries per year (2016-2018)

SELECT case_yr, sum(num_of_inj) injuries, sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) severeity FROM(
SELECT DISTINCT crashid, case_yr, num_of_inj, ext_of_inj
FROM nysdot_all nys_a
WHERE nys_a.accd_type_int= 1
and case_yr between 2016 and 2018
and LOC = 'MID'
) x
GROUP BY case_yr



-- 2. a table of ped crossing against the signal injuries and severe injuries per year (2016-2018)


SELECT case_yr, sum(num_of_inj) crossing_injuries, sum(length(ext_of_inj::text) - length(replace(ext_of_inj::text, 'A'::text, ''::text))) severeity FROM(
SELECT DISTINCT crashid, case_yr, num_of_inj, ext_of_inj
FROM nysdot_all nys_a
WHERE nys_a.accd_type_int= 1
and case_yr between 2016 and 2018
and ped_actn = '02'
) x
GROUP BY case_yr