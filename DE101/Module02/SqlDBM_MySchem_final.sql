

-- ************************************** segment_dim
DROP TABLE if exists segment_dim cascade;

CREATE TABLE segment_dim
(
 segment_id  serial NOT NULL,
 segment_name varchar(50) NOT null,
 CONSTRAINT PK_21 PRIMARY KEY ( segment_id )
);

truncate table segment_dim cascade;

insert into segment_dim 
select row_number() over() , Segment from (select distinct Segment from orders) a;

select * from segment_dim sd;

-- ************************************** ship_dim
DROP TABLE if exists ship_dim cascade;

CREATE TABLE ship_dim
(
 ship_id     int NOT NULL,
 ship_mod varchar(50) NOT NULL,
 CONSTRAINT PK_13 PRIMARY KEY ( ship_id )
);

truncate table ship_dim cascade;

insert into ship_dim 
select 100+row_number() over() , ship_mode from (select distinct ship_mode from orders) a;

select * from ship_dim shd;


-- ************************************** region_dim
DROP TABLE if exists region_dim cascade;

CREATE TABLE region_dim
(
 region_id serial NOT NULL,
 region    varchar(10) NOT NULL,
 manager   varchar(25) NOT NULL,
 CONSTRAINT PK_33 PRIMARY KEY ( region_id )
);

truncate table region_dim cascade;

insert into region_dim 
select 10+row_number() over() , region, person from (select distinct region, person from people) a;

select * from region_dim red;
-- ************************************** area_dim
DROP TABLE if exists area_dim cascade;

CREATE TABLE area_dim
(
 area_id   serial NOT NULL,
 region_id serial NOT NULL,
 country   varchar(50) NOT NULL,
 state     varchar(50) NOT NULL,
 city      varchar(50) NOT NULL,
 zip       int,
 CONSTRAINT PK_25 PRIMARY KEY ( area_id ),
 CONSTRAINT FK_85 FOREIGN KEY ( region_id ) REFERENCES region_dim ( region_id )
);

CREATE INDEX FK_87 ON area_dim
(
 region_id
);

truncate table area_dim cascade;

insert into area_dim (zip, region_id, country, state, city)
select postal_code, rd.region_id, country, state, city from orders o inner join region_dim rd on rd.region = o.region group by postal_code, rd.region_id, country, state, city;

select * from area_dim;

-- ************************************** category_dim
DROP TABLE if exists category_dim cascade;

CREATE TABLE category_dim
(
 category_id   serial NOT NULL,
 category_name varchar(50) NOT NULL,
 CONSTRAINT PK_42 PRIMARY KEY ( category_id )
);

truncate table category_dim cascade;

insert into category_dim 
select 10+row_number() over() , category from (select distinct category from orders) a;

select * from category_dim cd;
-- ************************************** subcategory_dim
DROP TABLE if exists subcategory_dim cascade;

CREATE TABLE subcategory_dim
(
 subcat_id       serial NOT NULL,
 subcategory_name varchar(50) NOT NULL,
 category_id     serial NOT NULL,
 CONSTRAINT PK_97 PRIMARY KEY ( subcat_id ),
 CONSTRAINT FK_99 FOREIGN KEY ( category_id ) REFERENCES category_dim ( category_id )
);

CREATE INDEX FK_101 ON subcategory_dim
(
 category_id
);

truncate table subcategory_dim cascade;

insert into subcategory_dim (subcategory_name,category_id)
select subcategory, rd.category_id from orders o inner join category_dim rd on rd.category_name = o.category group by subcategory, rd.category_id ;

select * from subcategory_dim;

-- ************************************** customer_dim
DROP TABLE if exists customer_dim cascade;

CREATE TABLE customer_dim
(
 customer_id   serial NOT NULL,
 customer_code varchar(10) NOT NULL,
 customer_name varchar(50) NOT NULL,
 segment_id    serial NOT NULL,
 CONSTRAINT PK_17 PRIMARY KEY ( customer_id ),
 CONSTRAINT FK_88 FOREIGN KEY ( segment_id ) REFERENCES segment_dim ( segment_id )
);

CREATE INDEX FK_90 ON customer_dim
(
 segment_id
);

truncate table customer_dim cascade;

insert into customer_dim (customer_code,customer_name,segment_id)
select customer_id, customer_name, rd.segment_id from orders o inner join segment_dim rd on rd.segment_name = o.segment group by customer_id, customer_name, rd.segment_id;

select * from customer_dim;

-- ************************************** date_tab

DROP TABLE if exists date_tab cascade;

CREATE TABLE date_tab
(
  date_id              DATE NOT NULL,
   year_actual              INT NOT NULL,
   quarter_actual           INT NOT NULL,
   quarter_name             VARCHAR(9) NOT NULL,
   month_actual             INT NOT NULL,
  month_name               VARCHAR(9) NOT NULL,
  month_name_abbreviated   CHAR(3) NOT NULL,
  day_of_week              INT NOT NULL,
  weekend_indr             BOOLEAN NOT null,
  day_of_month             INT NOT NULL,
  week_of_year             INT NOT NULL,
  CONSTRAINT PK_5 PRIMARY KEY ( date_id )
);

truncate table date_tab cascade;

INSERT INTO date_tab
SELECT 	datum AS date_id,
		EXTRACT(YEAR FROM datum) AS year_actual,
       	EXTRACT(QUARTER FROM datum) AS quarter_actual,
       	CASE
           WHEN EXTRACT(QUARTER FROM datum) = 1 THEN 'Q1'
           WHEN EXTRACT(QUARTER FROM datum) = 2 THEN 'Q2'
           WHEN EXTRACT(QUARTER FROM datum) = 3 THEN 'Q3'
           WHEN EXTRACT(QUARTER FROM datum) = 4 THEN 'Q4'
           END AS quarter_name,	
		EXTRACT(MONTH FROM datum) AS month_actual,
       	TO_CHAR(datum, 'TMMonth') AS month_name,
       	TO_CHAR(datum, 'Mon') AS month_name_abbreviated,           
       EXTRACT(ISODOW FROM datum) AS day_of_week,
       CASE
           WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE
           ELSE FALSE
           END AS weekend_indr,       
       EXTRACT(DAY FROM datum) AS day_of_month,
       EXTRACT(WEEK FROM datum) AS week_of_year

FROM (SELECT '2016-01-01'::DATE + SEQUENCE.DAY AS datum
      FROM GENERATE_SERIES(0, 2000) AS SEQUENCE (DAY)
      GROUP BY SEQUENCE.DAY) DQ
ORDER BY 1;

COMMIT;

select * from date_tab


-- ************************************** product_dim
DROP TABLE if exists product_dim cascade;

CREATE TABLE product_dim
(
 product_id  serial NOT NULL, 
 product_code varchar(15) NOT NULL,
 product_name varchar(150) NOT NULL,
 subcat_id    serial NOT NULL,
 CONSTRAINT PK_38 PRIMARY KEY ( product_id ),
 CONSTRAINT FK_102 FOREIGN KEY ( subcat_id ) REFERENCES subcategory_dim ( subcat_id )
);

CREATE INDEX FK_104 ON product_dim
(
 subcat_id
);

truncate table product_dim cascade;

insert into product_dim (product_code,product_name,subcat_id)
select product_id, product_name, rd.subcat_id 
from orders o 
inner join subcategory_dim rd on rd.subcategory_name = o.subcategory 
group by product_id, product_name, rd.subcat_id;

select * from product_dim order by product_id;
-- ************************************** order_dim
DROP TABLE if exists order_dim cascade; 

CREATE TABLE order_dim
(
 order_id    serial NOT NULL,
 order_num	 varchar(15) not null,
 date_id     date NOT NULL,
 customer_id serial NOT NULL,
 area_id     serial NOT NULL,
 ship_id     int NOT NULL,
 ship_date   date NOT NULL,
 
 CONSTRAINT PK_107 PRIMARY KEY ( order_id, order_num ),
 CONSTRAINT FK_110 FOREIGN KEY ( area_id ) REFERENCES area_dim ( area_id ),
 CONSTRAINT FK_113 FOREIGN KEY ( customer_id ) REFERENCES customer_dim ( customer_id ),
 CONSTRAINT FK_116 FOREIGN KEY ( ship_id ) REFERENCES ship_dim ( ship_id ),
 CONSTRAINT FK_125 FOREIGN KEY ( date_id ) REFERENCES date_tab ( date_id )
);

CREATE INDEX FK_112 ON order_dim
(
 area_id
);

CREATE INDEX FK_115 ON order_dim
(
 customer_id
);

CREATE INDEX FK_118 ON order_dim
(
 ship_id
);

CREATE INDEX FK_128 ON order_dim
(
 date_id
);

select * from order_dim;

truncate table order_dim cascade;

insert into order_dim (order_num, date_id, customer_id, area_id, ship_id, ship_date)
select order_id, dd.date_id, cusd.customer_id, ad.area_id, sh.ship_id, ddd.date_id 
from orders o 
inner join date_tab dd on dd.date_id = o.order_date  
inner join customer_dim cusd on cusd.customer_code = o.customer_id 
inner join area_dim ad on ad.city = o.city and (ad.zip = o.postal_code or ((o.postal_code is null)and(ad.zip is null))) 
inner join ship_dim sh on sh.ship_mod  = o.ship_mode 
inner join date_tab ddd on ddd.date_id = o.ship_date  
group by order_id, dd.date_id, cusd.customer_id, ad.area_id, sh.ship_id, ddd.date_id;

select * from order_dim order by order_id;

select count(*) from order_dim;

-- ************************************** sales_fact
drop table if exists sales_fact cascade;

CREATE TABLE sales_fact
(
 sales_id   bigserial NOT NULL,
 product_id serial NOT NULL,
 order_id   serial NOT NULL,
 order_num  varchar(15) not null,
 quantity   int4 NOT NULL,
 discount   numeric(4,2) NOT NULL,
 sales      numeric(9,4) NOT NULL,
 profit     numeric(21,16) NOT NULL,
 CONSTRAINT PK_47 PRIMARY KEY ( sales_id ),
 CONSTRAINT FK_122 FOREIGN KEY ( order_id, order_num ) REFERENCES order_dim ( order_id, order_num ),
 CONSTRAINT FK_51 FOREIGN KEY ( product_id ) REFERENCES product_dim ( product_id )
);

CREATE INDEX FK_124 ON sales_fact
(
 order_id, order_num
);

CREATE INDEX FK_53 ON sales_fact
(
 product_id
);

truncate table sales_fact cascade;

insert into sales_fact (order_id, order_num, product_id, quantity, discount, sales, profit)
select od.order_id, od.order_num , pd.product_id, quantity, discount, sales, profit 
from orders o 
inner join order_dim od on od.order_num  = o.order_id  
inner join product_dim pd on pd.product_code = o.product_id and pd.product_name = o.product_name ;

-- проверка на соответствие количества записе и содержания
select count(*), sum(sales) from sales_fact;
select count(*), sum(sales) from orders;

--поиск потерянных при переносе данных
SELECT order_id  
FROM orders 
WHERE NOT EXISTS (SELECT sales_fact.order_num
                 FROM sales_fact
                 WHERE orders.order_id = sales_fact.order_num and orders.sales = sales_fact.sales);
                 

-- ************************************** returns
drop table if exists returns_dim cascade;

CREATE TABLE returns_dim
(
 ret_id   serial NOT NULL,
 order_id serial NOT NULL,
 order_num  varchar(15) not null,
 CONSTRAINT PK_134 PRIMARY KEY ( ret_id ),
 CONSTRAINT FK_119 FOREIGN KEY ( order_id, order_num ) REFERENCES order_dim ( order_id,order_num )
);

CREATE INDEX FK_121 ON returns_dim
(
 order_id, order_num
);

truncate table returns_dim cascade;

insert into returns_dim (order_id, order_num)
select od.order_id, od.order_num  
from "returns" o 
inner join order_dim od on od.order_num  = o.order_id  
group by od.order_id, order_num;

select * from returns_dim;





