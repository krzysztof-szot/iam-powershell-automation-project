# Day 06 — Access drift and recovery tests

[Implementation plan](../docs/day-06.md) · [Evidence checklist](../evidence/day-06/README.md)

| ID | Procedure | Expected | Actual | Status | Planned evidence |
| --- | --- | --- | --- | --- | --- | --- |
| D06-01 | Compare expected and actual memberships | The report flags both missing and unexpected memberships. | Pending | Planned | `01-drift-report.png` |
| D06-02 | Inject failure after removal | The run reports partial execution and does not claim success. | Pending | Planned | `02-partial-failure.png` |
| D06-03 | Resume from observed state | Only the missing change is applied and final membership matches policy. | Pending | Planned | `03-resume-verified.png` |
