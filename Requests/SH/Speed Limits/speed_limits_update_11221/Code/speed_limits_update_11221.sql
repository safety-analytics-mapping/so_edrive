-- BACK UP SPEED LIMITS FILE
-- CREATE A TABLE WITH SPEED LIMITS DATA AND TODAY'S DATE
-- i.e Archive Copy


CREATE TABLE archive_speed_limit_19d_11221 AS

SELECT * FROM speed_limit_19d;

GRANT ALL ON archive_speed_limit_19d_11221 TO PUBLIC;



SELECT * FROM archive_speed_limit_19d_11221;


INSERT into speed_limit_19d




SELECT * FROM speed_limit_19d limit 1



INSERT INTO speed_limit_19d(segmentid, street, postvz_sl, postvz_sg, prevz_sl, prevz_sg, version, geom)
SELECT segmentid::int , street, 0 postvz_sl, 'NO'::varchar postvz_sg, 0 prevz_sl, 'NO'::varchar _prevz_sg, '19d' "version", geom
FROM LION
WHERE segmentid ::int IN  ('0312733', '0312802', '0312769')




SELECT segmentid::int FROM LION 
WHERE 
--1. Meeker Ave / Cherry St - Metropolitan Ave to Stewart Ave - BK - signed for 25
segmentid ::int IN  ('0312733', '0312802', '0312769')

OR

--2. Williamsburg St E/W - Marcy Ave to Grand Ave - BK - unsigned (25MPH default)
segmentid ::int IN  ('0030494','0030546','0163949','0163948','0163961','0030710','0030704','0030514','0030521',
		     '0163962','0030734','0030542','0030730','0030727','0030494','0030546','0163949','0163948',
		     '0163961','0030710','0030704','0030514','0030521','0163962','0030734','0030542','0030730',
		     '0030727','163958', '30737', '30708', '290694', '30680', '30712', '290693', '30675', '30684')

OR

--3. Park Ave N/S - Grand to Navy - BK - signed for 25
"segmentid"::int IN ('122059', '30089', '256877', '30314', '256878', '30099', '30310', '30310', '234112', '9008308', 
		     '234111', '30097', '30319', '9008307', '30091', '136115', '30197', '30304', '30187', '29945', 
		     '30302', '30199', '30082', '30321', '29940', '29949', '30103', '30191', '30105', '30195', '24646', 
		     '248653', '24646', '248654', '215350', '215351', '30203', '30312', '122058', '24650', '24650')

OR

--4. 7th Ave / 8th Ave - Erik Pl - 79th St (was signed for 25mph as part of a School Safety project in 2018 or 2019)
segmentid ::int IN ('17376', '17368', '126862', '126861', '105730', '105729', '161143', '161142', '17404', '17351', 
		    '17399', '17353', '17405', '261390', '17276', '17367')

OR

--5. Various parts of Shore Road/Belt Parkway Service Rd -signed for 25mph as part of last year's speed reductions - see image below
segmentid ::int IN ('25571', '194348', '25582', '118124', '163285', '40177', '194323', '25732', '252472', '252473', 
		    '190722', '190723', '141956', '141955')





DROP TABLE IF EXISTS segmentid_check_speed_limit_19d;
CREATE TABLE segmentid_check_speed_limit_19d AS
SELECT * FROM speed_limit_19d
WHERE 
--1. Meeker Ave / Cherry St - Metropolitan Ave to Stewart Ave - BK - signed for 25
segmentid ::int IN  ('144186', '165251', '165252', '165257', '165258', '172164', '172165', '257728', 
		     '257729', '31128', '31130', '31135', '31137', '31143', '31145', '31152', '312695', 
		     '35235', '35237', '35420', '35431', '35432', '35434', '35438', '35443', '35456', 
		     '35459', '35464', '35588', '35597', '35603', '35617', '35619', '35625', '65835', 
		     '65863', '65871', '65874', '65878', '65880', '65890', '65892', '66000', '66006', 
		     '66012','312732','0312733', '0312802', '0312769','0312733', '0312802', '0312769')

OR

--2. Williamsburg St E/W - Marcy Ave to Grand Ave - BK - unsigned (25MPH default)
segmentid ::int IN  ('0030546','0163949','0163948','0163961','0030710','0030704','0030514','0030521',
		     '0163962','0030734','0030542','0030730','0030727','0030546','0163949','0163948',
		     '0163961','0030710','0030704','0030514','0030521','0163962','0030734','0030542','0030730',
		     '0030727', '30737', '30708', '290694', '30680', '30712', '290693', '30675', '30684')

OR

--3. Park Ave N/S - Grand to Navy - BK - signed for 25
"segmentid"::int IN ('122059', '30089', '256877', '30314', '256878', '30099', '30310', '30310', '234112', '9008308', 
		     '234111', '30097', '30319', '9008307', '30091', '136115', '30197', '30304', '30187', '29945', 
		     '30302', '30199', '30082', '30321', '29940', '29949', '30103', '30191', '30105', '30195', '24646', 
		     '248653', '24646', '248654', '215350', '215351', '30203', '30312', '122058', '24650', '24650')

OR

--4. 7th Ave / 8th Ave - Erik Pl - 79th St (was signed for 25mph as part of a School Safety project in 2018 or 2019)
segmentid ::int IN ('17376', '17368', '126862', '126861', '105730', '105729', '161143', '161142', '17404', '17351', 
		    '17399', '17353', '17405', '261390', '17276', '17367','17343','17344', '17357', '17372', '17381',
		    '17387', '17408', '17410', '17414',  '261396')

OR

--5. Various parts of Shore Road/Belt Parkway Service Rd -signed for 25mph as part of last year's speed reductions - see image below
segmentid ::int IN ('25571', '194348', '25582', '118124', '163285', '40177', '194323', '25732', '252472', '252473', 
		    '190722', '190723', '141956', '141955');


GRANT ALL ON segmentid_check_speed_limit_19d TO PUBLIC;
