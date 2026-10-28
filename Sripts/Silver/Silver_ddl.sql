use warehouse

drop table if exists silver.locations
go
create table silver.locations (
									location_id		int,
									locality	nvarchar(255),
									city		nvarchar(255),
									state		nvarchar(255),
									region		nvarchar(255)

									constraint PK_locations 
									primary key (location_id)
							  );



drop table if exists silver.customers
go
create table silver.customers	(
									customer_id		int,
									customer_name	nvarchar(255),
									email			nvarchar(255),
									phone			nvarchar(255),
									location_id		int,
									signup_date		date

									constraint PK_customers
									primary key (customer_id)
								);	



drop table if exists silver.products 
go
create table silver.products (
									 
									product_id		int,
									product_name	nvarchar(255),
									category		nvarchar(255),
									brand			nvarchar(255),
									list_price		int,
									active_flag		int

									constraint PK_PRoducts
									primary key (product_id)
							  );



drop table if exists silver.orders
go
create table silver.orders	(
								order_id    int ,
								order_date date,
								customer_id int,
								order_status nvarchar(255),
								sales_channel nvarchar(255)

								constraint PK_orders
								primary key(order_id)
							);



drop table  if exists silver.order_lines
go
create table silver.order_lines (
									order_line_id	int,
									order_id		int,
									product_id		int,
									quantity		int,
									unit_price		int,
									discount_pct	int

									constraint PK_order_lines
									primary key(order_line_id)
								);



drop table  if exists silver.payments
go
create table silver.payments  (
									payment_id			int,
									order_id			int,
									payment_method		nvarchar(255) ,
									payment_status		nvarchar(255),
									payment_date		date,
									payment_reference	nvarchar(255)


									constraint PK_payments
									primary key(payment_id)
							 );


									



