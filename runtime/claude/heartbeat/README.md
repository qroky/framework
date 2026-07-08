# Qroky heartbeat (runtime/claude)

Ежедневный пульс проекта: будни 09:07, read-only скан → уведомление CEO
только если есть действия его уровня. Паттерн: `_BUSOS/tools/hermes-24x7`.

- `heartbeat-prompt.md` — что сканирует и правило честности («скажи, если не знаешь»)
- `heartbeat.sh` — удар: скан через `claude -p` (только Read/Glob/Grep + ls/head/tail/git log), запись в `heartbeat.log`, osascript-уведомление при `ACTION:`
- `launchd/md.qroky.heartbeat.plist` — расписание (Mon–Fri 09:07, `__HOME__` подставляет installer)
- `install.sh` / `uninstall.sh` — идемпотентно

## Dead-man правило (для человека)
Тишина пинга ≠ тишина сторожа. Сторож ЖИВ, если в `heartbeat.log` есть
сегодняшняя строка `START…END`. Если в будний день к 10:00 нет ни
уведомления, ни строки в логе — сторож умер: `bash install.sh` заново или
`launchctl list | grep qroky`.

## Ограничения v0 (честно)
- Живёт на этом Mac: ноут спит/выключен в 09:07 — удара нет (launchd
  StartCalendarInterval догоняет пропуск после пробуждения в тот же день).
- Перенос на 24×7 Гермес (192.168.100.240): скопировать бандл, склонировать
  qroky/framework, `bash install.sh` — дизайн совместим.
- `out/` и `heartbeat.log` — локальные, в git не идут (.gitignore).
