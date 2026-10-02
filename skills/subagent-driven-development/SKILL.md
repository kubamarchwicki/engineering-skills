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

The numbered sequence below is authoritative. For diagrams or a worked
example, consult [EXAMPLES.md](EXAMPLES.md).

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

Batch small independent edits of the same kind into one brief listing every
file and change; review the batch as one unit. Use separate dispatches when
work needs its own judgment, tests, or review surface. Never dispatch multiple
implementation subagents in parallel. Workers never spawn helpers or reviewers;
the controller supplies each review seat.

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

Check `<workspace>/progress.md` first; create it only when absent, with first line
`# SDD ledger — plan: <plan file path>`. For a matching identity,
`Task <N>: complete` means DONE: never re-dispatch it. Resume at the first
incomplete task; a last fix-round line resumes at the next round. Leave a
mismatched ledger or old flat `.superpowers/sdd/progress.md` alone.
**Recovery:** after compaction, resumed execution, identity mismatch, or scratch
loss, you MUST read [RECOVERY.md](RECOVERY.md) before dispatch. Trust the ledger
and git history; `git clean -fdx` destroys this scratch workspace.

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

Before dispatching Task 1, scan the plan once for conflicts, writing down
what you checked as you check it:

- tasks that contradict each other or the plan's Global Constraints
- anything the plan explicitly mandates that the review rubric treats as a
  defect (a test that asserts nothing, verbatim duplication of a logic block)

The scan's output is a table, not a verdict. One row for every pair of tasks
that share a file or an interface: the two tasks, what one produces against
what the other consumes, and what you found. One row for every task: whether
its own text agrees with itself — the tests it specifies against the code it
specifies, the files it creates against the files it later touches. "The scan
is clean" without those rows is not a scan you ran.

Write the table to the ledger and record Provisional interfaces as unresolved
dependencies. Investigate each finding; update routine inconsistencies in the
plan, and obtain the user decision for consequential conflicts before affected
work proceeds. Dispatch only semantically Ready tasks. The review loop remains
the net for conflicts that only emerge from implementation.

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

Template: [implementer-prompt.md](implementer-prompt.md)

### 3. Handle the report

Implementer subagents report one of four statuses. Handle each appropriately:

**DONE:** Proceed to task review.

**DONE_WITH_CONCERNS:** The implementer completed the work but flagged doubts. Read the concerns before proceeding. If the concerns are about correctness or scope, address them before review. If they're observations (e.g., "this file is getting large"), note them and proceed to review.

**NEEDS_CONTEXT:** The implementer needs information that wasn't provided. Provide the missing context and re-dispatch.

**BLOCKED:** The implementer cannot complete the task. Assess the blocker:
1. If it's a context problem, provide more context and re-dispatch with the same model
2. If the task requires more reasoning, re-dispatch with a more capable model
3. If the task is too large, break it into smaller pieces
4. If the plan itself is wrong, classify and investigate the defect; update routine details or obtain the consequential user decision before redispatch. Record the disposition in the plan and ledger.

**Never** ignore an escalation or force the same model to retry without changes. If the implementer said it's stuck, something needs to change.

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
The task reviewer may report "⚠️ Cannot verify from diff" items — requirements
that live in unchanged code or span tasks. These do not block the rest of the
review, but you must resolve each one yourself before marking the task
complete: you hold the plan and cross-task context the reviewer
lacks. If you confirm an item is a real gap, treat it as a blocking finding
in the affected review concern — it enters the fix loop with the other findings.

Template: [task-reviewer-prompt.md](task-reviewer-prompt.md)

### 5. Repair blocking findings

A blocking finding in any of the four concerns — a Critical/Important issue or
a controller-confirmed real gap — triggers repair. Before a task repair, final
repair wave, or adjudication of residual findings, you MUST read
[REPAIR.md](REPAIR.md) and follow its evidence and scoped re-review procedure.

A task has at most five rounds, each one fix dispatch plus one scoped re-review.
Rounds 1–3 resume the original implementer (fresh only if the harness cannot
resume); rounds 4–5 use a fresh implementer at least one model tier higher.
Record each round in the ledger. The controller never fixes code itself.

Record Minor findings in the ledger and durable plan for final-review triage;
defer only non-blocking items that leave accepted outcomes valid. Investigate
plan-mandated or plan-conflicting findings under receiving-code-review; update
routine details or obtain consequential user decisions before affected work
resumes. A ruling cannot override agreed outcomes or ADRs.

After round 5, stop dispatching and adjudicate every open finding: reject
unsupported findings with inspectable evidence and both sides recorded; defer
real non-blocking findings with reason, evidence, and limits; preserve real
blocking findings as unresolved. Record dispositions in the plan and ledger.
Blocked tasks and dependants remain incomplete; unrelated Ready work may
continue. Caps never waive acceptance, and findings never disappear silently.

### 6. Complete the task

Complete requires supported acceptance and all four review conclusions, with
no real blocking finding. Record deferred non-blocking items and limits in the
plan, then append `Task <N>: complete (commits <base7>..<head7>, four conclusions
supported, <K> non-blocking deferred)` to the ledger and mark the todo complete.
An unresolved blocking finding leaves the task incomplete and blocks affected
dependants. Assess readiness again before dispatching later tasks. Repeat
steps 2–6 for remaining Ready tasks; unresolved work stays visible.

### 7. Review the whole branch

After all tasks are complete, generate a package from the fixed Execution
base. Dispatch on the most capable
available model, applying `code-review` for its Standards and Spec axes. Both
final reviewers receive applicable agreement, decision/source revisions,
acceptance evidence, and unresolved/deferred findings from the durable plan.
Require four supported conclusions: implementation correctness, design validity,
evidence quality, and scope and standards.

If findings remain, follow [REPAIR.md](REPAIR.md): dispatch ONE fix subagent with
the complete findings list and run exactly one scoped re-review of that wave
using FIX_BASE. Apply the breaker dispositions to residual findings. There is
no second fix wave; real blocking findings mean incomplete work. Report
unresolved work and consequential decisions to your human partner.

### 8. Preserve evidence, assess gates, and stop

Before scratch cleanup, maintain this section in the plan:

```markdown
## Execution record
- Agreement baseline: [revision and document paths]
- Execution base: [fixed revision]
- Task refinements: [task, decision/source revision, finding, disposition, reason]
- Acceptance evidence: [criterion, command, exit status, tested state including
  relevant dirty changes, relevant conditions, output/stable reference, limits]
- Review conclusions: [four concerns, evidence, unresolved/deferred findings]
```

Preserve relevant output or sufficient inspectable summaries; links to
soon-deleted scratch are insufficient. Preserve additional logs where the
claim needs them. Commit agreed plan/evidence updates during task/fix
bookkeeping before deleting their only scratch source. Substantive decisions
follow ADR supersession. After scratch loss, recover from committed documents
and durable evidence, using git history and recorded baselines.

Apply verification-before-completion and assess accepted outcomes and required
gates against current applicable evidence before cleanup. Branch Ready requires
supported accepted outcomes and all required gates with no blocking gap.
Only then delete eligible scratch for this plan, leaving sibling workspaces
alone. Report actual completion, deferred limits, and unresolved work, and stop.
Merging, sanity testing, and Git-worktree cleanup belong to your human partner.
