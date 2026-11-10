# Day 07 — Pester tests and GitHub Actions

**Status** · Planned

[Tests](../tests/day-07.md) · [Screenshot checklist](../evidence/day-07/README.md)

## Objective

Automate offline validation of the PowerShell logic and keep live lab verification separate.

## Implementation plan

1. Extend the starter Pester checks with mocks for AD DS and Graph. Cover invalid data, scope checks, dry-run behavior and repeated runs.
2. Cover partial execution and resume behavior. Assert the expected write calls and ordering.
3. Run the same suite locally and in GitHub Actions. Keep integration results in the daily test record.

## Verification

Record observed results and deviations in the test record. Capture the planned evidence after running each scenario.
