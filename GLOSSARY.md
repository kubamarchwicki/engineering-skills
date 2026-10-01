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
