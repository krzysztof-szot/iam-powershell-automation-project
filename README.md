<h1 align="center">IAM PowerShell Automation Project</h1>

<p align="center"><strong>Active Directory · Microsoft Graph · Identity Lifecycle</strong></p>

<p align="center">
  <img alt="8 documented labs" src="https://img.shields.io/badge/LABS-8%20DOCUMENTED-6f42c1?style=for-the-badge">
  <img alt="Educational scope completed" src="https://img.shields.io/badge/STATUS-COMPLETED-238636?style=for-the-badge">
</p>

<p align="center">
  <img alt="Active Directory Domain Services" src="https://img.shields.io/badge/Microsoft-AD%20DS-0078D4?style=flat-square">
  <img alt="Microsoft Entra ID" src="https://img.shields.io/badge/Microsoft-Entra%20ID-0078D4?style=flat-square">
  <img alt="Microsoft Graph" src="https://img.shields.io/badge/Microsoft-Graph-5C2D91?style=flat-square">
  <img alt="PowerShell automation" src="https://img.shields.io/badge/PowerShell-Automation-3973B9?style=flat-square">
  <img alt="VMware lab" src="https://img.shields.io/badge/VMware-Lab-607078?style=flat-square">
  <img alt="44 Pester tests passed" src="https://img.shields.io/badge/Pester-44%20PASSED-805AD5?style=flat-square">
</p>

<p align="center">
  <a href="#project-overview">Overview</a> ·
  <a href="#implemented-architecture">Architecture</a> ·
  <a href="#featured-implementation-evidence">Featured evidence</a> ·
  <a href="#implementation-progress">Lab roadmap</a> ·
  <a href="#supporting-documentation">Documentation</a> ·
  <a href="#security-design-principles">Security principles</a>
</p>

A hands-on Microsoft identity lab for the fictional organization **Baltic Finance**, built around PowerShell, Active Directory Domain Services and Microsoft Entra ID.

The project progresses from account queries and group administration to a working AD Joiner–Mover–Leaver workflow. Implementation is supported by positive and negative access tests, independent state checks, controlled recovery, screenshots and automated regression tests.

## Project Overview

**Status: completed educational scope — Days 01–08.**  
Documentation closure: **2026-11-11**. Published evidence: **79 screenshots**, daily test records, synthetic input files and two cloud membership reports. Recorded CI: **44 Pester tests passed** plus **50 checks in the separate offline assertion runner**.

The lab connects identity changes to observed behavior: the intended account attributes, the correct direct memberships, access to a department share, an expected sign-in denial or a recovery that applies only the missing operation.

Days 04–05 use separate cloud-only identities through Microsoft Graph. Day 06 correlates a dedicated hybrid test identity through Cloud Sync. The lifecycle implementation in Days 07–08 manages the AD lab scope.

## Explore the Project

| Architecture | Implementation | Validation | Evidence |
|:---:|:---:|:---:|:---:|
| [View design](#implemented-architecture) | [Browse labs](#implementation-progress) | [Open tests](tests/) | [Open screenshots](evidence/) |
| Local and cloud identity paths | Eight documented milestones | Live checks, Pester and recovery | 79 published screenshots |

## Technologies and Concepts

| Area | Implemented technologies and concepts |
| --- | --- |
| PowerShell foundation | Object pipelines, filtering, property selection, CSV import/export, modules |
| AD identity administration | Users, organizational units, attributes, security groups, account state |
| Resource authorization | SMB shares, NTFS permissions, direct memberships, fresh-session access checks |
| Cloud identity | Microsoft Entra ID, delegated Microsoft Graph PowerShell, cloud-only users and assigned security groups |
| Hybrid identity | Existing Cloud Sync provisioning agent, selected-group scope, provision on demand, source-anchor correlation |
| Lifecycle automation | Synthetic HR events, access matrix, Joiner–Mover–Leaver plans, ShouldProcess and WhatIf |
| Recovery and verification | GUID-bound operations, fresh read-back, per-step CSV audit, partial-run reconciliation |
| Automated validation | Pester 5.7.1, writer mocks, simulated AD, TestDrive and GitHub Actions |

The Day 01 tenant overview records Microsoft Entra ID P2. The local lab uses BFL-DC01 and the domain-connected BFL-WKS01 on VMware.

---

## Demonstrated Outcomes

| Identity or automation objective | Recorded outcome |
| --- | --- |
| Manage accounts with PowerShell | Scoped AD user queries, attribute updates and Graph user creation/update with read-back |
| Connect groups to effective access | Finance access allowed before transfer, denied afterward; IT access allowed in the new client session |
| Review cloud access against policy | CSV review identifies the Finance-to-IT correction; independent reads confirm the final memberships |
| Correlate a hybrid identity | SAM name, DN and source-anchor comparisons succeed; an AD department change is verified in Entra |
| Automate the AD lifecycle | Joiner, Mover and Leaver complete in the isolated JML OU with per-step audit records |
| Recover a partial run | Mover stops after old-group removal; the fresh plan and retry apply only the missing IT grant |
| Enforce safety and repeat behavior | WhatIf preserves state; same-stage repeats make zero changes; an outside-OU request is rejected before write steps |
| Keep regression checks repeatable | 44 Pester tests and a separate 50-check runner pass in CI with synthetic data and simulated AD |

[Day 08 result matrix](tests/day-08.md) · [Recorded CI result](evidence/day-08/ci-summary.md)

---

## Featured Implementation Evidence

Selected screenshots from the completed exercises. Each image links to its daily evidence index; the lab records explain the conditions and observed result.

<table>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-08/README.md"><img src="evidence/day-08/13-capstone-mover-recovery-applied.png" alt="Recovered Mover applies only one missing IT group grant" width="100%"></a><br>
  <strong>Lifecycle Automation &amp; Partial Recovery</strong><br>
  <sub><a href="docs/day-08.md">Day 08 documentation</a> · <a href="evidence/day-08/README.md">Evidence</a></sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-08/README.md"><img src="evidence/day-08/24-capstone-out-of-scope-state-preserved.png" alt="Outside-OU request rejected with unchanged state and zero write steps" width="100%"></a><br>
  <strong>OU Boundary &amp; Unchanged-State Verification</strong><br>
  <sub><a href="docs/day-08.md">Day 08 documentation</a> · <a href="evidence/day-08/README.md">Evidence</a></sub>
</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-06/README.md"><img src="evidence/day-06/14-sync-anchor-verification.png" alt="AD source anchor compared with Graph and all identity checks matching" width="100%"></a><br>
  <strong>Hybrid Identity Correlation</strong><br>
  <sub><a href="docs/day-06.md">Day 06 documentation</a> · <a href="evidence/day-06/README.md">Evidence</a></sub>
</td>
<td width="50%" align="center" valign="top">
  <a href="evidence/day-08/README.md"><img src="evidence/day-08/26-capstone-pester-ci-passed.png" alt="Successful GitHub Actions job reporting 44 Pester tests passed" width="100%"></a><br>
  <strong>Pester &amp; GitHub Actions</strong><br>
  <sub><a href="docs/day-08.md">Day 08 documentation</a> · <a href="evidence/day-08/README.md">Evidence</a></sub>
</td>
</tr>
</table>

## Implemented Architecture

The live identity paths and the offline validation environment are shown separately. The AD lifecycle targets the JML OU and its two managed department groups. The Cloud Sync exercise uses its own dedicated identity and selected-group scope.

~~~mermaid
flowchart TB
    subgraph LiveLab["Live identity lab"]
        Host["Local laptop / VMware"] --> DC["BFL-DC01<br/>AD DS / balticfinance.test"]
        Host --> WKS["BFL-WKS01<br/>Domain-connected Windows client"]
        HR["Synthetic HR CSV<br/>Access matrix + local configuration"] --> PS["PowerShell lifecycle entry point<br/>Preview / WhatIf / Apply"]
        PS -->|"Pinned DC; exact user/OU/group checks"| DC
        DC --> JML["OU=JML<br/>GG-IAM-LAB-Finance / GG-IAM-LAB-IT"]
        DC --> Shares["Finance and IT SMB shares<br/>Group-based SMB + NTFS access"]
        WKS -->|"Fresh domain sign-in"| DC
        WKS -->|"Proof-file allow / deny checks"| Shares
        PS --> Audit["Local CSV audit<br/>Independent AD read-back"]

        DC --> Sync["Existing Cloud Sync agent<br/>Dedicated IAM-Sync test identity"]
        Sync -->|"Provision on demand"| Entra["Microsoft Entra ID<br/>Baltic Finance Lab"]
        Graph["Microsoft Graph PowerShell<br/>Cloud-only user and group exercises"] <-->|"Delegated operations / read-back"| Entra
    end

    subgraph Offline["Offline validation"]
        Fixtures["Synthetic fixtures<br/>Simulated ActiveDirectory adapter"] --> Pester["41 lifecycle + 3 repository<br/>Pester tests"]
        Fixtures --> Checks["Separate 50-check<br/>assertion runner"]
        Pester --> CI["GitHub Actions"]
        Checks --> CI
    end

    classDef identity fill:#e8f1ff,stroke:#2563eb,stroke-width:2px,color:#111827;
    classDef local fill:#f8fafc,stroke:#64748b,stroke-width:1.5px,color:#111827;
    classDef automation fill:#faf5ff,stroke:#9333ea,stroke-width:1.5px,color:#111827;
    classDef validation fill:#f0fdf4,stroke:#16a34a,stroke-width:1.5px,color:#111827;

    class DC,JML,Entra identity;
    class Host,WKS,Shares,HR local;
    class PS,Graph,Sync,Audit automation;
    class Fixtures,Pester,Checks,CI validation;
~~~

<details>
<summary><strong>Architecture notes and recorded scope</strong></summary>

- Live lifecycle execution uses Windows PowerShell 5.1 on BFL-DC01. The full Pester suite runs in PowerShell 7 with Pester 5.7.1.
- The lifecycle account DN must match the synthetic SAM name directly inside OU=JML,OU=IAM-Automation. Only the configured Finance and IT lab groups are reconciled.
- Cloud-only Graph exercises and the dedicated Cloud Sync identity remain separate from the AD lifecycle account set.
- The Day 06 record establishes on-demand creation, identity correlation and attribute propagation. Recurring-cycle health and password propagation were outside those checks.
- Audit CSV, local configuration and comparison baselines stay in local-output or local configuration files. The repository publishes synthetic examples, source and captured evidence.

[Full architecture](docs/architecture.md) · [Permissions and boundaries](docs/permissions.md)

</details>

---

## Implementation Progress

### Quick Lab Index

Each milestone links its implementation notes, observed test results and screenshot index.

| Day | Milestone | Implementation | Tests | Evidence |
|:---:|---|:---:|:---:|:---:|
| 01 | Lab Foundation and PowerShell Basics | [Notes](docs/day-01.md) | [Results](tests/day-01.md) | [Screenshots](evidence/day-01/README.md) |
| 02 | Active Directory User Management | [Notes](docs/day-02.md) | [Results](tests/day-02.md) | [Screenshots](evidence/day-02/README.md) |
| 03 | Security Groups and Effective Access | [Notes](docs/day-03.md) | [Results](tests/day-03.md) | [Screenshots](evidence/day-03/README.md) |
| 04 | Entra Users and Microsoft Graph | [Notes](docs/day-04.md) | [Results](tests/day-04.md) | [Screenshots](evidence/day-04/README.md) |
| 05 | Cloud Groups and Access Review | [Notes](docs/day-05.md) | [Results](tests/day-05.md) | [Screenshots](evidence/day-05/README.md) |
| 06 | Scoped Cloud Sync and Identity Correlation | [Notes](docs/day-06.md) | [Results](tests/day-06.md) | [Screenshots](evidence/day-06/README.md) |
| 07 | Build the Joiner–Mover–Leaver Automation | [Notes](docs/day-07.md) | [Results](tests/day-07.md) | [Screenshots](evidence/day-07/README.md) |
| 08 | Capstone, Recovery and Automated Testing | [Notes](docs/day-08.md) | [Results](tests/day-08.md) | [Screenshots](evidence/day-08/README.md) |

### Detailed Lab Notes

Select a day to expand its recorded implementation checklist and supporting links.

<details>
<summary><strong>Day 01 — Lab Foundation and PowerShell Basics</strong> · implementation, tests &amp; evidence</summary>

Verify the existing VMware domain and Entra tenant, then work with PowerShell objects and a small synthetic CSV.

- [x] BFL-WKS01 domain membership and BFL-DC01 TCP 389 connectivity
- [x] Recorded tenant overview displaying Microsoft Entra ID P2
- [x] AD account filtering with Where-Object and property selection
- [x] Synthetic CSV content, import and record-count validation

[Documentation](docs/day-01.md) · [Tests](tests/day-01.md) · [Evidence](evidence/day-01/README.md)

</details>

---

<details>
<summary><strong>Day 02 — Active Directory User Management</strong> · implementation, tests &amp; evidence</summary>

Create and inspect disposable users in the dedicated IAM-Automation OU, then verify an attribute update through a fresh read.

- [x] Separate GUI and PowerShell test identities
- [x] Scoped Get-ADUser query using SearchBase and SearchScope
- [x] Department and Title update for iam.ps01
- [x] Before/after attribute evidence

[Documentation](docs/day-02.md) · [Tests](tests/day-02.md) · [Evidence](evidence/day-02/README.md)

</details>

---

<details>
<summary><strong>Day 03 — Security Groups and Effective Access</strong> · implementation, tests &amp; evidence</summary>

Connect AD group membership to real Finance and IT share access from the domain client.

- [x] Department security groups with SMB Read and NTFS ReadAndExecute
- [x] Finance membership removed and IT membership granted for iam.gui01
- [x] Finance proof file readable before the transfer and denied afterward
- [x] IT proof file readable after the transfer
- [x] Separate iam.ps01 disable/enable state check

[Documentation](docs/day-03.md) · [Tests](tests/day-03.md) · [Evidence](evidence/day-03/README.md)

</details>

---

<details>
<summary><strong>Day 04 — Entra Users and Microsoft Graph</strong> · implementation, tests &amp; evidence</summary>

Use a delegated Microsoft Graph PowerShell session to read, update and create separate cloud-only lab identities.

- [x] Portal-created iam.cloud01 and a captured delegated Process context
- [x] Department and JobTitle changed with Update-MgUser
- [x] Independent Graph read confirming the attribute update
- [x] Graph-created iam.graph01 retrieved as enabled with its intended attributes

[Documentation](docs/day-04.md) · [Tests](tests/day-04.md) · [Evidence](evidence/day-04/README.md)

</details>

---

<details>
<summary><strong>Day 05 — Cloud Groups and Access Review</strong> · implementation, tests &amp; evidence</summary>

Review a deliberately mismatched department/group assignment, record the decision and verify the corrected direct memberships.

- [x] Assigned Entra security groups for Finance and IT
- [x] CSV report containing current membership, expected membership, decision and reason
- [x] Remove Finance and add IT for the IT-department test identity
- [x] Independent final membership read: Finance=False and IT=True
- [x] Published review and final-state report samples

[Documentation](docs/day-05.md) · [Tests](tests/day-05.md) · [Evidence](evidence/day-05/README.md)

</details>

---

<details>
<summary><strong>Day 06 — Scoped Cloud Sync and Identity Correlation</strong> · implementation, tests &amp; evidence</summary>

Identify the existing Cloud Sync engine, correct a provisioning-scope issue and correlate one dedicated AD identity with its Entra object.

- [x] Running provisioning-agent service and active registered agent
- [x] Selected-group scope corrected with GG-IAM-LAB-Sync
- [x] Provision-on-demand account creation after the scope fix
- [x] SAM name, DN and objectGUID source-anchor comparisons succeed
- [x] AD Department Finance to IT propagated and read back through Graph

[Documentation](docs/day-06.md) · [Tests](tests/day-06.md) · [Evidence](evidence/day-06/README.md)

</details>

---

<details>
<summary><strong>Day 07 — Build the Joiner–Mover–Leaver Automation</strong> · implementation, tests &amp; evidence</summary>

Combine the earlier AD exercises into a versioned, CSV-driven workflow in the isolated JML OU.

- [x] Validated HR events, access matrix and exact lab boundaries
- [x] Default Preview and explicit Apply with ShouldProcess / WhatIf
- [x] Joiner creates the account and grants the department group
- [x] Mover removes old access before granting new access
- [x] Leaver disables the account before removing managed memberships
- [x] Independent AD reads and per-step CSV audit views for each stage

[Documentation](docs/day-07.md) · [Tests](tests/day-07.md) · [Evidence](evidence/day-07/README.md)

</details>

---

<details>
<summary><strong>Day 08 — Capstone, Recovery and Automated Testing</strong> · implementation, tests &amp; evidence</summary>

Validate a fresh lifecycle identity with real Windows access, controlled failure/recovery and a separate outside-OU safety test.

- [x] Independent WhatIf before/after comparison
- [x] Finance access after Joiner; Finance denial and IT access after Mover
- [x] Same-stage Joiner, Mover and Leaver repeats produce NoChange
- [x] Injected Mover stop followed by a one-operation recovery
- [x] Disabled-account new-sign-in rejection and independent final-state read
- [x] Outside-JML request rejected with unchanged state and zero write-step starts
- [x] Manual scope-fixture cleanup; 44 Pester tests and 50 separate offline checks pass

[Documentation](docs/day-08.md) · [Tests](tests/day-08.md) · [Evidence](evidence/day-08/README.md)

</details>

---

## Supporting Documentation

| Resource | Purpose |
| --- | --- |
| [Architecture and lab prerequisites](docs/architecture.md) | Recorded environments, identity paths and lifecycle validation |
| [Permissions and boundaries](docs/permissions.md) | Operator context, exact lab scope and result limits |
| [Recovery runbook](docs/recovery-runbook.md) | Inspect a partial run, re-plan and apply the missing work |
| [PowerShell entry points](scripts/README.md) | Examples, lifecycle parameters and the manual scope-fixture helper |
| [IAM module](src/IamAutomation/README.md) | Input validation, snapshots, planning, execution and audit functions |
| [Lab configuration example](config/lab.example.json) and [access matrix](config/access-matrix.example.json) | Local identifiers and department-to-entitlement policy |
| [Day 07 HR feed](samples/hr-events.example.csv), [Day 08 feed](samples/hr-events.day08.example.csv) and [scope-test event](samples/hr-events.out-of-scope.example.csv) | Separate synthetic inputs for the recorded exercises |
| [Membership review](samples/membership-review.csv) and [final-state report](samples/membership-after.csv) | Day 05 cloud access review and correction |
| [Pester instructions](tests/unit/README.md) and [separate assertion runner](tests/offline/Lifecycle.Checks.ps1) | Offline regression checks using simulated directory operations |
| [CI result record](evidence/day-08/ci-summary.md) and [evidence guide](evidence/README.md) | Recorded automated validation and screenshot conventions |

---

## Security Design Principles

**Explicit scope before mutation**

The workflow validates the domain, exact lifecycle account location and the two managed groups before writing. The live outside-OU exercise verifies rejection and unchanged target state.

**Preview and deliberate execution**

Preview is the default. Apply expresses write intent, and ShouldProcess guards the operations so WhatIf preserves managed directory state while retaining a local audit.

**Group-based authorization**

Department access is managed through security groups. Fresh Windows sessions test the actual share permissions after membership changes.

**Verification around each step**

Existing identities and groups are bound by objectGUID, relevant state is re-read and each applied operation is checked through fresh read-back. Separate native queries and client access tests support the recorded outcomes.

**Recovery from current state**

A partial run is inspected before retry. The new plan contains the remaining work; same-stage repeats are checked for zero additional changes.

**Separate privileged execution from access testing**

The controller-side lab operator performs setup and changes. Client proof-file checks identify the ordinary test account explicitly through whoami.

---

## Final Recorded State

| Identity or component | Recorded state |
| --- | --- |
| Day 07 iam.lab001 / LAB-001 | Disabled, Department=IT, no membership in either managed department group |
| Day 08 iam.lab002 / LAB-002 | Disabled, Department=IT, no membership in either managed group; new sign-in rejected |
| Scope fixture iam.lab003 / LAB-003 | Disabled, Department=Finance; temporary Finance membership manually removed after the boundary test |
| Lifecycle source | Version 0.2.0; scoped AD entry point, shared module and synthetic event feeds |
| Automated validation | 44 Pester tests and 50 separate assertion checks passed in CI |
| Earlier directory exercises | Cloud-only Graph objects and the dedicated Cloud Sync identity documented in their daily records |

[Day 07 final-state evidence](evidence/day-07/15-lifecycle-leaver-verification.png) · [Day 08 final-state evidence](evidence/day-08/20-capstone-leaver-verification.png) · [Scope-fixture cleanup](evidence/day-08/25-capstone-scope-fixture-cleanup.png)

## Evidence Boundaries

Live screenshots, directory reads and local audit views are distinguished from offline tests. The CI suites use simulated AD and synthetic fixtures.

The capstone validates new-sign-in rejection for a disabled account. Existing-session termination, multi-DC behavior and delegated least-privilege permissions were outside the live test scope. Each AD operation commits independently. Recovery uses step logs and a fresh state-based plan; automatic rollback and a durable event-processing ledger are outside the implementation.

This is a documented educational lab and portfolio. Raw VM audit and baseline files remain local. Published input examples are synthetic; screenshots document the recorded execution.

---

## Repository Structure

| Path | Contents |
| --- | --- |
| [README.md](README.md) | Project overview, architecture, outcomes, lab index and featured evidence |
| [docs/](docs/) | Eight daily records, architecture, permissions and recovery procedure |
| [tests/](tests/) | Daily result matrices, Pester tests and the separate assertion runner |
| [evidence/](evidence/) | 79 screenshots, daily indexes and the recorded CI result |
| [scripts/](scripts/) | Introductory examples, lifecycle entry point and scope-test setup helper |
| [src/IamAutomation/](src/IamAutomation/) | Shared AD lifecycle module and implementation notes |
| [config/](config/) | Lab configuration and access-matrix examples |
| [samples/](samples/) | Synthetic HR feeds and cloud membership reports |

## Related Projects

- [Microsoft Entra Identity &amp; Access Project](https://github.com/krzysztof-szot/entra-identity-access-project)
- [Microsoft Hybrid Enterprise Security Project](https://github.com/krzysztof-szot/hybrid-enterprise-security-project)
