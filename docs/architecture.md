# Architecture

## Environments

| Path | Directory and tools | Validation |
| --- | --- | --- |
| Domain | Existing VMware Windows Server domain controller, ActiveDirectory PowerShell module, domain-connected Windows client | Account and membership read-back, live SMB access, fresh domain authentication and Windows Security log |
| Cloud | Microsoft Entra ID P2 displayed in the Day 01 tenant overview, Microsoft Graph PowerShell with delegated authentication, separate cloud-only lab objects | Graph read-back and Microsoft Entra admin center evidence |

The lab uses an existing VMware domain controller, a Windows client with domain connectivity and a Microsoft Entra tenant. The core user and static-group exercises use capabilities available in Entra ID Free. The recorded Day 01 tenant overview displays Microsoft Entra ID P2. Both directories use the same example policy keys and resolve their own identities and group identifiers. Days 04 and 05 use separate cloud-only test objects. Day 06 offers Entra Connect Sync in a dedicated test OU or a report that compares expected and actual memberships in each directory.

## Day 01 recorded environment

| Component | Recorded observation |
| --- | --- |
| Domain client | BFL-WKS01, PartOfDomain=True |
| AD domain | balticfinance.test |
| Controller endpoint | BFL-DC01.balticfinance.test, TCP 389 reachable |
| Entra tenant | Baltic Finance Lab, portal displays Microsoft Entra ID P2 |
| AD test identity | anna.finance, Enabled=True, Department=Finance |
| CSV working directory | `C:\IAM-Automation\local-output\day-01` |

[Day 01 lab record](day-01.md) · [Screenshots](../evidence/day-01/README.md)

## Day 02 recorded AD scope

| Component | Recorded observation |
| --- | --- |
| Dedicated OU | `OU=IAM-Automation,DC=balticfinance,DC=test` |
| First test user | IAM GUI User / iam.gui01, Enabled=True |
| Second test user | IAM PowerShell User / iam.ps01, Enabled=True at the scoped query |
| Attribute update | iam.ps01 Department=IT, Title=IAM Automation Trainee |
| Saved example | scripts/day-02-user-attributes.ps1 |

[Day 02 lab record](day-02.md) · [Screenshots](../evidence/day-02/README.md)

## Day 03 recorded access model

| Component | Recorded observation |
| --- | --- |
| Finance share | IAM-LAB-Finance, department SMB Read and NTFS ReadAndExecute |
| IT share | IAM-LAB-IT, department SMB Read and NTFS ReadAndExecute |
| Lab folders | `C:\LabShares\IAM-Automation\Finance` and `C:\LabShares\IAM-Automation\IT` |
| Transfer identity | iam.gui01, Finance membership before and IT membership after |
| Effective access | Finance proof file readable before transfer, denied afterward. IT proof file readable afterward. |
| Separate account state test | iam.ps01 Enabled=True → False → True |
| Saved example | scripts/day-03-group-memberships.ps1 |

[Day 03 lab record](day-03.md) · [Screenshots](../evidence/day-03/README.md)

## Planned AD lifecycle workflow

1. Validate the input and the lab boundary.
2. Read current state and calculate changes from the access matrix.
3. Preview changes by default and require explicit apply intent. Honor PowerShell `-WhatIf` for write operations.
4. Recheck relevant state, apply scoped changes and record step outcomes.
5. Verify directory state and collect independent access evidence where applicable.

Use `config/lab.local.json` for actual identifiers and `local-output/` for logs or exports.
