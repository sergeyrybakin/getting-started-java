# Фаза 5 — CI/CD с GitHub Actions (ветка lispublika, qwen3_8b)

Дата: 2026-11-09

## Запрос пользователя

Просмотреть проект и реализовать Фазу 5 по `docs/plans/plan_phase5.md`.
Решения пользователя:
1. GitHub Pages — делаем.
2. `browser_size` — спрашиваем (workflow_dispatch, choice), дефолт **1920x1200** (пользователь поправил план).
3. Создать `package.json`/`package-lock.json`, поправить `build.gradle`, `.gitignore`.
4. В коммит включить WIP от Фазы 4 (`docs/logs/phase4-lispublika-qwen3_8b-chat-history.md`).

## Изменения

- `package.json` (new): allure@3.22.1, private. `package-lock.json` (new, npm --package-lock-only).
- `build.gradle`: Allure-результаты в `build/allure-results` (системное свойство allure.results.directory),
  очистка `build/allure-results` в doFirst, задача `failOnEmptyTestRun` («0 тестов» — не успех) через finalizedBy.
- `.github/workflows/ui-tests.yml` (new): job `test` (ubuntu-24.04, Temurin 21, Node 22, npm ci,
  case-проверка browser_size, ./gradlew test только с -Dselenide.headless=true и -Dselenide.browserSize,
  allure generate, 3 артефакта 7 дней) + job `pages` (master/lispublika, if: always(),
  upload-pages-artifact → deploy-pages). Actions по SHA (checkout v4 11d5960a, setup-java v4 cf277c60,
  setup-node v4 49933ea5, upload-artifact v4 ea165f8d, download-artifact v4 d3f86a10,
  upload-pages-artifact v3 56afc609, deploy-pages v4 d6db9016). permissions: {} на уровне workflow,
  job-оверрайд permissions в pages-job (pages: write, id-token: write, contents: read).
- `.gitignore`: проверен — `node_modules/` игнорируется, `package.json`/`package-lock.json` НЕ игнорируются (git check-ignore).
- `docs/plans/plan_phase5.md`: дефолт 1920x1200, критерии отмечены, статус DONE.

## Проверки (локально)

- `./gradlew test -Dselenide.headless=true -Dselenide.browserSize=1920x1200` → BUILD SUCCESSFUL, 3/3;
  1 случай StaleElementReferenceException на successfulSearchTest — повторный прогон зелёный (flaky, ретраев в CI нет).
- `npx allure generate build/allure-results -o allure-report` → отчёт собран; --partial в Allure 3 CLI (3.22.1) отсутствует — убран из workflow.
- «0 тестов»: `./gradlew test --tests "tests.DefinitelyMissing"` → BUILD FAILED («No tests were executed»).
- YAML workflow: валиден (pyyaml), jobs: test, pages.

## Осталось (требует разрешения пользователя)

- Push ветки lispublika (и workflow) в GitHub — без разрешения не выполнялся.
- Включить GitHub Pages в настройках репозитория (Settings → Pages → Source: GitHub Actions)
  и убедиться, что защита окружения github-pages не блокирует деплой.
- First run: workflow_dispatch с browser_size=1920x1200, проверить артефакты и Pages.

## Статус: завершено (2026-11-09) bf0e834

## Push

- 2026-11-09: push ветки lispublika выполнен (origin/sergeyrybakin, new branch, tracking установлен).
  Ожидался автостарт workflow ui-tests.yml (в push входят .github/workflows/ui-tests.yml, build.gradle, package*.json).

## Фикс (2026-11-09)

- GitHub отклонил workflow: «Unrecognized named-value: env» в job-if pages-job (контекст env
  недоступен в job-level if). Исправлено: ветки встроены в выражение —
  always() && (github.ref_name == \master\ || github.ref_name == \lispublika\),
  переменная PAGES_BRANCHES удалена из env. YAML перевалидирован, push выполнен.

## Дополнение (2026-11-10) — «0 тестов» одной кнопкой

- Задача: гарантировать, что сценарий «0 тестов» не проходит как успех, и дать способ проверить
  это одной кнопкой из GitHub Actions (без коммитов).
- `build.gradle`: `failOnEmptyTestRun` пересчитан — теперь считает только реально выполненные тесты
  (по JUnit-XML: атрибут `testsuite.tests` минус `testsuite.skipped`, сумма по файлам); пропущенные
  (`@Disabled` / `assumeTrue(false)` / @Tag-эксклюзии) НЕ засчитываются. Причина: старая реализация
  считала тег `<testcase>` (включая `<skipped/>`), поэтому «все @Disabled» давал `BUILD SUCCESSFUL` — ложное прохождение.
- `.github/workflows/ui-tests.yml`: вход `test_filter` (workflow_dispatch, `type: string`, default `«»`);
  `env.TEST_FILTER`; шаг «Run UI tests» (`shell: bash`) при непустом фильтре добавляет `--tests "<filter>"`,
  пусто = все тесты. Кнопка: Actions → UI Tests → Run workflow → `test_filter = no.such.*`.
- Проверки (локально, с актуальным кодом):
  - все `@Disabled` (`tests=3 skipped=3`) → `failOnEmptyTestRun FAILED` → `BUILD FAILED` (разрыв закрыт);
  - `tests=3 skipped=0` → `BUILD SUCCESSFUL` (executed=3); `tests=3 skipped=1` → `BUILD SUCCESSFUL` (executed=2);
  - пустая папка результатов → `BUILD FAILED`;
  - E2E-команда из workflow с `--tests 'no.such.*'` → `BUILD FAILED` («No tests were executed (0 non-skipped)»);
  - YAML валиден (pyyaml); bash-логика (пусто/фильтр) и пустой массив `FILTER_ARGS` под `set -u` — OK.
- Статус: завершена (2026-11-10) c520662
