# Day 03 — Mover in Active Directory tests

[Implementation plan](../docs/day-03.md) · [Evidence checklist](../evidence/day-03/README.md)

| ID | Procedure | Expected | Actual | Status | Planned evidence |
| --- | --- | --- | --- | --- | --- | --- |
| D03-01 | Apply Finance to IT transfer | Finance is removed, IT is added and the control group is preserved. | Pending | Planned | `01-membership-diff.png` |
| D03-02 | Open both shares in a fresh session | The same UNC paths now deny Finance and allow IT. | Pending | Planned | `02-finance-access-denied.png` |
| D03-03 | Reapply the Mover event | No additional writes are needed. | Pending | Planned | `04-mover-rerun-noop.png` |
