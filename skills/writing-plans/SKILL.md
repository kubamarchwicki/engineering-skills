---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before production implementation
disable-model-invocation: true
---

# Writing Plans

## Overview

Write implementation plans for an engineer who has not seen this codebase or the agreed requirements and decision sources. Assume they write idiomatic code in the project's language once they know the exact interface and the exact test, and that they will make a reasonable choice wherever the plan leaves one open. What they cannot know is what you decided: which files, which names and signatures, which values from the agreed requirements and decision sources, which tests prove each task. Document those. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** For heavy work an isolated worktree may have been created via the `using-git-worktrees` skill; small work runs inline on the current branch.

**Save plans to:** `docs/plans/NNNN-<feature-name>.md` (next number in sequence)

## Scope Check

If the agreed work covers independently deliverable subsystems, recommend separate numbered plans with their own outcomes and acceptance criteria. Use applicable decision sources; separate feature specs are optional.

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

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. Specify evidence-supported choices for Ready Slices; keep dependent choices Provisional until their named evidence arrives.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate. When drawing task boundaries: fold setup,
configuration, scaffolding, and documentation steps into the task whose
deliverable needs them; split only where a reviewer could meaningfully
reject one task while approving its neighbor. Each task ends with an
independently testable deliverable.

## Step Granularity

**Each step is one action with a checkable result:**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Decision sources:** [applicable GLOSSARY.md/ADR paths, optional supplied spec,
and the source of agreed grilling outcomes]

## Outcome and verification
[Number observable outcomes, constraints, and exclusions. Each acceptance
criterion names its real boundary/check and the evidence needed to establish
it. Link detailed investigation.]

## Design review
[Reviewer disposition, findings/dispositions, evidence references, and limits.
Identify dependencies on unresolved findings.]

## Global Constraints

[Project-wide requirements from agreed outcomes and decision sources — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the agreed outcomes and decision sources. Every task's requirements implicitly
include this section.]

## Review Focus

[The input classes or failure modes the agreed outcomes and decision sources
imply but no task's tests exercise that are most likely to bite a person using
this software — one line each, naming the input or condition and the behavior
a reasonable person would expect, most likely first. Use the number warranted
by the work. The agreed outcomes and decision sources say what the software
must do, not everything it will meet, and their silence on an input is not
permission for that input to break the program. Write the list here, once,
with the agreed outcomes and decision sources in front of you. Then, for
each line, add the test that pins it to the task that owns the code, in that
task's own step style. Name actual boundaries, consequential failures, and
the evidence or explicit limits.]

---
```

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

## Task Structure

For Ready Slices:

````markdown
### Task N: [Component Name]

**Status:** Ready
**Outcome and acceptance:** [slice behavior, criterion IDs, concrete conditions/results]
**Decision context:** [applicable ADR/glossary references, relevant assumptions/evidence,
and decisions from earlier slices required by this task]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Implement `function(input: InputType) -> ResultType` in `exact/path/to/file.py`**

One line on the approach when the signature and the test leave a choice
(which library call, which data structure); a code block only for an
algorithm they do not determine.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

### Task N: Recover after a dropped connection
**Status:** Provisional
**Outcome and acceptance:** The next operation succeeds after a transient
connection loss without duplicate retained state.
**Decision context:** The agreed recovery outcome and ownership ADR.
**Dependencies:** The client-lifecycle experiment.
**Needs evidence:** Which component reconnects and releases failed-operation
state. Refine after normal, failed, and subsequent operations are observed
through the actual client boundary.

## What a Step Contains

These exact-step and signature requirements apply to Ready Slices.

A step is done when the implementer can write exactly one reasonable thing
from it. That is the whole requirement: unambiguous, not complete. Each kind
of step carries what makes it unambiguous and nothing more:

- **A test step:** the test's name and its assertions, as code, with the
  agreed outcomes and decision sources' exact values in them.
- **A code step:** the exact signature (name, parameters, return type), the
  file it lives in, and the specific values the agreed outcomes and decision sources pin. The implementer
  writes the body. A body appears only for an algorithm the signature and
  tests do not determine, or for exact copy the agreed outcomes and decision sources fix.
- **A verification step:** the command to run and the output that means it
  passed.
- **A reference to another task:** that task's Interfaces block says what
  to use; the plan does not repeat that task's code.

A plan is the set of decisions the implementer cannot make alone. A plan
longer than the code it describes has written the code instead. Lines that
decide nothing ("TBD", "handle edge cases", "add appropriate validation",
"write tests for the above", a type or function no task defines) are the
opposite failure, and the self-review catches both.

## Self-Review

After writing the complete plan, look at the agreed outcomes and decision sources with fresh eyes and check the plan against them. This is a checklist you run yourself — not a subagent dispatch.

**1. Coverage:** Every agreed outcome/constraint and applicable decision source is accounted for. Can you point to a task that implements each? List any gaps.

**2. Step scan:** Every Ready step must let the implementer write exactly one reasonable thing, and no step may carry more than that: a line that decides nothing is a gap, a function body the signature and tests already determine is a transcript. Fix both. Provisional tasks name dependencies and an evidence condition.

**3. Type consistency:** Do the types, method signatures, and property names you used in later Ready tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug. Provisional interface dependencies remain blocked.

**4. Review Focus:** For each input class or failure mode the agreed outcomes and decision sources imply, is there a task whose tests exercise it? The uncovered ones most likely to bite a person go in the Review Focus section, using the number warranted by the work, and each line there gets its test added to the owning task. Actual boundaries and consequential failures have evidence or explicit limits. An empty section means you checked and found none, not that you skipped the check.

**5. Proportion:** Compare the plan's length to the agreed outcomes and decision sources. A plan several times longer than the requirements it implements is a transcript of the program, not a plan. If code blocks are most of the document, replace bodies with signatures, test names and assertions, and check that each Ready step is still unambiguous.

If you find issues, fix them inline. Fix routine details inline; revisit the affected independent review if a correction changes a reviewed design choice or invalidates its assumption. If you find an agreed requirement with no task, add the task.

## Execution Handoff

After saving the plan, stop:

**"Plan complete and saved to `docs/plans/<filename>.md`. Review it; when you're ready, `/subagent-driven-development` executes it."**

The gear shift belongs to your human partner: they read the plan and type the next command. Do not begin execution yourself.
