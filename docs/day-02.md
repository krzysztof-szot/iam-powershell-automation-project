# Day 02 — Joiner in Active Directory

**Status** · Planned

[Tests](../tests/day-02.md) · [Screenshot checklist](../evidence/day-02/README.md)

## Objective

Create a disposable domain user from a synthetic HR event and prove that the intended access is available.

## Implementation plan

1. Resolve the employee to a stable lab identity and validate the target OU and groups before applying changes.
2. Create the lab user and grant the Finance group. Record account creation and group assignment as separate operations.
3. Validate membership independently and try both test shares in a fresh session on the Windows client. Run the same event again.

## Verification

Record observed results and deviations in the test record. Capture the planned evidence after running each scenario.
