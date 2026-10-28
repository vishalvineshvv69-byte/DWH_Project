drop procedure if exists Silver_load
go
create procedure Silver_load as 
begin  try 

truncate table silver.locations

insert into silver.locations  (
										location_id,
										locality,
										city,
										state,
										region
							  )
		
								(
									select 
									t.location_id,
									trim(t.locality) locality,
									case 
										when t.city = 'Bengaluru' then 'Bangalore'
										else t.city
									end city,
									t.state,
									case 
										when  trim(replace(t.region,CHAR(13),'')) = '' or  t.region is null then 'N/A'
										else  lower(trim(replace(t.region,CHAR(13),'')))
									end region

									from  (
												select 
												l.location_id,
												l.locality,
												l.city,
												l.state,
												l.region,
												row_number() over (partition by l.location_id  order by l.location_id ) as rank
												from bronze.locations as l
											)t
										where t.rank = 1
								);









truncate table silver.customers

insert into silver.customers (
									customer_id	,	
									customer_name,	
									email,		
									phone,		
									location_id,
									signup_date
							)


									(
										select 
										t.customer_id,
										trim(t.customer_name) as customer_name ,
										case
											when	t.email is null 
													or upper(trim(t.email)) = 'NULL'
													or trim(t.email) = ''
													or trim(t.email) not like '%@%.%'
											then	'N/A'
											else	lower(trim(t.email))
										end email,
										case 
											when	t.phone is null
													or trim(t.phone) like '%[a-z,A-Z]%'
											then   'N/A'
											when	t.phone like '+%' 
											then	substring(replace(replace(replace(trim(t.phone),' ',''),'-',''),'+',''),3,len(replace(replace(replace(trim(t.phone),' ',''),'-',''),'+','')))
											else	replace(replace(replace(trim(t.phone),' ',''),'-',''),'+','')
										end phone,
										case 
											when	t.location_id is null 
													or t.location_id like '%[a-z,A-Z]%'
													or t.location_id not in (select location_id from  bronze.locations )
											then	null
											else	t.location_id
											end location_id,
										try_convert(date,nullif(upper(trim(replace(t.signup_date,char(13),''))),'N/A'),23) signup_date
										from (
											select 
											c.customer_id,
											c.customer_name,
											c.email,
											c.phone,
											c.location_id,
											c.signup_date,
											row_number() over (partition by c.customer_id order by c.signup_date ) as  cust_rank
											from bronze.customers as c

										)t
										where t.cust_rank = 1 and t.customer_id is not null
										and try_convert(date,nullif(upper(trim(replace(t.signup_date,char(13),''))),'N/A'),23) between '20220101' and '20250630'
	 
									)







truncate table silver.products

insert into silver.products (
								product_id,
								product_name,
								category,
								brand,
								list_price,
								active_flag
							)
							(
							select
							product_id,
							lower(trim(product_name)) as product_name,
							case 
								when lower(trim(category)) in ('buauty & personalcare','personal care') then 'Buauty & Personalcare' 
								when lower(trim(category)) in ('electronic','electronics') then 'Electronic'
								when lower(trim(category)) in ('fashion','fashion wear') then 'Fashion Wear'
								when lower(trim(category)) in ('home & kitchen','home and kitchen') then 'Home & Kitchen'
								else upper(left (category,1)) + lower(substring(category,2,len(category)))
							end  as category,
							upper(left (brand,1)) + lower(substring(brand,2,len(brand))) as brand,
							case
								
								when upper(trim(list_price)) like 'RS.%' then substring(upper(trim(list_price)),4,len(upper(trim(list_price))))
								else trim(list_price)
							end list_price,
							case
								when upper(trim(replace(replace(active_flag,char(13),''),char(10),''))) in ('1','Y','YES','TRUE') then 1
								else null
							end active_flag
							from
								( select 
								*,
								row_number() over (partition by product_id order by list_price) as rank
								from bronze.products
							)t
							where t.rank = 1
							and upper(trim(list_price)) not in ('','NULL','N/A')
							and trim(list_price) not like '%[^1-9]%' 
							and upper(trim(replace(replace(active_flag,char(13),''),char(10),''))) not in ('0','N','NO','FALSE') 
							and trim(upper(trim(replace(replace(active_flag,char(13),''),char(10),'')))) != '' 
							)

   



truncate table Silver.orders

insert into Silver.orders(
							order_id,
							order_date,
							customer_id,
							order_status,
							sales_channel
						)
						(
							select 
							t.order_id,
							case 
								when try_convert(date,replace(replace(trim(t.order_date),char(13),''),char(10),''),23) is null 
									or try_convert(date,replace(replace(trim(t.order_date),char(13),''),char(10),''),23) like '%[a-z,A-Z]%'
								then null
								else try_convert(date,replace(replace(trim(t.order_date),char(13),''),char(10),''),23)
							end order_date,
							case
								when t.customer_id not in  (select customer_id from Silver.customers) 
									 or customer_id is null
									 or customer_id  like '%[a-z,A-Z]%'
								then null
								else t.customer_id
							end customer_id,
							case
								when lower(trim(t.order_status))in ('canceled','cancelled') then 'Cancelled'
								when lower(trim(t.order_status))in ('pending','in progress') then  'In Progress'
								when lower(trim(t.order_status))in ('complete','completed') then  'Completed'
								when lower(trim(t.order_status))in ('return','returned') then	'Returned'
								when lower(trim(t.order_status))in ('shiped','shipped') then 'Shipped'
								else 'N/A'
							end order_status,
							case 
								when replace(replace(trim(t.sales_channel),char(13),''),char(10),'') in ('App','Mobile  App','Mobile App','Online','Online','Website') then 'Website'
								when replace(replace(trim(t.sales_channel),char(13),''),char(10),'') in ('In-Store','Market Place','Marketplace','wtore','Store','Store') then 'In-Store'
								else 'N/A'
							end sales_channel
							from 
							(
								select 
								*,
								ROW_NUMBER() over (partition by order_id order by order_status ) rank
								from bronze.orders
							) t
							where t.order_id is not null 
							and t.rank = 1
							and try_convert(date,replace(replace(trim(t.order_date),char(13),''),char(10),''),23) between '20240101' and '20251231'
							and t.customer_id in (select customer_id from Silver.customers)
						)




truncate table silver.order_lines

insert into silver.order_lines	(	
									order_line_id,
									order_id,
									product_id,
									quantity,
									unit_price,
									discount_pct
								)

								(
									select 
									t.order_line_id,
									t.order_id,
									t.product_id,
									trim(t.quantity) as quantity,
									trim(t.unit_price) as unit_price, 
									trim(replace(replace(t.discount_pct,char(13),''),char(10),'')) as discount_pct
									from (	
										select 
										*,
										row_number() over (partition by order_line_id order by quantity) as rank
										from bronze.order_lines	
									)t
									where t.rank = 1 
									and order_id in (select order_id from silver.orders) 
									and product_id in (select product_id from silver.products)
									and product_id is not null
									and order_id  is not null
									and t.quantity is not null 
									and t.quantity ! = 0
									and trim(replace(replace(t.quantity,char(13),''),char(10),''))  not like '%[^0-9]%'
									and t.unit_price is not null 
									and trim(replace(replace(t.unit_price,char(13),''),char(10),''))  not like '%[^0-9]%'
									and trim(t.unit_price) =   t.unit_price
									and trim(replace(replace(t.discount_pct,char(13),''),char(10),''))  not like '%[^0-9]%'

								)






   
truncate table silver.payments

insert into Silver.payments (
								payment_id,
								order_id,
								payment_method,
								payment_status,
								payment_date,
								payment_reference
							)

							(					
									select 
									t.payment_id,
									t.order_id,
									case 
										when trim(t.payment_method) in ('DC','Debit Card')  then 'Debit Card'
										when trim(t.payment_method) in ('Net Banking','NetBanking','UPI') then 'UPI'
										when trim(t.payment_method) in ('Cash on Delivery','COD') then 'Cash on Delivery'
										when trim(t.payment_method) in ('CC','Credit Card','Credit  Card') then 'Credit Card'
										else 'N/A'
									end payment_method,
									case 
										when trim(t.payment_status) in ('Paid','Success') then 'Successfull'
										when trim(t.payment_status) in ('Pending') then 'Pending'
										when trim(t.payment_status) in ('Fail','Failed') then 'Failed'
										when trim(t.payment_status) in ('Refunded','Refund') then 'Refunded'
										else 'N/A'
									end payment_status,
									try_convert(date,trim(replace(replace(t.payment_date,char(13),''),char(10),'')),23) as payment_date,
									case 
										when  trim(replace(replace(t.payment_reference,char(13),''),char(10),'')) = '' then 'N/A'
										else trim(t.payment_reference)
									end payment_reference
									from 
									(
										select 
										*,
										row_number() over(partition by payment_id order by payment_date) rank,
										ROW_NUMBER() over (partition by order_id order by payment_id desc) rank2
										from bronze.payments
									)t
									where t.rank = 1 
									and t.rank2 = 1
									and t.payment_id is not null
									and try_convert(date,trim(replace(replace(t.payment_date,char(13),''),char(10),'')),23) between  '20240101' and '20260105' 
									and order_id in (select order_id from Silver.orders)
							);


 end try
 begin catch
 print'-----------------------ERROR----------------------'

 end catch






 go
 
  exec Silver_load
