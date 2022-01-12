/*SELECT  

ASCII(DAY([Issue Date])) + 
ASCII(MONTH([Issue Date]))+
ASCII(right(year([Issue Date]),1))+
ASCII(left([Plate ID],1)),*

  

FROM [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_]
WHERE [Issue Date]= '06/14/2018'

SELECT  TOP 2 *
  
FROM [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_]
WHERE [Plate ID] = 'FTY7997'


SELECT  TOP 2 

ASCII(DAY([Issue Date])) + 
ASCII(MONTH([Issue Date]))+
ASCII(right(year([Issue Date]),1))+
ASCII(left([Plate ID],1)), *
FROM [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_]
WHERE [Plate ID] = 'BZS6697'


SELECT  TOP 2 *
  
FROM [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_]
WHERE [Plate ID] = 'BZS6697'
*/

--[_dof_violations_data_2019-03-29_] 
SELECT  

CONCAT(
Case
	When Isnumeric(left([Plate ID],1)) = 0 Then ASCII(left([Plate ID],1)) --Checks if first character in license plate is numeric 
	Else left([Plate ID],1) * 12  --Takes licenses that start numerically and multiplies with 12
End + DATEPART(dy, [Issue Date])*2, ' - ', --Adds day of year to numeric conversion of license plate to get new sequential id number
right(year([Issue Date]),2)) AS [NEW ID],* -- concatenates new id number with year to express heiarchy
From [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_] 



--[_AIS_PD_Vehicle_F]
SELECT  TOP 100 
CONCAT(
Case
	When Isnumeric(left(PLATE_NUMBER,1)) = 0 Then ASCII(left(PLATE_NUMBER,1)) --Checks if first character in license plate is numeric 	
	Else cast(left(PLATE_NUMBER,1) as int) *  12  --Takes licenses that start numerically and multiplies with 12
End + DATEPART(dy, CREATEDON)*2, ' - ', --Adds day of year to numeric conversion of license plate to get new sequential id number
right(year(CREATEDON),2)) AS [NEW ID],* -- concatenates new id number with year to express heiarchy
From [RISCRASHDATA].[dbo].[_AIS_PD_Vehicle_F]


select Top 100 * 
From [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_]


Select Ascii('.') as A

SELECT TOP 1 [Plate ID],* 
From RISCRASHDATA.dbo.[_dof_violations_data_2019-03-29_]
Where left([Plate ID],1) = '''\\\'''

select distinct left([Plate ID], 1) from RISCRASHDATA.dbo.[_dof_violations_data_2019-03-29_]


SELECT  

Case
	When Isnumeric(left(PLATE_NUMBER,1)) = 0 Then ASCII(left(PLATE_NUMBER,1)) --Checks if first character in license plate is numeric 	
	Else cast(left(PLATE_NUMBER,1) as int) *  12 
select top 1 Isnumeric(left('%',1)) from RISCRASHDATA.dbo.[_dof_violations_data_2019-03-29_]


case when condition1 = x then x1
when condition2 = y then y1
when condition  
else
 
Select top 1 *
from RISCRASHDATA.dbo.[_dof_violations_data_2019-03-29_]
Where left([Plate ID],1) in  ('^[,$[;/~! ]=:`#@.&]')
 
--'%[^,$[;/~! ]'=:`#@.&]'



SELECT  

CONCAT(
Case
	When Isnumeric(left([Plate ID],1)) = 1 Then left([Plate ID],1) * 12  --Checks if first character in license plate is numeric 
	Else ASCII(left([Plate ID],1))  --Takes licenses that start numerically and multiplies with 12
End + DATEPART(dy, [Issue Date])*2, ' - ', --Adds day of year to numeric conversion of license plate to get new sequential id number
right(year([Issue Date]),2)) AS [NEW ID],* -- concatenates new id number with year to express heiarchy
From [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_] 


SELECT  

CONCAT(

IF (left([Plate ID],1) in (0,1,2,3,4,5,6,7,8,9)) Then left([Plate ID],1) * 12  --Checks if first character in license plate is numeric 
Else ASCII(left([Plate ID],1))  --Takes licenses that start numerically and multiplies with 12
 + DATEPART(dy, [Issue Date])*2, ' - ', --Adds day of year to numeric conversion of license plate to get new sequential id number
right(year([Issue Date]),2)) AS [NEW ID],* -- concatenates new id number with year to express heiarchy
From [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_] 

DECLARE @teststring nvarchar(max)
SET @teststring = 'Test''Me'
SELECT 'IS ALPHANUMERIC: ' + @teststring
WHERE @teststring NOT LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' {ESCAPE '\'}



SELECT  
CONCAT(
Case
	When Isnumeric(left[PLATE ID],1)) = 0 Then ASCII(left([PLATE ID],1)) --Checks if first character in license plate is numeric 	
	Else cast(left([PLATE ID],1) as int) *  12  --Takes licenses that start numerically and multiplies with 12
End + DATEPART(dy, [ISSUE DATE])*2, ' - ', --Adds day of year to numeric conversion of license plate to get new sequential id number
right(year([iSSUE DATE]),2)) AS [NEW ID],* -- concatenates new id number with year to express heiarchy
From [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_] 
WHERE left([PLATE ID],1) NOT LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' {ESCAPE '\'}



SELECT  

CONCAT(
Case
	When Isnumeric(left([Plate ID],1)) = 0 Then ASCII(left([Plate ID],1)) --Checks if first character in license plate is numeric 
	Else left([Plate ID],1) * 12  --Takes licenses that start numerically and multiplies with 12
End + DATEPART(dy, [Issue Date])*2, ' - ', --Adds day of year to numeric conversion of license plate to get new sequential id number
right(year([Issue Date]),2)) AS [NEW ID],* -- concatenates new id number with year to express heiarchy
From [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_] 
WHERE left([PLATE ID],1) NOT LIKE '%[-!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' {ESCAPE '\'}


--[_dof_violations_data_2019-03-29_] 18 MIN RUNTIME

SELECT  

CONCAT(
Case
	When Isnumeric(left([Plate ID],1)) = 0 Then ASCII(left([Plate ID],1)) --Checks if first character in license plate is numeric 
	Else left([Plate ID],1) * 12  --Takes licenses that start numerically and multiplies with 12
End + DATEPART(dy, [Issue Date])*2, ' - ', --Adds day of year to numeric conversion of license plate to get new sequential id number
right(year([Issue Date]),2)) AS [NEW ID],* -- concatenates new id number with year to express heiarchy
From [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_] 
WHERE left([PLATE ID],1) NOT LIKE '%[-$!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' {ESCAPE '\'}


--[_dof_violations_data_2019-03-29_] SPECIAL CHARS 49 SEC RUNTIME

SELECT  

CONCAT(
ASCII(left([Plate ID],1)) +
DATEPART(dy, [Issue Date])*2, ' - ', --Adds day of year to numeric conversion of license plate to get new sequential id number
right(year([Issue Date]),2)) AS [NEW ID],*
From [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_] 
WHERE left([PLATE ID],1) LIKE '%[-$!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' {ESCAPE '\'}

----------------------------------------------------------------------------------------------------------------------------------------
--[_dof_violations_data_2019-03-29_] SPECIAL CHARS 17:30 MIN RUNTIME

SELECT  

CONCAT(
Case
	WHEN left([PLATE ID],1) LIKE '%[-$!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' {ESCAPE '\'} Then ASCII(left([Plate ID],1))
	When Isnumeric(left([Plate ID],1)) = 0 Then ASCII(left([Plate ID],1)) --Checks if first character in license plate is numeric 
	Else left([Plate ID],1) * 12  --Takes licenses that start numerically and multiplies with 12
End + DATEPART(dy, [Issue Date])*2, ' - ', --Adds day of year to numeric conversion of license plate to get new sequential id number
right(year([Issue Date]),2)) AS [NEW ID],* -- concatenates new id number with year to express heiarchy
From [RISCRASHDATA].[dbo].[_dof_violations_data_2019-03-29_] 
---------------------------------------------------------------------------------------------------------------------------------------

--[_AIS_PD_Vehicle_F]
SELECT  TOP 100 
CONCAT(
Case
	When Isnumeric(left(PLATE_NUMBER,1)) = 0 Then ASCII(left(PLATE_NUMBER,1)) --Checks if first character in license plate is numeric 	
	Else cast(left(PLATE_NUMBER,1) as int) *  12  --Takes licenses that start numerically and multiplies with 12
End + DATEPART(dy, CREATEDON)*2, ' - ', --Adds day of year to numeric conversion of license plate to get new sequential id number
right(year(CREATEDON),2)) AS [NEW ID],* -- concatenates new id number with year to express heiarchy
From [RISCRASHDATA].[dbo].[_AIS_PD_Vehicle_F]
WHERE left(PLATE_NUMBER,1) NOT LIKE '%[-$!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' {ESCAPE '\'}


----------------------------------------------------------------------------------------------------------------------------------------
--[_AIS_PD_Vehicle_F]
SELECT  
CONCAT(
Case
	WHEN left(PLATE_NUMBER,1) LIKE '%[-$!#%&+,./:;<=>@`{|}~"()*\\\_\^\?\[\]\'']%' {ESCAPE '\'} Then ASCII(left(PLATE_NUMBER,1))
	When Isnumeric(left(PLATE_NUMBER,1)) = 0 Then ASCII(left(PLATE_NUMBER,1)) --Checks if first character in license plate is numeric 	
	Else cast(left(PLATE_NUMBER,1) as int) *  12  --Takes licenses that start numerically and multiplies with 12
End + DATEPART(dy, CREATEDON)*2, ' - ', --Adds day of year to numeric conversion of license plate to get new sequential id number
right(year(CREATEDON),2)) AS [NEW ID],* -- concatenates new id number with year to express heiarchy
From [RISCRASHDATA].[dbo].[_AIS_PD_Vehicle_F]
----------------------------------------------------------------------------------------------------------------------------------------