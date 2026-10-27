--==================================================================================================================================================================================--
-----------------------------------------------------------------------------Creating Bronze Layer DDL--------------------------------------------------------------------------------
--Use [warehouse]
--Create each table for csv ['customers','products','orders','orders_lines','Payments','locations'] into the broze scheama
--drop table if exists
--all Colums have datatype [nvarchar(255)]
--==================================================================================================================================================================================--


use warehouse;
go
drop table if exists bronze.locations
go
Create table bronze.locations (
									location_id nvarchar(255),
									locality	nvarchar(255),
									city		nvarchar(255),
									state		nvarchar(255),
									region		nvarchar(255)
						);



drop table if exists bronze.customers
go
Create table bronze.customers (
									customer_id		nvarchar(255),
									customer_name	nvarchar(255),
									email			nvarchar(255),
									phone			nvarchar(255),
									location_id		nvarchar(255),
									signup_date		nvarchar(255)
							   );


	
drop table if exists bronze.products
go
Create table bronze.products (
									product_id		nvarchar(255),
									product_name	nvarchar(255),
									category		nvarchar(255),
									brand			nvarchar(255),
									list_price		nvarchar(255),
									active_flag		nvarchar(255)
							  );



drop table if exists bronze.orders
go
Create table bronze.orders (
									order_id		nvarchar(255),
									order_date		nvarchar(255),
									customer_id		nvarchar(255),
									order_status	nvarchar(255),
									sales_channel	nvarchar(255)
							);


drop table if exists bronze.order_lines
go
Create table bronze.order_lines (
										order_line_id	nvarchar(255),
										order_id		nvarchar(255),
										product_id		nvarchar(255),
										quantity		nvarchar(255),
										unit_price		nvarchar(255),
										discount_pct	nvarchar(255)
								 );


drop table if exists bronze.payments
go
Create table bronze.payments (
									payment_id			nvarchar(255),
									order_id			nvarchar(255),
									payment_method		nvarchar(255),
									payment_status		nvarchar(255),
									payment_date		nvarchar(255),
									payment_reference	nvarchar(255)
							  );

