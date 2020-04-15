CREATE DATABASE InterpOrg  
ON							  -- Задаем параметры Базы Данных.
(
	NAME = 'InterpOrg',
	FILENAME = 'C:\DB\InterpOrg.mdf',	
	SIZE = 10MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 10MB				
)
LOG ON						  -- Задаем параметры журнала Базы Данных.
( 
	NAME = 'LogInterOrg',
	FILENAME = 'C:\DB\InterpOrg.ldf', 
	SIZE = 5MB,                  
	MAXSIZE = 50MB,   
	FILEGROWTH = 5MB 
)               
COLLATE Cyrillic_General_CI_AS -- Задаем кодировку для базы данных по умолчанию


USE InterpOrg                
GO  

CREATE TABLE ORG
(
	OrgID int IDENTITY PRIMARY KEY,
	OrgName Varchar(20) NOT NULL ,
	PID int 
    CONSTRAINT AK_OrgName UNIQUE(OrgName)
)
GO 

ALTER TABLE ORG
ADD CONSTRAINT FK_ORG_OrgID
FOREIGN KEY (PID) REFERENCES ORG(OrgID);
GO

CREATE TABLE POST
(
    PostID int IDENTITY PRIMARY KEY,
    PostName NVARCHAR(20) NOT NULL,
    OrgID int NOT NULL
)
GO

ALTER TABLE POST
ADD CONSTRAINT FK_POST_OrgID
FOREIGN KEY (OrgID) REFERENCES ORG(OrgID)
GO

CREATE TABLE USERS
(
    UserID int IDENTITY PRIMARY KEY,
    FIO NVARCHAR (20),
    PostID int NOT NULL
)
GO

ALTER TABLE USERS
ADD CONSTRAINT FK_USERS_PostID
FOREIGN KEY (PostID) REFERENCES Post(PostID)
GO

CREATE TABLE Emps
(
    EmpsID int IDENTITY PRIMARY KEY,
    UserID int NOT NULL,
    OKLAD SMALLMONEY,
)
GO

ALTER TABLE Emps
ADD CONSTRAINT FK_Emps_UsersID
FOREIGN KEY (UserID) REFERENCES USERS(UserID)
GO

INSERT INTO ORG
(OrgName, PID)
VALUES
('НИКО ТЬЮБ', null),
('ТПЦ', 1),
('ТПЦ 2', 1),
('ТПЦ 7', 2),
('ТПЦ 6', 2),
('Обсадный участок', 5);


INSERT INTO POST
([PostName],[OrgID])
VALUES
('Стропальщик', 3),
('Старший Мастер', 2),
('Сортировщик', 2),
('Мастер', 3),
('Сортировщик', 3),
('Мастер', 5);

INSERT INTO POST
([PostName],[OrgID])
VALUES
('Стропальщик', 3),
('Старший Мастер', 2),
('Сортировщик', 2),
('Мастер', 3),
('Сортировщик', 3),
('Мастер', 5);

INSERT INTO USERS
([FIO],[PostID])
VALUES
('Петров', 1),
('Сидоров', 1),
('Иванов', 3),
('Кулемин', 5),
('Сирко', 5),
('Петлюра', 3),
('Злой', 3),
('Мух', 5),
('Чек', 1);

INSERT INTO Emps
([UserID],[OKLAD])
VALUES
(1, 100),
(7, 110),
(3, 300),
(8, 850),
(9, 500),
(6, 130),
(2, 400),
(4, 700),
(5, 700);


SELECT  ORG.OrgName, POST.PostName, USERS.FIO, OKLAD

FROM ORG
JOIN POST on POST.OrgID = ORG.OrgID
JOIN USERS on USERS.PostID = POST.PostID
JOIN Emps on Emps.UserID = USERS.UserID
WHERE OrgName = 'ТПЦ 2'
AND OKLAD = (SELECT MIN(OKLAD) FROM Emps)
GO
2