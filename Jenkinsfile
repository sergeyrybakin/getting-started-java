// =============================================================================
// Фаза 7 — Jenkins Pipeline (UI-тесты). См. docs/plans/plan_phase7.md.
//
// Принципы (из плана + AGENTS.md + эталон .github/workflows/ui-tests.yml):
//   * Те же команды wrapper и генерации отчёта, что локально и в GitHub Actions:
//     `npm ci` → `./gradlew test -Dselenide.headless -Dselenide.browserSize`
//     → `npx allure generate`.
//   * Режим по умолчанию — браузер НА АГЕНТЕ (без remote-инфраструктуры).
//     build.gradle НЕ форвардит selenide.remote, поэтому remote — ТОЛЬКО опционально,
//     через init-скрипт (stage 'Run tests'), только при непустом selenide_remote.
//   * Публикация JUnit XML + сохранение результатов/вложений/отчёта при падениях.
//   * НЕ маскировать падение тестов: код возврата `./gradlew test` авторитетен.
//     Диагностические стейджи (отчёт/архив/уведомление) через catchError —
//     не переворачивают FAILURE тестов (test FAILED → FAILURE), а при проходе
//     тестов и сбое отчёта дают UNSTABLE (проблема отчёта, а не тестов).
//   * Отчёт — закреплённый CLI (npx allure, как в CI). Allure/JUnit ПЛАГИНЫ НЕ
//     используются: только core-шаги, чтобы не требовать установки плагинов/
//     изменений Jenkins без разрешения (см. план и AGENTS.md).
//
// ВАЖНО (интеграция НЕ проверена — Jenkins недоступен, API 401; см. план):
//   * Job = "Pipeline (from SCM)" → репозиторий
//     https://github.com/sergeyrybakin/getting-started-java, ветка `lispublika`
//     (иначе `checkout scm` не сработает).
//   * УТОЧНИТЬ на реальном Jenkins: лейбл агента, JDK 21, Chrome/Chromium, npm/Node.
//     ЛЕЙБЛ ниже — лучшее известное значение; подтверждение НЕ получено.
// =============================================================================

pipeline {
    // Браузер на агенте. ЛЕЙБЛ УТОЧНИТЬ — лучшее известное значение (401, не подтверждено).
    agent {
        label 'java-jdk21-jenkins-warm-agent-1'
    }

    options {
        // Аналог concurrency из GitHub Actions: не дублировать параллельные запуски.
        disableConcurrentBuild()
        // Таймаут всего пайплайна (защита от «зависания» браузера/сети).
        timeout(time: 40, unit: 'MINUTES')
        // Ротация: хранить 10 последних запусков и 30 дней (core-опция).
        buildDiscarder(logRotator(numToKeepStr: '5', numDaysToKeepStr: '15'))
    }

    // Согласованные параметры — зеркалят workflow_dispatch из ui-tests.yml.
    parameters {
        choice(
            name: 'browser_size',
            choices: ['1920x1200', '1366x768'],
            description: 'Размер браузера (selenide.browserSize)'
        )
        string(
            name: 'test_filter',
            defaultValue: '',
            description: 'Gradle --tests фильтр (пусто = все тесты). Пример «0 тестов»: no.such.*'
        )
        // ПУСТО = локальный браузер на агенте (режим по умолчанию плана).
        // URL remote (например http://warm-chrome-1:4444) → init-скрипт вставит selenide.remote.
        string(
            name: 'selenide_remote',
            defaultValue: '',
            description: 'URL remote WebDriver (пусто = локальный браузер на агенте)'
        )
        // Секреты TG — как в CI (secrets). Пусто = уведомление SKIPPED (без отправки).
        // password — маскируются в UI/логах; это НЕ секрет в коде (задаётся при запуске).
        password(
            name: 'TG_BOT_TOKEN',
            description: 'Telegram bot token (пусто = уведомление SKIPPED)'
        )
        password(
            name: 'TG_CHAT_ID',
            description: 'Telegram chat id (пусто = уведомление SKIPPED)'
        )
    }

    environment {
        HEADLESS           = 'true'
        BROWSER_SIZE       = "${params.browser_size ?: '1920x1200'}"
        TEST_FILTER        = "${params.test_filter ?: ''}"
        SELENIDE_REMOTE    = "${params.selenide_remote ?: ''}"
        ALLURE_RESULTS_DIR = 'build/allure-results'
        ALLURE_REPORT_DIR  = 'allure-report'
        JUNIT_XML_GLOB     = 'build/test-results/test/*.xml'
        TEST_REPORTS_DIR   = 'build/reports/tests'
    }

    stages {
        stage('Checkout') {
            steps {
                // SCM задан в job (Pipeline from SCM → репозиторий/ветка из шапки).
                checkout scm
            }
        }

        stage('Prechecks') {
            steps {
                // Логирование окружения + валидация параметров (как Verify в CI).
                // Секреты (TG_*) здесь НЕ печатаются — только факт заданности.
                sh '''
                    set -euo pipefail
                    echo "== Jenkins pipeline env =="
                    echo "agent node      : ${NODE_NAME:-<unset>}"
                    echo "workspace       : ${WORKSPACE:-<unset>}"
                    echo "headless        : ${HEADLESS}"
                    echo "browser_size    : ${BROWSER_SIZE}"
                    echo "test_filter     : ${TEST_FILTER:-<all>}"
                    echo "selenide_remote : ${SELENIDE_REMOTE:-<local-browser>}"
                    if [ -n "${TG_BOT_TOKEN:-}" ] && [ -n "${TG_CHAT_ID:-}" ]; then echo "TG configured   : yes"; else echo "TG configured   : no"; fi

                    case "${BROWSER_SIZE}" in
                        1366x768|1920x1200) echo "browser_size OK" ;;
                        *) echo "ERROR: недопустимый browser_size=${BROWSER_SIZE} (допустимо: 1366x768, 1920x1200)"; exit 1 ;;
                    esac

                    if [ -n "${SELENIDE_REMOTE}" ]; then
                        case "${SELENIDE_REMOTE}" in
                            http://*|https://*) echo "remote WebDriver: ${SELENIDE_REMOTE}" ;;
                            *) echo "ERROR: selenide_remote должен начинаться с http:// или https://"; exit 1 ;;
                        esac
                    fi

                    command -v java >/dev/null 2>&1 || { echo "ERROR: java не найден в PATH"; exit 1; }
                    command -v node >/dev/null 2>&1 || { echo "ERROR: node не найден в PATH"; exit 1; }
                    command -v npm  >/dev/null 2>&1 || { echo "ERROR: npm не найден в PATH"; exit 1; }
                    echo "--- java ---"; java -version 2>&1 | head -1
                    echo "node : $(node --version)"
                    test -f gradlew || { echo "ERROR: нет gradlew"; exit 1; }
                    echo "prechecks OK"
                '''
            }
        }

        stage('Setup dependencies') {
            steps {
                // npm ci — та же команда, что в GitHub Actions (pinned allure-CLI).
                sh 'npm ci --no-audit --no-fund'
            }
        }

        stage('Run tests') {
            // АВТОРИТЕТНЫЙ шаг: его код возврата = статус прогона тестов.
            // Без catchError: ошибка здесь = FAILURE сборки (не маскируется).
            steps {
                sh '''
                    set -euo pipefail
                    FILTER_ARGS=()
                    if [ -n "${TEST_FILTER}" ]; then
                        FILTER_ARGS+=(--tests "${TEST_FILTER}")
                        echo "Фильтр тестов: --tests ${TEST_FILTER}"
                    else
                        echo "test_filter пустой — запускаю ВСЕ тесты"
                    fi

                    if [ -n "${SELENIDE_REMOTE}" ]; then
                        echo "РЕЖИМ: REMOTE WebDriver (${SELENIDE_REMOTE}) — init-скрипт вставляет selenide.remote"
                        cat > ci-init.gradle <<'EOF'
allprojects {
    tasks.withType(Test) {
        // build.gradle не форвардит selenide.remote — вставляем из env (без хардкода URL).
        systemProperty 'selenide.remote', System.getenv('SELENIDE_REMOTE')
    }
}
EOF
                        ./gradlew --init-script ci-init.gradle test --console=plain \
                            -Dselenide.headless="${HEADLESS}" \
                            -Dselenide.browserSize="${BROWSER_SIZE}" \
                            "${FILTER_ARGS[@]}"
                    else
                        echo "РЕЖИМ: LOCAL браузер на агенте (без remote-инфраструктуры) — те же аргументы, что в CI"
                        ./gradlew test --console=plain \
                            -Dselenide.headless="${HEADLESS}" \
                            -Dselenide.browserSize="${BROWSER_SIZE}" \
                            "${FILTER_ARGS[@]}"
                    fi
                '''
            }
        }

        // --- Диагностические стейджи: всегда выполняются (в т.ч. при падении тестов),
        //     но через catchError НЕ переворачивают FAILURE тестов:
        //       тесты ПАЛИ → сборка FAILURE (авторитетный статус, не маскируется);
        //       тесты ПРОШЛИ, а отчёт/архив упали → UNSTABLE (проблема отчёта, а не тестов).
        stage('Generate Allure report') {
            when {
                always()
            }
            steps {
                catchError {
                    // Закреплённый CLI (npx allure, как в CI), а не Allure-плагин.
                    sh 'npx allure generate "${ALLURE_RESULTS_DIR}" -o "${ALLURE_REPORT_DIR}"'
                }
            }
        }

        stage('Publish artifacts') {
            when {
                always()
            }
            steps {
                catchError {
                    // Публикация JUnit XML + результатов + отчёта. Все core-шаги.
                    // allowEmptyArchive: не падать при отсутствии файлов (напр. сбой до тестов).
                    archiveArtifacts artifacts: "${JUNIT_XML_GLOB}", allowEmptyArchive: true, fingerprint: true
                    archiveArtifacts artifacts: "${ALLURE_RESULTS_DIR}/**", allowEmptyArchive: true, fingerprint: true
                    archiveArtifacts artifacts: "${TEST_REPORTS_DIR}/**", allowEmptyArchive: true, fingerprint: true
                    archiveArtifacts artifacts: "${ALLURE_REPORT_DIR}/**", allowEmptyArchive: true, fingerprint: true
                }
            }
        }

        stage('Notify Telegram') {
            when {
                always()
            }
            // Секреты из password-параметров → env (см. telegram-notify.sh: пусто → SKIPPED, exit 0).
            environment {
                TG_BOT_TOKEN = "${params.TG_BOT_TOKEN ?: ''}"
                TG_CHAT_ID   = "${params.TG_CHAT_ID ?: ''}"
                PROJECT      = 'getting-started-java'
                CI_NAME      = 'jenkins'
                BRANCH       = "${env.BRANCH_NAME ?: 'unknown-branch'}"
                COMMIT       = "${env.GIT_COMMIT ?: 'unknown-commit'}"
            }
            steps {
                // Скрипт best-effort (всегда exit 0); catchError на случай сбоев окружения.
                catchError {
                    sh 'bash scripts/telegram-notify.sh'
                }
            }
        }
    }
}
