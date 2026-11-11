# IAM Automation module

[IamAutomation.psm1](IamAutomation.psm1) is the Day 07 AD-only lifecycle implementation, version 0.2.0. It supports Windows PowerShell 5.1 and PowerShell 7.

| Export | Responsibility |
| --- | --- |
| Read-IamLifecycleInput | Validate config/matrix schemas, synthetic CSV events, identity format and exact lab boundaries. |
| Get-IamAdSnapshot | Resolve the configured domain, OU, Security groups, domain-wide account collisions and direct managed memberships on the pinned DC. |
| New-IamLifecyclePlan | Produce ordered operations from current state, without directory calls or writes. |
| Write-IamRunRecord | Append the fixed audit fields to a local UTF-8 CSV; never serialize password parameters. |
| Invoke-IamLifecycleEvent | Coordinate Preview, ShouldProcess/WhatIf, GUID-bound Apply, fresh read-back and per-step logging. |

The [entry point](../../scripts/Invoke-IamLifecycle.ps1) supplies default paths and one log per invocation. WhatIf intentionally writes the audit CSV while preserving managed AD state. Only the exact synthetic account DN in JML and the two configured lab groups are eligible.

[Live results and boundaries](../../docs/day-07.md) · [Offline validation](../../tests/day-07.md) · [Recovery](../../docs/recovery-runbook.md)

Graph operations from the earlier days remain separate from this AD module.
