SELECT (
		SELECT sys.schemas.NAME
		FROM sys.schemas
		WHERE c.schema_id = sys.schemas.schema_id
		) ObjectSchema
	,c.NAME AS ObjectName
	,ps.NAME AS ParentSchemaName
	,p.NAME AS ParentObjectName
	,CASE c.type
		WHEN 'P'
			THEN 'Stored Procedure'
		WHEN 'V'
			THEN 'View'
		WHEN 'TR'
			THEN 'DML Trigger'
		WHEN 'FN'
			THEN 'Scalar Function'
		WHEN 'IF'
			THEN 'Inline Table Valued Function'
		WHEN 'TF'
			THEN 'SQL Table Valued Function'
		WHEN 'R'
			THEN 'Rule'
		ELSE 'Check MSDN for type - ' + c.type
		END AS ObjectType
	,m.DEFINITION AS ObjectDefinition
FROM sys.sql_modules m
INNER JOIN sys.objects c ON m.object_id = c.object_id
LEFT JOIN sys.objects p ON p.object_id = c.parent_object_id
LEFT JOIN sys.schemas ps ON p.schema_id = ps.schema_id
--WHERE c.name LIKE '%ABC%' OR m.definition LIKE '%ABC%'
ORDER BY c.type_desc;
