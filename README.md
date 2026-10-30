# claude-dual

[![CI](https://github.com/hoaiphongdev/claude-dual/actions/workflows/ci.yml/badge.svg)](https://github.com/hoaiphongdev/claude-dual/actions/workflows/ci.yml)

Run several **Claude Desktop** accounts side by side on one Mac — each with its own login, chats, settings, connectors and Claude Code sessions. No logging out, no mixing.

> Unofficial. Not affiliated with or endorsed by Anthropic. It relies on Claude Desktop honouring `--user-data-dir`; CI checks that against the latest Claude Desktop every day.

## How it works

Your normal Claude app stays **account 1**. Each profile adds a tiny `Claude <Label>.app` in `~/Applications` that starts the **real, unmodified Claude.app** with:

- its own `--user-data-dir` → separate login, chats, settings, connectors and MCP config
- its own `CLAUDE_CONFIG_DIR` → separate Claude Code sessions

Claude.app is never patched or re-signed, so it keeps updating itself normally. Each launcher gets an original icon (colour + initials) so you never click the wrong one. Clicking a launcher that is already open focuses its window instead of opening a duplicate.

## Install

```bash
git clone https://github.com/hoaiphongdev/claude-dual.git
cd claude-dual
./claude-dual create Work --dock     # adds "Claude Work" and pins it to the Dock
./claude-dual login Work             # sign in to your second account
```

To call it from anywhere: `echo "alias claude-dual='$PWD/claude-dual'" >> ~/.zshrc`

Requirements: macOS and Claude Desktop ([claude.ai/download](https://claude.ai/download)). Nothing else is installed; it only uses tools that ship with macOS.

## Commands

| Command | What it does |
|---|---|
| `create <Label> [--color teal] [--dock] [--open]` | Make a launcher. Re-run to rebuild; data is kept |
| `login <Label>` | Quit other Claude windows (asks first), then open the profile to sign in |
| `open <Label>` | Open the profile, or focus it if already open |
| `list` | Profiles and which are running |
| `doctor` | Check the Claude version, the launchers, and that data is really isolated |
| `rebuild` | Rebuild all launchers (after `git pull`) |
| `remove <Label> [--purge]` | Remove the launcher; `--purge` also deletes its data (asks first) |

Colours: `indigo teal rose amber violet sky emerald slate`, or `#RRGGBB`. Add `-y` to answer yes to prompts.

## Caveats

- **Sign in with `login`.** Claude sends the `claude://` sign-in link to the Claude window that was opened *first*, not the one you are signing in to ([anthropics/claude-code#98549](https://github.com/anthropics/claude-code/issues/98549)). `login` closes the other windows first. Once signed in, open them all again freely.
- **After Claude auto-updates and relaunches itself**, that window may lose `CLAUDE_CONFIG_DIR` ([#90868](https://github.com/anthropics/claude-code/issues/90868)). `doctor` detects it; quit the window (⌘Q) and reopen it from its launcher.
- While running, every window shows the standard Claude icon in the Dock (macOS groups them by app). The custom icon is on the pinned launcher. Check the account in the bottom-left corner before sensitive work.
- Profile data lives in `~/Library/Application Support/claude-dual/profiles/<label>/`. Don't symlink it; Claude's VM breaks on symlinked data folders.
- The first time you open a launcher, macOS may ask for confirmation: right-click → Open.
- macOS only. On Windows, Claude Desktop 2.42304 currently ignores `--user-data-dir` ([#103068](https://github.com/anthropics/claude-code/issues/103068)).

## How compatibility is checked

[`tests/e2e-macos.sh`](tests/e2e-macos.sh) runs in GitHub Actions on real macOS runners, daily, against the latest Claude Desktop from Homebrew. It creates two profiles, opens both side by side, and fails if Claude writes to the default folder, shares a process between profiles, drops `CLAUDE_CONFIG_DIR`, or opens a duplicate when a launcher is clicked twice. Sign-in needs a real account, so it isn't tested in CI.

## Uninstall

```bash
./claude-dual remove Work --purge
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Commit messages must follow `<emoji> <type>: <message>`, e.g. `✨ feat: add --color option`; this is enforced by a git hook and in CI.

## License

MIT
