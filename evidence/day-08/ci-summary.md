# Day 08 — Recorded CI result

- Workflow: PowerShell checks.
- Branch: main.
- [Validated source commit](https://github.com/krzysztof-szot/iam-powershell-automation-project/commit/0c7ddb65b5900767bbe4f4ee8528f9c685abac4f): 0c7ddb65b5900767bbe4f4ee8528f9c685abac4f.
- [Successful run](https://github.com/krzysztof-szot/iam-powershell-automation-project/actions/runs/43039551586).
- [Job and log](https://github.com/krzysztof-szot/iam-powershell-automation-project/actions/runs/43039551586/job/130587363165).
- Runner: ubuntu-latest; PowerShell 7.6.9; Pester 5.7.1.
- Separate assertion runner: 50 passed, 0 failed.
- Pester: 44 passed, 0 failed, 0 skipped, 0 inconclusive, 0 not run.

The Pester total consists of 41 lifecycle tests and three repository scaffold checks. [Screenshot 26](26-capstone-pester-ci-passed.png) shows the successful job and detailed Pester output. Both suites use simulated AD and synthetic inputs, with no live directory credentials.

This records the code-validation run captured during Day 08. Subsequent evidence/documentation commits run the same workflow again; their individual status is available from the repository Actions page.
