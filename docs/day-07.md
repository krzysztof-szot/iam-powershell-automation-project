# Day 07 — Build the Joiner–Mover–Leaver automation

**Status** · Documented from sixteen lab screenshots

[Tests](../tests/day-07.md) · [Evidence index](../evidence/day-07/README.md) · [Entry point](../scripts/Invoke-IamLifecycle.ps1) · [Module](../src/IamAutomation/IamAutomation.psm1)

## Objective and result

Build an AD-only lifecycle workflow from a synthetic HR feed and an access matrix. Version 0.1.0 first produced a read-only Joiner plan. Version 0.2.0 added explicit Apply, ShouldProcess, per-run CSV logging and fresh read-back after each write.

The live sequence completed Joiner, Mover and Leaver for one disposable identity, iam.lab001 / LAB-001. Independent AD reads and CSV audit views confirm the state at each stage. Fresh workstation access, repeated events and live failure/recovery exercises remain in Day 08.

## Recorded environment and scope

| Component | Observation |
| --- | --- |
| Execution host and operator | BFL-DC01 / BFL\Administrator |
| Runtime | Windows PowerShell 5.1.26100.33438, RemoteSigned |
| Working root | C:\IAM-Automation\day-07 |
| Pinned DC | BFL-DC01.balticfinance.test |
| Domain | balticfinance.test |
| Parent OU | OU=IAM-Automation,DC=balticfinance,DC=test |
| Lifecycle OU | OU=JML,OU=IAM-Automation,DC=balticfinance,DC=test |
| Account | CN=iam.lab001 in the lifecycle OU; DisplayName Anna Example |
| Managed groups | GG-IAM-LAB-Finance and GG-IAM-LAB-IT, both Security groups directly in IAM-Automation |
| Initial collision checks | Zero SAM-name matches and zero EmployeeID matches |
| Separate hybrid identity | The earlier IAM-Sync OU and iam.sync01 were outside this workflow |

The OU screenshot shows JML beside IAM-Sync. The input-file check confirms the server, OU, group DNs, department entitlements and three CSV events.

## Inputs and layout

- [config/lab.example.json](../config/lab.example.json): schemaVersion 1 and example domain identifiers. Copy to config/lab.local.json and set the DC, domain, exact JML OU and the two group DNs.
- [config/access-matrix.example.json](../config/access-matrix.example.json): Finance maps to FinanceAccess; IT maps to ITAccess.
- [samples/hr-events.example.csv](../samples/hr-events.example.csv): the three synthetic events below.
- [scripts/Invoke-IamLifecycle.ps1](../scripts/Invoke-IamLifecycle.ps1): command entry point.
- [src/IamAutomation/IamAutomation.psm1](../src/IamAutomation/IamAutomation.psm1): validation, snapshots, planning, execution and audit functions.
- local-output/: local run logs; excluded from Git.

| EventId | EventType | EmployeeId | Department |
| --- | --- | --- | --- |
| JML-001 | Joiner | LAB-001 | Finance |
| JML-002 | Mover | LAB-001 | IT |
| JML-003 | Leaver | LAB-001 | Empty |

The synthetic account name is derived from EmployeeId: LAB-001 becomes iam.lab001. AD Name/CN uses that SAM name; GivenName, Surname and DisplayName retain the synthetic person's profile.

## Recorded execution

Run the entry point from the project root. Preview is the default:

~~~powershell
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-001'
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-001' -Apply -WhatIf
~~~

The v0.1.0 preview reported two planned operations and no account before or after. The v0.2.0 WhatIf run reported PlannedOperations=2, AppliedOperations=0, RemainingOperations=2 and ManagedStateUnchanged=True. It printed CreateUser and AddGroupMember WhatIf messages and created a local audit CSV.

After reviewing each event's preview, the recorded Apply commands were:

~~~powershell
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-001' -Apply
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-002' -Apply
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-003' -Apply
~~~

The Joiner prompted for a SecureString password only when creation was needed. The isolated lab account was created with ChangePasswordAtLogon=False for later workstation testing. No password is stored in the HR CSV, source or audit records.

| Stage | Ordered applied operations | Independent AD result | Audit result |
| --- | --- | --- | --- |
| Joiner | CreateUser; AddGroupMember Finance | Enabled=True; Department=Finance; Finance=True; IT=False | 2 Applied, 0 Failed, RunCompleted=True |
| Mover | SetDepartment IT; RemoveGroupMember Finance; AddGroupMember IT | Enabled=True; Department=IT; Finance=False; IT=True | 3 Applied, 0 Failed, RunCompleted=True |
| Leaver | DisableUser; RemoveGroupMember IT | Enabled=False; Department=IT; Finance=False; IT=False | 2 Applied, 0 Failed, RunCompleted=True |

All three Apply summaries report Status=Completed and RemainingOperations=0. The account remains in JML after Mover and Leaver. Leaver preserves the account and its Department attribute while disabling it and removing managed direct memberships.

## Independent verification and audit

The verification blocks call Get-ADUser with EmployeeID and Department, then Get-ADGroupMember separately for each managed group on the configured DC. They compare member objectGUIDs to the account objectGUID and print the raw account fields, DN and direct-membership booleans. These are separate commands from the lifecycle entry point.

Each invocation creates a timestamped, randomly identified CSV. The live views show Started and Applied records for every successful step and a final Run / Completed record. Summaries count Applied records, Failed records and the final completion record. The recorded counts are 2, 3 and 2 Applied, each with zero Failed.

The CSV columns are TimestampUtc, RunId, EventId, EventType, EmployeeId, SamAccountName, Operator, Computer, Mode, Step, Action, Target, Value, Status and Message. The screenshots show real lab output. Raw audit files remain in local-output; they are not reconstructed or committed as original CSV evidence.

## Implementation boundaries

Input validation checks schema versions, CSV columns, unique event IDs, known event types, LAB-nnn employee IDs, policy entitlements and exact OU/group boundaries before directory writes. A domain-wide collision query resolves EmployeeID, SAM name and the expected UPN.

The adapter rejects ambiguous identities, accounts outside the exact lifecycle DN, identity mismatches and protected/critical objects. All AD operations use the configured server. Writes bind to objectGUIDs, re-read before execution, re-plan the remaining work and verify the resulting state. Group replacement or account replacement during the run aborts execution when detected.

Default Preview and Apply with WhatIf preserve managed directory state. They intentionally create audit files. Apply uses ShouldProcess before each write and before any password prompt. Leaver disables first; Mover removes old managed access before granting new managed access. Only the two configured groups are reconciled.

AD operations are not transactional. A failed run can leave completed steps in place. Review the log and a fresh plan before retrying. A repeated event at its completed current stage can be NoChange; this is state reconciliation, not a persistent event-processing ledger. A disabled account is never silently reactivated by Joiner.

[Recovery procedure](recovery-runbook.md) · [Permissions](permissions.md#day-07-recorded-ad-lifecycle-operations)

## Offline validation and remaining live tests

The [offline assertion runner](../tests/offline/Lifecycle.Checks.ps1) uses a [mutable simulated AD adapter](../tests/offline/fixtures/ActiveDirectory.psm1). Its 50 checks passed in Windows PowerShell 5.1 and PowerShell 7 before the package was used in the VM. They cover plans, scope checks, WhatIf, write ordering, no-op repeats, read-back failures, partial Mover recovery and identity/group replacement.

This custom assertion runner is separate from the scaffold Pester tests. GitHub Actions runs both. Day 08 will extend the lifecycle coverage in Pester and collect the remaining live evidence.

The Day 07 screenshots establish directory state and audit outcomes. They do not establish fresh SMB access, fresh disabled-account logon rejection or termination of existing sessions.

- [PowerShell ShouldProcess and WhatIf](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess)
- [Get-ADUser](https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-aduser)
- [Get-ADGroupMember](https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adgroupmember)
