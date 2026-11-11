# Day 05 — Entra security groups and manual access review tests

**Status** · Three recorded result checks passed  
Record updated 2026-11-11.

[Lab record](../docs/day-05.md) · [Screenshots](../evidence/day-05/README.md) · [Review CSV](../samples/membership-review.csv) · [Final-state CSV](../samples/membership-after.csv)

The owner performed the lab actions. PASS applies to the observations described below.

| ID | Procedure | Expected | Actual | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| D05-01 | Read the prepared Finance membership and export the two-group review snapshot | The initial membership and imported report identify the intended user and both lab groups. | iam.cloud01 has Department=IT and Finance DirectMember=True. Import-Csv returns two rows showing Finance present and IT absent before correction. | PASS | [01](../evidence/day-05/01-cloud-membership-before.png), [02](../evidence/day-05/02-membership-report.png), [Review CSV](../samples/membership-review.csv) |
| D05-02 | Compare memberships with the department rule and record the review decision | The report identifies the required removal and addition with a reason. | Finance CurrentMember=True / ExpectedMember=False / Decision=Remove. IT CurrentMember=False / ExpectedMember=True / Decision=Add. Both rows give the reason Department requires SG-IAM-LAB-IT. | PASS | [02](../evidence/day-05/02-membership-report.png), [Review CSV](../samples/membership-review.csv) |
| D05-03 | Apply the reviewed correction and read direct members again | Finance membership is absent and IT membership is present. | The captured read and uploaded final-state CSV both show Finance=False and IT=True for iam.cloud01, Department=IT. | PASS | [03](../evidence/day-05/03-cloud-membership-after.png), [Final-state CSV](../samples/membership-after.csv) |

## Report validation and coverage

Both uploaded CSV files were parsed and checked for two rows, unique Finance and IT group entries, the expected column sets and consistency with the screenshots. All rows identify the synthetic alias iam.cloud01 and Department IT.

The policy calculation supplies the Decision column. The owner reviewed the report and followed the correction procedure. The final evidence records direct memberships in the two lab groups.
