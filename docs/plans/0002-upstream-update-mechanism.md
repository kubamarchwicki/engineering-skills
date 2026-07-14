# Upstream Update Mechanism Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the imported skill set syncable with its upstream submodules: a provenance manifest as single source of truth, a three-way-merge script that flows upstream content into `skills/` automatically, and a repo-local skill that turns each sync into a grilled walk-through of what upstream changed.

**Architecture:** `provenance.tsv` (repo root) maps every skill to its submodule and source path and drives everything: the README Reference table is *generated* from it, and `scripts/update-from-upstream.sh` merges per file with base = the submodule SHA pinned in HEAD, ours = the `skills/` copy (carrying our rewirings), theirs = the new upstream commit. Judgment stays human: the repo-local `update-from-upstream` skill narrates clean merges, grills conflicts / new skills / deletions one question at a time, and stops before the commit.

**Tech Stack:** bash (macOS /bin/bash 3.2-compatible), awk, git (`merge-file`, `ls-tree`, `rev-parse`), Markdown skill files (Agent Skills format, with repository discovery for Claude and Codex).

## Global Constraints

- Repo root: `/Users/jakub/workspaces/engineering-skills`. All commands run from the repo root unless stated.
- **Prerequisite:** plan 0001 fully executed and committed — `skills/` populated with the 22 skills, `README.md` written with the `<!-- provenance:begin/end -->` markers around its Reference table, `scripts/link-skills.sh` and `scripts/check-refs.sh` in place, and the submodule gitlinks (`mattpocock-skills` @ `66898f60e8c744e269f8ce06c2b2b99ce7660d5f`, `superpowers` @ `d884ae04edebef577e82ff7c4e143debd0bbec99`) committed to HEAD.
- All scripts: `#!/usr/bin/env bash`, `set -euo pipefail` (check-refs excepted per 0001), executable, and **bash 3.2 compatible** — no associative arrays, no `${var,,}`. No BSD-sed `\t` in replacements (use awk for tab handling).
- `provenance.tsv` format: 7 tab-separated columns `name, submodule, source_path, status, inv, role, changes`; header row first; statuses are `imported`, `original`, `dropped`; imported+original rows appear in README-table order; `dropped` rows are never rendered into the README.
- Nothing in this plan pushes to any upstream, commits inside a submodule beyond throwaway test branches (deleted in the same task), or bumps the submodule pins. The update *script* never commits and never bumps pins either — close-out belongs to the skill + Jakub.
- Commit after every task with the message given in the task.

---

### Task 1: `provenance.tsv` + README table generator

**Files:**
- Create: `provenance.tsv` (repo root)
- Create: `scripts/gen-readme-table.sh` (executable)
- Modify: `README.md` (only via the generator — proving it reproduces the hand-written table exactly)

**Interfaces:**
- Produces: `provenance.tsv`, consumed by `scripts/update-from-upstream.sh` (Task 2: columns 1–4) and by `gen-readme-table.sh` (all columns).
- Produces: `scripts/gen-readme-table.sh`, invoked by the `update-from-upstream` skill (Task 3) at close-out.

- [ ] **Step 1: Create `provenance.tsv`**

The heredoc uses ` | ` as a readable separator; awk converts it to real tabs (BSD sed can't emit `\t`).

```bash
cd /Users/jakub/workspaces/engineering-skills
awk '{ gsub(/ \| /, "\t"); print }' > provenance.tsv <<'EOF'
name | submodule | source_path | status | inv | role | changes
how | - | - | original | U | Router over the whole set | —
grill-me | mattpocock-skills | skills/productivity/grill-me | imported | U | Interview to align before building | verbatim
grill-with-docs | mattpocock-skills | skills/engineering/grill-with-docs | imported | U | Grill + CONTEXT.md/ADRs inline | verbatim
to-spec | mattpocock-skills | skills/engineering/to-spec | imported | U | Conversation → `docs/specs/<name>.md` | tracker → local file; gear-shift ending
implement | mattpocock-skills | skills/engineering/implement | imported | U | Light-track build | + verification-before-completion gate
writing-plans | superpowers | skills/writing-plans | imported | U | Exhaustive plan → `docs/plans/` | user-invoked; docs/plans path; grilling refs; SDD-only handoff
subagent-driven-development | superpowers | skills/subagent-driven-development | imported | U | Heavy-track execution engine | user-invoked; code-review axes; verification gate; stop-before-merge
using-git-worktrees | superpowers | skills/using-git-worktrees | imported | U | Optional isolation for heavy work | user-invoked
handoff | mattpocock-skills | skills/productivity/handoff | imported | U | Compact session → handoff doc | verbatim
improve-codebase-architecture | mattpocock-skills | skills/engineering/improve-codebase-architecture | imported | U | Deep-module sweep + report | verbatim
writing-great-skills | mattpocock-skills | skills/productivity/writing-great-skills | imported | U | Meta: how to write skills | verbatim
grilling | mattpocock-skills | skills/productivity/grilling | imported | M | The reusable interview loop | verbatim
tdd | mattpocock-skills | skills/engineering/tdd | imported | M | Seams-based red-green loop | verbatim
code-review | mattpocock-skills | skills/engineering/code-review | imported | M | Two-axis review (Standards + Spec) | verbatim
receiving-code-review | superpowers | skills/receiving-code-review | imported | M | Rigor when subagent review feedback arrives | description rescoped
verification-before-completion | superpowers | skills/verification-before-completion | imported | M | Universal completion gate | verbatim
systematic-debugging | superpowers | skills/systematic-debugging | imported | M | 4-phase root-cause debugging | refs → tdd, verification-before-completion
dispatching-parallel-agents | superpowers | skills/dispatching-parallel-agents | imported | M | Concurrent subagent workflows | verbatim
domain-modeling | mattpocock-skills | skills/engineering/domain-modeling | imported | M | Glossary + ADR discipline | verbatim
codebase-design | mattpocock-skills | skills/engineering/codebase-design | imported | M | Deep-module vocabulary | verbatim
resolving-merge-conflicts | mattpocock-skills | skills/engineering/resolving-merge-conflicts | imported | M | Conflict resolution by intent | verbatim
research | mattpocock-skills | skills/engineering/research | imported | M | Cited findings → Markdown in repo | verbatim
brainstorming | superpowers | skills/brainstorming | dropped | - | - | dropped: replaced by grilling
executing-plans | superpowers | skills/executing-plans | dropped | - | - | dropped: superseded by implement
finishing-a-development-branch | superpowers | skills/finishing-a-development-branch | dropped | - | - | dropped: user owns merge and cleanup
requesting-code-review | superpowers | skills/requesting-code-review | dropped | - | - | dropped: replaced by code-review
test-driven-development | superpowers | skills/test-driven-development | dropped | - | - | dropped: replaced by seams-based tdd
using-superpowers | superpowers | skills/using-superpowers | dropped | - | - | dropped: no bootstrap hook by design
writing-skills | superpowers | skills/writing-skills | dropped | - | - | dropped: replaced by writing-great-skills
ask-matt | mattpocock-skills | skills/engineering/ask-matt | dropped | - | - | dropped: replaced by how
diagnosing-bugs | mattpocock-skills | skills/engineering/diagnosing-bugs | dropped | - | - | dropped: replaced by systematic-debugging
prototype | mattpocock-skills | skills/engineering/prototype | dropped | - | - | dropped: not needed
setup-matt-pocock-skills | mattpocock-skills | skills/engineering/setup-matt-pocock-skills | dropped | - | - | dropped: no tracker setup needed
to-tickets | mattpocock-skills | skills/engineering/to-tickets | dropped | - | - | dropped: no issue tracker
triage | mattpocock-skills | skills/engineering/triage | dropped | - | - | dropped: no issue tracker
wayfinder | mattpocock-skills | skills/engineering/wayfinder | dropped | - | - | dropped: not needed
teach | mattpocock-skills | skills/productivity/teach | dropped | - | - | dropped: not needed
EOF
```

Note on `dropped` rows: they record "known and deliberately rejected". Only the 15 *considered-and-dropped* skills get rows; upstream skills never considered (mattpocock `deprecated/`, `in-progress/`, `misc/`, `personal/` categories) need none, because new-candidate detection (Task 2) also checks presence at the base SHA.

- [ ] **Step 2: Verify TSV structure**

```bash
awk -F'\t' 'NF != 7 { print "BAD ROW (" NF " cols): " $0 }' provenance.tsv
wc -l < provenance.tsv
```
Expected: no `BAD ROW` lines; `38` (1 header + 22 imported/original + 15 dropped).

- [ ] **Step 3: Verify TSV against reality — local dirs and upstream paths**

```bash
awk -F'\t' 'NR>1 && $4!="dropped" {print $1}' provenance.tsv | sort | diff - <(ls skills | sort) && echo NAMES-MATCH
while IFS=$'\t' read -r n sub sp; do
  git -C "$sub" cat-file -e "HEAD:$sp/SKILL.md" 2>/dev/null || echo "MISSING UPSTREAM: $n $sub $sp"
done < <(awk -F'\t' 'NR>1 && $2!="-" {print $1 "\t" $2 "\t" $3}' provenance.tsv)
```
Expected: `NAMES-MATCH`; no `MISSING UPSTREAM` lines (submodule HEADs are the pinned SHAs).

- [ ] **Step 4: Create `scripts/gen-readme-table.sh` with exactly this content**

```bash
#!/usr/bin/env bash
# Regenerate the README provenance table from provenance.tsv (single source of truth).
# Rewrites the block between <!-- provenance:begin --> and <!-- provenance:end -->.
# Idempotent: safe to re-run any time provenance.tsv changes.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TSV="$REPO/provenance.tsv"
README="$REPO/README.md"

table="$(mktemp)"
{
  echo "| Skill | Inv. | Role | Source | Changes |"
  echo "|---|---|---|---|---|"
  awk -F'\t' 'NR>1 && $4!="dropped" {
    if ($4 == "original") src = "original"
    else { lbl = $2; sub(/-skills$/, "", lbl); src = lbl " `" $3 "`" }
    printf "| %s | %s | %s | %s | %s |\n", $1, $5, $6, src, $7
  }' "$TSV"
} > "$table"

out="$(mktemp)"
awk -v tf="$table" '
  /<!-- provenance:begin -->/ { print; while ((getline line < tf) > 0) print line; inblock=1; next }
  /<!-- provenance:end -->/   { inblock=0 }
  !inblock { print }
' "$README" > "$out"
mv "$out" "$README"
rm -f "$table"
echo "README provenance table regenerated from provenance.tsv"
```

- [ ] **Step 5: Make executable, syntax-check**

```bash
chmod +x scripts/gen-readme-table.sh
bash -n scripts/gen-readme-table.sh && echo SYNTAX-OK
```
Expected: `SYNTAX-OK`

- [ ] **Step 6: Run the generator — it must reproduce 0001's hand-written table byte-for-byte**

This is the fidelity proof for the whole TSV: if the generated table differs from the table 0001 wrote by hand, either the TSV or the generator is wrong. Fix it, don't paper over the diff.

```bash
scripts/gen-readme-table.sh
git diff --exit-code README.md && echo TABLE-FAITHFUL
```
Expected: `README provenance table regenerated from provenance.tsv`, then `TABLE-FAITHFUL` (no diff).

- [ ] **Step 7: Idempotency check**

```bash
scripts/gen-readme-table.sh
git diff --exit-code README.md && echo IDEMPOTENT
```
Expected: `IDEMPOTENT`

- [ ] **Step 8: Commit**

```bash
git add provenance.tsv scripts/gen-readme-table.sh
git commit -m "feat: provenance.tsv as single source of truth + README table generator"
```

---

### Task 2: `scripts/update-from-upstream.sh` — the three-way merge engine

**Files:**
- Create: `scripts/update-from-upstream.sh` (executable)

**Interfaces:**
- Consumes: `provenance.tsv` (Task 1) — columns `name`, `submodule`, `source_path`, `status`; the submodule gitlinks in HEAD (merge base); the submodules' `origin` remotes.
- Produces: merged content in the working tree (uncommitted), `git merge-file` conflict markers in files where upstream touched rewired lines, and a stdout report the skill (Task 3) parses by convention: `CONFLICT:` / `ATTENTION` / `NEW-CANDIDATE:` / `SUMMARY:` lines. Exit 0 on a completed run, 2 on usage error or dirty tree.

- [ ] **Step 1: Create `scripts/update-from-upstream.sh` with exactly this content**

```bash
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
```

- [ ] **Step 2: Make executable, syntax-check**

```bash
chmod +x scripts/update-from-upstream.sh
bash -n scripts/update-from-upstream.sh && echo SYNTAX-OK
```
Expected: `SYNTAX-OK`

- [ ] **Step 3: Dirty-tree guard test**

```bash
printf '\n' >> skills/how/SKILL.md
scripts/update-from-upstream.sh --to mattpocock-skills=66898f60e8c744e269f8ce06c2b2b99ce7660d5f --to superpowers=d884ae04edebef577e82ff7c4e143debd0bbec99; echo "exit=$?"
git restore skills/how/SKILL.md
```
Expected: `ABORT: skills/ or provenance.tsv has uncommitted changes - commit or restore first`, `exit=2`.

- [ ] **Step 4: No-op run (targets pinned at the current bases; offline-safe, no fetch)**

```bash
scripts/update-from-upstream.sh --to mattpocock-skills=66898f60e8c744e269f8ce06c2b2b99ce7660d5f --to superpowers=d884ae04edebef577e82ff7c4e143debd0bbec99
```
Expected output:
```
== mattpocock-skills: 66898f60e -> 66898f60e
   up to date
== superpowers: d884ae04e -> d884ae04e
   up to date

SUMMARY: conflicts=0 attention=0 new-candidates=0
Working tree updated; nothing committed, submodule pins not bumped.
```

- [ ] **Step 5: Simulated upstream drift — clean merge, conflict, and new candidate in one synthetic commit**

Build a throwaway branch in the `superpowers` submodule with three kinds of drift: an appended line in a verbatim skill (must merge clean), an upstream edit to the exact line 0001 rewired in `writing-plans` (must conflict), and a brand-new skill dir (must report as candidate).

```bash
cd /Users/jakub/workspaces/engineering-skills
git -C superpowers checkout -q -b _upd-test
printf '\n<!-- upd-test marker -->\n' >> superpowers/skills/verification-before-completion/SKILL.md
perl -pi -e 's|^\*\*Save plans to:\*\* .*$|**Save plans to:** `docs/moved-by-upstream/plans/`|' superpowers/skills/writing-plans/SKILL.md
mkdir -p superpowers/skills/zzz-upd-test
printf -- '---\nname: zzz-upd-test\ndescription: synthetic test skill for the update mechanism\n---\n\nTest body.\n' > superpowers/skills/zzz-upd-test/SKILL.md
git -C superpowers add -A
git -C superpowers commit -qm "test: synthetic upstream drift"
scripts/update-from-upstream.sh --to superpowers=_upd-test --to mattpocock-skills=66898f60e8c744e269f8ce06c2b2b99ce7660d5f
```
Expected output must contain (among `= <name>: unchanged` lines for untouched skills):
```
   CONFLICT: skills/writing-plans/SKILL.md (markers left in file)
   ok writing-plans: 1 merged (1 conflicts), 0 added, 0 deleted, 0 kept
   ok verification-before-completion: 1 merged (0 conflicts), 0 added, 0 deleted, 0 kept
   NEW-CANDIDATE: skills/zzz-upd-test - synthetic test skill for the update mechanism
SUMMARY: conflicts=1 attention=0 new-candidates=1
```

- [ ] **Step 6: Verify merge effects on disk**

```bash
tail -1 skills/verification-before-completion/SKILL.md
grep -c '^<<<<<<<' skills/writing-plans/SKILL.md
```
Expected: `<!-- upd-test marker -->` (the clean merge carried the appended line into our copy); `1` (exactly one conflict block, at the rewired "Save plans to" line).

- [ ] **Step 7: Clean up the simulation completely**

```bash
git restore skills/
git -C superpowers checkout -q --detach d884ae04edebef577e82ff7c4e143debd0bbec99
git -C superpowers branch -qD _upd-test
git status --porcelain skills/ superpowers provenance.tsv
```
Expected: no output from the final status — `skills/` restored, submodule back on the pinned SHA, test branch gone.

- [ ] **Step 8: Commit**

```bash
git add scripts/update-from-upstream.sh
git commit -m "feat: update-from-upstream.sh three-way merge engine (base = submodule pin)"
```

---

### Task 3: The canonical repo-local `update-from-upstream` skill + dual-harness discovery + README Maintenance section

**Files:**
- Create: `skills-internal/update-from-upstream/SKILL.md` (canonical repo-local source — deliberately NOT under distributed `skills/`)
- Create: `skills-internal/update-from-upstream/agents/openai.yaml` (Codex explicit-invocation policy)
- Create: `.claude/skills/update-from-upstream` -> `../../skills-internal/update-from-upstream` (Claude repository discovery symlink)
- Create: `.agents/skills/update-from-upstream` -> `../../skills-internal/update-from-upstream` (Codex repository discovery symlink)
- Modify: `README.md` (insert Maintenance section)

**Interfaces:**
- Consumes: `scripts/update-from-upstream.sh` (Task 2), `scripts/gen-readme-table.sh` (Task 1), `scripts/check-refs.sh` and `scripts/link-skills.sh` (plan 0001), `provenance.tsv` (Task 1).
- Produces: `/update-from-upstream` in Claude and `$update-from-upstream` in Codex, available only when working in this repo and never added to the globally distributed set.

- [ ] **Step 1: Create `skills-internal/update-from-upstream/SKILL.md` with exactly this content**

```markdown
---
name: update-from-upstream
description: Sync the skill set with its upstream submodules — automatic three-way merge, then a grilled walk-through of what changed. Repo-local maintenance for engineering-skills.
disable-model-invocation: true
---

You are running the upstream sync for this repo. The mechanical merge is a script's job; yours is the judgment layer: help the user understand what upstream changed and put every real decision to them, one at a time.

**Ground rules (non-negotiable):**
- Ask in plain prose, one question at a time, always leading with your recommended answer. Never use the AskUserQuestion widget.
- Never commit, never push, never do more than the close-out lists. The commit belongs to the user.
- Report, never act, on set membership: adopting or dropping a skill happens only on the user's explicit say-so.
- Name user-invoked skills in the active harness's form: `/skill-name` for Claude and `$skill-name` for Codex.

## 1. Prove worktree isolation

This maintenance workflow may run only in a linked Git worktree. The primary checkout may be live through the real `~/.agents/skills` and `~/.claude/skills` symlinks, so mutating its `skills/` would change running installations before the user accepts the sync.

Resolve `git rev-parse --git-dir` and `git rev-parse --git-common-dir` to canonical paths, and also run `git rev-parse --show-superproject-working-tree`. A non-empty superproject path means this is a submodule, not an isolated root worktree. Only a root checkout whose canonical Git dir differs from its canonical common dir is isolated.

If this is the primary checkout or a submodule, recommend creating an isolated worktree and **STOP**. For Claude, name `/using-git-worktrees` as the next manual command, then `/update-from-upstream` after entering the linked worktree. For Codex, name `$using-git-worktrees` (also available from the `/skills` picker), then `$update-from-upstream` after entering the linked worktree. Do not create or auto-chain the worktree.

Once isolation is confirmed, initialize this worktree's pinned submodules before invoking the updater:

    git submodule update --init --recursive mattpocock-skills superpowers

For each submodule, compare `git -C <submodule> rev-parse HEAD` with `git rev-parse HEAD:<submodule>` and require an exact match. If initialization fails or either SHA differs from its recorded gitlink, stop and report the mismatch; do not fetch or merge.

## 2. Mechanical merge

Run `scripts/update-from-upstream.sh` from the repo root. It fetches both submodules and three-way-merges every imported skill (base = pinned submodule SHA, ours = the `skills/` copy, theirs = upstream HEAD) into the working tree, uncommitted. Its report lines: `ok`/`=` (merged/unchanged), `CONFLICT:` (markers left in the file), `+`/`-`/`!` (file added/deleted/needs attention), `ATTENTION` (source path gone: rename or deletion), `NEW-CANDIDATE:` (upstream skill we've never seen), `ERROR:` (operational/binary merge failure; local file preserved), `SUMMARY:` (totals).

If it aborts on a dirty working tree, stop and tell the user. If it exits nonzero after reporting `ERROR:`, stop and tell the user; do not enter the walk-through or close-out until the error is resolved. If both submodules report `up to date`, say so and stop — there is nothing to walk through.

## 3. Understand before narrating

For each submodule that moved, read the upstream history for the imported paths — mandatory; the diff alone is not enough context to explain intent:

    git -C <submodule> log --no-merges --oneline <base>..<target> -- <source paths from provenance.tsv>

Read the full message (`git show <sha>`) of any commit whose one-liner doesn't explain itself. You are about to explain *why* upstream changed things, not just which lines moved.

## 4. Walk-through

**Narrated tier — clean merges.** Group by skill. For each changed skill, give a short summary: what upstream changed, why (from the commit messages), and whether it touches our rewirings (check the Changes column in `provenance.tsv`). Offer drill-in (`git diff skills/<name>/`) or rejection. Rejection = `git restore skills/<name>/` — warn that this is permanent divergence (the base advances with the pin bump, so the rejected change never resurfaces) and must be recorded in the row's Changes column.

**Grilled tier — one item at a time, recommendation first:**
- Each **CONFLICT**: show both sides of the markers, explain what upstream wants vs. what our rewiring does, propose a concrete resolution, apply it only once the user agrees.
- Each per-file **`! ... KEPT`** attention item — including add/add, upstream-deleted/local-modified, upstream-modified/local-deleted, ancestor collision, and type or mode transition: show the base, committed local, and exact upstream target entry (content or deletion, type, and mode) plus the relevant upstream commit intent. Recommend one concrete resolution: keep local intent, accept the exact upstream target entry, or manually merge. Apply nothing until the user agrees. If local intent remains after the pin advances, record that permanent divergence in the skill's `provenance.tsv` `changes` field.
- Each **NEW-CANDIDATE**: read its SKILL.md at the target SHA, then argue adopt or drop against this set's philosophy (two tracks, manual gear shifts, user owns merges, no auto-chaining). Adopt = copy the directory into `skills/`, add an `imported` row to `provenance.tsv`, and grill any rewiring it needs. Drop = add a `dropped` row with the reason.
- Each **deletion** (ATTENTION without a rename line): fork or drop. Fork = keep `skills/<name>`, set its row to status `original`, Changes `forked from <submodule> @ <short-sha>`. Drop = delete `skills/<name>` and set the row's status to `dropped`.
- Each suspected **rename** (ATTENTION with an `R` line) is a human-in-the-loop edge case. Explain the old and proposed upstream paths, the upstream commit intent, and why the report looks like a rename. Recommend that the user manually reconcile the affected `skills/<name>/` directory and its `source_path` in `provenance.tsv` inside this isolated maintenance worktree. Then ask the user to report when that manual fix is complete and **STOP**. Do not edit either path for them and do not re-run the updater against a dirty manifest. When the user reports completion, inspect the exact `skills/<name>/` and `provenance.tsv` diff, verify that the new source path exists at the agreed target SHA and that the local directory represents the intended result, then continue the walk-through. If it is not actually a rename, return to the deletion or new-candidate decision instead.

Close-out is forbidden while any `!`, `CONFLICT`, `ATTENTION`, `NEW-CANDIDATE`, deletion, or rename item remains unresolved.

## 5. Close-out

Only after every item above is resolved, perform every applicable check below and inspect its actual output before staging:

1. Confirm `provenance.tsv` records every membership and divergence decision, including rejections, adoptions, drops, forks, and every retained local `!` item.
2. Run `scripts/gen-readme-table.sh`. If provenance changed, hash the resulting README content, run the generator a second time, and require the second README hash to be identical.
3. Run `scripts/check-refs.sh` and require the exact success line `check-refs: clean`; fix any hit before continuing.
4. Identify every changed file whose shebang names Bash, including extensionless scripts, and run `bash -n` on each one.
5. For each moved submodule only, check out the agreed target SHA detached. Do not move an unchanged submodule, stage anything yet, or commit.
6. Validate that every `provenance.tsv` row has exactly seven tab-separated columns; non-dropped names exactly equal the flat directories under `skills/`; and every imported source path exists at its submodule's now-pinned `HEAD`.
7. Diff changed verbatim imports against their pinned source directories. Separately verify each rewired import and require that every difference is documented in that row's `changes` field.
8. If membership changed, create a throwaway `HOME`, run `scripts/link-skills.sh` twice with only that `HOME`, verify the second run is idempotent, and remove the fixture. Never run the real linker from this maintenance worktree.
9. After every applicable check above passes, stage only the agreed sync result, including each moved submodule gitlink. Run `git status --short`, distinguish staged from remaining changes, and report both accurately.

Then **STOP**. Present the staged summary and suggest `chore: sync upstream (<submodule> <old-short>..<new-short>)`, but do not commit, push, merge, or relink the real global installs. The user owns the commit, merge, sanity testing, and maintenance-worktree cleanup. If membership changed, tell the user to run `scripts/link-skills.sh` from the primary checkout only after merging, and remind them that already-running harness sessions retain their old skill snapshot until restarted.
```

- [ ] **Step 2: Create the Codex explicit-invocation policy**

Create `skills-internal/update-from-upstream/agents/openai.yaml` with exactly this content:

```yaml
policy:
  allow_implicit_invocation: false
```

Keep `disable-model-invocation: true` in the canonical `SKILL.md` for Claude. In the canonical skill's linked-worktree isolation handoff, name `/using-git-worktrees` then `/update-from-upstream` for Claude, and `$using-git-worktrees` then `$update-from-upstream` for Codex (the Codex skills are also available from its `/skills` picker).

- [ ] **Step 3: Create both repository discovery symlinks**

```bash
mkdir -p .claude/skills .agents/skills
ln -s ../../skills-internal/update-from-upstream .claude/skills/update-from-upstream
ln -s ../../skills-internal/update-from-upstream .agents/skills/update-from-upstream
```

The canonical directory remains repo-local automation. Neither it nor either discovery link belongs under distributed `skills/` or in the global installs created by `scripts/link-skills.sh`.

- [ ] **Step 4: Verify both discovery links, frontmatter, and Codex policy**

```bash
test -L .claude/skills/update-from-upstream
test -L .agents/skills/update-from-upstream
test "$(readlink .claude/skills/update-from-upstream)" = "../../skills-internal/update-from-upstream"
test "$(readlink .agents/skills/update-from-upstream)" = "../../skills-internal/update-from-upstream"
test -f .claude/skills/update-from-upstream/SKILL.md
test -f .agents/skills/update-from-upstream/SKILL.md
test -f .claude/skills/update-from-upstream/agents/openai.yaml
test -f .agents/skills/update-from-upstream/agents/openai.yaml
test "$(realpath .claude/skills/update-from-upstream)" = "$(realpath skills-internal/update-from-upstream)"
test "$(realpath .agents/skills/update-from-upstream)" = "$(realpath skills-internal/update-from-upstream)"
head -5 .claude/skills/update-from-upstream/SKILL.md | grep -c "name: update-from-upstream\|disable-model-invocation: true"
head -5 .agents/skills/update-from-upstream/SKILL.md | grep -c "name: update-from-upstream\|disable-model-invocation: true"
printf 'policy:\n  allow_implicit_invocation: false\n' | cmp - .claude/skills/update-from-upstream/agents/openai.yaml
printf 'policy:\n  allow_implicit_invocation: false\n' | cmp - .agents/skills/update-from-upstream/agents/openai.yaml
set +e
primary_output="$(scripts/update-from-upstream.sh 2>&1)"
primary_rc=$?
set -e
test "$primary_rc" -eq 2
printf '%s\n' "$primary_output" | grep -F '/using-git-worktrees'
printf '%s\n' "$primary_output" | grep -F '/update-from-upstream'
printf '%s\n' "$primary_output" | grep -F '$using-git-worktrees'
printf '%s\n' "$primary_output" | grep -F '$update-from-upstream'
```
Expected: both frontmatter `grep` commands print `2`; every `test` and `cmp` succeeds; the updater exits `2` before fetching and its diagnostic names both Claude slash commands and both Codex dollar commands.

- [ ] **Step 5: Insert the Maintenance section into `README.md`**

Edit `README.md` — insert between the Install section and `## Reference`:

Old:
```
Symlinks every skill in `skills/` into `~/.agents/skills` and `~/.claude/skills`. Edits in this repo are live immediately; re-run after adding, removing, or renaming a skill.

## Reference
```
New:
```
Symlinks every skill in `skills/` into `~/.agents/skills` and `~/.claude/skills`. Edits in this repo are live immediately; re-run after adding, removing, or renaming a skill.

## Maintenance

`provenance.tsv` is the single source of truth for the skill ↔ upstream mapping. The Reference table below is generated from it by `scripts/gen-readme-table.sh` (between the provenance markers) — edit the tsv, never the table.

Upstream sync: `/update-from-upstream` in Claude or `$update-from-upstream` in Codex, backed by one canonical repo-local source (`skills-internal/update-from-upstream/`) exposed through `.claude/skills/` and `.agents/skills/` discovery symlinks. Claude's frontmatter and Codex's `agents/openai.yaml` both disable implicit invocation. It loads only in this workspace and is never part of the globally linked set. If isolation is absent, it names `/using-git-worktrees` then `/update-from-upstream` for Claude, or `$using-git-worktrees` then `$update-from-upstream` for Codex, and stops. It runs `scripts/update-from-upstream.sh` — a three-way merge of every imported skill, base = the pinned submodule SHA — then walks through conflicts, new upstream skills, and deletions as grilled decisions, regenerates this README, runs `scripts/check-refs.sh`, bumps the submodule pins, and stops. The commit is mine.

## Reference
```

- [ ] **Step 6: Verify the README survived intact**

```bash
grep -c "provenance:begin\|provenance:end" README.md
scripts/gen-readme-table.sh
git diff --stat README.md
scripts/check-refs.sh
```
Expected: `2`; regeneration message; diff stat shows only the Maintenance insertion (the generated table region unchanged); `check-refs: clean`.

- [ ] **Step 7: Commit**

```bash
git add skills-internal/update-from-upstream/SKILL.md skills-internal/update-from-upstream/agents/openai.yaml .claude/skills/update-from-upstream .agents/skills/update-from-upstream scripts/update-from-upstream.sh AGENTS.md README.md docs/plans/0002-upstream-update-mechanism.md
git commit -m "feat: expose upstream maintenance skill to codex"
```

---

## Self-Review

- **Decision coverage (vs. the grilled design):** 3-way merge with pinned-SHA base → Task 2 `merge_skill`; whole-submodule atomicity → script merges every imported row per submodule, pins bumped only at skill close-out; TSV as single source with generated README table → Task 1; dropped rows + base-presence check so membership reporting stays quiet on never-considered skills → Task 1 Step 1 note + Task 2 membership block; report-never-act on membership → script only prints `NEW-CANDIDATE`/`ATTENTION`, skill acts only on user say-so; stop-and-report on renames → `ATTENTION` path, no auto-repair; merge-first-review-after with uncommitted working tree → script guard + no commits; two-tier walk-through with mandated upstream-log reading → SKILL.md §2–3; close-out with regenerate/check-refs/bump/STOP → SKILL.md §4; repo-local packaging → one canonical `skills-internal/` body with exact Claude and Codex discovery symlinks, Claude and Codex implicit invocation disabled separately, and no inclusion in distributed `skills/` or global installs. ✓
- **Placeholder scan:** every file carries complete content; every verification has exact commands and expected output; no "handle appropriately" steps. The one deliberately loose expectation (Task 2 Step 5's "among unchanged lines") states exactly which lines are load-bearing. ✓
- **Consistency:** `provenance.tsv` name/columns identical across Task 1 heredoc, generator awk (`$1..$7`), update-script awk (`$2,$4`), and SKILL.md references; pinned SHAs `66898f60e…`/`d884ae04e…` match the committed gitlinks; script/skill names match across README, SKILL.md, and commit messages; TSV row order matches 0001's README table order, proven byte-for-byte by Task 1 Step 6. ✓
- **Prerequisite honesty:** Task 1 Step 6 requires 0001's README (with markers, per the 0001 amendment); Task 2 Step 3 requires committed `skills/` and gitlinks; both are stated in Global Constraints. ✓
