# Day 05 — Cloud-only lifecycle in Entra ID Free

**Status** · Planned

[Tests](../tests/day-05.md) · [Screenshot checklist](../evidence/day-05/README.md)

## Objective

Demonstrate the same policy against separate cloud-only lab accounts and static Entra security groups.

## Implementation plan

1. Use Microsoft Graph PowerShell with delegated authentication. Verify the expected tenant, operator and permitted cloud group IDs.
2. Repeat Joiner, Mover and Leaver for one dedicated cloud-only user. Independently read back the managed group memberships and account state.
3. Capture directory audit evidence from the Entra portal on the day of testing. Keep this scenario independent from AD DS and directory synchronization.

## Verification

Record observed results and deviations in the test record. Capture the planned evidence after running each scenario.
