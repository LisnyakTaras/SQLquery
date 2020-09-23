USE [ASPnetIdentity]
GO

if OBJECT_ID ('AspNetUsers_UserAddToRole') IS NOT NULL
BEGIN 
	DROP PROC AspNetUsers_UserAddToRole
END

GO

CREATE PROC AspNetUsers_UserAddToRole
    @RoleName         nvarchar(256)
	AS
	BEGIN
	SELECT USERS.ID,USERS.[UserName],ROLES.[ID] ,ROLES.[Name]

	FROM [ASPnetIdentity].[dbo].[AspNetUsers] USERS
	INNER JOIN [ASPnetIdentity].[dbo].[AspNetUserRoles] UserRoles ON USERS.ID = UserRoles.UserId
	INNER JOIN [ASPnetIdentity].[dbo].AspNetRoles ROLES ON UserRoles.RoleId = ROLES.Id
END