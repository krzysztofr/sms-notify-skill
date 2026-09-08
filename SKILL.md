---
name: sms-notify
description: Use ONLY when the user explicitly asks for an SMS / text message - "sms me", "text me", "send me an sms when done", "/sms-notify". Do NOT use for generic "notify me" or "remind me" - ask which channel if unclear.
---

# sms-notify

Sends an SMS to the user's phone via smsapi.pl. Typical use: user starts a
long task and says "text me when it's done" - finish the task, then send.

## Send

1. Compose the message: max 160 characters, plain text, one line. Include
   the project directory name and the outcome (success / failure + one
   decisive detail). Diacritics are transliterated by the API
   (`normalize=1`), so Polish text is fine but counts as ASCII length.
2. Run:

```sh
~/.claude/skills/sms-notify/send.sh "<message>"
```

3. Exit 0 and JSON with `"status": "QUEUE"` means sent - confirm to the
   user in one line. Non-zero exit: quote the `message` field from the
   JSON (or the curl error) and stop. Do NOT fall back to any other
   notification channel.

## Dry run

`send.sh --test "<message>"` hits the API with `test=1`: full validation,
no SMS sent, no credits used. Use it when verifying setup.

## Notes

- Recipient number, token: macOS Keychain items `smsapi-to`,
  `smsapi-token` (see README). Never print them.
- Sender name is hardcoded `Alert` in `send.sh` (must be a verified
  sender in the smsapi.pl account).
- One SMS per request. If the user asks for periodic texts, say no and
  offer a single summary text instead.
