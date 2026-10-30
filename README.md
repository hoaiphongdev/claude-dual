# claude-dual

[![CI](https://github.com/hoaiphongdev/claude-dual/actions/workflows/ci.yml/badge.svg)](https://github.com/hoaiphongdev/claude-dual/actions/workflows/ci.yml)

Run several **Claude Desktop** accounts side by side on one Mac — each with its own login, chats, settings, connectors and Claude Code sessions. No logging out, no mixing.

[Tiếng Việt](#tiếng-việt) · [English](#english)

> Unofficial. Not affiliated with or endorsed by Anthropic. It relies on Claude Desktop honouring `--user-data-dir`; CI tests that against the latest Claude every day.

---

## Tiếng Việt

### Cách hoạt động

App Claude bình thường của bạn vẫn là **account 1**. Mỗi profile tạo thêm một app nhỏ `Claude <Tên>.app` trong `~/Applications`. App này mở **chính Claude.app gốc** (không sửa, không ký lại) với:

- `--user-data-dir` riêng → đăng nhập, chat, cài đặt, connector, MCP tách riêng
- `CLAUDE_CONFIG_DIR` riêng → Claude Code trong app cũng tách riêng

Claude vẫn tự cập nhật như bình thường. Mỗi profile có icon riêng (màu + chữ cái) để không bao giờ bấm nhầm.

### Cài đặt

```bash
git clone https://github.com/hoaiphongdev/claude-dual.git
cd claude-dual
./claude-dual create Work --dock     # tạo "Claude Work", ghim lên Dock
./claude-dual login Work             # đăng nhập account 2
```

Muốn gõ `claude-dual` ở mọi nơi: `echo "alias claude-dual='$PWD/claude-dual'" >> ~/.zshrc`

### Lệnh

| Lệnh | Tác dụng |
|---|---|
| `create <Tên> [--color teal] [--dock] [--open]` | Tạo launcher. Chạy lại để build lại, dữ liệu giữ nguyên |
| `login <Tên>` | Tắt các cửa sổ Claude khác (có hỏi trước) rồi mở profile để đăng nhập |
| `open <Tên>` | Mở profile, hoặc focus nếu đang mở |
| `list` | Danh sách profile, cái nào đang chạy |
| `doctor` | Kiểm tra bản Claude, launcher, và profile có thật sự tách dữ liệu không |
| `rebuild` | Build lại mọi launcher (sau khi `git pull` bản mới) |
| `remove <Tên> [--purge]` | Xóa launcher; `--purge` xóa luôn dữ liệu (có hỏi) |

Màu: `indigo teal rose amber violet sky emerald slate` hoặc `#RRGGBB`.

### Lưu ý quan trọng

- **Đăng nhập lần đầu phải dùng `login`.** Claude gửi link đăng nhập (`claude://`) vào cửa sổ Claude nào mở *trước*, không phải cửa sổ bạn đang đăng nhập ([anthropics/claude-code#98549](https://github.com/anthropics/claude-code/issues/98549)). `login` tắt các cửa sổ khác trước để tránh việc này. Đăng nhập xong thì mở lại thoải mái.
- **Sau khi Claude tự cập nhật và tự mở lại**, cửa sổ đó có thể mất `CLAUDE_CONFIG_DIR` (bug [#90868](https://github.com/anthropics/claude-code/issues/90868)). Chạy `./claude-dual doctor`; nếu nó báo, chỉ cần tắt (⌘Q) rồi mở lại từ launcher.
- Khi đang chạy, Dock vẫn hiện icon Claude gốc cho mọi cửa sổ (macOS gom theo app). Icon riêng nằm ở launcher đã ghim. Luôn nhìn email account ở góc dưới bên trái trước khi làm việc quan trọng.
- Dữ liệu nằm trong `~/Library/Application Support/claude-dual/profiles/<tên>/`. Đừng symlink thư mục này (VM của Cowork sẽ lỗi).
- Chỉ hỗ trợ macOS. Trên Windows, Claude bản 2.42304 đang bỏ qua `--user-data-dir` ([#103068](https://github.com/anthropics/claude-code/issues/103068)).
- Lần đầu mở launcher, macOS có thể hỏi xác nhận: chuột phải → Open.

### Gỡ cài đặt

```bash
./claude-dual remove Work --purge
```

---

## English

### How it works

Your normal Claude app stays **account 1**. Each profile adds a tiny `Claude <Label>.app` in `~/Applications` that starts the **real, unmodified Claude.app** with:

- its own `--user-data-dir` → separate login, chats, settings, connectors, MCP config
- its own `CLAUDE_CONFIG_DIR` → separate Claude Code sessions

Claude keeps updating itself normally. Each launcher gets an original icon (colour + initials) so you never click the wrong one.

### Install

```bash
git clone https://github.com/hoaiphongdev/claude-dual.git
cd claude-dual
./claude-dual create Work --dock
./claude-dual login Work
```

### Commands

| Command | What it does |
|---|---|
| `create <Label> [--color teal] [--dock] [--open]` | Make a launcher. Re-run to rebuild; data is kept |
| `login <Label>` | Quit other Claude windows (asks first), open the profile to sign in |
| `open <Label>` | Open the profile, or focus it if already open |
| `list` | Profiles and which are running |
| `doctor` | Check Claude version, launchers, and that data is really isolated |
| `rebuild` | Rebuild all launchers (after `git pull`) |
| `remove <Label> [--purge]` | Remove the launcher; `--purge` also deletes its data (asks) |

### Caveats

- **Sign in with `login`.** Claude routes the `claude://` sign-in link to the Claude window that was opened *first* ([#98549](https://github.com/anthropics/claude-code/issues/98549)), so `login` closes the others first.
- **After Claude auto-updates and relaunches itself**, that window may lose `CLAUDE_CONFIG_DIR` ([#90868](https://github.com/anthropics/claude-code/issues/90868)). `doctor` detects it; quit and reopen from the launcher.
- Running windows all show the standard Claude Dock icon; the custom icon is on the pinned launcher. Check the account in the bottom-left corner before sensitive work.
- macOS only.

### How compatibility is checked

[`tests/e2e-macos.sh`](tests/e2e-macos.sh) runs in GitHub Actions on real macOS runners, daily, against the latest Claude Desktop from Homebrew. It creates two profiles, opens both side by side, and fails if Claude writes to the default folder, shares a process between profiles, drops `CLAUDE_CONFIG_DIR`, or opens a duplicate when a launcher is clicked twice. Sign-in itself needs a real account, so it isn't tested in CI.

## License

MIT
