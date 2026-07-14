#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
status=0

fail() {
  printf 'check-model-routing: %s\n' "$1" >&2
  status=1
}

require_file() {
  if [ ! -f "$1" ]; then
    fail "missing file: ${1#$repo_root/}"
  fi
}

require_text() {
  file=$1
  text=$2
  if ! grep -Fq -- "$text" "$file"; then
    fail "${file#$repo_root/}: missing required adapter field: $text"
  fi
}

codex_dir="$repo_root/skills/subagent-driven-development/agents/codex"

check_codex_profile() {
  name=$1
  model=$2
  effort=$3
  sandbox=$4
  file="$codex_dir/$name.toml"
  require_file "$file"
  if [ -f "$file" ]; then
    require_text "$file" "name = \"$name\""
    require_text "$file" "model = \"$model\""
    require_text "$file" "model_reasoning_effort = \"$effort\""
    require_text "$file" "sandbox_mode = \"$sandbox\""
    if [ "$sandbox" = workspace-write ]; then
      require_text "$file" 'Do not spawn subagents.'
    else
      require_text "$file" 'Do not mutate files and do not spawn subagents.'
    fi
  fi
}

check_codex_profile engineering-worker-bounded-medium gpt-5.6-luna medium workspace-write
check_codex_profile engineering-worker-bounded-high gpt-5.6-luna high workspace-write
check_codex_profile engineering-worker-integrated-medium gpt-5.6-terra medium workspace-write
check_codex_profile engineering-worker-integrated-high gpt-5.6-terra high workspace-write
check_codex_profile engineering-worker-demanding-high gpt-5.6-sol high workspace-write
check_codex_profile engineering-worker-demanding-xhigh gpt-5.6-sol xhigh workspace-write
check_codex_profile engineering-worker-exceptional-xhigh gpt-5.6-sol xhigh workspace-write
check_codex_profile engineering-worker-exceptional-max gpt-5.6-sol max workspace-write
check_codex_profile engineering-reviewer-integrated-high gpt-5.6-terra high read-only
check_codex_profile engineering-reviewer-integrated-xhigh gpt-5.6-terra xhigh read-only
check_codex_profile engineering-reviewer-demanding-high gpt-5.6-sol high read-only
check_codex_profile engineering-reviewer-demanding-xhigh gpt-5.6-sol xhigh read-only
check_codex_profile engineering-reviewer-exceptional-xhigh gpt-5.6-sol xhigh read-only
check_codex_profile engineering-reviewer-exceptional-max gpt-5.6-sol max read-only

if [ -d "$codex_dir" ]; then
  codex_count=$(find "$codex_dir" -type f -name '*.toml' | wc -l | tr -d ' ')
  if [ "$codex_count" != 14 ]; then
    fail "expected 14 Codex profiles, found $codex_count"
  fi
  codex_model_count=$(grep -h '^model = ' "$codex_dir"/*.toml | wc -l | tr -d ' ')
  codex_effort_count=$(grep -h '^model_reasoning_effort = ' "$codex_dir"/*.toml | wc -l | tr -d ' ')
  if [ "$codex_model_count" != 14 ] || [ "$codex_effort_count" != 14 ]; then
    fail 'each Codex profile must declare exactly one pinned model and effort'
  fi
fi

if [ "$status" -ne 0 ]; then
  exit 1
fi

printf 'check-model-routing: clean\n'
