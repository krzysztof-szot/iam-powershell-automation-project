#requires -Version 5.1
<#
.SYNOPSIS
Preview or apply one synthetic AD lifecycle event in the isolated JML lab.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z0-9][A-Z0-9._-]{0,63}$')][string]$EventId,
    [switch]$Apply,
    [Security.SecureString]$InitialPassword,
    [switch]$SimulateFailureAfterRemoval,
    [string]$ConfigPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'config\lab.local.json'),
    [string]$MatrixPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'config\access-matrix.example.json'),
    [string]$EventsPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'samples\hr-events.example.csv'),
    [string]$OutputDirectory = (Join-Path (Split-Path $PSScriptRoot -Parent) 'local-output')
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $projectRoot 'src\IamAutomation\IamAutomation.psm1') -Force -ErrorAction Stop
# Audit files are intentional in all modes, including -WhatIf.
$null = New-Item -ItemType Directory -Path $OutputDirectory -Force -WhatIf:$false -Confirm:$false
$runId = [guid]::NewGuid().ToString('N')
$logPath = Join-Path $OutputDirectory ("run-{0}-{1}.csv" -f [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ'), $runId)
$mode = if (-not $Apply) { 'Preview' } elseif ($WhatIfPreference) { 'WhatIf' } else { 'Apply' }
$runRecord = @{ LogPath = $logPath; RunId = $runId; EventId = $EventId; Mode = $mode }
try {
    Write-IamRunRecord @runRecord -Status 'Started'
    $context = Read-IamLifecycleInput -EventId $EventId -EventsPath $EventsPath -ConfigPath $ConfigPath -MatrixPath $MatrixPath
    $runRecord.EventType = $context.Event.EventType
    $runRecord.EmployeeId = $context.Event.EmployeeId
    $runRecord.SamAccountName = $context.SamAccountName
    $parameters = @{
        Context = $context; LogPath = $logPath; RunId = $runId; Apply = [bool]$Apply
        WhatIf = [bool]$WhatIfPreference
        SimulateFailureAfterRemoval = [bool]$SimulateFailureAfterRemoval
    }
    if ($PSBoundParameters.ContainsKey('InitialPassword')) { $parameters.InitialPassword = $InitialPassword }
    if ($PSBoundParameters.ContainsKey('Confirm')) { $parameters.Confirm = $PSBoundParameters.Confirm }
    $result = Invoke-IamLifecycleEvent @parameters
    Write-IamRunRecord @runRecord -Status $result.Status
    $result | Select-Object ScriptVersion, Mode, Status, EventId, EventType, EmployeeId,
        SamAccountName, TargetOU, UserExistsBefore, UserExistsAfter, PlannedOperations,
        AppliedOperations, RemainingOperations, ManagedStateUnchanged,
        AccountEnabledAfter, DepartmentAfter, ManagedGroupsAfter, LogPath | Format-List
    if ($result.Plan.Count -gt 0) {
        $result.Plan | Select-Object Step, Action, Target, Value | Format-Table -AutoSize -Wrap
    } else {
        'No changes required for this event.'
    }
    if ($result.Status -eq 'Cancelled') { throw 'One or more operations were declined. Inspect the log and run a fresh preview.' }
} catch {
    $originalError = $_
    try { Write-IamRunRecord @runRecord -Status 'Failed' -Message $originalError.Exception.Message } catch { }
    Write-Host "Run log: $logPath"
    throw $originalError
}
