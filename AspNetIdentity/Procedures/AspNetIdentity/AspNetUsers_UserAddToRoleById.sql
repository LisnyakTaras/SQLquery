USE [ASPnetIdentity]
GO

if OBJECT_ID ('AspNetUsers_UserAddToRoleByID') IS NOT NULL
BEGIN 
	DROP PROC AspNetUsers_UserAddToRoleByID
END

GO

CREATE PROC AspNetUsers_UserAddToRoleByID
	@ID_User 		nvarchar(128)
    ,@ID_Role         nvarchar(128)
	AS
BEGIN
	INSERT INTO AspNetUserRoles
		(UserId, RoleId)
	VALUES
		(@ID_User, @ID_Role);

END


--Смотрим имена колонок и их тип в таблицах AspNetUsers, AspNetUserRoles, AspNetRoles
USE [ASPnetIdentity]

SELECT COLUMN_NAME AS CN_AspNetUsers, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetUserRoles'
GO
