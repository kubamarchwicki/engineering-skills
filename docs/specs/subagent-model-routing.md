# Centrally Governed Subagent Model Routing

## Problem Statement

Engineering Skills delegates implementation and review work to subagents, but its acceptance workflows do not currently provide a coherent way to choose among the models and reasoning levels available in Codex and Claude. Existing instructions use broad labels such as cheap, standard, or most capable; omit reasoning as an independent control; contain assumptions about inheritance and turn count that are not reliably supported; and cannot prove that a reviewer ran with enough capability to protect the Correctness Bar.

This leaves the user exposed to two opposite failures. A weak or automatically selected reviewer can approve incorrect work, while an unnecessarily expensive model can be used for a bounded task without improving the outcome. The problem is amplified by differences between harnesses: Codex and Claude discover custom agents differently, support different model families, and do not expose model selection and effective-configuration reporting through every dispatch surface.

The user needs one globally governed policy for the acceptance path, explicit provider mappings, auditable dispatch decisions, and a human-controlled way to adjust the policy. Local workflows must remain useful when an implementer cannot be pinned, but no unverified reviewer may make work Branch Ready.

## Solution

Introduce a versioned, provider-neutral Routing Policy owned by Subagent-Driven Development and consumed by Code Review. For every acceptance-relevant dispatch, the Controller assigns a qualitative Work Class, combines the work's floors with the subagent role's floors to obtain the Effective Floor, selects a pinned Provider Adapter profile that meets or exceeds both capability and reasoning, and writes a Dispatch Record.

The current version covers SDD implementers, fixers, task reviewers, and final review, plus Code Review's Standards and Spec axes. It uses pinned Codex and Claude model identifiers, explicit reasoning levels, read-only reviewer profiles, a finite set of named profiles, and Single-Agent dispatches by default. Provider profiles remain colocated with the owning Skill and are additionally exposed in each harness's custom-agent discovery location by the existing linker.

Explorers and implementers may proceed when their Effective Floor is unverified because they produce evidence or proposed changes. Acceptance reviewers fail closed unless their Effective Floor is verified. No runtime may silently substitute a configuration below the floor, prompt steering alone does not prove selection, and no local workflow may tune the global Routing Policy.

Policy Calibration is initiated by the user without an evidence threshold. A Critical or Important finding that escaped verified task review emits an explicit pending-calibration flag and preserves local evidence, but the current authorized branch continues through Exceptional/xhigh remediation, re-review, both final axes, and verification. An incorrect Branch Ready result or the absence of any compatible surface that can obtain a verified reviewer is an immediate hard stop. Inability of only the active runtime to verify a required reviewer fails closed before dispatch and names a compatible surface or configuration without itself forcing calibration. Manual Gear Shifts, final verification, stop-before-merge behavior, and the user's ownership of merge, sanity testing, and cleanup remain unchanged.

## User Stories

1. As a user, I want correctness to govern model routing, so that cost or latency never lowers an acceptance gate below the Correctness Bar.

2. As a user, I want capability and reasoning selected independently, so that narrow but subtle work can receive deep reasoning without conflating that need with broader model capability.

3. As a Controller, I want every dispatch to have a Capability Floor, so that the selected model is strong enough for the work's breadth, autonomy, and consequence.

4. As a Controller, I want every dispatch to have a Reasoning Floor, so that the selected model deliberates deeply enough for the task even when the task is small.

5. As a Controller, I want role floors and work floors composed independently, so that a reviewer cannot be weakened merely because the implementation looked mechanical.

6. As a Controller, I want to assign Work Classes without interrupting an already authorized Stage, so that SDD can remain continuous between task boundaries.

7. As a user, I want classification uncertainty to resolve upward, so that ambiguous routing decisions favor correctness.

8. As an implementer, I want Bounded Work recognized as exact, local, reversible, and strongly verified, so that a suitable fast model can handle it.

9. As an implementer, I want Integrated Work recognized as ordinary repository coordination, so that it receives a capable everyday model without automatic frontier escalation.

10. As a reviewer, I want security, authorization, privacy, secrets, data integrity, migrations, concurrency, ordering, public compatibility, cross-module invariants, weak verification, and novel architecture to force at least Demanding Work, so that apparent task size cannot hide consequential risk.

11. As a user, I want Exceptional Work to require a strict trigger, so that the strongest configurations are reserved for genuinely long-horizon, highest-consequence, repeatedly failing, or escaped-defect cases.

12. As a Controller, I want the Work Class to set an initial capability and reasoning pair, so that routing begins from a predictable policy rather than ad hoc preference.

13. As an SDD implementer, I want a Bounded/medium role baseline, so that write-capable work receives at least routine deliberation.

14. As an SDD task reviewer, I want an Integrated/high role baseline, so that independent task review is never assigned a merely mechanical configuration.

15. As a Code Review user, I want both Standards and Spec reviewers to use at least Demanding/high, so that the two acceptance axes share a simple, correctness-oriented baseline.

16. As a final-review user, I want whole-branch review to use at least Demanding/high, so that the branch cannot inherit a weak session configuration.

17. As a final reviewer, I want the branch Work Class recomputed from all task classes and cross-task interactions, so that migrations, accumulated findings, review escapes, and weak end-to-end verification can raise the final floor.

18. As a fixer, I want my Work Class to be no lower than both the original task and the finding, so that correcting a consequential defect never downgrades the configuration.

19. As a re-reviewer, I want my Effective Floor to be no lower than the reviewer that found the defect, so that a fix cannot pass through weaker scrutiny.

20. As a user, I want Codex Bounded Work mapped to 5.6 Luna, so that clear and repeatable implementation can use the appropriate current model.

21. As a user, I want Codex Integrated Work mapped to 5.6 Terra, so that ordinary engineering work uses the pragmatic all-rounder.

22. As a user, I want Codex Demanding and Exceptional Work mapped to 5.6 Sol, so that complex work uses the strongest current 5.6 model while reasoning distinguishes the two floors.

23. As a user, I want Claude Bounded and Integrated Work mapped to Sonnet, so that routine work uses the current balanced coding model.

24. As a user, I want Claude Demanding Work mapped to Opus, so that complex engineering judgment receives the stronger agentic model.

25. As a user, I want Claude Exceptional Work mapped to Fable, so that the highest-capability model is reserved for strict Exceptional triggers.

26. As a maintainer, I want full model identifiers pinned, so that model behavior does not change silently when a family alias moves between versions or providers.

27. As a maintainer, I want GPT-5.5 excluded, so that the Routing Policy has no ambiguous compatibility tier.

28. As a Controller, I want Max reasoning available only as an explicit escalation above xhigh, so that it is used for the hardest single-agent cases rather than as a routine default.

29. As a Controller, I want Ultra treated as a Dispatch Mode rather than ordinary reasoning, so that permission to delegate is visible and governed separately.

30. As an SDD user, I want implementers and fixers to remain Single-Agent, so that parallel writers cannot violate sequential task ownership.

31. As a Code Review user, I want v2 reviewer profiles to remain Single-Agent, so that the existing two-axis orchestration stays explicit and auditable.

32. As a user, I want Delegating mode allowed only for explicitly decomposable, read-only work, so that nested delegation cannot expand write authority or bypass workflow structure.

33. As a Controller, I want a finite set of named profiles covering baselines, reachable escalation steps, and strongest Single-Agent Max, so that the adapters remain explicit without a full model-by-effort-by-role Cartesian product.

34. As a Controller, I want the next available named profile that meets or exceeds both floors when an exact pair is absent, so that finite profiles never cause a downward substitution.

35. As a Codex user, I want Codex profiles exposed only through Codex agent discovery, so that Claude configuration is ignored by Codex.

36. As a Claude user, I want Claude profiles exposed only through Claude agent discovery, so that Codex configuration is ignored by Claude.

37. As a maintainer, I want both providers' profiles colocated inside the owning Skill, so that policy, prompts, and adapter definitions remain one reviewable package.

38. As a maintainer, I want explicit Codex and Claude profile files even when they repeat configuration, so that a generator or shared manifest does not obscure the installed behavior.

39. As a user, I want the linker to expose profiles to the harness-specific discovery directories, so that the globally linked Skill Set can enforce routing in repositories other than Engineering Skills.

40. As a user, I want the linker to refuse to replace real profile files, so that installing Engineering Skills cannot destroy my local custom agents.

41. As a user, I want repeated linking to be idempotent, so that updating or repairing the installation is safe.

42. As a Controller, I want a named profile selection or an effective runtime report before claiming Floor Verification, so that a requested configuration is not confused with the configuration that ran.

43. As a reviewer, I want prompt steering alone treated as unverified, so that natural-language routing hints cannot satisfy an acceptance gate.

44. As an implementer, I want to proceed with an unverified Effective Floor when the runtime cannot pin my profile, so that a limited surface can still produce a proposed change.

45. As a reviewer, I want the workflow to stop when my Effective Floor cannot be verified, so that an unsupported runtime cannot approve work under an unknown model.

46. As a user, I want an unverified implementer prevented from making work Branch Ready without verified independent review, so that fallback usefulness does not weaken acceptance.

47. As a user, I want unavailable pinned models substituted only by a reported configuration known to meet or exceed the floor, so that availability problems never cause silent downgrades.

48. As a user, I want a local override to raise floors or choose an allowed Dispatch Mode, so that I can demand more scrutiny for a particular task.

49. As a user, I want a local request below the Effective Floor barred from satisfying a gate, so that consuming workflows cannot weaken global policy.

50. As a reviewer, I want Review Independence based on fresh context, read-only authority, independent evidence, and an adversarial contract, so that independence does not depend on switching model families.

51. As a Controller, I want the Escalation Ladder to repair context before raising reasoning, raise reasoning before capability, split oversized work before forcing it, and return contradictory requirements to the user, so that model escalation addresses the actual cause of failure.

52. As a Controller, I want unchanged retries forbidden, so that a blocked subagent is not repeatedly dispatched without a meaningful intervention.

53. As a user, I want every acceptance-relevant dispatch represented by a Dispatch Record, so that routing and gate decisions are auditable.

54. As a user, I want Dispatch Records to include role, Work Class, Escalation Signals, Effective Floor, Dispatch Mode, requested configuration, effective configuration, and Floor Verification, so that the complete routing decision is inspectable.

55. As a user, I want correctness outcomes added to Dispatch Records, so that first-pass verdicts, Critical and Important findings, retries, escalation, and final verification can inform future judgment.

56. As a user, I want raw Dispatch Records stored locally per workspace and excluded from version control, so that they remain available without creating repository noise.

57. As a user, I want raw telemetry to exclude prompts, diffs, and source code, so that routing evidence does not become a second store of sensitive work.

58. As a user, I want no global telemetry aggregate or sample-size threshold, so that supervised workflows do not accumulate unnecessary cross-repository state.

59. As a user, I want to initiate Policy Calibration whenever I judge it necessary, so that global policy changes do not require a prescribed amount of evidence.

60. As a user, I want a Critical or Important escape to emit `POLICY_CALIBRATION_REQUIRED`, preserve its record identifiers, and force Exceptional/xhigh acceptance for the current branch without blocking its remediation, so that policy debt is visible without abandoning the authorized work.

61. As a user, I want an incorrect Branch Ready result or the absence of any compatible verified-review surface to hard-stop after in-flight work, so that unsafe acceptance cannot continue.

62. As a user, I want a calibration flag to produce a redacted handoff with relevant Dispatch Record identifiers, so that I can review the failure without copying prompts or code.

63. As a user, I want the handoff to direct me back to Engineering Skills and `$grill-with-docs`, so that policy adjustment is an explicit global Gear Shift.

64. As a user, I want consuming workflows prohibited from editing global routing policy, so that one review cannot silently retune every future workflow.

65. As a maintainer, I want the Routing Policy to have an explicit integer version, so that Dispatch Records and calibration handoffs identify the policy that governed them.

66. As a maintainer, I want policy-relevant changes to increment the version, so that floors, mappings, fallbacks, triggers, and profiles cannot change invisibly.

67. As a maintainer, I want imported-skill changes recorded as Rewirings in Provenance, so that upstream synchronization can distinguish deliberate routing behavior from drift.

68. As a user, I want model routing to remain inside the Stage I explicitly authorized, so that it cannot auto-chain workflow stages.

69. As a user, I want final verification and stop-before-merge behavior preserved, so that stronger models cannot assume ownership of merge, sanity testing, or cleanup.

70. As a user of a limited runtime, I want the workflow to name the missing compatible surface or configuration when review fails closed, so that the stop gives me an actionable next step.

## Implementation Decisions

- Correctness is the primary optimization objective. Cost and latency may distinguish configurations only after every candidate meets the Correctness Bar.

- The Routing Policy is provider-neutral, centrally governed, and explicitly versioned with an integer beginning at version 1. Any change to floors, mappings, role baselines, fallback rules, calibration triggers, or named profiles increments the version.

- Subagent-Driven Development owns the canonical Routing Policy reference. Code Review consumes the same reference rather than maintaining a second policy copy. No new Original Skill is introduced; `how` remains the only Original Skill in the Distributed Skill Set.

- V2 modifies only the acceptance path: SDD implementers, fixers, task reviewers, final review, and Code Review's Standards and Spec axes. Other active subagent sites remain unchanged.

- Work Class is qualitative rather than numeric. File count, line count, and a point score never determine the class by themselves.

- Bounded Work is exact, local, reversible, and supported by strong verification. Its work floors are Bounded capability and low reasoning.

- Integrated Work requires ordinary multi-file coordination or judgment about established repository patterns. Its work floors are Integrated capability and medium reasoning.

- Demanding Work includes ambiguity, broad interactions, high consequence, weak verification, or substantial novelty. Its work floors are Demanding capability and high reasoning.

- Exceptional Work is unusually long-horizon, highest-consequence, or still inadequate after repaired context and a stronger prior dispatch. Its work floors are Exceptional capability and xhigh reasoning.

- Security, authorization, privacy, secrets, data loss or corruption, schema migration, irreversible state, concurrency, distributed coordination, ordering guarantees, public compatibility, cross-module invariants, a weak or absent verification oracle, and novel architecture without an established pattern force at least Demanding Work.

- Long-horizon work spanning many subsystems that cannot safely be decomposed, a highest-consequence audit with weak verification and irreversible or external impact, failure after Demanding/xhigh with repaired context, and final review after a Critical or Important task-review escape force Exceptional Work.

- Classification uncertainty resolves upward and is recorded as an Escalation Signal.

- Capability Floor and Reasoning Floor are independent. Effective Floor takes the higher of the work and role floors separately on each axis.

- Implementers and fixers have a Bounded capability and medium reasoning Role Floor. SDD task reviewers have an Integrated capability and high reasoning Role Floor. Both Code Review axes and final whole-branch review have a Demanding capability and high reasoning Role Floor.

- The Controller assigns Work Classes and profiles automatically inside an authorized Stage. It does not request human approval for each routine dispatch.

- Final whole-branch review recomputes a branch Work Class from the highest task class plus cross-task interactions, migrations, repeated review escapes, accumulated Minor findings, and weak end-to-end verification.

- A fixer uses the higher of the original task class and the finding's class. Re-review uses an Effective Floor no lower than the reviewer that found the defect.

- Codex capability mapping uses `gpt-5.6-luna` for Bounded, `gpt-5.6-terra` for Integrated, and `gpt-5.6-sol` for Demanding and Exceptional. Exceptional is distinguished from Demanding through reasoning and scrutiny because Sol is the highest mapped Codex capability.

- Claude capability mapping uses `claude-sonnet-5` for Bounded and Integrated, `claude-opus-4-8` for Demanding, and `claude-fable-5` for Exceptional.

- GPT-5.5 is ignored and has no profile or fallback role.

- Reasoning mapping starts at low for Bounded, medium for Integrated, high for Demanding, and xhigh for Exceptional. Max is an explicit Single-Agent escalation above xhigh, not a default Work-Class floor.

- Ultra is modeled as Delegating Dispatch Mode because it changes execution topology in addition to reasoning. V2 automatically selects no Ultra profile. An explicit user request may use Delegating only for independently decomposable, read-only work; SDD implementers and fixers may never use it.

- Every v2 named profile is Single-Agent. Code Review retains its existing explicit parallelism between Standards and Spec; nested reviewer delegation is not automatic.

- Provider Adapters use full pinned model identifiers. Moving provider aliases are not used.

- Provider Adapter definitions are colocated inside the SDD Skill, separated into Codex-owned and Claude-owned directories. The definitions may repeat configuration explicitly; there is no generator or shared machine-readable manifest.

- The finite profile set covers every baseline Effective Floor, each next configuration reachable through the Escalation Ladder, and the strongest Single-Agent Max configuration. It does not contain the full Cartesian product. When an exact pair is absent, the Controller selects the next named profile that meets or exceeds both floors.

- Worker profiles are write-capable subject to the parent Stage's authority. Reviewer profiles are read-only and carry a review-focused contract. Parent runtime permissions remain authoritative and profiles never widen them.

- The existing linker continues to distribute whole Skill directories and additionally links the colocated Provider Adapter definitions into the harness-specific global custom-agent discovery directories. Codex receives only Codex profiles; Claude receives only Claude profiles.

- The linker remains idempotent, prunes only dead or stale symlinks it owns, and refuses to replace a real non-symlink skill or agent entry. Profile names use an Engineering Skills namespace to reduce collisions.

- Floor Verification requires either explicit named-profile selection through a surface that supports it or a trustworthy effective-configuration report showing capability and reasoning at or above the Effective Floor. Profile existence, prompt steering, assumed inheritance, and an unconfirmed request are insufficient.

- An unavailable pinned model may be replaced only by an explicitly reported configuration known to meet or exceed the floor. No downward substitution is automatic or silent.

- Explorers and implementers may run with an unverified Effective Floor, but their output remains evidence or a proposed change. Task review and final review fail closed without Floor Verification. An unverified implementer can never make work Branch Ready without verified independent review.

- If the active runtime cannot enforce or report a required reviewer floor, the workflow stops before dispatch and names a compatible surface or configuration. This active-runtime stop does not itself require Policy Calibration; the workflow may resume on compatible verified capacity. If no compatible surface or configuration can obtain the reviewer, the stop becomes a hard Policy Calibration Trigger.

- A local user override may raise capability, reasoning, or an allowlisted Dispatch Mode. A request below the Effective Floor may run only as unverified exploration or implementation and cannot satisfy an acceptance gate. Lowering a global floor requires Policy Calibration in Engineering Skills.

- Review Independence comes from fresh context, read-only authority, independent evidence, and an adversarial review contract. A reviewer need not use a different model family from the implementer.

- The Escalation Ladder repairs context, raises reasoning, raises capability, splits oversized work while preserving sequential write ownership, and finally returns contradictory requirements to the user. An unchanged retry is forbidden.

- Every acceptance-relevant implementer, fixer, and reviewer produces a Dispatch Record. The record contains policy version, role, Work Class, Escalation Signals, Effective Floor, Dispatch Mode, requested configuration, effective configuration, Floor Verification status, first-pass verdict, Critical and Important finding counts, retries, escalation, final verification, and available elapsed-time or usage metadata.

- Raw Dispatch Records use a self-ignored per-worktree JSON Lines log under the existing temporary-artifact hierarchy. They contain no prompt, diff, source code, or global repository aggregate.

- Policy Calibration is always human-controlled and may be initiated without an evidence threshold. Dispatch Records are optional evidence rather than authority to self-tune.

- A Critical or Important defect that escaped a verified task reviewer emits `POLICY_CALIBRATION_REQUIRED` as pending policy debt and preserves the relevant Dispatch Record identifiers. It does not hard-stop the current authorized branch. The Controller recomputes final review as Exceptional/xhigh, completes in-flight work, fixes, re-review, both final axes, and verification. If every gate passes, it may report Branch Ready together with the still-pending calibration requirement. No future SDD work may begin until the user resolves that calibration.

- A previously declared Branch Ready result later shown incorrect, or the absence of any compatible surface or configuration that can obtain a verified acceptance reviewer, is an immediate hard-stop Policy Calibration Trigger. The workflow waits for any in-flight subagent, preserves its result, then starts no new dispatch and makes no Branch Ready declaration.

- Every calibration flag supplies a redacted brief with policy version, trigger, outcome counts, and relevant Dispatch Record identifiers and names `$grill-with-docs` in the Engineering Skills repository as the next manual Gear Shift. A hard-stop trigger waits for the user immediately; pending escape debt waits before future SDD work after the current branch reaches its acceptance boundary.

- Consuming workflows may use the Escalation Ladder for the current task but never rewrite floors, mappings, thresholds, or profiles locally.

- Existing manual Tracks, Stage boundaries, final verification, Branch Ready semantics, and user ownership of merge, sanity testing, relinking, and cleanup remain unchanged.

- Changes to imported Skills are narrow Rewirings. Provenance records every changed imported Skill, and the generated README table is regenerated from Provenance rather than edited by hand.

## Testing Decisions

- Tests assert external behavior at two high seams: distribution through the real linker and routing through black-box SDD/Code Review scenarios. Tests do not assert Markdown paragraph layout or internal helper implementation.

- The distribution acceptance test runs the linker against a throwaway home directory twice. It verifies idempotent skill links, Codex-only profile discovery, Claude-only profile discovery, profile targets within the owning Skill, and absence of cross-harness profile exposure.

- Distribution tests create real colliding skill and agent entries and require the linker to preserve them, report the refusal, and return failure. They also create dead and stale repository-owned symlinks and require only those links to be pruned.

- Linker tests use a throwaway home exclusively. The real global installation is not changed during implementation verification, and the maintenance-worktree restriction remains in force.

- A black-box Bounded implementation scenario must produce Bounded/medium after applying the implementer Role Floor and select the corresponding pinned worker profile for each harness.

- A black-box Bounded task-review scenario must produce Integrated/high after applying the task-reviewer Role Floor.

- A black-box Code Review scenario must produce Demanding/high for both Standards and Spec axes, while preserving their separate prompts and parallel execution.

- Mandatory-signal scenarios cover authorization, data migration, concurrency, public compatibility, weak verification, and novel architecture. Each must classify as at least Demanding regardless of file count.

- Exceptional scenarios cover an unsafe-to-decompose long-horizon change, an irreversible highest-consequence audit with weak verification, failure after repaired Demanding/xhigh work, and a final-review escape. Each must classify as Exceptional.

- An ambiguous boundary scenario must choose the higher adjacent Work Class and record classification uncertainty as an Escalation Signal.

- A final-review scenario must recompute the branch class and raise it for cross-task interactions or review escapes rather than merely copying the largest task class.

- Fix and re-review scenarios must prove the monotonic rule: neither the fixer nor re-reviewer may be dispatched below the relevant prior floor.

- A runtime-without-profile-selection scenario must allow an implementer to proceed as unverified, record that status, and prevent the result from passing an acceptance gate.

- The same unsupported-runtime scenario must make a task reviewer or final reviewer stop with an actionable compatible-surface/configuration message.

- A prompt-only model request must remain unverified. An explicitly selected named profile or trustworthy effective-configuration report must satisfy verification when it meets the floor.

- An unavailable-model scenario must accept a reported equal-or-higher substitute and reject or stop on a lower substitute. No result may report the requested model as effective when substitution occurred.

- A local downward-override scenario may produce unverified implementation evidence but must not satisfy task review, final review, or Branch Ready. An upward override must be accepted when the profile and Dispatch Mode are supported.

- Escalation scenarios must prove the order context, reasoning, capability, split, human; an unchanged retry must be rejected.

- Max scenarios must require explicit escalation. No ordinary Work Class or role baseline selects Max, and no v2 scenario automatically selects Ultra.

- Dispatch Record tests validate required fields, policy version, requested/effective distinction, correctness outcomes, and omission of prompts, diffs, and source code.

- Calibration tests cover each boundary. Escape tests verify that in-flight results are collected, current-branch remediation and acceptance continue at Exceptional/xhigh, a passing branch may be reported Branch Ready with calibration still pending, and no future SDD work begins before calibration. Hard-stop tests verify that no next dispatch or Branch Ready declaration occurs. Every case verifies that the redacted brief identifies relevant records and names the Engineering Skills `$grill-with-docs` handoff.

- Calibration tests verify that no dispatch-count threshold, cross-repository aggregate, or self-tuning behavior exists.

- Provider-profile validation checks the exact pinned model identifiers, allowed reasoning values, read-only reviewer authority, Single-Agent v2 behavior, Engineering Skills namespace, and absence of GPT-5.5.

- Every changed shell script is syntax-checked under the repository's macOS Bash 3.2 portability rules.

- Repository close-out includes the whole-set reference sweep, seven-column Provenance validation, generated README idempotence after Provenance changes, comparison of imported directories against pinned upstream sources with Rewirings inspected separately, and an accurate final working-tree status.

- Already-running Codex and Claude sessions are treated as retaining their prior skill and profile snapshot. Manual post-merge sanity testing includes relinking from the primary checkout, restarting each harness, and confirming that a named worker and reviewer profile are discoverable where the surface supports custom-agent selection.

## Out of Scope

- Routing for Research, generic parallel debugging, architecture exploration, Design It Twice, or dormant plan-review prompts.

- A new Original model-routing Skill, plugin, marketplace package, or session-start bootstrap hook.

- Automatic policy learning, self-tuning, local policy mutation, or a global telemetry aggregate.

- Cost-minimizing routing, a numeric complexity score, or a required evidence sample before human Policy Calibration.

- Mandatory reviewer model-family diversity.

- GPT-5.5 profiles or fallback behavior.

- Moving model aliases or automatic adoption of newly released models.

- A full Cartesian product of capability, reasoning, role, and Dispatch Mode profiles.

- Automatic Ultra selection, nested write delegation, or parallel SDD implementers.

- Implementing a new model/effort/custom-agent selector in a harness whose spawn surface does not expose one.

- Treating prompt steering as proof of effective model selection.

- Persisting prompts, diffs, source code, or cross-repository identifiers in routing telemetry.

- Changing the Light or Heavy Track, automatic Gear Shifts, automatic merge, final sanity testing, or worktree cleanup ownership.

- Relinking the user's real global installation as part of implementation or from a maintenance worktree.

## Further Notes

- [ADR 0004](../adr/0004-use-centrally-governed-model-routing.md) records the architectural choice to centralize provider-neutral policy, duplicate pinned harness profiles, fail closed for unverified review, and keep calibration human-controlled.

- [The research note](../research/2026-07-14-subagent-model-selection.md) captures the first-party platform documentation and the original dispatch-site inventory. The decisions in this specification supersede its preliminary routing recommendations where they differ, notably no downward fallback, no sample-size calibration threshold, current Max/Ultra support, and exclusion of GPT-5.5.

- Model availability and supported reasoning values are time-sensitive. A pinned model retirement or provider-control change requires user-initiated Policy Calibration and a version increment; consuming workflows do not repair it locally.

- Current Codex and Claude clients can discover named custom agents from their harness-specific locations, but not every exposed `spawn_agent` surface allows the Controller to select or verify such a profile. That limitation is intentional input to the fail-closed review behavior, not something the Skill should conceal.

- The implementation must preserve the repository's documented upstream-maintenance model. New local files inside an Imported Skill and every changed upstream file are lasting Divergences unless later adopted upstream, so their purpose must remain explicit in Provenance.
