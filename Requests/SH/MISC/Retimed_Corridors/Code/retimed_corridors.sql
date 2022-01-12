SELECT DISTINCT rc.segmentid rc_seg, l.segmentid l_seg, rc.rb_layer rcrc, l.rb_layer lrb
FROM working.retimed_corridors rc
LEFT JOIN lion l
ON rc.segmentid = l.segmentid
--WHERE l.segmentid is null

SELECT * --DISTINCT segmentid, rb_layer, shape_leng
FROM working.retimed_corridors rc



SELECT DISTINCT rc.segmentid rc_seg, l.segmentid l_seg
               ,rc.rb_layer rcrc, l.rb_layer lrb
               ,left(rc.shape_leng::varchar,7) rcsl, left(l.shape_length::varchar,7) lsl
               ,l.mft
FROM working.retimed_corridors rc
LEFT JOIN lion l
ON rc.segmentid = l.segmentid
WHERE l.segmentid is not null





DROP TABLE IF EXISTS working.retimed_corridors_19d;
CREATE TABLE working.retimed_corridors_19d AS

WITH data AS(

SELECT DISTINCT l.mft
FROM working.retimed_corridors rc
LEFT JOIN lion l
ON rc.segmentid = l.segmentid
WHERE l.mft is not null

UNION 

SELECT mft FROM lion 
WHERE segmentid::int in (152322,320296,320286,152321
                         ,0000059,0000139)

)

SELECT  * 
FROM lion 
WHERE mft in (SELECT * FROM data)
AND rb_layer in ('G','B');

GRANT ALL ON working.retimed_corridors_19d TO PUBLIC;


SELECT * FROM working.retimed_corridors_19d



DROP TABLE IF EXISTS working.retimed_corridors_2021_02_16_19d;
CREATE TABLE working.retimed_corridors_2021_02_16_19d AS

WITH DATA AS(
SELECT DISTINCT l.mft
FROM working.retimed_corridors rc
LEFT JOIN lion l
ON rc.segmentid = l.segmentid
WHERE l.mft is not null
and rc.rb_layer != 'B'

UNION 

SELECT mft FROM lion 
WHERE segmentid::int in (152322,320296,320286,152321
                         ,0000059,0000139)
)

SELECT * 
FROM lion 
WHERE mft in (SELECT * FROM data)
AND rb_layer in ('G','B')

UNION

SELECT l.*
FROM working.retimed_corridors rc
LEFT JOIN lion l
ON rc.segmentid = l.segmentid
WHERE l.mft is not null
and rc.rb_layer = 'B';

GRANT ALL ON working.retimed_corridors_2021_02_16_19d TO PUBLIC;
