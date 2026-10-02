# Plan Format

Required header and task fields for plans saved to
`docs/plans/NNNN-<feature-name>.md`. Apply the Task Contract in SKILL.md.

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

