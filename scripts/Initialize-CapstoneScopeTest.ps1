#requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param([string]$ProjectRoot = 'C:\IAM-Automation\day-08')

& {
    $ErrorActionPreference = 'Stop'
    Import-Module ActiveDirectory
    Set-Location $ProjectRoot

    $labServer = 'BFL-DC01.balticfinance.test'
    $labParentOu = 'OU=IAM-Automation,DC=balticfinance,DC=test'
    $labFinanceDn = "CN=GG-IAM-LAB-Finance,$labParentOu"
    $labItDn = "CN=GG-IAM-LAB-IT,$labParentOu"
    $labEventsPath = '.\samples\hr-events.out-of-scope.example.csv'
    $labBaselinePath = '.\local-output\scope-test-before.json'

    $labLookup = @{
        Filter = "EmployeeID -eq 'LAB-003' -or SamAccountName -eq 'iam.lab003' -or UserPrincipalName -eq 'iam.lab003@balticfinance.test'"
        SearchBase = 'DC=balticfinance,DC=test'
        Server = $labServer
    }

    if (@(Get-ADUser @labLookup).Count -ne 0) {
        throw 'Tozsamosc LAB-003 juz istnieje. Przerwano przygotowanie.'
    }
    if ((Test-Path -LiteralPath $labEventsPath) -or
        (Test-Path -LiteralPath $labBaselinePath)) {
        throw 'Pliki testu zakresu juz istnieja. Przerwano bez nadpisywania.'
    }

    $null = Get-ADOrganizationalUnit -Identity $labParentOu -Server $labServer

    if (-not $PSCmdlet.ShouldProcess('iam.lab003 outside JML and the Finance lab group', 'Create disabled test fixture, add test membership and save baseline')) {
        return
    }

    $labNewUserParameters = @{
        Name = 'iam.lab003'
        SamAccountName = 'iam.lab003'
        UserPrincipalName = 'iam.lab003@balticfinance.test'
        GivenName = 'Scope'
        Surname = 'Example'
        DisplayName = 'Scope Example'
        EmployeeID = 'LAB-003'
        Department = 'Finance'
        Description = 'Day 08 outside-OU scope test'
        Enabled = $false
        Path = $labParentOu
        Server = $labServer
        PassThru = $true
        Confirm = $false
    }
    $labCreated = New-ADUser @labNewUserParameters

    Add-ADGroupMember -Identity $labFinanceDn -Members $labCreated -Server $labServer -Confirm:$false

    $labUser = Get-ADUser -Identity $labCreated.ObjectGUID -Server $labServer -Properties EmployeeID, Department, memberOf, uSNChanged

    $labBefore = [pscustomobject]@{
        Server = $labServer
        ObjectGUID = $labUser.ObjectGUID.ToString()
        SamAccountName = $labUser.SamAccountName
        EmployeeId = [string]$labUser.EmployeeID
        DistinguishedName = $labUser.DistinguishedName
        Enabled = [bool]$labUser.Enabled
        Department = [string]$labUser.Department
        UserRevision = [string]$labUser.uSNChanged
        FinanceDirectMember = $labUser.memberOf -contains $labFinanceDn
        ITDirectMember = $labUser.memberOf -contains $labItDn
    }

    if ($labBefore.Enabled -or -not $labBefore.FinanceDirectMember) {
        throw 'Stan konta testowego nie odpowiada zalozeniom. Sprawdz konto przed kontynuacja.'
    }

    $labBefore | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $labBaselinePath -Encoding UTF8

    @(
        'EventId,EventType,EmployeeId,GivenName,Surname,Department'
        'JML-201,Leaver,LAB-003,Scope,Example,'
    ) | Set-Content -LiteralPath $labEventsPath -Encoding UTF8

    Clear-Host
    'OUTSIDE-OU TEST FIXTURE'

    $labBefore |
        Select-Object Server, SamAccountName, EmployeeId, Enabled, Department,
            DistinguishedName, FinanceDirectMember, ITDirectMember |
        Format-List

    [pscustomobject]@{
        AllowedOU = 'OU=JML,OU=IAM-Automation,DC=balticfinance,DC=test'
        TestEventId = 'JML-201'
        BaselineSaved = Test-Path -LiteralPath $labBaselinePath
        EventCount = @(Import-Csv -LiteralPath $labEventsPath).Count
    } | Format-List
}
