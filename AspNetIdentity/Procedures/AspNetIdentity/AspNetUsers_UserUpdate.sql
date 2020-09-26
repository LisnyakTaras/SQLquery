USE [ASPnetIdentity]
GO

if OBJECT_ID ('AspNetUsers_UserUpdate') IS NOT NULL
BEGIN 
	DROP PROC AspNetUsers_UserUpdate
END

GO

CREATE PROC AspNetUsers_UserUpdate
	@ID_User 		nvarchar(128)
    ,@PhoneNumber   nvarchar(256)
    
	AS
BEGIN
	UPDATE  AspNetUsers
    SET
        PhoneNumber =@PhoneNumber
    WHERE Id = @ID_User

END


--Смотрим имена колонок и их тип в таблицах AspNetUsers, AspNetUserRoles, AspNetRoles
USE [ASPnetIdentity]

SELECT COLUMN_NAME AS CN_AspNetUsers, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetUsers'
GO
