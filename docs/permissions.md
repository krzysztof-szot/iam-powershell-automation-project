# Permissions and boundaries

| Environment | Planned access | Boundary |
| --- | --- | --- |
| AD DS | Read lab identities and groups. Delegate user and group changes to the dedicated lab OU and groups. | Validate domain, target OU and managed groups before writing. |
| Microsoft Entra ID | Separate delegated Microsoft Graph permissions and an appropriate signed-in operator role. | Validate tenant, account type and managed group IDs. Use dedicated cloud-only test identities for Days 04–05, an AD-sourced test user for Day 06 and static security groups. |
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

## Day 06 recorded Cloud Sync operations

The captured local operator is BFL\\Administrator on BFL-DC01. The guided creation targeted the dedicated IAM-Sync OU. The captured console operations create GG-IAM-LAB-Sync as a Global Security group, add iam.sync01 directly and change only the test user's Department to IT. The observation establishes use of the lab administrator account; delegated OU permissions were outside this exercise.

The existing Cloud Sync agent performs the Entra creation and update through Provision on demand for the exact test-user DN. The selected-group filter was extended with the dedicated group, and the saved view retains the original three entries. Its initial overview shows Configuration status=Disabled.

The guided Graph connection requested User.Read.All with ContextScope Process. The recorded Graph commands are Get-MgUser reads with explicit property selection. The published Day 06 images establish successful reads, but do not capture a new Get-MgContext scope list or the signed-in cloud operator's assigned role. The Day 04 captured context remains documented above.

The anchor check calculates a Base64 value from the AD source and compares it with onPremisesImmutableId. The captured output reports objectGUID and three True comparisons. The exercise records on-demand creation and attribute propagation. Recurring-job health, password propagation and sign-in are outside the result claims.

[Day 06 record](day-06.md) · [Result checks](../tests/day-06.md) · [Screenshots](../evidence/day-06/README.md)

## Day 07 recorded AD lifecycle operations

The execution uses BFL\Administrator on BFL-DC01 with the ActiveDirectory module in Windows PowerShell 5.1. This records a lab-administrator run, not validation of delegated least-privilege permissions.

The script checks the configured DNS domain and DC, the exact JML OU, the two Security group DNs and the synthetic LAB-nnn identity. It rejects ambiguous matches, mismatched identities, targets outside the exact synthetic account DN and protected/critical objects. Existing account and group writes use objectGUID bindings and the configured server, with fresh reads around each operation.

Default Preview and Apply with WhatIf make no intended AD writes. Audit CSV creation remains enabled in these modes. Apply uses ShouldProcess before each write; native AD confirmation is suppressed only after that guard has permitted the operation.

The new-account password is supplied as a SecureString. The isolated lab account is created enabled with ChangePasswordAtLogon=False for subsequent workstation testing. Passwords are excluded from the audit fields. The script manages only the two direct lab group memberships and does not delete accounts or reactivate a disabled account.

The captured Joiner, Mover and Leaver runs completed with 2, 3 and 2 applied steps. Independent reads confirm the expected state after each stage. Disabled-account authentication and active-session behavior were not tested on Day 07.

[Day 07 record](day-07.md) · [Evidence](../evidence/day-07/README.md) · [Recovery](recovery-runbook.md)

## Day 08 recorded execution and scope test

The controller-side execution continues as BFL\Administrator. The captured client access commands explicitly identify bfl\iam.lab002 on BFL-WKS01. This separates the privileged setup/execution operator from the ordinary identity used for Finance and IT access checks.

The WhatIf verification uses independent native queries for matching accounts and group identities/direct members. The outside-OU verification binds its read to the saved fixture objectGUID and checks the same account fields, revision and membership booleans against the saved baseline.

Manual lab setup creates disabled iam.lab003 directly in IAM-Automation and adds temporary Finance membership. The lifecycle entry point keeps its configured JML boundary and rejects JML-201 before any write step. The test audit records Run Started/Failed with the expected DN error; the account state and Finance membership remain unchanged.

Only after collecting that result, the operator manually removes the temporary Finance membership. The account remains disabled. This fixture setup/cleanup is explicitly separate from the blocked lifecycle operation and is not a relaxation of its scope.

The live test proves new-sign-in rejection for the disabled account. Existing-session termination and delegated least-privilege permissions were outside the exercise. The offline suites use synthetic data, simulated directory operations and read-only repository access in CI.

[Day 08 record](day-08.md) · [Scope evidence](../evidence/day-08/24-capstone-out-of-scope-state-preserved.png) · [Manual cleanup](../evidence/day-08/25-capstone-scope-fixture-cleanup.png)

## Synchronization and references

Day 06 records the existing Cloud Sync engine, its selected-group scope, one scoped test identity and the on-demand result details. [Day 06](day-06.md)

- [Microsoft Entra log retention](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/reference-reports-data-retention)
- [Microsoft Graph user update permissions](https://learn.microsoft.com/en-us/graph/api/user-update?view=graph-rest-1.0)
- [Microsoft Graph group membership removal](https://learn.microsoft.com/en-us/graph/api/group-delete-members?view=graph-rest-1.0)
- [Cloud Sync scope configuration](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/how-to-configure)
- [Cloud Sync source anchor selection](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/plan-cloud-sync-topologies)
