# PowerShell entry points

The following entry points are planned for implementation during the lab.

| Script | Responsibility |
| --- | --- |
| `Invoke-IamLifecycle.ps1` | Accept an HR event and target directory, preview the plan, and apply only after explicit approval. |
| `Get-IamAccessDrift.ps1` | Report unexpected or missing direct memberships in managed groups. |

Shared planning and directory-specific operations belong in [the IAM module](../src/IamAutomation/README.md). See [Day 01](../docs/day-01.md) for the first implementation step.
