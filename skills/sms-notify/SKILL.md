---
name: sms-notify
description: Use ONLY when the user explicitly asks for an SMS / text message - "sms me", "text me", "send me an sms when done", "/sms-notify". Do NOT use for generic "notify me" or "remind me" - ask which channel if unclear.
---

# sms-notify

Sends an SMS to the user's phone via smsapi.pl. Typical use: user starts a
long task and says "text me when it's done" - finish the task, then send.

## Send

1. Compose the message: one line, plain text, max ~130 characters (the
   script prepends `<project>: ` and hard-cuts at 160, so keep the important
   part first). Do not repeat the project name; state the outcome
   (success / failure + one decisive detail). Polish diacritics are
   transliterated to ASCII by the script; anything else non-ASCII is
   dropped, so prefer plain ASCII.
2. Run `send.sh` from this skill's base directory (Claude Code prints
   "Base directory for this skill" when the skill loads):

```sh
"<base directory>/send.sh" "<message>"
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
  `smsapi-token` (see README). Never print them. The script already
  redacts phone numbers from the API response.
- Sender name (`Alert`) is hardcoded in `send.sh`; must be a verified name
  in the smsapi.pl account.
- Prefix is the project name: git repo root directory name, else the
  current directory name. Run `send.sh` from the project directory.
- One SMS per request. If the user asks for periodic texts, say no and
  offer a single summary text instead.
