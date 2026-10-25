#!/usr/bin/env bash
# Read-only check: committed pins/provenance, checkout state, and imported trees.
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

scratch="$(mktemp -d "${TMPDIR:-/tmp}/check-upstream.XXXXXX")"
trap 'rm -rf "$scratch"' EXIT
# Use the manifest from the same committed snapshot as the gitlinks.
if ! git show HEAD:provenance.tsv > "$scratch/provenance.tsv"; then
  fail 'Cannot read committed provenance.tsv.'
  exit 1
fi
if ! awk -F'\t' '
  NR == 1 && $0 != "name\tsubmodule\tsource_path\tstatus\tinv\trole\tchanges" { exit 1 }
  NF != 7 { exit 1 }
  $4 == "imported" && ($2 == "" || $2 == "-" || $3 == "" || $3 == "-") { exit 1 }
  END { if (NR == 0) exit 1 }
' "$scratch/provenance.tsv"; then
  fail 'Invalid committed provenance.tsv; expected seven columns and imported source paths.'
  exit 1
fi
while IFS= read -r source; do
  entry="$(git --literal-pathspecs ls-tree HEAD -- "$source")"
  if [ "${entry%% *}" != "160000" ]; then
    fail "$source: imported provenance entry has no committed submodule."
  fi
done < <(awk -F'\t' 'NR>1 && $4=="imported" {print $2}' "$scratch/provenance.tsv" | sort -u)

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
  # ls-remote reads the current default branch without moving local refs.
  if ! remote_head="$(git -C "$path" \
    -c url.https://github.com/.insteadOf=git@github.com: \
    ls-remote --exit-code origin HEAD)"; then
    fail "$path: cannot read upstream HEAD; freshness could not be checked."
    continue
  fi
  upstream="${remote_head%%$'\t'*}"
  printf '%s: pin=%s checkout=%s upstream=%s\n' "$path" "$pinned" "$current" "$upstream"
  awk -F'\t' -v submodule="$path" 'NR>1 && $4=="imported" && $2==submodule {print $3}' \
    "$scratch/provenance.tsv" > "$scratch/paths"
  if [ ! -s "$scratch/paths" ]; then
    printf '%s: no imported skills to compare\n' "$path"
    continue
  fi

  target_repo="$path"
  if ! git -C "$path" cat-file -e "$upstream^{commit}" 2>/dev/null; then
    # Fetch only into disposable storage; submodule objects, refs, and pins stay put.
    # Tree IDs cover every nested file, addition, deletion, type, and mode change.
    target_repo="$scratch/target-$checked.git"
    remote_url="$(git -C "$path" remote get-url origin)"
    if ! git init --bare --quiet "$target_repo" || ! git -C "$target_repo" \
      -c url.https://github.com/.insteadOf=git@github.com: \
      fetch --quiet --no-tags --depth=1 --filter=blob:none "$remote_url" "$upstream"; then
      fail "$path: cannot inspect upstream HEAD; imported skills could not be checked."
      continue
    fi
  fi

  changed=0
  comparison_failed=0
  while IFS= read -r source_path; do
    if ! base_entry="$(git --literal-pathspecs -C "$path" ls-tree "$pinned" -- "$source_path")" \
      || [ "${base_entry%% *}" != "040000" ]; then
      fail "$path: imported path $source_path is not a directory at the committed pin."
      comparison_failed=1
      continue
    fi
    if ! target_entry="$(git --literal-pathspecs -C "$target_repo" ls-tree "$upstream" -- "$source_path")"; then
      fail "$path: cannot inspect imported path $source_path at upstream HEAD."
      comparison_failed=1
      continue
    fi
    if [ "$base_entry" != "$target_entry" ]; then
      printf '%s: imported path changed: %s\n' "$path" "$source_path"
      changed=1
    fi
  done < "$scratch/paths"
  if [ "$changed" -ne 0 ]; then
    fail "$path: upstream update needed ($pinned -> $upstream). Run /update-from-upstream in Claude or \$update-from-upstream in Codex."
  elif [ "$comparison_failed" -eq 0 ]; then
    printf '%s: imported skills unchanged\n' "$path"
  fi
done < <(git ls-tree -rz HEAD)

if [ "$checked" -eq 0 ]; then
  fail 'No committed submodules found.'
fi
if [ "$failed" -ne 0 ]; then
  exit 1
fi
printf 'check-upstream: all %s submodules are clean and pinned; imported skills are up to date\n' "$checked"
