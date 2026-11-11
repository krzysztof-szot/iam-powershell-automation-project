# Day 02 — Active Directory user management evidence

Three uploaded screenshots support the recorded result checks. Record updated 2026-11-11.

[Lab record](../../docs/day-02.md) · [Test results](../../tests/day-02.md) · [Saved PowerShell example](../../scripts/day-02-user-attributes.ps1)

## 01 — Dedicated OU and user objects

Active Directory Users and Computers is connected to `BFL-DC01.balticfinance.test`. The selected `IAM-Automation` OU contains `IAM GUI User` and `IAM PowerShell User`.

![IAM-Automation OU containing the two test user objects](01-lab-ou-and-users.png)

## 02 — OU-scoped PowerShell query

The displayed SearchBase is `OU=IAM-Automation,DC=balticfinance,DC=test`. The query uses `OneLevel` and the `iam.*` login filter. It returns `iam.gui01` and `iam.ps01`, both enabled, with empty Department and Title fields at this point in the exercise.

![OU-scoped query returning the two enabled IAM test accounts](02-scoped-user-query.png)

## 03 — Attribute values before and after the update

The BEFORE read shows empty Department and Title for `iam.ps01`. The captured `Set-ADUser` command sets IT and IAM Automation Trainee, and the independent AFTER read returns those values for the same account.

![PowerShell attribute update with before and after reads for iam.ps01](03-user-attributes-before-after.png)
