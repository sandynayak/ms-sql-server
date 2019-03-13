/*
-- Description: A generic stored procedure to handle any errors in the system

--	Usage example
--	EXEC dbo.uspHandleErrors
*/

CREATE PROCEDURE dbo.uspHandleErrors
	@ErrorProcedure		nvarchar(128)	= NULL,
	@NestLevel			tinyint			= NULL,
	@ErrorParameters	varchar(4000)	= NULL,
	@CustomMessage		varchar(4000)	= NULL,
	@RaiseError			bit				= 1
AS
SET NOCOUNT ON;
BEGIN
    DECLARE 
			@ErrorNumber	int				= ERROR_NUMBER(),
			@ErrorSeverity	int				= ERROR_SEVERITY(),
			@ErrorState		int				= ERROR_STATE(),
			@ErrorLine		int				= ERROR_LINE(),
			@ErrorMessage	varchar(8000)	= ERROR_MESSAGE();	
	
	DECLARE @ErrorLogID Table (ErrorLogID bigint);
	
	SELECT  @ErrorProcedure	= COALESCE(@ErrorProcedure,ERROR_PROCEDURE());

	INSERT INTO dbo.ErrorLog (ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, NestLevel, ErrorMessage, CustomMessage, ErrorParameters, HostName, UserCreated, DateCreated)
		OUTPUT inserted.ErrorLogID INTO @ErrorLogID
		SELECT @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @NestLevel, @ErrorMessage, @CustomMessage, @ErrorParameters, HOST_NAME(), SUSER_SNAME(), SYSDATETIME();

	
    IF (@RaiseError = 1)
	BEGIN
		SELECT @ErrorMessage = 'ErrorLogID - ' + CAST(ErrorLogID AS VARCHAR) 
								+ '; ErrorProcedure - ' + @ErrorProcedure + '; ' 
								+ @ErrorMessage 
		FROM @ErrorLogID;

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	END

	RETURN 0;
END
