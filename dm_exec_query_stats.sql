SELECT 
	db_name(cast(pa.dbid as int)) database_name
	,object_name(cast(pa.objectid as int)) object_name
	,pa.user_id
	,st.TEXT sql_text_batch
	,SUBSTRING(st.text,qs.statement_start_offset/2+1,(ISNULL(NULLIF(qs.statement_end_offset,-1),LEN(st.text)) - qs.statement_start_offset/2)) sql_text_statement
	,qp.query_plan
	,qs.plan_handle
	,qs.sql_handle
	,qs.plan_generation_num
	,qs.creation_time
	,qs.last_execution_time
	,qs.execution_count
	,qs.total_worker_time
	,qs.last_worker_time
	,qs.min_worker_time
	,qs.max_worker_time
	,qs.total_physical_reads
	,qs.last_physical_reads
	,qs.min_physical_reads
	,qs.max_physical_reads
	,qs.total_logical_writes
	,qs.last_logical_writes
	,qs.min_logical_writes
	,qs.max_logical_writes
	,qs.total_logical_reads
	,qs.last_logical_reads
	,qs.min_logical_reads
	,qs.max_logical_reads
	,qs.total_clr_time
	,qs.last_clr_time
	,qs.min_clr_time
	,qs.max_clr_time
	,qs.total_elapsed_time
	,qs.last_elapsed_time
	,qs.min_elapsed_time
	,qs.max_elapsed_time
	,qs.query_hash
	,qs.query_plan_hash
	,qs.total_rows
	,qs.last_rows
	,qs.min_rows
	,qs.max_rows
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
OUTER APPLY (SELECT * FROM
				(SELECT attribute, value FROM sys.dm_exec_plan_attributes(qs.plan_handle)) t
				PIVOT (MAX(value) FOR attribute IN ("objectid","dbid","user_id")) AS pvt) pa
where 
	1=1
	AND st.TEXT NOT LIKE '%sys.dm_exec_%'
	--AND sql_handle = 0x06000B
	--AND object_name(cast(pa.objectid as int)) like '%ABC%'
	AND st.TEXT like '%SELECT ABC%'
	--AND query_hash = 0xBA3CA38
--order by last_execution_time desc
