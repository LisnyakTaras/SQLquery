CREATE DATABASE PackOTP   
    ON (FILENAME = 'C:\SQLDatabase\PackOTP.mdf'),   
    (FILENAME = 'C:\SQLDatabase\PackOTP.ldf')   
    FOR ATTACH;  


    RESTORE FILELISTONLY  
FROM DISK = 'C:\db\AdventureWorks\AdventureWorks2017.bak' 

-- this work in docker container
	RESTORE DATABASE AdventureWorks2017
FROM DISK = 'C:\db\AdventureWorks\AdventureWorks2017.bak' 
 WITH RECOVERY,  
   MOVE 'AdventureWorks2017' TO 'C:\db\AdventureWorks\AdventureWorks2017.mdf',   
   MOVE 'AdventureWorks2017_log' TO 'C:\db\AdventureWorks\AdventureWorks2017_Log.ldf';  

   
   
   With Move 'primarydatafilename' To 'D:\DB\data.mdf', 
Move 'secondarydatafile' To 'D:\DB\data1.ndf', 
Move 'logfilename' To 'D:\DB\log.ldf'