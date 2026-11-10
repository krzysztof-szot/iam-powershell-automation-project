# Day 03 — Active Directory groups and effective access tests

[Implementation plan](../docs/day-03.md) · [Evidence checklist](../evidence/day-03/README.md)

| ID | Procedure | Expected | Actual | Status | Planned evidence |
| --- | --- | --- | --- | --- | --- |
| D03-01 | Inspect share and NTFS access rules for both SMB shares | Each intended department group has the access needed for its own share. | Pending | Planned | `01-smb-share-permissions.png` |
| D03-02 | Open the Finance test file before transfer | The Finance member can read the file. | Pending | Planned | `02-finance-baseline-allowed.png` |
| D03-03 | Transfer the user from Finance to IT | Direct Finance membership is absent and direct IT membership is present. | Pending | Planned | `03-memberships-before-after.png` |
| D03-04 | Try both UNC paths in a fresh Windows session | Finance returns an authorization denial and the IT test file opens. | Pending | Planned | `04-finance-access-denied.png`, `05-it-access-allowed.png` |
| D03-05 | Disable and re-enable a separate disposable account | Read-back shows Enabled change to False, then True. | Pending | Planned | `06-account-enabled-state.png` |
