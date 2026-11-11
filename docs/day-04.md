# Day 04 — Entra ID user management with Microsoft Graph

**Status** · Completed documented scope  
Record updated 2026-11-11.

[Tests](../tests/day-04.md) · [Screenshots](../evidence/day-04/README.md) · [Permissions record](permissions.md)

## Objective

Create a dedicated user through the Entra portal, connect through delegated Microsoft Graph PowerShell, update the user's attributes and create a second cloud identity through Graph.

The owner performed the lab actions. Four uploaded screenshots record the portal account, authentication context, attribute update and Graph user creation with independent read-back.

## Recorded results

### Portal-created test account

The Entra user Overview shows `IAM Cloud Portal User`, the login prefix `iam.cloud01@` and `User type=Member`. The object ID and part of the domain are redacted. The visible creation timestamp is Nov 11, 2026, 8:54 AM in the portal's display. [Screenshot 01](../evidence/day-04/01-cloud-user-in-portal.png)

### Delegated Graph connection

The guided preparation used the Microsoft.Graph.Authentication and Microsoft.Graph.Users modules. The connection requested:

```powershell
Connect-MgGraph `
    -TenantId $labTenantId `
    -Scopes 'User.ReadWrite.All' `
    -ContextScope Process `
    -NoWelcome
```

The owner-supplied console output initially showed `Invalid tenant id provided` after Read-Host captured command text as the tenant value. Assigning the tenant GUID directly to the local variable corrected the input before the successful session capture.

`Get-MgContext` shows `AuthType=Delegated`, `ContextScope=Process` and an account with the visible alias `bg01`. Its domain and tenant ID are redacted. The displayed scope list includes User.ReadWrite.All together with application, directory, group, policy and role-management scopes. [Screenshot 02](../evidence/day-04/02-graph-context-redacted.png)

The requested permission and the observed context are recorded separately in the [permissions guide](permissions.md#day-04-recorded-graph-context). Successful user operations below provide the authorization evidence for this session.

### Attribute update through Graph

The BEFORE read shows:

| Property | Recorded value |
| --- | --- |
| DisplayName | IAM Cloud Portal User |
| Department | Finance |
| JobTitle | IAM Lab User |

The captured update uses the previously resolved user's object:

```powershell
Update-MgUser -UserId $labCloudUser.Id `
    -Department 'IT' `
    -JobTitle 'IAM Automation Trainee' `
    -ErrorAction Stop
```

An independent Get-MgUser query explicitly requests the properties and reads them again:

```powershell
Get-MgUser -UserId $labCloudUser.Id `
    -Property DisplayName, Department, JobTitle |
    Format-List DisplayName, Department, JobTitle
```

The AFTER result shows the same display name, `Department=IT` and `JobTitle=IAM Automation Trainee`. [Screenshot 03](../evidence/day-04/03-graph-attribute-before-after.png)

### Second user created through Graph

The owner prepared `iam.graph01` in the same lab domain and entered a temporary password through `Read-Host -AsSecureString`. The capture shows masked input, a password profile with `ForceChangePasswordNextSignIn=True`, and this creation call:

```powershell
$labCreatedUser = New-MgUser `
    -DisplayName 'IAM Cloud Graph User' `
    -UserPrincipalName $labNewUpn `
    -MailNickname 'iam.graph01' `
    -AccountEnabled `
    -Department 'Finance' `
    -JobTitle 'IAM Lab User' `
    -PasswordProfile $labPasswordProfile `
    -ErrorAction Stop
```

The captured finally block removes the password-profile variable and disposes the SecureString. The subsequent Get-MgUser read uses the returned object's ID and shows:

| Property | Recorded value |
| --- | --- |
| DisplayName | IAM Cloud Graph User |
| MailNickname | iam.graph01 |
| AccountEnabled | True |
| Department | Finance |
| JobTitle | IAM Lab User |

The screenshot records the configured first-sign-in password-change flag in the creation request and the five properties returned by the independent read. [Screenshot 04](../evidence/day-04/04-graph-created-user.png)

## Final recorded state and coverage

The portal-created `iam.cloud01` account has the updated IT department and IAM Automation Trainee job title. The Graph-created `iam.graph01` account is enabled with Finance and IAM Lab User values.

The authentication evidence consists of the redacted Get-MgContext view. The attribute and creation results are supported by fresh Get-MgUser reads. The displayed context includes additional scopes beyond the scope named in the guided connection command.

[Test results](../tests/day-04.md) · [Evidence page](../evidence/day-04/README.md)
