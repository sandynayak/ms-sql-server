SELECT es.session_id
	,es.login_time
	,es.host_name
	,es.program_name
	,es.host_process_id
	,es.client_interface_name
	,es.login_name
	,es.original_login_name
	,es.STATUS
	,CAST(es.context_info as int) context_info
	,es.cpu_time
	,es.memory_usage
	,es.total_scheduled_time
	,es.total_elapsed_time
	,es.last_request_start_time
	,es.last_request_end_time
	,es.reads
	,es.writes
	,es.logical_reads
	,es.is_user_process
	,es.transaction_isolation_level
	,es.LOCK_TIMEOUT
	,es.DEADLOCK_PRIORITY
	,es.row_count
	,es.prev_error
	,es.group_id
/*For SQL 2012 above only*/
--,es.database_id
--,es.authenticating_database_id
--,es.open_transaction_count
FROM sys.dm_exec_sessions es
WHERE 1=1
AND es.is_user_process = 1
--AND es.original_login_name not in( 'ABC','XYZ')
--AND es.original_login_name = 'ABC'
--AND es.session_id = 210
--AND es.host_name in ('XXXX')
order by cpu_time DESC;
