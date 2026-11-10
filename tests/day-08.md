# Day 08 — Capstone, Pester and portfolio review tests

[Implementation plan](../docs/day-08.md) · [Evidence checklist](../evidence/day-08/README.md)

| ID | Procedure | Expected | Actual | Status | Planned evidence |
| --- | --- | --- | --- | --- | --- |
| D08-01 | Run Joiner, Mover and Leaver on a fresh domain account | Finance opens after Joiner, Finance denies and IT opens after Mover, and fresh domain logon is denied after Leaver. | Pending | Planned | `01-joiner-finance-access.png`, `02-mover-finance-denied.png`, `03-mover-it-access.png`, `04-leaver-domain-logon-denied.png` |
| D08-02 | Request a change for a known user outside the lab OU | The operation is rejected before any write. | Pending | Planned | `05-out-of-scope-blocked.png` |
| D08-03 | Compare AD state before and after Apply with -WhatIf | The preview is visible and the account and memberships are unchanged. | Pending | Planned | `06-whatif-state-preserved.png` |
| D08-04 | Replay the same event at the same stage | The second run makes zero additional changes. | Pending | Planned | `07-repeat-event-noop.png` |
| D08-05 | Resume after a controlled failure during Mover | Recovery applies only the missing step and the final group state matches policy. | Pending | Planned | `08-partial-run-and-recovery.png` |
| D08-06 | Run the offline Pester suite in GitHub Actions | The workflow completes successfully on synthetic fixtures. | Pending | Planned | `09-pester-ci-passed.png` |
