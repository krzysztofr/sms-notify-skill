#!/usr/bin/env bash
# Send an SMS via smsapi.pl. Credentials come from macOS Keychain.
# Usage: send.sh [--test] "message"
set -euo pipefail

FROM="Alert"
# Prefix = project name: git repo root name, else current directory name.
PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
MAXLEN=160   # one GSM-7 SMS part; we strip to plain ASCII so 160 applies
TEST=0
if [[ "${1:-}" == "--test" ]]; then TEST=1; shift; fi
MSG="${1:-}"
[[ -n "$MSG" ]] || { echo "usage: send.sh [--test] \"message\"" >&2; exit 2; }

# Transliterate Polish letters and typographic dashes/quotes, drop every other
# non-ASCII char, drop GSM-7 extension chars (they cost 2 chars each), cap length.
# ponytail: sed y-table covers Polish only; add rows if other languages show up
MSG=$(printf '%s' "$PROJECT: $MSG" \
  | LC_ALL=en_US.UTF-8 sed 'y/ąćęłńóśźżĄĆĘŁŃÓŚŹŻ—–“”„’/acelnoszzACELNOSZZ--"""'"'"'/' \
  | LC_ALL=C tr -cd ' -~' \
  | tr -d '[]{}\\^~|' \
  | cut -c1-"$MAXLEN")

TOKEN=$(security find-generic-password -a "$USER" -s smsapi-token -w)
TO=$(security find-generic-password -a "$USER" -s smsapi-to -w)

# Token goes in via curl config on stdin so it never appears in argv / ps.
RESP=$(printf 'header = "Authorization: Bearer %s"\n' "$TOKEN" \
  | curl -sS -m 10 -K - -X POST https://api.smsapi.pl/sms.do \
  --data-urlencode "to=$TO" \
  --data-urlencode "from=$FROM" \
  --data-urlencode "message=$MSG" \
  --data-urlencode "encoding=utf-8" \
  --data-urlencode "format=json" \
  --data-urlencode "test=$TEST")

# Print response with phone numbers redacted (Claude reads this output).
printf '%s' "$RESP" | jq -c 'del(.list[]?.number, .list[]?.submitted_number,
                              .invalid_numbers[]?.number, .invalid_numbers[]?.submitted_number)'
# ponytail: error detection by JSON key only; parse message/points if ever needed
printf '%s' "$RESP" | jq -e 'has("error") | not' >/dev/null
