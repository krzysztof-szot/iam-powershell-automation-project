# Day 03 — Active Directory groups and effective access tests

**Status** · Five recorded result checks passed  
Record updated 2026-11-11.

[Lab record](../docs/day-03.md) · [Screenshots](../evidence/day-03/README.md) · [Membership example](../scripts/day-03-group-memberships.ps1)

The owner performed the lab actions. PASS applies to the observations described below.

| ID | Procedure | Expected | Actual | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| D03-01 | Inspect SMB and NTFS permissions for both dedicated shares | Each department group has read access to its intended share and folder. | SMB department groups have Read, Domain Admins has Full. NTFS department groups have ReadAndExecute and Synchronize, SYSTEM and Administrators have FullControl. All shown entries are Allow. | PASS | [01](../evidence/day-03/01-smb-share-permissions.png) |
| D03-02 | Read the Finance proof file as iam.gui01 before transfer | The Finance read succeeds under the test identity. | whoami=bfl\\iam.gui01, Finance proof.txt returns FINANCE - access test successful. | PASS | [02](../evidence/day-03/02-finance-baseline-allowed.png) |
| D03-03 | Remove Finance membership, add IT membership and read the lab-group view again | Finance is replaced by IT in the filtered membership results. | BEFORE shows GG-IAM-LAB-Finance. The change commands complete, and AFTER shows GG-IAM-LAB-IT. | PASS | [03](../evidence/day-03/03-memberships-before-after.png) |
| D03-04 | Retest Finance and IT from the client after the instructed session refresh | Finance denies the read and IT allows it under the same test identity. | Both captures show bfl\\iam.gui01. Finance returns Access is denied, while IT returns IT - access test successful. | PASS | [04](../evidence/day-03/04-finance-access-denied.png), [05](../evidence/day-03/05-it-access-allowed.png) |
| D03-05 | Disable and re-enable the separate iam.ps01 account with read-back between operations | Enabled changes from True to False and back to True. | The three reads show True, False and True for iam.ps01. | PASS | [06](../evidence/day-03/06-account-enabled-state.png) |

## Additional authorization observation

Before the successful administrative transfer, the owner supplied console output showing both group writes denied for `bfl\iam.gui01` with `ActiveDirectoryServer:8344`. The final query in that transcript still showed Finance membership. This records the observed authorization boundary in that session. [Console excerpts](../evidence/day-03/console-excerpts.md)

## Evidence coverage

The access screenshots record the acting identity, UNC path and returned content or denial. The session refresh follows the guided procedure. The account-state exercise records the Enabled flag at three points. The saved membership report was reviewed and syntax-checked separately. [Script](../scripts/day-03-group-memberships.ps1)
