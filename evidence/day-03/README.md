# Day 03 — Active Directory groups and effective access evidence

[Implementation plan](../../docs/day-03.md) · [Test record](../../tests/day-03.md)

| Planned file | Intended observation |
| --- | --- |
| `01-smb-share-permissions.png` | The dedicated shares have the expected lab group permissions. |
| `02-finance-baseline-allowed.png` | The test user can open the Finance test file before transfer. |
| `03-memberships-before-after.png` | Finance membership is removed and IT membership is present after transfer. |
| `04-finance-access-denied.png` | The same Finance share denies access in a fresh session. |
| `05-it-access-allowed.png` | The user can open the IT test file in the fresh session. |
| `06-account-enabled-state.png` | Independent reads show the disabled state and the re-enabled state of a separate test user. |
