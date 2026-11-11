#!/usr/bin/env bash
#
# telegram-notify.test.sh — проверка telegram-notify.sh БЕЗ реальной отправки:
#   * fixtures JUnit XML (scripts/fixtures) + локальный mock HTTP-сервер (python3).
#   * сценарии: все прошли / есть падения / все skipped / нет результатов /
#     нет секретов (SKIPPED) / HTTP 200+ok:false / HTTP 400 / HTTP 403.
#   * контроль, что токен бота НЕ попадает в stdout и не уходит в теле запроса.
#
# Запуск: bash scripts/telegram-notify.test.sh

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$DIR/telegram-notify.sh"
FIX="$DIR/fixtures"

WORK="$(mktemp -d)"
trap 'kill "${MOCK_PID:-}" 2>/dev/null || true; rm -rf "$WORK"' EXIT

PASS=0; FAIL=0
ok()  { echo "  ✓ $1"; PASS=$((PASS+1)); }
bad() { echo "  ✗ $1"; FAIL=$((FAIL+1)); }
assert_contains()     { if printf '%s' "$1" | grep -qF -- "$2"; then ok "содержит: $2"; else bad "нет строки: $2"; fi; }
assert_not_contains() { if printf '%s' "$1" | grep -qF -- "$2"; then bad "УТЕЧКА: $2"; else ok "нет утечки: $2"; fi; }

# ---------- mock-сервер Telegram API ----------
# Mock повторяет схему реального Telegram API: POST /bot<TOKEN>/sendMessage.
# Сценарий ответа определяется токеном в URL (TG_API_BASE — только host:port):
#   OK_TOKEN      → 200 {"ok":true,...}
#   BADOK_TOKEN   → 200 {"ok":false,"description":"Bad Request: chat not found"}
#   BADHTTP_TOKEN → 400 {"ok":false,"description":"Bad Request: parse error"}
#   NOPERM_TOKEN  → 403 {"ok":false,"description":"Forbidden: bot was blocked by the user"}
#   любой другой  → 404 {"ok":false,"description":"unknown token"}
cat > "$WORK/mock.py" <<'PYEOF'
import http.server, re, sys
port = int(sys.argv[1])
bodyfile = sys.argv[2]
class H(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        ln = int(self.headers.get('Content-Length','0'))
        body = self.rfile.read(ln).decode('utf-8','replace')
        with open(bodyfile,'a') as f:
            f.write('PATH=' + self.path + '\n')
            f.write('BODY=' + body + '\n---\n')
        m = re.match(r'^/bot([^/]+)/sendMessage$', self.path)
        token = m.group(1) if m else None
        if token == 'OK_TOKEN':
            data = b'{"ok":true,"result":{"message_id":1,"chat":{"id":42}}}'; code = 200
        elif token == 'BADOK_TOKEN':
            data = b'{"ok":false,"description":"Bad Request: chat not found"}'; code = 200
        elif token == 'BADHTTP_TOKEN':
            data = b'{"ok":false,"description":"Bad Request: parse error"}'; code = 400
        elif token == 'NOPERM_TOKEN':
            data = b'{"ok":false,"description":"Forbidden: bot was blocked by the user"}'; code = 403
        else:
            data = b'{"ok":false,"description":"unknown token"}'; code = 404
        self.send_response(code)
        self.send_header('Content-Type','application/json')
        self.send_header('Content-Length',str(len(data)))
        self.end_headers()
        self.wfile.write(data)
    def log_message(self,*a): pass
http.server.HTTPServer(('127.0.0.1',port),H).serve_forever()
PYEOF

PORT="$(python3 - <<'PY'
import socket
s=socket.socket(); s.bind(('127.0.0.1',0)); print(s.getsockname()[1]); s.close()
PY
)"
BODYLOG="$WORK/body.log"; : > "$BODYLOG"
python3 "$WORK/mock.py" "$PORT" "$BODYLOG" &
MOCK_PID=$!

# Ждём готовности mock.
for _ in $(seq 1 100); do
  if curl -s -o /dev/null -X POST --data '{}' "http://127.0.0.1:${PORT}/botOK_TOKEN/sendMessage" 2>/dev/null; then break; fi
  sleep 0.05
done

# run_notify <results_dir> <token> — общий env для отправки (секреты заданы).
run_notify() {
  local results_dir="$1" token="$2"
  RESULTS_DIR="$results_dir" \
  TG_API_BASE="http://127.0.0.1:${PORT}" \
  PROJECT="lispublika-ui" CI_NAME="github-actions" BRANCH="lispublika" COMMIT="abc1234" \
  RUN_URL="https://github.com/example/lispublica/actions/runs/12345" \
  TG_BOT_TOKEN="$token" TG_CHAT_ID="42" \
  bash "$SCRIPT"
}
# ---------- сценарии ----------
R_ALL="$WORK/results_all";        mkdir -p "$R_ALL"; cp "$FIX/all-pass.xml" "$FIX/all-pass-2.xml" "$R_ALL/"
R_FAIL="$WORK/results_fail";      mkdir -p "$R_FAIL"; cp "$FIX/with-failures.xml" "$R_FAIL/"
R_SKIP="$WORK/results_skip";      mkdir -p "$R_SKIP"; cp "$FIX/all-skipped.xml" "$R_SKIP/"
R_EMPTY="$WORK/results_empty";    mkdir -p "$R_EMPTY"

echo "— A. все прошли (2 файла, агрегация) + HTTP 200 ok:true"
OUT="$(run_notify "$R_ALL" OK_TOKEN)"
assert_contains "$OUT" "STATE=ALL_PASSED"
assert_contains "$OUT" "PASSED=3 FAILED=0 SKIPPED=0 TOTAL=3"
assert_contains "$OUT" "NOTIFY_RESULT=SENT"
assert_contains "$OUT" "HTTP_CODE=200 API_OK=true"
# Содержимое сообщения — в теле запроса (BODY=... в body.log), а не в stdout
assert_contains "$(grep '^BODY=' "$BODYLOG")" "lispublika-ui"
assert_contains "$(grep '^BODY=' "$BODYLOG")" "https://github.com/example/lispublica/actions/runs/12345"
assert_not_contains "$OUT" "OK_TOKEN"

echo "— B. есть падения + HTTP 200 ok:true"
OUT="$(run_notify "$R_FAIL" OK_TOKEN)"
assert_contains "$OUT" "STATE=HAS_FAILURES"
assert_contains "$OUT" "PASSED=1 FAILED=1 SKIPPED=1 TOTAL=3"
assert_contains "$OUT" "NOTIFY_RESULT=SENT"

echo "— C. все skipped (0 выполнено) + HTTP 200 ok:true"
OUT="$(run_notify "$R_SKIP" OK_TOKEN)"
assert_contains "$OUT" "STATE=ZERO_EXECUTED"
assert_contains "$OUT" "PASSED=0 FAILED=0 SKIPPED=2 TOTAL=2"
assert_contains "$(grep '^BODY=' "$BODYLOG")" "0 тестов прошло (все пропущены)"
assert_contains "$OUT" "NOTIFY_RESULT=SENT"

echo "— D. нет результатов (сбой до тестов) + HTTP 200 ok:true"
OUT="$(run_notify "$R_EMPTY" OK_TOKEN)"
assert_contains "$OUT" "STATE=NO_RESULTS"
assert_contains "$OUT" "PASSED=0 FAILED=0 SKIPPED=0 TOTAL=0"
assert_contains "$(grep '^BODY=' "$BODYLOG")" "Сборка не дошла до тестов"
assert_contains "$OUT" "NOTIFY_RESULT=SENT"

echo "— E. нет секретов → SKIPPED, запрос не отправлен"
BEFORE="$(wc -l < "$BODYLOG" | tr -d ' ')"
OUT="$(RESULTS_DIR="$R_ALL" PROJECT="p" CI_NAME="c" TG_API_BASE="http://127.0.0.1:${PORT}" bash "$SCRIPT")"
AFTER="$(wc -l < "$BODYLOG" | tr -d ' ')"
assert_contains "$OUT" "NOTIFY_RESULT=SKIPPED"
assert_contains "$OUT" "STATE=ALL_PASSED"
[ "$BEFORE" -eq "$AFTER" ] && ok "HTTP-запрос не отправлен (body.log не изменился)" || bad "ожидается, что запрос не отправился (before=$BEFORE after=$AFTER)"

echo "— F. HTTP 200, но ok:false"
OUT="$(run_notify "$R_FAIL" BADOK_TOKEN)"
assert_contains "$OUT" "NOTIFY_RESULT=FAILED"
assert_contains "$OUT" "HTTP_CODE=200 API_OK=false"
assert_contains "$OUT" "chat not found"
assert_not_contains "$OUT" "BADOK_TOKEN"

echo "— G. HTTP 400 (bad request)"
OUT="$(run_notify "$R_FAIL" BADHTTP_TOKEN)"
assert_contains "$OUT" "NOTIFY_RESULT=FAILED"
assert_contains "$OUT" "HTTP_CODE=400"

echo "— H. HTTP 403 (bot blocked)"
OUT="$(run_notify "$R_FAIL" NOPERM_TOKEN)"
assert_contains "$OUT" "NOTIFY_RESULT=FAILED"
assert_contains "$OUT" "HTTP_CODE=403"
assert_contains "$OUT" "bot was blocked"

# ---------- тело запроса: токен в URL (bot<TOKEN>/, схема Telegram API), НЕ в BODY ----------
echo "— I. тело запроса: есть chat_id/text, НЕТ токена; токен — только в PATH"
assert_contains "$(grep '^PATH=' "$BODYLOG")" "/botOK_TOKEN/sendMessage"
assert_contains "$(grep '^BODY=' "$BODYLOG")" '"chat_id":"42"'
assert_contains "$(grep '^BODY=' "$BODYLOG")" '"text":"'
assert_not_contains "$(grep '^BODY=' "$BODYLOG")" "OK_TOKEN"
assert_not_contains "$(grep '^BODY=' "$BODYLOG")" "BADOK_TOKEN"

# ---------- итог ----------
echo
echo "ИТОГ: PASS=${PASS} FAIL=${FAIL}"
if [ "$FAIL" -eq 0 ]; then
  echo "ВЕСЬ НАБОР ПРОВЕРОК ПРОЙДЕН"
  exit 0
else
  echo "ЕСТЬ ПРОВАЛЫ"
  exit 1
fi

