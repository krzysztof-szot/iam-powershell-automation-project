# Day 06 — Optional AD-to-Entra synchronization or access drift report tests

[Implementation plan](../docs/day-06.md) · [Evidence checklist](../evidence/day-06/README.md)

Record results only for the track you run. Mark the other track as N/A. The project uses separate cloud-only accounts for the exercises in Days 04 and 05.

| ID | Procedure | Expected | Actual | Status | Planned evidence |
| --- | --- | --- | --- | --- | --- |
| D06-01 | Sync track. Review active configuration and staging scope | The preview contains the intended disposable lab account and any unrelated changes have been resolved before export. | Pending | Planned | `01-sync-scope-and-preview.png` |
| D06-02 | Sync track. Change an AD attribute and verify it in Entra | Read-back shows the same test identity, its configured anchor and the updated attribute. | Pending | Planned | `02-sync-attribute-verification.png` |
| D06-03 | Drift track. Report a controlled mismatch | The report identifies the exact missing or unexpected direct membership and its directory. | Pending | Planned | `03-access-drift-report.png` |
| D06-04 | Drift track. Recheck after the approved correction | The corrected membership matches the intended policy. | Pending | Planned | `04-access-drift-cleared.png` |
