# PowerShell entry points

## Available examples

| Script | Purpose |
| --- | --- |
| [day-02-user-attributes.ps1](day-02-user-attributes.ps1) | Read iam.ps01, set Department to IT and Title to IAM Automation Trainee, and read the attributes again. |
| [day-03-group-memberships.ps1](day-03-group-memberships.ps1) | Read direct members of the Finance and IT lab groups and report whether iam.gui01 is present. |

Use the Day 02 example in a PowerShell session with the ActiveDirectory module and permission to update `iam.ps01` in the intended lab domain. Start from the repository root:

```powershell
.\scripts\day-02-user-attributes.ps1
```

Each run writes the two configured attribute values. The BEFORE and AFTER sections show the account state observed during that run. The source was reviewed and syntax-checked, and the Day 02 screenshots record the original console sequence. [Lab record](../docs/day-02.md) · [Test results](../tests/day-02.md)

## Day 03 membership report

Run the membership example in a PowerShell session with the ActiveDirectory module and access to read the two lab groups. Start from the repository root:

```powershell
.\scripts\day-03-group-memberships.ps1
```

The script reads direct group membership and prints SamAccountName, Group and IsMember. After the recorded transfer, the expected values for iam.gui01 are Finance=False and IT=True. The uploaded source was reviewed and syntax-checked. The retained screenshots independently record the lab membership change and the resulting SMB access. [Day 03 record](../docs/day-03.md) · [Test results](../tests/day-03.md)

## Planned entry points

The AD examples from Days 02 and 03 will feed into the lifecycle script on Day 07. The Entra and Graph exercises in Days 04 and 05 use their own cloud-only test accounts.

| Script | Responsibility |
| --- | --- |
| `Invoke-IamLifecycle.ps1` | Accept a synthetic HR event, preview the plan for AD DS and honor explicit `Apply` intent and PowerShell `-WhatIf`. |
| `Get-IamAccessDrift.ps1` | Report unexpected or missing direct memberships if you choose the access drift track on Day 06. |

Shared planning and AD operations belong in the IAM module. [Module notes](../src/IamAutomation/README.md) · [Day 07 lifecycle exercise](../docs/day-07.md)
