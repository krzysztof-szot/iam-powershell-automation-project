#requires -Version 5.1
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0
$packageRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$testRoot = Join-Path $packageRoot ('local-output/offline-checks-' + $PSVersionTable.PSVersion.Major)
$null = New-Item -ItemType Directory -Path $testRoot -Force
$modulePath = Join-Path $packageRoot 'src\IamAutomation\IamAutomation.psm1'
$driverPath = Join-Path $packageRoot 'scripts\Invoke-IamLifecycle.ps1'
Import-Module $modulePath -Force

$baseConfig = [ordered]@{
    schemaVersion = 1
    ad = [ordered]@{
        server = 'BFL-DC01.balticfinance.test'; domain = 'balticfinance.test'
        testOu = 'OU=JML,OU=IAM-Automation,DC=balticfinance,DC=test'
        groupMap = [ordered]@{
            FinanceAccess = 'CN=GG-IAM-LAB-Finance,OU=IAM-Automation,DC=balticfinance,DC=test'
            ITAccess = 'CN=GG-IAM-LAB-IT,OU=IAM-Automation,DC=balticfinance,DC=test'
        }
    }
}
$baseMatrix = [ordered]@{
    schemaVersion = 1; departments = [ordered]@{ Finance = @('FinanceAccess'); IT = @('ITAccess') }
}
$baseCsv = @(
    'EventId,EventType,EmployeeId,GivenName,Surname,Department'
    'JML-001,Joiner,LAB-001,Anna,Example,Finance'
    'JML-002,Mover,LAB-001,Anna,Example,IT'
    'JML-003,Leaver,LAB-001,Anna,Example,'
)
$inputPaths = @{
    ConfigPath = (Join-Path $testRoot 'lab.local.json')
    MatrixPath = (Join-Path $testRoot 'matrix.json')
    EventsPath = (Join-Path $testRoot 'events.csv')
}
function Reset-Inputs {
    $baseConfig | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $inputPaths.ConfigPath -Encoding UTF8
    $baseMatrix | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $inputPaths.MatrixPath -Encoding UTF8
    $baseCsv | Set-Content -LiteralPath $inputPaths.EventsPath -Encoding UTF8
}
function Read-Context([string]$Id = 'JML-001') { Read-IamLifecycleInput -EventId $Id @inputPaths }
function Make-User {
    param([bool]$Enabled = $true, [string]$Department = 'Finance')
    [pscustomobject]@{
        ObjectGUID = '11111111-1111-1111-1111-111111111111'
        DistinguishedName = 'CN=iam.lab001,OU=JML,OU=IAM-Automation,DC=balticfinance,DC=test'
        SamAccountName = 'iam.lab001'; EmployeeId = 'LAB-001'
        Enabled = $Enabled; Department = $Department; GivenName = 'Anna'; Surname = 'Example'
        AdminCount = $null; IsCriticalSystemObject = $false
    }
}
function Make-Snapshot {
    param([object]$User = $null, [string[]]$Memberships = @())
    [pscustomobject]@{
        Domain = 'balticfinance.test'; TestOU = $baseConfig.ad.testOu
        User = $User; DirectGroupDns = @($Memberships)
    }
}
function Assert-Equal($Actual, $Expected) {
    if ($Actual -cne $Expected) { throw "Expected [$Expected], got [$Actual]." }
}
function Assert-Throws([scriptblock]$Action, [string]$Message) {
    $caught = $false
    try { & $Action } catch {
        $caught = $true
        if ($_.Exception.Message -notlike "*$Message*") { throw "Wrong exception: $($_.Exception.Message)" }
    }
    if (-not $caught) { throw "Expected exception containing: $Message" }
}
$script:passed = 0
$script:failed = 0
function Check([string]$Name, [scriptblock]$Action) {
    Reset-Inputs
    try {
        & $Action
        $script:passed++
        Write-Output "PASS $Name"
    } catch {
        $script:failed++
        Write-Output "FAIL $Name : $($_.Exception.Message)"
    }
}
$finance = $baseConfig.ad.groupMap.FinanceAccess
$it = $baseConfig.ad.groupMap.ITAccess

Check 'Joiner plans creation and only the Finance grant' {
    $context = Read-Context
    $plan = @(New-IamLifecyclePlan -Context $context -Snapshot (Make-Snapshot))
    Assert-Equal ($plan.Action -join ',') 'CreateUser,AddGroupMember'
    Assert-Equal $plan[1].GroupDN $finance
    Assert-Equal $context.SamAccountName 'iam.lab001'
}
Check 'Mover removes old access before granting new access' {
    $plan = @(New-IamLifecyclePlan -Context (Read-Context 'JML-002') -Snapshot (Make-Snapshot (Make-User) @($finance)))
    Assert-Equal ($plan.Action -join ',') 'SetDepartment,RemoveGroupMember,AddGroupMember'
    Assert-Equal $plan[1].GroupDN $finance
    Assert-Equal $plan[2].GroupDN $it
}
Check 'Leaver disables before removing managed access' {
    $plan = @(New-IamLifecyclePlan -Context (Read-Context 'JML-003') -Snapshot (Make-Snapshot (Make-User) @($finance, $it)))
    Assert-Equal ($plan.Action -join ',') 'DisableUser,RemoveGroupMember,RemoveGroupMember'
}
Check 'Joiner repeat at its completed stage is a no-op' {
    Assert-Equal @(New-IamLifecyclePlan -Context (Read-Context) -Snapshot (Make-Snapshot (Make-User) @($finance))).Count 0
}
Check 'Mover repeat at its completed stage is a no-op' {
    Assert-Equal @(New-IamLifecyclePlan -Context (Read-Context 'JML-002') -Snapshot (Make-Snapshot (Make-User $true 'IT') @($it))).Count 0
}
Check 'Leaver repeat is a no-op and leaves unmanaged membership alone' {
    Assert-Equal @(New-IamLifecyclePlan -Context (Read-Context 'JML-003') -Snapshot (Make-Snapshot (Make-User $false 'IT') @('CN=Unmanaged,DC=balticfinance,DC=test'))).Count 0
}
Check 'Mover recovery plans only the missing new membership' {
    $plan = @(New-IamLifecyclePlan -Context (Read-Context 'JML-002') -Snapshot (Make-Snapshot (Make-User $true 'IT')))
    Assert-Equal ($plan.Action -join ',') 'AddGroupMember'
    Assert-Equal $plan[0].GroupDN $it
}
Check 'Disabled Joiner is rejected' {
    Assert-Throws { New-IamLifecyclePlan -Context (Read-Context) -Snapshot (Make-Snapshot (Make-User $false)) } 'cannot reactivate'
}
Check 'Disabled Mover is rejected' {
    Assert-Throws { New-IamLifecyclePlan -Context (Read-Context 'JML-002') -Snapshot (Make-Snapshot (Make-User $false)) } 'disabled account'
}
Check 'A stale Joiner cannot revert a later department' {
    Assert-Throws { New-IamLifecyclePlan -Context (Read-Context) -Snapshot (Make-Snapshot (Make-User $true 'IT')) } 'profile differs'
}
Check 'A target in the parent OU is rejected' {
    $user = Make-User
    $user.DistinguishedName = 'CN=iam.lab001,OU=IAM-Automation,DC=balticfinance,DC=test'
    Assert-Throws { New-IamLifecyclePlan -Context (Read-Context) -Snapshot (Make-Snapshot $user) } 'approved lifecycle account DN'
}
Check 'An escaped-comma DN cannot fake the OU boundary' {
    $user = Make-User
    $user.DistinguishedName = 'CN=iam.lab001\,OU=JML,OU=IAM-Automation,DC=balticfinance,DC=test'
    Assert-Throws { New-IamLifecyclePlan -Context (Read-Context) -Snapshot (Make-Snapshot $user) } 'approved lifecycle account DN'
}
Check 'EmployeeId mismatch is rejected' {
    $user = Make-User
    $user.EmployeeId = 'LAB-002'
    Assert-Throws { New-IamLifecyclePlan -Context (Read-Context) -Snapshot (Make-Snapshot $user) } 'identity does not match'
}
Check 'Protected accounts are rejected' {
    $user = Make-User
    $user.AdminCount = 1
    Assert-Throws { New-IamLifecyclePlan -Context (Read-Context) -Snapshot (Make-Snapshot $user) } 'protected or critical'
}
Check 'Critical system objects are rejected' {
    $user = Make-User
    $user.IsCriticalSystemObject = $true
    Assert-Throws { New-IamLifecyclePlan -Context (Read-Context) -Snapshot (Make-Snapshot $user) } 'protected or critical'
}
Check 'Wrong-domain snapshots are rejected' {
    $snapshot = Make-Snapshot
    $snapshot.Domain = 'other.test'
    Assert-Throws { New-IamLifecyclePlan -Context (Read-Context) -Snapshot $snapshot } 'Snapshot domain or OU'
}
Check 'Mover with no matching identity is rejected' {
    Assert-Throws { New-IamLifecyclePlan -Context (Read-Context 'JML-002') -Snapshot (Make-Snapshot) } 'existing matching account'
}
Check 'Leaver with no matching identity is rejected' {
    Assert-Throws { New-IamLifecyclePlan -Context (Read-Context 'JML-003') -Snapshot (Make-Snapshot) } 'existing matching account'
}
Check 'Duplicate event IDs are rejected' {
    @($baseCsv + $baseCsv[1]) | Set-Content -LiteralPath $inputPaths.EventsPath -Encoding UTF8
    Assert-Throws { Read-Context } 'duplicate EventId'
}
Check 'Invalid lab employee identifiers are rejected before directory reads' {
    $bad = $baseCsv -replace 'LAB-001', "LAB-001' -or Name -like '*'"
    $bad | Set-Content -LiteralPath $inputPaths.EventsPath -Encoding UTF8
    Assert-Throws { Read-Context } 'Invalid lab EmployeeId'
}
Check 'Unknown departments are rejected' {
    ($baseCsv -replace ',Finance$', ',Unknown') | Set-Content -LiteralPath $inputPaths.EventsPath -Encoding UTF8
    Assert-Throws { Read-Context } 'Unknown department'
}
Check 'Unsupported event types are rejected' {
    ($baseCsv -replace ',Joiner,', ',Rehire,') | Set-Content -LiteralPath $inputPaths.EventsPath -Encoding UTF8
    Assert-Throws { Read-Context } 'Unknown event type'
}
Check 'Unknown EventId arguments are rejected' {
    Assert-Throws { Read-Context 'JML-999' } 'Expected one HR event'
}
Check 'Broadened user OU configuration is rejected' {
    $cfg = Get-Content -LiteralPath $inputPaths.ConfigPath -Raw | ConvertFrom-Json
    $cfg.ad.testOu = 'OU=IAM-Automation,DC=balticfinance,DC=test'
    $cfg | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $inputPaths.ConfigPath -Encoding UTF8
    Assert-Throws { Read-Context } 'account boundary must be'
}
Check 'A privileged group mapping is rejected' {
    $cfg = Get-Content -LiteralPath $inputPaths.ConfigPath -Raw | ConvertFrom-Json
    $cfg.ad.groupMap.FinanceAccess = 'CN=Domain Admins,CN=Users,DC=balticfinance,DC=test'
    $cfg | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $inputPaths.ConfigPath -Encoding UTF8
    Assert-Throws { Read-Context } 'lab group boundary'
}
Check 'Unexpected HR columns are rejected' {
    ($baseCsv -replace '^EventId,', 'Extra,') | Set-Content -LiteralPath $inputPaths.EventsPath -Encoding UTF8
    Assert-Throws { Read-Context } 'Unexpected HR CSV columns'
}

# Integration checks use a mutable in-memory AD adapter.
$fakeRoot = Join-Path $testRoot 'modules\ActiveDirectory'
$null = New-Item -ItemType Directory -Path $fakeRoot -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'fixtures/ActiveDirectory.psm1') -Destination (Join-Path $fakeRoot 'ActiveDirectory.psm1') -Force
$env:PSModulePath = (Join-Path $testRoot 'modules') + [IO.Path]::PathSeparator + $env:PSModulePath
Import-Module (Join-Path $fakeRoot 'ActiveDirectory.psm1') -Force
$testPassword = ConvertTo-SecureString 'Offline-Synthetic-Only!8x' -AsPlainText -Force
function Run-Event {
    param([string]$Id = 'JML-001',[switch]$Apply,[switch]$WhatIf,[switch]$Password,[switch]$Inject)
    $script:lastLog = Join-Path $testRoot ([guid]::NewGuid().ToString('N') + '.csv')
    $parameters = @{
        Context = (Read-Context $Id); LogPath = $script:lastLog
        RunId = [guid]::NewGuid().ToString('N'); Apply = [bool]$Apply
        WhatIf = [bool]$WhatIf; Confirm = $false; SimulateFailureAfterRemoval = [bool]$Inject
    }
    if ($Password) { $parameters.InitialPassword = $testPassword }
    Invoke-IamLifecycleEvent @parameters
}
function Seed-User([string]$Department = 'Finance',[bool]$Enabled = $true,[string[]]$Memberships = @($finance)) {
    Reset-FakeAd
    $state = Get-FakeAd
    $state.User = Make-User $Enabled $Department
    $state.User | Add-Member -NotePropertyName UserPrincipalName -NotePropertyValue 'iam.lab001@balticfinance.test'
    $state.Memberships = @($Memberships)
}
function Assert-NoWrites { Assert-Equal (Get-FakeAd).Calls.Count 0 }
Check 'Both source files parse in this PowerShell engine' {
    foreach ($path in @($modulePath,$driverPath)) {
        $tokens = $null; $errors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile($path,[ref]$tokens,[ref]$errors)
        Assert-Equal @($errors).Count 0
    }
}
Check 'Default preview logs plans with no password and zero writes' {
    Reset-FakeAd
    $result = Run-Event
    Assert-Equal $result.Mode 'Preview'
    Assert-Equal $result.PlannedOperations 2
    Assert-Equal $result.ManagedStateUnchanged $true
    Assert-Equal $result.UserExistsAfter $false
    Assert-NoWrites
    Assert-Equal @((Import-Csv $script:lastLog) | Where-Object Status -eq Planned).Count 2
}
Check 'Joiner WhatIf never prompts for a password or calls any writer' {
    Reset-FakeAd
    $result = Run-Event -Apply -WhatIf
    Assert-Equal $result.Mode 'WhatIf'
    Assert-Equal $result.AppliedOperations 0
    Assert-Equal $result.RemainingOperations 2
    Assert-Equal $result.ManagedStateUnchanged $true
    Assert-NoWrites
    Assert-Equal @((Import-Csv $script:lastLog) | Where-Object Status -eq WhatIf).Count 2
}
Check 'Joiner creates correct user then grants only Finance' {
    Reset-FakeAd
    $result = Run-Event -Apply -Password
    $state = Get-FakeAd
    Assert-Equal ($state.Calls -join ',') 'New-ADUser,Add-ADGroupMember'
    Assert-Equal $state.User.DistinguishedName ('CN=iam.lab001,' + $baseConfig.ad.testOu)
    Assert-Equal $state.User.UserPrincipalName 'iam.lab001@balticfinance.test'
    Assert-Equal $state.User.Enabled $true
    Assert-Equal $state.User.EmployeeID 'LAB-001'
    Assert-Equal ($state.Memberships -join ',') $finance
    Assert-Equal $result.AppliedOperations 2
    Assert-Equal $result.RemainingOperations 0
    Assert-Equal $result.Status 'Completed'
    Assert-Equal @((Import-Csv $script:lastLog) | Where-Object Status -eq Applied).Count 2
}
Check 'Completed Joiner repeat is NoChange with no password' {
    Seed-User
    $result = Run-Event -Apply
    Assert-Equal $result.Status 'NoChange'
    Assert-NoWrites
}
Check 'Mover applies department then revokes old group before grant' {
    Seed-User
    $result = Run-Event 'JML-002' -Apply
    $state = Get-FakeAd
    Assert-Equal ($state.Calls -join ',') 'Set-ADUser,Remove-ADGroupMember,Add-ADGroupMember'
    Assert-Equal $state.User.Department 'IT'
    Assert-Equal ($state.Memberships -join ',') $it
    Assert-Equal $result.AppliedOperations 3
    Assert-Equal $result.RemainingOperations 0
}
Check 'Completed Mover repeat is NoChange' {
    Seed-User 'IT' $true @($it)
    $result = Run-Event 'JML-002' -Apply
    Assert-Equal $result.Status 'NoChange'
    Assert-NoWrites
}
Check 'Leaver disables first and preserves unrelated group membership' {
    Seed-User 'IT' $true @($it,'CN=Unmanaged,DC=balticfinance,DC=test')
    $result = Run-Event 'JML-003' -Apply
    $state = Get-FakeAd
    Assert-Equal ($state.Calls -join ',') 'Disable-ADAccount,Remove-ADGroupMember'
    Assert-Equal $state.User.Enabled $false
    Assert-Equal ($state.Memberships -join ',') 'CN=Unmanaged,DC=balticfinance,DC=test'
    Assert-Equal $result.RemainingOperations 0
}
Check 'Completed Leaver repeat is NoChange' {
    Seed-User 'IT' $false @()
    $result = Run-Event 'JML-003' -Apply
    Assert-Equal $result.Status 'NoChange'
    Assert-NoWrites
}
Check 'Mover and Leaver WhatIf preserve complete target state' {
    foreach ($id in @('JML-002','JML-003')) {
        Seed-User
        $result = Run-Event $id -Apply -WhatIf
        Assert-Equal $result.ManagedStateUnchanged $true
        Assert-Equal $result.AppliedOperations 0
        Assert-NoWrites
    }
}
Check 'Partial Mover failure records successful revocation and retry only grants IT' {
    Seed-User
    Assert-Throws { Run-Event 'JML-002' -Apply -Inject } 'Injected failure'
    $rows = @(Import-Csv $script:lastLog)
    Assert-Equal @($rows | Where-Object { $_.Action -eq 'RemoveGroupMember' -and $_.Status -eq 'Applied' }).Count 1
    Assert-Equal @($rows | Where-Object Status -eq Failed).Count 0
    Assert-Equal (Get-FakeAd).User.Department 'IT'
    Assert-Equal (Get-FakeAd).Memberships.Count 0
    (Get-FakeAd).Calls = @()
    $result = Run-Event 'JML-002' -Apply
    Assert-Equal ((Get-FakeAd).Calls -join ',') 'Add-ADGroupMember'
    Assert-Equal $result.PlannedOperations 1
    Assert-Equal $result.RemainingOperations 0
}
Check 'Outside-OU target never reaches an AD write' {
    Seed-User
    (Get-FakeAd).User.DistinguishedName = 'CN=iam.lab001,OU=BFL,DC=balticfinance,DC=test'
    Assert-Throws { Run-Event 'JML-003' -Apply } 'approved lifecycle account DN'
    Assert-NoWrites
}
Check 'Multiple matching identities never reach an AD write' {
    Seed-User
    (Get-FakeAd).ExtraUsers = @(Make-User)
    Assert-Throws { Run-Event -Apply -Password } 'Multiple AD accounts'
    Assert-NoWrites
}
Check 'Protected live user never reaches an AD write' {
    Seed-User
    (Get-FakeAd).User.AdminCount = 1
    Assert-Throws { Run-Event 'JML-003' -Apply } 'protected or critical'
    Assert-NoWrites
}
Check 'Replaced account between plan and execution stops before writes' {
    Seed-User
    (Get-FakeAd).ReplaceUserAtRead = 2
    Assert-Throws { Run-Event 'JML-002' -Apply } 'bound account was removed or replaced'
    Assert-NoWrites
}
Check 'Group replacement after creation prevents access grant' {
    Reset-FakeAd
    (Get-FakeAd).ReplaceGroupAfterCreate = $true
    Assert-Throws { Run-Event -Apply -Password } 'managed group was moved'
    Assert-Equal ((Get-FakeAd).Calls -join ',') 'New-ADUser'
}
Check 'User replacement after department update prevents subsequent group writes' {
    Seed-User
    (Get-FakeAd).ReplaceUserAfterSet = $true
    Assert-Throws { Run-Event 'JML-002' -Apply } 'bound account was removed or replaced'
    Assert-Equal ((Get-FakeAd).Calls -join ',') 'Set-ADUser'
}
Check 'Failed revocation stops before adding new access and is audited' {
    Seed-User
    (Get-FakeAd).FaultAction = 'Remove-ADGroupMember'
    Assert-Throws { Run-Event 'JML-002' -Apply } 'Simulated Remove-ADGroupMember failure'
    Assert-Equal ((Get-FakeAd).Calls -join ',') 'Set-ADUser,Remove-ADGroupMember'
    Assert-Equal ((Get-FakeAd).Memberships -join ',') $finance
    Assert-Equal @((Import-Csv $script:lastLog) | Where-Object { $_.Action -eq 'RemoveGroupMember' -and $_.Status -eq 'Failed' }).Count 1
}
Check 'Read-back catches a writer that silently ignored the requested change' {
    Seed-User
    (Get-FakeAd).IgnoreAction = 'Set-ADUser'
    Assert-Throws { Run-Event 'JML-002' -Apply } 'Department read-back failed'
    Assert-Equal ((Get-FakeAd).Calls -join ',') 'Set-ADUser'
}
Check 'Unavailable audit destination prevents every AD write' {
    Seed-User
    $badLog = Join-Path $testRoot ('absent-' + [guid]::NewGuid().ToString('N') + '\run.csv')
    Assert-Throws {
        Invoke-IamLifecycleEvent -Context (Read-Context 'JML-002') -LogPath $badLog -RunId test -Apply -Confirm:$false
    } ''
    Assert-NoWrites
}
Check 'Audit contains no password field or synthetic secret and preserves caller SecureString' {
    Reset-FakeAd
    $null = Run-Event -Apply -Password
    $raw = Get-Content $script:lastLog -Raw
    if ($raw -match 'Offline-Synthetic-Only|AccountPassword|InitialPassword') { throw 'Password data leaked into audit.' }
    Assert-Equal $testPassword.Length 25
}
Check 'Driver forwards WhatIf and writes a completed read-only audit' {
    Reset-FakeAd
    $out = Join-Path $testRoot ('driver-' + [guid]::NewGuid().ToString('N'))
    $output = & $driverPath -EventId JML-001 @inputPaths -OutputDirectory $out -Apply -WhatIf | Out-String -Width 200
    if ($output -notmatch 'Mode\s*:\s*WhatIf' -or $output -notmatch 'ManagedStateUnchanged\s*:\s*True') { throw "Unexpected driver result: $output" }
    Assert-NoWrites
    $logs = @(Get-ChildItem -LiteralPath $out -Filter '*.csv')
    Assert-Equal $logs.Count 1
    $rows = @(Import-Csv $logs[0].FullName)
    Assert-Equal $rows[-1].Status 'WhatIf'
    Assert-Equal @($rows | Where-Object { $_.Action -ne 'Run' -and $_.Status -eq 'WhatIf' }).Count 2
}
Check 'Driver logs input failure before any directory write' {
    Reset-FakeAd
    $out = Join-Path $testRoot ('invalid-' + [guid]::NewGuid().ToString('N'))
    Assert-Throws { & $driverPath -EventId JML-999 @inputPaths -OutputDirectory $out -Apply } 'Expected one HR event'
    Assert-NoWrites
    $log = @(Get-ChildItem -LiteralPath $out -Filter '*.csv')[0]
    Assert-Equal @(Import-Csv $log.FullName)[-1].Status 'Failed'
}
Check 'Driver audits injected run failure without relabeling the completed removal' {
    Seed-User
    $out = Join-Path $testRoot ('partial-' + [guid]::NewGuid().ToString('N'))
    Assert-Throws { & $driverPath -EventId JML-002 @inputPaths -OutputDirectory $out -Apply -SimulateFailureAfterRemoval } 'Injected failure'
    $log = @(Get-ChildItem -LiteralPath $out -Filter '*.csv')[0]
    $rows = @(Import-Csv $log.FullName)
    Assert-Equal $rows[-1].Status 'Failed'
    Assert-Equal $rows[-1].Action 'Run'
    Assert-Equal @($rows | Where-Object { $_.Action -eq 'RemoveGroupMember' -and $_.Status -eq 'Applied' }).Count 1
    Assert-Equal @($rows | Where-Object { $_.Action -eq 'RemoveGroupMember' -and $_.Status -eq 'Failed' }).Count 0
}
$testPassword.Dispose()
Remove-Module ActiveDirectory -Force
Write-Output ("PowerShell {0}: {1} passed, {2} failed." -f $PSVersionTable.PSVersion,$script:passed,$script:failed)
if ($script:failed -gt 0) { throw 'Lifecycle validation failed.' }


