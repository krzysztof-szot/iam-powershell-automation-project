# Day 05 — Entra security groups and manual access review

**Status** · Completed documented scope  
Record updated 2026-11-11.

[Tests](../tests/day-05.md) · [Screenshots](../evidence/day-05/README.md) · [Review CSV](../samples/membership-review.csv) · [Final-state CSV](../samples/membership-after.csv)

## Objective

Compare direct Entra group memberships with a department-based lab policy, review the proposed corrections and verify the resulting membership state.

The owner performed the lab actions. Three uploaded screenshots and two CSV reports record the controlled mismatch, review decision and final state.

## Lab setup and policy

The guided portal setup created two Security groups with Assigned membership, `SG-IAM-LAB-Finance` and `SG-IAM-LAB-IT`. The exercise used the existing `IAM Cloud Portal User` / `iam.cloud01` identity from Day 04.

The user's Department was already IT. Finance membership was intentionally added to create a controlled mismatch for the review. The local policy mapped each department to its corresponding lab group:

```powershell
$labAccessPolicy = @{
    Finance = 'SG-IAM-LAB-Finance'
    IT      = 'SG-IAM-LAB-IT'
}
```

The report evaluates the user's direct membership in these two groups against that rule.

## Recorded results

### Membership before review

A fresh Get-MgGroupMember query feeds the first captured result:

| Field | Recorded value |
| --- | --- |
| User | IAM Cloud Portal User |
| UserAlias | iam.cloud01 |
| Department | IT |
| Group | SG-IAM-LAB-Finance |
| DirectMember | True |

This establishes the controlled mismatch between the IT department and Finance membership. [Screenshot 01](../evidence/day-05/01-cloud-membership-before.png)

### Report export and review decision

The guided report read both groups, compared their direct members with the expected group for Department=IT, and exported the result through Export-Csv. The retained screenshot reads that file back with Import-Csv and reports `Imported rows: 2`.

| Group | CurrentMember | ExpectedMember | Decision |
| --- | --- | --- | --- |
| SG-IAM-LAB-Finance | True | False | Remove |
| SG-IAM-LAB-IT | False | True | Add |

Both rows identify `iam.cloud01`, Department=IT, and the reason `Department requires SG-IAM-LAB-IT`. The review decision was to remove the obsolete Finance membership and add IT membership. The owner then carried out those corrections through the guided Graph commands. [Screenshot 02](../evidence/day-05/02-membership-report.png) · [Review CSV](../samples/membership-review.csv)

The report's Decision values are calculated from the department rule. The review and execution are the owner's steps in the guided exercise.

### Membership correction and independent read-back

The correction first read the current Finance members and used `Remove-MgGroupMemberByRef` for the user's membership reference when present. It then read IT members and used `New-MgGroupMemberByRef` to add the user when absent.

A subsequent Get-MgGroupMember query for each group produces the captured final state:

| UserAlias | Department | Group | DirectMember |
| --- | --- | --- | --- |
| iam.cloud01 | IT | SG-IAM-LAB-Finance | False |
| iam.cloud01 | IT | SG-IAM-LAB-IT | True |

The owner exported this result to a separate CSV. The uploaded final-state file contains the same two rows. [Screenshot 03](../evidence/day-05/03-cloud-membership-after.png) · [Final-state CSV](../samples/membership-after.csv)

## Graph connection parameters

The guided connection requested `User.Read.All`, `Group.Read.All` and `GroupMember.ReadWrite.All` with `ContextScope Process`. The Day 05 result evidence covers membership reads, the report and final membership state. The earlier captured authentication context is recorded with the Day 04 evidence. [Permissions notes](permissions.md#day-05-guided-group-operations)

## Published reports

| File | Contents |
| --- | --- |
| [membership-review.csv](../samples/membership-review.csv) | Two pre-correction rows with CurrentMember, ExpectedMember, Decision and Reason. |
| [membership-after.csv](../samples/membership-after.csv) | Two post-correction rows with DirectMember. |

Both uploaded reports were parsed during documentation review. Their row counts, synthetic alias, department, group names and state values agree with the screenshots. The published files contain the lab alias and group labels.

## Final recorded state

`iam.cloud01` remains in Department IT. Its direct Finance membership is absent and its direct IT membership is present. The three result checks connect that state to the initial mismatch and recorded review decision.

[Test results](../tests/day-05.md) · [Evidence page](../evidence/day-05/README.md)
