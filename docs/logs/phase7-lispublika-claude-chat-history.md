# Фаза 7 — Jenkins Pipeline (ветка lispublika, claude / Cline)

Дата: 2026-11-17

## Запрос пользователя

Завершить офлайн-валидацию синтаксиса `Jenkinsfile`: решить проблему установки
плагинов в локальном Dockerized Jenkins (`jenkins/jenkins:lts`), получить
окончательный результат синтаксической проверки. Живая CI-интеграция на
`jenkins.qa.guru` невозможна: SSO/Keycloak блокирует write-операции API (401/403),
API-токен недоступен.

## Ход работы (запрос → ответ/действия)

1. **Проблема**: дефолтный образ Jenkins не содержит Pipeline/Workflow-плагинов;
   установка через API `installPlugin` возвращала «Batch of 0 plugins» (Update Center
   не наполнен/медленная загрузка `update-center.json`).
   **Решение**: запустить второй временный контейнер `jk-cli`, общий том с `jk-lint`,
   и поставить плагины `jenkins-plugin-cli` напрямую (файлы `.jpi` в
   `/var/jenkins_home/plugins`).

2. **Проблема**: первый запуск CLI — `No argument is allowed: install`
   (v2.15 не имеет подкоманды `install`).
   **Решение**: по `--help` корректный синтаксис —
   `jenkins-plugin-cli --plugins workflow-aggregator pipeline-model-definition
   --jenkins-version 2.580.2 -d /var/jenkins_home/plugins`.
   **Результат**: 51 плагин скачан с зеркал, проверен checksum'ами, RC=0
   (включая `workflow-aggregator`, `workflow-cps`, `workflow-job`,
   `pipeline-model-definition`).

3. **Действие**: перезапуск `jk-lint` → Jenkins 2.580.2 поднялся с 51 плагином.
   CSRF/аутентификация — сессионные cookies (`curl -c/-b`) + crumb.
   `createItem` с XML-конфигурацией Declarative Pipeline → **HTTP 200** (джоба
   создана, Jenkinsfile принят как валидная декларативная структура).

4. **Проблема**: endpoint `checkSyntax` в Jenkins 2.580.2 отсутствует (404 на
   `/job/<name>/checkSyntax` и `/definition/checkSyntax`).
   **Решение**: более строгий метод — **реальный билд probe-джобы** (копия
   Jenkinsfile с `agent { label 'built-in' }`, т.к. реальный лейбл агента не
   подтверждён).

5. **Результат билда** (консоль): скрипт **скомпилирован без ошибок**, полностью
   распарсен: `agent`, `options` (timeout 40 мин активен,
   disableConcurrentBuilds, buildDiscarder), `parameters` (choice/string/password),
   `environment`, все 4 стейджа (Checkout/Prechecks/Setup dependencies/Run tests),
   `post { always { ... } }` (catchError, archiveArtifacts ×4, withEnv, sh).
   Ошибок синтаксиса/компиляции («Syntax error», «Invalid pipeline script») — **нет**.
   Единственные FAILURE — ожидаемые runtime: `checkout scm` (у probe-джобы нет SCM по
   определению) и отсутствие `node`/`npm` во временном контейнере.

## Итог

- **Синтаксис Jenkinsfile: PASS (офлайн-валидация)** — на реальный Jenkins достаточно
  скопировать файл в «Pipeline from SCM»; плагины `workflow-aggregator` +
  `pipeline-model-definition` на целевом Jenkins обязательны.
- **Live-интеграция с `jenkins.qa.guru`: НЕ проверена (нет write-доступа)** — SSO/Keycloak,
  API 401/403; создание джобы/прогоны на warm-агенте остаются «ручным» этапом.
- **Не подтверждено**: лейбл агента `java-jdk21-jenkins-warm-agent-1`, JDK 21,
  Chrome/Chromium, npm/Node на реальном стенде.
- Уборка: контейнеры `jk-lint`/`jk-cli` удалены, все временные файлы в `/tmp` удалены.

## Изменения (коммит c0ad3c0)

- `Jenkinsfile`: шапка уточнена — синтаксис ПРОВЕРЕН офлайн PASS (Docker Jenkins
  2.580.2); live-интеграция НЕ проверена (SSO, API 401/403).
- `docs/plans/plan_phase7.md`: статус + блок «Результат (2026-11-17)» с описанием
  метода валидации и статусом live-интеграции.