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

1. Install as a Claude Code plugin (the repo is its own marketplace):

   ```sh
   claude plugin marketplace add krzysztofr/sms-notify-skill
   claude plugin install sms-notify@sms-notify-skill
   ```

   Update later with `claude plugin update sms-notify`.

   Alternative for hacking on it - clone and symlink as a plain skill:

   ```sh
   git clone https://github.com/krzysztofr/sms-notify-skill.git ~/work/sms-notify-skill
   ln -s ~/work/sms-notify-skill/skills/sms-notify ~/.claude/skills/sms-notify
   ```

   Do not use both at once or Claude sees the skill twice.

2. Store the token and your phone number in the Keychain (values never touch
   disk in plaintext and are never shown to Claude):

   ```sh
   security add-generic-password -a "$USER" -s smsapi-token -w '<your_oauth_token>'
   security add-generic-password -a "$USER" -s smsapi-to -w '48xxxxxxxxx'
   ```

   Phone number format: country code without `+`, e.g. `48501234567`.

3. Set the sender name. Edit `FROM="Alert"` in `skills/sms-notify/send.sh`
   to a sender name verified in your smsapi.pl account (unverified accounts
   can use `Test`). Note: a plugin install is overwritten on update, so for a
   permanent change fork the repo or use the symlink install.

4. Dry run (validates everything, sends nothing, uses no credits):

   ```sh
   "$(ls -d ~/.claude/plugins/cache/sms-notify-skill/sms-notify/*/ | tail -1)skills/sms-notify/send.sh" --test "hello"
   ```

   Expected: JSON with `"status": "QUEUE"` and exit code 0.

5. Restart Claude Code (or start a new session) so it picks up the skill.

## Usage

In any Claude Code session:

> run the full test suite and sms me when it's done

Claude finishes the task, composes a short message with the outcome, and runs
`send.sh`. Every message is prefixed with the project name: the git repo root
directory name, or the current directory name outside git, e.g.
`my-api: migration done, 0 errors`. The skill fires only on an explicit request
for an SMS / text message.

`send.sh` prepends the project name, transliterates Polish letters and typographic
dashes/quotes to ASCII, drops any other non-ASCII characters and the GSM-7
extension characters (`[]{}\^~|`, which cost two characters each), and cuts
the result at 160 characters so it always fits in a single SMS part.

Manual use: run `skills/sms-notify/send.sh "deploy finished OK"` from wherever
the plugin is installed.

## Files

- `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` - plugin
  and single-plugin marketplace manifests
- `skills/sms-notify/SKILL.md` - instructions Claude Code follows
- `skills/sms-notify/send.sh` - normalizes the message to a single ASCII SMS part, reads
  Keychain, POSTs to `https://api.smsapi.pl/sms.do`, prints the JSON
  response, exits non-zero on API error

## License

MIT - see [LICENSE](LICENSE). Attribution (keeping the copyright notice) is
required.
