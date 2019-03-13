SELECT SCHEMA_NAME(o.schema_id) + '.' + o.NAME TableName
	,i.type_desc TableType
	,o.type_desc TableTypeDescription
	,o.create_date CreationDate
FROM sys.indexes i
INNER JOIN sys.objects o ON i.object_id = o.object_id
WHERE o.type_desc = 'USER_TABLE'
	AND i.type_desc = 'HEAP'
ORDER BY o.NAME;
