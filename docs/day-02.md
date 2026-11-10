# Day 02 — Active Directory user management

**Status** · Planned

[Tests](../tests/day-02.md) · [Screenshot checklist](../evidence/day-02/README.md)

## Objective

Learn how to create, locate and update disposable domain users through the AD console and PowerShell.

## Implementation plan

1. Open Active Directory Users and Computers. Create or reuse the dedicated `IAM-Automation` OU and create the first test account in it.
2. Read the account with `Get-ADUser`. Practice a filter and an OU-scoped search with `-SearchBase`.
3. Use `New-ADUser` to create a second test account in the same OU. Read its current `Department` and `Title`, update them with `Set-ADUser`, and query them again.
4. Save a small PowerShell example for reading and updating a lab account. Keep passwords and local directory identifiers out of the published example.

## Verification

Record the observed outcome in the test record and capture the planned screenshots after each scenario.
