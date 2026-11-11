<h1 align="center">IAM PowerShell Automation Project</h1>

<p align="center">
  <img alt="8 of 8 labs documented" src="https://img.shields.io/badge/LABS-8%20OF%208%20DOCUMENTED-6f42c1?style=for-the-badge">
  <img alt="Project completed" src="https://img.shields.io/badge/STATUS-COMPLETED-2ea44f?style=for-the-badge">
  <img alt="79 screenshots" src="https://img.shields.io/badge/EVIDENCE-79%20SCREENSHOTS-0078D4?style=for-the-badge">
</p>

<p align="center">
  <img alt="Active Directory Domain Services" src="https://img.shields.io/badge/Microsoft-AD%20DS-0078D4?style=flat-square">
  <img alt="Microsoft Entra ID P2" src="https://img.shields.io/badge/Microsoft-Entra%20ID%20P2-0078D4?style=flat-square">
  <img alt="Microsoft Graph" src="https://img.shields.io/badge/Microsoft-Graph-5C2D91?style=flat-square">
  <img alt="PowerShell automation" src="https://img.shields.io/badge/PowerShell-Automation-3973B9?style=flat-square">
  <img alt="VMware lab" src="https://img.shields.io/badge/VMware-Lab-607078?style=flat-square">
  <img alt="44 Pester tests passed" src="https://img.shields.io/badge/Pester-44%20PASSED-2ea44f?style=flat-square">
</p>

An eight-day lab for learning PowerShell through identity and access management in Active Directory Domain Services on VMware and Microsoft Entra ID. The Day 01 tenant overview displays Microsoft Entra ID P2.

**Status** · All eight labs documented with seventy-nine screenshots, working AD lifecycle automation and successful CI: 44 Pester tests plus a separate 50-check offline runner.

## Project overview

The first labs build skills with PowerShell pipelines, domain accounts, security groups and Microsoft Graph. The capstone combines the AD exercises into a Joiner–Mover–Leaver workflow driven by synthetic HR events. The recorded Day 07 workflow previews changes, applies them in the isolated JML OU and verifies account/group state independently. Day 08 verified fresh SMB access, disabled-account sign-in rejection, repeated events, live partial-failure recovery and an outside-OU rejection with unchanged target state.

Days 04 and 05 use separate cloud-only test identities. Day 06 uses the existing Microsoft Entra Cloud Sync agent for a dedicated AD test user, diagnoses a scope issue, compares its source anchor and verifies a department change through Graph. The recorded synchronization requests were run on demand.

```mermaid
flowchart LR
    B["PowerShell basics"] --> AD["AD DS user and group exercises"]
    B --> E["Microsoft Entra ID and Microsoft Graph exercises"]
    AD --> JML["AD Joiner–Mover–Leaver"]
    HR["Synthetic HR events and access matrix"] --> JML
    JML --> V["Plan, apply and verify"]
    V --> S["Windows SMB and domain logon tests"]
    E --> R["Cloud membership report and manual review"]
    AD --> CS["Day 06: dedicated Cloud Sync test identity"]
    CS --> GV["Graph anchor and attribute verification"]
```

## Quick Lab Index

| Day | Milestone | Documentation | Tests | Evidence | Status |
| --- | --- | --- | --- | --- | --- |
| 01 | Lab setup and PowerShell basics | [Record](docs/day-01.md) | [Tests](tests/day-01.md) | [Evidence](evidence/day-01/README.md) | Documented |
| 02 | Active Directory user management | [Record](docs/day-02.md) | [Tests](tests/day-02.md) | [Evidence](evidence/day-02/README.md) | Documented |
| 03 | Active Directory groups and effective access | [Record](docs/day-03.md) | [Tests](tests/day-03.md) | [Evidence](evidence/day-03/README.md) | Documented |
| 04 | Entra ID user management with Microsoft Graph | [Record](docs/day-04.md) | [Tests](tests/day-04.md) | [Evidence](evidence/day-04/README.md) | Documented |
| 05 | Entra security groups and manual access review | [Record](docs/day-05.md) | [Tests](tests/day-05.md) | [Evidence](evidence/day-05/README.md) | Documented |
| 06 | Scoped Cloud Sync, source anchor and attribute propagation | [Record](docs/day-06.md) | [Tests](tests/day-06.md) | [Evidence](evidence/day-06/README.md) | Documented |
| 07 | Build the Joiner–Mover–Leaver automation | [Record](docs/day-07.md) | [Tests](tests/day-07.md) | [Evidence](evidence/day-07/README.md) | Documented |
| 08 | Capstone, Pester and portfolio review | [Record](docs/day-08.md) | [Tests](tests/day-08.md) | [Evidence](evidence/day-08/README.md) | Documented |

## Repository guide

- [Architecture and lab prerequisites](docs/architecture.md)
- [Permissions and lab boundaries](docs/permissions.md)
- [Recovery runbook](docs/recovery-runbook.md)
- [PowerShell examples and lifecycle usage](scripts/README.md)
- [AD lifecycle entry point](scripts/Invoke-IamLifecycle.ps1) and [module](src/IamAutomation/IamAutomation.psm1)
- [Pester lifecycle tests](tests/unit/Lifecycle.Tests.ps1) and [test instructions](tests/unit/README.md)
- [Separate offline lifecycle checks](tests/offline/Lifecycle.Checks.ps1)
- [Day 08 capstone events](samples/hr-events.day08.example.csv) and [scope-test event](samples/hr-events.out-of-scope.example.csv)
- [Recorded CI result](evidence/day-08/ci-summary.md)
- [Example access policy](config/access-matrix.example.json)
- [Synthetic HR events](samples/hr-events.example.csv)
- [Day 05 membership review report](samples/membership-review.csv) and [final-state report](samples/membership-after.csv)
- [Evidence guide](evidence/README.md)

## Featured evidence

The evidence from Days 01–08 connects directory fundamentals to a tested AD lifecycle: real access changes, controlled recovery, scope rejection, new-sign-in denial and automated regression checks.

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
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-03/README.md"><img src="evidence/day-03/04-finance-access-denied.png" alt="Finance file read denied for iam.gui01 after the group transfer" width="100%"></a><br>
  <strong>Finance access revoked</strong><br>
  <sub>The same proof-file path returns Access is denied</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-03/README.md"><img src="evidence/day-03/05-it-access-allowed.png" alt="IT proof file successfully read by iam.gui01 after transfer" width="100%"></a><br>
  <strong>IT access verified</strong><br>
  <sub>The transferred test identity reads its new department file</sub>
</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-04/README.md"><img src="evidence/day-04/03-graph-attribute-before-after.png" alt="Entra user attributes read before and after Update-MgUser" width="100%"></a><br>
  <strong>Graph attribute update</strong><br>
  <sub>Department and JobTitle verified through independent reads</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-04/README.md"><img src="evidence/day-04/04-graph-created-user.png" alt="Enabled Graph-created user retrieved with the intended attributes" width="100%"></a><br>
  <strong>Graph user creation</strong><br>
  <sub>New-MgUser followed by account read-back</sub>
</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-05/README.md"><img src="evidence/day-05/02-membership-report.png" alt="Membership report showing Finance removal and IT addition for an IT-department user" width="100%"></a><br>
  <strong>Membership review decision</strong><br>
  <sub>Expected access, observed memberships and the reason for correction</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-05/README.md"><img src="evidence/day-05/03-cloud-membership-after.png" alt="Final membership read showing Finance false and IT true" width="100%"></a><br>
  <strong>Correction verified</strong><br>
  <sub>Fresh reads confirm the intended direct memberships</sub>
</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-06/README.md"><img src="evidence/day-06/14-sync-anchor-verification.png" alt="Source anchor comparison showing matching SAM name, DN and Base64 anchor" width="100%"></a><br>
  <strong>Hybrid identity correlation</strong><br>
  <sub>AD source anchor compared with Graph onPremisesImmutableId</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-06/README.md"><img src="evidence/day-06/17-graph-department-after-sync.png" alt="Fresh Graph read confirming Department IT after the AD department update" width="100%"></a><br>
  <strong>Department propagation verified</strong><br>
  <sub>Finance → IT confirmed after an on-demand Cloud Sync update</sub>
</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-07/README.md"><img src="evidence/day-07/05-lifecycle-whatif.png" alt="Two planned operations, zero applied and unchanged AD state" width="100%"></a><br>
  <strong>Lifecycle WhatIf</strong><br>
  <sub>Two planned operations, zero applied and unchanged AD state</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-07/README.md"><img src="evidence/day-07/06-lifecycle-joiner-applied.png" alt="Account creation and Finance grant verified after Apply" width="100%"></a><br>
  <strong>Joiner completed</strong><br>
  <sub>Account creation and Finance grant verified after Apply</sub>
</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-07/README.md"><img src="evidence/day-07/11-lifecycle-mover-verification.png" alt="Department IT, Finance=False and IT=True" width="100%"></a><br>
  <strong>Mover independently verified</strong><br>
  <sub>Department IT, Finance=False and IT=True</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-07/README.md"><img src="evidence/day-07/15-lifecycle-leaver-verification.png" alt="Account disabled and both managed memberships absent" width="100%"></a><br>
  <strong>Leaver independently verified</strong><br>
  <sub>Account disabled and both managed memberships absent</sub>
</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-08/README.md"><img src="evidence/day-08/13-capstone-mover-recovery-applied.png" alt="Fresh plan and Apply complete only the missing IT grant" width="100%"></a><br>
  <strong>Partial Mover recovered</strong><br>
  <sub>Fresh plan and Apply complete only the missing IT grant</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-08/README.md"><img src="evidence/day-08/14-capstone-mover-finance-denied.png" alt="Fresh client session returns Finance PermissionDenied" width="100%"></a><br>
  <strong>Old access denied</strong><br>
  <sub>Fresh client session returns Finance PermissionDenied</sub>
</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-08/README.md"><img src="evidence/day-08/15-capstone-mover-it-access.png" alt="The same user reads the IT proof file" width="100%"></a><br>
  <strong>New access confirmed</strong><br>
  <sub>The same user reads the IT proof file</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-08/README.md"><img src="evidence/day-08/19-capstone-leaver-domain-logon-denied.png" alt="Windows refuses the new sign-in after Leaver" width="100%"></a><br>
  <strong>Disabled-account sign-in rejected</strong><br>
  <sub>Windows refuses the new sign-in after Leaver</sub>
</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-08/README.md"><img src="evidence/day-08/24-capstone-out-of-scope-state-preserved.png" alt="Expected rejection with unchanged target state and zero write steps" width="100%"></a><br>
  <strong>OU boundary enforced</strong><br>
  <sub>Expected rejection with unchanged target state and zero write steps</sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-08/README.md"><img src="evidence/day-08/26-capstone-pester-ci-passed.png" alt="Successful GitHub Actions job with detailed lifecycle results" width="100%"></a><br>
  <strong>44 Pester tests passed</strong><br>
  <sub>Successful GitHub Actions job with detailed lifecycle results</sub>
</td>
</tr>
</table>

## Related labs

- [Microsoft Entra Identity & Access Project](https://github.com/krzysztof-szot/entra-identity-access-project)
- [Hybrid Enterprise Security Project](https://github.com/krzysztof-szot/hybrid-enterprise-security-project)
