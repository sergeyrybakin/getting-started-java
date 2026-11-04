### План на Фаза 5 — GitHub Actions
- GitHub Actions (фаза 5): один workflow .github/workflows/ui-tests.yml.
  Запуск по сигналам:
* * workflow_dispatch 
* * push во все ветки с paths-ignore docs/** и **/*.md; без pull_request и schedule (риск HTTP 429 от github.com).
- Runner ubuntu-24.04, Chrome и ChromeDriver — предустановленные в образе; Chrome for Testing не ставится, --no-sandbox не используется.
- В CI передаются только -Dselenide.headless=true и -Dselenide.browserSize из input browser_size (choice: 1366x768 по умолчанию, 1920x1080), через env с проверкой case;
  baseUrl и browser — defaults TestBase.
- В CI: Temurin 21 (actions/setup-java), Gradle через wrapper с setup-gradle (cache-provider: basic, проверка wrapper), Node.js 24.22.2 с npm ci и кэшем npm.
- Actions закреплены по полному SHA с тегом в комментарии; permissions: {} на уровне workflow, минимальные — на уровне job; secrets не нужны.
- Артефакты (7 дней): allure-results, test-reports (JUnit XML и HTML-отчёт Gradle), allure-report. Отчёт генерируется только при наличии build/allure-results/*-result.json.
  Публикация Allure-отчёта в GitHub Pages — только с master (в том числе при упавших тестах); Pages включён с Source = GitHub Actions, environment github-pages разрешает
  деплой только из master.