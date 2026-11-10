# Day 05 — Cloud-only lifecycle in Entra ID Free tests

[Implementation plan](../docs/day-05.md) · [Evidence checklist](../evidence/day-05/README.md)

| ID | Procedure | Expected | Actual | Status | Planned evidence |
| --- | --- | --- | --- | --- | --- | --- |
| D05-01 | Apply Joiner to a dedicated cloud-only account | The account exists with the Finance membership. | Pending | Planned | `01-graph-joiner.png` |
| D05-02 | Apply Mover and then Leaver | IT replaces Finance, then the account is disabled and managed groups are removed. | Pending | Planned | `02-cloud-membership-before-after.png` |
| D05-03 | Inspect Entra Audit Logs | Recorded operations match the lab actor, target and time. | Pending | Planned | `04-entra-audit-event.png` |
