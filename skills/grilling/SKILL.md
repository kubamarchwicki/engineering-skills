---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

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

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
