# Planning and verification interview notes

Status: The user confirmed the complete design and coordinated scope, then explicitly requested committing the decision records and starting `writing-plans`. This is an interview record, not a required feature-specification artifact.

Source: [Optimizing the agentic loop](optimizing-agentic-loop.md). Durable decisions are recorded in [ADR 0004](../adr/0004-record-grilling-outcomes-in-glossary-and-adrs.md) and [ADR 0005](../adr/0005-validate-designs-before-detailed-planning.md); these notes preserve the interview detail for planning.

## Agreed decisions

### 1. Establish intended behavior before detailed planning

Grilling establishes observable behavior, constraints, exclusions, and acceptance criteria, distinguishing requirements from proposed implementation choices. Before choosing files or interfaces, `writing-plans` checks that this foundation is sufficient for decomposition.

The planner extracts requirements already agreed in the available material. When intended behavior is incomplete, it pauses detailed planning and resolves consequential gaps with the user in place. Questions are limited to decisions affecting behavior, ownership, or scope; the agent resolves routine implementation details itself.

The prerequisite is satisfied when success can be described without referring to proposed classes or modules.

### 2. Verify consequential contracts and ownership before dependent tasks

Investigate the responsibilities the proposed change touches: what existing code or dependencies already provide, and who creates, retains, updates, and releases state. Distinguish verified facts, unverified assumptions, and decisions requiring user judgment.

An unverified consequential ownership assumption blocks detailed planning of the tasks that depend on it until it is checked. Unaffected work can still be planned.

### Stage ownership for points 1–2

Grilling owns establishing the context: intended behavior, existing capabilities and ownership, consequential assumptions, and decisions requiring user judgment.

At the start of `writing-plans`, a readiness check uses the existing evidence and verifies that it supports decomposition. The planner investigates remaining gaps and any new questions exposed by planning, reusing evidence that still applies. It raises resulting behavior, ownership, or scope decisions with the user in place.

The readiness check is internal to `writing-plans`. The user still initiates the transition from grilling to planning.

### 3. Independently challenge every heavy-track design

Every heavy-track plan requires a fresh reviewer to challenge the proposed design before detailed tasks depend on its choices. This review is mandatory even when the planner considers the change routine.

The reviewer receives the intended outcomes, relevant source evidence, and proposed architecture. It examines whether existing components already provide the proposed responsibilities, what behavior each new abstraction adds, whether the design creates competing sources of truth, whether defensive checks enforce actual requirements, and which assumption would cause the largest rewrite.

This review evaluates whether the design is necessary and sufficient for the agreed outcomes. The planner's existing self-review also checks the detailed plan for coverage and consistency.

### 4. Allow bounded integration experiments during investigation

Grilling and the planning readiness check may write and run temporary experiment code to verify consequential integration assumptions. Production implementation remains in the execution stage.

Each experiment answers a named uncertainty, has a bounded scope, and preserves its findings for the planner and reviewer. It exercises the real integration boundary through normal execution, a meaningful failure, and the next operation after that failure, observing outputs and state ownership.

Grilling is the usual place for these experiments; the readiness check can run them when further uncertainties emerge. Evidence must support the risky choice, or the design must change before dependent implementation proceeds.

### 5. Plan observable slices with explicit readiness

Each slice demonstrates a complete observable behavior across relevant boundaries. Heavy-track plans may include both ready and provisional slices.

Ready slices have enough evidence to specify their files, interfaces, tests, and expected behavior. Provisional slices state the intended outcome, dependencies, and the named finding needed before their implementation details can be settled.

Every slice must become concrete before an implementer receives it. Planning and execution must both recognise this readiness requirement.

The execution controller may make a provisional slice ready when the required evidence arrives and the refinement preserves agreed behavior, ownership, and scope. It updates the plan before dispatching an implementer. Changes to behavior, ownership, or scope require the user's decision.

### Verification scope and evidence reuse

Implementation, review, and completion reporting judge evidence by whether it still supports the claim. Run focused checks for each slice and reuse results while the relevant code, dependencies, configuration, and environment remain applicable.

Rerun affected checks after changes. Broaden verification when integration risks, failures, or required repository gates justify it. Replace the blanket full-suite run before every task commit with checks appropriate to the change, while honoring project requirements.

Completion reporting identifies what was tested and any remaining limits. Reuse depends on the tested state and the scope of the claim; starting a new message or handing work to another reviewer does not by itself invalidate evidence.

### 6. Require four review conclusions at slice and branch level

Slice reviews and final whole-branch reviews use the existing reviewer structure and explicitly conclude on all four concerns:

| Concern | Question |
| --- | --- |
| Implementation correctness | Does the code satisfy the agreed behavior? |
| Design validity | Do the architecture and its assumptions still hold? |
| Evidence quality | Would the checks detect the failure we care about? |
| Scope and standards | Does the change respect agreed boundaries and conventions? |

Slice reviewers apply these questions within their scope; whole-branch review assesses the integrated result. Findings follow relevant consequences, including validation, errors, cleanup, configuration, and documentation, and identify supporting evidence or verification gaps. Discoveries that call agreed behavior or ownership into question require the user's decision.

### Document ownership

[ADR 0004](../adr/0004-record-grilling-outcomes-in-glossary-and-adrs.md) records the agreed roles of the glossary, ADRs, and numbered plans, including the plan's outcome-and-verification section. A separate living spec is optional.

### 7. Classify feedback and preserve the current decisions

Classify feedback before acting on it:

- Implementation defects are corrected in code and tests against the agreed behavior.
- Mistaken assumptions and new dependency capabilities require investigation before revisiting affected design choices.
- Changed requirements and newly expressed preferences follow the user's direction, with their consequences recorded.

Update affected plan slices and tests before dependent work resumes. Preserve decision rationale in the applicable durable documents and retire contradictory instructions. Substantive changes to accepted ADR decisions use the supersession rule in ADR 0004; clarifications may be edited in place.

### Preserve the starting agreement

Execution ensures a committed baseline of the agreed plan and relevant glossary/ADR changes before the first implementation task. It records an existing revision when those documents are already committed; otherwise it creates a focused documentation commit containing only the agreed material. ADR 0004 records this policy.

## Confirmed coordinated implementation scope

| Area | Required change |
| --- | --- |
| `grilling` | Establish outcomes and ownership evidence, distinguish facts from assumptions and user decisions, and allow bounded experiments. |
| `domain-modeling` and its ADR guidance | Preserve glossary scope and record substantive decision changes through superseding ADRs. `grill-with-docs` continues to compose grilling and domain modeling. |
| `writing-plans` | Add the Readiness Check and mandatory independent design review, use glossary/ADR sources, include outcome-and-verification criteria, and support Ready and Provisional Slices. |
| `subagent-driven-development`, its prompts, and context packaging | Preserve the committed baseline; gate dispatch on Slice readiness; carry applicable outcomes, decisions, assumptions, and evidence to workers and reviewers; refine plans within agreed bounds; and preserve durable findings before deleting temporary records. |
| `code-review` and `receiving-code-review` | Require the four review conclusions using existing reviewer structure, recognise glossary/ADR/plan sources, classify feedback, and apply the user-decision and durable-update rules. |
| `verification-before-completion` and execution completion instructions | Align claims, check scope, and evidence reuse, including the completion instructions in `implement` where needed. |
| Provenance, README, and workflow references | Record every intentional imported-skill divergence and update generated descriptions and affected references consistently. |

The mandatory design reviewer, provisional-slice execution, and committed planning baseline belong to the Heavy Track. Shared grilling, review, and verification disciplines also serve the Light Track through its existing commands. Inherited skill names and manual Stage boundaries remain in force.

## Interview handoff

The interview is complete. The user explicitly initiated the next manual Stage, `writing-plans`, and authorized committing these decision records. Skill implementation requires its own subsequent manual Stage.
