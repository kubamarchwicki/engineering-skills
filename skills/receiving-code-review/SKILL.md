---
name: receiving-code-review
description: Use when the orchestrator receives code review feedback from a reviewer subagent, before implementing suggestions - requires technical rigor and verification, not performative agreement or blind implementation
---

# Code Review Reception

**Core principle:** Verify before implementing. Ask before assuming. Technical correctness over social comfort.

## Reception sequence

1. **Understand:** Read the complete feedback and identify each requested outcome and affected work. Restate requirements when needed; record unclear items for investigation.
2. **Verify:** Check findings against code, tests, agreed behavior, and the technical checks below. Identify supporting evidence and its limits before accepting or rejecting a suggestion.
3. **Classify:** Assign each finding to the categories below so its correction addresses the cause.
4. **Resolve decisions:** Apply the decision and dependency rules below. An item is ready only when its meaning, evidence, and any consequential decision are settled.
5. **Dispatch corrections:** Give the implementer each settled item's requirement, evidence, classification, affected tasks, and acceptance checks. Correct one item at a time: blocking issues (breaks, security), simple fixes (typos, imports), then complex fixes (refactoring, logic). Test each fix and verify affected functionality for regressions.
6. **Report evidence:** Inspect the resulting diff and verification output. Report what changed, which findings are resolved, and remaining blocked items or evidence gaps; use the factual-response policy below.

## Feedback categories

| Category | Response |
|---|---|
| Implementation defect | Correct code/tests against agreed behavior. |
| Mistaken assumption | Investigate before revisiting affected design choices. |
| Changed requirement | Follow your human partner's direction; update outcomes and dependent work. |
| New dependency capability | Verify the capability and its ownership implications. |
| Newly expressed preference | Record consequences and apply the user's direction. |

## Decisions and blocked work

Resolve routine facts and reversible details yourself. For unclear feedback or
incomplete verification, investigate available facts first and report evidence
and its limits. Ask your human partner for missing clarification only after
that investigation.

Your human partner owns behavior, ownership, and scope changes. Present
evidence, tradeoffs, and a recommendation; ask in plain prose one question at
a time. Honor prior authorization and explicit direction without seeking
another approval of the same decision. External feedback conflicting with
your human partner's prior decisions requires discussion before affected work.

Unclear feedback and unresolved consequential decisions block affected items
and their dependants. Independent work with settled decisions and evidence
may continue. Before dependent work resumes, update affected plan tasks/tests
and durable decisions, and retire contradictory instructions. Use superseding
ADRs in `docs/adr/` for substantive changes; update `GLOSSARY.md` only when
terminology changes.

## Technical checks and pushback

**your human partner's rule:** "External feedback - be skeptical, but check carefully"

For external feedback, check:

- Technical correctness for THIS codebase and stack.
- Existing functionality and regression risk.
- Reasons for the current implementation, including legacy constraints.
- Supported platforms/versions and actual dependency capabilities.
- Reviewer context and consistency with your human partner's architectural decisions.
- Actual usage before adding a "professional" feature: search the codebase for callers. If unused, recommend removal or omission (YAGNI); if used, address the verified need.

These checks also identify reasons to push back. Explain with technical
reasoning, working tests/code, and specific questions. Route architectural
changes through the decision rules above. If discomfort inhibits pushback,
name that tension and tell your human partner about the issue you've seen.

**your human partner's rule:** "You and reviewer both report to me. If we don't need this feature, don't add it."

## Factual responses

State the requirement, evidence, fix and location, or reasoned pushback;
action can suffice when no response is needed. Use no praise, performative
agreement, or gratitude. If your pushback was wrong, state what you checked,
the corrected conclusion, and the next action; keep the correction brief.

For response wording when feedback is unclear, a compatibility or YAGNI
objection arises, feedback is correct, or your pushback was wrong, read
[EXAMPLES.md](EXAMPLES.md). Also read its GitHub reference when replying to
an inline review comment.
