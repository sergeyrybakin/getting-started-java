### Фаза 6 — Telegram-уведомления

Цель: информативное сообщение о результатах прогона.

Статус: завершена (2026-11-11, код: 533fb10)

### Перед реализацией согласовать

- [x] Уведомления — из GitHub Actions, для любого исхода: все прошли / есть падения /
  0 тестов / сбой сборки до тестов (шаг `if: always()`). Jenkins: пайплайна в репозитории нет —
  скрипт CI-агностичен (все параметры через env), подключается аналогично.
- [x] Secrets: `TG_BOT_TOKEN`, `TG_CHAT_ID` (secrets GitHub → env шага).
  Не заданы → отправка SKIPPED (запрос не выполняется, шаг успешный).
  Ошибка Telegram → `NOTIFY_RESULT=FAILED` видно в логе (аннотация `::error::`),
  исход сборки не меняется (скрипт всегда exit 0, best-effort; `continue-on-error` не
  используется — статус job не маскируется).
- [x] Реальная отправка — разрешена в CI при заданных секретах; локально проверяется
  только через fixtures + mock HTTP (без реальной отправки).

### Реализация и проверка

- [x] Использовать secrets окружения без хардкода и логирования; токен не попадает
  в тело запроса (проверено тестом I; в stdout только http-код/ok/description).
- [x] Брать passed/failed/skipped из проверенного формата JUnit XML
  (`build/test-results/test`, те же атрибуты `testsuite`, что в `failOnEmptyTestRun`);
  Allure-отчёт не используется.
- [x] Отличать сбой сборки до запуска тестов (NO_RESULTS) от успешного запуска
  с "0 тестов прошло" (ZERO_EXECUTED).
- [x] Включить проект, CI, branch/commit, статус тестов passed/failed/skipped,
  статистику (всего N) и ссылку на запуск.
- [x] Проверять HTTP-ответ (2xx) и `ok:true` в ответе Telegram API; не маскировать
  исходное падение ошибкой уведомления.
- [x] Проверить согласованные случаи без реальной отправки (fixtures + mock HTTP):
  `bash scripts/telegram-notify.test.sh` → 9 сценариев, 35/35 PASS (2026-11-11).
- [ ] Реальная отправка — на первом CI-прогоне при заданных `secrets.TG_BOT_TOKEN`/`TG_CHAT_ID`.

### Файлы

- `scripts/telegram-notify.sh` — скрипт отправки (bash+curl, best-effort, всегда exit 0).
- `scripts/telegram-notify.test.sh` + `scripts/fixtures/*.xml` — проверка без отправки.
- `.github/workflows/ui-tests.yml` — шаг «Notify to Telegram» (после артефактов, `if: always()`).