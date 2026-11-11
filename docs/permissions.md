# Permissions and boundaries

| Environment | Planned access | Boundary |
| --- | --- | --- |
| AD DS | Read lab identities and groups. Delegate user and group changes to the dedicated lab OU and groups. | Validate domain, target OU and managed groups before writing. |
| Microsoft Entra ID | Separate delegated Microsoft Graph permissions and an appropriate signed-in operator role. | Validate tenant, account type and managed group IDs. Use dedicated cloud-only test identities and static security groups. |
| GitHub Actions | Read repository contents for offline PowerShell tests. | Use synthetic fixtures. |

The Day 01 tenant overview displays Microsoft Entra ID P2. The planned basic user and static-group exercises use capabilities available in Entra ID Free.

Review Microsoft Graph permission requirements for the user operations in Day 04 and the group operations in Day 05. Record the scopes and operator role used in the lab. If you collect Entra audit evidence, capture it in the admin center on the day of the exercise.

## Day 04 recorded Graph context

The guided connection requested `User.ReadWrite.All` with `ContextScope Process`. The captured Get-MgContext view reports `AuthType=Delegated` and `ContextScope=Process`, with the visible operator alias `bg01`. The account domain and tenant ID are redacted.

The displayed scopes are transcribed from that context view:

```text
Application.Read.All
Application.ReadWrite.All
Directory.Read.All
Directory.ReadWrite.All
Group.Read.All
Group.ReadWrite.All
GroupMember.ReadWrite.All
openid
Policy.Read.All
profile
RoleManagement.Read.Directory
RoleManagement.ReadWrite.Directory
User.Read.All
User.ReadWrite.All
email
```

The requested scope and the additional displayed grants are both part of the lab record. The successful Update-MgUser and New-MgUser calls with independent read-back establish the observed authorization for those user-management operations. [Day 04 record](day-04.md) · [Context screenshot](../evidence/day-04/02-graph-context-redacted.png)

## Day 05 guided group operations

The connection parameters requested `User.Read.All` to read the test identity and department, `Group.Read.All` to resolve the lab groups, and `GroupMember.ReadWrite.All` for membership operations. The procedure used `ContextScope Process`.

The guided group setup used Security groups with Assigned membership and the role-assignable setting at No. The correction used `Remove-MgGroupMemberByRef` for the membership reference and `New-MgGroupMemberByRef` for the new membership. Fresh direct-member queries and the uploaded reports record the resulting state. [Day 05 record](day-05.md) · [Result evidence](../evidence/day-05/README.md)

The requested Day 05 parameters are recorded here separately from the captured Day 04 Get-MgContext scope list above.

## Synchronization and references

For the optional synchronization exercise, verify the active configuration and the intended OU scope before exporting changes. [Day 06](day-06.md)

- [Microsoft Entra log retention](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/reference-reports-data-retention)
- [Microsoft Graph user update permissions](https://learn.microsoft.com/en-us/graph/api/user-update?view=graph-rest-1.0)
- [Microsoft Graph group membership removal](https://learn.microsoft.com/en-us/graph/api/group-delete-members?view=graph-rest-1.0)
