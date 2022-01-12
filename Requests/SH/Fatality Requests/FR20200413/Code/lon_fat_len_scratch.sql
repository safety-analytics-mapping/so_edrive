SELECT DISTINCT acdate --, pos
FROM archive.fatalities_current
WHERE pos = 'PD'
ORDER BY acdate--,pos

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row -- Assigning a row number for vehicle per crash
       ,acdate, pos
FROM archive.fatalities_current
WHERE pos = 'PD'
ORDER BY acdate




Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, pos
FROM archive.fatalities_current
WHERE pos = 'PD'
ORDER BY acdate,pos) x
ORDER BY acdate



WITH data AS(

SELECT DISTINCT acdate, pos
FROM archive.fatalities_current
WHERE pos = 'PD'
ORDER BY acdate,pos

)

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM data
ORDER BY acdate





WITH data AS(

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, pos
FROM archive.fatalities_current
WHERE pos = 'PD'
ORDER BY acdate,pos) x
ORDER BY acdate

)

SELECT max(date2-date1) ped_length
FROM(   SELECT d1.acdate date1, d2.acdate date2
	FROM data d1
	JOIN data d2 
	ON (d1.row+1=d2.row)
)x



WITH data AS(

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, pos
FROM archive.fatalities_current
WHERE pos = 'BI'
ORDER BY acdate,pos) x
ORDER BY acdate

)

SELECT max(date2-date1) bike_length
FROM(   SELECT d1.acdate date1, d2.acdate date2
	FROM data d1
	JOIN data d2 
	ON (d1.row+1=d2.row)
)x




WITH data AS(

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, pos
FROM archive.fatalities_current
WHERE pos = 'BI'
ORDER BY acdate,pos) x
ORDER BY acdate

)

SELECT date1, date2, max(bike_length)
FROM(   SELECT d1.acdate date1, d2.acdate date2, d2.acdate-d1.acdate bike_length  
--d1.row row1, d1.acdate date1, d2.row row2, d2.acdate date2
	FROM data d1
	JOIN data d2 
	ON (d1.row+1=d2.row)
)x
GROUP BY date1, date2
ORDER BY max desc
limit 1






WITH data AS(

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, pos
FROM archive.fatalities_current
WHERE pos = 'BI'
ORDER BY acdate,pos) x
ORDER BY acdate

)

SELECT date1, date2, max(bike_length)
FROM(   SELECT d1.acdate date1, d2.acdate date2, d2.acdate-d1.acdate bike_length  
	FROM data d1
	JOIN data d2 
	ON (d1.row+1=d2.row)
)x
GROUP BY date1, date2
ORDER BY max desc
limit 1



WITH data AS(

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, 'mvo'pos
FROM archive.fatalities_current
WHERE pos in ('DR', 'PS', 'MO')
ORDER BY acdate,pos) x
ORDER BY acdate

)

SELECT date1, date2, max(mvo_length)
FROM(   SELECT d1.acdate date1, d2.acdate date2, d2.acdate-d1.acdate mvo_length  
	FROM data d1
	JOIN data d2 
	ON (d1.row+1=d2.row)
)x
GROUP BY date1, date2
ORDER BY max desc
limit 1





--Longest length between fatalites------------------------------------------------------- 




WITH ped_data AS(

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, pos
FROM archive.fatalities_current
WHERE pos = 'PD'
ORDER BY acdate,pos) x
ORDER BY acdate

)

,bike_data AS(

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, pos 
FROM archive.fatalities_current
WHERE pos = 'BI'
ORDER BY acdate,pos) x
ORDER BY acdate

)

,mvo_data AS(

Select DISTINCT row_number() OVER (PARTITION BY pos ORDER BY acdate) as row, acdate 
FROM(
SELECT DISTINCT acdate, 'mvo'pos
FROM archive.fatalities_current
WHERE pos in ('DR', 'PS', 'MO')
ORDER BY acdate,pos) x
ORDER BY acdate

)

SELECT * FROM (
SELECT 'ped' as mode, date1, date2, max(ped_length) len
FROM(   SELECT d1.acdate date1, d2.acdate date2, d2.acdate-d1.acdate ped_length  
--d1.row row1, d1.acdate date1, d2.row row2, d2.acdate date2
	FROM ped_data d1
	JOIN ped_data d2 
	ON (d1.row+1=d2.row)
)x
GROUP BY mode,date1, date2
ORDER BY len desc
limit 1
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
limit 1
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
limit 1)
mvo