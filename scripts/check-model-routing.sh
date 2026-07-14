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

claude_dir="$repo_root/skills/subagent-driven-development/agents/claude"

check_claude_profile() {
  name=$1
  model=$2
  effort=$3
  authority=$4
  file="$claude_dir/$name.md"
  require_file "$file"
  if [ -f "$file" ]; then
    require_text "$file" "name: $name"
    require_text "$file" "model: $model"
    require_text "$file" "effort: $effort"
    if [ "$authority" = worker ]; then
      require_text "$file" 'disallowedTools: Agent'
      require_text "$file" 'Do not spawn subagents.'
    else
      require_text "$file" 'tools: Read, Grep, Glob'
      require_text "$file" 'Do not mutate files and do not spawn subagents.'
    fi
  fi
}

check_claude_profile engineering-worker-bounded-medium claude-sonnet-5 medium worker
check_claude_profile engineering-worker-bounded-high claude-sonnet-5 high worker
check_claude_profile engineering-worker-integrated-medium claude-sonnet-5 medium worker
check_claude_profile engineering-worker-integrated-high claude-sonnet-5 high worker
check_claude_profile engineering-worker-demanding-high claude-opus-4-8 high worker
check_claude_profile engineering-worker-demanding-xhigh claude-opus-4-8 xhigh worker
check_claude_profile engineering-worker-exceptional-xhigh claude-fable-5 xhigh worker
check_claude_profile engineering-worker-exceptional-max claude-fable-5 max worker
check_claude_profile engineering-reviewer-integrated-high claude-sonnet-5 high reviewer
check_claude_profile engineering-reviewer-integrated-xhigh claude-sonnet-5 xhigh reviewer
check_claude_profile engineering-reviewer-demanding-high claude-opus-4-8 high reviewer
check_claude_profile engineering-reviewer-demanding-xhigh claude-opus-4-8 xhigh reviewer
check_claude_profile engineering-reviewer-exceptional-xhigh claude-fable-5 xhigh reviewer
check_claude_profile engineering-reviewer-exceptional-max claude-fable-5 max reviewer

if [ -d "$claude_dir" ]; then
  claude_count=$(find "$claude_dir" -type f -name '*.md' | wc -l | tr -d ' ')
  if [ "$claude_count" != 14 ]; then
    fail "expected 14 Claude profiles, found $claude_count"
  fi
  claude_model_count=$(grep -h '^model: ' "$claude_dir"/*.md | wc -l | tr -d ' ')
  claude_effort_count=$(grep -h '^effort: ' "$claude_dir"/*.md | wc -l | tr -d ' ')
  if [ "$claude_model_count" != 14 ] || [ "$claude_effort_count" != 14 ]; then
    fail 'each Claude profile must declare exactly one pinned model and effort'
  fi
fi

recorder="$repo_root/skills/subagent-driven-development/scripts/record-dispatch"

require_file "$recorder"

if [ -f "$recorder" ]; then
  bash -n "$recorder" || fail 'record-dispatch failed bash -n'

  record_tmp=$(mktemp -d "${TMPDIR:-/tmp}/model-routing-record.XXXXXX")
  git -C "$record_tmp" init -q
  sample_record='{"policy_version":2,"event":"started","dispatch_id":"check-1","role":"implementer","work_class":"Bounded","escalation_signals":[],"effective_floor":{"capability":"Bounded","reasoning":"medium"},"dispatch_mode":"Single-Agent","requested":{"profile":"engineering-worker-bounded-medium","model":"gpt-5.6-luna","effort":"medium"},"effective":{"model":null,"effort":null},"floor_verification":{"status":"unverified","evidence":"runtime did not report"},"outcome":{"first_pass":"pending","critical":0,"important":0,"retries":0,"escalation":"none","final_verification":"pending","elapsed":null,"usage":null}}'
  (
    cd "$record_tmp"
    printf '%s\n' "$sample_record" | "$recorder" >/dev/null
  )
  record_file="$record_tmp/.superpowers/model-routing/dispatches.jsonl"
  require_file "$record_file"
  if [ -f "$record_file" ] && [ "$(wc -l < "$record_file" | tr -d ' ')" != 1 ]; then
    fail 'record-dispatch did not append exactly one event'
  fi
  if [ "$(cat "$record_tmp/.superpowers/model-routing/.gitignore")" != '*' ]; then
    fail 'record-dispatch did not self-ignore its workspace'
  fi
  if (
    cd "$record_tmp"
    printf '%s\n' '{"prompt":"secret"}' | "$recorder" >/dev/null 2>&1
  ); then
    fail 'record-dispatch accepted a forbidden prompt field'
  fi
  if (
    cd "$record_tmp"
    printf '%s\n' '{"policy_version":2,"event":"started","dispatch_id":"incomplete","role":"implementer","work_class":"Bounded","escalation_signals":[],"effective_floor":{},"dispatch_mode":"Single-Agent","requested":{},"effective":{},"floor_verification":{},"outcome":{}}' | "$recorder" >/dev/null 2>&1
  ); then
    fail 'record-dispatch accepted missing nested fields'
  fi
  if (
    cd "$record_tmp"
    printf '%s\n' "$sample_record" | sed 's/"policy_version":2/"policy_version":1/' | "$recorder" >/dev/null 2>&1
  ); then
    fail 'record-dispatch accepted the wrong policy version'
  fi
  if [ "$(wc -l < "$record_file" | tr -d ' ')" != 1 ]; then
    fail 'record-dispatch appended a rejected event'
  fi
  rm -rf "$record_tmp"
fi

if [ "$status" -ne 0 ]; then
  exit 1
fi

printf 'check-model-routing: clean\n'
