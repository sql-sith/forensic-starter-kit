<#
    Forensic Helpers (PowerShell)
    Purpose:
        Toggle‑driven, JSON‑formatted forensic logging with correlation IDs,
        assumption checks, and scoped timing.

    Exports:
        - forensicLog([string]$Message, [datetime]$StartTime, [string]$Level = "INFO")
        - forensicCheck([bool]$Condition, [string]$Message)
        - forensicScope([string]$Name, [scriptblock]$Script)  # cross‑language parity
        - ForensicScope : IDisposable                          # idiomatic using pattern

    Scope Options:
        1. Cross‑language parity:
            forensicScope "MyBlock" {
                # ... logic ...
            }

        2. Idiomatic PowerShell using:
            using ($scope = [ForensicScope]::new("MyBlock")) {
                # ... logic ...
            }

    Example:
        # Enable logging
        $forensicOn = $true

        # Log a checkpoint
        forensicLog "Starting script" $forensicStart

        # Validate assumption
        forensicCheck ($items.Count -gt 0) "No items found"

        # Scoped timing (parity)
        forensicScope "LoadData" {
            Load-Data
        }

        # Scoped timing (idiomatic)
        using ($scope = [ForensicScope]::new("ProcessData")) {
            Process-Data
        }
#>

$forensicOn = $true
$correlationId = [guid]::NewGuid().ToString()
$forensicStart = Get-Date -AsUTC

function forensicLog {
    param(
        [string]$Message,
        [datetime]$StartTime,
        [string]$Level = "INFO"
    )
    if ($forensicOn) {
        $now = Get-Date -AsUTC
        $elapsedMs = [math]::Round(($now - $StartTime).TotalMilliseconds)
        $log = @{
            ts         = $now.ToString("o")
            elapsed_ms = $elapsedMs
            corr_id    = $correlationId
            level      = $Level
            msg        = $Message
        } | ConvertTo-Json -Compress
        Write-Host $log
    }
}

function forensicCheck {
    param(
        [bool]$Condition,
        [string]$Message
    )
    if ($forensicOn -and -not $Condition) {
        forensicLog $Message $forensicStart "WARN"
    }
}

# Idiomatic IDisposable scope
class ForensicScope : System.IDisposable {
    [string]$Name
    [datetime]$Start
    ForensicScope([string]$name) {
        $this.Name = $name
        $this.Start = Get-Date -AsUTC
        forensicLog "$name start" $this.Start
    }
    [void]Dispose() {
        forensicLog "$($this.Name) end" $this.Start
    }
}

# Cross‑language parity wrapper
function forensicScope {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][scriptblock]$Script
    )
    $scope = [ForensicScope]::new($Name)
    try {
        & $Script
    }
    finally {
        $scope.Dispose()
    }
}
