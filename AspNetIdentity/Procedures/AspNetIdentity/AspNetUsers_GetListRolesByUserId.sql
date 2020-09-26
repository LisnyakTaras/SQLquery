USE [ASPnetIdentity]
GO

if OBJECT_ID ('AspNetUsers_GetListRolesByUserId') IS NOT NULL
BEGIN 
	DROP PROC AspNetUsers_GetListRolesByUserId
END

GO

CREATE PROC AspNetUsers_GetListRolesByUserId(
    @USERID nvarchar(128)
)
	AS
	BEGIN
	--Содаем временную таблицу для сведения трех таблиц AspNetUsers, AspNetUserRoles, AspNetRoles
	DECLARE @UsersRoles TABLE (ID_User nvarchar(255), Name_User nvarchar(255), NameRole nvarchar(255) )

	--Заносим данные во временную таблицу 
	insert into @UsersRoles
	SELECT USERS.ID, USERS.UserName, ROLES.Name
	from [ASPnetIdentity].[dbo].[AspNetUsers] AS USERS
	LEFT JOIN [ASPnetIdentity].[dbo].[AspNetUserRoles] UserRoles ON USERS.ID = UserRoles.UserId
	LEFT JOIN [ASPnetIdentity].[dbo].AspNetRoles ROLES ON UserRoles.RoleId = ROLES.Id

	--Выбираем данные из таблицы AspNetUsers и временной таблицы @UsersRoles(из которой слаживаем все NameRole в одну ячейку)
	SELECT USERS.ID
	,USERS.[UserName]
	,RolesName = STUFF ((select '; ' + CAST( US.NameRole as nvarchar(255)) from @UsersRoles US where users.Id = US.ID_User FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(max)'), 1, 1, '')

	FROM [ASPnetIdentity].[dbo].[AspNetUsers] USERS
    WHERE USERS.Id = @USERID


END


USE [ASPnetIdentity]
GO
--Выполняем процедуру
exec AspNetUsers_GetListRolesById 

--Смотрим имена колонок и их тип в таблицах AspNetUsers, AspNetUserRoles, AspNetRoles
USE [ASPnetIdentity]
go
SELECT COLUMN_NAME  AS CN_AspNetUsers, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetUsers'
GO
SELECT COLUMN_NAME AS CN_AspNetUsers, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetUserRoles'
GO
SELECT COLUMN_NAME AS CN_AspNetUsers, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'AspNetRoles'
