Import-Module ActiveDirectory -ErrorAction Stop

$labUser = 'iam.gui01'

$labGroups = @(
    'GG-IAM-LAB-Finance'
    'GG-IAM-LAB-IT'
)

$report = foreach ($labGroup in $labGroups) {
    $members = @(
        Get-ADGroupMember -Identity $labGroup -ErrorAction Stop
    )

    [pscustomobject]@{
        SamAccountName = $labUser
        Group          = $labGroup
        IsMember       = $members.SamAccountName -contains $labUser
    }
}

$report | Format-Table -AutoSize