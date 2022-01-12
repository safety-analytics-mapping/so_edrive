

SELECT Distinct 
'AWS' typ, a.[SRP_Order], a.[SRP_Seq], a.SR_Dsf, a.SR_Date_Last_Faced, a.X, a.Y
FROM dot55sql01.datawarehouse.dbo.STATUS_SGNS a 
JOIN dot55sql01.datawarehouse.dbo.STATUS_SIGNS b 
        on SIR_KEY = SR_Mutcd_Code
WHERE a.SRP_Type=1
        and b.MAIN_CATEGORY='Regulatory Sign' --remove parking Signs                                                                                 
        and b.SUB_CATEGORY='All Way' -- ONLY ALL-WAYS (will only include locations labeled as all-ways) 
        and x is not null and y is not null


with aws_data as(
SELECT Distinct 
'AWS' typ, a.[SRP_Order], a.[SRP_Seq], a.SR_Dsf, a.SR_Date_Last_Faced, a.X, a.Y
FROM dot55sql01.datawarehouse.dbo.STATUS_SGNS a 
JOIN dot55sql01.datawarehouse.dbo.STATUS_SIGNS b 
        on SIR_KEY = SR_Mutcd_Code
WHERE a.SRP_Type=1
        and b.MAIN_CATEGORY='Regulatory Sign' --remove parking Signs                                                                                 
        and b.SUB_CATEGORY='All Way' -- ONLY ALL-WAYS (will only include locations labeled as all-ways) 
        and x is not null and y is not null
)

select 'AWS' typ, a1.[SRP_Order], a1.[SRP_Seq], a1.SR_Dsf, a1.SR_Date_Last_Faced, a1.X, a1.Y 
from aws_data a1
join
	(select  SRP_Order,  max(SRP_Seq) SRP_Seq
	from aws_data 
	group by SRP_Order) a2
    on a1.SRP_Order=a2.SRP_Order and a1.SRP_Seq=a2.SRP_Seq




with aws_data as(
select  a.[SRP_Order],  max(a.[SRP_Seq])
FROM dot55sql01.datawarehouse.dbo.STATUS_SGNS a 
JOIN dot55sql01.datawarehouse.dbo.STATUS_SIGNS b 
        on SIR_KEY = SR_Mutcd_Code
WHERE a.SRP_Type=1
        and b.MAIN_CATEGORY='Regulatory Sign' --remove parking Signs                                                                                 
        and b.SUB_CATEGORY='All Way' -- ONLY ALL-WAYS (will only include locations labeled as all-ways) 
        and x is not null and y is not null
group by a.[SRP_Order])

select 
from aws_data
join