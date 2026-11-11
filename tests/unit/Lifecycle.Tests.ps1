#requires -Version 5.1
# Pester 5 tests. All directory responses and writes stay in the simulated adapter.
BeforeAll {
    $script:iamRepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
    $script:iamTestRoot = Join-Path $TestDrive 'lifecycle'
    $null = New-Item -ItemType Directory -Path $script:iamTestRoot -Force
    $script:iamFinance = 'CN=GG-IAM-LAB-Finance,OU=IAM-Automation,DC=balticfinance,DC=test'
    $script:iamIT = 'CN=GG-IAM-LAB-IT,OU=IAM-Automation,DC=balticfinance,DC=test'
    $script:iamOU = 'OU=JML,OU=IAM-Automation,DC=balticfinance,DC=test'
    $script:iamBaseConfig = [ordered]@{
        schemaVersion = 1
        ad = [ordered]@{
            server = 'BFL-DC01.balticfinance.test'
            domain = 'balticfinance.test'
            testOu = $script:iamOU
            groupMap = [ordered]@{ FinanceAccess = $script:iamFinance; ITAccess = $script:iamIT }
        }
    }
    $script:iamBaseMatrix = [ordered]@{
        schemaVersion = 1
        departments = [ordered]@{ Finance = @('FinanceAccess'); IT = @('ITAccess') }
    }
    $script:iamBaseCsv = @(
        'EventId,EventType,EmployeeId,GivenName,Surname,Department'
        'JML-001,Joiner,LAB-001,Anna,Example,Finance'
        'JML-002,Mover,LAB-001,Anna,Example,IT'
        'JML-003,Leaver,LAB-001,Anna,Example,'
    )
    $script:iamInputPaths = @{
        ConfigPath = (Join-Path $script:iamTestRoot 'lab.local.json')
        MatrixPath = (Join-Path $script:iamTestRoot 'matrix.json')
        EventsPath = (Join-Path $script:iamTestRoot 'events.csv')
    }
    $script:iamDriver = Join-Path $script:iamRepoRoot 'scripts/Invoke-IamLifecycle.ps1'
    $script:iamOriginalModulePath = $env:PSModulePath
    $fakeModules = Join-Path $script:iamTestRoot 'modules'
    $fakeDirectory = Join-Path $fakeModules 'ActiveDirectory'
    $null = New-Item -ItemType Directory -Path $fakeDirectory -Force
    $fakeFile = Join-Path $fakeDirectory 'ActiveDirectory.psm1'
    Copy-Item -LiteralPath (Join-Path $script:iamRepoRoot 'tests/offline/fixtures/ActiveDirectory.psm1') -Destination $fakeFile
    $env:PSModulePath = $fakeModules + [IO.Path]::PathSeparator + $env:PSModulePath
    Import-Module $fakeFile -Force -Global
    Import-Module (Join-Path $script:iamRepoRoot 'src/IamAutomation/IamAutomation.psm1') -Force
    $script:iamPassword = ConvertTo-SecureString 'Offline-Synthetic-Only!8x' -AsPlainText -Force

    function Reset-IamTestInputs {
        $script:iamBaseConfig | ConvertTo-Json -Depth 8 |
            Set-Content -LiteralPath $script:iamInputPaths.ConfigPath -Encoding UTF8
        $script:iamBaseMatrix | ConvertTo-Json -Depth 8 |
            Set-Content -LiteralPath $script:iamInputPaths.MatrixPath -Encoding UTF8
        $script:iamBaseCsv |
            Set-Content -LiteralPath $script:iamInputPaths.EventsPath -Encoding UTF8
    }
    function Get-IamTestContext([string]$Id = 'JML-001') {
        Read-IamLifecycleInput -EventId $Id @script:iamInputPaths
    }
    function New-IamTestUser {
        param([bool]$Enabled = $true, [string]$Department = 'Finance', [string]$EmployeeId = 'LAB-001')
        $sam = 'iam.' + $EmployeeId.Replace('-', '').ToLowerInvariant()
        [pscustomobject]@{
            ObjectGUID = [guid]'11111111-1111-1111-1111-111111111111'
            DistinguishedName = "CN=$sam,$script:iamOU"
            SamAccountName = $sam; EmployeeId = $EmployeeId
            UserPrincipalName = "$sam@balticfinance.test"
            Enabled = $Enabled; Department = $Department
            GivenName = 'Anna'; Surname = 'Example'
            AdminCount = 0; IsCriticalSystemObject = $false
        }
    }
    function New-IamTestSnapshot {
        param([object]$User = $null, [string[]]$Memberships = @())
        [pscustomobject]@{
            Domain = 'balticfinance.test'; TestOU = $script:iamOU
            User = $User; DirectGroupDns = @($Memberships)
            Groups = @(
                [pscustomobject]@{ DistinguishedName = $script:iamFinance; ObjectGUID = '22222222-2222-2222-2222-222222222222' }
                [pscustomobject]@{ DistinguishedName = $script:iamIT; ObjectGUID = '33333333-3333-3333-3333-333333333333' }
            )
        }
    }
    function Set-IamTestDirectory {
        param([string]$Department = 'Finance', [bool]$Enabled = $true, [string[]]$Memberships = @($script:iamFinance))
        $state = Get-FakeAd
        $state.User = New-IamTestUser -Enabled $Enabled -Department $Department
        $state.Memberships = @($Memberships)
    }
    function Invoke-IamTestEvent {
        param([string]$Id = 'JML-001', [switch]$Apply, [switch]$WhatIf, [switch]$Password, [switch]$Inject)
        $script:iamLastLog = Join-Path $script:iamTestRoot ([guid]::NewGuid().ToString('N') + '.csv')
        $parameters = @{
            Context = (Get-IamTestContext $Id)
            LogPath = $script:iamLastLog
            RunId = [guid]::NewGuid().ToString('N')
            Apply = [bool]$Apply; WhatIf = [bool]$WhatIf; Confirm = $false
            SimulateFailureAfterRemoval = [bool]$Inject
        }
        if ($Password) { $parameters.InitialPassword = $script:iamPassword }
        Invoke-IamLifecycleEvent @parameters
    }
}

AfterAll {
    if ($null -ne $script:iamPassword) { $script:iamPassword.Dispose() }
    Remove-Module IamAutomation, ActiveDirectory -Force -ErrorAction SilentlyContinue
    $env:PSModulePath = $script:iamOriginalModulePath
}

Describe 'Synthetic IAM inputs and exact lab boundaries' {
    BeforeEach { Reset-IamTestInputs; Reset-FakeAd }

    It 'loads the lifecycle feed and derives a predictable lab identity' {
        $context = Get-IamTestContext
        $context.SamAccountName | Should -Be 'iam.lab001'
        $context.Event.EmployeeId | Should -Be 'LAB-001'
        $context.DesiredGroupDns | Should -Contain $script:iamFinance
    }
    It 'accepts the separate Day 08 lifecycle feed for LAB-002' {
        $context = Read-IamLifecycleInput -EventId 'JML-101' -ConfigPath $script:iamInputPaths.ConfigPath -MatrixPath $script:iamInputPaths.MatrixPath -EventsPath (Join-Path $script:iamRepoRoot 'samples/hr-events.day08.example.csv')
        $context.SamAccountName | Should -Be 'iam.lab002'
        $context.Event.GivenName | Should -Be 'Marek'
        $context.Event.Department | Should -Be 'Finance'
    }
    It 'rejects duplicate event IDs before directory reads' {
        @($script:iamBaseCsv + $script:iamBaseCsv[1]) |
            Set-Content -LiteralPath $script:iamInputPaths.EventsPath -Encoding UTF8
        { Get-IamTestContext } | Should -Throw -ExpectedMessage '*duplicate EventId*'
        (Get-FakeAd).SnapshotReads | Should -Be 0
    }
    It 'rejects an injection-shaped employee identifier' {
        ($script:iamBaseCsv -replace 'LAB-001', "LAB-001' -or Name -like '*'") |
            Set-Content -LiteralPath $script:iamInputPaths.EventsPath -Encoding UTF8
        { Get-IamTestContext } | Should -Throw -ExpectedMessage '*Invalid lab EmployeeId*'
    }
    It 'rejects an unknown department' {
        ($script:iamBaseCsv -replace ',Finance$', ',Unknown') |
            Set-Content -LiteralPath $script:iamInputPaths.EventsPath -Encoding UTF8
        { Get-IamTestContext } | Should -Throw -ExpectedMessage '*Unknown department*'
    }
    It 'rejects an unsupported event type' {
        ($script:iamBaseCsv -replace ',Joiner,', ',Rehire,') |
            Set-Content -LiteralPath $script:iamInputPaths.EventsPath -Encoding UTF8
        { Get-IamTestContext } | Should -Throw -ExpectedMessage '*Unknown event type*'
    }
    It 'rejects unexpected CSV columns' {
        ($script:iamBaseCsv -replace '^EventId,', 'Extra,') |
            Set-Content -LiteralPath $script:iamInputPaths.EventsPath -Encoding UTF8
        { Get-IamTestContext } | Should -Throw -ExpectedMessage '*Unexpected HR CSV columns*'
    }
    It 'rejects a broadened lifecycle OU' {
        $config = Get-Content $script:iamInputPaths.ConfigPath -Raw | ConvertFrom-Json
        $config.ad.testOu = 'OU=IAM-Automation,DC=balticfinance,DC=test'
        $config | ConvertTo-Json -Depth 8 | Set-Content $script:iamInputPaths.ConfigPath -Encoding UTF8
        { Get-IamTestContext } | Should -Throw -ExpectedMessage '*account boundary must be*'
    }
    It 'rejects a privileged group substituted into the access map' {
        $config = Get-Content $script:iamInputPaths.ConfigPath -Raw | ConvertFrom-Json
        $config.ad.groupMap.FinanceAccess = 'CN=Domain Admins,CN=Users,DC=balticfinance,DC=test'
        $config | ConvertTo-Json -Depth 8 | Set-Content $script:iamInputPaths.ConfigPath -Encoding UTF8
        { Get-IamTestContext } | Should -Throw -ExpectedMessage '*lab group boundary*'
    }
    It 'rejects a protected account' {
        $user = New-IamTestUser
        $user.AdminCount = 1
        { New-IamLifecyclePlan -Context (Get-IamTestContext) -Snapshot (New-IamTestSnapshot $user) } |
            Should -Throw -ExpectedMessage '*protected or critical*'
    }
    It 'rejects a critical system object' {
        $user = New-IamTestUser
        $user.IsCriticalSystemObject = $true
        { New-IamLifecyclePlan -Context (Get-IamTestContext) -Snapshot (New-IamTestSnapshot $user) } |
            Should -Throw -ExpectedMessage '*protected or critical*'
    }
    It 'rejects an escaped-comma DN that imitates the allowed OU suffix' {
        $user = New-IamTestUser
        $user.DistinguishedName = 'CN=iam.lab001\,OU=JML,OU=IAM-Automation,DC=balticfinance,DC=test'
        { New-IamLifecyclePlan -Context (Get-IamTestContext) -Snapshot (New-IamTestSnapshot $user) } |
            Should -Throw -ExpectedMessage '*approved lifecycle account DN*'
    }
    It 'rejects an employee-ID mismatch on the otherwise matching account' {
        $user = New-IamTestUser
        $user.EmployeeId = 'LAB-999'
        { New-IamLifecyclePlan -Context (Get-IamTestContext) -Snapshot (New-IamTestSnapshot $user) } |
            Should -Throw -ExpectedMessage '*identity does not match*'
    }
}

Describe 'Lifecycle plans and needed operations' {
    BeforeEach { Reset-IamTestInputs; Reset-FakeAd }

    It 'plans account creation before the first department grant' {
        $plan = @(New-IamLifecyclePlan -Context (Get-IamTestContext) -Snapshot (New-IamTestSnapshot))
        ($plan.Action -join ',') | Should -Be 'CreateUser,AddGroupMember'
        $plan[1].GroupDN | Should -Be $script:iamFinance
    }
    It 'plans old-access removal before the new Mover grant' {
        $plan = @(New-IamLifecyclePlan -Context (Get-IamTestContext 'JML-002') -Snapshot (New-IamTestSnapshot (New-IamTestUser) @($script:iamFinance)))
        ($plan.Action -join ',') | Should -Be 'SetDepartment,RemoveGroupMember,AddGroupMember'
        $plan[1].GroupDN | Should -Be $script:iamFinance
        $plan[2].GroupDN | Should -Be $script:iamIT
    }
    It 'plans account disabling before Leaver membership removal' {
        $plan = @(New-IamLifecyclePlan -Context (Get-IamTestContext 'JML-003') -Snapshot (New-IamTestSnapshot (New-IamTestUser) @($script:iamIT)))
        ($plan.Action -join ',') | Should -Be 'DisableUser,RemoveGroupMember'
    }
    It 'retains the outside-OU boundary for the disabled LAB-003 Leaver fixture' {
        $context = Read-IamLifecycleInput -EventId 'JML-201' -ConfigPath $script:iamInputPaths.ConfigPath -MatrixPath $script:iamInputPaths.MatrixPath -EventsPath (Join-Path $script:iamRepoRoot 'samples/hr-events.out-of-scope.example.csv')
        $user = New-IamTestUser -Enabled $false -EmployeeId 'LAB-003'
        $user.DistinguishedName = 'CN=iam.lab003,OU=IAM-Automation,DC=balticfinance,DC=test'
        { New-IamLifecyclePlan -Context $context -Snapshot (New-IamTestSnapshot $user @($script:iamFinance)) } |
            Should -Throw -ExpectedMessage '*approved lifecycle account DN*'
        # Disabling alone does not make this a no-op: the same profile inside JML still needs revocation.
        $user.DistinguishedName = "CN=iam.lab003,$script:iamOU"
        $plan = @(New-IamLifecyclePlan -Context $context -Snapshot (New-IamTestSnapshot $user @($script:iamFinance)))
        $plan.Count | Should -Be 1
        $plan[0].Action | Should -Be 'RemoveGroupMember'
    }
    It 'does not reactivate an existing disabled account through Joiner' {
        { New-IamLifecyclePlan -Context (Get-IamTestContext) -Snapshot (New-IamTestSnapshot (New-IamTestUser -Enabled $false)) } |
            Should -Throw -ExpectedMessage '*cannot reactivate*'
    }
    It 'rejects an old Joiner after the employee has moved to IT' {
        { New-IamLifecyclePlan -Context (Get-IamTestContext) -Snapshot (New-IamTestSnapshot (New-IamTestUser -Department 'IT') @($script:iamIT)) } |
            Should -Throw -ExpectedMessage '*profile differs*'
    }
}

Describe 'Read-only runs and Pester writer mocks' {
    BeforeEach {
        Reset-IamTestInputs
        Reset-FakeAd
        foreach ($writer in @('New-ADUser','Set-ADUser','Disable-ADAccount','Add-ADGroupMember','Remove-ADGroupMember')) {
            Mock -CommandName $writer -ModuleName IamAutomation -MockWith { throw 'Unexpected AD writer call.' }
        }
    }

    It 'keeps a default Preview read-only while recording its plan' {
        $result = Invoke-IamTestEvent
        $result.Mode | Should -Be 'Preview'
        $result.PlannedOperations | Should -Be 2
        $result.ManagedStateUnchanged | Should -BeTrue
        foreach ($writer in @('New-ADUser','Set-ADUser','Disable-ADAccount','Add-ADGroupMember','Remove-ADGroupMember')) {
            Should -Invoke -CommandName $writer -ModuleName IamAutomation -Exactly -Times 0 -Scope It
        }
        @((Import-Csv $script:iamLastLog) | Where-Object Status -eq 'Planned').Count | Should -Be 2
    }
    It 'honors Joiner WhatIf without a password or any writer call' {
        $result = Invoke-IamTestEvent -Apply -WhatIf
        $result.Mode | Should -Be 'WhatIf'
        $result.AppliedOperations | Should -Be 0
        $result.UserExistsAfter | Should -BeFalse
        $result.ManagedStateUnchanged | Should -BeTrue
        foreach ($writer in @('New-ADUser','Set-ADUser','Disable-ADAccount','Add-ADGroupMember','Remove-ADGroupMember')) {
            Should -Invoke -CommandName $writer -ModuleName IamAutomation -Exactly -Times 0 -Scope It
        }
    }
    It 'honors Mover WhatIf for an existing Finance account' {
        Set-IamTestDirectory
        $result = Invoke-IamTestEvent 'JML-002' -Apply -WhatIf
        $result.PlannedOperations | Should -Be 3
        $result.ManagedStateUnchanged | Should -BeTrue
        foreach ($writer in @('New-ADUser','Set-ADUser','Disable-ADAccount','Add-ADGroupMember','Remove-ADGroupMember')) {
            Should -Invoke -CommandName $writer -ModuleName IamAutomation -Exactly -Times 0 -Scope It
        }
        (Get-FakeAd).User.Department | Should -Be 'Finance'
    }
    It 'honors Leaver WhatIf without disabling the account' {
        Set-IamTestDirectory
        $result = Invoke-IamTestEvent 'JML-003' -Apply -WhatIf
        $result.ManagedStateUnchanged | Should -BeTrue
        (Get-FakeAd).User.Enabled | Should -BeTrue
        foreach ($writer in @('New-ADUser','Set-ADUser','Disable-ADAccount','Add-ADGroupMember','Remove-ADGroupMember')) {
            Should -Invoke -CommandName $writer -ModuleName IamAutomation -Exactly -Times 0 -Scope It
        }
    }
}

Describe 'Execution, repeats, partial recovery and audit' {
    BeforeEach { Reset-IamTestInputs; Reset-FakeAd }

    It 'creates the enabled Joiner account and grants only Finance' {
        $result = Invoke-IamTestEvent -Apply -Password
        ((Get-FakeAd).Calls -join ',') | Should -Be 'New-ADUser,Add-ADGroupMember'
        (Get-FakeAd).User.Enabled | Should -BeTrue
        (Get-FakeAd).User.EmployeeID | Should -Be 'LAB-001'
        (@((Get-FakeAd).Memberships) -join ',') | Should -Be $script:iamFinance
        $result.RemainingOperations | Should -Be 0
    }
    It 'repeats a completed Joiner with zero additional writes and no password' {
        Set-IamTestDirectory
        $result = Invoke-IamTestEvent -Apply
        $result.Status | Should -Be 'NoChange'
        $result.AppliedOperations | Should -Be 0
        (Get-FakeAd).Calls.Count | Should -Be 0
    }
    It 'executes the department update and revocation before the Mover grant' {
        Set-IamTestDirectory
        $result = Invoke-IamTestEvent 'JML-002' -Apply
        ((Get-FakeAd).Calls -join ',') | Should -Be 'Set-ADUser,Remove-ADGroupMember,Add-ADGroupMember'
        (Get-FakeAd).User.Department | Should -Be 'IT'
        (@((Get-FakeAd).Memberships) -join ',') | Should -Be $script:iamIT
        $result.RemainingOperations | Should -Be 0
    }
    It 'repeats a completed Mover with zero additional writes' {
        Set-IamTestDirectory -Department 'IT' -Memberships @($script:iamIT)
        $result = Invoke-IamTestEvent 'JML-002' -Apply
        $result.Status | Should -Be 'NoChange'
        (Get-FakeAd).Calls.Count | Should -Be 0
    }
    It 'disables first and preserves unrelated membership during Leaver' {
        Set-IamTestDirectory -Department 'IT' -Memberships @($script:iamIT,'CN=Unmanaged,DC=balticfinance,DC=test')
        $result = Invoke-IamTestEvent 'JML-003' -Apply
        ((Get-FakeAd).Calls -join ',') | Should -Be 'Disable-ADAccount,Remove-ADGroupMember'
        (Get-FakeAd).User.Enabled | Should -BeFalse
        (@((Get-FakeAd).Memberships) -join ',') | Should -Be 'CN=Unmanaged,DC=balticfinance,DC=test'
        $result.RemainingOperations | Should -Be 0
    }
    It 'repeats a completed Leaver with zero additional writes' {
        Set-IamTestDirectory -Department 'IT' -Enabled $false -Memberships @()
        $result = Invoke-IamTestEvent 'JML-003' -Apply
        $result.Status | Should -Be 'NoChange'
        (Get-FakeAd).Calls.Count | Should -Be 0
    }
    It 'resumes an injected partial Mover by applying only the missing IT grant' {
        Set-IamTestDirectory
        { Invoke-IamTestEvent 'JML-002' -Apply -Inject } |
            Should -Throw -ExpectedMessage '*Injected failure after managed group removal*'
        (Get-FakeAd).User.Department | Should -Be 'IT'
        (Get-FakeAd).Memberships.Count | Should -Be 0
        $partial = @(Import-Csv $script:iamLastLog)
        @($partial | Where-Object { $_.Action -eq 'RemoveGroupMember' -and $_.Status -eq 'Applied' }).Count | Should -Be 1
        (Get-FakeAd).Calls = @()
        $result = Invoke-IamTestEvent 'JML-002' -Apply
        ((Get-FakeAd).Calls -join ',') | Should -Be 'Add-ADGroupMember'
        $result.PlannedOperations | Should -Be 1
        $result.RemainingOperations | Should -Be 0
    }
    It 'stops before a new grant when old-access removal fails' {
        Set-IamTestDirectory
        Mock -CommandName Remove-ADGroupMember -ModuleName IamAutomation -MockWith { throw 'Revocation rejected by the directory.' }
        Mock -CommandName Add-ADGroupMember -ModuleName IamAutomation -MockWith { throw 'Unexpected new grant.' }
        { Invoke-IamTestEvent 'JML-002' -Apply } |
            Should -Throw -ExpectedMessage '*Revocation rejected by the directory*'
        Should -Invoke -CommandName Remove-ADGroupMember -ModuleName IamAutomation -Exactly -Times 1 -Scope It
        Should -Invoke -CommandName Add-ADGroupMember -ModuleName IamAutomation -Exactly -Times 0 -Scope It
    }
    It 'rejects an outside-OU target before any directory writer call' {
        Set-IamTestDirectory -Enabled $false
        (Get-FakeAd).User.DistinguishedName = 'CN=iam.lab001,OU=IAM-Automation,DC=balticfinance,DC=test'
        { Invoke-IamTestEvent 'JML-003' -Apply } |
            Should -Throw -ExpectedMessage '*approved lifecycle account DN*'
        (Get-FakeAd).Calls.Count | Should -Be 0
    }
    It 'rejects ambiguous domain-wide identity matches before writes' {
        Set-IamTestDirectory
        (Get-FakeAd).ExtraUsers = @(New-IamTestUser)
        { Invoke-IamTestEvent -Apply -Password } |
            Should -Throw -ExpectedMessage '*Multiple AD accounts*'
        (Get-FakeAd).Calls.Count | Should -Be 0
    }
    It 'detects a replaced group before granting access' {
        (Get-FakeAd).ReplaceGroupAfterCreate = $true
        { Invoke-IamTestEvent -Apply -Password } |
            Should -Throw -ExpectedMessage '*managed group was moved, removed or replaced*'
        ((Get-FakeAd).Calls -join ',') | Should -Be 'New-ADUser'
    }
    It 'detects a replaced user before subsequent membership writes' {
        Set-IamTestDirectory
        (Get-FakeAd).ReplaceUserAfterSet = $true
        { Invoke-IamTestEvent 'JML-002' -Apply } |
            Should -Throw -ExpectedMessage '*bound account was removed or replaced*'
        ((Get-FakeAd).Calls -join ',') | Should -Be 'Set-ADUser'
    }
    It 'fails read-back when a directory writer silently ignores the requested value' {
        Set-IamTestDirectory
        (Get-FakeAd).IgnoreAction = 'Set-ADUser'
        { Invoke-IamTestEvent 'JML-002' -Apply } |
            Should -Throw -ExpectedMessage '*Department read-back failed*'
        ((Get-FakeAd).Calls -join ',') | Should -Be 'Set-ADUser'
    }
    It 'prevents directory writes when the audit destination is unavailable' {
        Set-IamTestDirectory
        $missingLog = Join-Path $script:iamTestRoot ('absent-' + [guid]::NewGuid().ToString('N') + '/run.csv')
        { Invoke-IamLifecycleEvent -Context (Get-IamTestContext 'JML-002') -LogPath $missingLog -RunId test -Apply -Confirm:$false } |
            Should -Throw
        (Get-FakeAd).Calls.Count | Should -Be 0
    }
    It 'excludes secret data from the audit and retains caller ownership of its SecureString' {
        $null = Invoke-IamTestEvent -Apply -Password
        $raw = Get-Content $script:iamLastLog -Raw
        $raw | Should -Not -Match 'Offline-Synthetic-Only|AccountPassword|InitialPassword'
        $script:iamPassword.Length | Should -Be 25
    }
}

Describe 'Lifecycle entry-point integration' {
    BeforeEach { Reset-IamTestInputs; Reset-FakeAd }

    It 'forwards WhatIf and persists a completed read-only audit' {
        $outputDirectory = Join-Path $script:iamTestRoot ('driver-' + [guid]::NewGuid().ToString('N'))
        $output = & $script:iamDriver -EventId 'JML-001' @script:iamInputPaths -OutputDirectory $outputDirectory -Apply -WhatIf |
            Out-String -Width 200
        $output | Should -Match 'Mode\s*:\s*WhatIf'
        $output | Should -Match 'ManagedStateUnchanged\s*:\s*True'
        (Get-FakeAd).Calls.Count | Should -Be 0
        $log = @(Get-ChildItem $outputDirectory -Filter '*.csv')[0]
        @(Import-Csv $log.FullName)[-1].Status | Should -Be 'WhatIf'
    }
    It 'records invalid-event failure without directory writes' {
        $outputDirectory = Join-Path $script:iamTestRoot ('invalid-' + [guid]::NewGuid().ToString('N'))
        { & $script:iamDriver -EventId 'JML-999' @script:iamInputPaths -OutputDirectory $outputDirectory -Apply } |
            Should -Throw -ExpectedMessage '*Expected one HR event*'
        (Get-FakeAd).Calls.Count | Should -Be 0
        $log = @(Get-ChildItem $outputDirectory -Filter '*.csv')[0]
        @(Import-Csv $log.FullName)[-1].Status | Should -Be 'Failed'
    }
    It 'records run failure without relabeling the completed controlled revocation as failed' {
        Set-IamTestDirectory
        $outputDirectory = Join-Path $script:iamTestRoot ('partial-' + [guid]::NewGuid().ToString('N'))
        { & $script:iamDriver -EventId 'JML-002' @script:iamInputPaths -OutputDirectory $outputDirectory -Apply -SimulateFailureAfterRemoval } |
            Should -Throw -ExpectedMessage '*Injected failure after managed group removal*'
        $log = @(Get-ChildItem $outputDirectory -Filter '*.csv')[0]
        $rows = @(Import-Csv $log.FullName)
        $rows[-1].Action | Should -Be 'Run'
        $rows[-1].Status | Should -Be 'Failed'
        @($rows | Where-Object { $_.Action -eq 'RemoveGroupMember' -and $_.Status -eq 'Applied' }).Count | Should -Be 1
        @($rows | Where-Object { $_.Action -eq 'RemoveGroupMember' -and $_.Status -eq 'Failed' }).Count | Should -Be 0
    }
}
