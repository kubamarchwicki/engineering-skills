# Bootstrap engineering-skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Populate `/Users/jakub/workspaces/engineering-skills/skills/` with the 22-skill set (14 mattpocock + 7 superpowers + 1 fresh router), rewire the agreed edits, write the README/provenance map and `link-skills.sh`, and swap the stale `~/.agents/skills` installs for symlinks into this repo.

**Architecture:** Every imported skill is copied whole-directory, verbatim, from its source checkout (`mattpocock-skills/` or `superpowers/` — soon git submodules). Edits are limited to the surgical exceptions agreed in the design: invocation frontmatter, dangling-reference repoints, and the specific rewirings listed per task. Fresh files (`how`, `README.md`, `link-skills.sh`) are written from the complete content in this plan.

**Tech Stack:** Markdown skill files (Claude Code Agent Skills format), bash, git, symlinks.

## Global Constraints

- Repo root: `/Users/jakub/workspaces/engineering-skills` (already a git repo, branch `master`). All commands below run from the repo root unless stated.
- **Verbatim rule:** never edit imported content beyond the exact edits a task lists. No style rewrites, no reformatting, no "improvements". Superpowers' "your human partner" wording stays.
- Skill names stay exactly as inherited. The only new name is `how`.
- Artifact conventions the skills must reference: `CONTEXT.md` at repo root, `docs/adr/`, `docs/specs/`, `docs/plans/NNNN-<feature-name>.md`.
- User-invoked skills carry `disable-model-invocation: true` in frontmatter; model-invoked skills must not.
- No Claude plugin / marketplace files. Distribution is `scripts/link-skills.sh` only.
- Copy each skill's **entire directory** (including `agents/`, reference `.md` files, `scripts/`). Do not prune sub-files.
- Commit after every task with the message given in the task.
- Where a step says "Replace every occurrence", use Edit with replace_all; expected occurrence counts are stated so a mismatch is caught, not papered over.

---

### Task 1: Verbatim import of the 14 clean skills

**Files:**
- Create: `skills/grilling/`, `skills/grill-me/`, `skills/grill-with-docs/`, `skills/tdd/`, `skills/code-review/`, `skills/domain-modeling/`, `skills/codebase-design/`, `skills/research/`, `skills/handoff/`, `skills/improve-codebase-architecture/`, `skills/resolving-merge-conflicts/`, `skills/writing-great-skills/` (from mattpocock-skills)
- Create: `skills/verification-before-completion/`, `skills/dispatching-parallel-agents/` (from superpowers)
- Delete: `skills/.empty`

**Interfaces:**
- Produces: 14 skill directories, byte-identical to their sources. Later tasks rely on skill names `tdd`, `code-review`, `verification-before-completion`, `grilling` existing under `skills/`.

- [ ] **Step 1: Copy the 14 directories**

```bash
cd /Users/jakub/workspaces/engineering-skills
M=mattpocock-skills/skills; S=superpowers/skills
cp -R $M/productivity/grilling            skills/grilling
cp -R $M/productivity/grill-me            skills/grill-me
cp -R $M/engineering/grill-with-docs      skills/grill-with-docs
cp -R $M/engineering/tdd                  skills/tdd
cp -R $M/engineering/code-review          skills/code-review
cp -R $M/engineering/domain-modeling      skills/domain-modeling
cp -R $M/engineering/codebase-design      skills/codebase-design
cp -R $M/engineering/research             skills/research
cp -R $M/productivity/handoff             skills/handoff
cp -R $M/engineering/improve-codebase-architecture skills/improve-codebase-architecture
cp -R $M/engineering/resolving-merge-conflicts     skills/resolving-merge-conflicts
cp -R $M/productivity/writing-great-skills         skills/writing-great-skills
cp -R $S/verification-before-completion   skills/verification-before-completion
cp -R $S/dispatching-parallel-agents      skills/dispatching-parallel-agents
rm skills/.empty
```

- [ ] **Step 2: Verify byte-identical copies**

```bash
cd /Users/jakub/workspaces/engineering-skills
M=mattpocock-skills/skills; S=superpowers/skills
diff -r $M/productivity/grilling skills/grilling && \
diff -r $M/productivity/grill-me skills/grill-me && \
diff -r $M/engineering/grill-with-docs skills/grill-with-docs && \
diff -r $M/engineering/tdd skills/tdd && \
diff -r $M/engineering/code-review skills/code-review && \
diff -r $M/engineering/domain-modeling skills/domain-modeling && \
diff -r $M/engineering/codebase-design skills/codebase-design && \
diff -r $M/engineering/research skills/research && \
diff -r $M/productivity/handoff skills/handoff && \
diff -r $M/engineering/improve-codebase-architecture skills/improve-codebase-architecture && \
diff -r $M/engineering/resolving-merge-conflicts skills/resolving-merge-conflicts && \
diff -r $M/productivity/writing-great-skills skills/writing-great-skills && \
diff -r $S/verification-before-completion skills/verification-before-completion && \
diff -r $S/dispatching-parallel-agents skills/dispatching-parallel-agents && echo ALL-IDENTICAL
```
Expected: `ALL-IDENTICAL` (no diff output).

- [ ] **Step 3: Commit**

```bash
git add -A skills/
git commit -m "feat: import 14 skills verbatim from mattpocock-skills and superpowers"
```

---

### Task 2: Import + rewire `to-spec` (tracker → docs/specs/)

**Files:**
- Create: `skills/to-spec/` (from `mattpocock-skills/skills/engineering/to-spec`)
- Modify: `skills/to-spec/SKILL.md` (3 edits)

**Interfaces:**
- Produces: `/to-spec` saving specs to `docs/specs/<feature-name>.md` and ending with a manual gear shift. `writing-plans` (Task 6) consumes those spec files.

- [ ] **Step 1: Copy**

```bash
cd /Users/jakub/workspaces/engineering-skills
cp -R mattpocock-skills/skills/engineering/to-spec skills/to-spec
```

- [ ] **Step 2: Edit `skills/to-spec/SKILL.md` — description**

Old:
```
description: Turn the current conversation into a spec and publish it to the project issue tracker — no interview, just synthesis of what you've already discussed.
```
New:
```
description: Turn the current conversation into a spec saved to docs/specs/ — no interview, just synthesis of what you've already discussed.
```

- [ ] **Step 3: Edit — delete the setup-skill line (including its trailing blank line)**

Old:
```
The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

```
New: (nothing — delete)

- [ ] **Step 4: Edit — publish step becomes save-to-file + gear shift**

Old:
```
3. Write the spec using the template below, then publish it to the project issue tracker. Apply the `ready-for-agent` triage label - no need for additional triage.
```
New:
```
3. Write the spec using the template below, then save it to `docs/specs/<feature-name>.md` in the repo (create the directory if needed). Tell the user the path and stop: `/writing-plans` is the next gear for heavy work, `/implement` for small.
```

- [ ] **Step 5: Verify no tracker references remain**

```bash
grep -n "tracker\|triage\|setup-matt-pocock" skills/to-spec/SKILL.md
```
Expected: no output (exit code 1).

- [ ] **Step 6: Commit**

```bash
git add skills/to-spec
git commit -m "feat: import to-spec, rewired to save specs to docs/specs/ instead of a tracker"
```

---

### Task 3: Import + rewire `implement` (verification gate)

**Files:**
- Create: `skills/implement/` (from `mattpocock-skills/skills/engineering/implement`)
- Modify: `skills/implement/SKILL.md` (1 edit)

**Interfaces:**
- Consumes: skill names `tdd`, `code-review` (Task 1), `verification-before-completion` (Task 1) — referenced by name in the body.
- Produces: the light track's execution command, gated by verification before commit.

- [ ] **Step 1: Copy**

```bash
cd /Users/jakub/workspaces/engineering-skills
cp -R mattpocock-skills/skills/engineering/implement skills/implement
```

- [ ] **Step 2: Edit `skills/implement/SKILL.md` — insert the verification gate**

Old:
```
Once done, use /code-review to review the work.

Commit your work to the current branch.
```
New:
```
Once done, use /code-review to review the work.

Before committing, use the verification-before-completion skill: run the verification commands (tests, typecheck) and confirm their output before claiming the work complete.

Commit your work to the current branch.
```

- [ ] **Step 3: Verify**

```bash
grep -c "verification-before-completion" skills/implement/SKILL.md
```
Expected: `1`

- [ ] **Step 4: Commit**

```bash
git add skills/implement
git commit -m "feat: import implement, gated by verification-before-completion"
```

---

### Task 4: Import + rescope `receiving-code-review`

**Files:**
- Create: `skills/receiving-code-review/` (from `superpowers/skills/receiving-code-review`)
- Modify: `skills/receiving-code-review/SKILL.md` (frontmatter description only; body verbatim)

**Interfaces:**
- Produces: model-invoked discipline that fires when review feedback arrives from a reviewer subagent. `subagent-driven-development` (Task 7) lists it under Integration.

- [ ] **Step 1: Copy**

```bash
cd /Users/jakub/workspaces/engineering-skills
cp -R superpowers/skills/receiving-code-review skills/receiving-code-review
```

- [ ] **Step 2: Edit description (scope to subagent review feedback)**

Old:
```
description: Use when receiving code review feedback, before implementing suggestions, especially if feedback seems unclear or technically questionable - requires technical rigor and verification, not performative agreement or blind implementation
```
New:
```
description: Use when the orchestrator receives code review feedback from a reviewer subagent, before implementing suggestions - requires technical rigor and verification, not performative agreement or blind implementation
```

- [ ] **Step 3: Verify body untouched**

```bash
diff <(tail -n +5 superpowers/skills/receiving-code-review/SKILL.md) <(tail -n +5 skills/receiving-code-review/SKILL.md) && echo BODY-VERBATIM
```
Expected: `BODY-VERBATIM`

- [ ] **Step 4: Commit**

```bash
git add skills/receiving-code-review
git commit -m "feat: import receiving-code-review, rescoped to subagent review feedback"
```

---

### Task 5: Import + repoint `systematic-debugging`

**Files:**
- Create: `skills/systematic-debugging/` (from `superpowers/skills/systematic-debugging`, whole dir incl. reference files)
- Modify: `skills/systematic-debugging/SKILL.md` (3 line edits)

**Interfaces:**
- Consumes: skill names `tdd` and `verification-before-completion` (Task 1).

- [ ] **Step 1: Copy**

```bash
cd /Users/jakub/workspaces/engineering-skills
cp -R superpowers/skills/systematic-debugging skills/systematic-debugging
```

- [ ] **Step 2: Repoint the three skill references**

Edit `skills/systematic-debugging/SKILL.md`:

Old:
```
   - Use the `superpowers:test-driven-development` skill for writing proper failing tests
```
New:
```
   - Use the `tdd` skill for writing proper failing tests
```

Old:
```
- **superpowers:test-driven-development** - For creating failing test case (Phase 4, Step 1)
```
New:
```
- **tdd** - For creating failing test case (Phase 4, Step 1)
```

Old:
```
- **superpowers:verification-before-completion** - Verify fix worked before claiming success
```
New:
```
- **verification-before-completion** - Verify fix worked before claiming success
```

- [ ] **Step 3: Verify no superpowers: prefixes remain**

```bash
grep -rn "superpowers:" skills/systematic-debugging/SKILL.md
```
Expected: no output (exit code 1).

- [ ] **Step 4: Commit**

```bash
git add skills/systematic-debugging
git commit -m "feat: import systematic-debugging, refs repointed to tdd and verification-before-completion"
```

---

### Task 6: Import + rewire `writing-plans`

**Files:**
- Create: `skills/writing-plans/` (from `superpowers/skills/writing-plans`, incl. `plan-document-reviewer-prompt.md`)
- Modify: `skills/writing-plans/SKILL.md` (frontmatter + 5 edits)

**Interfaces:**
- Consumes: specs in `docs/specs/` (Task 2).
- Produces: plans at `docs/plans/NNNN-<feature-name>.md`, consumed by `subagent-driven-development` (Task 7). User-invoked.

- [ ] **Step 1: Copy**

```bash
cd /Users/jakub/workspaces/engineering-skills
cp -R superpowers/skills/writing-plans skills/writing-plans
```

- [ ] **Step 2: Frontmatter — make user-invoked**

Old:
```
description: Use when you have a spec or requirements for a multi-step task, before touching code
---
```
New:
```
description: Use when you have a spec or requirements for a multi-step task, before touching code
disable-model-invocation: true
---
```

- [ ] **Step 3: Edit worktree context line**

Old:
```
**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.
```
New:
```
**Context:** For heavy work an isolated worktree may have been created via the `using-git-worktrees` skill; small work runs inline on the current branch.
```

- [ ] **Step 4: Edit plan location**

Old:
```
**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
```
New:
```
**Save plans to:** `docs/plans/NNNN-<feature-name>.md` (next number in sequence)
```

- [ ] **Step 5: Edit scope-check wording (brainstorming → grilling)**

Old:
```
If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.
```
New:
```
If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during grilling. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.
```

- [ ] **Step 6: Edit plan header template**

Old:
```
> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
```
New:
```
> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
```

- [ ] **Step 7: Replace the Execution Handoff section (from `## Execution Handoff` to end of file)**

New content for the section:
```
## Execution Handoff

After saving the plan, stop:

**"Plan complete and saved to `docs/plans/<filename>.md`. Review it; when you're ready, `/subagent-driven-development` executes it."**

The gear shift belongs to your human partner: they read the plan and type the next command. Do not begin execution yourself.
```

- [ ] **Step 8: Verify**

```bash
grep -n "superpowers:\|executing-plans\|docs/superpowers\|brainstorm" skills/writing-plans/SKILL.md
```
Expected: no output (exit code 1).

- [ ] **Step 9: Commit**

```bash
git add skills/writing-plans
git commit -m "feat: import writing-plans, user-invoked, docs/plans convention, manual handoff to SDD"
```

---

### Task 7: Import + rewire `subagent-driven-development`

**Files:**
- Create: `skills/subagent-driven-development/` (whole dir: `SKILL.md`, `implementer-prompt.md`, `task-reviewer-prompt.md`, `scripts/`)
- Modify: `skills/subagent-driven-development/SKILL.md` only (prompts and scripts stay verbatim)

**Interfaces:**
- Consumes: plans from `docs/plans/` (Task 6); skills `tdd`, `code-review`, `verification-before-completion` (Task 1), `receiving-code-review` (Task 4), `using-git-worktrees` (Task 8).
- Produces: the heavy track's execution engine: per-task two-stage review, final whole-branch review via the `code-review` skill, verification gate, then STOP (no merge).

- [ ] **Step 1: Copy**

```bash
cd /Users/jakub/workspaces/engineering-skills
cp -R superpowers/skills/subagent-driven-development skills/subagent-driven-development
```

- [ ] **Step 2: Frontmatter — make user-invoked**

Old:
```
description: Use when executing implementation plans with independent tasks in the current session
---
```
New:
```
description: Use when executing implementation plans with independent tasks in the current session
disable-model-invocation: true
---
```

- [ ] **Step 3: Rewire the "When to Use" digraph (executing-plans branch removed, brainstorm → grill)**

Old:
```
    "Have implementation plan?" [shape=diamond];
    "Tasks mostly independent?" [shape=diamond];
    "Stay in this session?" [shape=diamond];
    "subagent-driven-development" [shape=box];
    "executing-plans" [shape=box];
    "Manual execution or brainstorm first" [shape=box];

    "Have implementation plan?" -> "Tasks mostly independent?" [label="yes"];
    "Have implementation plan?" -> "Manual execution or brainstorm first" [label="no"];
    "Tasks mostly independent?" -> "Stay in this session?" [label="yes"];
    "Tasks mostly independent?" -> "Manual execution or brainstorm first" [label="no - tightly coupled"];
    "Stay in this session?" -> "subagent-driven-development" [label="yes"];
    "Stay in this session?" -> "executing-plans" [label="no - parallel session"];
```
New:
```
    "Have implementation plan?" [shape=diamond];
    "Tasks mostly independent?" [shape=diamond];
    "subagent-driven-development" [shape=box];
    "Manual execution or grill first" [shape=box];

    "Have implementation plan?" -> "Tasks mostly independent?" [label="yes"];
    "Have implementation plan?" -> "Manual execution or grill first" [label="no"];
    "Tasks mostly independent?" -> "subagent-driven-development" [label="yes"];
    "Tasks mostly independent?" -> "Manual execution or grill first" [label="no - tightly coupled"];
```

- [ ] **Step 4: Retitle the comparison block**

Old:
```
**vs. Executing Plans (parallel session):**
```
New:
```
**Properties:**
```

- [ ] **Step 5: Rewire the process digraph endgame — replace every occurrence (replace_all)**

Replace every occurrence (expected: 3) of:
```
"Dispatch final code reviewer subagent (../requesting-code-review/code-reviewer.md)"
```
with:
```
"Dispatch final whole-branch review subagent applying the code-review skill"
```

Replace every occurrence (expected: 2) of:
```
"Use superpowers:finishing-a-development-branch"
```
with:
```
"Run verification-before-completion, report branch ready, STOP - merge and cleanup belong to your human partner"
```

- [ ] **Step 6: Rewire the Prompt Templates line**

Old:
```
- Final whole-branch review: use superpowers:requesting-code-review's [code-reviewer.md](../requesting-code-review/code-reviewer.md)
```
New:
```
- Final whole-branch review: dispatch a reviewer subagent that applies the code-review skill (Standards + Spec axes) to the whole branch diff
```

- [ ] **Step 7: Fix the example plan path**

Old:
```
[Read plan file once: docs/superpowers/plans/feature-plan.md]
```
New:
```
[Read plan file once: docs/plans/feature-plan.md]
```

- [ ] **Step 8: Replace the Integration section skill lists**

Old:
```
**Required workflow skills:**
- **superpowers:using-git-worktrees** - Ensures isolated workspace (creates one or verifies existing)
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:requesting-code-review** - Code review template for the final whole-branch review
- **superpowers:finishing-a-development-branch** - Complete development after all tasks

**Subagents should use:**
- **superpowers:test-driven-development** - Subagents follow TDD for each task

**Alternative workflow:**
- **superpowers:executing-plans** - Use for parallel session instead of same-session execution
```
New:
```
**Required workflow skills:**
- **using-git-worktrees** - Optional isolated workspace for heavy work (creates one or verifies existing)
- **writing-plans** - Creates the plan this skill executes
- **code-review** - Two-axis review (Standards + Spec) for the final whole-branch review
- **verification-before-completion** - Final gate before reporting the branch ready
- **receiving-code-review** - Governs how you respond to reviewer subagent feedback

**Subagents should use:**
- **tdd** - Subagents follow seams-based TDD at pre-agreed seams

**After the final review:** run verification-before-completion, then stop and report the branch ready. Merging, sanity testing, and worktree cleanup belong to your human partner - never merge automatically.
```

- [ ] **Step 9: Sweep for stragglers**

```bash
grep -n "superpowers:\|requesting-code-review\|finishing-a-development-branch\|executing-plans\|brainstorm\|docs/superpowers" skills/subagent-driven-development/SKILL.md
```
If any lines remain, apply this mapping and re-run until output is empty: `superpowers:X` → `X`; `requesting-code-review` (any form) → `the code-review skill`; `finishing-a-development-branch` → `verification-before-completion, then stop — the user owns merge and cleanup`; `executing-plans` → delete the line if it only offers the alternative workflow, otherwise replace with `subagent-driven-development`; `brainstorm`/`brainstorming` → `grill`/`grilling`; `docs/superpowers/plans` → `docs/plans`.
Expected final state: no output (exit code 1).

- [ ] **Step 10: Verify prompts stayed verbatim**

```bash
diff superpowers/skills/subagent-driven-development/implementer-prompt.md skills/subagent-driven-development/implementer-prompt.md && \
diff superpowers/skills/subagent-driven-development/task-reviewer-prompt.md skills/subagent-driven-development/task-reviewer-prompt.md && \
diff -r superpowers/skills/subagent-driven-development/scripts skills/subagent-driven-development/scripts && echo PROMPTS-VERBATIM
```
Expected: `PROMPTS-VERBATIM`

- [ ] **Step 11: Commit**

```bash
git add skills/subagent-driven-development
git commit -m "feat: import subagent-driven-development, rewired to code-review axes, verification gate, stop-before-merge"
```

---

### Task 8: Import `using-git-worktrees` (frontmatter only)

**Files:**
- Create: `skills/using-git-worktrees/` (from `superpowers/skills/using-git-worktrees`)
- Modify: `skills/using-git-worktrees/SKILL.md` (frontmatter only)

- [ ] **Step 1: Copy**

```bash
cd /Users/jakub/workspaces/engineering-skills
cp -R superpowers/skills/using-git-worktrees skills/using-git-worktrees
```

- [ ] **Step 2: Frontmatter — make user-invoked (optional tool, never auto-fires)**

Old:
```
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - ensures an isolated workspace exists via native tools or git worktree fallback
---
```
New:
```
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - ensures an isolated workspace exists via native tools or git worktree fallback
disable-model-invocation: true
---
```

- [ ] **Step 3: Verify body untouched**

```bash
diff <(tail -n +5 superpowers/skills/using-git-worktrees/SKILL.md) <(tail -n +6 skills/using-git-worktrees/SKILL.md) && echo BODY-VERBATIM
```
Expected: `BODY-VERBATIM`

- [ ] **Step 4: Commit**

```bash
git add skills/using-git-worktrees
git commit -m "feat: import using-git-worktrees as optional user-invoked tool"
```

---

### Task 9: Write the `/how` router

**Files:**
- Create: `skills/how/SKILL.md`

**Interfaces:**
- Consumes: every user-reachable skill name from Tasks 1–8 (routes to them by exact name).
- Produces: the router; `README.md` (Task 10) is its full-catalog companion.

- [ ] **Step 1: Create `skills/how/SKILL.md` with exactly this content**

```markdown
---
name: how
description: Route me — which track and which command fits what I'm about to do.
disable-model-invocation: true
---

You are the router for the engineering-skills set. The user is deciding how to start. If it isn't obvious from the conversation, ask one question: what are they trying to do? Then name the track and the exact next command. Do not start the work yourself.

## The map

Two tracks. The user picks the gear: every stage boundary is the user typing the next command. Nothing auto-chains, and nothing ever merges automatically.

**Light track** — small changes, single issues; runs inline on the current branch (master included):

1. `/grill-me` — align on what to build (use `/grill-with-docs` when terminology or decisions need capturing)
2. `/implement` — build it: tdd at pre-agreed seams, then code-review, then verification-before-completion, then commit

**Heavy track** — features and multi-step work:

1. `/grill-with-docs` — align, sharpening `CONTEXT.md` and ADRs as you go
2. `/to-spec` — synthesize the conversation into `docs/specs/<feature>.md`
3. `/using-git-worktrees` — optional: isolate the work in a worktree
4. `/writing-plans` — exhaustive plan to `docs/plans/NNNN-<feature>.md`
5. `/subagent-driven-development` — execute: fresh subagent per task with two-stage review; ends with a whole-branch code-review, then verification-before-completion, then STOPS. Merge, sanity testing, and worktree cleanup belong to the user.

**Debugging:** describe the bug — systematic-debugging fires on its own (nudge it by name if it doesn't).

**Disciplines that fire mid-flow** (model-invoked; invoke by name to nudge): systematic-debugging, tdd, code-review, receiving-code-review, verification-before-completion, domain-modeling, codebase-design, grilling, dispatching-parallel-agents, resolving-merge-conflicts, research.

**Other commands:** `/handoff` (compact this session for a future one), `/improve-codebase-architecture` (periodic deep-module sweep), `/writing-great-skills` (when editing this skill set).

Full catalog and provenance: `~/workspaces/engineering-skills/README.md`.
```

- [ ] **Step 2: Verify frontmatter parses (name + flag present)**

```bash
head -5 skills/how/SKILL.md | grep -c "name: how\|disable-model-invocation: true"
```
Expected: `2`

- [ ] **Step 3: Commit**

```bash
git add skills/how
git commit -m "feat: add /how router"
```

---

### Task 10: Write `README.md` (map + provenance)

**Files:**
- Create: `README.md` (repo root)

- [ ] **Step 1: Create `README.md` with exactly this content**

````markdown
# engineering-skills

My personal agent skill set — a deliberate hybrid of [obra/superpowers](https://github.com/obra/superpowers) and [mattpocock/skills](https://github.com/mattpocock/skills), designed 2026-07-13. Design record: `docs/plans/0001-bootstrap-engineering-skills.md` and the grilling session behind it.

**The contract:** two tracks, manual gear shifts. I pick the track; skills never decide for me. No session-start bootstrap, no auto-chaining, and nothing ever merges automatically — verification runs, then the system stops and the branch is mine.

## The two tracks

**Light** — small changes, single issues, inline on the current branch:

```
/grill-me  →  /implement   (tdd at agreed seams → code-review → verification-before-completion → commit)
```

**Heavy** — features and multi-step work:

```
/grill-with-docs  →  /to-spec  →  [/using-git-worktrees]  →  /writing-plans  →  /subagent-driven-development
                     docs/specs/                              docs/plans/       per-task two-stage review,
                                                                                whole-branch code-review,
                                                                                verification, then STOP
```

Lost? Type `/how`.

## Conventions

- `CONTEXT.md` (repo root) — domain glossary; `docs/adr/` — decisions; `docs/specs/` — specs from `/to-spec`; `docs/plans/NNNN-<name>.md` — plans from `/writing-plans`. All created lazily.
- Skill names are inherited from their source repos, unchanged.
- Imported skills are verbatim except the rewirings listed below. The submodule SHAs pin exactly what each import forked from.
- Meta-philosophy for writing and editing these skills: `writing-great-skills`.

## Install

```bash
scripts/link-skills.sh
```

Symlinks every skill in `skills/` into `~/.agents/skills` and `~/.claude/skills`. Edits in this repo are live immediately; re-run after adding, removing, or renaming a skill.

## Reference

U = user-invoked (slash only) · M = model-invoked (fires on its own)

<!-- provenance:begin -->
| Skill | Inv. | Role | Source | Changes |
|---|---|---|---|---|
| how | U | Router over the whole set | original | — |
| grill-me | U | Interview to align before building | mattpocock `skills/productivity/grill-me` | verbatim |
| grill-with-docs | U | Grill + CONTEXT.md/ADRs inline | mattpocock `skills/engineering/grill-with-docs` | verbatim |
| to-spec | U | Conversation → `docs/specs/<name>.md` | mattpocock `skills/engineering/to-spec` | tracker → local file; gear-shift ending |
| implement | U | Light-track build | mattpocock `skills/engineering/implement` | + verification-before-completion gate |
| writing-plans | U | Exhaustive plan → `docs/plans/` | superpowers `skills/writing-plans` | user-invoked; docs/plans path; grilling refs; SDD-only handoff |
| subagent-driven-development | U | Heavy-track execution engine | superpowers `skills/subagent-driven-development` | user-invoked; code-review axes; verification gate; stop-before-merge |
| using-git-worktrees | U | Optional isolation for heavy work | superpowers `skills/using-git-worktrees` | user-invoked |
| handoff | U | Compact session → handoff doc | mattpocock `skills/productivity/handoff` | verbatim |
| improve-codebase-architecture | U | Deep-module sweep + report | mattpocock `skills/engineering/improve-codebase-architecture` | verbatim |
| writing-great-skills | U | Meta: how to write skills | mattpocock `skills/productivity/writing-great-skills` | verbatim |
| grilling | M | The reusable interview loop | mattpocock `skills/productivity/grilling` | verbatim |
| tdd | M | Seams-based red-green loop | mattpocock `skills/engineering/tdd` | verbatim |
| code-review | M | Two-axis review (Standards + Spec) | mattpocock `skills/engineering/code-review` | verbatim |
| receiving-code-review | M | Rigor when subagent review feedback arrives | superpowers `skills/receiving-code-review` | description rescoped |
| verification-before-completion | M | Universal completion gate | superpowers `skills/verification-before-completion` | verbatim |
| systematic-debugging | M | 4-phase root-cause debugging | superpowers `skills/systematic-debugging` | refs → tdd, verification-before-completion |
| dispatching-parallel-agents | M | Concurrent subagent workflows | superpowers `skills/dispatching-parallel-agents` | verbatim |
| domain-modeling | M | Glossary + ADR discipline | mattpocock `skills/engineering/domain-modeling` | verbatim |
| codebase-design | M | Deep-module vocabulary | mattpocock `skills/engineering/codebase-design` | verbatim |
| resolving-merge-conflicts | M | Conflict resolution by intent | mattpocock `skills/engineering/resolving-merge-conflicts` | verbatim |
| research | M | Cited findings → Markdown in repo | mattpocock `skills/engineering/research` | verbatim |
<!-- provenance:end -->

## Sources

`superpowers/` and `mattpocock-skills/` are git submodules pinning the exact upstream commits these skills were imported from. Diff any skill against its source to see the full delta:

```bash
diff -r superpowers/skills/writing-plans skills/writing-plans
```
````

- [ ] **Step 2: Verify every skill directory has a README row and vice versa**

```bash
cd /Users/jakub/workspaces/engineering-skills
for d in skills/*/; do n=$(basename "$d"); grep -q "^| $n " README.md || echo "MISSING ROW: $n"; done
grep -c "^| " README.md
```
Expected: no `MISSING ROW` lines; row count `23` (22 skills + header row).

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: README with track map and provenance table"
```

---

### Task 11: Write `scripts/link-skills.sh` and `scripts/check-refs.sh`

**Files:**
- Create: `scripts/link-skills.sh` (executable)
- Create: `scripts/check-refs.sh` (executable)

**Interfaces:**
- Produces: idempotent linker: repo `skills/*` → `~/.agents/skills/<name>` and `~/.claude/skills/<name>`. Refuses to clobber real (non-symlink) entries; prunes dead symlinks it finds.
- Produces: `check-refs.sh`, the whole-set dangling-reference sweep (exit 0 = clean). Task 12 runs it, and every future upstream update (plan 0002) reruns it.

- [ ] **Step 1: Create `scripts/link-skills.sh` with exactly this content**

```bash
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
```

- [ ] **Step 2: Make executable and syntax-check**

```bash
chmod +x scripts/link-skills.sh
bash -n scripts/link-skills.sh && echo SYNTAX-OK
```
Expected: `SYNTAX-OK`

- [ ] **Step 3: Test against a throwaway HOME (does not touch the real install)**

```bash
TESTHOME=$(mktemp -d)
HOME="$TESTHOME" bash scripts/link-skills.sh | tail -3
ls "$TESTHOME/.claude/skills" | wc -l
readlink "$TESTHOME/.claude/skills/how"
rm -rf "$TESTHOME"
```
Expected: link lines printed; count `22`; readlink shows `/Users/jakub/workspaces/engineering-skills/skills/how`.

- [ ] **Step 4: Create `scripts/check-refs.sh` with exactly this content**

```bash
#!/usr/bin/env bash
# Whole-set dangling-reference sweep: fails if any skill still references
# dropped upstream skill names, prefixes, or paths.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"
bad=0

if grep -rn "superpowers:\|setup-matt-pocock\|docs/superpowers\|ask-matt" skills/ --include=SKILL.md; then
  bad=1
fi
if grep -rln "brainstorming skill\|requesting-code-review\|finishing-a-development-branch" skills/ --include=SKILL.md; then
  bad=1
fi

if [ "$bad" -eq 0 ]; then
  echo "check-refs: clean"
fi
exit "$bad"
```

- [ ] **Step 5: Make executable, syntax-check, and run against the imported set**

```bash
chmod +x scripts/check-refs.sh
bash -n scripts/check-refs.sh && echo SYNTAX-OK
scripts/check-refs.sh
```
Expected: `SYNTAX-OK`, then `check-refs: clean` with exit code 0 (Tasks 1–8 already imported and rewired every skill).

- [ ] **Step 6: Commit**

```bash
git add scripts/link-skills.sh scripts/check-refs.sh
git commit -m "feat: link-skills.sh installer and check-refs.sh dangling-reference sweep"
```

---

### Task 12: Swap the stale installs for repo symlinks

**Files:**
- Modify: `~/.agents/skills/` and `~/.claude/skills/` (outside the repo — destructive; the diff review in Step 1 is the safety gate)

- [ ] **Step 1: Diff review — prove the old copies hold nothing worth keeping**

The `~/.agents/skills` copies are Jul-10 snapshots of upstream. Differences vs. our fresh imports should be *upstream drift only*. For each old copy that has a counterpart in the repo:

```bash
cd /Users/jakub/workspaces/engineering-skills
for d in ~/.agents/skills/*/; do n=$(basename "$d"); if [ -d "skills/$n" ]; then echo "== $n"; diff -r "$d" "skills/$n" | head -20; fi; done
```

Read the output. Expected: small wording drift and our known rewirings. **If any difference looks like a local customization (content that exists in the old copy but in NEITHER source checkout), STOP and show it to Jakub before deleting anything.** Cross-check suspicious hunks:

```bash
grep -rn "<suspicious phrase>" superpowers/skills mattpocock-skills/skills
```

- [ ] **Step 2: Remove the old copies and stale links**

Old skills with no successor (dropped by design): `diagnosing-bugs`, `prototype`, `wayfinder`, `executing-plans`, `finishing-a-development-branch`, `requesting-code-review`, `test-driven-development`, `writing-skills` — plus all stale keeper copies (replaced by symlinks next step).

```bash
rm -rf ~/.agents/skills/*
find ~/.claude/skills -maxdepth 1 -type l -delete
```

- [ ] **Step 3: Link the new set**

```bash
cd /Users/jakub/workspaces/engineering-skills
scripts/link-skills.sh
```
Expected: 44 `linked:` lines (22 skills × 2 targets), exit code 0, no `SKIP` lines.

- [ ] **Step 4: Verify the installed set**

```bash
ls ~/.claude/skills | wc -l
ls ~/.claude/skills | sort | diff - <(ls /Users/jakub/workspaces/engineering-skills/skills | sort) && echo SETS-MATCH
readlink ~/.claude/skills/grilling
```
Expected: `22`; `SETS-MATCH`; `/Users/jakub/workspaces/engineering-skills/skills/grilling`.

- [ ] **Step 5: Whole-set dangling-reference sweep**

```bash
cd /Users/jakub/workspaces/engineering-skills
scripts/check-refs.sh
```
Expected: `check-refs: clean`, exit code 0.

- [ ] **Step 6: Final commit (nothing should be dirty; confirm clean tree)**

```bash
git status --short
```
Expected: empty output. New sessions now load the set from this repo. Remind Jakub: current Claude Code sessions keep the old skill snapshot until restarted, and the submodule conversion of `superpowers/` and `mattpocock-skills/` is his manual follow-up.
```

---

## Self-Review

- **Spec coverage:** 22 skills → Task 1 (14) + Tasks 2–8 (7 imports with edits) + Task 9 (how) = 22. Rewirings from the design: to-spec→docs/specs (T2), implement verification gate (T3), receiving-code-review rescope (T4), systematic-debugging repoints (T5), writing-plans conventions + SDD-only handoff (T6), SDD full rewire incl. stop-before-merge (T7), worktrees optional/user-invoked (T8), router (T9), README provenance (T10), link script (T11), install swap + diff-review guard (T12). ✓
- **Placeholder scan:** all edits carry exact old/new text; fresh files carry complete content; Task 7 Step 9 and Task 12 Step 1 are bounded sweeps with explicit mappings and stop conditions, not "handle appropriately". ✓
- **Consistency:** skill names referenced across tasks (`tdd`, `code-review`, `verification-before-completion`, `how`) match the directory names created in Tasks 1 and 9; plan-path convention `docs/plans/NNNN-<feature-name>.md` used consistently in T6, T7, T9, T10 — and by this very file. ✓
