# Day 01 — Lab setup and PowerShell basics

**Status** · Completed documented scope  
Record updated 2026-11-11.

[Tests](../tests/day-01.md) · [Screenshots](../evidence/day-01/README.md)

## Objective

Verify the existing Windows domain and Entra tenant, practice a read-only AD PowerShell pipeline, and validate a CSV containing synthetic HR data.

The owner performed the lab actions. This record describes the four uploaded screenshots and the commands used in the guided exercise.

## Recorded results

### Domain membership and controller connectivity

On the Windows client, the owner ran:

```powershell
Get-CimInstance Win32_ComputerSystem |
    Format-List Name, Domain, PartOfDomain

Test-NetConnection -ComputerName BFL-DC01.balticfinance.test -Port 389 |
    Format-List ComputerName, RemotePort, TcpTestSucceeded
```

The client identifies itself as `BFL-WKS01`, belongs to `balticfinance.test` and reports `PartOfDomain=True`. The TCP test to `BFL-DC01.balticfinance.test` on port `389` returns `TcpTestSucceeded=True`. These observations establish domain membership and reachability of that TCP endpoint. [Screenshot 01](../evidence/day-01/01-domain-connectivity.png)

### Entra tenant and observed license

The tenant Overview page shows `Baltic Finance Lab` and `License = Microsoft Entra ID P2`. The tenant ID and primary domain are redacted in the published image. The environment record now reflects the license displayed during the exercise. [Screenshot 02](../evidence/day-01/02-entra-tenant-license.png)

### Read-only PowerShell pipeline

The guided practice included `Get-Command` and `Get-Help` for discovering `Get-ADUser` and `Export-Csv`. The retained evidence captures the AD pipeline:

```powershell
Get-ADUser -Filter * -Properties Department, Title |
    Where-Object { $_.SamAccountName -eq 'anna.finance' } |
    Select-Object Name, SamAccountName, Enabled, Department, Title
```

The result contains `Anna Finance` / `anna.finance`, `Enabled=True` and `Department=Finance`. `Title` is empty. This demonstrates passing AD user objects through `Where-Object` and `Select-Object`. [Screenshot 03](../evidence/day-01/03-powershell-pipeline.png)

### Synthetic CSV validation

The exercise loaded the [example HR events](../samples/hr-events.example.csv) into `$events` using `ConvertFrom-Csv`. The guided export selected the Joiner event and three columns:

```powershell
$events |
    Where-Object { $_.EventType -eq 'Joiner' } |
    Select-Object EventId, EmployeeId, Department |
    Export-Csv -Path '.\joiners.csv' -NoTypeInformation -Encoding UTF8
```

The captured validation ran from `C:\IAM-Automation\local-output\day-01`:

```powershell
Get-Content '.\joiners.csv'

Import-Csv '.\joiners.csv' | Format-Table -AutoSize

"Imported rows: $(@(Import-Csv '.\joiners.csv').Count)"
```

The file and imported table contain the headers `EventId`, `EmployeeId`, `Department` and the single record `JML-001 / LAB-001 / Finance`. The final line reports `Imported rows: 1`. Screenshot 04 records file contents and reimport validation. The export command above documents the preceding guided procedure. [Screenshot 04](../evidence/day-01/04-synthetic-csv.png)

## Evidence coverage

The four result tests below correspond to the four uploaded screenshots. Cmdlet discovery and help were part of the guided practice, with the retained PowerShell screenshot focused on the AD pipeline.

[Detailed test results](../tests/day-01.md) · [Evidence page](../evidence/day-01/README.md)
