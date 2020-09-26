USE [ASPnetIdentity]
GO

if OBJECT_ID ('AspNetRole_NewRole') IS NOT NULL
BEGIN 
	DROP PROC AspNetRole_NewRole
END

GO

CREATE PROC AspNetRole_NewRole
	@RoleName 		nvarchar(256)
	,@Description 	NVARCHAR(256)
	AS
BEGIN
	INSERT INTO AspNetRoles
		(id, [Name], [Description])
	VALUES
		(NEWID(), @RoleName, @Description);
END


--Смотрим имена колонок и их тип в таблицах AspNetUsers, AspNetUserRoles, AspNetRoles
USE [ASPnetIdentity]

SELECT COLUMN_NAME AS CN_AspNetUsers, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetRoles'
GO