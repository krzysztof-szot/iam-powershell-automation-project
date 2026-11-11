# Recovery runbook

**Status** · Implemented in Day 07; validated with simulated AD and the live Day 08 controlled Mover exercise.

## Inspect before retrying

1. Record the run ID, event ID, configured DC, account and last confirmed step from the local CSV.
2. Read the current account and its direct managed memberships independently.
3. Run the original event without Apply to calculate a fresh plan.
4. Confirm that the event is still the intended lifecycle stage and review the remaining operations.
5. Apply that reviewed event, verify the resulting state and inspect the new audit.
6. Repeat at the completed current stage to check for NoChange.

Every write is preceded by an audit Started row and followed by a fresh read-back. Applied means that read-back passed. A Failed row can follow a write that partially succeeded; inspect current AD state rather than assuming a rollback.

The implementation re-reads current state and binds existing account and group objectGUIDs. Detected replacement, an ambiguous identity, an out-of-scope target or a protected/critical account stops execution. Never broaden the OU/group configuration to bypass a rejection.

## Recorded live recovery

Day 08 applied JML-102 for LAB-002 with the exercise flag. The independent partial-state read confirms Department=IT and neither managed membership. The audit shows successful department update and Finance removal, followed by a Failed Run. A fresh plan contained one IT grant; Apply completed that one step. New-session client checks then denied Finance and allowed IT.

[Partial state](../evidence/day-08/10-capstone-mover-partial-state.png) · [Partial audit](../evidence/day-08/11-capstone-mover-partial-log.png) · [Recovery plan](../evidence/day-08/12-capstone-mover-recovery-preview.png) · [Recovery result](../evidence/day-08/13-capstone-mover-recovery-applied.png)

## Controlled Mover exercise

Use only a fresh disposable lab identity that is currently in Finance. Review the normal Mover preview first.

~~~powershell
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-102' -EventsPath '.\samples\hr-events.day08.example.csv' -Apply -SimulateFailureAfterRemoval
~~~

The exercise flag deliberately fails after the old managed membership has been successfully removed and audited. At that point Department is IT and the target has neither managed department membership. The Run ends Failed; the successful removal retains its Applied record.

~~~powershell
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-102' -EventsPath '.\samples\hr-events.day08.example.csv'
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-102' -EventsPath '.\samples\hr-events.day08.example.csv' -Apply
~~~

With that partial state, the expected fresh plan contains only AddGroupMember for IT. Do not pass the exercise flag on the retry. Both the simulated checks and the live Day 08 exercise establish this behavior. The recorded LAB-002 is now disabled; prepare a fresh synthetic event/identity set for a new complete exercise.

## Account creation and lifecycle stage

New-ADUser can leave a disabled account if password setup fails. Inspect its exact identity, OU, profile and audit before deciding how to correct the lab state. Joiner intentionally rejects an existing disabled account instead of silently reactivating it.

AD operations are not transactional and the script has no durable event-processing ledger. Its repeat behavior is reconciliation at the current stage. Do not replay an old Joiner after a Mover or treat reactivation after Leaver as a normal retry.

[Day 07 results](day-07.md) · [Day 08 plan](day-08.md) · [Permission boundaries](permissions.md)
