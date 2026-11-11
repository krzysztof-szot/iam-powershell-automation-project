# Day 03 — Active Directory groups and effective access

**Status** · Completed documented scope  
Record updated 2026-11-11.

[Tests](../tests/day-03.md) · [Screenshots](../evidence/day-03/README.md) · [Membership example](../scripts/day-03-group-memberships.ps1)

## Objective

Demonstrate that transferring a test user between department groups changes effective SMB read access, and practice disabling and re-enabling a separate account.

The owner performed the lab actions. Six uploaded screenshots record the permissions, successful reads, group transfer, expected access denial and account state changes. An owner-supplied console excerpt records the earlier unauthorized group-change attempts.

## Lab configuration

| Component | Lab value |
| --- | --- |
| Domain controller and SMB host | BFL-DC01.balticfinance.test |
| Windows test client | BFL-WKS01 |
| Access-test identity | BFL\\iam.gui01 |
| Separate account-state identity | iam.ps01 |
| Finance group | GG-IAM-LAB-Finance |
| IT group | GG-IAM-LAB-IT |
| Finance share and local folder | IAM-LAB-Finance, `C:\LabShares\IAM-Automation\Finance` |
| IT share and local folder | IAM-LAB-IT, `C:\LabShares\IAM-Automation\IT` |

The guided setup used dedicated shares on the existing lab domain controller. Each folder contains a `proof.txt` file prepared by the administrator for read-access testing.

## Recorded results

### Share and NTFS permissions

The final permissions report reads each share separately. It shows the following Allow entries:

| Layer | Finance | IT |
| --- | --- | --- |
| SMB department access | BFL\\GG-IAM-LAB-Finance, Read | BFL\\GG-IAM-LAB-IT, Read |
| SMB administration | BFL\\Domain Admins, Full | BFL\\Domain Admins, Full |
| NTFS department access | BFL\\GG-IAM-LAB-Finance, ReadAndExecute and Synchronize | BFL\\GG-IAM-LAB-IT, ReadAndExecute and Synchronize |
| NTFS administration | SYSTEM and BUILTIN\\Administrators, FullControl | SYSTEM and BUILTIN\\Administrators, FullControl |

[Permissions screenshot](../evidence/day-03/01-smb-share-permissions.png)

### Finance baseline

On the Windows client, `whoami` returns `bfl\iam.gui01`. The same session reads the Finance proof file successfully:

```powershell
Get-Content '\\BFL-DC01.balticfinance.test\IAM-LAB-Finance\proof.txt'
```

The returned content is `FINANCE - access test successful`. [Baseline screenshot](../evidence/day-03/02-finance-baseline-allowed.png)

### Finance-to-IT group transfer

The BEFORE membership query for `iam.gui01`, filtered to `GG-IAM-LAB-*`, shows Finance. The corrected administrative sequence removes Finance and adds IT:

```powershell
Remove-ADGroupMember `
    -Identity 'GG-IAM-LAB-Finance' `
    -Members 'iam.gui01' `
    -Confirm:$false `
    -ErrorAction Stop

Add-ADGroupMember `
    -Identity 'GG-IAM-LAB-IT' `
    -Members 'iam.gui01' `
    -ErrorAction Stop
```

The AFTER query shows IT in the filtered membership view. [Membership screenshot](../evidence/day-03/03-memberships-before-after.png)

### Effective access after transfer

The guided procedure required signing out of BFL-WKS01 and signing in again as `BFL\iam.gui01`. The two retained access captures identify that account with `whoami` and show:

- Finance `proof.txt` returns `Access is denied`, `PermissionDenied` and `UnauthorizedAccessException`. [Finance denial](../evidence/day-03/04-finance-access-denied.png)
- IT `proof.txt` returns `IT - access test successful`. [IT read](../evidence/day-03/05-it-access-allowed.png)

The same Finance UNC path was readable before transfer and denied afterward. The IT read verifies the new department access. The session refresh is part of the owner's guided procedure, and both result screenshots record the acting identity and tested UNC path.

### Separate account disable and re-enable

On the administrative side of the lab, the owner read `iam.ps01`, disabled it and read the state again, then re-enabled it and performed a final read:

```powershell
Disable-ADAccount -Identity 'iam.ps01' -ErrorAction Stop
Enable-ADAccount -Identity 'iam.ps01' -ErrorAction Stop
```

The retained capture includes the reads between operations and records `Enabled=True → False → True`. Its evidence covers the account's directory state. [Account-state screenshot](../evidence/day-03/06-account-enabled-state.png)

## Troubleshooting

The first group-change attempt ran as `bfl\iam.gui01`. Both Remove-ADGroupMember and Add-ADGroupMember returned `Insufficient access rights to perform the operation` with `ActiveDirectoryServer:8344`. A subsequent read still showed Finance membership. The owner then repeated the transfer in the instructed administrative session on BFL-DC01 and supplied the successful before/after capture. [Owner-supplied console excerpts](../evidence/day-03/console-excerpts.md) · [Corrected transfer](../evidence/day-03/03-memberships-before-after.png)

The first combined SMB report displayed Finance entries twice. A separate query confirmed the IT share and its permissions, and the final report queried each share individually. The published permissions screenshot contains both distinct shares.

## Saved membership example

The uploaded [day-03-group-memberships.ps1](../scripts/day-03-group-memberships.ps1) reads direct members of the two configured groups and reports whether `iam.gui01` is present. After the recorded transfer, the expected report is Finance=False and IT=True. The uploaded source was reviewed and parsed for PowerShell syntax. [Usage notes](../scripts/README.md)

## Final recorded state

`iam.gui01` has IT membership in the filtered lab-group view, receives a Finance read denial and can read the IT proof file. The separate `iam.ps01` account is enabled after the exercise. The six screenshots support the five result checks in the test record.

[Test results](../tests/day-03.md) · [Evidence page](../evidence/day-03/README.md)
