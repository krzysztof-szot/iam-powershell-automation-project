# PowerShell entry points

## Available examples

| Script | Purpose |
| --- | --- |
| [day-02-user-attributes.ps1](day-02-user-attributes.ps1) | Read iam.ps01, set Department to IT and Title to IAM Automation Trainee, and read the attributes again. |
| [day-03-group-memberships.ps1](day-03-group-memberships.ps1) | Read direct members of the Finance and IT lab groups and report whether iam.gui01 is present. |
| [Invoke-IamLifecycle.ps1](Invoke-IamLifecycle.ps1) | Preview or apply one synthetic Joiner, Mover or Leaver event in the isolated JML OU; log and verify each step. |
| [Initialize-CapstoneScopeTest.ps1](Initialize-CapstoneScopeTest.ps1) | Prepare the recorded lab's disabled outside-OU fixture, temporary Finance membership, scope-test feed and local baseline. |

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

## Day 06 recorded console workflow

The Day 06 evidence records New-ADGroup, Add-ADGroupMember, Set-ADUser and Get-MgUser operations for the dedicated Cloud Sync test identity. The lab record explains the selected-group correction, source-anchor comparison and on-demand department update.

[Day 06 record](../docs/day-06.md) · [Captured commands and results](../evidence/day-06/README.md)

## Day 07 lifecycle entry point

Copy config/lab.example.json to config/lab.local.json and set the actual lab DC, domain, exact JML OU and group DNs. Keep schemaVersion 1. Local configuration and runtime logs are ignored by Git. This configuration is for the AD-only lifecycle entry point; the earlier Graph and Cloud Sync exercises are documented separately.

From the repository root:

~~~powershell
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-001'
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-001' -Apply -WhatIf
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-001' -Apply

.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-002'
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-002' -Apply

.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-003'
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-003' -Apply
~~~

Review the corresponding preview before applying. The default event file is samples/hr-events.example.csv; ConfigPath, MatrixPath, EventsPath and OutputDirectory can override the default paths.

A new Joiner prompts for a SecureString password only after ShouldProcess permits account creation. InitialPassword also accepts a caller-supplied SecureString; it is never written to the audit. Keep the lab password locally for fresh workstation tests. The lab creation sets ChangePasswordAtLogon=False.

Each run creates a CSV under local-output, including Preview and WhatIf. A successful run reports Completed with zero remaining operations. At its completed current stage, a repeated event can report NoChange. Existing disabled accounts are never reactivated by Joiner.

For a controlled Day 08 Mover recovery exercise only, SimulateFailureAfterRemoval deliberately throws after the successful old-group removal. Inspect the audit and a new preview, then retry without that switch. [Recovery procedure](../docs/recovery-runbook.md)

[Day 07 lab record](../docs/day-07.md) · [Module notes](../src/IamAutomation/README.md) · [Tests](../tests/day-07.md)

## Day 08 capstone and scope fixture

The capstone feed is samples/hr-events.day08.example.csv. Select it explicitly with EventsPath when using the repository layout; it contains JML-101/102/103 for LAB-002.

~~~powershell
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-101' -EventsPath '.\samples\hr-events.day08.example.csv' -Apply -WhatIf
~~~

The separate Initialize-CapstoneScopeTest.ps1 helper is specific to the recorded Baltic Finance lab. It uses the pinned DC and parent IAM-Automation OU to prepare a disabled LAB-003 fixture outside JML and temporary Finance membership. It saves local-output/scope-test-before.json and samples/hr-events.out-of-scope.example.csv, refuses existing identities/files and honors ShouldProcess/WhatIf.

~~~powershell
.\scripts\Initialize-CapstoneScopeTest.ps1 -ProjectRoot (Get-Location).Path

.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-201' -EventsPath '.\samples\hr-events.out-of-scope.example.csv' -Apply
~~~

The second command is expected to fail the exact account-DN boundary. The live before/after read confirms unchanged state and zero write-step starts. The operator then manually removes only the fixture's temporary Finance membership. This manual test setup/cleanup does not broaden the lifecycle configuration.

[Day 08 record and results](../docs/day-08.md) · [Scope evidence](../evidence/day-08/README.md) · [Pester instructions](../tests/unit/README.md)
