#!/bin/bash
# Unit tests for the pure helpers in claude-dual. Runs on macOS and Linux.
set -u
cd "$(dirname "$0")/.." || exit 1
# shellcheck source=./claude-dual
. ./claude-dual
set +e +o pipefail

pass=0; fail=0
eq() { # name expected actual
  if [ "$2" = "$3" ]; then pass=$((pass + 1)); else fail=$((fail + 1)); printf 'FAIL %s\n  expected: [%s]\n  actual:   [%s]\n' "$1" "$2" "$3"; fi
}
okv() { if validate_label "$1" >/dev/null; then eq "valid '$1'" yes yes; else eq "valid '$1'" yes no; fi; }
badv() { if validate_label "$1" >/dev/null; then eq "invalid '$1'" no yes; else eq "invalid '$1'" no no; fi; }

# slugify
eq slug1 "work" "$(slugify Work)"
eq slug2 "big-client" "$(slugify "Big Client")"
eq slug3 "a-b-c" "$(slugify "A _ B--C")"
eq slug4 "client-2" "$(slugify "Client_2")"

# validate_label
okv Work; okv "Big Client"; okv "client_2"; okv "A"; okv "Team-B"
badv ""; badv "-x"; badv ".hidden"; badv " Work"; badv "Work "; badv "Wörk"; badv "a/b"
badv "Default"; badv "claude"; badv "1234567890123456789012345678901"

# colours
eq color1 "#4F46E5" "$(color_hex indigo)"
eq color2 "#abcdef" "$(color_hex '#abcdef')"
if color_hex nope >/dev/null; then eq color3 fail ok; else eq color3 ok ok; fi
eq pick0 indigo "$(palette_pick 0)"
eq pick8 indigo "$(palette_pick 8)"
eq pick1 teal "$(palette_pick 1)"

# icon text
eq icon1 "W" "$(icon_text Work)"
eq icon2 "BC" "$(icon_text "big client")"
eq icon3 "CA" "$(icon_text "client_a")"

# process matching
EXE="/Applications/Claude.app/Contents/MacOS/Claude"
W="/Users/me/Library/Application Support/claude-dual/profiles/work/data"
W2="/Users/me/Library/Application Support/claude-dual/profiles/work2/data"
PS="$(printf '%s\t%s\n' \
  100 "$EXE" \
  200 "$EXE --user-data-dir=$W" \
  201 "/Applications/Claude.app/Contents/Frameworks/Claude Helper.app/Contents/MacOS/Claude Helper --type=renderer --user-data-dir=$W" \
  202 "$EXE --user-data-dir=$W --type=gpu-process" \
  300 "$EXE --user-data-dir=$W2 --some-flag" \
  400 "/usr/bin/vim $EXE --user-data-dir=$W")"
eq match-work "200" "$(printf '%s\n' "$PS" | match_profile_pids "$EXE" "$W" | tr '\n' ' ' | sed 's/ $//')"
eq match-work2 "300" "$(printf '%s\n' "$PS" | match_profile_pids "$EXE" "$W2" | tr '\n' ' ' | sed 's/ $//')"
eq match-main "100 200 300" "$(printf '%s\n' "$PS" | match_main_pids "$EXE" | tr '\n' ' ' | sed 's/ $//')"
eq args-dd "$W" "$(args_data_dir "$EXE --user-data-dir=$W")"
eq args-dd2 "$W2" "$(args_data_dir "$EXE --user-data-dir=$W2 --some-flag")"

# generated launcher script is valid bash and keeps paths with spaces intact
tmp="$(mktemp -d)"
render_launch_script "Big Client" "$W" "/Users/me/x y/claude-code" "/Applications/Claude.app" "/tmp/l o g" >"$tmp/launch.sh"
if bash -n "$tmp/launch.sh"; then eq launch-syntax ok ok; else eq launch-syntax ok bad; fi
(
  eval "$(sed -n '/^LABEL=/,/^BUNDLE_ID=/p' "$tmp/launch.sh")"
  printf '%s|%s|%s\n' "$LABEL" "$DATA_DIR" "$CODE_DIR"
) >"$tmp/vals"
eq launch-vals "Big Client|$W|/Users/me/x y/claude-code" "$(cat "$tmp/vals")"
rm -rf "$tmp"

echo "unit: $pass passed, $fail failed"
[ "$fail" = 0 ]
