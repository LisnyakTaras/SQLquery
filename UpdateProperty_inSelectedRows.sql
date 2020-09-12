Create table tbl_User
(
	ID INT IDENTITY(0,1) PRIMARY KEY,
	[Name] nvarchar(255),
)
go

INSERT INTO tbl_User 
([Name])
VALUES
('Max'),
('Taras'),
('Roman'),
('Sergey'),
('Oleg');
GO

Create table tbl_UserTrans
(
	ID INT IDENTITY(0,1) PRIMARY KEY,
	ID_User int,
	Payment int,
	DatePayment datetime
)
ALTER TABLE tbl_UserTrans
ADD CONSTRAINT FK_tbl_UserTrans_tbl_User
FOREIGN KEY (ID_User) REFERENCES tbl_User(ID)
go





INSERT INTO tbl_UserTrans 
(ID_User,Payment, DatePayment)
VALUES
(0,250,GETDATE()),
(1,50,GETDATE()),
(2,450,GETDATE()),
(3,750,GETDATE()),
(4,350,GETDATE());
GO

INSERT INTO tbl_UserTrans 
(ID_User,Payment, DatePayment)
VALUES
(0,150,GETDATE()),
(1,250,GETDATE()),
(2,50,GETDATE()),
(3,20,GETDATE()),
(4,25,GETDATE());
GO


--Проверяем все записи в таблице tbl_UserTrans
select * from tbl_UserTrans

-- одни способ получить поледние записи по уникальному юзеру
SELECT  ID_User, max(DatePayment) as lastDate
FROM tbl_UserTrans
GROUP BY ID_User

--второй способ получить поледние записи по уникальному юзеру
select *
from tbl_UserTrans AS A
where DatePayment = (
    SELECT MAX(DatePayment)
    FROM tbl_UserTrans AS b
    WHERE a.ID_User = b.ID_User   
)

-- обновляем поле "Payment" по полседним записям для каждого юзера
update tbl_UserTrans
set Payment = 100
from
(select *
from tbl_UserTrans AS A
where DatePayment = (
    SELECT min(DatePayment)
    FROM tbl_UserTrans AS b
    WHERE a.ID_User = b.ID_User   
)) as Selected
where tbl_UserTrans.ID = Selected.ID



MERGE INTO tbl_UserTrans AS UserTrans
   USING (select * 
		from tbl_UserTrans AS A
		where DatePayment = (
			SELECT MAX(DatePayment)
			FROM tbl_UserTrans AS b
			WHERE a.ID_User = b.ID_User   
		)) Selected
   ON UserTrans.ID = Selected.ID
WHEN MATCHED THEN
   UPDATE 
  	SET UserTrans.Payment = 500;




BEGIN TRANSACTION ChangeUsersRow;
UPDATE Users
SET Title = 'FrontEnd', timeTransaction = GETDATE()
WHERE [Name] = 'Max'
COMMIT TRANSACTION;

BEGIN TRANSACTION ChangeUsersRow;
UPDATE Users
SET Title = 'SqlDev', timeTransaction = GETDATE()
WHERE [Name] = 'Max'
COMMIT TRANSACTION;

------------------------------
BEGIN TRANSACTION ChangeUsersRow;
UPDATE Users
SET Title = 'SqlDev', timeTransaction = GETDATE()
WHERE [Name] = 'Taras'
COMMIT TRANSACTION;


BEGIN TRANSACTION ChangeUsersRow;
UPDATE Users
SET Title = 'DevOps', timeTransaction = GETDATE()
WHERE [Name] = 'Taras'
COMMIT TRANSACTION;
--------------------------------

BEGIN TRANSACTION ChangeUsersRow;
UPDATE Users
SET Title = 'FrontEnd', timeTransaction = GETDATE()
WHERE [Name] = 'Roman'
COMMIT TRANSACTION;


BEGIN TRANSACTION ChangeUsersRow;
UPDATE Users
SET Title = 'DevOps', timeTransaction = GETDATE()
WHERE [Name] = 'Roman'
COMMIT TRANSACTION;
------------------------------------

BEGIN TRANSACTION ChangeUsersRow;
UPDATE Users
SET Title = 'FrontEnd', timeTransaction = GETDATE()
WHERE [Name] = 'Sergey'
COMMIT TRANSACTION;


BEGIN TRANSACTION ChangeUsersRow;
UPDATE Users
SET Title = 'WebDev', timeTransaction = GETDATE()
WHERE [Name] = 'Sergey'
COMMIT TRANSACTION;

-------------------------

BEGIN TRANSACTION ChangeUsersRow;
UPDATE Users
SET Title = 'Tester', timeTransaction = GETDATE()
WHERE [Name] = 'Oleg'
COMMIT TRANSACTION;


BEGIN TRANSACTION ChangeUsersRow;
UPDATE Users
SET Title = 'WebDev', timeTransaction = GETDATE()
WHERE [Name] = 'Oleg'
COMMIT TRANSACTION;

select * from Users



SELECT
  [Slot ID],
  [Transaction ID],
  [End Time] = (select  [End Time] from  sys.fn_dblog(NULL,NULL)as LOP_COMMIT WHERE Operation IN ('LOP_COMMIT_XACT' ) and LOP_MODIFY.[Transaction ID] = LOP_COMMIT.[Transaction ID] )
FROM sys.fn_dblog(NULL,NULL) as LOP_MODIFY
WHERE Operation IN 
   ('LOP_MODIFY_ROW')
	and AllocUnitName = 'dbo.Users.PK__Users__3214EC27C07BD835'

SELECT 
  [Slot ID],
  [Transaction ID],
  [End Time]
  FROM sys.fn_dblog(NULL,NULL) as LOP_MODIFY
WHERE Operation IN 
   ('LOP_MODIFY_ROW')
