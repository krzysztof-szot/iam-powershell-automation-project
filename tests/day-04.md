# Day 04 — Entra ID user management with Microsoft Graph tests

**Status** · Three recorded result checks passed  
Record updated 2026-11-11.

[Lab record](../docs/day-04.md) · [Screenshots](../evidence/day-04/README.md) · [Permissions record](../docs/permissions.md#day-04-recorded-graph-context)

The owner performed the lab actions. PASS applies to the observations described below.

| ID | Procedure | Expected | Actual | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| D04-01 | Verify the portal-created test identity and inspect the Graph session | The intended account is visible and the context shows delegated authentication with the required user-management scope. | IAM Cloud Portal User / iam.cloud01@… is a Member. Get-MgContext shows Delegated, Process, User.ReadWrite.All and additional scopes. Account domain and tenant ID are redacted. | PASS | [01](../evidence/day-04/01-cloud-user-in-portal.png), [02](../evidence/day-04/02-graph-context-redacted.png) |
| D04-02 | Update Department and JobTitle and query both properties again | The subsequent read returns the intended values for the same user. | BEFORE shows Finance / IAM Lab User. AFTER shows IT / IAM Automation Trainee for IAM Cloud Portal User. | PASS | [03](../evidence/day-04/03-graph-attribute-before-after.png) |
| D04-03 | Create a second user with New-MgUser and retrieve it through the returned ID | The new account has the intended name, alias, enabled state and attributes. | IAM Cloud Graph User, iam.graph01, AccountEnabled=True, Department=Finance, JobTitle=IAM Lab User. | PASS | [04](../evidence/day-04/04-graph-created-user.png) |

## Evidence coverage

- D04-01 records the portal account and the SDK context fields. The connection command requested User.ReadWrite.All, while the displayed context includes the additional scopes recorded in the permissions guide.
- D04-02 records both attribute values before and after the update, including the independent read.
- D04-03 records the creation command and returned account properties. The password profile's first-sign-in change setting is visible in the request.

The initial invalid tenant-input error is described in the lab record from the owner's console output. The successful authentication context is the retained result evidence.
