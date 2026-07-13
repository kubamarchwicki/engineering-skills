#!/usr/bin/env bash
# Link every skill in this repo into the harness skill directories.
# Idempotent: re-run after adding, removing, or renaming a skill.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO/skills"
TARGETS=("$HOME/.agents/skills" "$HOME/.claude/skills")
status=0

for target in "${TARGETS[@]}"; do
  mkdir -p "$target"

  # prune dead symlinks and stale links into this repo's skills dir
  for link in "$target"/*; do
    [ -L "$link" ] || continue
    if [ ! -e "$link" ]; then
      rm "$link"; echo "pruned dead link: $link"
    elif [[ "$(readlink "$link")" == "$SKILLS_DIR"/* ]] && [ ! -d "$SKILLS_DIR/$(basename "$link")" ]; then
      rm "$link"; echo "pruned removed skill: $link"
    fi
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

exit $status
