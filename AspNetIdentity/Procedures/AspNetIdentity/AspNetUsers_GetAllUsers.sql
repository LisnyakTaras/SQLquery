USE [ASPnetIdentity]
GO

if OBJECT_ID ('AspNetUsers_GetAllUsers') IS NOT NULL
BEGIN 
	DROP PROC AspNetUsers_GetAllUsers
END

GO

CREATE PROC AspNetUsers_GetAllUsers
	AS
	BEGIN
	SELECT USERS.ID
    ,USERS.[UserName]
    ,USERS.Email
    ,USERS.EmailConfirmed
    ,USERS.PhoneNumber
    ,USERS.PhoneNumberConfirmed
    ,USERS.LockoutEnabled
    ,USERS.TwoFactorEnabled

	FROM [ASPnetIdentity].[dbo].[AspNetUsers] USERS
END

--�믮��塞 ��楤���
exec AspNetUsers_GetAllUsers


--����ਬ ����� ������� � ⠡���� AspNetUsers
USE [ASPnetIdentity]
go
SELECT COLUMN_NAME AS CN_AspNetUsers
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetUsers'