#!/usr/bin/env bash
# Link every skill and the SDD-owned provider profiles into harness discovery directories.
# Idempotent: re-run after adding, removing, or renaming a skill or profile.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO/skills"
CODEX_PROFILES="$SKILLS_DIR/subagent-driven-development/agents/codex"
CLAUDE_PROFILES="$SKILLS_DIR/subagent-driven-development/agents/claude"
TARGETS=("$HOME/.agents/skills" "$HOME/.claude/skills")
status=0

for target in "${TARGETS[@]}"; do
  mkdir -p "$target"

  # Prune only dead or stale skill links owned by this repository.
  for link in "$target"/*; do
    [ -L "$link" ] || continue
    link_target="$(readlink "$link")"
    case "$link_target" in
      "$SKILLS_DIR"/*)
        if [ ! -e "$link" ] || [ ! -d "$SKILLS_DIR/$(basename "$link")" ]; then
          rm "$link"
          echo "pruned removed skill: $link"
        fi
        ;;
    esac
  done

  for skill in "$SKILLS_DIR"/*/; do
    name="$(basename "$skill")"
    dest="$target/$name"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      echo "SKIP: $dest exists and is not a symlink — remove it manually" >&2
      status=1
      continue
    fi
    ln -sfn "$SKILLS_DIR/$name" "$dest"
    echo "linked: $dest -> $SKILLS_DIR/$name"
  done
done

link_profiles() {
  source_dir=$1
  target_dir=$2
  extension=$3

  if [ ! -d "$source_dir" ]; then
    echo "SKIP: provider profile source is missing: $source_dir" >&2
    status=1
    return
  fi

  mkdir -p "$target_dir"

  # Prune only dead links owned by this repository's provider directory.
  for link in "$target_dir"/engineering-*."$extension"; do
    [ -L "$link" ] || continue
    link_target="$(readlink "$link")"
    case "$link_target" in
      "$source_dir"/*)
        if [ ! -e "$link" ]; then
          rm "$link"
          echo "pruned removed profile: $link"
        fi
        ;;
    esac
  done

  for profile in "$source_dir"/*."$extension"; do
    [ -f "$profile" ] || continue
    name="$(basename "$profile")"
    dest="$target_dir/$name"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      echo "SKIP: $dest exists and is not a symlink — remove it manually" >&2
      status=1
      continue
    fi
    ln -sfn "$profile" "$dest"
    echo "linked: $dest -> $profile"
  done
}

link_profiles "$CODEX_PROFILES" "$HOME/.codex/agents" toml
link_profiles "$CLAUDE_PROFILES" "$HOME/.claude/agents" md

exit $status
