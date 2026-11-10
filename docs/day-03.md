# Day 03 — Active Directory groups and effective access

**Status** · Planned

[Tests](../tests/day-03.md) · [Screenshot checklist](../evidence/day-03/README.md)

## Objective

Demonstrate how a group change affects SMB access and practice enabling and disabling a separate test account.

## Implementation plan

1. Create or reuse `GG-IAM-LAB-Finance` and `GG-IAM-LAB-IT` in the lab OU. Prepare dedicated `IAM-LAB-Finance` and `IAM-LAB-IT` SMB shares. Set both share and NTFS permissions for the corresponding groups and lab administrators.
2. Use `Get-ADGroup` and `Get-ADGroupMember` to inspect the groups. Add the test user to Finance and establish a baseline from the Windows client by opening the Finance test file.
3. Use `Remove-ADGroupMember` and `Add-ADGroupMember` to transfer the test user from Finance to IT. Read both direct memberships again. Use a fresh Windows session to test the same Finance share and the IT share.
4. Use `Disable-ADAccount` and `Enable-ADAccount` on a separate disposable user. Read `Enabled` after each operation. Save a short example for comparing direct group memberships.

## Verification

Record the observed outcome in the test record and capture the planned screenshots after each scenario.
