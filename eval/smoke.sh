#!/usr/bin/env bash
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Smoke test: register -> me -> logout -> login -> wrong password, for one server.
# usage: smoke.sh <dir> <port> <me-path> [extra env...]
dir="$1"; port="$2"; me="$3"; shift 3
E="${EVAL_DIR:-$HOME/eval-run}"
cd "$E/$dir" || exit 1
rm -rf data *.db *.sqlite* 2>/dev/null
env "$@" PORT="$port" node server.js > server.log 2>&1 &
pid=$!
for i in $(seq 1 40); do curl -s -o /dev/null "http://127.0.0.1:$port/" && break; sleep 0.25; done
B="http://127.0.0.1:$port"; J=(-H "Content-Type: application/json" -H "Origin: http://localhost:$port")
jar=$(mktemp)
req() { local m="$1" p="$2" d="$3"; curl -s -o /tmp/smoke_body -w '%{http_code}' -X "$m" "${J[@]}" -b "$jar" -c "$jar" ${d:+-d "$d"} "$B$p"; printf ' %s\n' "$(head -c 160 /tmp/smoke_body)"; }
echo "register:      $(req POST /api/auth/register '{"email":"max@example.de","password":"Sehr-sicheres-Passwort-2026!"}')"
echo "me:            $(req GET "$me")"
echo "logout:        $(req POST /api/auth/logout '{}')"
echo "me after out:  $(req GET "$me")"
echo "login:         $(req POST /api/auth/login '{"email":"max@example.de","password":"Sehr-sicheres-Passwort-2026!"}')"
echo "me:            $(req GET "$me")"
echo "wrong pw:      $(req POST /api/auth/login '{"email":"max@example.de","password":"falsch-falsch-falsch"}')"
echo "dup register:  $(req POST /api/auth/register '{"email":"max@example.de","password":"Sehr-sicheres-Passwort-2026!"}')"
echo "bad input:     $(req POST /api/auth/register '{"email":"nope","password":"1"}')"
echo "sql-ish email: $(req POST /api/auth/login '{"email":"x@x.de\" OR 1=1 --","password":"aaaaaaaaaa"}')"
echo "cookie flags:  $(grep -v '^#' "$jar" | awk 'NF{print $1, $4, $6}' | head -2 | tr '\n' ' ') | set-cookie: $(curl -s -D - -o /dev/null -X POST "${J[@]}" -d '{"email":"max@example.de","password":"Sehr-sicheres-Passwort-2026!"}' "$B/api/auth/login" | grep -i '^set-cookie' | head -1 | tr -d '\r')"
kill $pid 2>/dev/null; wait $pid 2>/dev/null
echo "server log errors: $(grep -ciE 'error|exception' server.log)"
