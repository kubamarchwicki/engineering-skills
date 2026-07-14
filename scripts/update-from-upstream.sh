#!/usr/bin/env bash
# Three-way merge of upstream changes into skills/.
#   base   = file at the submodule SHA pinned in HEAD (last sync point)
#   ours   = the copy under skills/ (carries our rewirings)
#   theirs = file at the target upstream commit (default: origin/HEAD after fetch)
# Prints a report; never commits, never bumps the submodule pins.
# The repo-local update-from-upstream skill drives the walk-through and close-out.
#
# Usage: scripts/update-from-upstream.sh [--to <submodule>=<committish>]...
#   --to pins a submodule's merge target and skips its fetch (used by tests).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TSV="$REPO/provenance.tsv"
cd "$REPO"

TO_MATTPOCOCK=""
TO_SUPERPOWERS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --to)
      case "${2:-}" in
        mattpocock-skills=*) TO_MATTPOCOCK="${2#*=}" ;;
        superpowers=*)       TO_SUPERPOWERS="${2#*=}" ;;
        *) echo "usage: $0 [--to <mattpocock-skills|superpowers>=<committish>]..." >&2; exit 2 ;;
      esac
      shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -n "$(git status --porcelain skills/ provenance.tsv)" ]; then
  echo "ABORT: skills/ or provenance.tsv has uncommitted changes - commit or restore first" >&2
  exit 2
fi

total_conflicts=0
total_attention=0
total_candidates=0

merge_skill() {
  local sub="$1" base="$2" target="$3" name="$4" srcpath="$5"
  local ours_dir="skills/$name"

  # Source path gone at target: rename (fix provenance.tsv, re-run) or deletion
  # (fork-or-drop decision in the walk-through). Never auto-repaired.
  if ! git -C "$sub" rev-parse --verify --quiet "$target:$srcpath/SKILL.md" >/dev/null; then
    echo "   ATTENTION $name: $srcpath missing at target (rename or deletion):"
    git -C "$sub" diff -M --name-status "$base" "$target" -- "$srcpath" | sed 's/^/     /' || true
    echo "     rename: fix source_path in provenance.tsv and re-run"
    echo "     deletion: decide fork-or-drop in the walk-through"
    total_attention=$((total_attention+1))
    return
  fi

  local changed=0 added=0 deleted=0 kept=0 nconf=0
  local f rel ours bsha tsha tmpb tmpt
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    rel="${f#"$srcpath"/}"
    ours="$ours_dir/$rel"
    bsha="$(git -C "$sub" rev-parse --verify --quiet "$base:$f" || true)"
    tsha="$(git -C "$sub" rev-parse --verify --quiet "$target:$f" || true)"
    [ "$bsha" = "$tsha" ] && continue           # unchanged upstream
    if [ -z "$bsha" ]; then                     # added upstream
      if [ -e "$ours" ] || [ -L "$ours" ]; then
        echo "   ! $ours: upstream added path but it already exists locally - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
        continue
      fi
      mkdir -p "$(dirname "$ours")"
      git -C "$sub" show "$target:$f" > "$ours"
      if git -C "$sub" ls-tree "$target" -- "$f" | grep -q '^100755'; then chmod +x "$ours"; fi
      echo "   + $ours (new upstream file)"
      added=$((added+1))
    elif [ -z "$tsha" ]; then                   # deleted upstream
      if [ -f "$ours" ] && [ "$(git hash-object "$ours")" = "$bsha" ]; then
        rm "$ours"
        echo "   - $ours (deleted upstream)"
        deleted=$((deleted+1))
      elif [ -f "$ours" ]; then
        echo "   ! $ours: deleted upstream but locally modified - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
      fi
    else                                        # modified upstream
      if [ ! -f "$ours" ]; then
        echo "   ! $ours: missing locally - copying upstream version"
        mkdir -p "$(dirname "$ours")"
        git -C "$sub" show "$target:$f" > "$ours"
        added=$((added+1))
        continue
      fi
      tmpb="$(mktemp)"; tmpt="$(mktemp)"
      git -C "$sub" show "$base:$f"   > "$tmpb"
      git -C "$sub" show "$target:$f" > "$tmpt"
      if git merge-file -L "ours ($name)" -L "base" -L "upstream" "$ours" "$tmpb" "$tmpt"; then
        changed=$((changed+1))
      else
        echo "   CONFLICT: $ours (markers left in file)"
        nconf=$((nconf+1)); total_conflicts=$((total_conflicts+1)); changed=$((changed+1))
      fi
      rm -f "$tmpb" "$tmpt"
    fi
  done < <( { git -C "$sub" ls-tree -r --name-only "$base" -- "$srcpath"; \
              git -C "$sub" ls-tree -r --name-only "$target" -- "$srcpath"; } | sort -u )

  if [ $((changed + added + deleted + kept)) -eq 0 ]; then
    echo "   = $name: unchanged"
  else
    echo "   ok $name: $changed merged ($nconf conflicts), $added added, $deleted deleted, $kept kept"
  fi
}

merge_submodule() {
  local sub="$1" override="$2"
  local base target
  base="$(git rev-parse "HEAD:$sub")"
  if [ -n "$override" ]; then
    target="$(git -C "$sub" rev-parse --verify "$override^{commit}")"
  else
    git -C "$sub" fetch --quiet origin
    target="$(git -C "$sub" rev-parse --verify --quiet origin/HEAD \
           || git -C "$sub" rev-parse --verify origin/main)"
  fi
  echo "== $sub: ${base:0:9} -> ${target:0:9}"
  if [ "$base" = "$target" ]; then
    echo "   up to date"
    return
  fi

  local name srcpath
  while IFS=$'\t' read -r name srcpath; do
    merge_skill "$sub" "$base" "$target" "$name" "$srcpath"
  done < <(awk -F'\t' -v s="$sub" 'NR>1 && $4=="imported" && $2==s {print $1 "\t" $3}' "$TSV")

  # Membership: a skill dir at target is NEW only if its name is neither in the
  # manifest (any status) nor present anywhere at base. Category moves of
  # never-imported skills therefore stay quiet.
  local known base_names dir bn desc
  known="$(awk -F'\t' 'NR>1 {print $1}' "$TSV")"
  base_names="$(git -C "$sub" ls-tree -r --name-only "$base" | awk -F/ '/\/SKILL\.md$/ {print $(NF-1)}' | sort -u)"
  while IFS= read -r dir; do
    [ -n "$dir" ] || continue
    bn="${dir##*/}"
    if printf '%s\n' "$known" | grep -qx "$bn"; then continue; fi
    if printf '%s\n' "$base_names" | grep -qx "$bn"; then continue; fi
    desc="$(git -C "$sub" show "$target:$dir/SKILL.md" | awk '/^description:/ {sub(/^description: */, ""); print; exit}')"
    echo "   NEW-CANDIDATE: $dir - $desc"
    total_candidates=$((total_candidates+1))
  done < <(git -C "$sub" ls-tree -r --name-only "$target" | grep '/SKILL\.md$' | sed 's|/SKILL\.md$||' || true)
}

merge_submodule mattpocock-skills "$TO_MATTPOCOCK"
merge_submodule superpowers "$TO_SUPERPOWERS"

echo
echo "SUMMARY: conflicts=$total_conflicts attention=$total_attention new-candidates=$total_candidates"
echo "Working tree updated; nothing committed, submodule pins not bumped."
