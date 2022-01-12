SELECT coalesce(core.nodeid, core.lion_node_number) NODEID
	  ,core.SRC_CROSS_STREET
      ,core.SRC_ON_STREET
	  ,core.ACCIDENT_DT 
	  ,left(stuff(STUFF(right('000000'+cast(core.ACCIDENT_TIME_WID AS VARCHAR),6),5,0,':'),3,0,':'), 5) ACCIDENT_TIME
	  ,core.INJURED_CNT
	  ,core.TRAFFIC_CONTROL
	  ,vic.PED_ACTION
	  ,PRE_ACDNT_ACTION
FROM [FORMS].[dbo].[WC_ACCIDENT_F] core
JOIN (SELECT DISTINCT ACCIDENT_ID,PRE_ACDNT_ACTION
      FROM FORMS.dbo.WC_ACCIDENT_VEHICLE_F) veh 
ON core.integration_id = veh.accident_id
JOIN (SELECT DISTINCT ACCIDENT_ID, PED_ACTION
	  FROM [FORMS].[dbo].[WC_ACCIDENT_VICTIM_F]) vic
ON core.integration_id = vic.accident_id
WHERE YEAR(core.ACCIDENT_DT)>2017
AND coalesce(core.VOID_STATUS_CD , 'N') ='N'
