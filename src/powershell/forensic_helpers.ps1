$ForensicOn = $true
$CorrelationID = [guid]::NewGuid().ToString()
$ForensicStart = Get-Date -AsUTC

function ForensicLog {
    param([string]$Message, [datetime]$StartTime, [string]$Level = "INFO")
    if ($ForensicOn) {
        $now = Get-Date -AsUTC
        $elapsedMs = [math]::Round(($now - $StartTime).TotalMilliseconds)
        $log = @{
            ts         = $now.ToString("o")
            elapsed_ms = $elapsedMs
            corr_id    = $CorrelationID
            level      = $Level
            msg        = $Message
        } | ConvertTo-Json -Compress
        Write-Host $log
    }
}

function ForensicCheck {
    param([bool]$Condition, [string]$Message)
    if ($ForensicOn -and -not $Condition) {
        ForensicLog $Message $ForensicStart "WARN"
    }
}
