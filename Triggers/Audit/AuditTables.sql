use uManageDBLogs
create table dbo.tbl_AuditBatch(
	AuditBatchId int identity,
	[Type]	char(1),
	TableName	varchar(128),
	AppUserName	varchar(255),
	AppName		varchar(128),
	HostName	varchar(255),
	EventInfo	nvarchar(4000),
	AuditDate	smalldatetime
)
GO

ALTER TABLE dbo.tbl_AuditBatch
   ADD CONSTRAINT PK_tbl_AuditBatch PRIMARY KEY CLUSTERED (AuditBatchId);
GO

use uManageDBLogs
create table dbo.tbl_AuditBatchDetails(
	AuditId	int identity,
	AuditBatchId int,
	PK	varchar(1000),
	FieldName	varchar(128),
	OldValue	varchar(1000),
	NewValue	varchar(1000),
	UserName	varchar(128),
	PKId	int
)
GO

ALTER TABLE dbo.tbl_AuditBatchDetails
   ADD CONSTRAINT PK_tbl_AuditBatchDetails PRIMARY KEY CLUSTERED (AuditId);
GO

ALTER TABLE dbo.tbl_AuditBatchDetails
   ADD CONSTRAINT FK_tbl_AuditBatchDetails_tbl_AuditBatch FOREIGN KEY (AuditBatchId)
   REFERENCES  dbo.tbl_AuditBatch(AuditBatchId);
GO