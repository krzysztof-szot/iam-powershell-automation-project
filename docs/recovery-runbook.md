# Recovery runbook

**Status** · Planned procedure. Add recovery handling on Day 07 and validate it on Day 08.

1. Record the run ID, event ID, directory, target and last confirmed step.
2. Read the current account state and direct managed memberships.
3. Generate a fresh plan against the original approved event.
4. Review the proposed remaining changes before applying them.
5. Verify the final state and record the recovery result. Rerun once to check for a no-op.

Stop and investigate if the directory or target differs from the approved scope, authorization fails or a newer HR event supersedes the original request. Treat reactivation of an offboarded account as a separate approved operation.
