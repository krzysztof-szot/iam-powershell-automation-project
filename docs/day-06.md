# Day 06 — Scoped Microsoft Entra Cloud Sync

**Status** · Completed documented scope  
Record updated 2026-11-11.

[Tests](../tests/day-06.md) · [17 screenshots](../evidence/day-06/README.md)

## Objective and selected track

Synchronize one new AD test identity through the existing Microsoft Entra Cloud Sync agent, verify its source anchor through Microsoft Graph, and propagate a department change from Finance to IT.

The owner performed the lab actions. The completed track used **Cloud Sync provision on demand**. Entra Connect Sync staging and the alternative access drift report are N/A for this run. Days 04 and 05 retain their separate cloud-only test identities.

## Environment and initial configuration

| Component | Recorded observation |
| --- | --- |
| AD controller and local operator | BFL-DC01 / BFL\\Administrator |
| Agent service | AADConnectProvisioningAgent, Running |
| Registered agent | BFL-DC01.balticfinance.test, active |
| Cloud Sync configuration | balticfinance.test, Configuration status=Disabled in the captured overview |
| Password hash sync setting | Enabled in the configuration |
| Initial filter | Sync selected security groups: GG-Finance, GG-IT and GG-Security |

The initial Connect Sync portal view displayed Sync status=Enabled and Last sync=More than 1 day ago. Discovery then identified the existing Cloud Sync service and registered agent. The Cloud Sync overview separately showed Disabled, with scheduled-cycle fields Not started / Never. The lab proceeded through explicit on-demand requests. [Screenshots 01–05](../evidence/day-06/README.md#environment-discovery)

## Dedicated test identity

| Field | Recorded value |
| --- | --- |
| Display name | IAM Sync User |
| AD sAMAccountName | iam.sync01 |
| Cloud UPN alias | bfl.iam.sync01 |
| Initial Enabled / AccountEnabled | True |
| Initial Department | Finance |
| AD Title / Graph JobTitle | IAM Sync Lab User |
| Description | Day 06 Cloud Sync test |

The test OU and user DN are:

```text
OU=IAM-Sync,OU=IAM-Automation,DC=balticfinance,DC=test
CN=IAM Sync User,OU=IAM-Sync,OU=IAM-Automation,DC=balticfinance,DC=test
```

The guided New-ADUser operation supplied this path, a tenant-domain UPN and a password through Read-Host -AsSecureString. The retained ADUC view and AD read establish the created object, its location and initial properties. The AD baseline shows ms-DS-ConsistencyGuid empty; ObjectGUID is redacted in the published image. [06](../evidence/day-06/06-sync-ou-and-user.png) · [07](../evidence/day-06/07-ad-sync-baseline.png)

## Troubleshooting the first provisioning request

The first request imported the object but ended with **Object was skipped**, SkipReason=JoinNotFound. The summary caption said Object is in scope, while its detailed evaluation reported:

| Detailed check | Value |
| --- | --- |
| Active in the source system | True |
| Scoping filter evaluation passed | False |

The initial selected-group scope did not cover the newly created test identity. The detailed False result identified the scope issue for this request. JoinNotFound is retained as the observed skip reason; the diagnosis also relies on the filter evaluation and successful retry. [08](../evidence/day-06/08-provision-on-demand-result.png) · [09](../evidence/day-06/09-provisioning-scope-details.png)

### Correction through a dedicated group

New-ADGroup created **GG-IAM-LAB-Sync** as a Global Security group in the test OU. Add-ADGroupMember added iam.sync01 directly. The captured member read contains one user.

```text
CN=GG-IAM-LAB-Sync,OU=IAM-Sync,OU=IAM-Automation,DC=balticfinance,DC=test
```

This DN was added to the existing selected-security-group filter. The saved view shows four entries: GG-Finance, GG-IT, GG-Security and GG-IAM-LAB-Sync. [10](../evidence/day-06/10-sync-scope-group.png) · [11](../evidence/day-06/11-cloud-sync-scope-updated.png)

The owner repeated Provision on demand for the exact user DN. Export details reported that the user was created in Microsoft Entra ID, with AccountEnabled=True and Department=Finance. [12](../evidence/day-06/12-provision-on-demand-after-fix.png)

## Independent Graph baseline

The guided connection requested User.Read.All with ContextScope Process. Get-MgUser explicitly selected the required properties and filtered for the bfl.iam.sync01 UPN alias. A count guard required exactly one result.

The captured read reports:

| Graph property | Value |
| --- | --- |
| UserAlias | bfl.iam.sync01 |
| AccountEnabled | True |
| Department | Finance |
| JobTitle | IAM Sync Lab User |
| OnPremisesSyncEnabled | True |
| OnPremisesSamAccountName | iam.sync01 |
| OnPremisesDistinguishedName | The dedicated user DN above |
| ImmutableIdPresent | True |

[Graph baseline — 13](../evidence/day-06/13-graph-sync-baseline.png)

## Source anchor verification

The guided AD calculation read ms-DS-ConsistencyGuid and ObjectGUID for the exact test DN. It used ms-DS-ConsistencyGuid when populated and otherwise ObjectGUID.ToByteArray(), then encoded the bytes through Convert.ToBase64String.

The owner supplied the calculated attribute name and Base64 value to the Graph comparison. The comparison validated the input format and 16-byte length, fetched the user again and used StringComparison.Ordinal for the Base64 equality check.

| Comparison output | Recorded result |
| --- | --- |
| SourceAnchorAttribute | objectGUID |
| SamAccountNameMatches | True |
| DistinguishedNameMatches | True |
| AnchorMatches | True |

The published screenshot records the comparison code and boolean results. The raw input value came from the guided AD calculation. [Anchor verification — 14](../evidence/day-06/14-sync-anchor-verification.png)

## Department change and read-back

Set-ADUser targeted the exact user DN on BFL-DC01.balticfinance.test and set Department to IT. Fresh AD reads captured Finance before and IT afterward. Title remained IAM Sync Lab User in both reads. [15](../evidence/day-06/15-ad-department-before-after.png)

A further Provision on demand request reported an update to the existing Entra user. Export details show Department=IT. A new Get-MgUser query independently returned:

| Final Graph property | Value |
| --- | --- |
| UserAlias | bfl.iam.sync01 |
| AccountEnabled | True |
| Department | IT |
| DepartmentMatchesExpected | True |
| JobTitle | IAM Sync Lab User |
| OnPremisesSyncEnabled | True |
| OnPremisesSamAccountName | iam.sync01 |
| OnPremisesDistinguishedName | The dedicated user DN above |
| ImmutableIdPresent | True |

[Exported update — 16](../evidence/day-06/16-cloud-sync-department-update.png) · [Final Graph read — 17](../evidence/day-06/17-graph-department-after-sync.png)

## Coverage and retained state

The last recorded user state is enabled with Department=IT in AD and Entra. The corrected scope view includes the dedicated group, whose captured direct membership contains iam.sync01.

The captured configuration overview is Disabled, and the procedure kept the exercise on provision on demand. Recurring synchronization, password propagation and user sign-in were outside the recorded tests. OnPremisesSyncEnabled=True is recorded as user metadata; it does not establish scheduled-job health. Anchor equality was checked before the department update, and the final read confirms ImmutableId presence.

Seven result checks passed for the observations in the [test record](../tests/day-06.md).

## References

- [Configure Cloud Sync and selected-group scope](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/how-to-configure)
- [Cloud Sync agent verification](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/how-to-troubleshoot)
- [Provision on demand and processing details](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/how-to-on-demand-provision)
- [Cloud Sync source anchor selection](https://learn.microsoft.com/en-us/entra/identity/hybrid/cloud-sync/plan-cloud-sync-topologies)
- [Source anchor and ImmutableId matching](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-install-existing-tenant)
- [Microsoft Graph user properties](https://learn.microsoft.com/en-us/graph/api/resources/user?view=graph-rest-1.0)
