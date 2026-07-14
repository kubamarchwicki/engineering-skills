# Engineering Skills

Engineering Skills is a curated set of agent skills that gives its user explicit control over software-development workflows while retaining reusable, model-applied disciplines.

## Workflow Language

**Track**:
A user-selected sequence of stages for a class of work. The set offers a Light Track for focused work and a Heavy Track for multi-stage work.
_Avoid_: Flow, mode

**Light Track**:
The track for a focused change that can be aligned, implemented, reviewed, and verified on the current branch.
_Avoid_: Fast track, simple track

**Heavy Track**:
The track for work that benefits from a durable specification, an explicit plan, and task-by-task execution with layered review.
_Avoid_: Full track, automatic track

**Stage**:
A bounded unit of work within a Track that produces one inspectable outcome and stops at its boundary.
_Avoid_: Phase, step

**Gear Shift**:
An explicit user invocation that advances work from one Stage to the next. A skill may name the next gear but never shifts on the user's behalf.
_Avoid_: Auto-chain, automatic handoff

**Branch Ready**:
The state reached after the agreed work, review, and verification are complete but before merge, sanity testing, or cleanup. Those final actions remain with the user.
_Avoid_: Done, merged

## Model-Selection Language

**Controller**:
The main agent coordinating an already authorized Stage, including Work-Class assignment, profile selection, Dispatch Records, and gate enforcement. Unlike a Router, it executes within the selected Stage rather than choosing the next one.
_Avoid_: Router, workflow runner

**Correctness Bar**:
The acceptance threshold requiring Branch Ready work to have no unresolved Critical or Important specification, standards, security, or regression defects, supported by the strongest applicable verification rather than test results alone.
_Avoid_: Passing tests, good enough

**Capability Floor**:
The minimum model capability permitted for a subagent dispatch, set by the work's ambiguity, breadth, consequence, verification strength, novelty, and horizon. A controller may raise this floor when evidence warrants it but does not lower it to save cost.
_Avoid_: Exact model, preferred model

**Reasoning Floor**:
The minimum deliberation level permitted for a subagent dispatch, selected independently of its Capability Floor. It increases when correctness depends on subtle reasoning even if the work is narrow.
_Avoid_: Token budget, model tier

**Role Floor**:
The minimum capability and reasoning assigned to a subagent role independently of the work it receives.
_Avoid_: Role default, preferred model

**Effective Floor**:
The minimum capability and reasoning permitted for a dispatch after independently taking the higher of the work's floors and the subagent role's floors.
_Avoid_: Default model, role model

**Floor Verification**:
Evidence that the active dispatch surface explicitly selected or reported capability and reasoning at or above the Effective Floor. Prompt steering, assumed inheritance, and an unconfirmed request do not constitute verification.
_Avoid_: Requested configuration, expected model

**Dispatch Mode**:
The execution topology selected independently of capability and reasoning: Single-Agent keeps the assigned work within one subagent, while Delegating permits that subagent to divide work among further agents.
_Avoid_: Effort level, model tier

**Provider Adapter**:
The provider-specific mapping from Work Classes, floors, roles, and Dispatch Modes to pinned model identifiers and supported runtime controls.
_Avoid_: Routing policy, model alias

**Routing Policy**:
The centrally governed, provider-neutral rules that establish Work Classes, role floors, Dispatch Modes, fallback behavior, and calibration triggers for the Skill Set.
_Avoid_: Local preference, runtime heuristic

**Policy Calibration**:
The human-controlled adjustment of the Routing Policy, initiated whenever the user judges it necessary and without an evidence threshold. Dispatch Records may inform the decision, but a consuming workflow may only escalate one dispatch and never tunes or rewrites the global policy locally.
_Avoid_: Self-tuning, local policy override

**Dispatch Record**:
The auditable account of an acceptance-relevant dispatch's role, Work Class, Escalation Signals, Effective Floor, Dispatch Mode, requested configuration, effective configuration, and Floor Verification status.
_Avoid_: Prompt transcript, agent summary

**Review Independence**:
The separation created by fresh context, read-only authority, independent evidence, and an adversarial review contract. It does not require a different model family from the implementer.
_Avoid_: Model diversity

**Escalation Signal**:
A qualitative condition—such as ambiguity, cross-module breadth, high consequence, weak verification, novelty, or long horizon—that raises a work floor regardless of apparent task size.
_Avoid_: Complexity point, file-count score

**Escalation Ladder**:
The ordered response to an inadequate dispatch: repair context, raise reasoning, raise capability, split oversized work, then return contradictory requirements to the user.
_Avoid_: Blind retry, immediate model upgrade

**Work Class**:
One of four qualitative classifications used to establish a work's Capability Floor and Reasoning Floor: Bounded, Integrated, Demanding, or Exceptional.
_Avoid_: Risk score, complexity score

**Bounded Work**:
Work that is exact, local, reversible, and supported by strong verification.

**Integrated Work**:
Work requiring ordinary multi-file coordination or judgment about established repository patterns.

**Demanding Work**:
Work involving ambiguity, broad interactions, high consequence, weak verification, or substantial novelty.

**Exceptional Work**:
Unusually long-horizon work, the highest-consequence audit, or work that still fails after its context and reasoning have already been improved.
_Avoid_: Default hard task

## Skill-Set Language

**Skill Set**:
The curated collection of Distributed Skills that together implement the Engineering Skills product contract.
_Avoid_: Plugin, marketplace, upstream suite

**Skill**:
A named package of agent instructions for one workflow stage, discipline, or maintenance responsibility.

**User-Invoked Skill**:
A Skill that begins only when the user explicitly selects it.
_Avoid_: Manual skill, command skill

**Model-Invoked Skill**:
A Skill that the agent applies when its described situation arises within another workflow.
_Avoid_: Automatic skill, background skill

**Router**:
The User-Invoked Skill that recommends a Track and names the exact next Skill without beginning that work.
_Avoid_: Orchestrator, workflow runner

**Distributed Skill**:
A Skill that belongs to the curated set exposed to supported agent harnesses.
_Avoid_: Global skill, installed skill

**Maintenance Skill**:
A repository-local Skill that administers the curated set but is not itself a Distributed Skill.
_Avoid_: Updater, admin command

**Imported Skill**:
A Skill selected from an Upstream Source and preserved whole by default, apart from explicitly recorded Rewirings.
_Avoid_: Fork, rewritten skill

**Original Skill**:
A Skill authored for Engineering Skills rather than selected from an Upstream Source.
_Avoid_: Custom skill, local skill

**Dropped Skill**:
A known upstream Skill that was considered and deliberately excluded from the curated set.
_Avoid_: Missing skill, deleted skill

**Rewiring**:
A narrow, intentional change that adapts an Imported Skill to the product contract while leaving unrelated upstream content intact.
_Avoid_: Rewrite, cleanup, customization

## Maintenance Language

**Upstream Source**:
An external skill collection from which Imported Skills retain their identity and history.
_Avoid_: Dependency, editable source

**Pin**:
The exact revision of an Upstream Source that defines the baseline for the curated imports.
_Avoid_: Latest version

**Provenance**:
The recorded relationship between every considered Skill, its Upstream Source or original status, its membership decision, and any local divergence.
_Avoid_: Inventory, README table

**Candidate**:
A newly discovered upstream Skill whose adoption or rejection requires an explicit user decision.
_Avoid_: Automatic addition

**Divergence**:
An intentional difference between an Imported Skill and its Upstream Source that must remain recorded after the Pin advances.
_Avoid_: Drift, accidental edit

**Upstream Sync**:
The controlled process of reconciling the curated set with newer Upstream Sources while preserving Rewirings and putting membership or divergence decisions to the user.
_Avoid_: Upgrade, overwrite
