USE [AdventureWorks2019]
-- пробовал включить оптимизацию в 2019SQL сервере 
ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = ON;
-- оптимизация ничем не помогла с трегером аудита.

SELECT SERVERPROPERTY('IsTempdbMetadataMemoryOptimized');


-----------------------------------------------------------------------------------------------
USE [AdventureWorks2019]
GO

SELECT *
INTO    [dbo].[SalesOrderDetail_Test]
FROM    [Sales].[SalesOrderDetail]
GO

ALTER TABLE dbo.SalesOrderDetail_Test
   ADD CONSTRAINT PK_SalesOrderDetail_Test PRIMARY KEY CLUSTERED (SalesOrderDetailID);
GO
--exec um_CreateAuditTriggerForTable 'SalesOrderDetail_Test'


USE [AdventureWorks2019]
GO

UPDATE [dbo].[SalesOrderDetail_Test]
   SET [rowguid] = newid()
      ,[ModifiedDate] = getdate()
GO
-------------------------------------------------------------------------------------------------
USE [AdventureWorks2019]
GO

-- пробовал вместо временной таблицы #TMP_COLUMNS по колонкам использовать тип
CREATE TYPE [dbo].umTAuditColumns
	AS TABLE(
	ColumnId int primary key not null,
	AuditBatchId int,
    ColumnName varchar(255),
    ColumnDataType varchar(128),
    isUpdated bit,
    isPK bit,
    isSkip bit)
GO
--DROP TYPE [dbo].[umTAuditColumns]
--GO
-- в данном случае, время выполнения почти в два раза дольше. данный трегер находится в файле AuditTriggerWithTableType.sql

