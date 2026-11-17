### Фаза 7 — Jenkins Pipeline

Цель: те же тесты и отчёт на Jenkins.

Статус: в процессе (2026-11-17): синтаксис Jenkinsfile проверен офлайн (PASS, см. ниже);
live-интеграция НЕ проверена (нет write-доступа к jenkins.qa.guru — SSO/Keycloak, API 401/403;
API-токен недоступен).

[ ] Уточнить нахождение, работоспособность, креденшенелы Jenkins и агента, ОС, браузеры, Java,
параметры, имена, способ публикации отчёта.
jenkins.qa.guru
SRB_JENKINS_ID
java-jdk21-jenkins-warm-agent-1
[ ] `Jenkinsfile`: те же команды wrapper и генерации отчёта, что локально и в GitHub Actions; согласованные параметры;
  браузер на агенте без remote-инфраструктуры.
[ ] Публиковать JUnit XML; сохранять результаты, вложения и отчёт при падениях; не маскировать падение статусом.
[ ] Согласовать различие FAILURE/UNSTABLE.
[ ] Способ генерации отчёта: закреплённый CLI (как в CI) или доказанно совместимый Allure Jenkins plugin —  не предполагать, а проверять совместимость заранее.
[ ] Не устанавливать плагины и не менять Jenkins глобально без разрешения.
[ ] Не копировать `--no-sandbox` как универсальную настройку — это компромисс конкретного runner.

Проверка на реальном агенте: успех, падение assertion,
ошибка компиляции, отсутствие результатов, сохранение
диагностики и уведомления. Если Jenkins недоступен —
проверен синтаксис Jenkinsfile, интеграция помечается
непроверенной.

## Результат (2026-11-17)

**Синтаксис Jenkinsfile: PASS (офлайн-валидация).**
Как: локальный `jenkins/jenkins:lts` (2.580.2) в Docker, плагины
`workflow-aggregator` + `pipeline-model-definition` установлены
`jenkins-plugin-cli`. Jenkinsfile был создан как Declarative pipeline
(Pipeline from SCM), билд запущен. Результат: скрипт **скомпилирован и
полностью распарсен** — отработали `agent`, `options` (timeout/
disableConcurrentBuilds/buildDiscarder), `parameters` (choice/string/
password), `environment`, все 4 стейджа и `post { always { ... } }`
(catchError/archiveArtifacts/withEnv/sh). Ошибок синтаксиса/компиляции
(«Syntax error», «Invalid pipeline script») **нет**. Единственный FAILURE —
ожидаемая runtime-ошибка `checkout scm` (у probe-джобы нет SCM по
определению) + отсутствие node/npm на временном контейнере. Валидация
проводилась на копии с лейблом агента `built-in` (реальный лейбл
`java-jdk21-jenkins-warm-agent-1` не подтверждён, см. выше).

**Live-интеграция с jenkins.qa.guru: НЕ проверена (нет write-доступа).**
SSO/Keycloak блокирует API без сессионного браузера (401/403); создание
джобы/запуск на реальном Jenkins, проверенные прогоны на warm-агенте —
остаются на «ручном» этапе после предоставления доступа.
