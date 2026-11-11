# Day 02 — Active Directory user management

**Status** · Completed documented scope  
Record updated 2026-11-11.

[Tests](../tests/day-02.md) · [Screenshots](../evidence/day-02/README.md) · [PowerShell example](../scripts/day-02-user-attributes.ps1)

## Objective

Create two disposable domain users in a dedicated OU, query them within that scope and update the second user's Department and Title.

The owner performed the lab actions. The record connects the guided console and PowerShell procedure to three uploaded screenshots and the saved example script.

## Recorded results

### Dedicated OU and test users

The guided procedure created or reused `IAM-Automation` directly under `balticfinance.test`. The owner followed the AD Users and Computers procedure for `IAM GUI User` and the `New-ADUser` procedure for `IAM PowerShell User`.

The retained console screenshot shows both User objects in the selected OU. The subsequent PowerShell read identifies their logins as `iam.gui01` and `iam.ps01`, both with `Enabled=True`. [OU screenshot](../evidence/day-02/01-lab-ou-and-users.png) · [Read-back screenshot](../evidence/day-02/02-scoped-user-query.png)

### OU-scoped user query

The captured SearchBase is:

```text
OU=IAM-Automation,DC=balticfinance,DC=test
```

The query used the following scope, filter and selected properties:

```powershell
Get-ADUser `
    -SearchBase $labOu `
    -SearchScope OneLevel `
    -Filter "SamAccountName -like 'iam.*'" `
    -Properties Department, Title |
    Select-Object Name, SamAccountName, Enabled, Department, Title |
    Format-Table -AutoSize
```

The result shows both test users as direct children of the lab OU. Department and Title are empty in this capture. [Screenshot 02](../evidence/day-02/02-scoped-user-query.png)

### Attribute update and independent verification

The owner read `iam.ps01` before and after updating its attributes:

```powershell
'BEFORE'

Get-ADUser -Identity 'iam.ps01' -Properties Department, Title |
    Format-List SamAccountName, Department, Title

Set-ADUser -Identity 'iam.ps01' `
    -Department 'IT' `
    -Title 'IAM Automation Trainee' `
    -ErrorAction Stop

'AFTER'

Get-ADUser -Identity 'iam.ps01' -Properties Department, Title |
    Format-List SamAccountName, Department, Title
```

The BEFORE read shows empty Department and Title. The AFTER read shows `Department=IT` and `Title=IAM Automation Trainee` for the same `iam.ps01` account. [Screenshot 03](../evidence/day-02/03-user-attributes-before-after.png)

### Saved PowerShell example

The uploaded [day-02-user-attributes.ps1](../scripts/day-02-user-attributes.ps1) contains the same read/update/read sequence, with the target stored in `$labUser`. Each run sets that lab account's Department to IT and Title to IAM Automation Trainee.

The screenshot records the console commands used during the lab. The saved file was reviewed separately for its contents and PowerShell syntax. [Usage notes](../scripts/README.md)

## Evidence coverage

Screenshot 01 records the resulting OU contents, screenshot 02 independently reads both users, and screenshot 03 records the attribute change and its read-back. The creation methods come from the guided procedure followed by the owner.

[Detailed test results](../tests/day-02.md) · [Evidence page](../evidence/day-02/README.md)
