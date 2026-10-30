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
| 👷 | `ci` | CI / GitHub Actions |
| 🔧 | `chore` | Tooling, config, maintenance |
| 🔒 | `security` | Security fix or hardening |
| 🔖 | `release` | Version bump / release |
| ⏪ | `revert` | Revert a previous commit |

Scope is optional, lowercase (`a-z 0-9 . _ / -`). Add `!` for breaking changes.

It is enforced in two places:

- **Locally**, by a `commit-msg` hook. Enable it once per clone:

  ```bash
  git config core.hooksPath .githooks
  ```

- **In CI**, by the `commit-format` job, which checks every commit in a push or pull request.

Check a message by hand: `./scripts/check-commit-msg.sh -m "✨ feat: something"`

## Development

```bash
shellcheck -x claude-dual scripts/*.sh .githooks/commit-msg tests/*.sh
bash tests/unit.sh
bash tests/commit-msg.sh
```

`claude-dual` must stay compatible with macOS's built-in bash 3.2 (no associative arrays, no `${var,,}`, no `mapfile`). CI runs the unit tests with `/bin/bash` on macOS to catch this.

`tests/e2e-macos.sh` opens real Claude Desktop instances. It runs in CI on macOS runners; run it locally only if you're fine with it creating and removing "Claude CI One/Two" launchers.
