---
gate: GATE-013
atom: ATOM-017
author: formulating agent (launch session) — never the gated executor (O8.2)
date: 2026-07-07
budget_spent: executor ~14k (BC4); verify round 1 — 123,722 real; round 2 ~25k (~, счётчик агента не доехал из-за стойла runtime — работа завершена по файловой шине)
budget_ahead: ~0 — закрытие (commit + push) и старт ATOM-018
---

# GATE BRIEF — GATE-013: приёмка ребрендинга (ATOM-017)

## Что изменилось — по-человечески

Публичное лицо репозитория теперь **Qroky**:
- Заголовки MANIFEST и README: **«Qroky — Recursive Product Framework»** — бренд первым, методология как подзаголовок (граница B2: «Recursive Product Framework» остаётся именем методологии, полное написание; аббревиатура «RPF» из брендовых позиций ушла всюду).
- Сноска «brand name is pending» и её якорь ¹ — сняты.
- Consent-текст пилота, стратегия и все живые аналитические документы — Qroky.
- README теперь прямо говорит: «Qroky is the product's brand name; the methodology it implements is the Recursive Product Framework».
- **История заморожена** (B3): решения, вердикты, atom-записи, закрытые launch-файлы, naming-verdict — нетронуты; там «RPF» остаётся как исторический факт.
- Remote подтверждён: `github.com/qroky/framework` (перенос — твоя рука).

## Verify

Round 1: **return** — слепой верификатор заблокировал из-за постороннего файла
`Handover1.md` в корне (H3 нарушен по букве; правильная строгость). Fix:
файл перенесён в `/Users/ghcernei/Work/rpf-Handover1.md` (вне репо; контент давно
поглощён записями INFO-004). Round 2: **accept, ноль findings** — no-drift
подтверждён, все 10 файлов перечитаны в раунде 1 без единой сломанной фразы.

## На твоё судейство — S3

*«Имя на витрине — моё»*: открой [MANIFEST.md](../../../MANIFEST.md) и [README.md](../../../README.md) — так ли должен выглядеть Qroky публично?

## Опции

| # | Опция | Trade-offs |
| :- | :---- | :---- |
| 1 | **Go — принять** | Витрина Qroky живая; цепочка идёт дальше: ATOM-018 (touch) → ATOM-007 |
| 2 | No-go | Откат свапа (git revert), имя возвращается в подвешенное состояние перед пилотом |
| 3 | Pivot | Точечные правки формулировок витрины (укажи какие) — round 3 verify |

## Рекомендация

**Опция 1 — Go.** Граница выдержана, история чиста, verify принял.

## Запрошенное решение
go / no-go / pivot — ответ записывается verbatim как GATE-013.
