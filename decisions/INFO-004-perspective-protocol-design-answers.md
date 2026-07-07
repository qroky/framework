---
id: INFO-004
date: 2026-07-06
kind: information
status: answered
atom: ATOM-016
trigger: E1
answered_by: Ghenadie (human)
recorded_by: external advisor session (framework audit, 2026-07-06)
---

# INFO-004 — Design answers for the perspective axis (ATOM-016: SYNTHESIS-PROTOCOL)

## Question / Brief

Context: an external audit session (2026-07-06) diagnosed that the framework recurses
by **product size only** (A4/K4): the atom formula binds exactly one role per atom
(ATOM-SPEC §1.1); there is no obligation to examine one question through several
role-lenses; no protocol for integrating divergent views (FEV-PROTOCOL has no twin
for synthesis); and fold-back lifts only accounting — status (SS3), cost (O4.2),
maturity (M3) — never meaning. Evidence: in business-strategy-v1 the two derived
roles (venture-strategist, market-analyst) never examined the same object; no
cross-lens conflict ever arose or was reconciled.

Before formulating the corrective atom, four design questions were put to the human
(audit handover §7):

1. **Threshold.** Is the perspective map mandatory for all atoms or only above some
   scale/type? (Cost concern: four roles on every small atom drowns the budget.)
2. **Synthesis authority.** Is an unresolved lens conflict always a human gate, or
   may synthesis decide below some threshold (analogous to the F3 risk mapping)?
3. **Fan budget.** How does the envelope cascade over N lenses of one question —
   equal shares, weighted, or map-assigned?
4. **Lens depth.** May a lens recursively open sub-lenses (Finance →
   treasury/FP&A/risk), and does that count against recursion_allowance (F6)?

## Answer (verbatim)

> Ответы на дизайн-вопросы Handover1, фиксируй как принятые решения и формулируй ATOM-016:
> Порог: карта перспектив обязательна широко (opt-out строкой «одна линза — вопрос узкий», логируемо как F3-отклонение); веер исполнения — селективно: обязателен при декомпозиционном плане (OD1), зрелости ≥ reviewed или пересечении периметра.
> Полномочия синтеза: факты примиряет синтез (с логом), ценности примиряет человек (всегда гейт). Природа конфликта, не сумма.
> Бюджет веера: линзы = сиблинги в конверте родителя (O6.1), веса назначает карта (дефолт поровну, min-конверт на линзу); линзы можно S/M-tier, синтез — всегда L.
> Глубина линз: под-линзы разрешены в той же валюте глубины (против recursion_allowance F6); дефолт веера плоский, раскрытие — с логируемым обоснованием.
> Плюс в INPUT: (а) правило смыслового fold-back — для обеих осей (родитель обязан интегрировать детей и в моно-ролевой декомпозиции); (б) prior art — скилл /council: извлечь механику столкновения взглядов и CEO-синтеза; (в) subtree-отчётность в cost-блоке — см. ниже.

English summary (HP3): (D1) The perspective **map** is mandatory broadly, with a
one-line opt-out ("single lens — narrow question") logged as an F3-style deviation;
the execution **fan** is selective — mandatory when a decomposition plan exists
(OD1), maturity target ≥ `reviewed`, or the product crosses the perimeter.
(D2) Synthesis reconciles conflicts of **fact** itself, with a logged reconciliation;
conflicts of **value** always gate to the human. Classification by the *nature* of
the conflict, not its magnitude. (D3) Lens atoms are siblings inside the parent's
envelope (O6.1); the map assigns weights (default equal; minimum envelope per lens);
lenses may run at tier S/M; synthesis always runs at tier L. (D4) Sub-lenses are
permitted in the same depth currency (charged against recursion_allowance, F6);
the default fan is flat; opening lens depth requires a logged justification.
Additionally for the INPUT: (a) a semantic fold-back rule covering **both axes** —
the parent must integrate its children's products into its own view even in
mono-role decomposition; (b) prior art: the human's council mechanism (multi-role
clash + chaired synthesis) — extract its mechanics; (c) per-subtree reporting in the
cost block.

**Recorded gap:** item (в)/(c) ends with "см. ниже" ("see below") but no further
content was transmitted. Minimal interpretation accepted by the recorder: cost
blocks of fan parents report **per-lens subtree lines**, extending the O4.2
aggregation. If this under-determines a rule, the ATOM-016 executor raises E1
(one consolidated question set) rather than inventing the detail.

## Consequences

ATOM-016 is formulated: launch file `ATOM-016-LAUNCH.md` at the repository root
(NC6), atom folder `products/framework-v1/016-synthesis-protocol/` to be
materialized at step 0 (LP3). Decisions D1–D7 enter its INPUT §3 as accepted
decisions (formalize, do not reopen). Ordering relative to the rebrand swap and
the queued constitutional touch remains a human decision (TASKS §2).

## Fed back to

`ATOM-016-LAUNCH.md` INPUT §3 (decisions D1–D7); `TASKS.md` queue. Role specs: none
yet — the protocol itself will fix where lens-role derivation lands.
**Update 2026-07-07 (DR6):** the recorded D7 gap ("см. ниже" detail) is closed by
`decisions/INFO-005-d7-subtree-accounting-detail.md` — transitive subtree
accounting (total_descendants / max_depth_reached / subtree_cost + type breakdown),
routed to the constitutional touch.
