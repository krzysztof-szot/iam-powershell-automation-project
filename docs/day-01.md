# Day 01 — Foundation and read-only planning

**Status** · Planned

[Tests](../tests/day-01.md) · [Screenshot checklist](../evidence/day-01/README.md)

## Objective

Set up an isolated AD DS lab and define how a PowerShell preview converts a synthetic HR request into proposed changes.

## Implementation plan

1. Verify the existing VMware domain controller, a Windows client and connectivity to the domain. Use a domain test account for access checks.
2. Create a dedicated lab OU, Finance and IT security groups, and disposable SMB test shares. Restrict the shares and their NTFS permissions to the intended groups and lab administrators.
3. Record the allowed OU, groups and domain in a local configuration file. Design `Plan` to validate the event and read current state without writing.

## Verification

Record observed results and deviations in the test record. Capture the planned evidence after running each scenario.
