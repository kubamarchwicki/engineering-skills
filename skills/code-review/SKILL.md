---
name: code-review
description: Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes — Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/PRD asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X".
---

Two-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the originating issue / PRD / spec?

Both axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

## Process

### 1. Pin the fixed point and freeze review evidence

Whatever the user said is the fixed point — a commit SHA, branch name, tag, `main`, `HEAD~5`, etc. If they didn't specify one, ask for it.

Resolve the fixed point and `HEAD` to full commit SHAs, then compute and pin the
merge base. Keep those exact values as `fixed_point_sha`, `head_sha`, and
`merge_base_sha` for the whole review. Capture the full diff command as
`git diff -U10 <merge-base-sha>..<head-sha>` and the commit list as
`git log <merge-base-sha>..<head-sha> --oneline`. Use the pinned SHAs in both;
do not leave a moving ref such as `HEAD` in either command.

Before going further, confirm both commits and the merge base resolve and that
the pinned diff is non-empty. A bad ref or empty diff should fail here — not
inside two parallel sub-agents.

Use the sibling
[`review-package`](../subagent-driven-development/scripts/review-package)
helper to freeze the evidence before either axis dispatches. Resolve the
repository root with `git rev-parse --show-toplevel` as `repo_root`, then run
`"$repo_root/skills/subagent-driven-development/scripts/review-package" "$merge_base_sha" "$head_sha"`
and capture the absolute path reported between `wrote ` and the summary as
`review_package_path`. Require that path to be absolute, a regular file,
readable, and non-empty. Also require its first line to identify the exact
`${merge_base_sha}..${head_sha}` range. Stop here if materialization or any
validation fails.

Immediately before every initial or repeat axis dispatch, verify that the
current `HEAD` still equals `head_sha`. If a fix advanced `HEAD`, pin the new
full head SHA and rerun the helper against the same `merge_base_sha`; use the
new range-named package. Never reuse or overwrite a package for a stale range.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. A path the user passed as an argument.
2. A spec or plan path referenced in the commit messages.
3. A PRD, spec, or plan file under `docs/specs/`, `docs/plans/`, `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below — a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation — and, like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Classify and verify both review axes

Read the [Subagent Model Routing Policy](../subagent-driven-development/model-routing.md)
before dispatching.
Apply Routing Policy Version 2 independently to the Standards and Spec axes.
Both axes have a Demanding/high role floor. Recompute branch Work Class from
the complete diff; raise either axis to Exceptional when the policy's signals
apply. Do not lower an axis because the diff is small.

Select the matching named read-only reviewer profile. The baseline is
`engineering-reviewer-demanding-high`; use an Exceptional or higher-reasoning
reviewer only when classification or the Escalation Ladder requires it.
Establish a verified Effective Floor for each axis before dispatch. Named
profile enforcement or a trustworthy effective model-and-effort report counts;
prompt steering alone does not. If either required reviewer cannot be verified,
stop before all dispatches and name a compatible surface or configuration.
Resume only there with verified capacity. Do not emit calibration merely
because the active runtime is limited. If no compatible surface or
configuration can obtain the reviewer, emit the hard-stop
`POLICY_CALIBRATION_REQUIRED`, provide the redacted calibration brief, name
`$grill-with-docs` in `engineering-skills`, and wait. Never silently substitute
downward.

For every axis that will run, append a redacted `started` event through
`../subagent-driven-development/scripts/record-dispatch`. After the reviewers
return, append the matching `completed` events with finding counts and available
elapsed-time or usage data. Do not record prompts, diffs, or source code.

### 5. Spawn the routed reviewers in parallel

Send a single message with two `Agent` tool calls, selecting the verified named
reviewer profile for each. Both agents receive fresh context and read-only
authority. They may use the same provider or model family; independence comes
from isolated context and adversarial instructions.

Use the same `review_package_path` captured in step 1 for every axis dispatched in this run.
The diff command and commit list remain provenance and traceability context;
the frozen package is the readable review evidence and executing the command
is not a reviewer capability prerequisite.

Prefix both prompts with this routing declaration, filled from step 4:

```text
Policy version: 2
Role: code-review Standards reviewer | code-review Spec reviewer
Work Class: <Bounded | Integrated | Demanding | Exceptional>
Effective Floor: <capability>/<reasoning>
Requested profile: <named reviewer profile>
Requested model and effort: <full model ID>/<effort>
Floor Verification: verified — <trustworthy evidence>
This is an independent read-only gate. Do not mutate files and do not spawn subagents.
If the runtime configuration does not match this declaration, return only
FLOOR_UNVERIFIED with mismatch evidence.
```

**Standards sub-agent prompt** — include:

- The routing declaration.
- The full diff command and commit list, for traceability.
- The absolute frozen review package path from step 1.
- This explicit instruction: "Read the frozen review package before reviewing. It is the shared evidence for the pinned range; do not depend on executing the diff command."
- The list of standards-source files you found in step 3, **plus the smell baseline from step 3** pasted in full — the sub-agent has no other access to it.
- The brief: "Report — per file/hunk where relevant — (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls — documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Label every finding Critical, Important, or Minor. Critical means a safety, security, data-integrity, or correctness failure with severe consequence; Important means the branch cannot be trusted until fixed; Minor is non-blocking. Under 400 words."

**Spec sub-agent prompt** — include:

- The routing declaration.
- The full diff command and commit list, for traceability.
- The absolute frozen review package path from step 1.
- This explicit instruction: "Read the frozen review package before reviewing. It is the shared evidence for the pinned range; do not depend on executing the diff command."
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Label every finding Critical, Important, or Minor using the same severity definitions as the Standards axis. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final
report. Do not create a Spec dispatch record for a dispatch that did not occur.

### 6. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings — the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes — that's the reranking the separation exists to prevent.

If a reviewer reports `FLOOR_UNVERIFIED`, discard that axis as a gate result and
finish the parallel peer if it is already running, stop before another review
dispatch, and name compatible verified capacity; do not report a pass. Emit the
hard-stop calibration trigger only if no compatible surface or configuration
can obtain the reviewer.

If a Critical or Important finding escaped an earlier verified task review,
finish the parallel peer, emit `POLICY_CALIBRATION_REQUIRED` as pending policy
debt, and preserve the Dispatch Record identifiers. Continue only this branch's
Exceptional/xhigh fixes, re-review, both final axes, and verification. A passing
branch may be reported Branch Ready with calibration still pending; begin no
future SDD work until the human resolves it through `$grill-with-docs`.

If the branch was already incorrectly described as Branch Ready, finish the
parallel peer, emit the hard-stop `POLICY_CALIBRATION_REQUIRED`, provide the
redacted brief and next manual gear, and stop before another dispatch or
readiness claim. Never change the global routing policy opportunistically from
inside this review.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
