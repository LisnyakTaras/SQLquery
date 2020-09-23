USE [ASPnetIdentity]
GO

SET ANSI_NULLS ON
GO

if OBJECT_ID ('AspNetUsers_GetListUsersWithRole') IS NOT NULL
BEGIN 
	DROP PROC AspNetUsers_GetListUsersWithRole
END

GO

CREATE PROC AspNetUsers_GetListUsersWithRole
	AS
	BEGIN
	SELECT USERS.ID,USERS.[UserName],ROLES.[ID] ,ROLES.[Name]

	FROM [ASPnetIdentity].[dbo].[AspNetUsers] USERS
	INNER JOIN [ASPnetIdentity].[dbo].[AspNetUserRoles] UserRoles ON USERS.ID = UserRoles.UserId
	INNER JOIN [ASPnetIdentity].[dbo].AspNetRoles ROLES ON UserRoles.RoleId = ROLES.Id
END

--Выполняем процедуру
exec AspNetUsers_GetListUsersWithRole

--Смотрим имена колонок в таблицах AspNetUsers, AspNetUserRoles, AspNetRoles
USE [ASPnetIdentity]
go
SELECT COLUMN_NAME AS CN_AspNetUsers
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetUsers'
GO
SELECT COLUMN_NAME AS CN_AspNetUserRoles
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetUserRoles'
GO
SELECT COLUMN_NAME AS CN_AspNetRoles
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetRoles'
