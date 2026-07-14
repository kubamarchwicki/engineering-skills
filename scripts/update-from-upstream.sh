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
total_errors=0
active_tmp=""

cleanup_active_tmp() {
  if [ -n "$active_tmp" ]; then
    rm -rf "$active_tmp"
    active_tmp=""
  fi
}
trap cleanup_active_tmp EXIT

entry_info() {
  local repo="$1" commit="$2" path="$3"
  local entry
  entry="$(git -C "$repo" ls-tree -d "$commit" -- "$path" \
    | awk 'NR==1 {print $1 "\t" $2 "\t" $3}')"
  if [ -n "$entry" ]; then
    printf '%s\n' "$entry"
  else
    git -C "$repo" ls-tree "$commit" -- "$path" \
      | awk 'NR==1 {print $1 "\t" $2 "\t" $3}'
  fi
}

remove_local_path() {
  local path="$1"
  if [ -d "$path" ] && [ ! -L "$path" ]; then
    rm -rf "$path"
  else
    rm -f "$path"
  fi
}

apply_regular_mode() {
  local path="$1" mode="$2"
  if [ "$mode" = "100755" ]; then
    chmod 755 "$path"
  else
    chmod 644 "$path"
  fi
}

materialize_entry() {
  local sub="$1" commit="$2" src="$3" dest="$4" mode="$5" type="$6"
  local link_target
  mkdir -p "$(dirname "$dest")"

  if [ "$type" = "tree" ]; then
    remove_local_path "$dest"
    mkdir -p "$dest"
    return
  fi

  active_tmp="$(mktemp -d "${TMPDIR:-/tmp}/update-from-upstream.XXXXXX")"
  case "$type:$mode" in
    blob:120000)
      link_target="$(git -C "$sub" show "$commit:$src"; printf x)"
      link_target="${link_target%x}"
      ln -s "$link_target" "$active_tmp/entry"
      ;;
    blob:100644|blob:100755)
      git -C "$sub" show "$commit:$src" > "$active_tmp/entry"
      apply_regular_mode "$active_tmp/entry" "$mode"
      ;;
    *)
      echo "unsupported tree entry: $type $mode" > "$active_tmp/error"
      return 1
      ;;
  esac

  remove_local_path "$dest"
  mv "$active_tmp/entry" "$dest"
  cleanup_active_tmp
}

is_regular_entry() {
  local mode="$1" type="$2"
  [ "$type" = "blob" ] && { [ "$mode" = "100644" ] || [ "$mode" = "100755" ]; }
}

is_tree_transition() {
  local base_type="$1" target_type="$2"
  if [ "$base_type" = "tree" ]; then
    [ "$target_type" != "tree" ]
  else
    [ "$target_type" = "tree" ]
  fi
}

committed_nondirectory_ancestor() {
  local root="$1" relative="$2" current="$1" component entry mode type oid
  while [ "${relative#*/}" != "$relative" ]; do
    component="${relative%%/*}"
    relative="${relative#*/}"
    current="$current/$component"
    entry="$(entry_info . HEAD "$current")"
    if [ -n "$entry" ]; then
      IFS=$'\t' read -r mode type oid <<< "$entry"
      if [ "$type" != "tree" ]; then
        printf '%s\n' "$current"
        return 0
      fi
    fi
  done
  return 1
}

is_descendant_of_prefixes() {
  local candidate="$1" prefixes="$2" prefix
  [ -n "$prefixes" ] || return 1
  while IFS= read -r prefix; do
    [ -n "$prefix" ] || continue
    case "$candidate" in
      "$prefix"*) return 0 ;;
    esac
  done < <(printf '%s' "$prefixes")
  return 1
}

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
  local f rel ours bentry tentry oentry bmode btype bsha tmode ttype tsha omode otype osha
  local result_mode merge_status tmpo tmpb tmpt tmpe collapsed_prefixes="" expanded_prefixes=""
  local local_ancestor ancestor_rel
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if is_descendant_of_prefixes "$f" "$collapsed_prefixes"; then continue; fi
    rel="${f#"$srcpath"/}"
    ours="$ours_dir/$rel"
    bentry="$(entry_info "$sub" "$base" "$f")"
    tentry="$(entry_info "$sub" "$target" "$f")"
    oentry="$(entry_info . HEAD "$ours")"
    bmode=""; btype=""; bsha=""
    tmode=""; ttype=""; tsha=""
    omode=""; otype=""; osha=""
    if [ -n "$bentry" ]; then IFS=$'\t' read -r bmode btype bsha <<< "$bentry"; fi
    if [ -n "$tentry" ]; then IFS=$'\t' read -r tmode ttype tsha <<< "$tentry"; fi
    if [ -n "$oentry" ]; then IFS=$'\t' read -r omode otype osha <<< "$oentry"; fi

    if [ -z "$bentry" ] && [ -n "$tentry" ]; then
      if ! is_descendant_of_prefixes "$f" "$expanded_prefixes"; then
        local_ancestor="$(committed_nondirectory_ancestor "$ours_dir" "$rel" || true)"
        if [ -n "$local_ancestor" ]; then
          ancestor_rel="${local_ancestor#"$ours_dir"/}"
          echo "   ! $local_ancestor: upstream added descendants beneath this committed local non-directory - KEPT, resolve in walk-through"
          kept=$((kept+1)); total_attention=$((total_attention+1))
          collapsed_prefixes="${collapsed_prefixes}${srcpath}/${ancestor_rel}/"$'\n'
          continue
        fi
      fi
    fi

    [ "$bentry" = "$tentry" ] && continue       # unchanged upstream, including mode/type
    if [ -z "$bentry" ]; then                    # added upstream
      if [ -n "$oentry" ] || [ -e "$ours" ] || [ -L "$ours" ]; then
        echo "   ! $ours: upstream added path but it already exists locally - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
        continue
      fi
      materialize_entry "$sub" "$target" "$f" "$ours" "$tmode" "$ttype"
      echo "   + $ours (new upstream file)"
      added=$((added+1))
    elif [ -z "$tentry" ]; then                 # deleted upstream
      if [ -z "$oentry" ]; then
        continue
      elif [ "$oentry" = "$bentry" ]; then
        remove_local_path "$ours"
        echo "   - $ours (deleted upstream)"
        deleted=$((deleted+1))
      else
        echo "   ! $ours: deleted upstream but locally modified - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
      fi
    else                                        # modified upstream content, mode, or type
      if [ -z "$oentry" ]; then
        echo "   ! $ours: modified upstream but locally deleted - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
        if is_tree_transition "$btype" "$ttype"; then
          collapsed_prefixes="${collapsed_prefixes}${f}/"$'\n'
        fi
        continue
      fi

      if [ "$oentry" = "$tentry" ]; then       # already matches upstream exactly
        if is_tree_transition "$btype" "$ttype"; then
          collapsed_prefixes="${collapsed_prefixes}${f}/"$'\n'
        fi
        continue
      fi
      if [ "$oentry" = "$bentry" ]; then       # locally unchanged: safe whole-entry fast-forward
        materialize_entry "$sub" "$target" "$f" "$ours" "$tmode" "$ttype"
        if [ "$btype" = "tree" ] && [ "$ttype" != "tree" ]; then
          collapsed_prefixes="${collapsed_prefixes}${f}/"$'\n'
        elif [ "$btype" != "tree" ] && [ "$ttype" = "tree" ]; then
          expanded_prefixes="${expanded_prefixes}${f}/"$'\n'
        fi
        changed=$((changed+1))
        continue
      fi

      if [ "$omode" != "$bmode" ] && [ "$tmode" != "$bmode" ] && [ "$omode" != "$tmode" ]; then
        echo "   ! $ours: upstream type/mode $bmode->$tmode conflicts with local $bmode->$omode - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
        if is_tree_transition "$btype" "$ttype"; then
          collapsed_prefixes="${collapsed_prefixes}${f}/"$'\n'
        fi
        continue
      fi
      if ! is_regular_entry "$bmode" "$btype" \
          || ! is_regular_entry "$omode" "$otype" \
          || ! is_regular_entry "$tmode" "$ttype"; then
        echo "   ! $ours: upstream changed a non-regular/type-transition entry with local changes - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
        if is_tree_transition "$btype" "$ttype"; then
          collapsed_prefixes="${collapsed_prefixes}${f}/"$'\n'
        fi
        continue
      fi

      result_mode="$omode"
      if [ "$omode" = "$bmode" ]; then
        result_mode="$tmode"
      elif [ "$tmode" = "$bmode" ]; then
        result_mode="$omode"
      elif [ "$omode" = "$tmode" ]; then
        result_mode="$omode"
      fi

      if [ "$osha" = "$bsha" ]; then           # only local mode changed
        materialize_entry "$sub" "$target" "$f" "$ours" "$tmode" "$ttype"
        apply_regular_mode "$ours" "$result_mode"
        changed=$((changed+1))
        continue
      fi
      if [ "$tsha" = "$bsha" ]; then           # only upstream mode changed
        if [ "$omode" != "$result_mode" ]; then
          apply_regular_mode "$ours" "$result_mode"
          changed=$((changed+1))
        fi
        continue
      fi
      if [ "$osha" = "$tsha" ]; then           # content already agrees
        if [ "$omode" != "$result_mode" ]; then
          apply_regular_mode "$ours" "$result_mode"
          changed=$((changed+1))
        fi
        continue
      fi

      active_tmp="$(mktemp -d "${TMPDIR:-/tmp}/update-from-upstream.XXXXXX")"
      tmpo="$active_tmp/ours"; tmpb="$active_tmp/base"; tmpt="$active_tmp/upstream"; tmpe="$active_tmp/error"
      cp "$ours" "$tmpo"
      git -C "$sub" show "$base:$f"   > "$tmpb"
      git -C "$sub" show "$target:$f" > "$tmpt"
      merge_status=0
      git merge-file -L "ours ($name)" -L "base" -L "upstream" "$tmpo" "$tmpb" "$tmpt" 2> "$tmpe" \
        || merge_status=$?
      if [ "$merge_status" -le 127 ]; then
        apply_regular_mode "$tmpo" "$result_mode"
        remove_local_path "$ours"
        mv "$tmpo" "$ours"
        if [ "$merge_status" -gt 0 ]; then
          echo "   CONFLICT: $ours (markers left in file)"
          nconf=$((nconf+1)); total_conflicts=$((total_conflicts+1))
        fi
        changed=$((changed+1))
      else
        echo "   ERROR: $ours: merge-file failed (exit $merge_status) - KEPT; operational error must be resolved before walk-through"
        if [ -s "$tmpe" ]; then sed 's/^/     /' "$tmpe"; fi
        kept=$((kept+1)); total_attention=$((total_attention+1)); total_errors=$((total_errors+1))
      fi
      cleanup_active_tmp
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
if [ "$total_errors" -gt 0 ]; then
  echo "FAILED: operational-errors=$total_errors; affected local files preserved; nothing committed, submodule pins not bumped."
  exit 1
fi
echo "Working tree updated; nothing committed, submodule pins not bumped."
