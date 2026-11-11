# Offline-only ActiveDirectory adapter. Never connect this file to a real domain.
Set-StrictMode -Version 2.0
function Reset-FakeAd {
    $script:state = [pscustomobject]@{
        User = $null; Memberships = @(); ExtraUsers = @(); Calls = @()
        FinanceGuid = '22222222-2222-2222-2222-222222222222'
        ITGuid = '33333333-3333-3333-3333-333333333333'
        FaultAction = ''; IgnoreAction = ''; ReplaceGroupAfterCreate = $false
        ReplaceUserAfterSet = $false; SnapshotReads = 0; ReplaceUserAtRead = 0
    }
}
function Get-FakeAd { return $script:state }
function Assert-FakeServer([string]$Server) {
    if ($Server -ne 'BFL-DC01.balticfinance.test') { throw 'Unexpected server.' }
}
function Get-ADDomain {
    [CmdletBinding()] param([string]$Server)
    Assert-FakeServer $Server
    [pscustomobject]@{ DNSRoot = 'balticfinance.test'; DistinguishedName = 'DC=balticfinance,DC=test' }
}
function Get-ADOrganizationalUnit {
    [CmdletBinding()] param([string]$Identity, [string]$Server)
    Assert-FakeServer $Server
    if ($Identity -ne 'OU=JML,OU=IAM-Automation,DC=balticfinance,DC=test') { throw 'Unexpected OU.' }
    [pscustomobject]@{ DistinguishedName = $Identity }
}
function Get-ADGroup {
    [CmdletBinding()] param([string]$Identity, [string]$Server)
    Assert-FakeServer $Server
    $id = if ($Identity -eq 'CN=GG-IAM-LAB-Finance,OU=IAM-Automation,DC=balticfinance,DC=test') {
        $script:state.FinanceGuid
    } elseif ($Identity -eq 'CN=GG-IAM-LAB-IT,OU=IAM-Automation,DC=balticfinance,DC=test') {
        $script:state.ITGuid
    } else { throw 'Unexpected managed group.' }
    [pscustomobject]@{ DistinguishedName = $Identity; ObjectGUID = [guid]$id; GroupCategory = 'Security' }
}
function Get-ADUser {
    [CmdletBinding()] param([string]$Filter, [string]$SearchBase, [string]$Server, [string[]]$Properties)
    Assert-FakeServer $Server
    if ($SearchBase -ne 'DC=balticfinance,DC=test' -or $Filter -notlike "*EmployeeID -eq 'LAB-001'*") {
        throw 'Expected the domain-wide identity collision check.'
    }
    $script:state.SnapshotReads++
    if ($script:state.ReplaceUserAtRead -eq $script:state.SnapshotReads -and $null -ne $script:state.User) {
        $script:state.User.ObjectGUID = [guid]'99999999-9999-9999-9999-999999999999'
    }
    if ($null -ne $script:state.User) { $script:state.User }
    foreach ($user in $script:state.ExtraUsers) { $user }
}
function Get-ADGroupMember {
    [CmdletBinding()] param([string]$Identity, [string]$Server)
    Assert-FakeServer $Server
    $dn = if ($Identity -eq $script:state.FinanceGuid) {
        'CN=GG-IAM-LAB-Finance,OU=IAM-Automation,DC=balticfinance,DC=test'
    } elseif ($Identity -eq $script:state.ITGuid) {
        'CN=GG-IAM-LAB-IT,OU=IAM-Automation,DC=balticfinance,DC=test'
    } else { throw 'Group membership was not resolved by bound GUID.' }
    if ($null -ne $script:state.User -and $dn -in $script:state.Memberships) {
        [pscustomobject]@{ ObjectGUID = $script:state.User.ObjectGUID }
    }
}
function Start-FakeWrite([string]$Action, [string]$Identity, [string]$Server) {
    Assert-FakeServer $Server
    $script:state.Calls += $Action
    if ($script:state.FaultAction -eq $Action) { throw "Simulated $Action failure." }
    if ($Action -ne 'New-ADUser' -and
        $Identity -ne $script:state.User.ObjectGUID.ToString() -and
        $Identity -notin @($script:state.FinanceGuid, $script:state.ITGuid)) { throw 'Unexpected write identity.' }
}
function New-ADUser {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Name,[string]$SamAccountName,[string]$UserPrincipalName,
        [string]$GivenName,[string]$Surname,[string]$DisplayName,[string]$EmployeeID,
        [string]$Department,[string]$Description,[string]$Path,
        [Security.SecureString]$AccountPassword,[bool]$Enabled,[bool]$ChangePasswordAtLogon,
        [string]$Server,[switch]$PassThru)
    Start-FakeWrite 'New-ADUser' '' $Server
    if ($AccountPassword.Length -eq 0) { throw 'Empty password.' }
    if ($script:state.IgnoreAction -eq 'New-ADUser') { return }
    $script:state.User = [pscustomobject]@{
        ObjectGUID = [guid]'11111111-1111-1111-1111-111111111111'
        DistinguishedName = "CN=$Name,$Path"; SamAccountName = $SamAccountName
        UserPrincipalName = $UserPrincipalName; EmployeeID = $EmployeeID
        GivenName = $GivenName; Surname = $Surname; DisplayName = $DisplayName
        Department = $Department; Enabled = $Enabled; adminCount = $null
        isCriticalSystemObject = $false
    }
    if ($script:state.ReplaceGroupAfterCreate) { $script:state.FinanceGuid = '99999999-9999-9999-9999-999999999999' }
    if ($PassThru) { $script:state.User }
}
function Set-ADUser {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Identity,[string]$Department,[string]$Server)
    Start-FakeWrite 'Set-ADUser' $Identity $Server
    if ($script:state.IgnoreAction -ne 'Set-ADUser') { $script:state.User.Department = $Department }
    if ($script:state.ReplaceUserAfterSet) { $script:state.User.ObjectGUID = [guid]'99999999-9999-9999-9999-999999999999' }
}
function Disable-ADAccount {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Identity,[string]$Server)
    Start-FakeWrite 'Disable-ADAccount' $Identity $Server
    if ($script:state.IgnoreAction -ne 'Disable-ADAccount') { $script:state.User.Enabled = $false }
}
function Set-FakeMembership([string]$Identity,[string]$Members,[string]$Server,[bool]$Add) {
    $action = if ($Add) { 'Add-ADGroupMember' } else { 'Remove-ADGroupMember' }
    Start-FakeWrite $action $Identity $Server
    if ($Members -ne $script:state.User.ObjectGUID.ToString()) { throw 'Membership write did not bind the user GUID.' }
    if ($Identity -eq $script:state.FinanceGuid) { $dn = 'CN=GG-IAM-LAB-Finance,OU=IAM-Automation,DC=balticfinance,DC=test' }
    elseif ($Identity -eq $script:state.ITGuid) { $dn = 'CN=GG-IAM-LAB-IT,OU=IAM-Automation,DC=balticfinance,DC=test' }
    else { throw 'Membership write did not bind a managed group GUID.' }
    if ($script:state.IgnoreAction -eq $action) { return }
    if ($Add) { $script:state.Memberships = @($script:state.Memberships + $dn | Select-Object -Unique) }
    else { $script:state.Memberships = @($script:state.Memberships | Where-Object { $_ -ne $dn }) }
}
function Add-ADGroupMember {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Identity,[string]$Members,[string]$Server)
    Set-FakeMembership $Identity $Members $Server $true
}
function Remove-ADGroupMember {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Identity,[string]$Members,[string]$Server)
    Set-FakeMembership $Identity $Members $Server $false
}
Reset-FakeAd
Export-ModuleMember -Function Reset-FakeAd,Get-FakeAd,Get-ADDomain,Get-ADOrganizationalUnit,Get-ADGroup,Get-ADUser,Get-ADGroupMember,New-ADUser,Set-ADUser,Disable-ADAccount,Add-ADGroupMember,Remove-ADGroupMember
