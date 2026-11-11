# Day 02 — Active Directory user management tests

**Status** · Three recorded result checks passed  
Record updated 2026-11-11.

[Lab record](../docs/day-02.md) · [Screenshots](../evidence/day-02/README.md) · [Saved example](../scripts/day-02-user-attributes.ps1)

The owner performed the lab actions. PASS applies to the observations described below.

| ID | Procedure | Expected | Actual | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| D02-01 | Verify the two test users after the guided console and New-ADUser creation procedure | Both users exist in the dedicated lab OU and can be read back. | IAM GUI User / iam.gui01 and IAM PowerShell User / iam.ps01 are present under IAM-Automation and both report Enabled=True. | PASS | [01](../evidence/day-02/01-lab-ou-and-users.png), [02](../evidence/day-02/02-scoped-user-query.png) |
| D02-02 | Filter users within the lab OU using SearchBase and OneLevel | The query returns the intended directly contained test accounts. | SearchBase=OU=IAM-Automation,DC=balticfinance,DC=test, filter iam.*, two expected accounts returned. | PASS | [02](../evidence/day-02/02-scoped-user-query.png) |
| D02-03 | Change iam.ps01 Department and Title and read them again | The subsequent query returns the intended values for the same account. | BEFORE has empty fields. AFTER shows Department=IT and Title=IAM Automation Trainee for iam.ps01. | PASS | [03](../evidence/day-02/03-user-attributes-before-after.png) |

## Saved example review

The uploaded PowerShell example was reviewed for the fixed lab target `iam.ps01`, its before/after reads and the intended Set-ADUser parameters. A syntax parse of the uploaded source completed successfully. The runtime result above is supported by the captured console sequence. [Script](../scripts/day-02-user-attributes.ps1)

## Coverage notes

The OU screenshot shows the resulting user objects. The scoped query confirms their login names and enabled state. The guided creation procedure is documented in the lab record, while the retained before/after capture provides direct evidence of the attribute update.
