# Day 04 — Leaver in Active Directory

**Status** · Planned

[Tests](../tests/day-04.md) · [Screenshot checklist](../evidence/day-04/README.md)

## Objective

Disable a disposable domain account and remove project-managed access.

## Implementation plan

1. Approve the lab Leaver plan and disable the account before removing project-managed groups.
2. Read back account status and membership. Keep the account for inspection until the capstone cleanup.
3. Attempt fresh domain authentication with DC connectivity and capture the relevant Security log event if auditing is enabled.

## Verification

Record observed results and deviations in the test record. Capture the planned evidence after running each scenario.
