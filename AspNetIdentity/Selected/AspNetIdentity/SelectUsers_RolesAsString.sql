
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
	,RolesName = STUFF ((select '; ' + CAST( US.NameRole as nvarchar(max)) from @UsersRoles US where users.Id = US.ID_User FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(max)'), 1, 1, '')

	FROM [ASPnetIdentity].[dbo].[AspNetUsers] USERS