# Day 04 — Leaver in Active Directory tests

[Implementation plan](../docs/day-04.md) · [Evidence checklist](../evidence/day-04/README.md)

| ID | Procedure | Expected | Actual | Status | Planned evidence |
| --- | --- | --- | --- | --- | --- | --- |
| D04-01 | Apply a Leaver event | The account is disabled and managed memberships are absent. | Pending | Planned | `01-account-disabled.png` |
| D04-02 | Attempt fresh domain authentication | The disabled identity is denied while the client can reach the DC. | Pending | Planned | `02-domain-logon-denied.png` |
| D04-03 | Inspect the domain controller Security log | An event confirms the disable operation and identifies the target. | Pending | Planned | `03-dc-audit-event.png` |
