USE [ASPnetIdentity]
GO

if OBJECT_ID ('AspNetUsers_UserDelete') IS NOT NULL
BEGIN 
	DROP PROC AspNetUsers_UserDelete
END

GO

CREATE PROC AspNetUsers_UserDelete
	@ID_User 		nvarchar(128)
	AS
BEGIN
	DELETE AspNetUsers
	WHERE  Id = @ID_User
END


--Смотрим имена колонок и их тип в таблицах AspNetUsers, AspNetUserRoles, AspNetRoles
USE [ASPnetIdentity]

SELECT COLUMN_NAME AS CN_AspNetUsers, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetUsers'
GO