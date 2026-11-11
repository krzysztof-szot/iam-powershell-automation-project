Import-Module ActiveDirectory -ErrorAction Stop

$labUser = 'iam.ps01'

'BEFORE'

Get-ADUser -Identity $labUser -Properties Department, Title |
    Format-List SamAccountName, Department, Title

Set-ADUser -Identity $labUser `
    -Department 'IT' `
    -Title 'IAM Automation Trainee' `
    -ErrorAction Stop

'AFTER'

Get-ADUser -Identity $labUser -Properties Department, Title |
    Format-List SamAccountName, Department, Title