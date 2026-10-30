#!/bin/bash
# End-to-end test on a real Mac with the installed (latest) Claude Desktop.
# Used by CI. It creates two throwaway profiles, opens both side by side and
# checks that each one really writes to its own folder.
#
# Run locally only if you don't mind it creating "Claude CI One/Two" launchers
# and quitting them again at the end.
set -euo pipefail
cd "$(dirname "$0")/.."

CD="./claude-dual"
APP="/Applications/Claude.app"
PROFILES="$HOME/Library/Application Support/claude-dual/profiles"
DEFAULT_DIR="$HOME/Library/Application Support/Claude"
ART="${E2E_ARTIFACTS:-$PWD/e2e-artifacts}"
mkdir -p "$ART"

step() { printf '\n\033[1m== %s\033[0m\n' "$*"; }
fail() {
  printf '\033[31mFAIL: %s\033[0m\n' "$*"
  screencapture -x "$ART/screen.png" 2>/dev/null || true
  ps -axww -o pid=,args= | grep -i '[c]laude' >"$ART/ps.txt" || true
  for f in "$PROFILES"/*/launcher.log; do [ -f "$f" ] && cp "$f" "$ART/$(basename "$(dirname "$f")").log"; done
  exit 1
}
exe() { echo "$APP/Contents/MacOS/$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Contents/Info.plist")"; }
pids_for() { # data dir -> main pids
  ps -axww -o pid= -o args= | sed -e 's/^ *//' -e 's/ /	/' |
    awk -F'\t' -v exe="$(exe)" -v needle="--user-data-dir=$1" '
      index($2, exe) != 1 || index($2, "--type=") { next }
      { i = index($2, needle); if (!i) next; n = substr($2, i + length(needle), 1)
        if (n == "" || n == " ") print $1 }'
}
wait_for() { # seconds description command...
  local secs="$1" what="$2" i=0; shift 2
  until "$@"; do
    i=$((i + 1)); [ "$i" -le "$secs" ] || fail "timed out after ${secs}s waiting for: $what"
    sleep 1
  done
}
has_items() { [ -n "$(find "$1" -mindepth 1 -maxdepth 1 2>/dev/null | head -1)" ]; }
running() { [ -n "$(pids_for "$1")" ]; }
quit_all() {
  local p
  for p in $(ps -axww -o pid= -o args= | awk -v exe="$(exe)" '{ pid=$1; sub(/^ *[0-9]+ /, "") } index($0, exe) == 1 && !index($0, "--type=") { print pid }'); do
    osascript -l JavaScript -e "ObjC.import('AppKit'); var a=\$.NSRunningApplication.runningApplicationWithProcessIdentifier($p); if (!a.isNil()) a.terminate;" >/dev/null 2>&1 || kill "$p" 2>/dev/null || true
  done
  sleep 5
}

step "Environment"
[ -d "$APP" ] || fail "Claude.app is not installed"
echo "macOS $(sw_vers -productVersion) $(uname -m)"
echo "Claude $(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist") ($(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Contents/Info.plist"))"
echo "Executable: $(exe)"
default_existed=0; [ -d "$DEFAULT_DIR" ] && default_existed=1

step "Create two profiles"
$CD create "CI One" --color teal
$CD create "CI Two"
D1="$PROFILES/ci-one/data"; D2="$PROFILES/ci-two/data"
for L in "CI One" "CI Two"; do
  A="$HOME/Applications/Claude $L.app"
  [ -d "$A" ] || fail "launcher '$A' missing"
  [ -f "$A/Contents/Resources/launch.sh" ] || fail "launch.sh missing in $A"
  [ -f "$A/Contents/Resources/claude-dual.profile" ] || fail "marker missing in $A"
  bash -n "$A/Contents/Resources/launch.sh" || fail "launch.sh has a syntax error"
  id="$(plutil -extract CFBundleIdentifier raw "$A/Contents/Info.plist")"
  case "$id" in io.github.hoaiphongdev.claude-dual.*) echo "bundle id: $id" ;; *) fail "unexpected bundle id $id" ;; esac
  codesign --verify --deep "$A" || fail "launcher signature invalid: $A"
  icon="$A/Contents/Resources/applet.icns"
  [ -s "$icon" ] && [ "$(wc -c <"$icon")" -gt 10000 ] || fail "custom icon was not generated for $A"
  [ ! -e "$A/Contents/Resources/Assets.car" ] || fail "Assets.car still present (would hide custom icon)"
done
cp "$HOME/Applications/Claude CI One.app/Contents/Resources/applet.icns" "$ART/icon-ci-one.icns"

step "Open profile 1 through its launcher"
open "$HOME/Applications/Claude CI One.app"
wait_for 90 "CI One process" running "$D1"
wait_for 90 "CI One writes into its own data folder" has_items "$D1"
P1="$(pids_for "$D1" | head -1)"; echo "CI One pid $P1"
env1="$(ps -E -ww -o command= -p "$P1" || true)"
case "$env1" in
  *"CLAUDE_CONFIG_DIR=$PROFILES/ci-one/claude-code"*) echo "CLAUDE_CONFIG_DIR ok" ;;
  *=*) fail "CLAUDE_CONFIG_DIR not passed to Claude" ;;
  *) echo "(process environment not readable; skipping CLAUDE_CONFIG_DIR check)" ;;
esac

step "Open profile 2 alongside"
$CD open "CI Two"
wait_for 90 "CI Two process" running "$D2"
wait_for 90 "CI Two writes into its own data folder" has_items "$D2"
P2="$(pids_for "$D2" | head -1)"; echo "CI Two pid $P2"
[ "$P1" != "$P2" ] || fail "both profiles share one process"
kill -0 "$P1" || fail "opening profile 2 killed profile 1"

step "Isolation"
if [ "$default_existed" = 0 ]; then
  [ ! -d "$DEFAULT_DIR" ] || fail "Claude wrote to the default folder: --user-data-dir was ignored"
  echo "default folder untouched"
fi
ls "$D1" | head -20 >"$ART/ci-one-data.txt"
ls "$D2" | head -20 >"$ART/ci-two-data.txt"

step "Clicking the launcher again focuses instead of duplicating"
open "$HOME/Applications/Claude CI One.app"
sleep 10
n="$(pids_for "$D1" | wc -l | tr -d ' ')"
[ "$n" = 1 ] || fail "expected 1 CI One process after re-open, found $n"
kill -0 "$P1" || fail "re-open replaced the running CI One process"

step "doctor"
$CD doctor | tee "$ART/doctor.txt" || fail "doctor reported problems"
grep -q "data isolated" "$ART/doctor.txt" || fail "doctor did not confirm isolation"
$CD list

step "Cleanup"
quit_all
$CD remove "CI One" --purge --yes
$CD remove "CI Two" --purge --yes
[ ! -d "$HOME/Applications/Claude CI One.app" ] || fail "launcher not removed"
[ ! -d "$PROFILES/ci-one" ] || fail "profile data not purged"

printf '\n\033[32mE2E PASSED\033[0m\n'
