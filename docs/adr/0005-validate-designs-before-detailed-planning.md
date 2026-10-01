# Validate designs before detailed planning

Agents can follow a precise plan and pass its tests while sharing a mistaken design assumption. We therefore require grilling to establish observable outcomes, constraints, exclusions, acceptance criteria, and evidence about existing capabilities and state ownership; `writing-plans` checks that foundation before decomposition and obtains a fresh independent design review for every Heavy Track plan. This adds investigation and a bounded review to each plan in exchange for exposing costly mistakes before dependent implementation.

## Planning and execution

- Grilling and the planning Readiness Check may run bounded temporary integration experiments, each answering a named uncertainty through normal execution, meaningful failure, and the next operation after failure. Findings survive for planners and reviewers; production implementation belongs to execution.
- Unverified consequential assumptions block detailed planning of dependent work. Plans describe observable Slices, marking later ones Provisional until a named finding supports their details; every Slice must be Ready before dispatch.
- The execution controller may refine a Provisional Slice and update the plan when evidence arrives, preserving agreed behavior, ownership, and scope. Changes to those agreements require the user's decision. The user initiates transitions between Stages.

## Review and evidence

- Slice and whole-branch reviews use the existing reviewer structure and explicitly assess implementation correctness, design validity, evidence quality, and scope and standards. They follow relevant consequences across boundaries and identify evidence and verification gaps.
- Verification scope follows the change and its risks. Results may be reused across implementation, review, and completion while they still support the claim for the relevant code, dependencies, configuration, and environment. Relevant changes, unresolved risks, failures, and required project gates determine reruns; completion reports name what was tested and its limits.
- Feedback distinguishes implementation defects, mistaken assumptions, changed requirements, new dependency capabilities, and newly expressed preferences. Correct defects against the agreement, investigate assumptions and capabilities, and follow the user's direction on requirements and preferences. Update affected plans and tests before dependent work resumes, retiring contradictory instructions.

Document ownership, ADR supersession, and the committed planning baseline follow [ADR 0004](0004-record-grilling-outcomes-in-glossary-and-adrs.md). The [interview record](../research/agentic-planning-verification-notes.md) preserves the detailed decisions derived from [the original research](../research/optimizing-agentic-loop.md).
