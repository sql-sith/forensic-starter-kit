DECLARE @ForensicOn BIT = 1;
DECLARE @CorrelationID NVARCHAR(36) = NEWID();
DECLARE @ForensicStart DATETIME2(3) = SYSUTCDATETIME();
GO

CREATE OR ALTER PROCEDURE dbo.ForensicLog
    @Message NVARCHAR(4000),
    @StartTime DATETIME2(3),
    @Level NVARCHAR(10) = 'INFO'
AS
BEGIN
    IF @ForensicOn = 1
    BEGIN
        DECLARE @Now DATETIME2(3) = SYSUTCDATETIME();
        DECLARE @ElapsedMs BIGINT = DATEDIFF(MILLISECOND, @StartTime, @Now);
        PRINT FORMATMESSAGE(
            '{"ts":"%s","elapsed_ms":%d,"corr_id":"%s","level":"%s","msg":"%s"}',
            CONVERT(VARCHAR(33), @Now, 126),
            @ElapsedMs,
            @CorrelationID,
            @Level,
            @Message
        );
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.ForensicCheck
    @Condition BIT,
    @Message NVARCHAR(4000)
AS
BEGIN
    IF @ForensicOn = 1 AND @Condition = 0
        EXEC dbo.ForensicLog @Message, @ForensicStart, 'WARN';
END;
GO
