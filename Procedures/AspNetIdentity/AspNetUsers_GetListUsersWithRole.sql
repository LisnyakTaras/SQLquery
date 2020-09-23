USE [ASPnetIdentity]
GO
/****** Object:  StoredProcedure [dbo].[aspnet_UsersInRoles_IsUserInRole]    Script Date: 9/22/2020 3:43:43 PM ******/
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


exec AspNetUsers_GetListUsersWithRole