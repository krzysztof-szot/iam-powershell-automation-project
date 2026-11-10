# Day 06 — Optional AD-to-Entra synchronization or access drift report

**Status** · Planned

[Tests](../tests/day-06.md) · [Screenshot checklist](../evidence/day-06/README.md)

## Objective

Validate one scoped synchronization exercise or build a report that compares expected and observed memberships in both directories.

## Implementation plan

1. Check which synchronization configuration is active in the lab and which objects it covers. Choose one track and record the choice in the test record.
2. **Synchronization track.** If the lab meets the Entra Connect Sync prerequisites, use one new test account in a separate sync OU. Inspect the configuration and pending exports in staging before activating the verified scope.
3. **Synchronization track.** Read the identity in both directories and record the configured source anchor. Change a supported attribute in AD, then verify the corresponding Entra value after synchronization.
4. **Access drift track.** Compare expected memberships from the access matrix with separately collected direct memberships in AD and Entra. Introduce one controlled mismatch, report it, then apply an approved correction and re-run the report.

## Verification

Record results only for the track you run. Mark the other track as N/A. The project uses separate cloud-only accounts for the exercises in Days 04 and 05.

- [Entra Connect Sync prerequisites](https://learn.microsoft.com/en-gb/entra/identity/hybrid/connect/how-to-connect-install-prerequisites)
- [Entra Connect staging mode](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sync-staging-server)
- [Entra Connect filtering](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sync-configure-filtering)
