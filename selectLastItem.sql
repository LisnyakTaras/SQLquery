/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [ID]
      ,[Action_Name]
      ,[Controller_Name]
      ,[User_Login]
      ,[Action_Date]
      ,[Action_WorkAtServer]
  FROM [SiteData].[dbo].[Visitors]
  order by ID DESC