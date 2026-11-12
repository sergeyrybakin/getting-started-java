# Фаза 6 — Telegram-уведомления (ветка lispublika, claude / Cline)

Дата: 2026-11-11

## Запрос пользователя

Реализовать Фазу 6 по `docs/plans/plan_phase6.md`: Telegram-уведомления о результатах
прогона; в коммит включить WIP от Фазы 5
(`docs/logs/phase5-lispublika-qwen3_8b-chat-history.md`) — файл уже в HEAD (коммит ac5ca16).

## Изменения

- `scripts/telegram-notify.sh` (new): парсит JUnit XML (директория `RESULTS_DIR`, по
  умолчанию `build/test-results/test`, те же атрибуты `testsuite`, что в `failOnEmptyTestRun`);
  состояния ALL_PASSED / HAS_FAILURES / ZERO_EXECUTED / NO_RESULTS / SKIPPED (нет секретов);
  сообщение содержит проект, CI, ветку, коммит, статус, passed/failed/skipped (всего N),
  ссылку на запуск; отправка POST `{TG_API_BASE}/bot{TG_BOT_TOKEN}/sendMessage` (curl,
  timeout 15s); проверка HTTP 2xx и `ok:true`; при ошибке — аннотация `::error::`;
  ВСЕГДА exit 0 (best-effort: не переворачивает статус job и не маскирует исходное падение).
- `scripts/telegram-notify.test.sh` (new): 9 сценариев / 35 проверок — fixtures + локальный
  mock (python3 `http.server`); mock повторяет схему реального API `/bot<TOKEN>/sendMessage`,
  сценарий выбирается токеном в URL (OK/BADOK/BADHTTP/NOPERM); контролируется, что токен
  НЕ в теле запроса и НЕ в stdout.
- `scripts/fixtures/*.xml` (new): all-pass.xml, all-pass-2.xml (агрегация двух файлов),
  with-failures.xml, all-skipped.xml.
- `.github/workflows/ui-tests.yml`: шаг «Notify to Telegram» в job `test` после артефактов —
  `if: always()` (уведомлять при любом исходе), `secrets.TG_BOT_TOKEN`/`secrets.TG_CHAT_ID` → env.
- `docs/plans/plan_phase6.md`: согласования, чекбоксы, статус «завершена».

## Проверки (локально, без реальной отправки)

- `bash scripts/telegram-notify.test.sh` → ИТОГ: PASS=35 FAIL=0, «ВЕСЬ НАБОР ПРОВЕРОК ПРОЙДЕН»
  (сценарии A–I: агрегация, падения, 0 выполнено, нет результатов, SKIPPED без секретов,
  HTTP 200+ok:false, HTTP 400, HTTP 403, отсутствие токена в теле и в stdout).
- Workflow: YAML валиден (pyyaml), jobs: test, pages; последний шаг job `test` — «Notify to Telegram».

## Осталось (требует действий пользователя)

- Задать в GitHub secrets: `TG_BOT_TOKEN`, `TG_CHAT_ID` — иначе отправка в CI будет SKIPPED.
- Реальная отправка — проверить по первому CI-прогону.
- Push без разрешения не выполнялся.

## Статус: завершено (2026-11-11) 533fb10


Completed

Push выполнен:

```
a731c23..d18c07e  lispublika -> lispublika
```

В `origin/lispublika` попали оба коммита Фазы 6:

- `533fb10` Фаза 6 — Telegram-уведомления (scripts, workflow)
- `d18c07e` Фаза 6 — лог сессии и статус плана: завершена

Локальная и удалённая ветка синхронизированы, рабочее дерево чистое.

Чего ожидать дальше:

1. __CI__: push в `lispublika` автоматически запустит workflow `ui-tests.yml` (Actions → UI Tests). Шаг «Notify to Telegram» отработает, но пока без секретов завершится `SKIPPED` (шаг успешный, на исход не влияет).
2. __Секреты__: задайте `TG_BOT_TOKEN` и `TG_CHAT_ID` (Settings → Secrets and variables → Actions, как описал выше) — тогда при следующем прогоне (push, PR или ручной Run workflow) придёт реальное сообщение в Telegram.
3. Проверить можно по-ручному: Actions → UI Tests → __Run workflow__ → ветка `lispublika` — прогон без новых коммитов.
