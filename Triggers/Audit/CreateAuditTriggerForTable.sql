use uManageDB
go

exec dbo.um_Start @name = 'um_CreateAuditTriggerForTable'
go
       
create procedure dbo.[um_CreateAuditTriggerForTable]
	             @TableName varchar(128)
as

if (@TableName = '') return;
    
declare @trbody varchar(max)
declare @trName varchar(50)
declare @cr char(2)
select @cr = char(13) + char(10)

select @trName = @TableName + '_Audit'

exec(N'IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(''dbo.' + @trName + ''') ' + @cr
+ 'AND TYPE = ''TR'') ' + @cr
+ 'BEGIN ' + @cr
+ '   PRINT ''DROPPING trigger ' + @trName + '''' + @cr
+ '   DROP trigger ' + @trName + ' '  + @cr
+ 'END ' + @cr
)


select @trbody = 'CREATE TRIGGER dbo.'+@trName+' ON dbo.'+@TableName+' FOR INSERT, UPDATE, DELETE
AS

DECLARE 
	@AuditBatchId INT,
	@Type CHAR(1),
	@AppUserName VARCHAR(128) = suser_sname(),
	@AppName VARCHAR(128) = app_name(),
	@HostName VARCHAR(128) = host_name(),
	@EventInfo NVARCHAR(4000) = ''null'',
	@AuditDate DATETIME = getutcdate(),
	@ColumnsUpdated VARBINARY(max) = COLUMNS_UPDATED(),

	@SkipCols VARCHAR(255) = ''LastVisited, CreateDate, UpdateDate, CreateBy, CreatedBy, LastUpdate, LastUpdatedBy, LastUpdateBy'', --this string 97 symbol length
	@PK NVARCHAR(255)

IF exists (SELECT top 1 1 FROM inserted) 
	BEGIN
		IF exists (SELECT TOP 1 1 FROM deleted)
			SELECT @Type = ''U'' 
	ELSE 
			SELECT @Type = ''I''
	END
ELSE
	BEGIN
		IF exists (SELECT TOP 1 1 FROM deleted)
			SELECT @Type = ''D'' 
		ELSE 
			RETURN
	END
	
DECLARE @dbcc_INPUTBUFFER TABLE(EventType NVARCHAR(30), Parameters INT, EventInfo NVARCHAR(4000))
DECLARE @my_spid VARCHAR(20)  
SET @my_spid = CAST(@@SPID AS VARCHAR(20)) 
INSERT @dbcc_INPUTBUFFER  
EXEC(''DBCC INPUTBUFFER ('' + @my_spid + '') WITH NO_INFOMSGS''); 
SELECT @EventInfo = replace(EventInfo, '''''''', '''''''''''') FROM  @dbcc_INPUTBUFFER

INSERT uManageDBLogs.dbo.tbl_AuditBatch([Type], TableName, AppUserName, AppName, HostName, EventInfo, AuditDate)
		VALUES(@Type, ''' + @TableName + ''', @AppUserName, @AppName, @HostName, @EventInfo, @AuditDate)
		SET @AuditBatchId = @@IDENTITY

BEGIN   ----   SELECT DATA FOR #TMP_COLUMNS WHERE FROM COLUMNSUPDATED DEFINE INPUT PARAMETERS 
	SELECT
		t.ColumnId,
		@AuditBatchId AS AuditBatchId,
		t.ColumnName, 
		t.ColumnDataType, 
		isUpdated = iif(t.ColumnsUpdated is null or SUBSTRING(t.ColumnsUpdated, (t.ColumnId-1)/8+1, 1) & POWER(2,((t.ColumnId-1)%8)) > 0, 1, 0),
		t.isPK,
		t.isSkip
	INTO #tmp_Columns 
	FROM
	(
		SELECT
			ColumnId = columnproperty(OBJECT_ID(c.TABLE_SCHEMA + ''.'' + c.TABLE_NAME), c.COLUMN_NAME, ''ColumnID''),
			ColumnName = c.COLUMN_NAME,
			ColumnDataType = c.DATA_TYPE,		
			ColumnsUpdated = @ColumnsUpdated,
			isPK = iif(kcu.COLUMN_NAME is null, 0, 1),
			isSkip = iif(charindex(c.COLUMN_NAME, @SkipCols) > 0, 1, 0)
		FROM INFORMATION_SCHEMA.COLUMNS AS c
		left join INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tcPK ON tcPK.TABLE_NAME = c.TABLE_NAME
			and tcPK.CONSTRAINT_TYPE = ''PRIMARY KEY''
		left join INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu ON kcu.TABLE_NAME = tcPK.TABLE_NAME
			and kcu.CONSTRAINT_NAME = tcPK.CONSTRAINT_NAME
			and kcu.COLUMN_NAME = c.COLUMN_NAME
			WHERE c.TABLE_NAME= ''' + @TableName + '''
	) AS t
END

BEGIN   ----   PREPARE DATA FOR SQL @SQL

	SELECT * INTO #ins FROM inserted 
	SELECT * INTO #del FROM deleted 

	DECLARE 
		@cols NVARCHAR (MAX),
		@colsSelect NVARCHAR (MAX),
		@SQL NVARCHAR (MAX),
		@PKname VARCHAR(255),
		@UserNameColumn VARCHAR(128)

	SET @PKname = (SELECT ColumnName FROM #tmp_Columns
		WHERE isPK = 1)

	IF @PKname is null 
	BEGIN 
			RAISERROR(''no PK on table %s'', 16, -1, ''' + @TableName + ''')
		RETURN
	END 

IF @Type = ''I''
	BEGIN
		SELECT @UserNameColumn = c.ColumnName
			FROM #tmp_Columns AS c
			WHERE c.ColumnName like ''Create%By''

		SET @UserNameColumn = coalesce('', '' + @UserNameColumn+'' as UserName'', '', 0 as UserName'')

		SET @colsSelect =  ''(SELECT ''+@PKname + @UserNameColumn
	END
ELSE IF @Type = ''U''
	BEGIN
		SELECT 
			@UserNameColumn = c.ColumnName
		FROM #tmp_Columns as c
		WHERE c.ColumnName like ''LastUpdate%By''

		SELECT @UserNameColumn = coalesce('', '' + @UserNameColumn+'' as UserName'', '', 0 as UserName'')

		SELECT @cols = COALESCE (@cols + '',('''''' + ColumnName + '''''',['' + ColumnName + ''])'', ''('''''' + ColumnName + '''''',['' + ColumnName + ''])'')
		FROM  #tmp_Columns
		WHERE isPK = 0 and isUpdated = 1 and isSkip = 0

		SELECT @colsSelect =  ''(SELECT ''+@PKname + @UserNameColumn

		SELECT @colsSelect = iif(ColumnDataType <> ''xml'',
						@colsSelect  + '',convert(varchar(1000), '' + ColumnName + '') as '' + ColumnName,
						@colsSelect  + '',cast(convert(varchar(max), '' + ColumnName + '') as varchar(1000))  as ''+ ColumnName)
				FROM  #tmp_Columns
				WHERE isPK = 0 and isUpdated = 1 and isSkip = 0
	END
ELSE IF @Type = ''D''
	BEGIN
		SELECT 
			@UserNameColumn = c.ColumnName
		FROM #tmp_Columns as c
		WHERE c.ColumnName like ''LastUpdate%By''

		SELECT @UserNameColumn = coalesce('', '' + @UserNameColumn+'' as UserName'', '', 0 as UserName'')

		SELECT @cols = COALESCE (@cols + '',['' + ColumnName + '']'', ''['' + ColumnName + '']'')
		FROM  #tmp_Columns
		WHERE isPK = 0 

		SELECT @colsSelect =  ''(SELECT ''+@PKname + @UserNameColumn

		SELECT @colsSelect = iif(ColumnDataType <> ''xml'',
						@colsSelect  + '',convert(varchar(1000), '' + ColumnName + '') as '' + ColumnName,
						@colsSelect  + '',cast(convert(varchar(max), '' + ColumnName + '') as varchar(1000))  as ''+ ColumnName)
				FROM  #tmp_Columns
				WHERE isPK = 0 
	END
END

BEGIN   ----   PREPARE SQL QUERY TO INSERT DATA IN tbl_AuditBatchDetails

IF @Type = ''I''
	BEGIN
		SET @SQL =''
			INSERT uManageDBLogs.dbo.tbl_AuditBatchDetails
			(
				AuditBatchId, 
				FieldName, 
				OldValue, 
				NewValue, 
				UserName, 
				PKId
			)
			SELECT 
				''+CONVERT(VARCHAR(128), @AuditBatchId)+'', 
				NULL, 
				NULL, 
				NULL, 
				UserName, 
				''+@PKname+''
			FROM ''+@colsSelect+'' FROM #ins) AS ins''
	END

ELSE IF  @Type = ''U''
	BEGIN
		SET @SQL =''
			INSERT uManageDBLogs.dbo.tbl_AuditBatchDetails
			(
				AuditBatchId, 
				FieldName, 
				OldValue, 
				NewValue, 
				UserName, 
				PKId
			)
			SELECT 
				''+CONVERT(VARCHAR(128),@AuditBatchId)+'', 
				insColumnName, 
				OldValue, 
				NewValue, 
				UserName, 
				PKIDins
			FROM 
			( 
				SELECT  
					PKIDins, 
					insColumnName, 
					newValue, 
					oldValue, 
					UserName 
				FROM 
				(
					SELECT 
						''+@PKname+'' AS PKIDins, 
						ColumnValue AS newValue, 
						ColumnName AS insColumnName, 
						UserName
					FROM ''+@colsSelect+'' FROM #ins) AS pv
					CROSS APPLY (values ''+@cols+'') AS b (ColumnName, ColumnValue)
				) AS ins
				JOIN 
				(
					SELECT 
						''+@PKname+'' AS PKIDdel, 
						ColumnValue AS oldValue, 
						ColumnName AS delColumnName
					FROM ''+@colsSelect+'' FROM #del) AS pv
					CROSS APPLY (values ''+@cols+'') AS b (ColumnName, ColumnValue)
				) AS del
					ON ins.PKIDins = del.PKIDdel 
						AND insColumnName = delColumnName
					WHERE ISNULL(newValue, '''''''') <> ISNULL(oldValue, '''''''')		
			) AS u''
	END

ELSE IF @Type = ''D''
	BEGIN
		SET @SQL =''
			INSERT uManageDBLogs.dbo.tbl_AuditBatchDetails
			(
				AuditBatchId,  
				FieldName, 
				OldValue, 
				NewValue, 
				UserName, 
				PKId
			)
			SELECT 
				''+CONVERT(varchar(128), @AuditBatchId)+'', 
				delColumnName, 
				OldValue, 
				NULL, 
				UserName, 
				PKIDdel
			FROM 
			(
				SELECT 
					''+@PKname+'' AS PKIDdel, 
					ColumnName AS delColumnName,
					ColumnValue AS oldValue, 
					UserName
				FROM ''+@colsSelect+'' FROM #del) AS pv
				UNPIVOT
				(ColumnValue for ColumnName in (''+@cols+'')) AS unpiv
			) AS del''
	END

	EXEC(@SQL)

END'

exec(@trbody)
--print len(@trbody)  exec with TableName = 'tbl_Test' length = 7632 (max 8000!!!)
GO

go

exec dbo.um_End @name = 'um_CreateAuditTriggerForTable'
go