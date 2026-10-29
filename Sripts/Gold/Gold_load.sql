
go

drop view if exists gold.customers
go
create view gold.Customers as

select 
c.customer_id,
c.customer_name,
c.email,
c.phone,
c.signup_date,
c.location_id,
l.locality,
l.city,
l.state,
l.region
from Silver.customers as c
left join Silver.locations as l
on c.location_id = l.location_id;



go




drop view if exists gold.orders
go
create view gold.orders as
select 
o.order_id,
o.order_date,
o.customer_id,
o.order_status,
o.sales_channel,
p.payment_id,
p.payment_method,
p.payment_date,
p.payment_status,
P.payment_reference
from Silver.orders as o
left join Silver.payments as p
on o.order_id = p.order_id;


go


drop view if exists gold.order_lines
go
create view gold.order_lines as
select 
o.order_line_id,
o.order_id,
o.product_id,
o.quantity,
o.unit_price,
o.discount_pct,
p.product_name,
p.category,
p.brand,
o.quantity * (o.unit_price-(o.unit_price*o.discount_pct/100)) as Amount
from Silver.order_lines as o
left join  Silver.products as p
on o.product_id = p.product_id;

go

drop view if exists gold.products
go
create view gold.products as
select * from Silver.products ;

go

drop view if exists gold.locations
go
create view gold.locations as
select * from Silver.locations

