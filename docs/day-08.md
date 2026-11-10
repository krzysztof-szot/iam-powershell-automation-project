# Day 08 — Capstone, Pester and portfolio review

**Status** · Planned

[Tests](../tests/day-08.md) · [Screenshot checklist](../evidence/day-08/README.md)

## Objective

Validate the end-to-end AD workflow, verify recovery behavior and prepare the portfolio documentation.

## Implementation plan

1. Run Joiner, Mover and Leaver in order on a fresh lab account. After each stage, independently verify user and group state. Check Finance and IT share access from fresh Windows sessions, then attempt a fresh domain logon with the disabled account.
2. Verify that a target outside the lab OU is rejected, that `Apply` with `-WhatIf` preserves state, and that repeating the same event at the same stage performs zero additional changes.
3. Inject a failure after the old group is removed and before the new group is added. Record the partial result and verify that resuming applies only the missing change.
4. Add Pester tests for the planning and safety behavior. Run them in GitHub Actions using synthetic fixtures. Add usage instructions, a workflow diagram and redacted evidence links to the project README.

## Verification

Record the observed outcome in the test record and capture the planned screenshots after each scenario.
