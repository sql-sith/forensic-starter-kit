/*
    Forensic Helpers (T‑SQL)
    Purpose:
        Toggle‑driven, JSON‑formatted forensic logging with correlation IDs,
        assumption checks, and scoped timing.

    Exports:
        - dbo.forensicLog(@Message NVARCHAR, @StartTime DATETIME2, @Level NVARCHAR = 'INFO')
        - dbo.forensicCheck(@Condition BIT, @Message NVARCHAR)
        - dbo.forensicScope(@Name NVARCHAR, @Mode NVARCHAR)  -- cross‑language parity

    Scope Options:
        1. Cross‑language parity:
            EXEC dbo.forensicScope @Name = N'MyBlock', @Mode = N'start';
            -- ... your logic ...
            EXEC dbo.forensicScope @Name = N'MyBlock', @Mode = N'end';

        2. Idiomatic T‑SQL TRY/FINALLY:
            DECLARE @BlockName NVARCHAR(64) = N'MyBlock';
            EXEC dbo.forensicScope @Name = @BlockName, @Mode = N'start';
            BEGIN TRY
                -- ... your logic ...
            END TRY
            BEGIN FINALLY
                EXEC dbo.forensicScope @Name = @BlockName, @Mode = N'end';
            END FINALLY;

    Example:
        -- Enable logging
        DECLARE @forensicOn BIT = 1;

        -- Log a checkpoint
        EXEC dbo.forensicLog @Message = N'Starting batch', @StartTime = SYSUTCDATETIME();

        -- Validate assumption
        EXEC dbo.forensicCheck @Condition = 0, @Message = N'Expected rows not found';

        -- Scoped timing (parity)
        EXEC dbo.forensicScope @Name = N'LoadData', @Mode = N'start';
        -- ... load logic ...
        EXEC dbo.forensicScope @Name = N'LoadData', @Mode = N'end';
*/

DECLARE @forensicOn BIT = 1;
DECLARE @correlationId NVARCHAR(36) = CONVERT(NVARCHAR(36), NEWID());
DECLARE @forensicStart DATETIME2(3) = SYSUTCDATETIME();
GO

CREATE OR ALTER PROCEDURE dbo.forensicLog
    @Message NVARCHAR(4000),
    @StartTime DATETIME2(3),
    @Level NVARCHAR(10) = 'INFO'
AS
BEGIN
    IF @forensicOn = 1
    BEGIN
        DECLARE @Now DATETIME2(3) = SYSUTCDATETIME();
        DECLARE @ElapsedMs BIGINT = DATEDIFF(MILLISECOND, @StartTime, @Now);

        PRINT FORMATMESSAGE(
            '{"ts":"%s","elapsed_ms":%d,"corr_id":"%s","level":"%s","msg":"%s"}',
            CONVERT(VARCHAR(33), @Now, 126),
            @ElapsedMs,
            @correlationId,
            @Level,
            @Message
        );
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.forensicCheck
    @Condition BIT,
    @Message NVARCHAR(4000)
AS
BEGIN
    IF @forensicOn = 1 AND @Condition = 0
    BEGIN
        EXEC dbo.forensicLog @Message = @Message, @StartTime = @forensicStart, @Level = 'WARN';
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.forensicScope
    @Name NVARCHAR(256),
    @Mode NVARCHAR(10)
AS
BEGIN
    IF @forensicOn = 0
    BEGIN
        RETURN;
    END;

    IF @Mode = N'start'
    BEGIN
        DECLARE @Now DATETIME2(3) = SYSUTCDATETIME();
        EXEC dbo.forensicLog @Message = @Name + N' start', @StartTime = @Now, @Level = 'INFO';
        EXEC sys.sp_set_session_context @key = N'forensicScope:' + @Name, @value = @Now, @read_only = 0;
        RETURN;
    END;

    IF @Mode = N'end'
    BEGIN
        DECLARE @Stored VARBINARY(128) = CAST(SESSION_CONTEXT(N'forensicScope:' + @Name) AS VARBINARY(128));
        DECLARE @Start DATETIME2(3);

        IF @Stored IS NOT NULL
        BEGIN
            SET @Start = CAST(@Stored AS DATETIME2(3));
        END
        ELSE
        BEGIN
            SET @Start = @forensicStart;
        END;

        EXEC dbo.forensicLog @Message = @Name + N' end', @StartTime = @Start, @Level = 'INFO';
        RETURN;
    END;
END;
GO
