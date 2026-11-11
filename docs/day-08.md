# Day 08 — Capstone, Pester and portfolio review

**Status** · Documented from twenty-six screenshots and successful GitHub Actions validation

[Test results](../tests/day-08.md) · [Evidence index](../evidence/day-08/README.md) · [Lifecycle source](../scripts/Invoke-IamLifecycle.ps1) · [Pester suite](../tests/unit/Lifecycle.Tests.ps1)

## Objective and result

Validate the AD lifecycle with a fresh synthetic identity, real Windows access, same-stage repeats, a controlled failure and an outside-OU request. The lab completed the lifecycle for iam.lab002 / LAB-002 and the separate scope check for iam.lab003 / LAB-003.

The live results establish Finance access after Joiner, Finance denial and IT access after Mover recovery, and a disabled-account sign-in rejection after Leaver. Independent directory reads, saved before/after state and CSV audit views support the directory and safety checks. Pester and the separate offline assertion runner pass in CI using simulated AD.

## Environment and inputs

| Component | Recorded observation |
| --- | --- |
| Controller and operator | BFL-DC01 / BFL\Administrator |
| Live runtime | Windows PowerShell 5.1.26100.33438 |
| Client | BFL-WKS01; access commands run as bfl\iam.lab002 |
| Working root | C:\IAM-Automation\day-08 |
| Lifecycle version | 0.2.0, copied from the completed Day 07 workspace |
| Managed OU | OU=JML,OU=IAM-Automation,DC=balticfinance,DC=test |
| Managed groups | GG-IAM-LAB-Finance and GG-IAM-LAB-IT |
| Test shares | IAM-LAB-Finance and IAM-LAB-IT, each with proof.txt |
| Primary test identity | Marek Example / iam.lab002 / LAB-002 |
| Outside-OU identity | Scope Example / iam.lab003 / LAB-003, initially disabled with Finance membership |

The preflight confirms zero identity collisions for LAB-002, both shares and both proof files. The previous iam.lab001 remains disabled. The new workspace keeps the original Day 07 records separate.

The recorded VM uses its own samples/hr-events.example.csv containing JML-101 through JML-103. The repository preserves the Day 07 feed and publishes this second feed as [hr-events.day08.example.csv](../samples/hr-events.day08.example.csv). Use EventsPath when reproducing it from the repository root.

| Event | Type | Employee | Department |
| --- | --- | --- | --- |
| JML-101 | Joiner | LAB-002 | Finance |
| JML-102 | Mover | LAB-002 | IT |
| JML-103 | Leaver | LAB-002 | Empty |
| JML-201 | Leaver, separate scope-test CSV | LAB-003 | Empty |

## WhatIf and Joiner

Apply with WhatIf for JML-101 planned two operations, applied zero and left the account absent. An independent block queried matching accounts and read each managed group's objectGUID and sorted direct member DNs before and after. Both user counts were zero, and ManagedGroupsUnchanged and TargetAndGroupsUnchanged were True.

The real Joiner then completed two steps: CreateUser and AddGroupMember Finance. Its result reports Enabled=True, Department=Finance, Finance membership and zero remaining operations. From a new client session, hostname reports BFL-WKS01, whoami reports bfl\iam.lab002 and the Finance proof file returns FINANCE - access test successful.

Repeating JML-101 with Apply reports NoChange, zero planned/applied/remaining operations and ManagedStateUnchanged=True.

## Controlled Mover failure and recovery

The first Mover preview planned SetDepartment IT, RemoveGroupMember Finance and AddGroupMember IT. The exercise used Apply with SimulateFailureAfterRemoval.

The expected injected exception stopped the run after the successful old-group removal. Independent AD reads show Enabled=True, Department=IT, Finance=False and IT=False. The CSV view shows two Applied steps, one Failed Run record and no IT grant records. The completed Finance removal retains its Applied status.

A new preview of the same event planned only AddGroupMember IT. Applying that plan without the exercise switch completed exactly one operation and reported zero remaining operations.

~~~mermaid
flowchart LR
    J["Joiner: enabled + Finance"] --> M["Mover: set IT; remove Finance"]
    M --> F["Injected stop: neither lab group"]
    F --> P["Fresh plan: add IT only"]
    P --> R["Recovery: enabled + IT"]
    R --> L["Leaver: disabled; no lab groups"]
~~~

The client procedure fully signed the user out and signed it in again before access checks. In that session the same Finance proof-file path returns PermissionDenied / UnauthorizedAccessException, while the IT proof file returns IT - access test successful. Repeating the completed Mover reports NoChange and zero operations.

## Leaver and sign-in

The preview planned DisableUser followed by removal from IT. Apply completed both steps, retained the account, set Enabled=False and left no managed memberships.

The guided test signed the client user out before applying Leaver, then attempted a new password sign-in with the DC running. The captured Windows screen displays Marek Example and Your account has been disabled. Please see your system administrator. An independent AD read links that display name to iam.lab002 / LAB-002 and confirms Enabled=False, Department=IT, the same JML DN and both memberships False.

The procedure included a DC TCP 88 reachability check before sign-out; no separate connectivity screenshot was collected. The sign-in image is a cropped result screen; the preceding client hostname/whoami evidence and the following AD identity read provide its lab context.

Repeating Leaver reports NoChange, zero operations, unchanged managed state and an account that remains disabled. These observations establish new-sign-in rejection, not termination of existing sessions.

## Outside-OU boundary and manual cleanup

The lab-only [Initialize-CapstoneScopeTest.ps1](../scripts/Initialize-CapstoneScopeTest.ps1) prepared a disabled identity directly in IAM-Automation, outside JML, and manually added it to Finance. It saved a native AD baseline under local-output/scope-test-before.json and created the separate [scope-test feed](../samples/hr-events.out-of-scope.example.csv).

A disabled Leaver with a remaining Finance membership still has an entitlement to remove. The test therefore requests a needed change while checking that the account boundary takes precedence.

Apply for JML-201 was rejected with:

~~~text
The resolved account DN differs from the approved lifecycle account DN.
~~~

The independent verification re-reads the account by its saved objectGUID and compares the same fields, object revision and membership booleans with the baseline. It reports UserRevisionUnchanged=True, TargetStateUnchanged=True, Finance=True before and after, and IT=False. The audit contains only Run Started and Run Failed, with StartedWriteSteps=0, AppliedOperations=0 and the expected rejection message.

After preserving that evidence, the operator manually removed the test Finance membership. The final cleanup view shows iam.lab003 still disabled and both managed memberships False. This setup/cleanup is separate from the blocked lifecycle invocation; the lifecycle configuration remains scoped to JML.

## Reproducing the recorded commands

Use a disposable lab with the configured DC, exact OU and groups, and an appropriate operator. Create config/lab.local.json from the example and set its lab identifiers.

From the repository root, select the capstone feed explicitly:

~~~powershell
$labEvents = '.\samples\hr-events.day08.example.csv'

.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-101' -EventsPath $labEvents -Apply -WhatIf
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-101' -EventsPath $labEvents -Apply

.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-102' -EventsPath $labEvents
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-102' -EventsPath $labEvents -Apply -SimulateFailureAfterRemoval
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-102' -EventsPath $labEvents
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-102' -EventsPath $labEvents -Apply

.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-103' -EventsPath $labEvents -Apply
~~~

These commands describe the recorded lifecycle stages. The completed lab identities are now disabled. For a new full run, prepare a fresh synthetic LAB-nnn identity and event set rather than treating reactivation or an old event as normal retry behavior. Review each event's current-state plan before Apply.

The scope helper is specific to the recorded Baltic Finance lab and deliberately performs manual fixture setup outside the lifecycle OU. It has its own ShouldProcess guard and refuses existing identities or baseline/event files. It is not a general provisioning entry point.

## Pester and CI

The suite adds 41 lifecycle tests to the three existing repository tests. It covers validation, exact boundaries, ordering, writer mocks for Preview/WhatIf, same-stage repeats, partial recovery, binding replacement, read-back failure, audit failure and secret exclusion. Directory operations use a simulated adapter copied into TestDrive; no live credentials are required.

The full Pester suite runs with PowerShell 7 and Pester 5.7.1 in CI. The separate 50-check runner remains available and the AD entry point retains its Windows PowerShell 5.1 support.

[Recorded successful main run](https://github.com/krzysztof-szot/iam-powershell-automation-project/actions/runs/43039551586) · [CI result record](../evidence/day-08/ci-summary.md)

## Coverage limits

The live exercise used a lab administrator, one domain/controller, two department groups and a few synthetic accounts. It did not validate delegated least-privilege permissions, large-directory performance, multi-DC races or revocation of existing sessions. The workflow has step logging and current-state reconciliation, not a transaction, automatic rollback or a durable event-processing ledger. Raw VM audit CSV and baseline JSON files remain local; their screenshots are retained, and no original exports are reconstructed from images.
