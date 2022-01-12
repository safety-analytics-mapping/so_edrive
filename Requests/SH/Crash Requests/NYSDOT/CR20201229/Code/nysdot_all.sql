
SELECT distinct nys_a.crashid, nys_a.*
FROM public.nysdot_all nys_a
WHERE nys_a.case_yr>= 2016 and nys_a.case_yr<=2018



SELECT distinct nys_v.crashid, nys_v.*
FROM public.nysdot_vehicle nys_v
WHERE nys_a.case_yr>= 2016 and nys_a.case_yr<=2018


SELECT distinct nys_v.crashid, pre_accd_actn
FROM public.nysdot_vehicle  nys_v
WHERE case_yr BETWEEN 2016 and 2018





--Crashes
SELECT distinct nys_a.case_num
               ,nys_a.case_yr
               ,nys_a.ref_mrkr
               ,nys_a.accd_dte
               ,nys_a.road_sys
               ,nys_a.num_of_fat
               ,nys_a.num_of_inj
               ,nys_a.reportable
               ,nys_a.police_dep 
               ,nys_a.intersect_
               ,nys_a.muni
               ,nys_a.precinct
               ,nys_a.num_of_veh
               ,nys_a.accd_typ
               ,nys_a.locn
               ,nys_a.traf_cntl
               ,nys_a.light_cond
               ,nys_a.weather
               ,nys_a.road_char
               ,nys_a.road_surf_
               ,nys_a.collision_
               ,nys_a.ped_loc
               ,nys_a.ped_actn
               ,nys_a.ext_of_inj
               ,nys_a.regn_cnty_
               ,nys_a.accd_tme
               ,nys_a.rpt_agcy
               ,nys_a.dmv_accd_c
               ,nys_a.err_cde
               ,nys_a.comm_veh_a
               ,nys_a.highway_in
               ,nys_a.intersect1
               ,nys_a.utm_northi
               ,nys_a.utm_eastin
               ,nys_a.geo_segmen
               ,nys_a.geo_node_i
               ,nys_a.geo_node_d
               ,nys_a.geo_node_1               
FROM public.nysdot_all nys_a
WHERE nys_a.case_yr>= 2016 and nys_a.case_yr<=2018





--Vehicle
SELECT distinct nys_v.case_num
	       ,nys_v.case_yr
	       ,nys_v.veh_seq_num
	       ,nys_v.rgst_typ
	       ,nys_v.body_typ
	       ,nys_v.veh_typ
	       ,nys_v.pre_accd_actn
	       ,nys_v.second_event
	       ,nys_v.veh_dirn_of_trav
	       ,nys_v.haz_cargo_ind
	       ,nys_v.tck_bus_clsf
	       ,nys_v.pbl_prpt_ind
	       ,nys_v.comm_veh_ind
	       ,nys_v.age
	       ,nys_v.sex
	       ,nys_v.occupant_num
	       ,nys_v.rgst_wgt
	       ,nys_v.cit_ind
	       ,nys_v.drvr_lic_st
	       ,nys_v.veh_lic_st
	       ,nys_v.tow_ind
FROM public.nysdot_vehicle nys_v
WHERE nys_v.case_yr>= 2016 and nys_v.case_yr<=2018



SELECT distinct nys_app.case_num
               ,nys_app.case_yr
               ,nys_app.veh_seq_num
               ,nys_app.aprnt_seq_num
               ,nys_app.aprnt_fctr
FROM public.nysdot_appfactor nys_app
WHERE nys_app.case_yr>= 2016 and nys_app.case_yr<=2018


