CREATE DATABASE PackOTP  
ON							  -- ������ ��������� ���� ������.
(
	NAME = 'PackOTP',
	FILENAME = 'C:\SQL\PackOTP.mdf',	
	SIZE = 50MB,
	MAXSIZE = 200MB,
	FILEGROWTH = 10MB				
)
LOG ON						  -- ������ ��������� ������� ���� ������.
( 
	NAME = 'LogPackOTP',
	FILENAME = 'C:\SQL\PackOTP.ldf', 
	SIZE = 5MB,                  
	MAXSIZE = 50MB,   
	FILEGROWTH = 5MB 
)               
COLLATE Cyrillic_General_CI_AS -- ������ ��������� ��� ���� ������ �� ���������

