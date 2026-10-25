#!/usr/bin/env bash
# Read-only check: committed gitlinks, local checkout state, and live upstream HEADs.
# Exit 1 when an update is needed or any check cannot be completed.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"
git rev-parse --verify HEAD >/dev/null

failed=0
checked=0

fail() {
  printf '::error::%s\n' "$*"
  failed=1
}

# Read pins from HEAD, not the index or the submodule's remote-tracking refs.
while IFS= read -r -d '' entry; do
  metadata="${entry%%$'\t'*}"
  [ "${metadata%% *}" = "160000" ] || continue
  path="${entry#*$'\t'}"
  pinned="${metadata##* }"
  checked=$((checked + 1))

  # An empty submodule directory otherwise lets Git discover the parent repo.
  if [ ! -e "$path/.git" ]; then
    fail "$path: submodule is not initialized. Run git submodule update --init."
    continue
  fi

  current="$(git -C "$path" rev-parse HEAD)"
  if [ "$current" != "$pinned" ]; then
    fail "$path: checkout $current does not match committed pin $pinned."
  fi

  dirty="$(git -C "$path" status --porcelain --untracked-files=all --ignore-submodules=none)"
  if [ -n "$dirty" ]; then
    fail "$path: submodule has uncommitted changes or untracked files."
    printf '%s\n' "$dirty"
  fi

  # Public GitHub sources need no SSH key, including after checkout removes auth.
  # ls-remote reads the current default branch without fetching or moving pins.
  if ! remote_head="$(git -C "$path" \
    -c url.https://github.com/.insteadOf=git@github.com: \
    ls-remote --exit-code origin HEAD)"; then
    fail "$path: cannot read upstream HEAD; freshness could not be checked."
    continue
  fi
  upstream="${remote_head%%$'\t'*}"
  printf '%s: pin=%s checkout=%s upstream=%s\n' "$path" "$pinned" "$current" "$upstream"
  if [ "$pinned" != "$upstream" ]; then
    fail "$path: upstream update needed ($pinned -> $upstream). Run /update-from-upstream in Claude or \$update-from-upstream in Codex."
  fi
done < <(git ls-tree -rz HEAD)

if [ "$checked" -eq 0 ]; then
  fail 'No committed submodules found.'
fi
if [ "$failed" -ne 0 ]; then
  exit 1
fi
printf 'check-upstream: all %s submodules are clean, pinned, and up to date\n' "$checked"
