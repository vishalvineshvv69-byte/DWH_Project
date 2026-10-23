--=========================================================================================================================================================================================
                                                                                --- Bronze Layer [Full-Load] ----
--=========================================================================================================================================================================================
-- Creating full load systum
--using Truncate and Drop for each table
--Store inside the procedure with try and chatch
--Providing real time duration to complet for each table and whole batch
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create or alter procedure bronze_load as
	begin
		declare @start_time datetime, @end_time datetime , @batch_satart_time datetime, @batch_end_time datetime;
			begin try
			
				set @batch_satart_time = GETDATE();
				print '=======================================================================';
				print 'Loadind Bronze layer'
				print '======================================================================='

				print '-----------------------------------------------------------------------';
				print 'Loadind crm table'
				print '-----------------------------------------------------------------------';
			


				set @start_time = getdate();
				print'>> truncate table : bronze.crm_cust_info';
				print'>> loading table : bronze.crm_cust_info';

				truncate table bronze.crm_cust_info
				bulk insert bronze.crm_cust_info
				from 'C:\Users\visha\Documents\DWH_Braaa_project\Datasates\source_crm\cust_info.csv'
				with (
						firstrow=2,
						fieldterminator = ',',
						tablock
					 );
				set @end_time = getdate();
				print 'Load duration ' + cast(datediff(second,@Start_time,@end_time)as varchar) + 'Seconds'



				set @start_time = getdate();
				print'>> truncate table : bronze.crm_prd_info';
				print'>> loading table : bronze.crm_prd_info';
				truncate table bronze.crm_prd_info
				bulk insert bronze.crm_prd_info
				from'C:\Users\visha\Documents\DWH_Braaa_project\Datasates\source_crm\prd_info.csv'
				with (
						firstrow = 2,
						fieldterminator = ',',
						tablock
					 );
				set @end_time = getdate();
				print 'Load duration ' + cast(datediff(second,@Start_time,@end_time)as varchar) + 'Seconds'
			


				set @start_time = getdate();
				print'>> truncate table : bronze.crm_sales_details';
				print'>> loading table : bronze.crm_sales_details';
				truncate table  bronze.crm_sales_details
				bulk insert bronze.crm_sales_details
				from 'C:\Users\visha\Documents\DWH_Braaa_project\Datasates\source_crm\sales_details.csv'
				with (
						firstrow = 2,
						fieldterminator = ',',
						tablock
					 );
				set @end_time = getdate();
				print 'Load duration ' + cast(datediff(second,@Start_time,@end_time)as varchar) + 'Seconds'



				print '-----------------------------------------------------------------------';
				print 'Loadind erp table'
				print '-----------------------------------------------------------------------';




				set @start_time = getdate();
				print'>> truncate table : bronze.erp_cust_az12';
				print'>> loading table : bronze.erp_cust_az12';
				truncate table bronze.erp_cust_az12
				bulk insert bronze.erp_cust_az12
				from 'C:\Users\visha\Documents\DWH_Braaa_project\Datasates\source_erp\CUST_AZ12.csv'
				with (
						firstrow = 2,
						fieldterminator = ',',
						tablock
					 );
				set @end_time = getdate();
				print 'Load duration ' + cast(datediff(second,@Start_time,@end_time)as varchar) + 'Seconds'




				set @start_time = getdate();
				print'>> truncate table : bronze.erp_loc_a101';
				print'>> loading table : bronze.erp_loc_a101';
				truncate table bronze.erp_loc_a101
				bulk insert bronze.erp_loc_a101
				from 'C:\Users\visha\Documents\DWH_Braaa_project\Datasates\source_erp\LOC_A101.csv'
				with (
						firstrow = 2,
						fieldterminator = ',',
						tablock
					 );
				set @end_time = getdate();
				print 'Load duration ' + cast(datediff(second,@Start_time,@end_time)as varchar) + 'Seconds'


				set @start_time = getdate();
				print'>> truncate table : bronze.erp_px_cat_g1v2';
				print'>> loading table : bronze.erp_px_cat_g1v2';
				truncate table bronze.erp_px_cat_g1v2
				bulk insert bronze.erp_px_cat_g1v2
				from 'C:\Users\visha\Documents\DWH_Braaa_project\Datasates\source_erp\PX_CAT_G1V2.csv'
				with (
						firstrow = 2,
						fieldterminator = ',',
						tablock
					 );
				set @end_time = getdate();
				print 'Load duration ' + cast(datediff(second,@Start_time,@end_time)as varchar) + 'Seconds';

				set @batch_end_time = GETDATE();


				print'-----------------------------------------';
				print'| Total batch load duration ' + cast(datediff(second,@batch_satart_time,@batch_end_time) as varchar)+ 'Seconds    |';
				print'-----------------------------------------';

			end try
			begin catch
		
				print '=======================================================================';
				print '---------------------------------ERORR---------------------------------';
				print '=======================================================================';

			end catch
	end;

 go

   exec bronze_load
