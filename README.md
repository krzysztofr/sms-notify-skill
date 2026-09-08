# sms-notify-skill

A [Claude Code](https://claude.com/claude-code) skill that sends you an SMS
via [smsapi.pl](https://www.smsapi.pl) when you ask for it - e.g. "run the
migration and text me when it's done" while you are away from your desk.

One bash script, one `SKILL.md`. Credentials live in the macOS Keychain, not
in files.

## Requirements

- macOS (uses `security` for Keychain access)
- `curl`, `jq`
- An smsapi.pl account with credits, an OAuth API token
  ([generate here](https://ssl.smsapi.pl/react/oauth/manage)) and a verified
  sender name

## Installation

1. Clone and symlink into Claude Code's skills directory:

   ```sh
   git clone https://github.com/krzysztofr/sms-notify-skill.git ~/work/sms-notify-skill
   ln -s ~/work/sms-notify-skill ~/.claude/skills/sms-notify
   ```

2. Store the token and your phone number in the Keychain (values never touch
   disk in plaintext and are never shown to Claude):

   ```sh
   security add-generic-password -a "$USER" -s smsapi-token -w '<your_oauth_token>'
   security add-generic-password -a "$USER" -s smsapi-to -w '48xxxxxxxxx'
   ```

   Phone number format: country code without `+`, e.g. `48501234567`.

3. Set the sender name. Edit `FROM="Alert"` in `send.sh` to a sender name
   verified in your smsapi.pl account. Unverified accounts can use `Test`.

4. Dry run (validates everything, sends nothing, uses no credits):

   ```sh
   ~/.claude/skills/sms-notify/send.sh --test "hello"
   ```

   Expected: JSON with `"status": "QUEUE"` and exit code 0.

5. Restart Claude Code (or start a new session) so it picks up the skill.

## Usage

In any Claude Code session:

> run the full test suite and sms me when it's done

Claude finishes the task, composes a message under 160 characters with the
project name and the outcome, and runs `send.sh`. The skill fires only on an
explicit request for an SMS / text message.

Manual use:

```sh
~/.claude/skills/sms-notify/send.sh "deploy finished OK"
```

## Files

- `send.sh` - reads Keychain, POSTs to `https://api.smsapi.pl/sms.do`,
  prints the JSON response, exits non-zero on API error
- `SKILL.md` - instructions Claude Code follows

## License

MIT - see [LICENSE](LICENSE). Attribution (keeping the copyright notice) is
required.
