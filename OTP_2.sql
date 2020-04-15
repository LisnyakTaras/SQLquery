USE PackOTP
GO

Create table [STATUS]
(	
	ID INT IDENTITY PRIMARY KEY,
	STATUS_NAME NVARCHAR(255),
)
go
--drop table [STATUS]

--IDENTITY(1,1)
--������� ��� ������ �� ����� �������.
Create table ACTIVEBOOK
(
	DATE_OPERATION NVARCHAR(255),
	ID INT PRIMARY KEY,
	SN_AB NVARCHAR(255),
	NAME_HMA NVARCHAR(255),
	INVENTORY NVARCHAR(255),
	ACTIVE_NOMBER NVARCHAR(255),
	CFO NVARCHAR(255),
	OPERATION_TERM NVARCHAR(255),
	COST_HMA REAL
)
go

--������� ��� ������ �� �������� �����������, ������ �������� ���.����������������.
CREATE TABLE dbo.LOCATION
	(
	ID INT IDENTITY PRIMARY KEY,
	NAME_LOCATION nvarchar(255),
	City nvarchar(255),
	ADRESS_LOCATION nvarchar(255),
	)

--������� ��� ������ �� ActiveDirectory �� ������.
Create table ADcompList
(
	CompName NVARCHAR(255),
	Office NVARCHAR(255),
	ID INT IDENTITY PRIMARY KEY
)
go


--�� ����� ������� ������ ��� �� ��� ����������� �������, ������ ������ ����������.
/*CREATE TRIGGER ADcomplist_INSERT ON dbo.ADcomplist
INSTEAD OF INSERT
AS
    DELETE FROM PackOTP.dbo.ADcomplist
GO*/
--drop trigger ADcomplist_INSERT



--������� ��� ������ �� ����, ������ �������� ���.����������������.
CREATE TABLE USERPLACEs
(
	ID INT IDENTITY PRIMARY KEY,
	ID_LOCATION INT NOT NULL,
	[IP] NVARCHAR(255),
	COMP NVARCHAR(255) NOT NULL,
	INV_SYSBLOCK NVARCHAR(255),
	INV_MONITOR NVARCHAR(255),
	INV_PRINTER NVARCHAR(255),
	INV_UPS NVARCHAR(255),
	INV_SCANNER NVARCHAR(255),
	USER_PHONE NVARCHAR(255),
	USER_ROOM NVARCHAR(255),
	DATA_MODIFY smalldatetime,
	WRITER NVARCHAR(255),
	COMMENTS NVARCHAR(255)
	)
GO
ALTER TABLE USERPLACEs
ADD CONSTRAINT FK_USERPLACEs_LOCATION
FOREIGN KEY (ID_LOCATION) REFERENCES LOCATION(ID)
GO

--������� ��� ������ �� ����(�������), ������ �������� ������������� ���������: USERPLACEs_INSERT, USERPLACEs_EDITs, USERPLACEs_DELITE. ������ ��� ����!!!!
CREATE TABLE USERPLACEs_History
(
	ID INT IDENTITY PRIMARY KEY,
	ID_STATUS INT NOT NULL,
	ID_LOCATION INT NOT NULL,
	ID_USRPLACEs INT NOT NULL,
	[IP] NVARCHAR(255),
	COMP NVARCHAR(255),
	INV_SYSBLOCK NVARCHAR(255),
	INV_MONITOR NVARCHAR(255),
	INV_PRINTER NVARCHAR(255),
	INV_UPS NVARCHAR(255),
	INV_SCANNER NVARCHAR(255),
	USER_LOGIN NVARCHAR(255),
	USER_ROOM NVARCHAR(255),
	DATA_MODIFY smalldatetime,
	WRITER NVARCHAR(255),
	COMMENTS NVARCHAR(255)
	)
GO

ALTER TABLE USERPLACEs_History
ADD CONSTRAINT FK_USERPLACEs_History_ID_STATUS
FOREIGN KEY (ID_STATUS) REFERENCES [STATUS](ID)
GO

ALTER TABLE USERPLACEs_History
ADD CONSTRAINT FK_USERPLACEs_History_LOCATION
FOREIGN KEY (ID_LOCATION) REFERENCES LOCATION(ID)
GO

BEGIN /* �������� �������� ��� ������� USERPLACEs*/

	--������ ��� ��������������
	CREATE TRIGGER USERPLACEs_EDITs ON dbo.USERPLACEs
	for update
	AS
		INSERT INTO PackOTP.dbo.USERPLACEs_History
		(ID_STATUS ,ID_LOCATION,	ID_USRPLACEs ,	[IP] ,	COMP ,	INV_SYSBLOCK,	INV_MONITOR,	INV_PRINTER ,	INV_UPS,	INV_SCANNER,	USER_LOGIN,	USER_ROOM,	DATA_MODIFY,WRITER,	COMMENTS)
		SELECT
		'1',ID_LOCATION, ID, [IP] ,	COMP ,	INV_SYSBLOCK, INV_MONITOR, INV_PRINTER , INV_UPS, INV_SCANNER, USER_PHONE, USER_ROOM,	DATA_MODIFY, WRITER,	COMMENTS
		FROM inserted
	

	--������ ��� ������ ���������� ������
	CREATE TRIGGER USERPLACEs_INSERT ON dbo.USERPLACEs
	for INSERT
	AS
		INSERT INTO PackOTP.dbo.USERPLACEs_History
		(ID_STATUS ,ID_LOCATION,	ID_USRPLACEs ,	[IP] ,	COMP ,	INV_SYSBLOCK,	INV_MONITOR,	INV_PRINTER ,	INV_UPS,	INV_SCANNER,	USER_LOGIN,	USER_ROOM,	DATA_MODIFY,WRITER,	COMMENTS)
		SELECT
		'3',ID_LOCATION, ID, [IP] ,	COMP ,INV_SYSBLOCK, INV_MONITOR, INV_PRINTER , INV_UPS, INV_SCANNER, USER_PHONE, USER_ROOM,	DATA_MODIFY, WRITER,	COMMENTS
		FROM inserted



	--������ ��� ��������
	CREATE TRIGGER USERPLACEs_DELITE ON dbo.USERPLACEs
	for DELETE
	AS
		INSERT INTO PackOTP.dbo.USERPLACEs_History
		(ID_STATUS ,ID_LOCATION,	ID_USRPLACEs ,	[IP] ,	COMP ,	INV_SYSBLOCK,	INV_MONITOR,	INV_PRINTER ,	INV_UPS,	INV_SCANNER,	USER_LOGIN,	USER_ROOM,	DATA_MODIFY,WRITER,	COMMENTS)
		SELECT
		'2',ID_LOCATION, ID, [IP] ,	COMP ,INV_SYSBLOCK, INV_MONITOR, INV_PRINTER , INV_UPS, INV_SCANNER, USER_PHONE, USER_ROOM,DATA_MODIFY, WRITER,COMMENTS
		FROM deleted

END

-- �������� �������
--drop trigger USERPLACEs_EDIT
GO

USE PackOTP
GO

--������� ��� ������ �� ����������� ���.������, ������ �������� ���.����������������.
CREATE TABLE dbo.SYSBLOCKTEST
	(
	ID INT IDENTITY PRIMARY KEY,
	ID_USERPLASE INT NOT NULL,
	COMP nvarchar(255) NOT NULL,
	[MB SN] nvarchar(255) NULL,
	HDDNAME nvarchar(255) NULL,
	[HDD_SN] nvarchar(255) NULL,
	HDDSMART nvarchar(255) NULL,
	HDD200MS int NULL,
	HDD500MS int NULL,
	HDDBAD int NULL,
	RAMTEST nvarchar(255) NULL,
	STRESSTEST nvarchar(255) NULL,
	COMMENTS nvarchar(255) NULL,
	[DATA_TEST] smalldatetime NOT NULL,
	ADMIN_NAME NVARCHAR(255) NOT NULL
	) 
GO
ALTER TABLE SYSBLOCKTEST
ADD CONSTRAINT FK_SYSBLOCKTEST_USERPLACE
FOREIGN KEY (ID_USERPLASE) REFERENCES USERPLACEs(ID)
	ON DELETE  CASCADE --���� �������� ������ �� USERPLACEs, �� � �������� ��� ������ ������ �������� � ������ USERPLACEs
GO






USE PackOTP
GO

-- �������� ������� ������!!!
/*
ALTER TABLE SYSBLOCKTEST
DROP CONSTRAINT FK_SYSBLOCKTEST_USERPLACE

ALTER TABLE UPSs
DROP CONSTRAINT FK_UPSs_USERPLACE

ALTER TABLE SCANNERS
DROP CONSTRAINT FK_SCANNERS_USERPLACE

ALTER TABLE PRINTERS
DROP CONSTRAINT FK_PRINTERS_USERPLACE

ALTER TABLE MONITORS
DROP CONSTRAINT FK_MONITORS_USERPLACE



/*
-- ������� ��� ������� ������ �� �������.
CREATE TABLE dbo.MONITORS
	(
	ID INT IDENTITY PRIMARY KEY,
	ID_USERPLACE INT,
	COMP nvarchar(255),
	MONITOR_NAME nvarchar(255),
	MONITOR_SN nvarchar(255),
	INVENTORY nvarchar(255),
	CHANGE_TIME NVARCHAR(255),
	CHANGE_ADMIN nvarchar(255),
	COMMENTS nvarchar(255)
	) 

ALTER TABLE MONITORS
ADD CONSTRAINT FK_MONITORS_USERPLACE
FOREIGN KEY (ID_USERPLACE) REFERENCES USERPLACEs(ID)
	ON DELETE SET NULL 
GO

CREATE TABLE dbo.PRINTERS
	(
	ID INT IDENTITY PRIMARY KEY,
	ID_USERPLACE INT,
	[IP] sql_variant,
	COMP nvarchar(255),
	PRINTER_NAME nvarchar(255),
	PRINTER_SN nvarchar(255),
	INVENTORY nvarchar(255),
	CHANGE_TIME NVARCHAR(255),
	CHANGE_ADMIN nvarchar(255),
	COMMENTS nvarchar(255),
	) 
ALTER TABLE PRINTERS
ADD CONSTRAINT FK_PRINTERS_USERPLACE
FOREIGN KEY (ID_USERPLACE) REFERENCES USERPLACEs(ID)
	ON DELETE SET NULL 
GO

CREATE TABLE dbo.SCANNERS
	(
	ID INT IDENTITY PRIMARY KEY,
	ID_USERPLACE INT,
	COMP nvarchar(255),
	SCANNER_NAME nvarchar(255),
	SCANNER_SN nvarchar(255),
	INVENTORY nvarchar(255),
	CHANGE_TIME NVARCHAR(255),
	CHANGE_ADMIN nvarchar(255),
	COMMENTS nvarchar(255)
	) 

ALTER TABLE SCANNERS
ADD CONSTRAINT FK_SCANNERS_USERPLACE
FOREIGN KEY (ID_USERPLACE) REFERENCES USERPLACEs(ID)
	ON DELETE SET NULL 
GO

CREATE TABLE dbo.UPSs
	(
	ID INT IDENTITY PRIMARY KEY,
	ID_USERPLACE INT,
	COMP nvarchar(255),
	UPS_NAME nvarchar(255),
	UPS_SN nvarchar(255),
	INVENTORY nvarchar(255),
	CHANGE_TIME NVARCHAR(255),
	CHANGE_ADMIN nvarchar(255),
	COMMENTS nvarchar(255),
	)

ALTER TABLE UPSs
ADD CONSTRAINT FK_UPSs_USERPLACE
FOREIGN KEY (ID_USERPLACE) REFERENCES USERPLACEs(ID)
	ON DELETE SET NULL 
GO
*/