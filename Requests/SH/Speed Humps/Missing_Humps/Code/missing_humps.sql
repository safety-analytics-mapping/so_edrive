SELECT *
  FROM working.selected_segment_lion;


select * from working.GEOCODED_SEGMENT

select * from working.missing_humps mh
where borough like 'Brooklyn'

select * from working.missing_humps mh
where onstreet like 'OCEAN PARKWAY ' 
or  onstreet like 'OCEAN PARKWAY'

"Brooklyn"
"2017-05-08 00:00"


"2018-04-30 00:00"
"1999-10-22 00:00"

select mh.id, mh.rec_id, mh.borough, mh.onstreet, mh.crossstreetone FromStreet, mh.crossstreettwo ToStreet, mh.date_installed date_insta, 
ssl.segmentid, ssl.nodeidfrom FromNode, ssl.nodeidto ToNode,ssl.lzip L_ZipCode, ssl.l_cd, ssl.r_cd, ssl.rzip R_ZipCode,'18D' "Version", ssl.wkb_geometry 
from working.selected_segment_lion ssl 
join working.missing_humps mh
on mh.onstreet = ssl.street 
where mh.unnamed__8 like 'SELECTED FROM LION'






select id, rec_id, borough, onstreet, FromStreet, ToStreet, date_insta, 
segmentid, FromNode, ToNode, L_ZipCode, l_cd, r_cd, R_ZipCode, version, ST_SetSRID(wkb_geometry,2263) geom 
from working.GEOCODED_SEGMENT


union 


select mh.id, mh.rec_id, mh.borough, mh.onstreet, mh.crossstreetone FromStreet, mh.crossstreettwo ToStreet, mh.date_installed::date date_insta, 
ssl.segmentid::bigint, ssl.nodeidfrom::bigint FromNode, ssl.nodeidto::bigint ToNode,ssl.lzip::bigint L_ZipCode, ssl.l_cd::bigint, ssl.r_cd::bigint, ssl.rzip::bigint R_ZipCode,'18D' "Version", ST_SetSRID(ssl.wkb_geometry ,2263) geom 
from working.selected_segment_lion ssl 
join working.missing_humps mh
on mh.onstreet = ssl.street 
where mh.unnamed__8 like 'SELECTED FROM LION'






select * from  archive."17d_clion"
limit 10

select segmentid, street from archive."17d_clion"
where mft in (select distinct mft from working.lion_18d l
join working.selected_segment_lion ssl
on ssl.segmentid=l.segmentid
where mft is not null)
and rb_layer in ('G','B')


select * from working.lion_18d limit 10

select cl.segmentid, street from archive."17d_clion" cl
join (select distinct ssl.segmentid, mft from working.lion_18d l
join working.selected_segment_lion ssl
on ssl.segmentid=l.segmentid
where mft is not null) sel
on cl.mft = sel.mft
where rb_layer in ('G','B')

select * from working.lion_18d 
where mft in (select distinct mft from working.lion_18d l
join working.selected_segment_lion ssl
on ssl.segmentid=l.segmentid
where mft is not null)
and rb_layer in ('G','B')










select id, rec_id, borough, onstreet, FromStreet, ToStreet, date_insta, 
segmentid, FromNode, ToNode, L_ZipCode, l_cd, r_cd, R_ZipCode, version, ST_SetSRID(wkb_geometry,2263) geom 
from working.GEOCODED_SEGMENT



union 


select distinct mh.id, mh.rec_id, mh.borough, mh.onstreet, mh.crossstreetone FromStreet, mh.crossstreettwo ToStreet, mh.date_installed::date date_insta, 
sel.segmentid::bigint, sel.nodeidfrom::bigint FromNode, sel.nodeidto::bigint ToNode,sel.lzip::bigint L_ZipCode, sel.l_cd::bigint, sel.r_cd::bigint, sel.rzip::bigint R_ZipCode,'18D' "Version", ST_SetSRID(sel.geom ,2263) geom 
from working.missing_humps mh
join (select * from working.lion_18d 
      where mft in (select distinct mft from working.lion_18d l
      join working.selected_segment_lion ssl
      on ssl.segmentid=l.segmentid)
      and rb_layer in ('G','B')) sel
on mh.onstreet = sel.street
where mh.unnamed__8 like 'SELECTED FROM LION'
order by id










select mh.id, mh.rec_id, mh.borough, mh.onstreet, mh.crossstreetone FromStreet, mh.crossstreettwo ToStreet, mh.date_installed::date date_insta, 
gs.segmentid, gs.FromNode, gs.ToNode, gs.L_ZipCode, gs.l_cd, gs.r_cd, gs.R_ZipCode, gs.version, ST_SetSRID(gs.wkb_geometry,2263) geom 
from working.missing_humps mh
right join working.GEOCODED_SEGMENT gs
on mh.rec_id = gs.rec_id
where mh.unnamed__8 is null


union 


select distinct mh.id, mh.rec_id, mh.borough, mh.onstreet, mh.crossstreetone FromStreet, mh.crossstreettwo ToStreet, mh.date_installed::date date_insta, 
sel.segmentid::bigint, sel.nodeidfrom::bigint FromNode, sel.nodeidto::bigint ToNode,sel.lzip::bigint L_ZipCode, sel.l_cd::bigint, sel.r_cd::bigint, sel.rzip::bigint R_ZipCode,'18D' "Version", ST_SetSRID(sel.geom ,2263) geom 
from working.missing_humps mh
join (select * from working.lion_18d 
      where mft in (select distinct mft from working.lion_18d l
      join working.selected_segment_lion ssl
      on ssl.segmentid=l.segmentid)
      and rb_layer in ('G','B')) sel
on mh.onstreet = sel.street
where mh.unnamed__8 like 'SELECTED FROM LION'
order by id


