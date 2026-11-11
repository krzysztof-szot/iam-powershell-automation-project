<h1 align="center">IAM PowerShell Automation Project</h1>

<p align="center">
  <img alt="2 of 8 labs documented" src="https://img.shields.io/badge/LABS-2%20OF%208%20DOCUMENTED-6f42c1?style=for-the-badge">
  <img alt="Project in progress" src="https://img.shields.io/badge/STATUS-IN%20PROGRESS-b36b00?style=for-the-badge">
</p>

<p align="center">
  <img alt="Active Directory Domain Services" src="https://img.shields.io/badge/Microsoft-AD%20DS-0078D4?style=flat-square">
  <img alt="Microsoft Entra ID P2" src="https://img.shields.io/badge/Microsoft-Entra%20ID%20P2-0078D4?style=flat-square">
  <img alt="Microsoft Graph" src="https://img.shields.io/badge/Microsoft-Graph-5C2D91?style=flat-square">
  <img alt="PowerShell automation" src="https://img.shields.io/badge/PowerShell-Automation-3973B9?style=flat-square">
  <img alt="VMware lab" src="https://img.shields.io/badge/VMware-Lab-607078?style=flat-square">
  <img alt="Pester tests" src="https://img.shields.io/badge/Pester-Tests-805AD5?style=flat-square">
</p>

An eight-day lab for learning PowerShell through identity and access management in Active Directory Domain Services on VMware and Microsoft Entra ID. The Day 01 tenant overview displays Microsoft Entra ID P2.

**Status** · Days 01–02 documented with seven screenshots and an AD attribute script. Days 03–08 are planned.

## Project overview

The first labs build skills with PowerShell pipelines, domain accounts, security groups and Microsoft Graph. The capstone combines the AD exercises into a Joiner–Mover–Leaver workflow driven by synthetic HR events. It previews proposed changes, applies them within the lab scope and verifies the outcome through SMB access and a fresh domain logon attempt.

The Entra labs use separate cloud-only test identities. Day 06 offers either an isolated Entra Connect Sync exercise or an access drift report for both directories.

```mermaid
flowchart LR
    B["PowerShell basics"] --> AD["AD DS user and group exercises"]
    B --> E["Microsoft Entra ID and Microsoft Graph exercises"]
    AD --> JML["AD Joiner–Mover–Leaver"]
    HR["Synthetic HR events and access matrix"] --> JML
    JML --> V["Plan, apply and verify"]
    V --> S["Windows SMB and domain logon tests"]
    E --> R["Cloud membership report and manual review"]
```

## Quick Lab Index

| Day | Milestone | Documentation | Tests | Evidence | Status |
| --- | --- | --- | --- | --- | --- |
| 01 | Lab setup and PowerShell basics | [Record](docs/day-01.md) | [Tests](tests/day-01.md) | [Evidence](evidence/day-01/README.md) | Documented |
| 02 | Active Directory user management | [Record](docs/day-02.md) | [Tests](tests/day-02.md) | [Evidence](evidence/day-02/README.md) | Documented |
| 03 | Active Directory groups and effective access | [Plan](docs/day-03.md) | [Tests](tests/day-03.md) | [Evidence](evidence/day-03/README.md) | Planned |
| 04 | Entra ID user management with Microsoft Graph | [Plan](docs/day-04.md) | [Tests](tests/day-04.md) | [Evidence](evidence/day-04/README.md) | Planned |
| 05 | Entra security groups and manual access review | [Plan](docs/day-05.md) | [Tests](tests/day-05.md) | [Evidence](evidence/day-05/README.md) | Planned |
| 06 | Optional AD-to-Entra synchronization or access drift report | [Plan](docs/day-06.md) | [Tests](tests/day-06.md) | [Evidence](evidence/day-06/README.md) | Planned |
| 07 | Build the Joiner–Mover–Leaver automation | [Plan](docs/day-07.md) | [Tests](tests/day-07.md) | [Evidence](evidence/day-07/README.md) | Planned |
| 08 | Capstone, Pester and portfolio review | [Plan](docs/day-08.md) | [Tests](tests/day-08.md) | [Evidence](evidence/day-08/README.md) | Planned |

## Repository guide

- [Architecture and lab prerequisites](docs/architecture.md)
- [Permissions and lab boundaries](docs/permissions.md)
- [Recovery runbook](docs/recovery-runbook.md)
- [PowerShell examples and planned entry points](scripts/README.md)
- [Example access policy](config/access-matrix.example.json)
- [Synthetic HR events](samples/hr-events.example.csv)
- [Evidence guide](evidence/README.md)

## Featured evidence

The evidence from Days 01–02 connects the lab environment to recorded account queries, attribute changes and CSV results.

<table>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-01/README.md"><img src="evidence/day-01/01-domain-connectivity.png" alt="Domain membership and controller connectivity" width="100%"></a><br>
  <strong>Domain connectivity</strong><br>
  <sub>BFL-WKS01 membership and TCP 389 reachability</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-01/README.md"><img src="evidence/day-01/02-entra-tenant-license.png" alt="Tenant overview showing Microsoft Entra ID P2" width="100%"></a><br>
  <strong>Microsoft Entra ID P2</strong><br>
  <sub>Recorded tenant overview with redacted identifiers</sub>
</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-01/README.md"><img src="evidence/day-01/03-powershell-pipeline.png" alt="AD user query with Where-Object and Select-Object" width="100%"></a><br>
  <strong>PowerShell pipeline</strong><br>
  <sub>Filtered AD account and selected properties</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-01/README.md"><img src="evidence/day-01/04-synthetic-csv.png" alt="Synthetic CSV content and successful one-row reimport" width="100%"></a><br>
  <strong>Synthetic CSV validation</strong><br>
  <sub>File content and one-record reimport</sub>
</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-02/README.md"><img src="evidence/day-02/02-scoped-user-query.png" alt="Two enabled test users returned from the dedicated AD OU" width="100%"></a><br>
  <strong>Scoped AD user query</strong><br>
  <sub>Two test accounts read from IAM-Automation</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-02/README.md"><img src="evidence/day-02/03-user-attributes-before-after.png" alt="Department and Title verified before and after Set-ADUser" width="100%"></a><br>
  <strong>Attribute update and verification</strong><br>
  <sub>Department and Title read before and after the change</sub>
</td>
</tr>
</table>

## Related labs

- [Microsoft Entra Identity & Access Project](https://github.com/krzysztof-szot/entra-identity-access-project)
- [Hybrid Enterprise Security Project](https://github.com/krzysztof-szot/hybrid-enterprise-security-project)
