# Architecture

## Environments

| Path | Directory and tools | Validation |
| --- | --- | --- |
| Domain | Existing VMware Windows Server domain controller, ActiveDirectory PowerShell module, domain-connected Windows client | Account and membership read-back, live SMB access, fresh domain authentication and Windows Security log |
| Cloud | Microsoft Entra ID Free, Microsoft Graph PowerShell with delegated authentication, separate cloud-only lab objects | Graph read-back and Microsoft Entra admin center evidence |

The two paths share policy keys and synthetic inputs. Each path resolves its own identity and group identifiers. The lab needs an existing VMware domain controller, a Windows client with domain connectivity and an Entra Free tenant. Cloud Sync and premium group-based application assignments are outside the planned scope.

## Workflow

1. Validate the input and the lab boundary.
2. Read current state and calculate changes from the access matrix.
3. Preview changes and require explicit apply intent.
4. Recheck relevant state, apply scoped changes and record step outcomes.
5. Verify directory state and collect independent access evidence where applicable.

Use `config/lab.local.json` for actual identifiers and `local-output/` for logs or exports.
