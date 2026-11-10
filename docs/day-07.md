# Day 07 — Build the Joiner–Mover–Leaver automation

**Status** · Planned

[Tests](../tests/day-07.md) · [Screenshot checklist](../evidence/day-07/README.md)

## Objective

Combine the earlier AD exercises into one PowerShell workflow for synthetic HR events.

## Implementation plan

1. Load the [synthetic events](../samples/hr-events.example.csv), the [access matrix](../config/access-matrix.example.json) and local lab configuration. Validate the event type, employee identity, target domain and OU, and the managed groups before writing.
2. Plan each event against current directory state. Joiner creates the lab account and grants the intended group. Mover removes the old managed group before granting the new one. Leaver disables the account and removes its managed memberships.
3. Default to a read-only plan. Require explicit `Apply` intent for writes and guard writes with `SupportsShouldProcess` and `$PSCmdlet.ShouldProcess()` so `-WhatIf` also preserves directory state.
4. Record the event ID, step and outcome. On a partial failure, read current state before continuing and compute the remaining operations. Use the [recovery runbook](recovery-runbook.md) to record the exercise.

## Verification

Record the observed outcome in the test record and capture the planned screenshots after each scenario.

- [PowerShell ShouldProcess and WhatIf](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess)
