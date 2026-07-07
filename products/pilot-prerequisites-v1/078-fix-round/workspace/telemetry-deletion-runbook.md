# Telemetry deletion runbook — Flow Support v0 (interim, pre-production)

**Source:** ATOM-078 register #5 (075-F2: "deletion-on-revocation is a paper
promise with zero enforcing lines"). Referenced from `telemetry/push.sh`'s
header and from `CONSENT.ro.md` / `CONSENT.ru.md`'s deletion paragraph.
**Status:** interim, human-executed. Applies only while
`telemetry/push.sh`'s `push_to_remote()` remains a stub (no real network
call, no real `qroky/pilot-telemetry` remote exists yet). Once
`push_to_remote()` is wired to a real remote (ATOM-071 setup kit,
production build), the automated part of this runbook (steps 2–3) should be
replaced by real code that executes the delete directly — this file should
be revisited at that point, not kept as permanent process.

## What is already automated (code, not this runbook)

`push.sh` already, in this build:
- detects the two triggers — the fixed deletion date (`telemetry/DELETE-BY`)
  being reached, and a revocation (an `OFF` file appearing after telemetry
  had sent something at least once, tracked via `telemetry/.ever-sent`);
- on either trigger, writes a dated, auditable line to
  `telemetry/deletion-requests.log` inside the founder's own workspace,
  naming the trigger and the action still needed;
- on the date trigger, also switches telemetry `OFF` automatically, so no
  further data is sent after the deletion date.

Verified by `telemetry/negative-test.sh` TEST 4 (revocation logs a request)
— re-run as part of this fix-round, green.

## What is NOT yet automated — this runbook's job

Nothing in this build actually deletes previously-sent copies at the real
remote, because there is no real remote to delete from yet (`push_to_remote()`
is a stub — see `push.sh`'s own header). Until that changes, a human on the
Flow Support team must execute the removal by hand, following these steps,
whenever real production telemetry (post-ATOM-071-production-wiring) has
actually been pushed for a founder and a deletion trigger fires.

1. **Find the trigger.** Check the founder's own
   `telemetry/deletion-requests.log` (the founder can also just tell you —
   it is their own file, in their own workspace, and the consent text tells
   them how to read it). Note the timestamp and reason logged there.
2. **Locate what was actually sent.** In the real `qroky/pilot-telemetry`
   remote, find every commit/object attributable to this founder's
   workspace (path or branch naming convention to be fixed when the real
   remote is stood up — out of this atom's scope, since the remote does not
   exist yet).
3. **Delete it, and record that you did.** Remove the founder's data at the
   remote (history rewrite or object deletion, per whatever the real
   remote's tooling supports). Append one line to a Flow-Support-team-owned
   deletion ledger (location TBD when the remote exists): date, founder,
   trigger reason (cross-referenced to the founder's own
   `deletion-requests.log` entry), who executed the removal.
4. **Confirm to the founder.** One short message: "Your telemetry data has
   been removed from our side as of [date], per your [request /
   the deletion date reached]." Matches the consent text's promise that
   revocation "triggers deletion", made concrete and auditable.

## Open item for CEO confirmation at G2 (per the register)

Whether this human-executed runbook is acceptable as the **permanent**
mechanism, or whether real deletion code must be written before the pilot's
telemetry is switched from dry-run to production — flagged in `CONSENT.ro.md`
/ `CONSENT.ru.md`'s deletion paragraph as "вариант, отмеченный для
подтверждения CEO на G2" ("variant flagged for CEO confirmation at G2").

## Provenance
| Event | Atom | Date |
| :---- | :---- | :---- |
| Created (register #5 — deletion mechanics, human-executed half) | ATOM-078 | 2026-07-07 |
