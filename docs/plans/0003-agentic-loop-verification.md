# Agentic Loop Verification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expose wrong assumptions before detailed implementation and preserve decisions and applicable verification evidence through both development Tracks.

**Architecture:** Rewire the existing owners: grilling establishes the foundation, planning validates it, execution handles observable slices, and the existing reviewers assess four concerns. Add one supporting design-reviewer prompt within `writing-plans` and a narrow guard in the existing task extractor; retain the existing commands and reviewer structure.

**Tech Stack:** Markdown, Git, Bash 3.2, POSIX awk, and Python 3 `unittest` for disposable extractor fixtures.

**Spec:** [ADR 0004](../adr/0004-record-grilling-outcomes-in-glossary-and-adrs.md), [ADR 0005](../adr/0005-validate-designs-before-detailed-planning.md), [GLOSSARY.md](../../GLOSSARY.md), and the [confirmed interview](../research/agentic-planning-verification-notes.md), committed at `b5f8c61`. The [original research](../research/optimizing-agentic-loop.md) supplies the motivating failures. A separate feature spec is unnecessary.

## Global Constraints

- Preserve the two Tracks, inherited names, invocation flags, manual Gear Shifts, and the user's ownership of merge, sanity testing, and worktree cleanup.
- Never push, merge, or install consuming-project skills during this plan.
- Keep `GLOSSARY.md`, `docs/adr/`, optional `docs/specs/`, and numbered `docs/plans/` conventions. `how` remains the only original distributed skill.
- Treat the source submodules as read-only. Planning pins: mattpocock `d81f3a183412e71a5b1e84ca21bc1a35eea03a60`; superpowers `8ca22dba9a94f28898bbce59f2537ff4d87c747d`.
- Preserve unrelated upstream prose, directories, and “your human partner” wording. Record each intentional rewiring in `provenance.tsv` in the task that introduces it.
- Provenance has exactly seven tab-separated columns. Generate its README table; never edit that block by hand.
- Shell scripts target macOS `/bin/bash` 3.2 with `#!/usr/bin/env bash` and `set -euo pipefail`. Use portable awk, no associative arrays or GNU-only flags.
- Record each task's scenario/check evidence in this plan's Execution record before its commit. The plan is an agreed documentation path in every task.
- Commit each task with its stated message and explicit paths, preserving unrelated index and working-tree changes. Check named paths for mixed unrelated edits before staging; resolve any overlap without committing unrelated content.
- Use repository skill files for this work. The confirmed ADRs supersede current SDD passages permitting unilateral changes to agreed behavior/ownership/scope or completion with real blocking failures.
- All tasks in this plan are Ready. Bracketed fields in proposed templates are literal fields for future callers, not missing implementation decisions.

## Outcome and verification

| ID | Observable result | Verification owner |
| --- | --- | --- |
| C1 | Grilling separates outcomes, facts, assumptions, and user decisions. | Task 1 ownership scenario. |
| C2 | ADR/glossary-based planning works without a mandatory spec and always obtains a heavy-track design review. | Task 2 readiness scenarios. |
| C3 | Provisional tasks cannot yield reusable dispatch briefs; task-local context reaches workers. | Task 5 extractor tests and dispatch walkthrough. |
| C4 | Reuse is tied to claim and relevant tested state; changes and required gates trigger necessary checks. | Task 3 evidence scenarios. |
| C5 | Reviews assess correctness, design, evidence, and scope/standards against the actual work. | Task 4 four-concern and working-tree review scenarios. |
| C6 | Execution preserves its baseline and user decision boundaries through refinement, caps, and resume. | Task 5 lifecycle scenarios. |
| C7 | Decisions and inspectable evidence survive scratch cleanup. | Tasks 1 and 5 supersession/cleanup scenarios. |
| C8 | Both Tracks and the documented upstream provenance remain consistent. | Per-task closeout and final checks. |

## Investigation and independent design review

The following evidence was obtained before decomposition, using disposable directories outside submodules:

- Actual `task-brief` kept per-task context but omitted header outcomes; it accepted Provisional with exit 0. Missing-task exit 3 was followed by a successful extraction.
- The seven Task 5 tests produced eight failed assertions across five test methods against the current script. A temporary Bash/awk prototype passed all seven: explicit readiness, stale output rejection, malformed/duplicate status, nested fences, legacy extraction, failure recovery, and output alias protection.
- In a temporary Git repository, `git diff BASE...HEAD` missed uncommitted changes. `git diff BASE -- tracked.txt` plus untracked enumeration exposed them.
- After inline commits on `main`, recomputing its merge base yielded `HEAD` and `review-package` rejected the empty range with exit 3. The fixed starting revision produced the correct package with exit 0.
- A disposable repository confirmed `git commit --only` with explicit agreed paths includes selected existing/new files and preserves unrelated staged content. Per-task commands below use this form.
- A fresh independent reviewer accepted the architecture with seven required dispositions: update all SDD decision/cap paths; provide task-local context; guard extraction; fix review artifact boundaries; supply both reviewers with agreement/evidence; preserve inspectable evidence; distinguish design review from author self-review. All are incorporated below.

Temporary fixtures are removed after recording results. This evidence proves the technical boundary assumptions; instruction behavior still requires the implementation-time walkthroughs.

## Ownership and dependencies

`grilling` owns discovery; `domain-modeling` owns glossary/ADRs; `writing-plans` owns readiness/design review/task contracts; `verification-before-completion` owns evidence validity; review skills own conclusions and feedback; SDD owns baseline, dispatch, refinement, durable records, and completion. `task-brief` checks explicit readiness metadata but does not decide semantic readiness. Existing `review-package` and `sdd-workspace` interfaces remain sufficient.

Execute Tasks 1–5 sequentially. Task 2 consumes Task 1; Task 3 defines evidence used by Tasks 4–5; Task 4 defines conclusions enforced by Task 5.

## Review Focus

- Ownership evidence contradicts an ADR: affected work waits for the user; unrelated Ready work may continue.
- The real integration boundary is unavailable: retain the limitation and dependent Provisional status.
- Ready becomes Provisional after an earlier extraction: reject and invalidate the stale brief.
- The review cap is reached with an acceptance failure: retries end, but completion remains blocked.
- Light-track work includes an untracked file: review its contents before committing.

---

### Task 1: Establish outcomes and durable decisions during grilling

**Status:** Ready
**Outcome and acceptance:** Grilling exposes observable outcomes and consequential ownership unknowns; changed accepted decisions get superseding ADRs. Both Step 3 scenarios follow those boundaries without adding heavy gates to the Light Track.
**Decision context:** C1/C7/C8; ADR 0004/0005; existing grilling fact-finding and domain-modeling ownership.

**Files:** Modify `skills/grilling/SKILL.md`, `skills/domain-modeling/SKILL.md`, `skills/domain-modeling/ADR-FORMAT.md`, `provenance.tsv`, and generated `README.md`.

**Interfaces:**
- Consumes user intent and existing source/decision documents.
- Produces observable outcomes, constraints, exclusions, acceptance criteria, cited facts, consequential assumptions, and explicit user decisions. Existing wrappers keep composing these skills.

- [x] **Step 1: Insert this before grilling's final “The session is done” paragraph.**

~~~markdown
## Establish the foundation

Before concluding, establish observable behavior, constraints, exclusions,
and acceptance criteria. Describe success without depending on proposed
classes or modules; distinguish requirements from implementation proposals.

For responsibilities the change touches, investigate existing code and
dependency capabilities. Trace who creates, retains, updates, and releases
state. Distinguish source-verified facts, consequential assumptions, and
decisions requiring the user's judgment.

Resolve routine facts and reversible implementation details yourself. For
changes to behavior, ownership, or scope, present evidence, a concrete
tradeoff, and a recommendation to the user before settling dependent work.

You may run bounded temporary integration experiments answering a named
uncertainty. Observe the actual boundary through normal execution, meaningful
failure, and the next operation after failure. Preserve findings, ownership
observations, and limits; production implementation belongs to execution.
If the real boundary cannot be exercised, retain the uncertainty.

When domain-modeling is active, record terminology in GLOSSARY.md and durable
decisions in ADRs as they settle. A separate living spec is optional.

The foundation is ready for the shared-understanding check when success is
observable, relevant responsibilities have identified owners, and consequential
unknowns are explicit. Planning withholds detailed tasks dependent on unresolved
assumptions while allowing unaffected work to be planned.
~~~

Keep the existing fact-finding delegation and final shared-understanding instructions.

- [x] **Step 2: Append this after domain-modeling's ADR criteria.**

~~~markdown
### Preserve decisions as they change

A substantive change to an accepted ADR decision gets a new numbered ADR
explicitly superseding it. Preserve the old decision body and add status
metadata linking to its replacement. Clarifications preserving meaning may
be edited in place.

Keep GLOSSARY.md focused on terminology. The numbered implementation plan
contains concrete outcomes, acceptance checks, slices, and evidence derived
from grilling and linked to applicable ADRs. A separate living spec is optional.
~~~

Add this to the Status guidance in `ADR-FORMAT.md`:

~~~markdown
For a substantive replacement, the new ADR names `Supersedes: ADR-NNNN`;
the old ADR gains `status: superseded by ADR-NNNN` frontmatter and retains
its decision body. For example, ADR-0006 supersedes ADR-0002; ADR-0002 gains
`status: superseded by ADR-0006`. In-place clarification preserves meaning.
~~~

Retain the existing threshold for creating ADRs.

- [x] **Step 3: Verify two behavior scenarios from the edited repository files.**

Record the next action and supporting passages:
1. User proposes a reconnect manager; the client already reconnects, cleanup ownership is unknown. Investigate cleanup, separate outcome from wrapper proposal, and expose the consequential unknown.
2. Evidence motivates moving state ownership from A in an accepted ADR to B. Obtain the user decision, create a superseding ADR, and update old status; glossary changes cannot authorize the move.

Bare `grill-me` must not gain a mandatory heavy plan, committed baseline, or design-review stage.

- [x] **Step 4: Record provenance and commit.**

Replace the existing `verbatim` value in these `changes` cells with the respective phrase:
- grilling: `outcome and ownership investigation; bounded experiments; explicit consequential decisions`
- domain-modeling: `ADR supersession; glossary/ADR/plan responsibility split`

~~~bash
scripts/gen-readme-table.sh
table_sha=$(git hash-object README.md)
scripts/gen-readme-table.sh
test "$table_sha" = "$(git hash-object README.md)"
scripts/check-refs.sh
git diff --check
git add skills/grilling/SKILL.md skills/domain-modeling/SKILL.md skills/domain-modeling/ADR-FORMAT.md provenance.tsv README.md docs/plans/0003-agentic-loop-verification.md
git diff --cached --check
git commit --only -m "feat: establish evidence and decisions during grilling" -- skills/grilling/SKILL.md skills/domain-modeling/SKILL.md skills/domain-modeling/ADR-FORMAT.md provenance.tsv README.md docs/plans/0003-agentic-loop-verification.md
~~~

Expected: identical README hashes, `check-refs: clean`, only agreed paths committed, and unrelated index content preserved. Apply that commit check to every task.

### Task 2: Write plans from reviewed evidence and explicit readiness

**Status:** Ready
**Outcome and acceptance:** An ADR/glossary-based plan passes readiness without a separate spec, obtains an independent design review, and gives each Ready task usable criteria/context. An unavailable integration leaves dependent details Provisional, as exercised in Step 5.
**Decision context:** C2/C3/C8; ADR 0004/0005; Task 1 discovery contract. The extraction experiment proved header-only context is insufficient.

**Files:** Modify `skills/writing-plans/SKILL.md`, `provenance.tsv`, generated `README.md`; create `skills/writing-plans/design-reviewer-prompt.md`.

**Interfaces:**
- Consumes agreed outcomes, applicable glossary/ADRs, optional supplied spec, and source/experiment evidence.
- Produces outcome/verification criteria, design-review disposition, and Ready/Provisional tasks with sufficient local context.

- [x] **Step 1: Insert readiness and design gates before File Structure.**

Change the description ending `before touching code` to `before production implementation`. Insert:

~~~markdown
## Readiness Check

Read the agreed grilling outcomes, applicable glossary/ADRs, and any supplied
spec. Extract behavior, constraints, exclusions, and acceptance criteria;
distinguish requirements from design proposals.

Check evidence for existing capabilities, contracts, and state ownership.
Reuse applicable investigation. Resolve factual gaps yourself; raise decisions
changing behavior, ownership, or scope with your human partner. Withhold
detailed tasks dependent on unresolved consequential assumptions.

Bounded temporary integration experiments may resolve a named uncertainty.
Exercise the actual boundary through normal execution, meaningful failure,
and the next operation. Preserve findings and limits. Production implementation
begins in the execution Stage.

## Independent Design Review

Every Heavy Track plan requires a fresh reviewer before detailed tasks depend
on its architecture. Use design-reviewer-prompt.md with outcomes, constraints,
relevant original source/evidence paths, and the proposed design.

Resolve findings with evidence. Your human partner decides changes to agreed
behavior, ownership, or scope. Record dispositions and limits in the plan;
unresolved consequential assumptions leave dependent slices Provisional.

Author self-review still checks the completed plan. If decomposition overturns
a reviewed architectural choice or assumption, revisit the affected independent
review before readying dependent tasks. Routine detail corrections need no
additional reviewer.
~~~

In Overview, use agreed requirements and decision sources where the prose assumes a supplied spec. Replace Scope Check with: `If the agreed work covers independently deliverable subsystems, recommend separate numbered plans with their own outcomes and acceptance criteria. Use applicable decision sources; separate feature specs are optional.`

Replace “This is where decomposition decisions get locked in.” with `Specify evidence-supported choices for Ready Slices; keep dependent choices Provisional until their named evidence arrives.`

- [x] **Step 2: Create the supporting reviewer prompt with this complete content.**

~~~markdown
# Independent Design Reviewer

Review the proposed design before detailed decomposition.

Inputs: agreed outcomes, constraints, exclusions, acceptance criteria;
applicable glossary/ADRs and optional spec; source/evidence references;
proposed architecture and consequential assumptions.

Inspect relevant original sources. Determine whether the design is necessary
and sufficient:
- Does an existing component already own each proposed responsibility?
- What observable behavior does each new abstraction add?
- Does the proposal copy state or create competing sources of truth?
- Does each defensive check enforce an actual requirement?
- Which assumption would cause the largest rewrite if false?
- Would the evidence detect the failure that matters?

Stay within the proposed change and its consequences. Distinguish verified
facts, factual unknowns, and user decisions. Challenge an existing decision
with concrete evidence; do not override it. Name a further experiment if
needed. Do not implement production code or dispatch another reviewer.

Return:
1. Ready to decompose | Investigation needed | User decision needed.
2. Findings with sources, consequences, and recommended actions.
3. The riskiest remaining assumption and smallest realistic experiment,
   or the applicable evidence that already settles it.
4. What was verified and the limits of the review.
~~~

- [x] **Step 3: Update the plan and task contracts.**

Replace the header's `**Spec:**` field with:

~~~markdown
**Decision sources:** [applicable GLOSSARY.md/ADR paths, optional supplied spec,
and the source of agreed grilling outcomes]

## Outcome and verification
[Number observable outcomes, constraints, and exclusions. Each acceptance
criterion names its real boundary/check and the evidence needed to establish
it. Link detailed investigation.]

## Design review
[Reviewer disposition, findings/dispositions, evidence references, and limits.
Identify dependencies on unresolved findings.]
~~~

Preserve Global Constraints and Review Focus, replacing mandatory-spec references with `agreed outcomes and decision sources`. Keep the uncovered-failure review, using the number warranted by the work rather than inventing exactly five cases.

Before Task Structure, insert:

~~~markdown
## Ready and Provisional Slices

A slice demonstrates complete observable behavior across relevant boundaries.
A Ready Slice has concrete files, interfaces, tests/checks, expected results,
and applicable decision/evidence context. Its implementer can act without
inventing requirements or reading the whole plan.

A Provisional Slice records its outcome/acceptance, dependencies, and the
named finding required to settle its details. Specify the observation that
permits refinement; leave unsupported implementation choices open explicitly.
A Provisional Slice is never dispatched.

The execution controller may refine a slice when evidence arrives, preserving
agreed behavior, ownership, and scope. It updates the plan before extraction.
Consequential changes require your human partner's decision.
~~~

Add these literal fields before Files in the Ready task template:

~~~markdown
**Status:** Ready
**Outcome and acceptance:** [slice behavior, criterion IDs, concrete conditions/results]
**Decision context:** [applicable ADR/glossary references, relevant assumptions/evidence,
and decisions from earlier slices required by this task]
~~~

Add this Provisional example:

~~~markdown
### Task N: Recover after a dropped connection
**Status:** Provisional
**Outcome and acceptance:** The next operation succeeds after a transient
connection loss without duplicate retained state.
**Decision context:** The agreed recovery outcome and ownership ADR.
**Dependencies:** The client-lifecycle experiment.
**Needs evidence:** Which component reconnects and releases failed-operation
state. Refine after normal, failed, and subsequent operations are observed
through the actual client boundary.
~~~

Scope exact-step/signature requirements to Ready Slices. Preserve the existing Ready example.

- [x] **Step 4: Reconcile author self-review.**

Keep the author's own checklist. Apply these requirements to its existing entries:
- Coverage: every agreed outcome/constraint and applicable decision source is accounted for.
- Steps: Ready tasks are actionable; Provisional ones name dependencies and an evidence condition.
- Types: Ready interfaces agree; provisional interface dependencies remain blocked.
- Review Focus: actual boundaries and consequential failures have evidence or explicit limits.
- Proportion: retain the instruction to avoid transcribing the program.

Replace “No need to re-review — just fix and move on.” with `Fix routine details inline; revisit the affected independent review if a correction changes a reviewed design choice or invalidates its assumption.` Keep the manual Execution Handoff.

- [x] **Step 5: Verify and commit.**

Walk through:
1. Glossary, two accepted ADRs, outcomes, and dependency evidence exist without a spec: readiness may pass, independent review runs, and plan sources/criteria are explicit.
2. The actual client boundary is unavailable: record the limitation, make recovery Provisional with the required observation, and retain unaffected Ready work.

Read a sample task independently; its concrete criteria and decision/evidence references must be usable with supplied global constraints.

Append `readiness and independent design review; ADR/glossary sources; outcome verification; ready/provisional slices; design-reviewer prompt` to writing-plans' changes. Set its role to `Evidence-backed plans → docs/plans/`.

~~~bash
scripts/gen-readme-table.sh
table_sha=$(git hash-object README.md)
scripts/gen-readme-table.sh
test "$table_sha" = "$(git hash-object README.md)"
scripts/check-refs.sh
git diff --check
git add skills/writing-plans/SKILL.md skills/writing-plans/design-reviewer-prompt.md provenance.tsv README.md docs/plans/0003-agentic-loop-verification.md
git diff --cached --check
git commit --only -m "feat: validate designs before decomposing plans" -- skills/writing-plans/SKILL.md skills/writing-plans/design-reviewer-prompt.md provenance.tsv README.md docs/plans/0003-agentic-loop-verification.md
~~~

### Task 3: Share evidence validity across implementation and completion

**Status:** Ready
**Outcome and acceptance:** Unchanged relevant state permits inspectable evidence reuse; changed dependencies or uncovered integration behavior require covering checks or an explicit gap. All four Step 4 cases obey the same rule in worker reports and completion claims.
**Decision context:** C4/C7/C8; ADR 0005. Same-message completion rules conflict with reviewer evidence reuse.

**Files:** Modify `skills/verification-before-completion/SKILL.md`, `skills/subagent-driven-development/implementer-prompt.md`, `skills/implement/SKILL.md`, `provenance.tsv`, generated `README.md`.

**Interfaces:**
- Produces the Evidence Record and validity rules consumed by Tasks 4–5.
- Consumes acceptance criteria, required project gates, relevant current state, and inspectable output. Existing report statuses/paths remain.

- [x] **Step 1: Replace the verifier's Iron Law and Gate Function sections.**

~~~markdown
## The Iron Law

NO COMPLETION CLAIMS WITHOUT APPLICABLE VERIFICATION EVIDENCE

A previous run can support a claim when its evidence remains applicable.
A new message or reviewer does not by itself invalidate it.

## Evidence Record

For each claim retain:
- Claim and scope.
- Command, result, and exit status.
- Tested state: commit plus relevant uncommitted changes/content identifiers.
- Relevant dependency, configuration, and environment conditions.
- Inspectable output or a stable log reference.
- Limitations and the acceptance criterion supported.

Record relevant conditions, not an indiscriminate environment dump.
A reported success without supporting evidence is a claim to investigate.

## The Gate Function

Before claiming completion:
1. Identify the criterion, claim scope, and required project gates.
2. Inspect existing evidence against relevant current code, dependencies,
   configuration, and environment, including uncommitted changes.
3. Reuse applicable evidence. Run affected checks when inputs changed,
   evidence cannot be recovered, a concrete doubt remains, or a required
   project gate demands a new run.
4. Read output and exit status; verify they support the stated claim.
5. Report evidence and limits. Failed checks and uncovered criteria remain
   unresolved.

Run focused checks during development. Broaden verification for integration
risk, changed scope, failures, or required project gates. A focused check
supports only its covered claim.
~~~

- [x] **Step 2: Reconcile affected examples and metadata.**

Use these exact substitutions/meanings; leave unrelated prose intact:

| Passage | Replacement |
| --- | --- |
| Description “requires running verification commands and confirming output” | `requires inspecting applicable verification evidence and confirming output` |
| Tests-pass row rejects “Previous run” | `Previous run without applicable tested state and inspectable output` |
| “Partial proves nothing” | `A focused check proves only its covered claim` |
| “ANY wording implying success without having run verification” | `ANY wording implying success without applicable verification evidence` |
| Excuses whose response unconditionally says “RUN the verification” | `Inspect applicable evidence or run the checks needed to support the claim` |
| Tests/build examples requiring a newly run command | `[Inspect applicable run/output OR run the needed command]` with the existing pass/failure expectations |
| Requirements and delegation examples | Inspect the current criteria/diff and actual supporting evidence; a subagent status alone stays insufficient. |

Remove any remaining same-message/fresh-run prohibition inconsistent with this policy. Preserve evidence-before-claims and the requirement to independently inspect reports.

- [x] **Step 3: Change implementation reports and completion instructions.**

Replace implementer-prompt's “run the full suite once before committing” paragraph with:

~~~text
Use verification-before-completion for evidence validity and reporting.
Run focused checks for the slice and all required project gates. Reuse
applicable evidence; broaden checking for concrete integration risk,
changed scope, or failure. Before committing, verify completion claims
against the relevant current state.
~~~

Replace its `What you tested and test results` report bullet with:

~~~text
Acceptance evidence using verification-before-completion's Evidence Record:
command, exit status, tested state including relevant dirty changes,
relevant conditions, output/log reference, acceptance criterion, and limits.
~~~

Keep RED/GREEN records for required TDD. In After Review Findings, replace unconditional rerun wording with `Re-evaluate evidence for amended code, run affected checks, and append the changed state, commands/results, output, and limits.`

In `implement` replace the regular-typecheck/full-suite sentence and the separate completion-verification sentence with one instruction at its completion gate:

~~~text
Use focused tests and typechecking appropriate to the change and satisfy
required project gates. Apply verification-before-completion for evidence
validity, reruns, and reporting before committing or claiming completion.
~~~

Keep its TDD, review, current-branch commit, and command identity.

- [x] **Step 4: Verify evidence dispositions.**

Read edited files and record the next action, claim limits, and supporting passages:

| Input | Required disposition |
| --- | --- |
| C1 is covered at commit X; relevant inputs/criterion are unchanged; output is inspectable. | Reuse across implementation, review, and completion. |
| The relevant lockfile dependency changed without a commit. | Invalidate the affected integration claim; run covering checks and required gates. |
| A helper test passes; acceptance concerns failure recovery through the actual client. | Obtain boundary evidence or report the uncovered criterion. |
| A report path disappeared but original output is recoverable at a stable reference. | Recover/inspect it before deciding a rerun is necessary. |

Do not add tests that merely search for the new prose.

- [x] **Step 5: Record divergence and commit.**

Replace verifier's `verbatim` changes with `applicable evidence reuse; risk-based check scope; inspectable evidence records`.
Append `evidence records and proportionate checks in implementer prompt` to SDD and `applicable evidence and proportionate checks` to implement.

~~~bash
scripts/gen-readme-table.sh
table_sha=$(git hash-object README.md)
scripts/gen-readme-table.sh
test "$table_sha" = "$(git hash-object README.md)"
scripts/check-refs.sh
git diff --check
git add skills/verification-before-completion/SKILL.md skills/subagent-driven-development/implementer-prompt.md skills/implement/SKILL.md provenance.tsv README.md docs/plans/0003-agentic-loop-verification.md
git diff --cached --check
git commit --only -m "feat: reuse applicable verification evidence" -- skills/verification-before-completion/SKILL.md skills/subagent-driven-development/implementer-prompt.md skills/implement/SKILL.md provenance.tsv README.md docs/plans/0003-agentic-loop-verification.md
~~~

### Task 4: Review the actual change and classify feedback

**Status:** Ready
**Outcome and acceptance:** Reviews inspect tracked and untracked work, produce all four conclusions without requiring a spec file, and route consequential feedback before dependent work resumes. Step 5 demonstrates artifact completeness and independent-work handling.
**Decision context:** C4/C5/C7/C8; ADR 0004/0005; Task 3 Evidence Record. The Git experiment proved committed-only review omits the light-track work before commit.

**Files:** Modify `skills/code-review/SKILL.md`, `skills/receiving-code-review/SKILL.md`, `skills/subagent-driven-development/task-reviewer-prompt.md`, `skills/subagent-driven-development/re-review-prompt.md`, `skills/implement/SKILL.md`, `provenance.tsv`, generated `README.md`.

**Interfaces:**
- Consumes actual change artifact, applicable outcomes/acceptance, decisions, constraints, baseline/current references, and evidence.
- Produces four conclusions: `Implementation correctness`, `Design validity`, `Evidence quality`, `Scope and standards`. Each is `Verified`, `Findings`, or `Evidence gap` with references/limits.
- Retain one task reviewer and two final reviewer roles. Standards owns design validity plus scope/standards; Spec owns correctness plus evidence quality. Both receive the agreement and evidence.

- [x] **Step 1: Add an explicit working-tree artifact mode to code-review.**

Retain committed mode's fixed point, three-dot diff, and commit list. Add:

~~~markdown
For explicitly requested working-tree review, use
`git diff <fixed-point> -- <task-paths>` for tracked committed, staged, and
unstaged changes. Enumerate untracked task files with
`git ls-files --others --exclude-standard -- <task-paths>` and inspect their
contents. The tracked diff alone omits these files.

Record the resolved fixed point, mode, task paths, and reviewed state. Give
both reviewers the same artifact. Working-tree review is non-empty when
either tracked diff or relevant untracked files exist. If the state changes
during review, invalidate the affected conclusions before reporting them.
~~~

Resolve placeholders as caller inputs, passing paths as separate quoted arguments. Keep unrelated user changes identified and outside the implementation's claimed scope.

In `implement` insert before production edits:

~~~text
Record the starting Git revision and existing working-tree changes. Preserve
unrelated work. For code-review supply this fixed revision, working-tree mode,
relevant task paths including untracked files, and the agreed outcomes and
decision sources.
~~~

Replace “Once done, use /code-review to review the work.” with:

~~~text
Use /code-review on that working-tree change before committing. Resolve
findings and verify that the reviewed state still matches the change committed.
~~~

- [x] **Step 2: Expand agreement lookup and the two reviewer briefs.**

Rename Identify the spec source to Identify the agreement sources. Lookup order:
1. Explicit caller/user outcomes and paths.
2. Named plan's outcome/verification, constraints, current refinements, and decision-source references.
3. Applicable glossary/ADRs and any supplied spec or matching local document found through existing lookup.
4. If the agreement cannot be recovered, ask for missing outcome/acceptance information and report that gap.

Absence of a separate spec does not skip Spec review. Give both reviewers the artifact, agreement/constraints, baseline/current references when available, and evidence. Preserve Standards' smell baseline and repo overrides. Replace the reviewer briefs with:

~~~text
Standards reviewer:
Conclude separately on Design validity and Scope and standards. Check design
necessity/sufficiency, actual responsibility ownership, competing state,
unsupported abstractions, and requirements behind defensive checks. Follow
concrete consequences into validation, errors, cleanup, configuration, and
documentation. Cite sources. Preserve the distinction between hard standards
and smell heuristics. A proposed change to an agreed decision is a finding
for the controller/user, not permission to override it.

Spec reviewer:
Conclude separately on Implementation correctness and Evidence quality.
Check agreed outcomes, missing/extra/misunderstood behavior, and whether
evidence detects meaningful failure at the actual boundary. Use
verification-before-completion to assess tested state, output, and limits.
Passing helper tests do not prove an unobserved integration.
~~~

Retain separate Standards and Spec reports with their two allocated conclusions, each explicitly `Verified`, `Findings`, or `Evidence gap` with references/limits; do not merge/rerank across axes. Update description, overview, and Why two axes only to reflect four concerns across the same reviewers. Remove “skip Spec without spec”.

- [x] **Step 3: Give task and scoped re-review the same conclusion contract.**

In `task-reviewer-prompt.md`:
- Supply Outcome and acceptance, Decision context, global constraints, baseline/current references, and Evidence Records.
- Keep bounded diff review and focused inspection of unchanged code for a named consequential risk.
- Make Tests use `verification-before-completion`. Focused checks answer concrete doubts; broader validation is routed to the controller with the named risk.
- Add the Design validity and Evidence quality questions from Step 2, scoped to this slice.
- Replace the two-verdict output contract and descriptions with:

~~~markdown
### Implementation correctness
Verified | Findings | Evidence gap — sources and observed behavior.

### Design validity
Verified | Findings | Evidence gap — responsibility and assumption evidence.

### Evidence quality
Verified | Findings | Evidence gap — criteria, tested state, output, limits.

### Scope and standards
Verified | Findings | Evidence gap — constraints, conventions, consequences.

### Issues
Critical / Important / Minor, each with file:line or evidence reference,
consequence, and recommended disposition. Identify questions needing
controller context or a user decision.
~~~

Preserve severity calibration and no reviewer-spawned subagents. A relevant criterion outside available evidence becomes an explicit controller follow-up.

In `re-review-prompt.md` retain scoped per-finding verdicts. Supply prior four conclusions and report each as `unchanged and still applicable`, `reassessed`, or `unresolved`; use evidence for changed conclusions. Apply the shared validity rule. An out-of-scope consequential/blocking discovery is routed to the controller's dependency gate; remove blanket statements that every out-of-scope observation is non-blocking/minor.

- [x] **Step 4: Classify feedback before implementation.**

Insert after receiving-code-review's Response Pattern and apply it from its IMPLEMENT step:

~~~markdown
## Classify and route feedback

Classify each finding:
- Implementation defect: correct code/tests against agreed behavior.
- Mistaken assumption: investigate before revisiting affected design choices.
- Changed requirement: follow your human partner's direction and update
  outcomes and dependent work.
- New dependency capability: verify it and its ownership implications.
- Newly expressed preference: record consequences and apply the user's direction.

Resolve routine facts and reversible details yourself. Present evidence,
tradeoffs, and a recommendation for a behavior, ownership, or scope change;
your human partner owns that decision. Already explicit user direction
does not need another approval of the same decision.

Before dependent work resumes, update affected plan tasks/tests and durable
decisions. Use superseding ADRs for substantive changes; change glossary
entries only when terminology changes. Retire contradictory instructions.

Unclear feedback blocks affected items and their dependants. Independent
work with settled decisions and evidence may continue.
~~~

Reconcile Handling Unclear Feedback, its examples, Implementation Order, and the “Partial implementation” row with dependency-scoped blocking. Replace the “can't easily verify” request to choose investigate/ask/proceed with factual investigation first, followed by evidence limits and any genuine user decision. Preserve unrelated upstream phrasing and technical skepticism.

- [x] **Step 5: Verify artifacts and decisions, then commit.**

In a disposable Git repository, change tracked.txt and create untracked new.txt before committing. Confirm the old `BASE...HEAD` diff is empty, `git diff BASE -- tracked.txt` contains the edit, and untracked enumeration includes new.txt. Review both contents through working-tree mode and record four conclusions.

Walk through ADR/plan acceptance without a spec: both reviewer roles still run. For an ownership change plus an independent typo in one feedback batch, the typo can proceed while ownership waits for the user and dependent instructions are updated.

Append these provenance entries:
- code-review: `four concerns across existing reviewers; ADR/plan agreement sources; working-tree and untracked review`
- receiving-code-review: `feedback classification; dependency-scoped decisions; durable updates`
- subagent-driven-development: `four-concern task and scoped re-review prompts`
- implement: `working-tree review from recorded base`

Set code-review's role to `Two reviewers covering correctness, design, evidence, and standards`.

~~~bash
scripts/gen-readme-table.sh
table_sha=$(git hash-object README.md)
scripts/gen-readme-table.sh
test "$table_sha" = "$(git hash-object README.md)"
scripts/check-refs.sh
git diff --check
git add skills/code-review/SKILL.md skills/receiving-code-review/SKILL.md skills/subagent-driven-development/task-reviewer-prompt.md skills/subagent-driven-development/re-review-prompt.md skills/implement/SKILL.md provenance.tsv README.md docs/plans/0003-agentic-loop-verification.md
git diff --cached --check
git commit --only -m "feat: review design validity and evidence with the actual change" -- skills/code-review/SKILL.md skills/receiving-code-review/SKILL.md skills/subagent-driven-development/task-reviewer-prompt.md skills/subagent-driven-development/re-review-prompt.md skills/implement/SKILL.md provenance.tsv README.md docs/plans/0003-agentic-loop-verification.md
~~~

### Task 5: Enforce readiness and preserve decisions through execution

**Status:** Ready
**Outcome and acceptance:** Only semantically Ready work is dispatched; explicit invalid readiness cannot leave a stale brief. Seven extractor tests and six lifecycle scenarios verify committed baselines, decision boundaries, fixed review ranges, durable evidence, and blocked completion for unmet acceptance.
**Decision context:** C3/C4/C5/C6/C7/C8; ADR 0004/0005; Task 2 schema and Tasks 3–4 evidence/review contracts. The independent review identified cap/finalization paths that must change together.

**Files:**
- Modify `skills/subagent-driven-development/SKILL.md` and `skills/subagent-driven-development/implementer-prompt.md`.
- Modify `skills/subagent-driven-development/scripts/task-brief`.
- Create `scripts/tests/test_task_brief.py`.
- Modify `skills/how/SKILL.md`, README prose outside the generated table, and `provenance.tsv`; regenerate the table.

**Interfaces:**
- task-brief stays `PLAN_FILE TASK_NUMBER [OUTFILE]`: 0 success, 2 argument/input misuse, 3 missing task, 4 explicit non-ready/invalid metadata.
- Legacy tasks without Status remain extractable only with controller semantic assessment.
- Agreement baseline identifies committed starting documents; Execution base is the fixed revision used for whole-branch review.
- Existing implementer status values remain; Task 4 supplies four review conclusions.

- [x] **Step 1: Create the regression tests and observe failure on the current extractor.**

Create `scripts/tests/test_task_brief.py` with this content:

~~~python
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

DEFAULT_SCRIPT = Path(__file__).resolve().parents[2] / "skills/subagent-driven-development/scripts/task-brief"
SCRIPT = Path(os.environ.get("TASK_BRIEF_SCRIPT", str(DEFAULT_SCRIPT))).resolve()


class TaskBriefTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="task-brief-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.plan = self.root / "plan.md"
        self.out = self.root / "brief.md"

    def extract(self, text, number=1):
        self.plan.write_text(text)
        return subprocess.run(
            ["/bin/bash", str(SCRIPT), str(self.plan), str(number), str(self.out)],
            text=True, capture_output=True,
        )

    def test_ready_preserves_task_context_without_other_tasks(self):
        result = self.extract(
            "# Plan\n## Outcome and verification\nGLOBAL_ONLY\n"
            "### Task 1: Save and reload\n**Status:** Ready\n"
            "**Decision context:** ADR-4; criterion C1; evidence E1\n"
            "- [ ] Save, restart, reload.\n"
            "### Task 2: Later\n**Status:** Provisional\nOTHER_TASK\n"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        body = self.out.read_text()
        self.assertIn("ADR-4; criterion C1; evidence E1", body)
        self.assertIn("Save, restart, reload.", body)
        self.assertNotIn("GLOBAL_ONLY", body)
        self.assertNotIn("OTHER_TASK", body)

    def test_provisional_invalidates_old_ready_brief_then_recovers(self):
        ready = "### Task 1: Save\n**Status:** Ready\nCURRENT\n"
        self.assertEqual(self.extract(ready).returncode, 0)
        result = self.extract("### Task 1: Save\n**Status:** Provisional\n")
        self.assertEqual(result.returncode, 4, result.stderr)
        self.assertFalse(self.out.exists())
        self.assertEqual(self.extract(ready).returncode, 0)
        self.assertIn("CURRENT", self.out.read_text())
        self.assertEqual(list(self.root.glob("brief.md.tmp.*")), [])

    def test_invalid_and_duplicate_status_are_rejected(self):
        cases = [
            "**Status:** Maybe",
            "**Status**: Ready",
            "**Status:** ready",
            "**Status:** Ready\n**Status:** Ready",
        ]
        for status in cases:
            with self.subTest(status=status):
                self.out.write_text("STALE")
                result = self.extract("### Task 1: Save\n" + status + "\n")
                self.assertEqual(result.returncode, 4, result.stderr)
                self.assertFalse(self.out.exists())

    def test_fenced_status_and_headings_are_literal(self):
        tick = chr(96)
        text = (
            "### Task 1: Edit a template\n**Status:** Ready\n"
            + tick * 4 + "markdown\n"
            "**Status:** Provisional\n"
            + tick * 3 + "python\n"
            "### Task 99: Quoted heading\n"
            + tick * 3 + "\n" + tick * 4 + "\n"
            "~~~text\n**Status:** invalid\n### Task 99: Also quoted\n~~~\n"
            "END_OF_TASK\n### Task 2: Other\nOTHER_TASK\n"
        )
        result = self.extract(text)
        self.assertEqual(result.returncode, 0, result.stderr)
        body = self.out.read_text()
        self.assertIn("END_OF_TASK", body)
        self.assertIn("Quoted heading", body)
        self.assertNotIn("OTHER_TASK", body)

    def test_legacy_without_status_is_extractable(self):
        result = self.extract("### Task 1: Legacy\n- [ ] Existing step.\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Existing step.", self.out.read_text())

    def test_missing_task_invalidates_previous_output(self):
        self.out.write_text("STALE")
        result = self.extract("### Task 1: Existing\n", number=2)
        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertFalse(self.out.exists())

    def test_output_cannot_replace_plan(self):
        content = "### Task 1: Existing\n**Status:** Ready\n"
        self.plan.write_text(content)
        result = subprocess.run(
            ["/bin/bash", str(SCRIPT), str(self.plan), "1", str(self.plan)],
            text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertEqual(self.plan.read_text(), content)


if __name__ == "__main__":
    unittest.main()
~~~

~~~bash
python3 scripts/tests/test_task_brief.py -v
~~~

Expected current failures: readiness rejection, invalid/duplicate metadata, nested fences, stale output, and output aliasing. Simple Ready and legacy extraction already work. These tests exercise the actual script through /bin/bash using only disposable directories.

- [x] **Step 2: Implement the tested guard while preserving the wrapper.**

Keep the current header, argument-count check, plan/output selection, and `sdd-workspace` invocation. After the plan-existence check insert:

~~~bash
case "$n" in
  ''|*[!0-9]*) echo "invalid task number: $n" >&2; exit 2 ;;
esac
~~~

Replace the current awk extraction, empty-output check, and final echo with:

~~~bash
if [ "$plan" -ef "$out" ]; then
  echo "brief output must differ from the plan" >&2
  exit 2
fi

tmp=$(mktemp "${out}.tmp.XXXXXX")
trap 'rm -f "$tmp"' EXIT

if awk -v n="$n" '
  {
    line = $0
    sub(/^[ \t]*/, "", line)
    mark = substr(line, 1, 1)
    len = 0
    if (mark == "\140" || mark == "~") {
      while (substr(line, len + 1, 1) == mark) len++
    }
    if (fence_len) {
      if (intask) print
      if (mark == fence_mark && len >= fence_len &&
          substr(line, len + 1) ~ /^[ \t]*$/) fence_len = 0
      next
    }
    if (len >= 3) {
      fence_mark = mark
      fence_len = len
      if (intask) print
      next
    }
    if ($0 ~ /^#+[ \t]+Task[ \t]+[0-9]+/) {
      intask = ($0 ~ ("^#+[ \t]+Task[ \t]+" n "([^0-9]|$)"))
      if (intask) found++
    }
    if (intask) {
      print
      if ($0 ~ /^[ \t]*\*\*Status/) {
        statuses++
        if ($0 !~ /^\*\*Status:\*\*[ \t]+Ready[ \t]*$/) invalid = 1
      }
    }
  }
  END {
    if (!found) {
      print "task " n " not found" > "/dev/stderr"
      exit 3
    }
    if (found != 1 || statuses > 1 || invalid) {
      print "task " n " has provisional or invalid readiness metadata" > "/dev/stderr"
      exit 4
    }
    # Legacy tasks without Status remain supported; the controller assesses readiness.
  }
' "$plan" > "$tmp"; then
  mv "$tmp" "$out"
else
  rc=$?
  rm -f "$out"
  exit "$rc"
fi
echo "wrote ${out}: $(wc -l < "$out" | tr -d ' ') lines"
~~~

Validation uses temporary output; rejection invalidates the previously generated brief. Fenced content does not determine readiness. A Ready label does not replace semantic review.

~~~bash
/bin/bash -n skills/subagent-driven-development/scripts/task-brief
python3 scripts/tests/test_task_brief.py -v
~~~

Expected: syntax succeeds; all seven tests pass.

- [x] **Step 3: Replace SDD's top-level autonomous-ruling policy.**

Replace the block from Continuous execution through the four-stop-conditions paragraph, before When to Use:

~~~markdown
**Continuous execution:** Continue Ready work within agreed outcomes, ownership,
and scope. Resolve routine facts and reversible details yourself.

**Decisions and feedback:** Apply receiving-code-review to classify findings.
Record routine refinements and evidence in the plan before dispatch. Your
human partner decides changes to behavior, ownership, or scope. Investigate
first, then present the tradeoff and recommendation. Already explicit user
direction is sufficient authorization.

A consequential unknown or decision blocks affected work and its dependants;
unaffected Ready work may continue. Preserve existing approval boundaries for
destructive, irreversible, security-sensitive, or externally publishing actions.
A plan with no evidenced path forward waits for clarification.
A retry cap ends repeated dispatch; it does not satisfy an unmet requirement.
~~~

Change the Properties claim about no human involvement to `Continuous execution within agreed decisions`.

- [x] **Step 4: Add baseline/readiness gates to Setup and dispatch.**

Replace the spec-authority paragraph in Setup with:

~~~markdown
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
~~~

Keep the preflight conflict table, recording provisional interfaces as unresolved dependencies. Resolve routine inconsistencies in the plan; consequential ones follow the user-decision rule.

Require task-brief exit 0 and semantic readiness before dispatch. Never reuse a cached output after failed extraction. Give implementer and reviewer the same task-local context, relevant constraints, baseline/current source references, and evidence. Keep the existing task-only extraction and diff package; no additional mutable contract document is needed.

Expand implementer Context/Before You Begin with:

~~~text
Read Outcome and acceptance and Decision context in the brief, plus supplied
Global Constraints. Inspect relevant source/evidence references. Report
NEEDS_CONTEXT if the task is Provisional, a consequential decision is missing,
or required assumptions lack supporting evidence. Do not silently substitute
a different outcome, state owner, or scope.
~~~

Add current task/decision revision and invalidated evidence to its report fields. Preserve no worker-spawned agents.

- [x] **Step 5: Reconcile every review, cap, and completion path.**

Update the Overview, Core principle, and Properties descriptions of task review to name the four concerns, matching the prompt and completion contract below.

Use these exact dispositions in the indicated SDD sections:

| Section | Final behavior |
| --- | --- |
| Handle report, BLOCKED item 4 | Classify/investigate the plan defect; update routine details or obtain the consequential user decision before redispatch. |
| Review the task | Require all four conclusions and applicable agreement/evidence inputs. Resolve an evidence gap before claiming its criterion verified. |
| Fix loop, plan-mandated route | A recorded ruling cannot override agreed outcomes/ADRs. Apply feedback classification and user decision boundaries. |
| Every fix round | Apply shared evidence validity and run affected checks; report covering evidence. |
| Scoped re-review | Reassess affected conclusions; route out-of-scope blocking/consequential discoveries to the controller without indefinitely expanding fix review. |
| Breaker | Preserve five rounds. Reject unsupported findings with evidence; defer only items that do not invalidate accepted outcomes. Real blocking findings stay unresolved; affected dependants cannot proceed. |
| Complete task | Complete requires supported acceptance and four conclusions, with no real blocking finding. Record deferred non-blocking items and limits explicitly. |
| Final Review | Use fixed Execution base with current HEAD. Both final reviewers receive agreement/evidence and deferred findings. Keep one final fix dispatch and one scoped re-review; residual blocking findings mean incomplete work. |
| Finish | Preserve durable records, assess completion evidence, then clean eligible scratch. Branch Ready requires supported accepted outcomes and required gates, with no blocking gap. |

Before scratch cleanup, maintain this section in the plan:

~~~markdown
## Execution record
- Agreement baseline: [revision and document paths]
- Execution base: [fixed revision]
- Task refinements: [task, decision/source revision, finding, disposition, reason]
- Acceptance evidence: [criterion, command, exit status, tested state including
  relevant dirty changes, relevant conditions, output/stable reference, limits]
- Review conclusions: [four concerns, evidence, unresolved/deferred findings]
~~~

Preserve relevant output or sufficient inspectable summaries; links to soon-deleted scratch are insufficient. Preserve additional logs only where the claim needs them. Commit agreed plan/evidence updates during task/fix bookkeeping before deleting their only scratch source. Substantive decisions follow ADR supersession.

Update process diagram nodes/edges, Example Workflow, and Common Rationalizations consistently:
- Baseline/readiness precede dispatch, including transitions to later tasks.
- Approval requires all four conclusions.
- Blocking findings route to unresolved/decision handling rather than completion.
- Final review uses Execution base and preserves evidence before verification/cleanup.
- Remove conflicting “only four reasons”, “rule and continue”, “every path forward is a guess”, and parked-with-ruling completion exemptions in these paths.
- Preserve batching, model selection, fix-agent reuse, caps, and unrelated upstream guidance.

- [x] **Step 6: Verify composed lifecycle scenarios.**

Use edited repository instructions directly and record each decision/action with its source:

| Scenario | Required result |
| --- | --- |
| Approved plan is uncommitted; an unrelated file is already staged. | Commit only agreed documents while preserving unrelated index content; record baseline and Execution base before implementation. |
| Evidence settles only a Provisional task's return type. | Refine within agreement, update plan, make Ready, then extract/dispatch. |
| Evidence requires a new state owner. | User decides; affected work waits; unrelated Ready work may continue. |
| Fifth fix round leaves an acceptance failure. | No blind retry or completion claim; preserve/classify/report unresolved work. |
| Resume after scratch cleanup. | Committed documents and durable evidence recover decisions/refinements/results without reconstructing chat. |
| Commits were made directly on the starting main/master branch. | Fixed Execution base yields the implementation range; recomputed branch-tip merge base is not used. |

Inspect a Ready brief from a synthetic plan with header-level decision/evidence references: its task must carry applicable references and concrete criteria, and the controller must supply binding constraints to both worker and reviewer.

- [x] **Step 7: Update the workflow map and finish the task.**

In how's Heavy Track map, describe planning as `readiness and independent design review; observable Ready/Provisional slices in docs/plans/` and execution as `committed baseline; refine/execute Ready slices; four-concern reviews; applicable verification evidence; then STOP`. Preserve commands and the Light Track route.

Update README prose outside the table with those handoffs and glossary/ADR/plan roles, retaining optional specs and the existing GitHub installation command.

Append to SDD changes: `committed agreement baseline; fixed execution review base; readiness-gated task extraction; per-task decision/evidence context; bounded consequential decisions; durable evidence and blocking completion gates`.
Set how's changes to `workflow descriptions for readiness, evidence, and four-concern review`. Preserve all earlier task provenance additions.

~~~bash
/bin/bash -n skills/subagent-driven-development/scripts/task-brief
python3 scripts/tests/test_task_brief.py -v
scripts/gen-readme-table.sh
table_sha=$(git hash-object README.md)
scripts/gen-readme-table.sh
test "$table_sha" = "$(git hash-object README.md)"
scripts/check-refs.sh
git diff --check
git add skills/subagent-driven-development/SKILL.md skills/subagent-driven-development/implementer-prompt.md skills/subagent-driven-development/scripts/task-brief scripts/tests/test_task_brief.py skills/how/SKILL.md provenance.tsv README.md docs/plans/0003-agentic-loop-verification.md
git diff --cached --check
git commit --only -m "feat: gate execution on evidence and preserve agreed decisions" -- skills/subagent-driven-development/SKILL.md skills/subagent-driven-development/implementer-prompt.md skills/subagent-driven-development/scripts/task-brief scripts/tests/test_task_brief.py skills/how/SKILL.md provenance.tsv README.md docs/plans/0003-agentic-loop-verification.md
~~~

## Final verification and handoff

Review the complete change using the required SDD workflow. Reuse applicable task evidence and run these structural checks on the final state:

~~~bash
/bin/bash -n skills/subagent-driven-development/scripts/task-brief
python3 scripts/tests/test_task_brief.py -v
scripts/check-refs.sh
git diff --check
python3 - <<'PY'
from pathlib import Path
import csv
import subprocess

rows = list(csv.reader(Path("provenance.tsv").open(), delimiter="\t"))
assert all(len(row) == 7 for row in rows)
assert {r[0] for r in rows[1:] if r[3] != "dropped"} == {
    p.name for p in Path("skills").iterdir() if p.is_dir()
}
for name, sub, source, status, invocation, role, changes in rows[1:]:
    if status != "imported":
        continue
    upstream = Path(sub) / source
    assert (upstream / "SKILL.md").is_file(), name
    pin = subprocess.check_output(["git", "rev-parse", "HEAD:" + sub], text=True).strip()
    checked = subprocess.check_output(["git", "-C", sub, "rev-parse", "HEAD"], text=True).strip()
    assert pin == checked, sub
    if changes == "verbatim":
        subprocess.run(["diff", "-r", str(upstream), "skills/" + name], check=True)
print("Provenance, pins, membership, and verbatim imports: valid")
PY
git status --short
~~~

Compare every modified import with its pinned source and `b5f8c61` separately. Every new difference must be a documented task rewiring. Confirm unchanged `review-package`/`sdd-workspace` interfaces, pins, discovery symlinks, and invocation flags.

Record final four-concern review and verification evidence in the Execution record. Stop with actual status and remaining changes; the user owns merge, sanity testing, cleanup, and later consuming-project refresh.

## Author self-review

- C1–C8 cover all seven research points, document ownership, and baseline preservation.
- Heavy-only gates stay in planning/SDD; shared review and verification serve both Tracks without a new command or mandatory spec.
- Task context survives extraction; status spellings, exit codes, four-conclusion names, and evidence fields agree across consumers.
- Actual extractor/Git experiments support the boundary choices. Instruction walkthroughs remain implementation acceptance checks.
- Existing reviewers/helper interfaces are retained; no second mutable contract or new distributed skill is introduced.
- Local document links, all embedded Bash/Python syntax, and all five briefs extracted by both the existing extractor and the proposed guard were checked successfully. Reconstructing the prototype directly from this plan's code blocks passed all seven tests. The reference sweep reported `check-refs: clean`; temporary fixtures were removed.
- Execution followed the user's separate invocation; completion evidence is recorded below.

## Execution record

- Branch: `codex/agentic-loop-verification` in the existing checkout.
- Starting state: `b5f8c61`; only this approved plan was untracked; no unrelated staged changes.
- Agreement baseline: `3363070f1179622ec32c64b30d3176d26ec493da`; includes this plan and the glossary/ADRs inherited from `b5f8c61`.
- Execution base: `3363070f1179622ec32c64b30d3176d26ec493da`, fixed before Task 1 and retained for final review.
- Preflight: five task consistency checks and all ten shared-file/interface pairs recorded in the plan workspace; no unresolved consequential choices.
- Refinements: normalized the accidental leading `q` in this plan heading; the confirmed ADRs govern consequential decisions and blocking completion.

- Task 1: implemented exact foundation and ADR-supersession additions. Reconnect scenario: investigate existing cleanup ownership, distinguish observable reconnect behavior from a manager proposal, retain consequential unknowns and withhold dependent detail. Ownership A→B scenario: evidence and recommendation require the user decision; a new numbered ADR supersedes the old decision with status linkage, preserving its body; glossary edits cannot authorize ownership. These are text-based scenario checks, not live integration evidence. Bare `grill-me` remains a direct grilling wrapper without mandatory heavy gates. README generation was idempotent (`144e1524e2ecfd7c0bd9131583c6fb5e0b504a03`); refs clean; diff check passed; seven-column membership/source-path validation passed; 11 verbatim imports matched pinned directories; removing exact additions reproduced baseline files. No shell scripts changed.

- Task 1 independent review (`3363070..1ab183c`): Implementation correctness, Design validity, Evidence quality, and Scope and standards all Verified; no findings. Inspected exact additions/provenance and the ownership/supersession walkthroughs. Limit: documentation walkthroughs do not prove live agent compliance.

- Task 2: readiness/design-review/task contracts implemented against Task 1 state `1ab183c` and agreement/execution baseline `3363070f1179622ec32c64b30d3176d26ec493da`. No-spec scenario: glossary, two accepted ADRs, agreed outcomes, and dependency evidence supply requirements and ownership; readiness can pass, a fresh design reviewer inspects original sources before dependent decomposition, and Decision sources plus numbered outcome criteria record the foundation. Unavailable-client scenario: preserve the boundary limitation, leave reconnect ownership/state-release detail open in a Provisional recovery task, require observed normal/failed/subsequent actual-client operations before refinement, and retain independent Ready work. Standalone task check: Task 2 brief plus supplied global constraints provides exact files/copy, C2/C3/C8, ADR 0004/0005, Task 1 dependency, scenario checks, expected outputs, and commit paths without the whole plan. These are documentation walkthroughs and do not establish live integration or agent compliance. Exact prompt/insertions matched; existing Ready example/manual handoff preserved; seven-column active membership/source paths passed; 11 verbatim imports matched pinned sources. README generation twice produced `8d62b1090c13cf52729285afd5c5992253e129e9`; refs reported `check-refs: clean`; diff checks passed. No shell scripts changed. Preserved Task 1 independent-review record in this commit.

- Task 2 independent review (`1ab183c..4a6d4b1`): all four conclusions Verified; no findings. Reviewed readiness/design gates, exact reviewer prompt, task-local Ready/Provisional contracts, optional specs, and preserved author self-review/manual handoff. Limits remain instruction-level walkthroughs, not future harness or live integration behavior.


- Task 3: shared evidence validity implemented against Task 2 `4a6d4b1` and agreement/execution baseline `3363070f1179622ec32c64b30d3176d26ec493da`; preserved Task 2 independent-review record. Four dispositions inspected in verifier Gate Function/Evidence Record and implementer/implement completion instructions: unchanged C1/state with inspectable output reuses across implementation, review, and completion (Iron Law/Gate 2–3), limited to that criterion; dirty relevant lockfile invalidates affected integration evidence and requires covering checks plus required gates (tested dirty state, dependency conditions, Gate 2–3); helper success cannot establish actual-client recovery, requiring boundary evidence or an unresolved criterion (focused-check scope/Gate 5); a vanished report with stable original output calls for recovery/inspection before rerun (stable reference/Gate 3–4). These are instruction walkthroughs, not runtime or harness-compliance tests. Self-review of baseline and pinned-source diffs confirmed only requested rewiring, metadata/examples, completion/report instructions; TDD RED/GREEN, review, invocation flags, and current-branch commit preserved. Seven-column provenance/membership/source paths and pinned SHAs valid; 10 remaining verbatim imports identical. README generated twice with identical hash `c7fd93b2a4d1f5a1011e765239c6ccf46b587d83`; refs output `check-refs: clean`; diff check exit 0. No shell scripts changed; updater-engine tests do not apply.

- Task 3 independent review (`4a6d4b1..1d2c364`): all four conclusions Verified; no findings. Shared claim/state/output validity reaches both implementation tracks; required gates and RED/GREEN reporting remain. Four evidence dispositions support the instruction claim, with live agent/runtime behavior outside the evidence scope.


- Task 4: actual tracked/untracked review and four-concern conclusions implemented against `1d2c364`, agreement/execution base `3363070`; preserved Task 3 independent-review record. Disposable `/private/tmp` Git fixture: committed-only BASE...HEAD empty, fixed-base tracked diff contains `+edited`, untracked enumeration contains `new.txt`, both actual contents inspected; cleanup confirmed. Four fixture conclusions Verified for correctness (both edits captured), design (existing Git primitives suffice), evidence (observed exit-0 diff/enumeration/contents), scope/standards (explicit two paths, temporary external fixture); limit: artifact collection only, no runtime agent compliance. No-spec walkthrough: ADR 0004/0005 and plan acceptance supply agreement to both Standards and Spec; missing recoverable acceptance is an Evidence gap, never a skipped reviewer. Mixed feedback walkthrough: investigate ownership A→B and present evidence/recommendation for user decision; block ownership-dependent work, permit independent typo, update affected tasks/tests and superseding ADR before resuming, without glossary change unless terms change. Names/flags, no reviewer subagents, smell baseline, calibration, TDD and Task 3 evidence gate preserved. Seven-column membership/source paths valid; 10 verbatim imports match pinned sources; narrowly rewired diffs inspected. README generation twice identical (`c219d44c5d2c486439594820d8c480702727ba3b`), refs `check-refs: clean`, diff check exit 0. No shell scripts changed; updater-engine checks inapplicable. Detailed evidence/output and limitations: task-4 report in the plan workspace.

- Task 4 independent review (`1d2c364..07fae81`): all four conclusions Verified after an evidence-only follow-up. The retained initial log selected zero verbatim imports; the original corrected command/output was recovered without rerunning, listing all ten unchanged verbatim directories as identical with no mismatch output. The reviewer marked the evidence finding addressed. Working-tree artifact collection, four-concern reviewer inputs, and dependency-scoped feedback were verified; future harness/runtime compliance remains outside this evidence.
- Dispatch refinement: Task 5 brief ends at the following global final-verification heading; its seven task steps remain verbatim, and the controller owns the retained global checks/review. This avoids sending earlier execution records as task requirements.


### Task 5 execution evidence

Task 5 acceptance evidence

Tested state: `07fae81` plus Task 5 dirty extractor/tests, SDD/prompt, how, provenance, README, and plan. Agreement/Execution base remains `3363070f1179622ec32c64b30d3176d26ec493da`. Conditions: macOS `/bin/bash` and awk; Python subprocess tests use unique disposable TemporaryDirectories outside both pinned source worktrees.

- RED: `python3 scripts/tests/test_task_brief.py -v`, exit 1: `Ran 7 tests`, `FAILED (failures=8)`. Five methods failed: fenced literals, invalid/duplicate status (four subcases), stale missing task, plan/output aliasing, Provisional rejection. Ready and legacy passed. Failures demonstrate prescribed gaps in the old script.
- GREEN: same command exit 0: seven named test methods `ok`, `Ran 7 tests`, `OK`. Syntax `/bin/bash -n skills/subagent-driven-development/scripts/task-brief` exit 0. Supports C3 extractor behavior only; no broad Markdown parser claim.
- `scripts/gen-readme-table.sh` twice, exit 0; both `git hash-object README.md` outputs `2c8bfc7642b0983b080d826c8b0a6bc8c192fdf4`. `scripts/check-refs.sh` exit 0, `check-refs: clean`; `git diff --check` exit 0.
- Repository Python validator initially failed because it included the TSV header in active skill membership; corrected `/private/tmp/task5-repository-check.py` exit 0. Every row has seven columns, active directories match, imported paths exist. `diff -r` listed ten identical verbatim imports: grill-me, grill-with-docs, handoff, wait-what, improve-codebase-architecture, writing-for-agents, tdd, dispatching-parallel-agents, codebase-design, research. Both source SHAs and source worktree status unchanged. Helpers, Task 4 prompts, Light implement, all invocation frontmatter unchanged.
- Exact test and guard content compared with brief, exit 0. Baseline/source diffs inspected. Model Selection, batching/waiting, original fix reuse/escalation blocks identical. Bash 3.2 syntax used; no updater-engine edits, so engine guard/no-op checks inapplicable.

Task 5 lifecycle evidence

`python3 /private/tmp/task5-lifecycle.py`, exit 0. TemporaryRepositories and scratch cleaned by TemporaryDirectory context exits. All Git/extractor subprocesses asserted exit 0.

1. Setup/ADR 0004: staged unrelated file; `git commit --only -m agreement -- plan.md` committed agreed document only; `git diff --cached --name-only` remained `unrelated`. Recorded Agreement/Execution baseline before refinement.
2. Setup/ADR 0005: evidence settled `load() -> str`, owner A and behavior unchanged. Updated Provisional to Ready before extraction, then exit 0; brief retained C1/ADR/E1, concrete save/restart/reload acceptance, interface and verification.
3. Decisions/Setup/ADR 0005 instruction walkthrough: new owner requires user decision; affected work/dependants wait; independent Ready work may continue.
4. Breaker/Complete instruction walkthrough: fifth-round acceptance failure stays unresolved/incomplete; no extra dispatch, no dependent continuation.
5. Finish/Evidence Record: committed baseline, refinement, command/status/result/limit into plan; `git show HEAD:plan.md` recovered each after scratch directory disappeared.
6. Final Review: direct main commits; fixed baseline-to-HEAD diff nonempty; `git merge-base main HEAD` equals HEAD, branch-tip diff empty. Fixed base therefore preserves implementation review range.

Standalone context: synthetic header named ADR 0004/0005, C1/E1 and owner-A constraints. Task-local Decision context carried applicable ADR/C1/E1, concrete criteria/interfaces/verification into Ready brief; global text not copied. SDD dispatch and reviewer-input rules require controller to give binding constraints, baseline/current sources, decision revisions and evidence identically to worker/reviewer. Limits: this is extraction plus instruction composition; fixture `restart/reload PASS` illustrates durable record recovery, not actual client operation. Scenarios 3/4 and future harness compliance are not runtime evidence.


Task 5 self-review corrected diagram routes: addressed/deferred findings still pass acceptance/four-conclusion gate; pending consequential decisions wait; final evidence/gates precede cleanup. All seven task steps marked implemented; independent review remains controller-owned. No substantive unresolved implementation decision. Preserved agreed Task 4 record and explicit baseline hashes.

### Final review and verification

All five tasks are complete at implementation head `6caf15a6194d71ba2ae02c411f55f5305680f293`. Their commits, in order: `1ab183c`, `4a6d4b1`, `1d2c364`, `07fae81`, `6caf15a`. Task 5 independent review (`07fae81..6caf15a`) verified all four concerns with no findings. The final reviewers independently inspected the entire five-commit artifact from fixed Execution base `3363070f1179622ec32c64b30d3176d26ec493da`; no final fix wave was needed.

| Final axis | Conclusion | Inspectable basis and limits |
| --- | --- | --- |
| Standards: Design validity | Verified | Existing skill owners, current ADR/plan authority, Ready context, evidence validity, consequential decision boundaries and blocking completion compose consistently. No extra framework or distributed command. |
| Standards: Scope and standards | Verified | All 19 changed paths are authorized; import rewirings/provenance/generated README/router agree. Bash 3.2 contract, names, flags, pins, helpers, discovery links, Light topology and manual transitions preserved. No actionable smell or hard-standard finding. |
| Spec: Implementation correctness | Verified | C1–C8 traced through the actual discovery/planning/dispatch/review/feedback/cap/cleanup instructions and executable extractor; no missing, extra or misunderstood agreed behavior. |
| Spec: Evidence quality | Verified | Inspected actual seven-case extractor evidence, real disposable Git assertions, recovered import output and final fail-fast structural validator. Instruction-only ownership/cap cases and synthetic durability data are explicitly limited. |

Final checks at `6caf15a`, with clean product working tree, local macOS Bash/awk/Python and unchanged source pins:

- `/bin/bash -n skills/subagent-driven-development/scripts/task-brief`: exit 0, no output.
- `python3 scripts/tests/test_task_brief.py -v`: exit 0; all seven named methods `ok`, `Ran 7 tests`, `OK`. Tests cover Ready context, Provisional rejection/stale output/recovery, malformed/duplicate statuses, nested backtick/tilde fences, legacy extraction, missing-task stale removal and plan/output protection.
- `scripts/check-refs.sh`: exit 0, `check-refs: clean`.
- Final Python structural validator: exit 0, `Provenance, source paths/pins, membership, 10 verbatim imports, helpers, links, flags and changed-path scope: valid`. It asserted seven columns; active directory membership; imported paths and both source HEAD/gitlink pins; fail-fast recursive `diff -r` equality for all ten remaining verbatim imports; baseline hashes for `review-package`/`sdd-workspace`; discovery link targets; invocation flags/names; authorized changed paths; plan/planning-skill document links.
- `git diff --check 3363070f1179622ec32c64b30d3176d26ec493da HEAD` and `git diff --check`: exit 0, no output.
- Task 5's double README generation remains applicable: both blob hashes `2c8bfc7642b0983b080d826c8b0a6bc8c192fdf4`, with no later README changes. No updater-engine changes; its unrelated regression fixtures were inapplicable.

Source pins remained mattpocock `d81f3a183412e71a5b1e84ca21bc1a35eea03a60` and superpowers `8ca22dba9a94f28898bbce59f2537ff4d87c747d`. All narrowly rewired source differences were inspected against pinned imports and the recorded baseline; every intentional divergence is recorded in provenance.

No unresolved or deferred finding remains. Evidence establishes extractor behavior, Git artifact/baseline/durability boundaries, repository integrity and instruction composition. Future harness compliance and actual-client recovery are not claimed. Documentation-only final recording does not change the tested implementation. These summaries preserve commands, tested state, results, decisions and limits after eligible scratch cleanup. Merge, sanity testing and branch/worktree cleanup remain user-owned.
