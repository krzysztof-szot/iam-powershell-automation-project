#requires -Version 5.1
Set-StrictMode -Version 2.0

function Get-IamField {
    param([object]$Object, [string]$Name)
    if ($null -eq $Object -or $null -eq $Object.PSObject.Properties[$Name]) {
        throw "Missing input field: $Name."
    }
    return $Object.PSObject.Properties[$Name].Value
}

function Get-IamText {
    param([object]$Object, [string]$Name)
    $value = Get-IamField $Object $Name
    if ($value -isnot [string] -or [string]::IsNullOrWhiteSpace($value)) {
        throw "Expected non-empty text in field: $Name."
    }
    return $value.Trim()
}

function Get-IamOptionalField {
    param([object]$Object, [string]$Name, [object]$Default = $null)
    $property = if ($null -eq $Object) { $null } else { $Object.PSObject.Properties[$Name] }
    if ($null -eq $property -or $null -eq $property.Value) { return $Default }
    return $property.Value
}

function Read-IamLifecycleInput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$EventId,
        [Parameter(Mandatory = $true)][string]$EventsPath,
        [Parameter(Mandatory = $true)][string]$ConfigPath,
        [Parameter(Mandatory = $true)][string]$MatrixPath
    )
    $ErrorActionPreference = 'Stop'
    $config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    $matrix = Get-Content -LiteralPath $MatrixPath -Raw | ConvertFrom-Json
    if ((Get-IamField $config 'schemaVersion') -ne 1 -or
        (Get-IamField $matrix 'schemaVersion') -ne 1) {
        throw 'Unsupported configuration or matrix schemaVersion.'
    }
    $ad = Get-IamField $config 'ad'
    $domain = (Get-IamText $ad 'domain').ToLowerInvariant()
    $server = Get-IamText $ad 'server'
    if ($domain.Length -gt 253 -or $domain -notmatch '^[a-z0-9-]+(\.[a-z0-9-]+)+$' -or
        $server -notmatch '^[a-z0-9.-]+$' -or
        -not $server.EndsWith(".$domain", [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Expected a lab DNS domain and a server FQDN in that domain.'
    }
    $domainDn = ($domain.Split('.') | ForEach-Object { "DC=$_" }) -join ','
    $parentOu = "OU=IAM-Automation,$domainDn"
    $expectedOu = "OU=JML,$parentOu"
    if ((Get-IamText $ad 'testOu') -ine $expectedOu) {
        throw "The lifecycle account boundary must be $expectedOu."
    }
    $groupMap = Get-IamField $ad 'groupMap'
    $expectedGroups = [ordered]@{
        FinanceAccess = 'GG-IAM-LAB-Finance'
        ITAccess = 'GG-IAM-LAB-IT'
    }
    $keys = @($groupMap.PSObject.Properties.Name)
    if ($keys.Count -ne 2) { throw 'Expected exactly the two managed lab group mappings.' }
    $managedDns = @()
    foreach ($key in $expectedGroups.Keys) {
        $dn = Get-IamText $groupMap $key
        if ($dn -ine "CN=$($expectedGroups[$key]),$parentOu") {
            throw "Group mapping $key is outside the expected lab group boundary."
        }
        $managedDns += $dn
    }
    $departments = Get-IamField $matrix 'departments'
    foreach ($department in @($departments.PSObject.Properties)) {
        if ([string]::IsNullOrWhiteSpace($department.Name)) { throw 'Empty department key.' }
        $entitlements = @($department.Value)
        if ($entitlements.Count -eq 0) { throw "Empty policy for $($department.Name)." }
        foreach ($entitlement in $entitlements) {
            if ($entitlement -isnot [string] -or $entitlement -notin @($expectedGroups.Keys)) {
                throw "Unknown entitlement in department $($department.Name)."
            }
        }
    }
    $events = @(Import-Csv -LiteralPath $EventsPath)
    if ($events.Count -eq 0) { throw 'The HR feed is empty.' }
    $headers = @($events[0].PSObject.Properties.Name)
    $requiredHeaders = @('EventId', 'EventType', 'EmployeeId', 'GivenName', 'Surname', 'Department')
    if ($headers.Count -ne $requiredHeaders.Count -or
        @($requiredHeaders | Where-Object { $_ -notin $headers }).Count -gt 0) {
        throw 'Unexpected HR CSV columns.'
    }
    $seen = @{}
    $normalizedEvents = @()
    foreach ($row in $events) {
        $id = Get-IamText $row 'EventId'
        if ($id -notmatch '^[A-Z0-9][A-Z0-9._-]{0,63}$' -or $seen.ContainsKey($id)) {
            throw "Invalid or duplicate EventId: $id."
        }
        $seen[$id] = $true
        $type = Get-IamText $row 'EventType'
        if ($type -notin @('Joiner', 'Mover', 'Leaver')) { throw "Unknown event type: $type." }
        $employee = (Get-IamText $row 'EmployeeId').ToUpperInvariant()
        if ($employee -cnotmatch '^LAB-[0-9]{3}$') { throw "Invalid lab EmployeeId: $employee." }
        $given = ([string](Get-IamField $row 'GivenName')).Trim()
        $surname = ([string](Get-IamField $row 'Surname')).Trim()
        if ($type -eq 'Joiner' -and
            ([string]::IsNullOrWhiteSpace($given) -or [string]::IsNullOrWhiteSpace($surname) -or
             $given.Length -gt 64 -or $surname.Length -gt 64)) {
            throw 'Joiner requires GivenName and Surname of at most 64 characters.'
        }
        $department = ([string](Get-IamField $row 'Department')).Trim()
        if ($type -eq 'Leaver') {
            if ($department.Length -gt 0) { throw 'Leaver Department must be empty.' }
        } else {
            $policy = @($departments.PSObject.Properties | Where-Object { $_.Name -ieq $department })
            if ($policy.Count -ne 1) { throw "Unknown department: $department." }
            $department = $policy[0].Name
        }
        $normalizedEvents += [pscustomobject]@{
            EventId = $id; EventType = $type; EmployeeId = $employee
            GivenName = $given; Surname = $surname; Department = $department
        }
    }
    $selected = @($normalizedEvents | Where-Object { $_.EventId -ieq $EventId })
    if ($selected.Count -ne 1) { throw "Expected one HR event for EventId=$EventId." }
    $event = $selected[0]
    $sam = 'iam.' + $event.EmployeeId.Replace('-', '').ToLowerInvariant()
    $desiredDns = @()
    if ($event.EventType -ne 'Leaver') {
        foreach ($key in @($departments.PSObject.Properties[$event.Department].Value)) {
            $desiredDns += [string]$groupMap.PSObject.Properties[$key].Value
        }
        $desiredDns = @($desiredDns | Select-Object -Unique)
    }
    return [pscustomobject]@{
        Event = $event; Config = $config; Matrix = $matrix; DomainDn = $domainDn
        SamAccountName = $sam; UserPrincipalName = "$sam@$domain"
        ManagedGroupDns = @($managedDns); DesiredGroupDns = @($desiredDns)
    }
}

function Assert-IamUserScope {
    param([object]$Context, [object]$User)
    if ($null -eq $User) { return }
    $ou = [string]$Context.Config.ad.testOu
    $expectedDn = "CN=$($Context.SamAccountName),$ou"
    if ($User.DistinguishedName -ine $expectedDn) {
        throw 'The resolved account DN differs from the approved lifecycle account DN.'
    }
    if ($User.SamAccountName -ine $Context.SamAccountName -or
        $User.EmployeeId -ine $Context.Event.EmployeeId) {
        throw 'EmployeeId, SAM name or UPN collision: account identity does not match.'
    }
    if ($User.AdminCount -eq 1 -or $User.IsCriticalSystemObject -eq $true) {
        throw 'A protected or critical account cannot be a lifecycle lab target.'
    }
}

function Get-IamAdSnapshot {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][object]$Context)
    $ErrorActionPreference = 'Stop'
    Import-Module ActiveDirectory -ErrorAction Stop
    $server = [string]$Context.Config.ad.server
    $domain = Get-ADDomain -Server $server -ErrorAction Stop
    if ($domain.DNSRoot -ine $Context.Config.ad.domain) { throw 'Connected AD domain differs from configuration.' }
    $ou = Get-ADOrganizationalUnit -Identity $Context.Config.ad.testOu -Server $server -ErrorAction Stop
    $groups = @()
    foreach ($dn in $Context.ManagedGroupDns) {
        $group = Get-ADGroup -Identity $dn -Server $server -ErrorAction Stop
        if ($group.GroupCategory -ne 'Security' -or $group.DistinguishedName -ine $dn) {
            throw 'A managed group is not the configured security group.'
        }
        $groups += [pscustomobject]@{ DistinguishedName = $group.DistinguishedName; ObjectGUID = $group.ObjectGUID.ToString() }
    }
    $filter = "EmployeeID -eq '$($Context.Event.EmployeeId)' -or SamAccountName -eq '$($Context.SamAccountName)' -or UserPrincipalName -eq '$($Context.UserPrincipalName)'"
    $query = @{
        Filter = $filter; SearchBase = $domain.DistinguishedName; Server = $server
        Properties = @('EmployeeID', 'Department', 'GivenName', 'Surname', 'adminCount', 'isCriticalSystemObject')
        ErrorAction = 'Stop'
    }
    $candidates = @(Get-ADUser @query)
    if ($candidates.Count -gt 1) { throw 'Multiple AD accounts match the lifecycle identity.' }
    $user = $null
    $memberships = @()
    if ($candidates.Count -eq 1) {
        $adUser = $candidates[0]
        $user = [pscustomobject]@{
            ObjectGUID = $adUser.ObjectGUID.ToString(); DistinguishedName = $adUser.DistinguishedName
            SamAccountName = $adUser.SamAccountName; EmployeeId = [string]$adUser.EmployeeID
            Enabled = [bool]$adUser.Enabled; Department = [string]$adUser.Department
            GivenName = [string]$adUser.GivenName; Surname = [string]$adUser.Surname
            UserPrincipalName = [string]$adUser.UserPrincipalName
            AdminCount = (Get-IamOptionalField $adUser 'adminCount' 0)
            IsCriticalSystemObject = [bool](Get-IamOptionalField $adUser 'isCriticalSystemObject' $false)
        }
        Assert-IamUserScope $Context $user
        foreach ($group in $groups) {
            $members = @(Get-ADGroupMember -Identity $group.ObjectGUID -Server $server -ErrorAction Stop)
            if (@($members | Where-Object { $_.ObjectGUID.ToString() -eq $user.ObjectGUID }).Count -gt 0) {
                $memberships += $group.DistinguishedName
            }
        }
    }
    return [pscustomobject]@{
        Domain = $domain.DNSRoot; TestOU = $ou.DistinguishedName
        Groups = @($groups); User = $user; DirectGroupDns = @($memberships)
    }
}

function New-IamLifecyclePlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][object]$Context,
        [Parameter(Mandatory = $true)][object]$Snapshot
    )
    $ErrorActionPreference = 'Stop'
    if ($Snapshot.Domain -ine $Context.Config.ad.domain -or $Snapshot.TestOU -ine $Context.Config.ad.testOu) {
        throw 'Snapshot domain or OU differs from the approved configuration.'
    }
    $user = $Snapshot.User
    Assert-IamUserScope $Context $user
    $event = $Context.Event
    $steps = New-Object 'System.Collections.Generic.List[object]'
    $current = @($Snapshot.DirectGroupDns | Where-Object { $_ -in $Context.ManagedGroupDns })
    $desired = @($Context.DesiredGroupDns)
    if ($event.EventType -eq 'Joiner') {
        if ($null -eq $user) {
            [void]$steps.Add([pscustomobject]@{
                Action = 'CreateUser'; Target = $Context.SamAccountName
                Value = "Department=$($event.Department)"; GroupDN = ''
            })
        } else {
            if (-not $user.Enabled) { throw 'Joiner cannot reactivate an existing disabled account.' }
            if ($user.Department -ine $event.Department -or
                $user.GivenName -ine $event.GivenName -or $user.Surname -ine $event.Surname) {
                throw 'Existing account profile differs from the Joiner event.'
            }
            if (@($current | Where-Object { $_ -notin $desired }).Count -gt 0) {
                throw 'Joiner found unexpected managed access; review the lifecycle stage.'
            }
        }
    } elseif ($event.EventType -eq 'Mover') {
        if ($null -eq $user) { throw 'Mover requires an existing matching account.' }
        if (-not $user.Enabled) { throw 'Mover cannot modify a disabled account.' }
        if ($user.Department -ine $event.Department) {
            [void]$steps.Add([pscustomobject]@{
                Action = 'SetDepartment'; Target = $Context.SamAccountName
                Value = $event.Department; GroupDN = ''
            })
        }
    } elseif ($event.EventType -eq 'Leaver') {
        if ($null -eq $user) { throw 'Leaver requires an existing matching account.' }
        if ($user.Enabled) {
            [void]$steps.Add([pscustomobject]@{
                Action = 'DisableUser'; Target = $Context.SamAccountName
                Value = 'Enabled=False'; GroupDN = ''
            })
        }
    } else {
        throw 'Unsupported event type.'
    }
    if ($event.EventType -in @('Mover', 'Leaver')) {
        foreach ($dn in @($current | Where-Object { $_ -notin $desired })) {
            [void]$steps.Add([pscustomobject]@{
                Action = 'RemoveGroupMember'; Target = ($dn -split ',', 2)[0].Substring(3)
                Value = $Context.SamAccountName; GroupDN = $dn
            })
        }
    }
    if ($event.EventType -ne 'Leaver') {
        foreach ($dn in @($desired | Where-Object { $_ -notin $current })) {
            [void]$steps.Add([pscustomobject]@{
                Action = 'AddGroupMember'; Target = ($dn -split ',', 2)[0].Substring(3)
                Value = $Context.SamAccountName; GroupDN = $dn
            })
        }
    }
    $number = 0
    foreach ($step in $steps) {
        $number++
        [pscustomobject]@{
            Step = $number; EventId = $event.EventId; EventType = $event.EventType
            EmployeeId = $event.EmployeeId; SamAccountName = $Context.SamAccountName
            Action = $step.Action; Target = $step.Target; Value = $step.Value; GroupDN = $step.GroupDN
        }
    }
}

function Write-IamRunRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$LogPath,
        [Parameter(Mandatory = $true)][string]$RunId,
        [Parameter(Mandatory = $true)][string]$EventId,
        [string]$EventType = '', [string]$EmployeeId = '', [string]$SamAccountName = '',
        [string]$Mode = 'Preview', [int]$Step = 0, [string]$Action = 'Run',
        [string]$Target = '', [string]$Value = '', [string]$Status = '', [string]$Message = ''
    )
    $ErrorActionPreference = 'Stop'
    $row = [pscustomobject]@{
        TimestampUtc = [DateTime]::UtcNow.ToString('o')
        RunId = $RunId; EventId = $EventId; EventType = $EventType
        EmployeeId = $EmployeeId; SamAccountName = $SamAccountName
        Operator = [Environment]::UserName; Computer = [Environment]::MachineName
        Mode = $Mode; Step = $Step; Action = $Action; Target = $Target
        Value = $Value; Status = $Status; Message = $Message
    }
    $parameters = @{
        LiteralPath = $LogPath; NoTypeInformation = $true; Encoding = 'UTF8'
        WhatIf = $false; Confirm = $false; ErrorAction = 'Stop'
    }
    if (Test-Path -LiteralPath $LogPath -PathType Leaf) { $parameters.Append = $true }
    $row | Export-Csv @parameters
}

function Assert-IamBoundSnapshot {
    param([object]$Baseline, [object]$Current, [string]$ExpectedUserGuid)
    foreach ($group in $Baseline.Groups) {
        $found = @($Current.Groups | Where-Object { $_.DistinguishedName -ieq $group.DistinguishedName })
        if ($found.Count -ne 1 -or $found[0].ObjectGUID -ine $group.ObjectGUID) {
            throw 'A managed group was moved, removed or replaced during the run.'
        }
    }
    if ([string]::IsNullOrEmpty($ExpectedUserGuid)) {
        if ($null -ne $Current.User) { throw 'An account appeared after planning. Review the new state and rerun.' }
    } elseif ($null -eq $Current.User -or $Current.User.ObjectGUID -ine $ExpectedUserGuid) {
        throw 'The bound account was removed or replaced during the run.'
    }
}

function Invoke-IamLifecycleEvent {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true)][object]$Context,
        [Parameter(Mandatory = $true)][string]$LogPath,
        [Parameter(Mandatory = $true)][string]$RunId,
        [switch]$Apply,
        [Security.SecureString]$InitialPassword,
        [switch]$SimulateFailureAfterRemoval
    )
    $ErrorActionPreference = 'Stop'
    $mode = if (-not $Apply) { 'Preview' } elseif ($WhatIfPreference) { 'WhatIf' } else { 'Apply' }
    if ($SimulateFailureAfterRemoval -and $Context.Event.EventType -ne 'Mover') {
        throw 'The failure exercise is supported only for a Mover event.'
    }
    $server = [string]$Context.Config.ad.server
    $before = Get-IamAdSnapshot -Context $Context
    $plan = @(New-IamLifecyclePlan -Context $Context -Snapshot $before)
    $expectedUserGuid = if ($null -eq $before.User) { '' } else { $before.User.ObjectGUID }
    $applied = 0
    $skipped = 0
    $baseRecord = @{
        LogPath = $LogPath; RunId = $RunId; EventId = $Context.Event.EventId
        EventType = $Context.Event.EventType; EmployeeId = $Context.Event.EmployeeId
        SamAccountName = $Context.SamAccountName; Mode = $mode
    }
    foreach ($step in $plan) {
        $record = @{}
        foreach ($key in $baseRecord.Keys) { $record[$key] = $baseRecord[$key] }
        $record.Step = $step.Step; $record.Action = $step.Action
        $record.Target = $step.Target; $record.Value = $step.Value
        if (-not $Apply) {
            Write-IamRunRecord @record -Status 'Planned'
            continue
        }
        if (-not $PSCmdlet.ShouldProcess($step.Target, "$($step.Action) for $($Context.SamAccountName)")) {
            $status = if ($WhatIfPreference) { 'WhatIf' } else { 'Skipped' }
            Write-IamRunRecord @record -Status $status
            $skipped++
            continue
        }
        $ownedPassword = $null
        try {
            $live = Get-IamAdSnapshot -Context $Context
            Assert-IamBoundSnapshot $before $live $expectedUserGuid
            $remaining = @(New-IamLifecyclePlan -Context $Context -Snapshot $live)
            $needed = @($remaining | Where-Object {
                $_.Action -eq $step.Action -and $_.GroupDN -ieq $step.GroupDN
            })
            if ($needed.Count -eq 0) {
                Write-IamRunRecord @record -Status 'NoChange' -Message 'Already satisfied on fresh read.'
                continue
            }
            Write-IamRunRecord @record -Status 'Started'
            switch ($step.Action) {
                'CreateUser' {
                    $password = $InitialPassword
                    if ($null -eq $password) {
                        $ownedPassword = Read-Host "Wpisz nowe haslo dla $($Context.SamAccountName)" -AsSecureString
                        $password = $ownedPassword
                    }
                    if ($password.Length -eq 0) { throw 'The initial password is empty.' }
                    $check = Get-IamAdSnapshot -Context $Context
                    Assert-IamBoundSnapshot $before $check ''
                    $newUserParameters = @{
                        Name = $Context.SamAccountName; SamAccountName = $Context.SamAccountName
                        UserPrincipalName = $Context.UserPrincipalName
                        GivenName = $Context.Event.GivenName; Surname = $Context.Event.Surname
                        DisplayName = "$($Context.Event.GivenName) $($Context.Event.Surname)"
                        EmployeeID = $Context.Event.EmployeeId; Department = $Context.Event.Department
                        Description = "IAM-Automation JML: $($Context.Event.EmployeeId), $($Context.Event.EventId)"
                        Path = $Context.Config.ad.testOu; AccountPassword = $password
                        Enabled = $true; ChangePasswordAtLogon = $false
                        Server = $server; PassThru = $true; Confirm = $false; ErrorAction = 'Stop'
                    }
                    $created = New-ADUser @newUserParameters
                    if ($null -eq $created -or $null -eq $created.ObjectGUID) {
                        throw 'Creation did not return an account identifier. Inspect AD before retrying.'
                    }
                    $expectedUserGuid = $created.ObjectGUID.ToString()
                }
                'SetDepartment' {
                    if ($null -eq $live.User) { throw 'The target account is absent.' }
                    Set-ADUser -Identity $expectedUserGuid -Server $server -Department $Context.Event.Department -Confirm:$false -ErrorAction Stop
                }
                'DisableUser' {
                    if ($null -eq $live.User) { throw 'The target account is absent.' }
                    Disable-ADAccount -Identity $expectedUserGuid -Server $server -Confirm:$false -ErrorAction Stop
                }
                { $_ -in @('AddGroupMember', 'RemoveGroupMember') } {
                    if ($null -eq $live.User) { throw 'The target account is absent; complete account creation first.' }
                    $group = @($live.Groups | Where-Object { $_.DistinguishedName -ieq $step.GroupDN })
                    if ($group.Count -ne 1) { throw 'Managed group binding is ambiguous.' }
                    $memberParameters = @{
                        Identity = $group[0].ObjectGUID; Members = $expectedUserGuid
                        Server = $server; Confirm = $false; ErrorAction = 'Stop'
                    }
                    if ($step.Action -eq 'AddGroupMember') { Add-ADGroupMember @memberParameters }
                    else { Remove-ADGroupMember @memberParameters }
                }
                default { throw 'Unsupported write operation.' }
            }
            $verified = Get-IamAdSnapshot -Context $Context
            Assert-IamBoundSnapshot $before $verified $expectedUserGuid
            switch ($step.Action) {
                'CreateUser' {
                    if (-not $verified.User.Enabled -or
                        $verified.User.Department -ine $Context.Event.Department -or
                        $verified.User.UserPrincipalName -ine $Context.UserPrincipalName -or
                        $verified.User.GivenName -ine $Context.Event.GivenName -or
                        $verified.User.Surname -ine $Context.Event.Surname) {
                        throw 'Created account read-back differs from the requested profile.'
                    }
                }
                'SetDepartment' {
                    if ($verified.User.Department -ine $Context.Event.Department) { throw 'Department read-back failed.' }
                }
                'DisableUser' {
                    if ($verified.User.Enabled) { throw 'Disabled state read-back failed.' }
                }
                'AddGroupMember' {
                    if ($step.GroupDN -notin @($verified.DirectGroupDns)) { throw 'Membership addition read-back failed.' }
                }
                'RemoveGroupMember' {
                    if ($step.GroupDN -in @($verified.DirectGroupDns)) { throw 'Membership removal read-back failed.' }
                }
            }
            Write-IamRunRecord @record -Status 'Applied' -Message 'Fresh read-back passed.'
            $applied++
        } catch {
            $originalError = $_
            try { Write-IamRunRecord @record -Status 'Failed' -Message $originalError.Exception.Message } catch { }
            throw $originalError
        } finally {
            if ($null -ne $ownedPassword) { $ownedPassword.Dispose() }
        }
        if ($SimulateFailureAfterRemoval -and $step.Action -eq 'RemoveGroupMember') {
            throw 'Injected failure after managed group removal.'
        }
    }
    $after = Get-IamAdSnapshot -Context $Context
    Assert-IamBoundSnapshot $before $after $expectedUserGuid
    $remaining = @(New-IamLifecyclePlan -Context $Context -Snapshot $after)
    $same = [string]::Equals(
        ($before | ConvertTo-Json -Depth 8 -Compress),
        ($after | ConvertTo-Json -Depth 8 -Compress), [StringComparison]::Ordinal
    )
    if ($mode -in @('Preview', 'WhatIf') -and -not $same) {
        throw 'Managed AD state changed during a read-only run. Investigate before proceeding.'
    }
    if ($mode -eq 'Apply' -and $skipped -eq 0 -and $remaining.Count -gt 0) {
        throw 'The final state still requires operations. Review the log and a new preview.'
    }
    $runStatus = if ($mode -ne 'Apply') { $mode } elseif ($skipped -gt 0) {
        'Cancelled'
    } elseif ($applied -eq 0) { 'NoChange' } else { 'Completed' }
    if ($plan.Count -eq 0) {
        Write-IamRunRecord @baseRecord -Action 'NoChange' -Status 'NoChange' -Target $Context.SamAccountName
    }
    $department = if ($null -eq $after.User) { '' } else { $after.User.Department }
    $enabled = if ($null -eq $after.User) { $null } else { $after.User.Enabled }
    return [pscustomobject]@{
        ScriptVersion = '0.2.0'; Mode = $mode; Status = $runStatus; RunId = $RunId
        EventId = $Context.Event.EventId; EventType = $Context.Event.EventType
        EmployeeId = $Context.Event.EmployeeId; SamAccountName = $Context.SamAccountName
        TargetOU = $Context.Config.ad.testOu
        UserExistsBefore = $null -ne $before.User; UserExistsAfter = $null -ne $after.User
        PlannedOperations = $plan.Count; AppliedOperations = $applied
        RemainingOperations = $remaining.Count; ManagedStateUnchanged = $same
        AccountEnabledAfter = $enabled; DepartmentAfter = $department
        ManagedGroupsAfter = @($after.DirectGroupDns | ForEach-Object { ($_ -split ',', 2)[0].Substring(3) })
        LogPath = $LogPath; Plan = @($plan)
    }
}

Export-ModuleMember -Function Read-IamLifecycleInput, Get-IamAdSnapshot, New-IamLifecyclePlan, Write-IamRunRecord, Invoke-IamLifecycleEvent
