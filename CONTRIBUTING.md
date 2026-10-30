# Contributing

## Commit messages (enforced)

Every commit subject must be:

```
<emoji> <type>[(scope)][!]: <message>
```

Examples:

```
✨ feat: add --color option
🐛 fix(login): wait for other windows to quit
📝 docs: explain the sign-in caveat
```

The emoji must match the type:

| Emoji | Type | Use for |
|---|---|---|
| ✨ | `feat` | New feature |
| 🐛 | `fix` | Bug fix |
| 📝 | `docs` | Documentation only |
| 💄 | `style` | Formatting, no behaviour change |
| ♻️ | `refactor` | Code change that is neither a fix nor a feature |
| ⚡️ | `perf` | Performance |
| ✅ | `test` | Tests |
| 👷 | `ci` | CI / build automation |
| 🔧 | `chore` | Tooling, config, maintenance |
| 🔒 | `security` | Security fix or hardening |
| 🔖 | `release` | Version bump / release |
| ⏪ | `revert` | Revert a previous commit |

Scope is optional, lowercase (`a-z 0-9 . _ / -`). Add `!` for breaking changes.

It is enforced by a `commit-msg` hook. Enable it once per clone:

```bash
git config core.hooksPath .githooks
```

Check a message by hand: `./scripts/check-commit-msg.sh -m "✨ feat: something"`

## Development

```bash
shellcheck -x claude-dual scripts/*.sh .githooks/commit-msg tests/*.sh
bash tests/unit.sh
bash tests/commit-msg.sh
```

`claude-dual` must stay compatible with macOS's built-in bash 3.2 (no associative arrays, no `${var,,}`, no `mapfile`). Run the unit tests with `/bin/bash` on a Mac to check this.
