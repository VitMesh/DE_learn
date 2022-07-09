select dt.date_id as "Order date",
		dt.year_actual as "Year",
		dt.quarter_name as "Qarter",
		dt.quarter_actual as "Quarter num",
		dt.month_actual as "Month num",
		dt.month_name_abbreviated as "Month",
		sf.sales_id ,
		sf.product_id ,
		sf.order_id ,
		sf.order_num as "Order ID",
		sf.quantity as "Q-ty",
		sf.discount as "Discount",
		sf.sales as "Sales",
		sf.profit as "Profit",
		od.customer_id ,
		od.area_id ,
		od.ship_id ,
		od.ship_date as "Ship date",
		pd.product_code as "Product ID",
		pd.product_name as "Product name",
		pd.subcat_id ,
		cd.customer_code as "Customer ID",
		cd.customer_name as "Customer name",
		cd.segment_id ,
		ad.region_id,
		ad.country as "Country",
		ad.state as "State",
		ad.city as "City",
		ad.zip as "Zip",
		scd.subcategory_name as "Subcategory",
		scd.category_id,
		ctd.category_name as "Category",
		rd.region as "Region",
		rd.manager as "Manager",
		sd.segment_name as "Segment",
		sd2.ship_mod as "Ship mode",
		rd2.ret_id
from dw.sales_fact sf
inner join dw.order_dim od on sf.order_id = od.order_id
inner join dw.product_dim pd on pd.product_id = sf.product_id
inner join dw.date_tab dt on dt.date_id = od.date_id
inner join dw.customer_dim cd  on cd.customer_id = od.customer_id
inner join dw.area_dim ad on ad.area_id = od.area_id
inner join dw.subcategory_dim scd on scd.subcat_id = pd.subcat_id
inner join dw.category_dim ctd on ctd.category_id = scd.category_id
inner join dw.region_dim rd on ad.region_id = rd.region_id
inner join dw.segment_dim sd on cd.segment_id = sd.segment_id 
inner join dw.ship_dim sd2 on sd2.ship_id = od.ship_id 
left join dw.returns_dim rd2 on rd2.order_id = od.order_id