# Permissions and boundaries

| Environment | Planned access | Boundary |
| --- | --- | --- |
| AD DS | Read lab identities and groups. Delegate user and group changes to the dedicated lab OU and groups. | Validate domain, target OU and managed groups before writing. |
| Microsoft Entra ID | Separate delegated Microsoft Graph permissions and an appropriate signed-in operator role. | Validate tenant, account type and managed group IDs. Use dedicated cloud-only test identities and static security groups. |
| GitHub Actions | Read repository contents for offline PowerShell tests. | Use synthetic fixtures. |

The Day 01 tenant overview displays Microsoft Entra ID P2. The planned basic user and static-group exercises use capabilities available in Entra ID Free.

Review Microsoft Graph permission requirements for the user operations in Day 04 and the group operations in Day 05. Record the scopes and operator role used in the lab. If you collect Entra audit evidence, capture it in the admin center on the day of the exercise.

For the optional synchronization exercise, verify the active configuration and the intended OU scope before exporting changes. [Day 06](day-06.md)

- [Microsoft Entra log retention](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/reference-reports-data-retention)
- [Microsoft Graph user update permissions](https://learn.microsoft.com/en-us/graph/api/user-update?view=graph-rest-1.0)
- [Microsoft Graph group membership removal](https://learn.microsoft.com/en-us/graph/api/group-delete-members?view=graph-rest-1.0)
