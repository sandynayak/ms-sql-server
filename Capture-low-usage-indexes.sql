/*
**********************************************Capture-low-usage-indexes**********************************************

-- This script could be used to capture the list of non clustered indexes which have relatively low usage in the database.
-- Reads < 10% of writes could really be bad which would mean - 100 DMLs are performed, but less than 10 reads are done
-- Modify the fraction in the query to change the threshold. 

-- Adapted from Diagnostic Information Queries written by Glenn Berry
-- Possible Bad NC Indexes (writes > reads)  (Query XX) (Bad NC Indexes)

*/
SELECT DB_NAME() AS [DatabaseName],
	GETDATE() AS [DateCaptured],
	(SELECT sqlserver_start_time FROM sys.dm_os_sys_info) AS [SqlServerStartTime],
	OBJECT_SCHEMA_NAME(s.[object_id]) AS [SchemaName],
	OBJECT_NAME(s.[object_id]) AS [TableName],
	i.NAME AS [IndexName],
	i.index_id AS [IndexID],
	i.is_disabled AS [IsDisabled],
	i.is_hypothetical AS [IsHypothetical],
	i.has_filter AS [HasFilter],
	i.fill_factor AS [FillFactor],
	user_updates AS [TotalWrites],
	user_seeks + user_scans + user_lookups AS [TotalReads],
	user_updates - (user_seeks + user_scans + user_lookups) AS [Difference],
	(SELECT MAX(last_read_date)
		FROM ( VALUES (s.last_user_lookup), (s.last_user_scan), (s.last_user_seek)) AS X(last_read_date)
		) AS [LastReadDate],
	(SELECT SUM(s.[used_page_count]) * 8.0 / 1024 / 1024
		FROM sys.dm_db_partition_stats AS s
		WHERE s.[object_id] = i.[object_id]
			AND s.[index_id] = i.[index_id] ) AS [IndexSizeGB]
--INTO dbo.IndexUsageStats
FROM sys.dm_db_index_usage_stats AS s
INNER JOIN sys.indexes AS i ON s.[object_id] = i.[object_id]
	AND i.index_id = s.index_id
WHERE OBJECTPROPERTY(s.[object_id], 'IsUserTable') = 1
	AND s.database_id = DB_ID()
	AND user_updates > (user_seeks + user_scans + user_lookups)
	AND i.index_id > 1
	AND (user_seeks + user_scans + user_lookups) < (user_updates * 0.10) -- Change this fraction to specify the threshold
ORDER BY IndexSizeGB DESC,
	[Difference] DESC,
	[TotalWrites] DESC,
	[TotalReads] ASC
OPTION (RECOMPILE);
GO

