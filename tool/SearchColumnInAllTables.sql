/****** Script for SelectTopNRows command from SSMS  ******/


  SELECT COLUMN_NAME, TABLE_NAME, TABLE_SCHEMA
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE COLUMN_NAME LIKE '%CurrentLogonUser%' --and TABLE_NAME like 'v_%'