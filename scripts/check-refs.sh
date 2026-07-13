#!/usr/bin/env bash
# Whole-set dangling-reference sweep: fails if any skill still references
# dropped upstream skill names, prefixes, or paths.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"
bad=0

if grep -rn "superpowers:\|setup-matt-pocock\|docs/superpowers\|ask-matt" skills/ --include=SKILL.md; then
  bad=1
fi
if grep -rln "brainstorming skill\|requesting-code-review\|finishing-a-development-branch" skills/ --include=SKILL.md; then
  bad=1
fi

if [ "$bad" -eq 0 ]; then
  echo "check-refs: clean"
fi
exit "$bad"
