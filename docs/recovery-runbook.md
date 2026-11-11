# Recovery runbook

**Status** · Recovery handling implemented in Day 07 and exercised with simulated AD; live failure/retry evidence is planned for Day 08.

## Inspect before retrying

1. Record the run ID, event ID, configured DC, account and last confirmed step from the local CSV.
2. Read the current account and its direct managed memberships independently.
3. Run the original event without Apply to calculate a fresh plan.
4. Confirm that the event is still the intended lifecycle stage and review the remaining operations.
5. Apply that reviewed event, verify the resulting state and inspect the new audit.
6. Repeat at the completed current stage to check for NoChange.

Every write is preceded by an audit Started row and followed by a fresh read-back. Applied means that read-back passed. A Failed row can follow a write that partially succeeded; inspect current AD state rather than assuming a rollback.

The implementation re-reads current state and binds existing account and group objectGUIDs. Detected replacement, an ambiguous identity, an out-of-scope target or a protected/critical account stops execution. Never broaden the OU/group configuration to bypass a rejection.

## Controlled Mover exercise

Use only a fresh disposable lab identity that is currently in Finance. Review the normal Mover preview first.

~~~powershell
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-002' -Apply -SimulateFailureAfterRemoval
~~~

The exercise flag deliberately fails after the old managed membership has been successfully removed and audited. At that point Department is IT and the target has neither managed department membership. The Run ends Failed; the successful removal retains its Applied record.

~~~powershell
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-002'
.\scripts\Invoke-IamLifecycle.ps1 -EventId 'JML-002' -Apply
~~~

With that partial state, the expected fresh plan contains only AddGroupMember for IT. Do not pass the exercise flag on the retry. The offline checks establish this behavior on simulated AD; the live Day 08 exercise is pending.

## Account creation and lifecycle stage

New-ADUser can leave a disabled account if password setup fails. Inspect its exact identity, OU, profile and audit before deciding how to correct the lab state. Joiner intentionally rejects an existing disabled account instead of silently reactivating it.

AD operations are not transactional and the script has no durable event-processing ledger. Its repeat behavior is reconciliation at the current stage. Do not replay an old Joiner after a Mover or treat reactivation after Leaver as a normal retry.

[Day 07 results](day-07.md) · [Day 08 plan](day-08.md) · [Permission boundaries](permissions.md)
