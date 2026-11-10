# Permissions and boundaries

| Environment | Planned access | Boundary |
| --- | --- | --- |
| AD DS | Read lab identities and groups. Delegate user and group changes to the dedicated lab OU and groups. | Validate domain, target OU and managed groups before writing. |
| Entra ID Free | Separate delegated Microsoft Graph permissions and an appropriate signed-in operator role. | Validate tenant, account type and managed group IDs. Use dedicated cloud-only test identities and static security groups. |
| GitHub Actions | Read repository contents for offline PowerShell tests. | Use synthetic fixtures. |

Review the permission requirements for each Graph operation during Day 05. Record the scopes and operator role that were verified in the lab. Use the Entra admin center for the planned audit evidence and capture it on the day of the test.

- [Microsoft Entra log retention](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/reference-reports-data-retention)
- [Microsoft Graph user update permissions](https://learn.microsoft.com/en-us/graph/api/user-update?view=graph-rest-1.0)
- [Microsoft Graph group membership removal](https://learn.microsoft.com/en-us/graph/api/group-delete-members?view=graph-rest-1.0)
