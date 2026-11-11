# Day 06 — Scoped Cloud Sync tests

**Status** · Seven recorded result checks passed  
Record updated 2026-11-11.

[Lab record](../docs/day-06.md) · [17 screenshots](../evidence/day-06/README.md)

The owner performed the runtime actions. PASS applies to each stated observation. The first provisioning request was skipped; D06-02 records successful diagnosis of that result.

| ID | Procedure | Expected | Actual | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| D06-01 | Identify the engine, local service, registered agent and initial configuration | The initial engine, agent state and configured scope are established. | AADConnectProvisioningAgent is Running on BFL-DC01; the Cloud Sync agent is active. The Cloud Sync overview is Disabled and its filter lists three security groups. | PASS | [02](../evidence/day-06/02-cloud-sync-agent-services.png), [03](../evidence/day-06/03-cloud-sync-agent-status.png), [04](../evidence/day-06/04-cloud-sync-configurations.png), [05](../evidence/day-06/05-cloud-sync-scoping-filters.png) |
| D06-02 | Inspect processing and scoping details after the skipped request | The diagnosis uses the detailed evaluation and final action. | Final action is Object was skipped, SkipReason=JoinNotFound. Active in the source system=True and Scoping filter evaluation passed=False identify the scope issue in this run. | PASS | [08](../evidence/day-06/08-provision-on-demand-result.png), [09](../evidence/day-06/09-provisioning-scope-details.png) |
| D06-03 | Create a dedicated sync group, add the test user directly and extend the filter | The group has the intended one-user membership and appears in selected-group scope. | GG-IAM-LAB-Sync is Global/Security with one captured member, iam.sync01. The saved filter lists it alongside the three prior groups. | PASS | [10](../evidence/day-06/10-sync-scope-group.png), [11](../evidence/day-06/11-cloud-sync-scope-updated.png) |
| D06-04 | Provision the dedicated user and perform an independent Graph read | The new Entra account corresponds to the AD test user and initial properties. | Export reports user creation. Graph returns one bfl.iam.sync01 account with Department=Finance, AccountEnabled=True, the expected AD DN and SAM name, OnPremisesSyncEnabled=True and ImmutableIdPresent=True. | PASS | [06](../evidence/day-06/06-sync-ou-and-user.png), [07](../evidence/day-06/07-ad-sync-baseline.png), [12](../evidence/day-06/12-provision-on-demand-after-fix.png), [13](../evidence/day-06/13-graph-sync-baseline.png) |
| D06-05 | Compare the owner-supplied AD anchor calculation with Graph | SAM name, DN and the Base64 anchor match. | SourceAnchorAttribute=objectGUID; SamAccountNameMatches=True, DistinguishedNameMatches=True and AnchorMatches=True. The code compares Base64 with StringComparison.Ordinal. | PASS | [07](../evidence/day-06/07-ad-sync-baseline.png), [14](../evidence/day-06/14-sync-anchor-verification.png) |
| D06-06 | Set Department to IT and read the AD user before and after | The AD read changes from Finance to IT. | iam.sync01 has Department=Finance before Set-ADUser and IT afterward; both reads show Title=IAM Sync Lab User. | PASS | [15](../evidence/day-06/15-ad-department-before-after.png) |
| D06-07 | Provision the attribute update and query Graph again | The existing Entra user reports Department=IT. | Export reports an update with Department=IT. Fresh Graph output shows IT, DepartmentMatchesExpected=True, AccountEnabled=True and the expected AD metadata. | PASS | [16](../evidence/day-06/16-cloud-sync-department-update.png), [17](../evidence/day-06/17-graph-department-after-sync.png) |

## Track selection

| Track | Status | Reason |
| --- | --- | --- |
| Microsoft Entra Cloud Sync, provision on demand | Completed | Existing lab agent, one dedicated test user and the recorded checks above. |
| Entra Connect Sync staging and export preview | N/A | The selected engine was Cloud Sync. |
| Alternative access drift report and correction | N/A | The synchronization track was selected. |

## Coverage

The tests establish on-demand creation, scope troubleshooting, source-anchor correlation and department propagation for the test identity. The initial overview records Disabled; recurring-cycle execution, password propagation and user sign-in were outside the recorded scope.

Anchor equality was captured before the department update. The final Graph read checks ImmutableId presence. These lab observations are separate from the offline repository checks in GitHub Actions.
