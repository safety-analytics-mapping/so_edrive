-- Full Years------------------------------------------------------------------------------
SELECT DISTINCT core.COMMUNITY_DISTRICT,     
		sum(coalesce(CASE WHEN YEAR(core.ACCIDENT_DT) = 2017 THEN 1 END, 0)) "2017",
		sum(coalesce(CASE WHEN YEAR(core.ACCIDENT_DT) = 2018 THEN 1 END, 0)) "2018",
		sum(coalesce(CASE WHEN YEAR(core.ACCIDENT_DT) = 2019 THEN 1 END, 0)) "2019",
		sum(coalesce(CASE WHEN YEAR(core.ACCIDENT_DT) = 2020 THEN 1 END, 0)) "2020"
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
JOIN [FORMS].[dbo].[WC_ACCIDENT_VICTIM_F] vic
ON core.INTEGRATION_ID = vic.ACCIDENT_ID
WHERE PERSON_ROLE_CODE = 'Pedestrian'
AND inj_killed = 'Injured'
AND YEAR(core.ACCIDENT_DT) between 2017 and 2020
AND core.BOROUGH = 'BRONX'
GROUP BY core.COMMUNITY_DISTRICT



-- Jan-7/31 ------------------------------------------------------------------------------
SELECT DISTINCT core.COMMUNITY_DISTRICT,     
		sum(coalesce(CASE WHEN YEAR(core.ACCIDENT_DT) = 2017 THEN 1 END, 0)) "2017",
		sum(coalesce(CASE WHEN YEAR(core.ACCIDENT_DT) = 2018 THEN 1 END, 0)) "2018",
		sum(coalesce(CASE WHEN YEAR(core.ACCIDENT_DT) = 2019 THEN 1 END, 0)) "2019",
		sum(coalesce(CASE WHEN YEAR(core.ACCIDENT_DT) = 2020 THEN 1 END, 0)) "2020"
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
JOIN [FORMS].[dbo].[WC_ACCIDENT_VICTIM_F] vic
ON core.INTEGRATION_ID = vic.ACCIDENT_ID
WHERE PERSON_ROLE_CODE = 'Pedestrian'
AND inj_killed = 'Injured'
AND YEAR(core.ACCIDENT_DT) between 2017 and 2020
AND MONTH(core.ACCIDENT_DT) < 8
AND core.BOROUGH = 'BRONX'
GROUP BY core.COMMUNITY_DISTRICT



