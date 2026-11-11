#!/usr/bin/env bash
#
# telegram-notify.sh — уведомление в Telegram о результатах прогона UI-тестов.
#
# Принципы (Фаза 6):
#  * Секреты — только из окружения (CI secrets); без хардкода и без логирования токена.
#  * Статистика passed/failed/skipped берётся из JUnit XML (build/test-results/test),
#    а НЕ из Allure-отчёта (формат проверен — те же атрибуты testsuite, что в failOnEmptyTestRun).
#  * Отличает «сборка упала до тестов» (нет результатов) от «0 тестов прошло» (все skipped).
#  * Проверяет HTTP-ответ и поле ok из ответа Telegram API.
#  * Best-effort: код выхода ВСЕГДА 0 — скрипт не переворачивает исход сборки
#    (ни green→red, ни red→green), поэтому не маскирует и не скрывает исходное падение.
#
# Переменные окружения:
#  * TG_BOT_TOKEN  — токен бота (обязателен для отправки; при отсутствии — SKIPPED)
#  * TG_CHAT_ID    — id чата/канала (обязателен для отправки; при отсутствии — SKIPPED)
#  * TG_API_BASE   — базовый URL API (по умолчанию https://api.telegram.org).
#                    Переопределяется в тестах для mock-HTTP без реальной отправки.
#  * RESULTS_DIR   — каталог JUnit XML (по умолчанию build/test-results/test)
#  * PROJECT, CI_NAME, BRANCH, COMMIT, RUN_URL — данные для сообщения (опционально;
#    по умолчанию берутся из GITHUB_* , при отсутствии — заглушки)
#
# Вывод (машиночитаемые строки для логов/автотестов):
#  * STATE=ALL_PASSED|HAS_FAILURES|ZERO_EXECUTED|NO_RESULTS
#  * PASSED=.. FAILED=.. SKIPPED=.. TOTAL=..
#  * HTTP_CODE=.. API_OK=..
#  * NOTIFY_RESULT=SENT|FAILED|SKIPPED
#
# Код выхода: ВСЕГДА 0 (см. Best-effort выше).

set -uo pipefail

# ---------- defaults ----------
TG_API_BASE="${TG_API_BASE:-https://api.telegram.org}"
RESULTS_DIR="${RESULTS_DIR:-build/test-results/test}"
PROJECT="${PROJECT:-${GITHUB_REPOSITORY:-unknown-project}}"
CI_NAME="${CI_NAME:-${CI:-unknown-ci}}"
BRANCH="${BRANCH:-${GITHUB_REF_NAME:-unknown-branch}}"
COMMIT="${COMMIT:-${GITHUB_SHA:-unknown-commit}}"

# Ссылка на запуск — только если все части GitHub env присутствуют.
DEFAULT_RUN_URL=""
if [ -n "${GITHUB_SERVER_URL:-}" ] && [ -n "${GITHUB_REPOSITORY:-}" ] && [ -n "${GITHUB_RUN_ID:-}" ]; then
  DEFAULT_RUN_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
fi
RUN_URL="${RUN_URL:-${DEFAULT_RUN_URL}}"
[ -n "$RUN_URL" ] || RUN_URL="n/a"

# ---------- helpers ----------
# Escaping для JSON-строки (обратный слэш, кавычки, переносы, табы).
json_escape() {
  local s="$1"
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

# CI-аннотация (в GitHub Actions) или обычный вывод локально.
ann_notice() { if [ -n "${GITHUB_ACTIONS:-}" ]; then echo "::notice::$1"; else echo "$1"; fi; }
ann_error()  { if [ -n "${GITHUB_ACTIONS:-}" ]; then echo "::error::$1";  else echo "$1"; fi; }
# ---------- читаем JUnit XML ----------
shopt -s nullglob
files=( "${RESULTS_DIR}"/*.xml )
shopt -u nullglob

if [ ${#files[@]} -gt 0 ]; then
  ALL_CONTENT="$(cat "${files[@]}" 2>/dev/null || true)"
else
  ALL_CONTENT=""
fi

# Суммируем атрибут testsuite по всем файлам. `="N"` (цифра) отличает атрибут
# от имени тега <testsuite> и от name="...".
sum_attr() {
  local attr="$1" n
  n="$(printf '%s' "$ALL_CONTENT" \
      | grep -oE "[^A-Za-z]${attr}=\"[0-9]+\"" \
      | sed -E "s/.*${attr}=\"([0-9]+)\"/\1/" \
      | awk '{s+=$1} END{print s+0}')"
  printf '%s' "${n:-0}"
}

TOTAL="$(sum_attr tests)"
SKIPPED="$(sum_attr skipped)"
FAILURES="$(sum_attr failures)"
ERRORS="$(sum_attr errors)"
FAILED_TOTAL=$(( FAILURES + ERRORS ))
PASSED=$(( TOTAL - SKIPPED - FAILURES - ERRORS ))
[ "$PASSED" -lt 0 ] && PASSED=0
EXECUTED=$(( TOTAL - SKIPPED ))
[ "$EXECUTED" -lt 0 ] && EXECUTED=0

# ---------- определяем исход ----------
if [ ${#files[@]} -eq 0 ]; then
  STATE="NO_RESULTS"; EMOJI="⛔"; HUMAN="Сборка не дошла до тестов / нет результатов прогона"
elif [ "$FAILED_TOTAL" -gt 0 ]; then
  STATE="HAS_FAILURES"; EMOJI="❌"; HUMAN="Есть упавшие тесты"
elif [ "$EXECUTED" -eq 0 ]; then
  STATE="ZERO_EXECUTED"; EMOJI="⚠️"; HUMAN="0 тестов прошло (все пропущены)"
else
  STATE="ALL_PASSED"; EMOJI="✅"; HUMAN="Все тесты прошли"
fi

# ---------- сообщение ----------
MESSAGE="${EMOJI} ${PROJECT} — UI Tests
CI: ${CI_NAME}
Ветка: ${BRANCH}
Коммит: ${COMMIT}
Статус: ${HUMAN}
Тесты: passed ${PASSED} · failed ${FAILED_TOTAL} · skipped ${SKIPPED} (всего ${TOTAL})
Запуск: ${RUN_URL}"

# ---------- отправка ----------
BOT_TOKEN="${TG_BOT_TOKEN:-}"
CHAT_ID="${TG_CHAT_ID:-}"

# Машиночитаемый вывод состояния (для автотестов).
echo "STATE=${STATE}"
echo "PASSED=${PASSED} FAILED=${FAILED_TOTAL} SKIPPED=${SKIPPED} TOTAL=${TOTAL}"

if [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ]; then
  echo "NOTIFY_RESULT=SKIPPED"
  ann_notice "Telegram notification skipped: TG_BOT_TOKEN/TG_CHAT_ID не заданы (отправка без секретов не выполняется)"
  exit 0
fi

# Секреты — только в URL запроса и в теле; токен НЕ попадает в stdout/лог.
ENDPOINT="${TG_API_BASE}/bot${BOT_TOKEN}/sendMessage"
ESC_MSG="$(json_escape "$MESSAGE")"
ESC_CHAT="$(json_escape "$CHAT_ID")"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
PAYLOAD_FILE="$TMP_DIR/payload.json"
printf '{"chat_id":"%s","text":"%s"}' "$ESC_CHAT" "$ESC_MSG" > "$PAYLOAD_FILE"

HTTP_CODE_FILE="$TMP_DIR/http_code"
BODY_FILE="$TMP_DIR/body.json"

curl --silent --show-error \
     --request POST \
     --header "Content-Type: application/json" \
     --data @"$PAYLOAD_FILE" \
     --max-time 30 \
     --output "$BODY_FILE" \
     --write-out '%{http_code}' \
     "$ENDPOINT" > "$HTTP_CODE_FILE" 2> "$TMP_DIR/curl.err"
CURL_RC=$?
HTTP_CODE="$(cat "$HTTP_CODE_FILE" 2>/dev/null || true)"
[ -n "$HTTP_CODE" ] || HTTP_CODE="000"

# Парсим ok / description из ответа Telegram API (безопасно для лога).
API_OK=""
API_DESC=""
if [ -s "$BODY_FILE" ]; then
  BODY="$(cat "$BODY_FILE" 2>/dev/null || true)"
  API_OK="$(printf '%s' "$BODY" | grep -oE '"ok"[[:space:]]*:[[:space:]]*(true|false)' | grep -oE 'true|false' | head -1 || true)"
  API_DESC="$(printf '%s' "$BODY" | grep -oE '"description"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -E 's/.*"description"[[:space:]]*:[[:space:]]*"//; s/"$//' | head -1 || true)"
fi

HTTP_OK="no"
case "$HTTP_CODE" in 2*) HTTP_OK="yes" ;; esac

if [ "$HTTP_OK" = "yes" ] && [ "$API_OK" = "true" ]; then
  NOTIFY_RESULT="SENT"
else
  NOTIFY_RESULT="FAILED"
fi

echo "HTTP_CODE=${HTTP_CODE} API_OK=${API_OK:-n/a}"
echo "NOTIFY_RESULT=${NOTIFY_RESULT}"

if [ "$NOTIFY_RESULT" = "SENT" ]; then
  ann_notice "Telegram: сообщение отправлено (http=${HTTP_CODE}, ok=true)"
else
  REASON="http=${HTTP_CODE} api_ok=${API_OK:-n/a}"
  [ -n "$API_DESC" ] && REASON="${REASON} ${API_DESC}"
  [ "$CURL_RC" -ne 0 ] && REASON="${REASON} (curl rc=${CURL_RC})"
  # Ошибка уведомления видна в логе, но НЕ влияет на исход сборки (best-effort).
  ann_error "Telegram notification FAILED: ${REASON}"
fi

exit 0
