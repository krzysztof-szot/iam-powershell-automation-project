# Day 06 — Access drift and recovery

**Status** · Planned

[Tests](../tests/day-06.md) · [Screenshot checklist](../evidence/day-06/README.md)

## Objective

Detect unauthorized membership drift and recover from a controlled interruption.

## Implementation plan

1. Introduce a missing required membership and an extra managed membership on a disposable account. Compare actual and intended state in a read-only report.
2. Inject a controlled failure after Finance removal and before IT assignment. Record each operation and mark the run partial.
3. Re-read directory state before resuming. Apply the missing step and verify the next run is a no-op.

## Verification

Record observed results and deviations in the test record. Capture the planned evidence after running each scenario.
