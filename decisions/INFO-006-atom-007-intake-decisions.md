---
id: INFO-006
date: 2026-07-07
kind: information
status: answered
atom: ATOM-007
trigger: E1
answered_by: Ghenadie (human)
recorded_by: formulating agent (launch session)
---

# INFO-006 — CEO decisions for ATOM-007: mission-first intake, starting lenses, cost-line showcase, field-test reservation, setup minimum

## Question / Brief

ATOM-007 (pilot prerequisites) was queued with composition fixed by ATOM-006 INPUT
§3.4 and `products/business-strategy-v1/pilot/pilot-design.md`. Before formulation
the human supplied additional accepted decisions to embed in the INPUT §3.

## Answer (verbatim)

> Дополнение к контексту ATOM-007 (пререквизиты пилота) — вложить в INPUT до формулирования, это принятые решения CEO:
>
> Intake начинается с ценностей и миссии, не с задач. Первый продукт onboarding-разговора — mission.md фаундера: ценности-ограничения («минимум ухода», «не отдам 30% equity»), миссия без метрик, периметр недопустимого. Цели и первые продукты-ветки выводятся из них. Фаундер видит разговор — не механику: DoD/атомы/verify работают внутри, не показываются и не объясняются.
> Стартовые линзы веера 007 (карта перспектив получает вход, не изобретает): UX нетехнического фаундера / токен-экономика / безопасность+телеметрия / операционная ёмкость владельца (Flow Support).
> Витрина работы — в каждый ответ фаундеру и в телеметрию с первого дня: итоговая строка вида «⚙ N агентов · M ролей · глубина D · возвратов verify R · $X» (данные из subtree-учёта INFO-005/D7). Строка себестоимости — продающий артефакт, Startup Moldova должна видеть её с первого дня.
> Intake-атом дерева — последним по зависимостям: в его INPUT зарезервировать секцию «уроки полевого теста» — сейчас идёт живой сад-тест copilot-паттерна (нечёткая формулировка → сначала ожидаемый результат → проработка), вердикт CEO с находками в течение 1–2 дней; уже зафиксированная находка для intake: as-is инвентаризация обязательна для трансформационных задач (опись существующего + explicit preserve/change/remove до проектирования to-be).
> Setup-минимум: от «фаундер сказал да» до первого атома ≤15 минут, ноль технических вопросов; телеметрия — whitelist операционных файлов в qroky/pilot-telemetry, скрипт открытый, отключаемо с датой.
>
> Если 007 уже сформулирован — оформи это уточнением INPUT с логом изменения; если в очереди — просто вложи в §3. План — мне на го до исполнения.

English summary (HP3): (P1) **Mission-first intake** — the onboarding
conversation's first product is the founder's `mission.md`: value-constraints
("minimal supervision", "won't give up 30% equity"), a mission without metrics,
and a perimeter of the unacceptable; goals and first product branches are derived
from it. The founder sees a conversation, never the machinery — DoD/atoms/verify
work inside and are neither shown nor explained. (P2) **Starting lenses** for the
007 fan (the perspective map receives input, it does not invent): non-technical
founder UX / token economics / security+telemetry / owner operational capacity
(Flow Support). (P3) **Showcase cost line** in every founder-facing reply and in
telemetry from day one: "⚙ N agents · M roles · depth D · verify returns R · $X",
sourced from INFO-005/D7 subtree accounting — a selling artifact Startup Moldova
must see from day one. (P4) The **intake atom is last** in dependency order; its
INPUT reserves a "field-test lessons" section — a live garden-test of the copilot
pattern (fuzzy request → expected result first → elaboration) is running, CEO
verdict with findings due within 1–2 days; one finding already fixed: **as-is
inventory is mandatory for transformational tasks** (inventory of the existing +
explicit preserve/change/remove before designing to-be). (P5) **Setup minimum**:
from "founder said yes" to the first atom in ≤15 minutes, zero technical
questions; telemetry = whitelist of operational files pushed to
`qroky/pilot-telemetry`, open script, deactivatable with a fixed date. Routing:
007 was still queued → embed in INPUT §3; the decomposition plan goes to the human
for go before execution.

## Consequences

- ATOM-007 formulated: `ATOM-007-LAUNCH.md` with P1–P5 in INPUT §3; gate G1 placed
  = decomposition plan + perspective map to the human (Russian, plain language)
  before execution.
- The 007 fan becomes the first real lens fan — the validation path for
  SYNTHESIS-PROTOCOL (`reviewed` → `validated`).
- The intake atom's INPUT carries the reserved "уроки полевого теста" section; if
  the garden-test verdict has not arrived when that atom is reached, it waits
  (E1), without blocking the rest of the tree.

## Fed back to

`ATOM-007-LAUNCH.md` INPUT §3 (P1–P5); `TASKS.md` queue row. Role specs: lens
roles will be created on demand at execution (F2).
