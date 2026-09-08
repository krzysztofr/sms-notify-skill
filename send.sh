#!/usr/bin/env bash
# Send an SMS via smsapi.pl. Credentials come from macOS Keychain.
# Usage: send.sh [--test] "message"
set -euo pipefail

FROM="Alert"
TEST=0
if [[ "${1:-}" == "--test" ]]; then TEST=1; shift; fi
MSG="${1:-}"
[[ -n "$MSG" ]] || { echo "usage: send.sh [--test] \"message\"" >&2; exit 2; }

TOKEN=$(security find-generic-password -a "$USER" -s smsapi-token -w)
TO=$(security find-generic-password -a "$USER" -s smsapi-to -w)

RESP=$(curl -sS -m 10 -X POST https://api.smsapi.pl/sms.do \
  -H "Authorization: Bearer $TOKEN" \
  --data-urlencode "to=$TO" \
  --data-urlencode "from=$FROM" \
  --data-urlencode "message=$MSG" \
  --data-urlencode "encoding=utf-8" \
  --data-urlencode "normalize=1" \
  --data-urlencode "format=json" \
  --data-urlencode "test=$TEST")

echo "$RESP"
# ponytail: error detection by JSON key only; parse message/points if ever needed
echo "$RESP" | jq -e 'has("error") | not' >/dev/null
