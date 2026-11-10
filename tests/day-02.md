# Day 02 — Active Directory user management tests

[Implementation plan](../docs/day-02.md) · [Evidence checklist](../evidence/day-02/README.md)

| ID | Procedure | Expected | Actual | Status | Planned evidence |
| --- | --- | --- | --- | --- | --- |
| D02-01 | Create one user in the AD console and another with New-ADUser | Both test accounts can be read back from the dedicated lab OU. | Pending | Planned | `01-lab-ou-and-users.png` |
| D02-02 | Filter users under the lab OU | The result contains the intended users from that OU. | Pending | Planned | `02-scoped-user-query.png` |
| D02-03 | Change the second user's Department and Title | A new Get-ADUser query returns both intended values. | Pending | Planned | `03-user-attributes-before-after.png` |
