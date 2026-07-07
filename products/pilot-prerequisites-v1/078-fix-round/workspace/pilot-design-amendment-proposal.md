# Amendment proposal for `products/business-strategy-v1/pilot/pilot-design.md`

**Source:** ATOM-078 register #7 (E8-2 wiring) and, incidentally, #8 (E8-1
wiring) — both answered at `decisions/GATE-018-atom-007-synthesis-e8-gate.md`
but not yet folded into `pilot-design.md`'s own master text. This file is a
**proposal only** — `pilot-design.md` itself belongs to a different tree
(`business-strategy-v1`) and this atom's obligations explicitly forbid
editing it directly. CEO applies (or rejects/edits) this diff at G2.

Until this is applied, `CONSENT.ro.md` / `CONSENT.ru.md` (this atom's own
artifacts) already carry the GATE-018 answers in full — their own header
comments say so explicitly, so no founder-facing promise is missing in the
meantime. This proposal exists so the two documents converge instead of
drifting: once applied, `pilot-design.md` becomes the source CONSENT is
rendered from again, same as every other paragraph.

---

## Diff 1 — `## Operating cadence & SLA` (E8-2, register #7)

**Current text (pilot-design.md, lines 54–59):**

```
## Operating cadence & SLA

- **Daily** owner review of each founder's flows (deliberately daily — accepted §3.4).
- Sentinel atoms draft interventions; **a human approves/sends every intervention** — nothing reaches a founder unreviewed.
- **SLA: reaction to any `blocked` state within one business day** (accepted §3.4 verbatim).
- Every intervention and its minutes logged — the human-hours ledger is a first-class pilot output (feeds Rung-2 pricing).
```

**Proposed replacement:**

```
## Operating cadence & SLA

- **Daily** owner review of each founder's flows (deliberately daily — accepted §3.4).
- Sentinel atoms draft interventions; **a human approves/sends every intervention** — nothing reaches a founder unreviewed.
- **SLA: reaction to any `blocked` state within one business day** (accepted §3.4 verbatim).
- **Owner primary-duty commitment (GATE-018, E8-2):** running the pilot at 2
  concurrent founders is conditioned on this pilot being the owner's
  **primary daily duty for its 8-week active-support window** — not work
  fit around other concurrent duties. This is a written commitment, not an
  aspiration; owner-capacity lens finding 076-F2 is the arithmetic basis
  (50–77 min/day baseline at 2 founders, 80–107 min/day on a 3-blocker day).
- **SLA-breach protocol (GATE-018, E8-2):** if the SLA above is missed on 2
  of any 5 consecutive business days, this **automatically** triggers a
  pause and a renegotiation — either the SLA relaxes (e.g. to 2 business
  days) or the cohort reduces to 1 founder. This is not a silent failure
  path; both the founder(s) and Startup Moldova are notified when the
  breach protocol fires.
- Every intervention and its minutes logged — the human-hours ledger is a
  first-class pilot output (feeds Rung-2 pricing).
- **Audit automation (076-F1, register #12):** honesty checks on the
  cost-line and TEAM-summary renders (jargon-free, fields present) run
  automatically (`showcase/render.sh --audit`); the owner reviews the
  aggregate weekly rather than spot-checking every render manually. This
  removes ~15–20% of the daily load 076-F2's arithmetic assumed, per
  GATE-018's own recommendation.
```

**Why:** GATE-018 answered E8-2 verbatim as **"2 фаундера + primary-duty
(Recommended)"** — the synthesis's own recommended resolution (SYNTHESIS.md
E8-2 block), now a decided value gate, not an open question. The current
`pilot-design.md` text states the SLA but names no owner-availability
condition and no breach protocol — both of which the register (item 7)
requires wired in, in this exact spot, since it is the SLA's own home
document.

## Diff 2 — `## Telemetry & consent` (E8-1, register #8 — for completeness)

**Current text (pilot-design.md, line 42, "Scope" bullet) says:** telemetry
is a closed list of operational files, no business content, script is open.
Silent on the TEAM-summary showcase artifact entirely (`showcase/render.sh`
did not exist yet when this section was written).

**Proposed addition**, appended after the existing "Scope" paragraph:

```
**TEAM-summary visibility across the perimeter (GATE-018, E8-1):** the
work-showcase's TEAM summary (`showcase/render.sh`) is **local-only by
default** — it never crosses the perimeter to Startup Moldova. A founder
may separately opt in, via one explicit consent item independent of the
telemetry consent above, to let **one plain sentence** describing what was
built cross the perimeter. Absent that separate opt-in, only role names and
independent-check counts — never content — may ever be shown externally.
```

**Why:** this is GATE-018's recorded E8-1 answer ("Opt-in в consent
(Recommended)"), already implemented in this atom's own artifacts
(`showcase/render.sh --external`, `CONSENT.ro.md`/`CONSENT.ru.md`'s separate
opt-in checkbox) — proposed here purely so `pilot-design.md` stops being
silent on a design decision its own downstream artifacts already carry.

---

## What CEO needs to do with this file

Nothing is applied automatically. At G2 (or sooner, at CEO's discretion):
review both diffs, edit wording as wanted, paste into `pilot-design.md`
directly (that edit is CEO's or a `business-strategy-v1`-tree atom's to
make — outside this atom's own folder). Once applied, this proposal file
can be marked superseded; `CONSENT.ro.md`/`CONSENT.ru.md`'s header comments
already point here so the gap is traceable in the meantime.

## Provenance
| Event | Atom | Date |
| :---- | :---- | :---- |
| Created (E8-2 wiring, register #7; E8-1 wiring noted, register #8) | ATOM-078 | 2026-07-07 |
