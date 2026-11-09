### Фаза 5 — GitHub Actions

Статус: DONE (2026-11-09, код: bf0e834), ожидает push и прогон в GitHub (push — по разрешению).

Цель: воспроизводимый CI на hosted runner, без Selenoid.

- Один workflow: .github/workflows/ui-tests.yml
- В CI передаются только -Dselenide.headless=true и -Dselenide.browserSize из input browser_size
(choice: 1920x1200 по умолчанию, 1366x768), через env с проверкой case; 
baseUrl и browser — defaults TestBase.
- Все переменные определяются в самом начале файла.
- Триггеры: workflow_dispatch + push (все ветки, paths-ignore: docs/**, **/*.md)
- Runner: ubuntu-24.04, Chrome/ChromeDriver из образа, без --no-sandbox
Java: Temurin 21, Gradle через wrapper, Node.js + npm ci
- Actions закреплёны по SHA, permissions: {} на уровне workflow
  (pages-job — job-оверрайд contents/pages/id-token: обязательное условие GitHub Pages)
- Артефакты (7 дней): allure-results, test-reports, allure-report
- Публикация в GitHub Pages — master и ветка lispublika, даже при упавших тестах (решение: делаем)
- Результаты Allure — build/allure-results (build.gradle), package.json/package-lock.json с
  allure@3.22.1 (npm ci в CI), failOnEmptyTestRun — «0 тестов» не успех

Критерий приёмки:

- [x] `./gradlew test` зелёный, браузерный lifecycle корректен (3/3, headless;
  1 раз нестабильность StaleElementReferenceException — повторный прогон зелёный, без ретраев в CI).
- [x] Page Object на месте, assertions в should-методах.
- [x] `allure generate` строит отчёт из `build/allure-results` (проверено локально, allure CLI 3.22.1,
  флаг --partial в Allure 3 не поддерживается — убран).
- [x] GitHub Actions: тесты, артефакты и (по решению) Pages — workflow создан, YAML валиден;
  финальная проверка — реальный прогон в GitHub после push (нужно включённое GitHub Pages в настройках репозитория).
- [x] План в `docs/plans/` актуален, `AGENTS.md` содержит правила.
- [x] «0 тестов» — не успех (failOnEmptyTestRun: `--tests "tests.DefinitelyMissing"` → BUILD FAILED).
