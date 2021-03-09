Use uManageDB

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER dbo.[TR_New_Audit]
ON dbo.tbl_Test
FOR INSERT, UPDATE, DELETE
AS
------------------- данные для таблицы Batch
DECLARE 
	@AuditBatchId INT,
	@TableName VARCHAR(128) = '[tbl_Test]',
	@Type CHAR(1),
	@AppUserName VARCHAR(128) = suser_sname(),
	@AppName VARCHAR(128) = app_name(),
	@HostName VARCHAR(128) = host_name(),
	@EventInfo NVARCHAR(4000) = 'null',
	@AuditDate DATETIME = getutcdate(),
	@ColumnsUpdated VARBINARY(max) = COLUMNS_UPDATED(),

	@SkipCols VARCHAR(255) = 'LastVisited, CreateDate, UpdateDate, CreateBy, CreatedBy, LastUpdate, LastUpdatedBy, LastUpdateBy', --this string 97 symbol length
	@AuditBatchStatus char(1) = 'I',
	@Status char(1),
	@PK NVARCHAR(255)

	IF exists (SELECT top 1 1 FROM inserted) 
		begin
			IF exists (SELECT TOP 1 1 FROM deleted) 
				SELECT @Type = 'U' 
			ELSE 
				SELECT @Type = 'I'
		END
	ELSE 
		SELECT @Type = 'D'

		IF (@Type = 'U' and (@Status is null or @Status <> 'D')) 
			begin
				SELECT @AuditBatchStatus = 'U'	
			end	
		ELSE IF (@Type = 'D' or (@Type = 'U' and @Status = 'D')		
				SELECT @AuditBatchStatus = 'D'

DECLARE @dbcc_INPUTBUFFER TABLE(EventType NVARCHAR(30), Parameters INT, EventInfo NVARCHAR(4000))  
DECLARE @my_spid VARCHAR(20)  
SET @my_spid = CAST(@@SPID AS VARCHAR(20)) 
INSERT @dbcc_INPUTBUFFER  
EXEC('DBCC INPUTBUFFER (' + @my_spid + ') WITH NO_INFOMSGS'); 
SELECT @EventInfo = replace(EventInfo, '''', '''''') FROM @dbcc_INPUTBUFFER

INSERT uManageDBLogs.dbo.new_tbl_AuditBatch([Type], TableName, AppUserName, AppName, HostName, EventInfo, AuditDate)
		VALUES(@Type, @TableName, @AppUserName,@AppName, @HostName, @EventInfo, @AuditDate)
		SET @AuditBatchId = @@IDENTITY


BEGIN   ----   SELECT DATA FOR #TMP_COLUMNS WHERE FROM COLUMNSUPDATED DEFINE INPUT PARAMETERS 
	SELECT
		t.ColumnId,
		@AuditBatchId AS AuditBatchId,
		t.ColumnName, 
		t.ColumnDataType, 
		isUpdated = iif(t.ColumnsUpdated is null or SUBSTRING(t.ColumnsUpdated, (t.ColumnId-1)/8+1, 1) & POWER(2,((t.ColumnId-1)%8)) > 0, 1, 0),
		t.isAudit,
		t.isPK,
		t.isSkip
	INTO #tmp_Columns 
	FROM
	(
		SELECT
			ColumnId = columnproperty(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'ColumnID'),
			ColumnName = c.COLUMN_NAME,
			ColumnDataType = c.DATA_TYPE,		
			ColumnsUpdated = @ColumnsUpdated,
			isAudit = iif(/*audCols.ObjectNameFields is null or*/ charindex(c.COLUMN_NAME, audCols.ObjectNameFields) > 0, 1, 0),
			isPK = iif(kcu.COLUMN_NAME is null, 0, 1),
			isSkip = iif(charindex(c.COLUMN_NAME, @SkipCols) > 0, 1, 0)
		FROM INFORMATION_SCHEMA.COLUMNS AS c
		left join dbo.tbls_AuditTable AS audCols WITH(NOLOCK) ON audCols.TableName = c.TABLE_NAME
		left join INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tcPK ON tcPK.TABLE_NAME = c.TABLE_NAME
			and tcPK.CONSTRAINT_TYPE = 'PRIMARY KEY'
		left join INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu ON kcu.TABLE_NAME = tcPK.TABLE_NAME
			and kcu.CONSTRAINT_NAME = tcPK.CONSTRAINT_NAME
			and kcu.COLUMN_NAME = c.COLUMN_NAME
			WHERE c.TABLE_NAME= 'tbl_Test'
	) AS t
END


BEGIN   ----   PREPARE DATA FOR SQL @SQL

  select * into #ins from inserted 
  select * into #del from deleted 

	DECLARE 
		@cols NVARCHAR (MAX),
		@colsSelect NVARCHAR (MAX),
		@sql NVARCHAR (MAX),
		@PKname VARCHAR(255),
		@UserNameColumn varchar(128)

if @Type = 'I'
	begin
		select @UserNameColumn = c.ColumnName
			from #tmp_Columns as c
			where c.ColumnName like 'Create%By'
			and c.isUpdated = 1

		select @UserNameColumn = coalesce(', ' + @UserNameColumn+' as UserName', ', 1 as UserName')
	end
else if @Type = 'U' or @Type ='D'
	begin
		select 
			@UserNameColumn = c.ColumnName
		from #tmp_Columns as c
		where c.ColumnName like 'LastUpdate%By'
			and c.isUpdated = 1

		select @UserNameColumn = coalesce(', ' + @UserNameColumn+' as UserName', ', 1 as UserName')
	end

	SELECT @cols = COALESCE (@cols + ',[' + ColumnName + ']', 
				   '[' + ColumnName + ']')
				   FROM  #tmp_Columns
				   where isPK = 0 and isUpdated = 1 and isSkip = 0

	SET @PKname = (SELECT ColumnName FROM #tmp_Columns
				   WHERE isPK = 1)
	if @PKname is null 
    begin 
  		    raiserror('no PK on table %s', 16, -1, @TableName) 
  	    return 
    end 	

SELECT @colsSelect =  '(select '+@PKname + @UserNameColumn

SELECT @colsSelect = iif(ColumnDataType <> 'xml',
						@colsSelect  + ',convert(varchar(1000), ' + ColumnName + ') as ' + ColumnName,
						@colsSelect  + ',cast(convert(varchar(max), ' + ColumnName + ') as varchar(1000))  as '+ ColumnName)
               FROM  #tmp_Columns
			   where isPK = 0 and isUpdated = 1 and isSkip = 0
END

BEGIN   ----   PREPARE SQL QUERY TO INSERT DATA IN tbl_Audit
	
IF @Type = 'I'
	BEGIN
		SET @SQL ='insert uManageDBLogs.dbo.new_tbl_Audit(AuditBatchId, PK, FieldName, OldValue, NewValue, UserName, PKId)
			select '+CONVERT(nvarchar(255),@AuditBatchId)+', ColumnName, NULL, NULL, newValue, UserName, PKIDins
			from (select *
				from  #tmp_Columns as colms
					inner join 
						( select '+@PKname+' as PKIDins, columnValue as newValue, ColumnNames, UserName
							from '+@colsSelect+' from #ins) pv
							unpivot
							(columnValue for ColumnNames in ('+@cols+')) as unpiv
						) as d
					on colms.ColumnName = d.ColumnNames) curData'
	END

ELSE IF @Type = 'U'
	BEGIN
		SET @SQL ='insert uManageDBLogs.dbo.new_tbl_Audit(AuditBatchId, PK, FieldName, OldValue, NewValue, UserName, PKId)
			select '+CONVERT(nvarchar(255),@AuditBatchId)+', NULL, ColumnName, OldValue, newValue, UserName, PKIDins
			from (select *
				from  #tmp_Columns as colms
					inner join 
						( select  PKIDins, insColumnNames, newValue, oldValue, UserName from 
							(select '+@PKname+' as PKIDins, columnValue as newValue, ColumnNames as insColumnNames, UserName
								from '+@colsSelect+' from #ins) pv
								unpivot
								(columnValue for ColumnNames in ('+@cols+')) as unpiv) ins
								inner join 
							(select '+@PKname+' as PKIDdel, columnValue as oldValue, ColumnNames as delColumnNames
								from '+@colsSelect+' from #del) pv
								unpivot
								(columnValue for ColumnNames in ('+@cols+')) as unpiv) del
							on ins.PKIDins = del.PKIDdel and insColumnNames = delColumnNames
							where newValue<>oldValue			
						) as d
					on colms.ColumnName = d.insColumnNames) curData'

	END
ELSE IF @Type = 'D'
	BEGIN
		SET @SQL ='insert uManageDBLogs.dbo.new_tbl_Audit(AuditBatchId, PK, FieldName, OldValue, NewValue, UserName, PKId)
			select '+CONVERT(nvarchar(255),@AuditBatchId)+', NULL, NULL, NULL, NULL, UserName, PKIDdel
			from ( select '+@PKname+' as PKIDdel, UserName
					from '+@colsSelect+' from #del) as del'
	END


	--DECLARE @SqlText NVARCHAR(max) = 'insert into uManageDBLogs.dbo.new_tbl_AuditQuery(Query, PKname, ColsSelect) values('''+@sql+''', '''+@PKname+''', '''+@colsSelect+''')'

	--EXEC( @SqlText)

	EXEC(@sql)

END