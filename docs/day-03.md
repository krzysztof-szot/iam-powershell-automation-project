# Day 03 — Mover in Active Directory

**Status** · Planned

[Tests](../tests/day-03.md) · [Screenshot checklist](../evidence/day-03/README.md)

## Objective

Transfer the lab user from Finance to IT and prove the effective access changed.

## Implementation plan

1. Compare managed memberships with the IT target in the access matrix and preview the exact removals and additions.
2. Remove Finance access before adding IT access. Preserve a control membership outside the managed group list.
3. Use a fresh Windows session so old group tokens and open SMB sessions do not distort the result.

## Verification

Record observed results and deviations in the test record. Capture the planned evidence after running each scenario.
