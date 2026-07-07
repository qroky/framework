---
id: INFO-008
date: 2026-07-07
kind: info
status: recorded
source: Ghenadie (human) — CEO directive, mid-ATOM-007
recorded_by: formulating agent (launch session)
---

# INFO-008 — Model-routing автономия

## Statement (verbatim)

> Model-routing автономия (в глобальный skill «кроки» + runtime binding,
> кандидат в touch-очередь): (1) порождение любого ребёнка/суб-агента — только
> с явным model_tier по MT-таблице; дефолт исполнения M, S для механики, L
> строго для Formulate/Verify/Synthesis; выбор логируется в run.log с классом
> работы; (2) в интерактивной сессии агент оценивает класс текущей работы
> против модели сессии и при несоответствии ставит человеку однострочную
> задачу переключения («работа M-класса, ты на L — /model sonnet, экономия
> ~N%»); (3) предохранители: Verify ниже L — только по записанному решению
> CEO; после 2 возвратов verify — автоэскалация tier'а исполнителя; (4) в
> subtree-отчётность добавить распад стоимости по tier'ам (L/M/S доли) —
> метрика здоровья маршрутизации.

## Interpretation (English, HP3)

Four routing rules, effective immediately at the operational layer (global
qroky skill + runtime binding), with constitutional codification queued:
1. **Explicit tier on every spawn** — no child/subagent without a `model_tier`
   assigned from the MT table; defaults: M for execution, S for mechanics, L
   strictly for Formulate/Verify/Synthesis; every choice logged in run.log
   with its work class.
2. **Session-model mismatch prompt** — in an interactive session the agent
   continuously classifies its current work against the session's model and,
   on mismatch, hands the human a one-line switch task with the estimated
   saving.
3. **Safeguards** — Verify below tier L only by a recorded CEO decision;
   after 2 verify returns of the same atom, the executor tier auto-escalates.
4. **Tier-share metric** — subtree accounting (O4.3) gains an L/M/S cost
   breakdown: the routing-health metric.

## Application (immediate)

- `~/.claude/skills/qroky/SKILL.md` — new §8 Model routing (machine-wide).
- `runtime/claude/README.md` §3 — routing-autonomy rules added (operator-facing
  binding; MT-table home), provenance note to this record.
- TASKS.md touch-queue: MT-space amendments (routing defaults + safeguards)
  and the O4.3 tier-share extension.
- ATOM-007 run.log: retro-attestation — Wave 0 spawns (S=haiku), Wave 1
  (M=sonnet), orchestrator/Formulate (L=Fable) already comply; per-spawn work
  class logged from now on.
- Session self-check per rule 2 at the time of recording: current work =
  Formulate / gate authoring / synthesis prep = L-class on an L session — no
  mismatch, no switch task.

## Fed back to

Global skill; runtime binding; TASKS.md; ATOM-007 run.log; memory.
