# PowerShell entry points

The AD examples from Days 02 and 03 will feed into the lifecycle script on Day 07. The Entra and Graph exercises in Days 04 and 05 use their own cloud-only test accounts.

| Script | Responsibility |
| --- | --- |
| `Invoke-IamLifecycle.ps1` | Accept a synthetic HR event, preview the plan for AD DS and honor explicit `Apply` intent and PowerShell `-WhatIf`. |
| `Get-IamAccessDrift.ps1` | Report unexpected or missing direct memberships if you choose the access drift track on Day 06. |

Shared planning and AD operations belong in the IAM module. [Module notes](../src/IamAutomation/README.md) · [Day 07 lifecycle exercise](../docs/day-07.md)
