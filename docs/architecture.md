# Architecture

## Environments

| Path | Directory and tools | Validation |
| --- | --- | --- |
| Domain | Existing VMware Windows Server domain controller, ActiveDirectory PowerShell module, domain-connected Windows client | Account and membership read-back, live SMB access, fresh domain authentication and Windows Security log |
| Cloud | Microsoft Entra ID Free, Microsoft Graph PowerShell with delegated authentication, separate cloud-only lab objects | Graph read-back and Microsoft Entra admin center evidence |

The lab needs an existing VMware domain controller, a Windows client with domain connectivity and an Entra ID Free tenant. Both directories use the same example policy keys and resolve their own identities and group identifiers. Days 04 and 05 use separate cloud-only test objects. Day 06 offers Entra Connect Sync in a dedicated test OU or a report that compares expected and actual memberships in each directory.

## AD lifecycle workflow

1. Validate the input and the lab boundary.
2. Read current state and calculate changes from the access matrix.
3. Preview changes by default and require explicit apply intent. Honor PowerShell `-WhatIf` for write operations.
4. Recheck relevant state, apply scoped changes and record step outcomes.
5. Verify directory state and collect independent access evidence where applicable.

Use `config/lab.local.json` for actual identifiers and `local-output/` for logs or exports.
