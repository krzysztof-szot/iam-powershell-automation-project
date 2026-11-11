# Day 07 — Joiner–Mover–Leaver automation tests

[Lab record](../docs/day-07.md) · [Evidence](../evidence/day-07/README.md) · [Offline runner](offline/Lifecycle.Checks.ps1)

## Live lab results

| ID | Procedure | Expected | Observed | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| D07-01 | Check environment and prepare JML OU and inputs | Isolated OU, Security groups and no identity collision; three valid events | BFL-DC01 / BFL\Administrator; PS 5.1; JML OU; zero SAM and employee matches; three events loaded | Passed | [01](../evidence/day-07/01-lifecycle-environment.png), [02](../evidence/day-07/02-lifecycle-ou.png), [03](../evidence/day-07/03-lifecycle-input-files.png) |
| D07-02 | Run default Joiner preview | Two intended operations, unchanged directory state | v0.1.0 Preview; user absent before/after; PlannedOperations=2; ManagedStateUnchanged=True | Passed | [04](../evidence/day-07/04-lifecycle-preview.png) |
| D07-03 | Run Joiner Apply with WhatIf | No AD changes and no account creation | v0.2.0 WhatIf; 2 planned, 0 applied, 2 remaining; user absent; unchanged=True | Passed | [05](../evidence/day-07/05-lifecycle-whatif.png) |
| D07-04 | Apply Joiner | Create enabled account and add Finance | Completed; 2 applied, 0 remaining; Enabled=True; Department=Finance; Finance group present | Passed | [06](../evidence/day-07/06-lifecycle-joiner-applied.png) |
| D07-05 | Independently read Joiner state and audit | Expected identity/OU and Finance-only managed membership; successful step log | LAB-001 / iam.lab001 in JML; Enabled=True; Finance=True; IT=False; 2 Applied, 0 Failed, completed=True | Passed | [07](../evidence/day-07/07-lifecycle-joiner-verification.png), [08](../evidence/day-07/08-lifecycle-joiner-log.png) |
| D07-06 | Preview Mover | Department update, revoke Finance, grant IT; unchanged state | 3 planned, 0 applied; Department still Finance; unchanged=True | Passed | [09](../evidence/day-07/09-lifecycle-mover-preview.png) |
| D07-07 | Apply Mover | Update department and remove Finance before adding IT | Completed; 3 applied, 0 remaining; Department=IT; IT group present | Passed | [10](../evidence/day-07/10-lifecycle-mover-applied.png) |
| D07-08 | Independently read Mover state and audit | IT-only managed membership; ordered successful audit | Enabled=True; Department=IT; Finance=False; IT=True; 3 Applied, 0 Failed, completed=True | Passed | [11](../evidence/day-07/11-lifecycle-mover-verification.png), [12](../evidence/day-07/12-lifecycle-mover-log.png) |
| D07-09 | Preview Leaver | Disable before removing IT; unchanged state | 2 planned, 0 applied; still enabled and in IT; unchanged=True | Passed | [13](../evidence/day-07/13-lifecycle-leaver-preview.png) |
| D07-10 | Apply Leaver | Disable account and remove remaining managed membership | Completed; 2 applied, 0 remaining; Enabled=False; managed groups empty | Passed | [14](../evidence/day-07/14-lifecycle-leaver-applied.png) |
| D07-11 | Independently read Leaver state and audit | Account retained, disabled, neither managed membership; successful audit | Same JML DN and LAB-001; Enabled=False; Department=IT; Finance=False; IT=False; 2 Applied, 0 Failed, completed=True | Passed | [15](../evidence/day-07/15-lifecycle-leaver-verification.png), [16](../evidence/day-07/16-lifecycle-leaver-log.png) |

## Offline implementation checks

The custom assertion runner has 50 checks with a mutable in-memory AD adapter. It passed on Windows PowerShell 5.1.26100.9711 and PowerShell 7.6.9 during package validation. It uses no lab credentials and performs no real AD writes.

Coverage includes validation and exact OU/group boundaries; ambiguous/protected/out-of-scope accounts; default Preview and WhatIf with zero writer calls; happy lifecycle order; no-op repeats at the current stage; preservation of unrelated group membership; partial Mover retry; account/group replacement; failed revocation; ignored writes detected by read-back; audit failure before writes; secret exclusion from audit; and entry-point forwarding/error logging.

Run from the repository root in a separate process:

~~~powershell
pwsh -NoProfile -File ./tests/offline/Lifecycle.Checks.ps1
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File ./tests/offline/Lifecycle.Checks.ps1
~~~

The runner creates fixtures and audit files under local-output/offline-checks-<engine-major> and shadows AD commands with the simulated adapter inside that test process. The existing Pester scaffold checks remain a separate suite. Both are wired into the PowerShell checks workflow.

## Limits

The 50 offline checks are simulated tests, not additional live-lab results. Fresh SMB checks, disabled-account authentication, live same-stage repeats and live partial-failure recovery remain pending in [Day 08](day-08.md). The raw live CSV audit files were viewed in the VM; their screenshots are retained as evidence, and no original CSV files are reconstructed from those images.
