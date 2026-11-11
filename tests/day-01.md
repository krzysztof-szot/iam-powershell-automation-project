# Day 01 — Lab setup and PowerShell basics tests

**Status** · Four recorded result checks passed  
Record updated 2026-11-11.

[Lab record](../docs/day-01.md) · [Screenshots](../evidence/day-01/README.md)

The owner performed the actions. PASS applies to the observations described in the table.

| ID | Procedure | Expected | Actual | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| D01-01 | Read client domain membership and test TCP connectivity to the controller on port 389 | The client belongs to the lab domain and reaches the selected controller endpoint. | BFL-WKS01, balticfinance.test, PartOfDomain=True, TCP 389 to BFL-DC01.balticfinance.test succeeds. | PASS | [01](../evidence/day-01/01-domain-connectivity.png) |
| D01-02 | Open the lab tenant Overview and read its displayed license | The intended tenant and its current license are identifiable. | Baltic Finance Lab, License=Microsoft Entra ID P2. | PASS | [02](../evidence/day-01/02-entra-tenant-license.png) |
| D01-03 | Filter AD users with Where-Object and select account properties | The pipeline returns the intended lab identity and selected properties. | Anna Finance, anna.finance, Enabled=True, Department=Finance, Title empty. | PASS | [03](../evidence/day-01/03-powershell-pipeline.png) |
| D01-04 | Inspect the synthetic CSV and import it into PowerShell | The expected columns and single Joiner record are readable after import. | EventId / EmployeeId / Department, JML-001 / LAB-001 / Finance, Imported rows: 1. | PASS | [04](../evidence/day-01/04-synthetic-csv.png) |

## Coverage notes

- D01-01 records configured domain membership and a successful TCP connection to the selected LDAP port.
- D01-02 records the tenant-level license value displayed in the portal.
- D01-03 covers the captured AD pipeline. The guided command-discovery and help steps are described in the lab record.
- D01-04 covers the captured file contents and CSV reimport. The lab record includes the guided export command.
