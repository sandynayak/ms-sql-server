SELECT db_name(er.database_id) database_name
	,object_name(st.objectid) object_name
	,er.session_id
	,er.blocking_session_id
	,st.TEXT sql_text_batch
	,SUBSTRING(st.TEXT, er.statement_start_offset / 2 + 1, (ISNULL(NULLIF(er.statement_end_offset, - 1), LEN(st.TEXT)) - er.statement_start_offset / 2)) sql_text_statement
	,er.sql_handle
	,er.plan_handle
	,qp.query_plan
	,er.start_time request_start_time
	,es.login_time
	,es.host_name
	,es.program_name
	,es.login_name
	,es.cpu_time session_cpu_time
	,er.cpu_time request_cpu_time
	,es.memory_usage session_memory_usage
	,es.total_elapsed_time session_total_elapsed_time
	,er.total_elapsed_time request_total_elapsed_time
	,es.last_request_start_time
	,es.last_request_end_time
	,es.reads session_reads
	,er.reads request_reads
	,es.writes session_writes
	,er.writes request_writes
	,es.logical_reads session_logical_reads
	,er.logical_reads request_logical_reads
	,es.STATUS session_status
	,er.STATUS request_status
	,er.command
	--,er.sql_handle
	--,er.plan_handle
	--,er.user_id
	,er.wait_type
	,er.wait_time
	,er.last_wait_type
	,er.wait_resource
	,er.open_transaction_count
	,er.open_resultset_count
	,er.transaction_id --SELECT * FROM sys.dm_tran_locks WHERE request_owner_type = N'TRANSACTION' AND request_owner_id = 
	,CAST(er.context_info as int) context_info
	,er.percent_complete
	,er.transaction_isolation_level
	,er.LOCK_TIMEOUT
	,er.DEADLOCK_PRIORITY
	,er.row_count
	,er.prev_error
	,er.nest_level
	,er.granted_query_memory
	,er.executing_managed_code
	,er.group_id
	,er.query_hash
	,er.query_plan_hash
/*SQL 2014 onwards only*/
--	,er.statement_sql_handle
FROM sys.dm_exec_requests er
INNER JOIN sys.dm_exec_sessions es ON er.session_id = es.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) qp
WHERE 1 = 1
	AND er.session_id in (81)
	--AND es.host_name NOT IN (SELECT host_name FROM sys.dm_exec_sessions AS s WHERE s.session_id = @@SPID ) -- exclude current host
	--AND es.host_name in ('XXXX')
	--AND object_name(cast(st.objectid as int)) like '%ABC%'
	--AND st.text like '%SELECT TableXYZ%'
;
