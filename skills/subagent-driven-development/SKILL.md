---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
disable-model-invocation: true
---

# Subagent-Driven Development

Execute an implementation plan in this session: a fresh implementer per task,
a task review after each, and a broad whole-branch review at the end. Construct
isolated task context; subagents never inherit your session history. Use for
mostly independent tasks; without a plan or with tightly coupled tasks, use
manual execution or grill first.

The numbered sequence below and its required references are authoritative.
Read each reference when its stated condition applies. For diagrams or a
worked example, consult [EXAMPLES.md](EXAMPLES.md).

**Narration:** between tool calls, narrate at most one short line — the ledger
and tool results carry the record.

**Decisions and feedback:** apply receiving-code-review to classify findings.
Continue Ready work within agreed outcomes, ownership, and scope. Investigate
routine facts and reversible details yourself; record refinements and evidence
in the plan before dispatch. Your human partner decides changes to behavior,
ownership, or scope. Investigate first, then present the tradeoff and
recommendation. Already explicit user direction is sufficient authorization.

A consequential unknown or decision blocks affected work and its dependants;
unaffected Ready work may continue. Preserve existing approval boundaries for
destructive, irreversible, security-sensitive, or externally publishing actions.
A plan with no evidenced path forward waits for clarification. A retry cap ends
repeated dispatch; it does not satisfy an unmet requirement.

## Dispatch rules

**Batching:** when the plan lists small independent edits of the same kind,
read [references/batching.md](references/batching.md) before dispatch.

Never dispatch multiple implementation subagents in parallel. Workers never
spawn helpers or reviewers; the controller supplies each review seat.

Hand artifacts over as files. Every dispatch contains only its task, relevant
interfaces/decisions, and Global Constraints; accumulated session history stays
out of it.

**Model Selection:** explicitly specify the least powerful model that can
handle the role. Turn count matters more than token price: use a mid-tier floor
for reviewers and implementers working from prose. Complete-code transcription
plus testing and single-file mechanical fixes use the cheapest tier. Integration,
multi-file coordination, and debugging use a standard model; architecture or
broad design judgment use the most capable available model. Scale reviews to
diff complexity and risk; small scoped fix reviews take a cheap-to-mid tier.
Rounds 4–5 use at least one tier above the stuck implementer. The final
whole-branch review uses the most capable available model, not the session default.

**Review packages:** from this skill's directory, run
`bash scripts/review-package PLAN_FILE BASE HEAD` and pass the unique printed
path to the reviewer. BASE is the recorded pre-dispatch commit for a task,
FIX_BASE is the head the preceding review saw for a fix, and EXECUTION_BASE is
the fixed execution baseline for final review. Never use `HEAD~1`: tasks may
have multiple commits. Without bash, redirect the range's `git log --oneline`,
`git diff --stat`, and `git diff -U10` into one unique file. Keep package output
out of controller context; never dispatch a reviewer without a diff file.

**Waiting:** keep working on local ledger, packaging, and report work while
children run. When idle, wait in bounded stretches (five to ten minutes where
the platform allows), then post one status line, list live children, and chase
finished children that did not report. Avoid short polling and silent open-ended
waits.

## Numbered sequence

### 1. Set up and assess readiness

If the user chose isolation, use `using-git-worktrees` to create a worktree or verify the existing one. Otherwise work on the current branch.
Never start implementation on a main/master branch without your human
partner's explicit consent.

Track progress in a ledger, not only todos. Run this skill's
`bash scripts/sdd-workspace PLAN_FILE` at start; its printed git-ignored
`<repo-root>/.superpowers/sdd/` directory owns this plan's ledger, briefs,
reports, and packages. Another plan's workspace is never yours to read or write.

Check `<workspace>/progress.md` first. If it exists, or after compaction,
resumed execution, identity mismatch, or scratch loss, you MUST read
[references/resuming.md](references/resuming.md) before dispatch.
Create the ledger only when absent, with first line
`# SDD ledger — plan: <plan file path>`.

Read the plan's outcomes, verification criteria, Global Constraints, and
decision sources: applicable glossary/ADRs and any optional spec. Resolve
conflicts against current agreed decisions. A missing separate spec does not
make the agreement provisional. Escalate conflicting decisions rather than
inventing precedence between contradictory sources.

Before the first production task, ensure the agreed plan and relevant
glossary/ADR changes exist in a committed revision. Reuse an existing revision
representing that content. Otherwise stage only agreed document paths,
inspect the exact staged change, and create a focused documentation commit.
Preserve unrelated staged/working-tree changes; report a concrete obstruction
if a safe path-scoped commit cannot be made.

Record the Agreement baseline revision and paths. Record Execution base once
before the first implementation task and use it for final review; never
recompute it from main/master after inline execution has moved that branch.
Resume with the recorded values.

Keep Ready and Provisional tasks visible. Before dispatch, verify dependencies
and evidence, make permitted refinements, and update the Ready task before
extraction. A behavior, ownership, or scope change requires your human
partner's decision first.

A Ready task carries concrete acceptance conditions, decision references,
relevant assumptions/evidence, exact interfaces, and verification steps.
Supply applicable Global Constraints with the brief. Legacy tasks without
Status require the same readiness assessment and context.

Before dispatching Task 1, read
[references/preflight.md](references/preflight.md) and run its conflict scan.
Resolve consequential findings before affected work proceeds.

### 2. Dispatch the implementer

Record BASE (`git rev-parse HEAD`) before dispatching — the review package
and fix-round diffs need it.

- **Task brief:** before dispatching an implementer, run this skill's
  `bash scripts/task-brief PLAN_FILE N` — it extracts the task's full text to a
  uniquely named file and prints the path. Require exit 0 and semantic readiness;
  never reuse cached output after failed extraction. Compose the dispatch so the
  brief stays the single source of
  requirements. Your dispatch should contain: (1) one line on where this
  task fits in the project; (2) the brief path, introduced as "read this
  first — it is your requirements, with the exact values to use verbatim";
  (3) interfaces and decisions from earlier tasks that the brief cannot
  know; (4) permitted refinements and already agreed decisions;
  (5) the report-file path and report contract. Exact values (numbers,
  magic strings, signatures, test cases) appear only in the brief. Never
  make a subagent read the whole plan file.
- **Report file:** name the implementer's report file after the brief
  (brief `…/task-N-brief.md` → report `…/task-N-report.md`) and put it in
  the dispatch prompt. The implementer writes the full report there and
  returns only status, commits, a one-line test summary, and concerns.
- Supply applicable Global Constraints, current task/decision revisions,
  baseline/current source references, and relevant evidence to both implementer
  and reviewer. Carry unresolved/deferred findings that affect the task, using
  durable plan records rather than only scratch pointers.
- Record the implementer's agent identity from the dispatch result —
  fix-loop rounds 1-3 resume this agent.

Use [implementer-prompt.md](implementer-prompt.md) for every implementation
and fix dispatch. Its `tdd` skill invocation is mandatory even when the task
does not mention TDD. Supply the pre-agreed test seams; resolve missing seam
agreement with your human partner before behavioral implementation begins.

### 3. Handle the report

Implementer subagents report one of four statuses. Handle each appropriately:

**DONE:** Proceed to task review.

**Any other status** (DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED): read
[references/handling-reports.md](references/handling-reports.md) and follow
it, every time you get one.

If the implementer asks questions — before starting or mid-task — answer
clearly and completely, provide additional context if needed, and don't
rush it into implementation.

### 4. Review the task

Per-task reviews are task-scoped gates. The broad review happens once, at the
final whole-branch review. Never skip the task review, and never accept a
report missing any of the four conclusions: implementation correctness, design
validity, evidence quality, and scope and standards. Each must be supported;
resolve evidence gaps before claiming the affected criterion verified.
Implementer self-review never replaces the task review; both are
needed.

- Generate the task review package using the recorded BASE (see Dispatch rules).
- **Reviewer inputs:** the task reviewer gets three paths — the same brief
  file, the report file, and the review package — plus the global
  constraints that bind the task, applicable agreement/baseline and current
  source references, decision revisions, evidence, and deferred findings.
- The global-constraints block you hand the reviewer is its attention
  lens. Copy the binding requirements verbatim from the plan's Global
  Constraints section or the spec: exact values, exact formats, and the
  stated relationships between components ("same layout as X", "matches
  Y"). The reviewer's template already carries the process rules (YAGNI,
  test hygiene, review method) — the constraints block is for what THIS
  project's spec demands.
- Do not add open-ended directives like "check all uses" or "run race tests
  if useful" without a concrete, task-specific reason
- Do not ask a reviewer to re-run tests the implementer already ran on the
  same code — the implementer's report carries the test evidence
- Do not pre-judge findings for the reviewer — never instruct a reviewer to
  ignore or not flag a specific issue. If you believe a finding would be a
  false positive, let the reviewer raise it and adjudicate it in the review
  loop. If the prompt you are writing contains "do not flag," "don't treat X
  as a defect," "at most Minor," or "the plan chose" — stop: you are
  pre-judging, usually to spare yourself a review loop.

If the reviewer reports "⚠️ Cannot verify from diff" items, read
[references/cannot-verify.md](references/cannot-verify.md) and resolve each
item before marking the task complete.

Template: [task-reviewer-prompt.md](task-reviewer-prompt.md)

### 5. Repair blocking findings

A blocking finding in any of the four concerns — a Critical/Important issue or
a controller-confirmed real gap — triggers repair. Before every task fix round,
final repair wave, or adjudication of residual findings, you MUST read
[references/fix-loop.md](references/fix-loop.md) and follow it. Read it again
before each round; do not rely on memory after compaction.

A retry cap ends dispatch, never acceptance requirements. Unresolved blocking
findings leave affected work and its dependants incomplete.

### 6. Complete the task

Complete requires supported acceptance and all four review conclusions, with
no real blocking finding. Record deferred non-blocking items and limits in the
plan, then append `Task <N>: complete (commits <base7>..<head7>, four conclusions
supported, <K> non-blocking deferred)` to the ledger and mark the todo complete.
An unresolved blocking finding leaves the task incomplete and blocks affected
dependants. Assess readiness again before dispatching later tasks. Repeat
steps 2–6 for remaining Ready tasks; unresolved work stays visible.

### 7. Review the whole branch

After all tasks are complete, read
[references/final-review.md](references/final-review.md) and follow its
test-audit, both Thermos passes, whole-branch code-review, and scoped repair procedure from the
fixed Execution base.

### 8. Preserve evidence, assess gates, and stop

Follow [the finish procedure](references/final-review.md#preserve-evidence-assess-gates-and-stop)
before cleanup or reporting completion. Preserve durable evidence, apply
verification-before-completion, and stop. Merging, sanity testing, and
Git-worktree cleanup belong to your human partner.
