---
id: INFO-005
date: 2026-07-07
kind: information
status: answered
atom: ATOM-016
trigger: E1
answered_by: Ghenadie (human)
recorded_by: formulating agent (launch session)
---

# INFO-005 — D7 completed: transitive subtree accounting (closes the INFO-004 recorded gap)

## Question / Brief

INFO-004 recorded a gap: decision item (в)/D7 ("subtree-отчётность в cost-блоке —
см. ниже") referenced detail that was never transmitted. ATOM-016 executed on the
accepted minimal interpretation (per-lens subtree lines in fan parents' cost
blocks — codified as LF7) and judged E1 not fired. The human was asked to supply
the missing detail if and when it existed.

## Answer (verbatim)

> D7, недостающая детализация subtree-отчётности (ответ на recorded gap INFO-004): в frontmatter RESULT каждого атома-родителя — три транзитивных числа по всему поддереву, не только прямым детям: total_descendants (все порождённые атомы всех уровней), max_depth_reached, subtree_cost (суммарные токены + wall time поддерева, включая собственные). Механика дешёвая: каждый уровень складывает то, что уже отчитали дети (O4.2 расширяется транзитивно). Обязательная разбивка по типам атомов: execute / verify / role-creation / synthesis — чтобы governance-накладные не смешивались с «мышлением» и диагноз раздутого поддерева был точным. Назначение: цена инсайта как метрика (сопоставимые продукты с разным весом поддерева = сигнал кривой формулировки), калибровка Formulate по прецедентам классов деревьев, строка себестоимости для клиента («ваш вопрос стоил 6 агентов, $2.1»).

English summary (HP3): The `RESULT.md` frontmatter of **every parent atom** must
carry three transitive subtree numbers — `total_descendants` (all spawned atoms at
all levels, not only direct children), `max_depth_reached`, and `subtree_cost`
(aggregate tokens + wall time of the subtree, own consumption included). Mechanics
are cheap: each level sums what its children already reported (O4.2 extended
transitively). A breakdown by atom type is mandatory — `execute` / `verify` /
`role-creation` / `synthesis` — so governance overhead is never conflated with
"thinking" and a bloated subtree is precisely diagnosable. Purpose: cost-of-insight
as a metric (comparable products with different subtree weight signal a crooked
formulation), Formulate calibration by tree-class precedents, and a cost line for
the client ("your question cost 6 agents, $2.1").

## Consequences

- The INFO-004 recorded gap is closed. LF7 (the minimal interpretation) stands as
  codified and is **not reopened** — ATOM-016 is accepted (GATE-011, DR7/VP19
  discipline).
- The full D7 exceeds LF7's scope: it extends O4.2 and the ATOM-SPEC §6.2
  `RESULT.md` template (new frontmatter fields + type breakdown) for every parent
  atom, and re-aligns LF7 with the transitive scheme. Normative home: the **queued
  constitutional touch** (next touch of ATOM-SPEC; SYNTHESIS-PROTOCOL's LF7
  alignment at its next touch) — per the HP4/GB5 migration discipline, no accepted
  document is edited outside a touch atom.
- Until the touch lands: T1 permits template extension, so parent atoms MAY carry
  the three fields and the type breakdown voluntarily; the MUST arrives with the
  touch.

## Fed back to

- `TASKS.md` — constitutional-touch queue row extended with the full D7 item.
- `decisions/INFO-004-perspective-protocol-design-answers.md` — *Fed back to*
  updated to reference this record (the DR6-mutable section only).
- Memory (`project_rpf-atom-016.md`) — gap marked closed via INFO-005.
