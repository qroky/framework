---
atom: ATOM-007
delivered: 2026-07-07
total_descendants: 18
max_depth_reached: 1
subtree_cost: ~2,123,000 tokens real (children 1,982,936 by EC6 counters + parent orchestration ~140k BC4; pre-closure snapshot — parent verify + gate/closure costs added at final closure line, per 007-VERIFY M2)
subtree_cost_breakdown:
  execute: 1117974          # 4 builds (624,036) + 4 lens atoms (493,938)
  verify: 466204            # 4 blind slim verifies, all accept round 1
  role_creation: 267420     # ROLE-004..008
  synthesis: 131338         # ATOM-007-SYNTH
tier_shares:                # INFO-008 rule 4 — routing health
  L: ~35%                   # verifies + synthesis + parent orchestration (fable)
  M: ~44%                   # builds + judgment lenses (sonnet)
  S: ~21%                   # roles + arithmetic lenses (haiku)
verify_returns_total: 0     # every blind verify accepted round 1
---

# RESULT — ATOM-007 (Pilot Prerequisites v1)

## Product

The tree under `products/pilot-prerequisites-v1/` — all five §4 deliverables:
1. **Setup kit + tiers** — `071-setup-kit/setup/` (bootstrap, QUICKSTART RO/RU,
   TIERS RO/RU, timed dry-run ≤15 min) — blind-accept r1 + fix-round re-verified.
2. **Execution tiers** — inside №1 (TIERS.ro/ru.md).
3. **Telemetry + consent** — `072-telemetry-showcase/telemetry/` + `consent/`
   (whitelist = closed list with negative test; consent RO/RU with opt-in item,
   primary-duty + 2-of-5 breach protocol per GATE-018) — blind-accept r1 ×2.
4. **Intake protocol** — `077-intake-protocol/intake/` (mission-first guide,
   templates RO/RU, derivation method, field-test lessons verbatim) —
   blind-accept r1.
5. **Work showcase (three artifacts per INFO-006/007/009)** —
   `072-telemetry-showcase/showcase/`: cost-line spec, TEAM-summary spec,
   narrative spec + render with worked examples from this repo's real records.

## DoD self-check

| Criterion | Verdict | Evidence |
| :---- | :---- | :---- |
| H1 deliverables at plan paths + map + OD4 | PASS | PLAN.md (map §1, OD4, Addendum 2); ls per tree above |
| H2 dry-run ≤15 min, zero tech questions | PASS | 071 transcript; re-run green at 078-VERIFY H6 (regression) |
| H3 whitelist == closed list + negative test | PASS | 072-VERIFY H2; 078-VERIFY H6 regression re-run |
| H4 consent RO/RU == master substance | PASS | 072-VERIFY H3; E8 wiring re-verified verbatim at 078-VERIFY H4 |
| H5 showcase specs from named fields + worked examples | PASS | 072-VERIFY H4/H5; narrative spec 078-VERIFY H5 |
| H6 SYNTHESIS.md per §6.2 + FB4/D7 in this RESULT | PASS | 007-synth/SYNTHESIS.md (SY9 coverage, X-classification); frontmatter above |
| S1 machinery hidden (jargon zero-hit) | PASS (verify) | 071V S1, 077V S2, 078V H3 — final judge: human at G2 |
| S2 goals derived from values | PASS (verify) | 077-VERIFY S1 — the guide passes its own disguised-task-list test |
| S3 cost line honest | PASS (verify) | checkstop on placeholder rate landed (register №1); contract rate = G2 input |
| S4 lenses produced named contradictions | PASS (verify) | 2 value conflicts (E8-1/E8-2, answered GATE-018) + per-lens SY9 records |
| S5 «я бы подписал как фаундер» | **human** | G2 — this gate |

## Semantic fold-back (FB4 — what each axis returned to the whole)

**Size axis (children → parent):** the builds returned not files but three
corrections to the parent's picture: (1) the 15-minute promise is real but was
underspecified at step 0 (fixed); (2) telemetry-as-promised and
telemetry-as-code diverged in four places — consent language is now generated
from what the code does, not vice versa; (3) the true cost of rigor
(~2.1M tokens for prerequisites) is itself pilot pricing data, recorded as
precedent (`subagent-fixed-overhead.md`).

**Perspective axis (fan → parent):** the four lenses changed the product's
shape, not just its polish: the UX lens forced consent into plain language
(register №2); the economics lens killed the flattering $8/M placeholder
(№1); the security lens caught the render reading the one file the telemetry
canon forbids (№8 → E8-1); the capacity lens overturned the plan's implicit
«owner will cope» into a written primary-duty commitment + breach protocol
(E8-2). Neither axis alone would have produced conditions 7 or 8 — the fan
earned its cost.

**SYNTHESIS-PROTOCOL maturity:** first real fan consumed end-to-end
(map → 4 lenses → SY6 fact/value split → E8 gate answered → register consumed
by two downstream atoms). Per M3, `framework/SYNTHESIS-PROTOCOL.md` is
recorded **`reviewed` → `validated`** by this atom's closure.

## Первая живая TEAM-сводка (INFO-007 self-application, per team-summary-spec)

**Кто работал (7 ролей, 18 агентов):**
- *framework-architect* — создал 5 новых ролей; провёл 4 слепые проверки, все приняты с первого раунда;
- *pilot-toolsmith* — построил setup-кит (≤15 мин подтверждено таймером), телеметрию с открытым скриптом и витрину; затем сам прошёл по реестру из 22 правок;
- *venture-strategist* — вёл синтез веера и написал гайд первого разговора (mission-first);
- *четыре линзовых ревьюера* — UX фаундера, токен-экономика, безопасность, ёмкость владельца — смотрели на одно и то же разными глазами.

**Где спорили и как решилось:** линза UX требовала прятать механику, линза
безопасности — показывать каждое имя файла в согласии; синтез не стал
сглаживать — вынес CEO, тот выбрал: по умолчанию сводка остаётся у фаундера,
делиться фразой «что построено» — его личный явный выбор при подписании.
Линза ёмкости сказала «нет» всему плану (владельцу не хватит дня); CEO выбрал
держать двух фаундеров, но с письменным обязательством primary-duty и
протоколом паузы при двух срывах SLA за пять дней.

**Возвраты проверок:** 0 — все четыре слепые проверки приняли работу с первого раунда.

**Итог:** пререквизиты пилота готовы к подписи фаундера — ждут последнего
человеческого «я бы подписал» (G2).

⚙ 18 агентов · 7 ролей · глубина 1 · возвратов verify 0 · ~$17 *(ставка-заглушка $8/M; контрактная ставка — вход G2, до неё цифра не показывается фаундеру — реестр №1)*

## Residual (queued, non-blocking)

- 5 minor findings of 078-VERIFY (M1–M5: swapped A/B labels in RESULT table
  row №3; №5 variant flagged descriptively; opt-in marker base divergence;
  dead `pct` var; record numbers in debrief rows) — fix-list attachment at G2.
- Minor findings of earlier verifies absorbed by the register or queued in
  their VERDICTs.
- pilot-design.md amendment (E8-2 protocol) — proposal at
  `078-fix-round/workspace/pilot-design-amendment-proposal.md`, CEO applies at G2.
- Contract $/M rate — written CEO input at G2 (checkstop active until then).
