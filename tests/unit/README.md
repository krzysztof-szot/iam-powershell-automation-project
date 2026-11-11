# Offline Pester tests

The CI workflow pins Pester 5.7.1. Lifecycle.Tests.ps1 covers input validation, exact account/OU/group boundaries, lifecycle ordering, WhatIf writer mocks, same-stage repeats, partial Mover recovery, binding changes, read-back and audit failures. Repository.Tests.ps1 checks the daily lab records, example AD policy mappings and synthetic event feed.

Run the full suite in a fresh PowerShell 7 process (pwsh). CI uses PowerShell 7 with Pester 5.7.1; the existing repository checks use ConvertFrom-Json -AsHashtable. The AD entry point itself retains Windows PowerShell 5.1 support, separately exercised by the assertion runner.

From the repository root:

~~~powershell
Import-Module Pester -RequiredVersion 5.7.1
Invoke-Pester -Path ./tests/unit -CI -Output Detailed
~~~

All lifecycle directory responses and writes use the simulated ActiveDirectory adapter copied into TestDrive. The suite uses synthetic identities, temporary input files and CSV logs. It restores PSModulePath and unloads the test modules when finished. No tenant or AD credentials are required.

The separate assertion runner remains available:

~~~powershell
pwsh -NoProfile -File ./tests/offline/Lifecycle.Checks.ps1
~~~

The successful Day 08 CI run reports 44 Pester tests: 41 lifecycle and three repository checks. The separate runner reports 50 checks passed. [Recorded CI result](../../evidence/day-08/ci-summary.md)

Live Windows access, domain sign-in and the outside-OU exercise are documented separately in the [Day 08 lab record](../../docs/day-08.md). Offline test success does not establish those live results.

[Pester v5 mocking](https://pester.dev/docs/v5/usage/mocking) · [Discovery and runtime setup](https://pester.dev/docs/v5/usage/discovery-and-run)
