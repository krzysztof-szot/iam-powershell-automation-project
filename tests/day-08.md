# Day 08 — Capstone and safety test results

[Lab record](../docs/day-08.md) · [Evidence](../evidence/day-08/README.md) · [Pester suite](unit/Lifecycle.Tests.ps1)

## Live lab checks

| ID | Procedure | Expected | Observed | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| D08-01 | Check environment and fresh event set | Ready DC/client resources, zero identity collisions, three valid LAB-002 events | Correct lab scope/runtime; both proof files; zero collisions; JML-101/102/103 loaded | Passed | [01](../evidence/day-08/01-capstone-environment.png), [02](../evidence/day-08/02-capstone-input-files.png) |
| D08-02 | Run Apply with WhatIf and independently compare state | No account creation or managed group changes | 2 planned, 0 applied; zero matching accounts before/after; group identities and sorted direct memberships unchanged | Passed | [03](../evidence/day-08/03-capstone-whatif.png), [04](../evidence/day-08/04-capstone-whatif-state-preserved.png) |
| D08-03 | Apply Joiner and read Finance from the client | Enabled Finance user can read the exact test share | 2 operations completed; BFL-WKS01 / bfl\iam.lab002 reads FINANCE - access test successful | Passed | [05](../evidence/day-08/05-capstone-joiner-applied.png), [06](../evidence/day-08/06-capstone-joiner-finance-access.png) |
| D08-04 | Replay completed Joiner at the same stage | No additional operations | NoChange; 0 planned/applied/remaining; unchanged=True | Passed | [07](../evidence/day-08/07-capstone-joiner-repeat-noop.png) |
| D08-05 | Inject failure after Mover's old-group removal | Department changed, old group removed, new grant not reached | IT department; neither membership; 2 Applied audit steps; Failed Run; ITGrantRecords=0 | Passed | [08](../evidence/day-08/08-capstone-mover-preview.png), [09](../evidence/day-08/09-capstone-mover-injected-failure.png), [10](../evidence/day-08/10-capstone-mover-partial-state.png), [11](../evidence/day-08/11-capstone-mover-partial-log.png) |
| D08-06 | Re-plan and resume the same Mover without the exercise flag | Only the missing IT grant is applied | One AddGroupMember planned and applied; Completed; 0 remaining | Passed | [12](../evidence/day-08/12-capstone-mover-recovery-preview.png), [13](../evidence/day-08/13-capstone-mover-recovery-applied.png) |
| D08-07 | Check both proof files after a full client sign-out/sign-in | Finance denied and IT readable | Same host/user/path context; Finance PermissionDenied; IT successful | Passed | [14](../evidence/day-08/14-capstone-mover-finance-denied.png), [15](../evidence/day-08/15-capstone-mover-it-access.png) |
| D08-08 | Replay completed Mover | No additional operations | NoChange, all operation counts zero, unchanged=True | Passed | [16](../evidence/day-08/16-capstone-mover-repeat-noop.png) |
| D08-09 | Apply Leaver and attempt a new client password sign-in | Disable before revocation; disabled-account sign-in rejected | 2 applied, 0 remaining; Enabled=False; Windows displays the disabled-account message for Marek Example | Passed | [17](../evidence/day-08/17-capstone-leaver-preview.png), [18](../evidence/day-08/18-capstone-leaver-applied.png), [19](../evidence/day-08/19-capstone-leaver-domain-logon-denied.png) |
| D08-10 | Independently read final identity and replay Leaver | Disabled LAB-002, neither membership, repeat is a no-op | DisplayName/SAM/employee/DN correlated; Enabled=False; Finance=False; IT=False; repeat NoChange | Passed | [20](../evidence/day-08/20-capstone-leaver-verification.png), [21](../evidence/day-08/21-capstone-leaver-repeat-noop.png) |
| D08-11 | Prepare outside-OU fixture with access still to revoke | Existing disabled LAB-003 outside JML with Finance membership | Direct parent IAM-Automation DN; Finance=True; IT=False; baseline saved | Passed | [22](../evidence/day-08/22-capstone-out-of-scope-fixture.png) |
| D08-12 | Apply Leaver for the outside-OU identity and compare native AD state | Exact OU rejection before writes; state retained | Expected DN-boundary exception; revision/state unchanged; Finance=True before/after; 0 started write steps; 0 Applied; only Run Started/Failed | Passed | [23](../evidence/day-08/23-capstone-out-of-scope-blocked.png), [24](../evidence/day-08/24-capstone-out-of-scope-state-preserved.png) |
| D08-13 | Manually remove the scope fixture's temporary Finance membership after collecting proof | Disabled fixture with neither managed membership | CleanupStatus=Completed; Enabled=False; Finance=False; IT=False | Passed | [25](../evidence/day-08/25-capstone-scope-fixture-cleanup.png) |

## Automated checks

The main-branch code-validation run passes 44 Pester tests: 41 lifecycle tests plus three repository checks. The separate assertion runner passes 50 checks. These use simulated directory operations and synthetic fixtures, separately from the live observations above.

Pester writer mocks assert zero New-ADUser, Set-ADUser, Disable-ADAccount, Add-ADGroupMember and Remove-ADGroupMember calls for read-only runs. Additional tests cover failed revocation blocking a new grant, ambiguous/out-of-scope identities, same-stage repeats, partial recovery, replaced bindings, read-back/audit failures and secret exclusion.

The full Pester suite uses PowerShell 7 with Pester 5.7.1. The core AD entry point runs in Windows PowerShell 5.1 in the live lab.

| ID | Procedure | Observed | Status | Evidence |
| --- | --- | --- | --- | --- |
| D08-14 | Run lifecycle/repository Pester and the separate offline runner in GitHub Actions | 44 Pester passed, 0 failed; 50 assertion checks passed, 0 failed | Passed | [26](../evidence/day-08/26-capstone-pester-ci-passed.png), [CI result record](../evidence/day-08/ci-summary.md), [main run](https://github.com/krzysztof-szot/iam-powershell-automation-project/actions/runs/43039551586) |

## Interpretation

The disabled-account sign-in result is a new-logon check. Existing-session termination was not tested. The scope-test Failed Run is the expected rejection, not a successful lifecycle write. The later manual cleanup is recorded separately. Raw live audit/baseline files remain local, and screenshots are not expanded into fabricated original CSV/JSON records.
