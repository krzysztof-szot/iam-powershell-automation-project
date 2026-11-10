# Day 01 — Lab setup and PowerShell basics

**Status** · Planned

[Tests](../tests/day-01.md) · [Screenshot checklist](../evidence/day-01/README.md)

## Objective

Confirm access to the Windows domain and the Entra ID Free tenant. Practice finding commands, filtering PowerShell objects and exporting a synthetic CSV.

## Implementation plan

1. Start the VMware domain controller and Windows client. On the client, verify domain membership and connectivity to the controller. Record the lab components in the [architecture notes](architecture.md).
2. Sign in to the Microsoft Entra admin center and verify the intended test tenant and license. Record the result without exposing tenant identifiers.
3. On the lab server, use `Get-Command` and `Get-Help` to inspect `Get-ADUser` and `Export-Csv`. Read one known test account, then use a pipeline with `Where-Object` to filter and `Select-Object` to display only the properties needed for the exercise.
4. Filter and select columns from the [synthetic HR events](../samples/hr-events.example.csv), export with `Export-Csv` to `local-output/day-01/` and read the result back with `Import-Csv`.

## Verification

Record the observed outcome in the test record and capture the planned screenshots after each scenario.
