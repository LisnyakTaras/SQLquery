use CM_ATB

select [SYSTEM].ResourceID, --уникальное для компьютера
[SYSTEM].Name0 as Comp_Name, 
[SYSTEM].Domain0 as Domain,
[SYSTEM].SystemRole0 as [Role],
COMPUTER.UserName0 as Login_User, --в данном значении хочу CurrentLogonUser, не смог найти в базе нужную таблицу
ADAPTER.IPAddress0 as Comp_IP,
ADAPTER.MACAddress0 as Comp_MAC,
COMPUTER.Manufacturer0 as Manufacturer,
COMPUTER.Model0 as Manufacturer_Model,
BASEBOARD.Product0 as MB_Model,
BASEBOARD.SerialNumber0 as MB_Serial, 
PROCESSOR.Name0 as CPU_Name, 
COMPUTER.TotalPhysicalMemory0/1000 as TotalRam,
-- собираем несколько значений из других таблиц и добавляем в столбец
RAM_Bank = STUFF ((select '; ' + CAST( MEMORY.Capacity0 as nvarchar(max)) from v_GS_PHYSICAL_MEMORY MEMORY where [SYSTEM].ResourceID = MEMORY.ResourceID FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(max)'), 1, 1, ''),
RAM_Serial = STUFF ((select '; ' + CAST( MEMORY.SerialNumber0 as nvarchar(255)) from v_GS_PHYSICAL_MEMORY MEMORY where [SYSTEM].ResourceID = MEMORY.ResourceID FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(255)'), 1, 1, ''),
HDDModel = STUFF ((select '; ' + CAST( DiskModel.Model0 as VARCHAR(255)) from v_GS_DISK DiskModel where [SYSTEM].ResourceID = DiskModel.ResourceID FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(255)'), 1, 1, ''),
HDDSerial = STUFF ((select '; ' + CAST(REPLACE( DiskSerial.SerialNumber0,char(0x0003), '' )as VARCHAR(max)) from v_GS_PHYSICAL_MEDIA DiskSerial where [SYSTEM].ResourceID = DiskSerial.ResourceID FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(255)'), 1, 1, ''),
Monitor_Model = STUFF ((select '; ' + CAST( Monitors.Name0 as VARCHAR(255)) from v_GS_MONITORDETAILS Monitors where [SYSTEM].ResourceID = Monitors.ResourceID FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(255)'), 1, 1, ''),
Monitor_Serial = STUFF ((select '; ' + CAST( Monitors.SerialNumber0 as VARCHAR(255)) from v_GS_MONITORDETAILS Monitors where [SYSTEM].ResourceID = Monitors.ResourceID FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(255)'), 1, 1, ''),
Monitor_Manufactoring = STUFF ((select  '; ' + CAST( Monitors.ManufacturingYear0 as VARCHAR(255)) from v_GS_MONITORDETAILS Monitors where [SYSTEM].ResourceID = Monitors.ResourceID FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(255)'), 1, 1, ''),

BASEBOARD.TimeStamp as Motherboard_ScanDate, 
OPERATING_S.TimeStamp as OS_ScanDate, 
R_System.Build01 as VersionOS, 
OPERATING_S.InstallDate0 as DateInstallOS, 
OPERATING_S.LastBootUpTime0 as BootTimeOS

from v_GS_SYSTEM [SYSTEM]
left join v_GS_COMPUTER_SYSTEM  COMPUTER on [SYSTEM].ResourceID = COMPUTER.ResourceID
left join v_GS_NETWORK_ADAPTER_CONFIGURATION ADAPTER on [SYSTEM].Name0 = ADAPTER.DNSHostName0
left join v_GS_PROCESSOR PROCESSOR on [SYSTEM].ResourceID = PROCESSOR.ResourceID
left join v_GS_BASEBOARD BASEBOARD on [SYSTEM].ResourceID = BASEBOARD.ResourceID
left join v_GS_OPERATING_SYSTEM OPERATING_S on [SYSTEM].ResourceID =OPERATING_S.ResourceID
left join v_R_System R_System on  [SYSTEM].ResourceID = R_System.ResourceID
--where [SYSTEM].Domain0 = 'atbmarket.com' and SystemRole0 = 'Workstation'
where COMPUTER.Name0 = 'MARKET-070-145'