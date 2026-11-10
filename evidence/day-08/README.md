# Day 08 — Capstone, Pester and portfolio review evidence

[Implementation plan](../../docs/day-08.md) · [Test record](../../tests/day-08.md)

| Planned file | Intended observation |
| --- | --- |
| `01-joiner-finance-access.png` | The new test user opens the Finance test file. |
| `02-mover-finance-denied.png` | The old Finance share returns an authorization denial after the transfer. |
| `03-mover-it-access.png` | The transferred user opens the IT test file. |
| `04-leaver-domain-logon-denied.png` | A fresh domain logon with the disabled test account is rejected. |
| `05-out-of-scope-blocked.png` | The automation rejects an existing target outside the permitted OU. |
| `06-whatif-state-preserved.png` | The proposed changes are visible and independent reads show the same state before and after. |
| `07-repeat-event-noop.png` | Repeating the same event at the same stage produces zero additional writes. |
| `08-partial-run-and-recovery.png` | A controlled failure is logged and the resumed run applies the missing step. |
| `09-pester-ci-passed.png` | GitHub Actions reports a successful Pester run for the matching commit. |
