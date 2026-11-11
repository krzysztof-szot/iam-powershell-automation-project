# Day 04 — Entra ID user management with Microsoft Graph

**Status** · Planned

[Tests](../tests/day-04.md) · [Screenshot checklist](../evidence/day-04/README.md)

## Objective

Practice user management in the lab Entra tenant through the portal and delegated Microsoft Graph PowerShell. The Day 01 overview displays Microsoft Entra ID P2.

## Implementation plan

1. Create a dedicated cloud-only test user in the Entra admin center.
2. Connect with `Connect-MgGraph`. Use `Get-MgContext` to check the intended tenant, operator and delegated scopes. Verify the scope and role requirements in the [permissions guide](permissions.md) before making changes.
3. Read the test account with `Get-MgUser`. Update a selected attribute with `Update-MgUser`, then independently read the same property again.
4. Create a second cloud-only test account through `New-MgUser` and verify its intended properties. Record the scopes and operator role used without recording secrets or private identifiers.

## Verification

Record the observed outcome in the test record and capture the planned screenshots after each scenario.
