
select distinct segmentid from (
SELECT distinct sh.ogc_fid, sh.street_1, sh.street_2, sh.street_3, sh.borough, sh.noofhumps, sh.nearschoo, 
       dateinsta, datereins, orderno, sh.segmentid, manualadd, wkb_geometry, lion.mft 
FROM working."installations_2018tojan2020.shp" sh
JOIN archive."18d.2019-11-13_lion" lion
on sh.segmentid = lion.segmentid
order by sh.segmentid
) x



