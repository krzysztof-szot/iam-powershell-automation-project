# Day 03 — Owner-supplied console excerpts

The owner pasted the following output during the guided lab. These selected lines retain the acting identity, membership queries, attempted group changes and returned errors. The subsequent successful administrative transfer is documented separately. [Successful transfer screenshot](03-memberships-before-after.png)

## Initial identity and membership

```text
PS C:\WINDOWS\system32> whoami
bfl\iam.gui01

PS C:\WINDOWS\system32> 'BEFORE - iam.gui01'
BEFORE - iam.gui01
PS C:\WINDOWS\system32> Get-ADPrincipalGroupMembership -Identity 'iam.gui01' |
>>     Where-Object { $_.Name -like 'GG-IAM-LAB-*' } |
>>     Select-Object Name |
>>     Format-Table -AutoSize

Name
----
GG-IAM-LAB-Finance
```

## Denied group changes

```text
PS C:\WINDOWS\system32> Remove-ADGroupMember `
>>     -Identity 'GG-IAM-LAB-Finance' `
>>     -Members 'iam.gui01' `
>>     -Confirm:$false `
>>     -ErrorAction Stop
Remove-ADGroupMember : Insufficient access rights to perform the operation
    + FullyQualifiedErrorId : ActiveDirectoryServer:8344,Microsoft.ActiveDirectory.Management.Commands.RemoveADGroupMember

PS C:\WINDOWS\system32> Add-ADGroupMember `
>>     -Identity 'GG-IAM-LAB-IT' `
>>     -Members 'iam.gui01' `
>>     -ErrorAction Stop
Add-ADGroupMember : Insufficient access rights to perform the operation
    + FullyQualifiedErrorId : ActiveDirectoryServer:8344,Microsoft.ActiveDirectory.Management.Commands.AddADGroupMember
```

## Membership after the denied attempts

```text
PS C:\WINDOWS\system32> 'AFTER - iam.gui01'
AFTER - iam.gui01
PS C:\WINDOWS\system32> Get-ADPrincipalGroupMembership -Identity 'iam.gui01' |
>>     Where-Object { $_.Name -like 'GG-IAM-LAB-*' } |
>>     Select-Object Name |
>>     Format-Table -AutoSize

Name
----
GG-IAM-LAB-Finance
```
