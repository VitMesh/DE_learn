--1.	Overview (обзор ключевых метрик)

--Х	Total Sales
select round(sum(sales),2) as "Total Sales" from dw.sales_fact;

--Х	Total Profit
select round(sum(profit),2) as "Total Profit" from dw.sales_fact;

--Х	Profit Ratio
select round(sum(profit)/sum(sales)*100,1) as "Profit Ratio" 
from dw.sales_fact;

--Х	Profit per Order
select round(sum(sales)/count(distinct(order_id))*100,2) as "Profit per Order" from dw.sales_fact o;

--Х	Sales per Customer
select round(sum(sales)/count(distinct(customer_id))*100,2) as "Sales per Customer" from dw.sales_fact o inner join dw.order_dim rd on rd.order_id = o.order_id;

--Х	Avg. Discount
select round(avg(discount),1) as "Avg. Discount" from dw.sales_fact;

--Х	Monthly Sales by Segment ( табличка и график)
select coalesce(sed.segment_name, 'Total sum') as "Segment",
  round(sum(case when date_part('month',rd.date_id) = 1 then sales else 0 end),2) "Jan",
  round(sum(case when date_part('month',rd.date_id) = 2 then sales else 0 end),2) "Feb",
  round(sum(case when date_part('month',rd.date_id) = 3 then sales else 0 end),2) "Mar",
  round(sum(case when date_part('month',rd.date_id) = 4 then sales else 0 end),2) "Apr",
  round(sum(case when date_part('month',rd.date_id) = 5 then sales else 0 end),2) "May",
  round(sum(case when date_part('month',rd.date_id) = 6 then sales else 0 end),2) "Jun",
  round(sum(case when date_part('month',rd.date_id) = 7 then sales else 0 end),2) "Jul",
  round(sum(case when date_part('month',rd.date_id) = 8 then sales else 0 end),2) "Aug",
  round(sum(case when date_part('month',rd.date_id) = 9 then sales else 0 end),2) "Sep",
  round(sum(case when date_part('month',rd.date_id) = 10 then sales else 0 end),2) "Oct",
  round(sum(case when date_part('month',rd.date_id) = 11 then sales else 0 end),2) "Nov",
  round(sum(case when date_part('month',rd.date_id) = 12 then sales else 0 end),2) "Dec",
  round(sum(sales),2) as "Total"
from dw.sales_fact o
inner join dw.order_dim rd on rd.order_id = o.order_id
inner join dw.customer_dim cud on rd.customer_id = cud.customer_id
inner join dw.segment_dim sed on sed.segment_id = cud.segment_id
group by rollup(sed.segment_name);

--Х	Monthly Sales by Product Category (табличка и график) 
 select concat(  text(date_part('Year',rd.date_id)),'-',
                case when date_part('Month',rd.date_id) < 10 then concat('0',text(date_part('Month',rd.date_id))) 
                                                              else text(date_part('Month',rd.date_id))
                                                              end) as "Month", 
       round(sum(case when ctd.category_name = 'Furniture' then t.sales end),2) as "Furniture",
       round(sum(case when ctd.category_name = 'Office Supplies' then t.sales end),2) as "Office Supplies",
       round(sum(case when ctd.category_name = 'Technology' then t.sales end),2) as "Technology",
       round(sum(t.sales),2) as "Total"
from dw.sales_fact t
inner join dw.order_dim rd on rd.order_id = t.order_id
inner join dw.product_dim cud on t.product_id = cud.product_id
inner join dw.subcategory_dim sed on sed.subcat_id = cud.subcat_id
inner join dw.category_dim ctd on ctd.category_id = sed.category_id
group by concat(text(date_part('Year',rd.date_id)),'-',case when date_part('Month',rd.date_id) < 10 then concat('0',text(date_part('Month',rd.date_id))) 
                                                              else text(date_part('Month',rd.date_id))
                                                              end)  
order by concat(text(date_part('Year',rd.date_id)),'-',case when date_part('Month',rd.date_id) < 10 then concat('0',text(date_part('Month',rd.date_id))) 
                                                              else text(date_part('Month',rd.date_id))
                                                              end);

--2.	Product Dashboard (ѕродуктовые метрики)
--Х	Sales by Product Category over time (ѕродажи по категори€м)
select ctd.category_name as "Category", round(sum(t.sales),2) as "Total Sales" 
from dw.sales_fact t
inner join dw.order_dim rd on rd.order_id = t.order_id
inner join dw.product_dim cud on t.product_id = cud.product_id
inner join dw.subcategory_dim sed on sed.subcat_id = cud.subcat_id
inner join dw.category_dim ctd on ctd.category_id = sed.category_id
group by ctd.category_name 
order by sum(t.sales) desc; 

--3.	Customer Analysis
--Х	Sales and Profit by Customer
--Х	Customer Ranking
select cud.customer_name as "Customer name", 
       round(sum(o.sales),2) as "Total Sales", 
       round(sum(o.profit),2) as "Total Profit" 
from dw.sales_fact o
inner join dw.order_dim rd on rd.order_id = o.order_id
inner join dw.customer_dim cud on rd.customer_id = cud.customer_id
group by cud.customer_name 
order by sum(o.profit) desc;

--Х	Sales per region
select cur.region as "Region", round(sum(o.sales),2) as "Total Sales" 
from dw.sales_fact o
inner join dw.order_dim rd on rd.order_id = o.order_id
inner join dw.area_dim cud on rd.area_id = cud.area_id
inner join dw.region_dim cur on cur.region_id = cud.region_id
group by cur.region 
order by sum(o.sales) desc; 