--========================================================================================================================================================================================
                                                                                --- Project Intilisation ----
--========================================================================================================================================================================================
-- This is starting of Datawarehouse [Datawarehouse]
--Creating DB Datawarehouse while droping any existing Datawarehouse
--Creating Schema [bronze,silver,gold]
--Database [Datawarehouse] 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
use master 

go

if exists (select 1 from sys.databases where name = 'Datawarehouse')
begin
	alter database Datawarehouse set single_user with rollback immediate
	drop database Datawarehouse
end


go 

create database Datawarehouse 

go 

use Datawarehouse;


go
create schema bronze 
go 
create schema silver
go 
create schema gold
