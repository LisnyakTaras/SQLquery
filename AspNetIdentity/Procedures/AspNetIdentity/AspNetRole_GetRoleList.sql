USE [ASPnetIdentity]
GO

if OBJECT_ID ('AspNetRole_GetRoleList') IS NOT NULL
BEGIN 
	DROP PROC AspNetRole_GetRoleList
END
GO

CREATE PROC AspNetRole_GetRoleList
AS
	BEGIN
	SELECT 
     Roles.ID
    ,Roles.[Name]
    ,Roles.[Description]

	FROM [ASPnetIdentity].[dbo].[AspNetRoles] Roles
END


USE [ASPnetIdentity]
exec AspNetRole_GetRoleList


USE [ASPnetIdentity]
go
SELECT COLUMN_NAME AS CN_AspNetUsers
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetRoles'