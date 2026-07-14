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

GIT_DIR_CANONICAL="$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)"
GIT_COMMON_DIR_CANONICAL="$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)"
SUPERPROJECT_WORK_TREE="$(git rev-parse --show-superproject-working-tree 2>/dev/null || true)"
if [ -n "$SUPERPROJECT_WORK_TREE" ] || [ "$GIT_DIR_CANONICAL" = "$GIT_COMMON_DIR_CANONICAL" ]; then
  echo "ABORT: upstream sync must run in a linked Git worktree; the primary checkout may be live through global skill symlinks. Run /using-git-worktrees, then re-run /update-from-upstream inside that linked worktree." >&2
  exit 2
fi

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
  local submodule_path="$1" base_commit="$2" target_commit="$3" skill_name="$4" source_path="$5"
  local local_skill_dir="skills/$skill_name"

  # Source path gone at target: rename (manual reconciliation and a hard workflow
  # stop) or deletion (fork-or-drop decision in the walk-through). Never auto-repaired.
  if ! git -C "$submodule_path" rev-parse --verify --quiet "$target_commit:$source_path/SKILL.md" >/dev/null; then
    echo "   ATTENTION $skill_name: $source_path missing at target (rename or deletion):"
    git -C "$submodule_path" diff -M --name-status "$base_commit" "$target_commit" \
      | awk -F'\t' -v source_prefix="$source_path/" 'index($2, source_prefix) == 1 { print }' \
      | sed 's/^/     /' || true
    echo "     rename: STOP; manually reconcile $local_skill_dir and provenance.tsv in the maintenance worktree"
    echo "     deletion: decide fork-or-drop in the walk-through"
    total_attention=$((total_attention+1))
    return
  fi

  local changed=0 added=0 deleted=0 kept=0 conflict_count=0
  local upstream_path relative_path local_path base_entry target_entry local_entry
  local base_mode base_type base_blob target_mode target_type target_blob local_mode local_type local_blob
  local result_mode merge_status temporary_local_file temporary_base_file temporary_target_file temporary_error_file
  local collapsed_prefixes="" expanded_prefixes=""
  local local_ancestor ancestor_rel
  while IFS= read -r upstream_path; do
    [ -n "$upstream_path" ] || continue
    if is_descendant_of_prefixes "$upstream_path" "$collapsed_prefixes"; then continue; fi
    relative_path="${upstream_path#"$source_path"/}"
    local_path="$local_skill_dir/$relative_path"
    base_entry="$(entry_info "$submodule_path" "$base_commit" "$upstream_path")"
    target_entry="$(entry_info "$submodule_path" "$target_commit" "$upstream_path")"
    local_entry="$(entry_info . HEAD "$local_path")"
    base_mode=""; base_type=""; base_blob=""
    target_mode=""; target_type=""; target_blob=""
    local_mode=""; local_type=""; local_blob=""
    if [ -n "$base_entry" ]; then IFS=$'\t' read -r base_mode base_type base_blob <<< "$base_entry"; fi
    if [ -n "$target_entry" ]; then IFS=$'\t' read -r target_mode target_type target_blob <<< "$target_entry"; fi
    if [ -n "$local_entry" ]; then IFS=$'\t' read -r local_mode local_type local_blob <<< "$local_entry"; fi

    if [ -z "$base_entry" ] && [ -n "$target_entry" ]; then
      if ! is_descendant_of_prefixes "$upstream_path" "$expanded_prefixes"; then
        local_ancestor="$(committed_nondirectory_ancestor "$local_skill_dir" "$relative_path" || true)"
        if [ -n "$local_ancestor" ]; then
          ancestor_rel="${local_ancestor#"$local_skill_dir"/}"
          echo "   ! $local_ancestor: upstream added descendants beneath this committed local non-directory - KEPT, resolve in walk-through"
          kept=$((kept+1)); total_attention=$((total_attention+1))
          collapsed_prefixes="${collapsed_prefixes}${source_path}/${ancestor_rel}/"$'\n'
          continue
        fi
      fi
    fi

    [ "$base_entry" = "$target_entry" ] && continue       # unchanged upstream, including mode/type
    if [ -z "$base_entry" ]; then                    # added upstream
      if [ -n "$local_entry" ] || [ -e "$local_path" ] || [ -L "$local_path" ]; then
        echo "   ! $local_path: upstream added path but it already exists locally - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
        continue
      fi
      materialize_entry "$submodule_path" "$target_commit" "$upstream_path" "$local_path" "$target_mode" "$target_type"
      echo "   + $local_path (new upstream file)"
      added=$((added+1))
    elif [ -z "$target_entry" ]; then                 # deleted upstream
      if [ -z "$local_entry" ]; then
        continue
      elif [ "$local_entry" = "$base_entry" ]; then
        remove_local_path "$local_path"
        echo "   - $local_path (deleted upstream)"
        deleted=$((deleted+1))
      else
        echo "   ! $local_path: deleted upstream but locally modified - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
      fi
    else                                        # modified upstream content, mode, or type
      if [ -z "$local_entry" ]; then
        echo "   ! $local_path: modified upstream but locally deleted - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
        if is_tree_transition "$base_type" "$target_type"; then
          collapsed_prefixes="${collapsed_prefixes}${upstream_path}/"$'\n'
        fi
        continue
      fi

      if [ "$local_entry" = "$target_entry" ]; then       # already matches upstream exactly
        if is_tree_transition "$base_type" "$target_type"; then
          collapsed_prefixes="${collapsed_prefixes}${upstream_path}/"$'\n'
        fi
        continue
      fi
      if [ "$local_entry" = "$base_entry" ]; then       # locally unchanged: safe whole-entry fast-forward
        materialize_entry "$submodule_path" "$target_commit" "$upstream_path" "$local_path" "$target_mode" "$target_type"
        if [ "$base_type" = "tree" ] && [ "$target_type" != "tree" ]; then
          collapsed_prefixes="${collapsed_prefixes}${upstream_path}/"$'\n'
        elif [ "$base_type" != "tree" ] && [ "$target_type" = "tree" ]; then
          expanded_prefixes="${expanded_prefixes}${upstream_path}/"$'\n'
        fi
        changed=$((changed+1))
        continue
      fi

      if [ "$local_mode" != "$base_mode" ] && [ "$target_mode" != "$base_mode" ] && [ "$local_mode" != "$target_mode" ]; then
        echo "   ! $local_path: upstream type/mode $base_mode->$target_mode conflicts with local $base_mode->$local_mode - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
        if is_tree_transition "$base_type" "$target_type"; then
          collapsed_prefixes="${collapsed_prefixes}${upstream_path}/"$'\n'
        fi
        continue
      fi
      if ! is_regular_entry "$base_mode" "$base_type" \
          || ! is_regular_entry "$local_mode" "$local_type" \
          || ! is_regular_entry "$target_mode" "$target_type"; then
        echo "   ! $local_path: upstream changed a non-regular/type-transition entry with local changes - KEPT, resolve in walk-through"
        kept=$((kept+1)); total_attention=$((total_attention+1))
        if is_tree_transition "$base_type" "$target_type"; then
          collapsed_prefixes="${collapsed_prefixes}${upstream_path}/"$'\n'
        fi
        continue
      fi

      result_mode="$local_mode"
      if [ "$local_mode" = "$base_mode" ]; then
        result_mode="$target_mode"
      elif [ "$target_mode" = "$base_mode" ]; then
        result_mode="$local_mode"
      elif [ "$local_mode" = "$target_mode" ]; then
        result_mode="$local_mode"
      fi

      if [ "$local_blob" = "$base_blob" ]; then           # only local mode changed
        materialize_entry "$submodule_path" "$target_commit" "$upstream_path" "$local_path" "$target_mode" "$target_type"
        apply_regular_mode "$local_path" "$result_mode"
        changed=$((changed+1))
        continue
      fi
      if [ "$target_blob" = "$base_blob" ]; then           # only upstream mode changed
        if [ "$local_mode" != "$result_mode" ]; then
          apply_regular_mode "$local_path" "$result_mode"
          changed=$((changed+1))
        fi
        continue
      fi
      if [ "$local_blob" = "$target_blob" ]; then           # content already agrees
        if [ "$local_mode" != "$result_mode" ]; then
          apply_regular_mode "$local_path" "$result_mode"
          changed=$((changed+1))
        fi
        continue
      fi

      active_tmp="$(mktemp -d "${TMPDIR:-/tmp}/update-from-upstream.XXXXXX")"
      temporary_local_file="$active_tmp/local"; temporary_base_file="$active_tmp/base"
      temporary_target_file="$active_tmp/upstream"; temporary_error_file="$active_tmp/error"
      cp "$local_path" "$temporary_local_file"
      git -C "$submodule_path" show "$base_commit:$upstream_path"   > "$temporary_base_file"
      git -C "$submodule_path" show "$target_commit:$upstream_path" > "$temporary_target_file"
      merge_status=0
      git merge-file -L "ours ($skill_name)" -L "base" -L "upstream" "$temporary_local_file" "$temporary_base_file" "$temporary_target_file" 2> "$temporary_error_file" \
        || merge_status=$?
      if [ "$merge_status" -le 127 ]; then
        apply_regular_mode "$temporary_local_file" "$result_mode"
        remove_local_path "$local_path"
        mv "$temporary_local_file" "$local_path"
        if [ "$merge_status" -gt 0 ]; then
          echo "   CONFLICT: $local_path (markers left in file)"
          conflict_count=$((conflict_count+1)); total_conflicts=$((total_conflicts+1))
        fi
        changed=$((changed+1))
      else
        echo "   ERROR: $local_path: merge-file failed (exit $merge_status) - KEPT; operational error must be resolved before walk-through"
        if [ -s "$temporary_error_file" ]; then sed 's/^/     /' "$temporary_error_file"; fi
        kept=$((kept+1)); total_attention=$((total_attention+1)); total_errors=$((total_errors+1))
      fi
      cleanup_active_tmp
    fi
  done < <( { git -C "$submodule_path" ls-tree -r --name-only "$base_commit" -- "$source_path"; \
              git -C "$submodule_path" ls-tree -r --name-only "$target_commit" -- "$source_path"; } | sort -u )

  if [ $((changed + added + deleted + kept)) -eq 0 ]; then
    echo "   = $skill_name: unchanged"
  else
    echo "   ok $skill_name: $changed merged ($conflict_count conflicts), $added added, $deleted deleted, $kept kept"
  fi
}

merge_submodule() {
  local submodule_path="$1" target_override="$2"
  local base_commit target_commit
  base_commit="$(git rev-parse "HEAD:$submodule_path")"
  if [ -n "$target_override" ]; then
    target_commit="$(git -C "$submodule_path" rev-parse --verify "$target_override^{commit}")"
  else
    git -C "$submodule_path" fetch --quiet origin
    target_commit="$(git -C "$submodule_path" rev-parse --verify --quiet origin/HEAD \
           || git -C "$submodule_path" rev-parse --verify origin/main)"
  fi
  echo "== $submodule_path: ${base_commit:0:9} -> ${target_commit:0:9}"
  if [ "$base_commit" = "$target_commit" ]; then
    echo "   up to date"
    return
  fi

  local skill_name source_path
  while IFS=$'\t' read -r skill_name source_path; do
    merge_skill "$submodule_path" "$base_commit" "$target_commit" "$skill_name" "$source_path"
  done < <(awk -F'\t' -v selected_submodule="$submodule_path" 'NR>1 && $4=="imported" && $2==selected_submodule {print $1 "\t" $3}' "$TSV")

  # Membership: a skill dir at target is NEW only if its name is neither in the
  # manifest (any status) nor present anywhere at base. Category moves of
  # never-imported skills therefore stay quiet.
  local manifest_names base_skill_names candidate_directory candidate_name candidate_description
  manifest_names="$(awk -F'\t' 'NR>1 {print $1}' "$TSV")"
  base_skill_names="$(git -C "$submodule_path" ls-tree -r --name-only "$base_commit" | awk -F/ '/\/SKILL\.md$/ {print $(NF-1)}' | sort -u)"
  while IFS= read -r candidate_directory; do
    [ -n "$candidate_directory" ] || continue
    candidate_name="${candidate_directory##*/}"
    if printf '%s\n' "$manifest_names" | grep -qx "$candidate_name"; then continue; fi
    if printf '%s\n' "$base_skill_names" | grep -qx "$candidate_name"; then continue; fi
    candidate_description="$(git -C "$submodule_path" show "$target_commit:$candidate_directory/SKILL.md" | awk '/^description:/ {sub(/^description: */, ""); print; exit}')"
    echo "   NEW-CANDIDATE: $candidate_directory - $candidate_description"
    total_candidates=$((total_candidates+1))
  done < <(git -C "$submodule_path" ls-tree -r --name-only "$target_commit" | grep '/SKILL\.md$' | sed 's|/SKILL\.md$||' || true)
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
