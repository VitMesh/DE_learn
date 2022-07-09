--1.	Overview (обзор ключевых метрик)

--Х	Total Sales
select round(sum(sales),2) as "Total Sales" from orders;

--Х	Total Profit
select round(sum(profit),2) as "Total Profit" from orders;

--Х	Profit Ratio
select round(sum(profit)/sum(sales)*100,1) as "Profit Ratio" 
from orders;

--Х	Profit per Order
select round(sum(sales)/count(distinct(order_id))*100,2) as "Profit per Order" from orders o;

--Х	Sales per Customer
select round(sum(sales)/count(distinct(customer_id))*100,2) as "Sales per Customer" from orders o;

--Х	Avg. Discount
select round(avg(discount),1) as "Avg. Discount" from orders;

--Х	Monthly Sales by Segment ( табличка и график)
select coalesce(segment, 'Total sum') as "Segment",
  round(sum(case when date_part('month',order_date) = 1 then sales else 0 end),2) "Jan",
  round(sum(case when date_part('month',order_date) = 2 then sales else 0 end),2) "Feb",
  round(sum(case when date_part('month',order_date) = 3 then sales else 0 end),2) "Mar",
  round(sum(case when date_part('month',order_date) = 4 then sales else 0 end),2) "Apr",
  round(sum(case when date_part('month',order_date) = 5 then sales else 0 end),2) "May",
  round(sum(case when date_part('month',order_date) = 6 then sales else 0 end),2) "Jun",
  round(sum(case when date_part('month',order_date) = 7 then sales else 0 end),2) "Jul",
  round(sum(case when date_part('month',order_date) = 8 then sales else 0 end),2) "Aug",
  round(sum(case when date_part('month',order_date) = 9 then sales else 0 end),2) "Sep",
  round(sum(case when date_part('month',order_date) = 10 then sales else 0 end),2) "Oct",
  round(sum(case when date_part('month',order_date) = 11 then sales else 0 end),2) "Nov",
  round(sum(case when date_part('month',order_date) = 12 then sales else 0 end),2) "Dec",
  round(sum(sales),2) as "Total"
from orders
group by rollup(segment);

--Х	Monthly Sales by Product Category (табличка и график) 
 select concat(  text(date_part('Year',order_date)),'-',
                case when date_part('Month',order_date) < 10 then concat('0',text(date_part('Month',order_date))) 
                                                              else text(date_part('Month',order_date))
                                                              end) as "Month", 
       round(sum(case when t.category = 'Furniture' then t.sales end),2) as "Furniture",
       round(sum(case when t.category = 'Office Supplies' then t.sales end),2) as "Office Supplies",
       round(sum(case when t.category = 'Technology' then t.sales end),2) as "Technology",
       round(sum(t.sales),2) as "Total"
from orders t
group by concat(text(date_part('Year',order_date)),'-',case when date_part('Month',order_date) < 10 then concat('0',text(date_part('Month',order_date))) 
                                                              else text(date_part('Month',order_date))
                                                              end)  
order by concat(text(date_part('Year',order_date)),'-',case when date_part('Month',order_date) < 10 then concat('0',text(date_part('Month',order_date))) 
                                                              else text(date_part('Month',order_date))
                                                              end);

--2.	Product Dashboard (ѕродуктовые метрики)
--Х	Sales by Product Category over time (ѕродажи по категори€м)
select category as "Category", round(sum(sales),2) as "Total Sales" 
from orders 
group by category 
order by sum(sales) desc; 

--3.	Customer Analysis
--Х	Sales and Profit by Customer
--Х	Customer Ranking
select customer_name as "Customer name", 
       round(sum(sales),2) as "Total Sales", 
       round(sum(profit),2) as "Total Profit" 
from orders 
group by customer_name 
order by sum(profit) desc;

--Х	Sales per region
select region as "Region", round(sum(sales),2) as "Total Sales" 
from orders 
group by region 
order by sum(sales) desc; 