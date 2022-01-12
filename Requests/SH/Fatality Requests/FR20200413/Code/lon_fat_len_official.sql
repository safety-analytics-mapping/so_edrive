
--Longest length between fatalites------------------------------------------------------- 


WITH ped_data AS(

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, pos
FROM fatality_nycdot_current
WHERE pos = 'PD' and date_part('year',acdate)>1989
ORDER BY acdate,pos) x
ORDER BY acdate
)

,bike_data AS(

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, pos 
FROM fatality_nycdot_current
WHERE pos = 'BI' and date_part('year',acdate)>1989
ORDER BY acdate,pos) x
ORDER BY acdate
)

,mvo_data AS(

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, 'mvo'pos
FROM fatality_nycdot_current
WHERE pos in ('DR', 'PS', 'MO') and date_part('year',acdate)>1989
ORDER BY acdate,pos) x
ORDER BY acdate
)

SELECT * FROM (
SELECT 'ped' as mode, date1, date2, max(ped_length) len
FROM(   SELECT d1.acdate date1, d2.acdate date2, d2.acdate-d1.acdate ped_length  
	FROM ped_data d1
	JOIN ped_data d2 
	ON (d1.row+1=d2.row)
)x
GROUP BY mode,date1, date2
ORDER BY len desc
limit 3
)ped

UNION ALL

SELECT * FROM(
SELECT 'bike' as mode, date1, date2, max(bike_length) len
FROM(   SELECT d1.acdate date1, d2.acdate date2, d2.acdate-d1.acdate bike_length  
	FROM bike_data d1
	JOIN bike_data d2 
	ON (d1.row+1=d2.row)
)x
GROUP BY mode, date1, date2
ORDER BY len desc
limit 3
)bike

UNION ALL

SELECT * FROM(
SELECT 'mvo' as mode, date1, date2, max(mvo_length) len
FROM(   SELECT d1.acdate date1, d2.acdate date2, d2.acdate-d1.acdate mvo_length  
	FROM mvo_data d1
	JOIN mvo_data d2 
	ON (d1.row+1=d2.row)
)x
GROUP BY mode, date1, date2
ORDER BY len desc
limit 3)
mvo