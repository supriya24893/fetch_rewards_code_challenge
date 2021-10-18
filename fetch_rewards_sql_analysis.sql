---Assumptions
---used Microsoft SQL Server management studio 18 for this analysis
--finished receipts are the ones which have been accepted
-- The most recent scan date for receipts was 1st March 2021. Since the month of march only has one day, we will take february, 2021 as 
---most recent month of analysis and January 2021 is taken as previous month
---due to data inconsistency and incompleteness, while the receipts and brands tables can be joined on brand code, a
--as well as rewards parnter id and cpg id respective, I have only used brandcode to link tables to get the maximum range of data and dates.
---Joining on both rewards_partner_id and brandcode limits the data siginificantly giving only January 2021 data which isnt sufficent for robust analysis
--Joining on just rewards_partner_id and cpg_id gives an erroneous join and hence cant be used
---I have taken most recent dates based on date of receit scanned and date of user created columns as a standalone 
--each distinct receipt scanned is taken as one independant transaction on the fetch rewards app

--using the database
use fetch_rewards
go

----What are the top 5 brands by receipts scanned for most recent month?---
--exploring data---------------------
select * from fetch_rewards.dbo.df_receipts_final

select * from fetch_rewards.dbo.users_final

select top 10 * from fetch_rewards.dbo.df_brands_new


---- finding most recent scan date------------------------------
select max(dateScanned)
from
fetch_rewards.dbo.df_receipts_final  ---1st March 2021

---joining brands and receipts tables on brand code
select count(distinct table2.id) as total_receipts,table2.Brand_code
from
(select *
from
(select a.id,a.dateScanned,b.name, a.Brand_code,
month(dateScanned) as date_month,year(dateScanned) as date_year ---into #table1
from
fetch_rewards.dbo.df_receipts_final as a
left join
fetch_rewards.dbo.df_brands_new as b
on a.Brand_code=b.brand_code) as table1
where table1.date_month=2 and table1.date_year=2021) as table2
group by Brand_code



---none (brands not documented in the data),brand, mission foods, viva (collection of apparels and accessories) top 4 brands
--for further analysis data entries classified as none can be further analyzed


---The above can also be done without joining as brand code can be extracted from receipts table as shown
select count (distinct id) as total_receipts, Brand_code
from
(select *
from
(select a.id,a.dateScanned,a.Brand_code,month(a.dateScanned) as scan_month,year(a.dateScanned) as scan_year
from fetch_rewards.dbo.df_receipts_final as a) as table1
where scan_month=2 and scan_year=2021) as table2
group by Brand_code


--most recent month being feb 2021, there are total 4 brands documented. A lot of the receipts do not have a brandcode hence they have been classified as None


---How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
--recent month was february 2021, hence the month before that is january 2021
select count(distinct table2.id) as total_receipts, table2.Brand_code
from
(select *
from
(select a.id,a.dateScanned,a.Brand_code, b.name,
month(dateScanned) as date_month,year(dateScanned) as date_year ---into #table1
from
fetch_rewards.dbo.df_receipts_final as a
left join
fetch_rewards.dbo.df_brands_new as b
on a.Brand_code=b.brand_code) as table1
where table1.date_month=1 and table1.date_year=2021 ) as table2
group by Brand_code
order by total_receipts desc

--again due to data incompletness and inconsistency, most receipts have been classified into none
---none, ben and jerrys, tie between folgers and pepsi, tie between kraft and kelloggs and Kleenex can be termed as top 5 brands

--more than 5 distinct brands, more variety of receipts in January data
--this could be affected by how receipts are scanned, how data is collected, how accurate is computer vision capabilities of the app

---question 3 When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
--question 4 When considering total number of items purchased from receipts with 
--'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

--assumption: finished receipts are accepted

select sum(totalSpent) as total_spent ,rewardsReceiptStatus, sum(purchasedItemCount) as total_items
from
fetch_rewards.dbo.df_receipts_final
group by rewardsReceiptStatus

--for both accepted (finished) and rejected the total spent as well as purchased item count is way higher for finished/accepted than rejected
--This shows that the fetch rewards app does acccount and recognize most items.
--This also shows the number of receipts that are accepted are way more than those rejected. This helps in serving more consumers and brands

---question 5 ---------------------------------------------
---Which brand has the most spend among users who were created within the past 6 months?

---finding dates for 6 month
select max(createdDate)
from fetch_rewards.dbo.users_final--2021/02/12

select dateadd(month,-6,'2021/02/12')  --2020/08/12


select Brand_code,sum(totalSpent) as total_spent
from
(select b.id,a.userId,a.totalSpent,b.createdDate,a.Brand_code
from
fetch_rewards.dbo.df_receipts_final as a
join
fetch_rewards.dbo.users_final as b
on a.userId=b.id
where b.createdDate<='2021/02/12' and b.createdDate>'2020/08/12') as table1
group by Brand_code
order by total_spent DESC

---Again due to data collection problems and incmplete data, most receipts do not have a brand code listed on them for users created in the recent 6 months.
---thus total spent is maximum from those receipts
--Close that, total spent is highest for HY-VEE the midwest based grocery store chain

---08/12/2020

--question 6-----------------------------------------------------
---Which brand has the most transactions among users who were created within the past 6 months?

---each independant receipt scanned is taken to be one transaction
select Brand_code,count(distinct receipt_id) as distinct_transactions 
from
(select b.id,a.userId,a.totalSpent,a.id as receipt_id,b.createdDate,a.Brand_code
from
fetch_rewards.dbo.df_receipts_final as a
join
fetch_rewards.dbo.users_final as b
on a.userId=b.id
where b.createdDate<='2021/02/12' and b.createdDate>'2020/08/12' and a.dateScanned is not NULL) as tab1
group by Brand_code
order by distinct_transactions DESC

--The trend continues and most transactions cant be placed into a particular brand as that has not been documented with the given data
---none, tie between brand,mission foods,ben and jerrys icecream, pepsi, tie between Kleenex/Dole/FOLGERS, BIGELOW/KNORR/KRAFT/KELLOGS are some top brands
--most transactions are hence for food/grocery/snack brands


