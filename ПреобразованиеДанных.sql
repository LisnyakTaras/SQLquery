USE PackOTP
GO

CREATE TABLE dbo.EQUIPMENTS
	(
	ID INT IDENTITY PRIMARY KEY,
	ID_TYPE INT not null,
	NAME_EQ nvarchar(MAX),
	SN_EQ nvarchar(MAX),
	DATE_OF_MANUFACTURE INT,
	INVENTORY nvarchar(MAX),
	CHANGE_TIME NVARCHAR(MAX),
	CHANGE_ADMIN nvarchar(MAX),
	COMMENTS nvarchar(MAX),
	) 
GO
ALTER TABLE EQUIPMENTS
ADD CONSTRAINT FK_EQUIPMENTS_EQUIPMENT_TYPE
FOREIGN KEY (ID_TYPE) REFERENCES EQUIPMENT_TYPE(ID)
GO


CREATE TABLE dbo.EQUIPMENT_TYPE
	(
	ID INT IDENTITY PRIMARY KEY,
	NAME_TYPE nvarchar(MAX),
	)
GO
CREATE TABLE USERPLACEs
(
	ID INT IDENTITY PRIMARY KEY,
	[IP] NVARCHAR(MAX),
	COMP NVARCHAR(MAX),
	INV_SYSBLOCK NVARCHAR(MAX),
	INV_MONITOR NVARCHAR(MAX),
	INV_PRINTER NVARCHAR(MAX),
	INV_UPS NVARCHAR(MAX),
	INV_SCANNER NVARCHAR(MAX),
	USER_LOGIN NVARCHAR(MAX),
	[USER_NAME] NVARCHAR(MAX),
	USER_PHONE NVARCHAR(MAX),
	USER_ROOM NVARCHAR(MAX),
	DATA_MODIFY NVARCHAR(MAX),
	WRITER NVARCHAR(MAX),
	COMMENTS NVARCHAR(MAX)
	)
GO

-- ������� � �������������� ������ �� ������� - USER_NAME
SELECT CAST(USER_NAME AS NVARCHAR(MAX)) 
FROM dbo.USERPLACE 

-- �������������� ���� ������ ������� � ������ ��� (�� �������� � sql_variant)
ALTER TABLE USERPLACE 
ALTER COLUMN USER_NAME NVARCHAR(200)


-- (������� ������� �������)������� ������ � ������ �������, � ��������������� ����������� ������� � ������ ������� ������� - [IP]!!!
INSERT INTO PRINTERS ( ID_USERPLACE, [IP], COMP, PRINTER_NAME, PRINTER_SN, INVENTORY, CHANGE_TIME, CHANGE_ADMIN, COMMENTS)
SELECT ID_USERPLACE, CAST([IP] AS NVARCHAR(MAX)), COMP, PRINTER_NAME, PRINTER_SN, INVENTORY, CHANGE_TIME, CHANGE_ADMIN, COMMENTS
  FROM scriptPRINTERS

  ---- (������� ������� �������)������� ������ � ������ �������, � ��������������� ����������� �������!!!
  INSERT INTO USERPLACEs ([IP] , COMP, INV_SYSBLOCK, INV_MONITOR, INV_PRINTER, INV_UPS, INV_SCANNER, USER_PHONE, USER_ROOM, DATA_MODIFY, WRITER, COMMENTS)
SELECT [IP] , COMP, INV_SYSBLOCK, INV_MONITOR, INV_PRINTER, INV_UPS, INV_SCANNER, USER_LOGIN, CAST(USER_NAME AS NVARCHAR(MAX)),  CAST(USER_PHONE AS NVARCHAR(MAX)),  CAST(USER_ROOM AS NVARCHAR(MAX)), DATA_MODIFY, WRITER, COMMENTS
  FROM scriptUSERPLACEs



  DECLARE @MyCounter int;
  set @MyCounter = 1;
   DECLARE @Date int;
  set @Date = null;

    ---- (������� ������� �������)������� ������ � ������ �������, � ��������������� ����������� �������!!!
  INSERT INTO EQUIPMENTS (ID_TYPE,NAME_EQ,SN_EQ,INVENTORY,DATE_OF_MANUFACTURE,CHANGE_TIME,CHANGE_ADMIN ,COMMENTS)
SELECT  @MyCounter, PRINTER_NAME, PRINTER_SN, INVENTORY,@Date, CHANGE_TIME, CHANGE_ADMIN, COMMENTS
  FROM PRINTERS


  
  DECLARE @MyCounter int;
  set @MyCounter = 2;
   DECLARE @Date int;
  set @Date = null;

    ---- (������� ������� �������)������� ������ � ������ �������, � ��������������� ����������� �������!!!
  INSERT INTO EQUIPMENTS (ID_TYPE,NAME_EQ,SN_EQ,INVENTORY,DATE_OF_MANUFACTURE,CHANGE_TIME,CHANGE_ADMIN ,COMMENTS)
SELECT  @MyCounter , SCANNER_NAME, SCANNER_SN, INVENTORY,@Date, CHANGE_TIME, CHANGE_ADMIN, COMMENTS
  FROM SCANNERS

    DECLARE @MyCounter int;
  set @MyCounter = 3;
   DECLARE @Date int;
  set @Date = null;

    ---- (������� ������� �������)������� ������ � ������ �������, � ��������������� ����������� �������!!!
  INSERT INTO EQUIPMENTS (ID_TYPE,NAME_EQ,SN_EQ,INVENTORY,DATE_OF_MANUFACTURE,CHANGE_TIME,CHANGE_ADMIN ,COMMENTS)
SELECT  @MyCounter , MONITOR_NAME, MONITOR_SN, INVENTORY,@Date, CHANGE_TIME, CHANGE_ADMIN, COMMENTS
  FROM MONITORS


      DECLARE @MyCounter int;
  set @MyCounter = 4;
   DECLARE @Date int;
  set @Date = null;

    ---- (������� ������� �������)������� ������ � ������ �������, � ��������������� ����������� �������!!!
  INSERT INTO EQUIPMENTS (ID_TYPE,NAME_EQ,SN_EQ,INVENTORY,DATE_OF_MANUFACTURE,CHANGE_TIME,CHANGE_ADMIN ,COMMENTS)
SELECT  @MyCounter , UPS_NAME, UPS_SN, INVENTORY,@Date, CHANGE_TIME, CHANGE_ADMIN, COMMENTS
  FROM UPSs

  -- �������� ����� ������� ��������!
  DELETE FROM table WHERE edit_user IS NULL;
  DELETE FROM EQUIPMENTS WHERE NAME_EQ like '���';