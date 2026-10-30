# claude-dual — notes for Claude

## Hard rule: commit message format

Every commit subject MUST be `<emoji> <type>[(scope)][!]: <message>`, with the emoji matching the type, e.g. `✨ feat: add --color option`.

Allowed pairs: ✨ feat · 🐛 fix · 📝 docs · 💄 style · ♻️ refactor · ⚡️ perf · ✅ test · 👷 ci · 🔧 chore · 🔒 security · 🔖 release · ⏪ revert

Before committing, run `git config core.hooksPath .githooks` once so the hook validates the message. Never bypass it with `--no-verify`. CI rejects non-conforming commits. Full table in CONTRIBUTING.md.

## Other conventions

- All docs, code comments and CLI output are in English.
- `claude-dual` must run on macOS's bash 3.2.
- Run `shellcheck -x claude-dual scripts/*.sh .githooks/commit-msg tests/*.sh`, `bash tests/unit.sh` and `bash tests/commit-msg.sh` before pushing.
