;WITH CTE
AS (
	SELECT ic.object_id AS ObjectId
		,ic.index_id AS IndexId
		,object_schema_name(ic.object_id) TableSchema
		,object_name(ic.object_id) AS TableName
		,i.NAME AS IndexName
		,i.type_desc IndexType
		,col_name(ic.object_id, ic.column_id) AS ColumnName
		,i.is_primary_key AS PrimaryKey
		,i.is_unique AS UniqueKey
		,ic.key_ordinal
		,ic.partition_ordinal
		,ic.is_included_column
		,ic.is_descending_key
		,COLUMNPROPERTY(i.object_id, col_name(ic.object_id, ic.column_id), 'IsIdentity') is_identity_key
		,i.filter_definition FilterDefinition
		,i.fill_factor [FillFactor]
		,ds.name AS FileGroupOrPS
	FROM sys.indexes i
	INNER JOIN sys.index_columns ic ON i.index_id = ic.index_id
		AND i.object_id = ic.object_id
	INNER JOIN sys.data_spaces AS ds ON i.data_space_id = ds.data_space_id  
	)
SELECT C.TableSchema + '.' + C.TableName TableName
	,C.IndexName
	,C.IndexType
	,C.PrimaryKey
	,C.UniqueKey
	,C.FilterDefinition
	,C.[FillFactor]
	,STUFF((SELECT ',' + a.ColumnName + CASE is_descending_key WHEN 1 THEN ' DESC' ELSE '' END FROM CTE a WHERE C.ObjectId = a.ObjectId AND C.IndexId = a.IndexId AND key_ordinal > 0 
			ORDER BY key_ordinal FOR XML PATH('') ), 1, 1, '') AS KeyColumns
	,STUFF((SELECT ',' + a.ColumnName FROM CTE a WHERE C.ObjectId = a.ObjectId AND C.IndexId = a.IndexId AND partition_ordinal > 0 
			ORDER BY partition_ordinal FOR XML PATH('') ), 1, 1, '') AS PartitionColumns
	,STUFF((SELECT ',' + a.ColumnName FROM CTE a WHERE C.ObjectId = a.ObjectId AND C.IndexId = a.IndexId AND is_included_column = 1
			FOR XML PATH('') ), 1, 1, '') AS IncludeColumns
	,C.FileGroupOrPS
	,STUFF((SELECT ',' + a.ColumnName FROM CTE a WHERE C.ObjectId = a.ObjectId AND C.IndexId = a.IndexId AND is_identity_key = 1
			FOR XML PATH('') ), 1, 1, '') AS IdentityColumn
FROM CTE C
--WHERE C.tablename IN ('***TABLENAME***')
GROUP BY C.ObjectId
	,C.TableSchema
	,C.IndexId
	,C.TableName
	,C.IndexName
	,C.IndexType
	,C.PrimaryKey
	,C.UniqueKey
	,C.FilterDefinition
	,C.[FillFactor]
	,C.FileGroupOrPS
ORDER BY C.TableName ASC
	,C.PrimaryKey DESC;
