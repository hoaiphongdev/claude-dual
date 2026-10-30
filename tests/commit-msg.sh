#!/bin/bash
# Tests for scripts/check-commit-msg.sh
set -u
cd "$(dirname "$0")/.." || exit 1
C=./scripts/check-commit-msg.sh
pass=0; fail=0
good() { if $C -m "$1" 2>/dev/null; then pass=$((pass + 1)); else fail=$((fail + 1)); echo "FAIL (should pass): $1"; fi; }
bad()  { if $C -m "$1" 2>/dev/null; then fail=$((fail + 1)); echo "FAIL (should reject): $1"; else pass=$((pass + 1)); fi; }

good "✨ feat: add --color option"
good "🐛 fix(login): wait for windows to quit"
good "📝 docs: rewrite README"
good "♻️ refactor: split launcher"
good "♻ refactor: split launcher"
good "⚡️ perf: faster ps parsing"
good "⚡ perf: faster ps parsing"
good "👷 ci: run e2e daily"
good "✨ feat!: rename create to add"
good "🔧 chore(deps): bump action"
good "Merge pull request #1 from x/y"
good $'✨ feat: subject\n\nbody line'
bad  "feat: missing emoji"
bad  "✨ missing type"
bad  "✨ fix: emoji does not match type"
bad  "🐛 feat: emoji does not match type"
bad  "✨ feat:no space"
bad  "✨ feat: "
bad  "✨feat: no space after emoji"
bad  "✨ Feat: capital type"
bad  "✨ feat(Bad Scope): x"
bad  "Initial commit"
bad  ""

echo "commit-msg: $pass passed, $fail failed"
[ "$fail" = 0 ]
