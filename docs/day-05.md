# Day 05 — Entra security groups and manual access review

**Status** · Planned

[Tests](../tests/day-05.md) · [Screenshot checklist](../evidence/day-05/README.md)

## Objective

Manage direct memberships in static Entra security groups and use a report to support a manual access decision.

## Implementation plan

1. Create dedicated static Finance and IT security groups in the Entra admin center.
2. Use Graph PowerShell to retrieve the groups and direct members. Add a cloud-only test user to the Finance group and export a membership snapshot locally.
3. Review the report against the test user's new department. Record the reason for removing obsolete Finance access and granting IT access.
4. Apply the membership changes through Graph and read both groups again. Save an example CSV with synthetic identities for the repository.

## Verification

Record the observed outcome in the test record and capture the planned screenshots after each scenario.
