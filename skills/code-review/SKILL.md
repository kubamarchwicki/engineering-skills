---
name: code-review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) across four concerns: correctness, design validity, evidence quality, and scope and standards, allocated to Standards and Spec reviewers. Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."
---

Review the actual change against its agreement across four concerns:

- **Standards**: Design validity and Scope and standards.
- **Spec**: Implementation correctness and Evidence quality.

Both reviewers run as **parallel sub-agents**, then this skill presents their separate conclusions.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, resolve the fixed point to a SHA (`git rev-parse <fixed-point>`) and check the selected mode's artifact is non-empty. A bad ref or empty artifact should fail here, not inside two parallel sub-agents.

For explicitly requested working-tree review, use
`git diff <fixed-point> -- <task-paths>` for tracked committed, staged, and
unstaged changes. Enumerate untracked task files with
`git ls-files --others --exclude-standard -- <task-paths>` and inspect their
contents. The tracked diff alone omits these files.

Record the resolved fixed point, mode, task paths, and reviewed state. Give
both reviewers the same artifact. Working-tree review is non-empty when
either tracked diff or relevant untracked files exist. If the state changes
during review, invalidate the affected conclusions before reporting them.

`<fixed-point>` is the caller's resolved revision; `<task-paths>` are the caller's relevant paths. Pass each path as a separate quoted argument, never interpolate a joined shell string. Identify unrelated user changes and keep them outside the implementation's claimed scope. Preserve committed mode's three-dot diff and commit list above.

### 2. Identify the agreement sources

Look for the agreed outcomes and acceptance, in this order:

1. Explicit caller/user outcomes and paths.
2. The named plan's outcome/verification, constraints, current refinements, and decision-source references. Use commit-message references when applicable.
3. Applicable `GLOSSARY.md` and ADRs, any supplied spec, or a matching local document under `docs/specs/`, `docs/plans/`, `docs/`, `specs/`, or `.scratch/` found by branch or feature name.
4. If the agreement cannot be recovered, ask for missing outcome/acceptance information and report that gap.

Absence of a separate spec does not skip Spec review.

### 3. Identify the standards sources

Search the repo for every file that documents how code should be written. When `CODING_STANDARDS.md` or `CONTRIBUTING.md` exists, it must be on the list.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn both sub-agents in parallel

Issue both sub-agent calls together, in the foreground, and aggregate the reports they return.

Give both reviewers the same actual change artifact, agreement and constraints, baseline/current references when available, and Evidence Records. Include the selected mode, resolved fixed point, task paths, reviewed state, and committed-mode commit list when applicable.

Give Standards the standards sources and the full smell baseline from step 3; preserve repo overrides and the distinction between standards and heuristics.

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

Each reviewer reports its two allocated conclusions separately as `Verified`, `Findings`, or `Evidence gap`, with references and limits. A relevant criterion outside available evidence is an explicit controller follow-up.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings, because the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why two axes

The same two reviewers cover four distinct concerns. Correct implementation can rest on an invalid design; good design can lack boundary evidence; passing checks can still hide a scope or standards breach. Separate conclusions keep any one concern from masking another.
