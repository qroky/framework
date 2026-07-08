---
atom: ATOM-091
product: kickoff sale kit — Startup Moldova (готов к действию рукой CEO в тот же день)
parent: ATOM-090 (pilot sale)
role: sales-operator (ROLE-009 — roles/sales-operator.md)
formulated_by: launch session, 2026-07-08
verification: blind (ATOM-091-VERIFY, L)
maturity_target: draft (reviewed после G2)
instantiation: subagent
model_tier: M (MT2; INFO-008 rule 1)
budget: ~180k tokens
recursion_allowance: 0
---

# ATOM-091 — Kickoff Sale Kit (Input Specification)

## 1. Mission
Превратить «согласны в принципе» (INFO-001, 05.07) в назначенный кикофф со
Startup Moldova и, далее, в двух названных фаундеров с подписанными
согласиями. Ты готовишь каждое касание периметра; отправляет и говорит CEO.

## 2. Files you may read (the law and the assets)
1. `decisions/INFO-001-pilot-terms-startup-moldova.md` — обмен + red lines (VERBATIM — цитировать, не пересказывать)
2. `decisions/INFO-010-signature-subject-principle.md` — предмет подписи
3. `decisions/GATE-022-atom-090-sale-go.md` — рамка задачи
4. `products/business-strategy-v1/STRATEGY.md` — позиционирование, сегменты, pricing ladder
5. `products/business-strategy-v1/pilot/pilot-design.md` — дизайн пилота (6 критериев, SLA)
6. `products/pilot-prerequisites-v1/072-telemetry-showcase/consent/CONSENT.ro.md` + `.ru.md` — подписанная CEO сделка-согласие (показывается на кикоффе)
7. `products/pilot-prerequisites-v1/071-setup-kit/setup/QUICKSTART.ro.md` — приложение «после да»
8. `roles/sales-operator.md` — твоя роль
9. `/Users/ghcernei/.claude/skills/style/style-profile.md` — голос CEO (заходы писать ИМ)
10. `/Users/ghcernei/Work/qroky-landing.html` — существует как ссылка-материал (не редактировать)

## 3. Deliverables (все в `products/pilot-sale-v1/091-sale-kit/kit/`)
1. `outreach.md` — заход к контакту Startup Moldova: 2 варианта (короткий
   мессенджер ≤120 слов; email ≤200 слов), каждый RU + RO, в голосе CEO по
   style-profile. Цель захода — ОДНО действие: дата кикоффа. Плейсхолдеры
   `[имя]`, `[канал]`, `[окна дат]` — заполняет CEO при отправке.
2. `kickoff-agenda.md` — агенда 30–45 мин: открытие (миссия, не механика) →
   живой показ (что именно открыть на экране: CONSENT.ro, лендинг, живой
   журнал решений) → сделка INFO-001 своими словами + red lines явно →
   следующее действие (имена 2 фаундеров + окно старта). Тайминг по блокам.
3. `talk-script.md` — скрипт разговора: ключевые формулировки (что говорим /
   чего НЕ говорим), ответ на «что вы просите взамен» (INFO-001 дословно),
   ответ на «сколько это стоит» (пилот бесплатный; ставка $/M — «уточняется»,
   не выдумывать цифру), 4 ветки возражений с ответами: «зачем нам это»,
   «а если фаундер недоволен», «что с данными фаундеров», «почему бесплатно —
   в чём подвох».
4. `signals.md` — бинарные наблюдаемые сигналы: что считается продвижением
   (дата в календаре ≤10 дней), продажей (2 названных фаундера + подписанные
   согласия), отказом, и какой сигнал = «переформулировать заход» (нет ответа
   7 дней → follow-up, один, тоже подготовить в этом файле).

## 4. Definition of Done
**Hard:**
- H1. Все 4 файла существуют, полны по §3.
- H2. Обмен и red lines — дословные цитаты INFO-001 (diff-проверяемо).
- H3. Заходы и агенда jargon-free: grep -iE "DoD|атом|atom|verify|INPUT|гейт|gate|tier" — ноль вхождений (пути/код исключаются).
- H4. Ни одного обещания сверх INFO-001/STRATEGY (ни цифр стоимости, ни сроков результата фаундера, ни гарантий).
- H5. Подпись упоминается только с явным предметом (INFO-010): согласие = сделка.
- H6. signals.md: каждый сигнал бинарен и наблюдаем извне (дата есть/нет, имена есть/нет).
**Soft:**
- S1. Заходы звучат как Ghenadie, а не как маркетинг (сверь тон со style-profile; финальный судья — CEO).
- S2. Kit достаточен для действия в тот же день без доработки.

## 5. Discipline
RESULT.md (карта поставки + самопроверка DoD), STATUS.md, workspace/run.log —
в твоей папке. status.yaml не трогать. Файлы — продукт, чат — сигнал.
