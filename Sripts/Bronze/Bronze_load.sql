--==================================================================================================================================================================================--
---------------------------------------------------------------------------------Bronze bulk insert from csvs ------------------------------------------------------------------------
--Inserting data with bulk insert
--droping each table befor inserting 
--used[Full load]
--store at procedure [bronze_load]
--==================================================================================================================================================================================--

use warehouse
go

drop procedure if exists bronze_load
go
create procedure bronze_load as 

	begin

		truncate table bronze.customers 
			
			bulk insert bronze.customers 
			from 'C:\Users\visha\Desktop\My Warehouse\dataset\customers.csv'
			with (
						firstrow = 2,
						fieldterminator = ',',
						tablock
				 );




			truncate table bronze.products
			
			bulk insert bronze.products
			from 'C:\Users\visha\Desktop\My Warehouse\dataset\products.csv'
			with (
						firstrow = 2,
						fieldterminator = ',',
						tablock
				 );
	


			truncate table bronze.orders
			
			bulk insert bronze.orders
			from 'C:\Users\visha\Desktop\My Warehouse\dataset\orders.csv'
			with (
						firstrow = 2,
						fieldterminator = ',',
						tablock
				 );



			truncate table bronze.order_lines
			
			bulk insert bronze.order_lines
			from 'C:\Users\visha\Desktop\My Warehouse\dataset\order_lines.csv'
			with (
						firstrow = 2,
						fieldterminator = ',',
						tablock
				 );




			truncate table bronze.locations
			
			bulk insert bronze.locations
			from 'C:\Users\visha\Desktop\My Warehouse\dataset\locations.csv'
			with (
						firstrow = 2,
						fieldterminator = ',',
						tablock
				 );





			truncate table bronze.payments
			
			bulk insert bronze.payments
			from 'C:\Users\visha\Desktop\My Warehouse\dataset\payments.csv'
			with (
						firstrow = 2,
						fieldterminator = ',',
						tablock
				 );

	end


	exec bronze_load
