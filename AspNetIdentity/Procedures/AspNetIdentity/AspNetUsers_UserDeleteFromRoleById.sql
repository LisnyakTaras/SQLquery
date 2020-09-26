USE [ASPnetIdentity]
GO

if OBJECT_ID ('AspNetUsers_UserDeleteFromRoleById') IS NOT NULL
BEGIN 
	DROP PROC AspNetUsers_UserDeleteFromRoleById
END

GO

CREATE PROC AspNetUsers_UserDeleteFromRoleById
	@ID_User 		nvarchar(128)
    ,@ID_Role         nvarchar(128)
	AS
BEGIN
	DELETE AspNetUserRoles
	WHERE UserId = @ID_User AND RoleId = @ID_Role
END


--Смотрим имена колонок и их тип в таблицах AspNetUsers, AspNetUserRoles, AspNetRoles
USE [ASPnetIdentity]

SELECT COLUMN_NAME AS CN_AspNetUsers, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetUserRoles'
GO