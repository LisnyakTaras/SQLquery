USE [ASPnetIdentity]
GO

if OBJECT_ID ('AspNetRole_NewRole') IS NOT NULL
BEGIN 
	DROP PROC AspNetRole_NewRole
END

GO

CREATE PROC AspNetRole_NewRole
	@RoleName 		nvarchar(256)
	AS
BEGIN
	INSERT INTO AspNetRoles
		(id, [Name])
	VALUES
		(NEWID(), @RoleName);
END


--����ਬ ����� ������� � �� ⨯ � ⠡���� AspNetUsers, AspNetUserRoles, AspNetRoles
USE [ASPnetIdentity]

SELECT COLUMN_NAME AS CN_AspNetUsers, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetRoles'
GO