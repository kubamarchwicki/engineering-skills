# Subagent Model Routing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development to implement this plan task-by-task.

**Goal:** Add a versioned, correctness-first policy that chooses and verifies the minimum effective model capability and reasoning effort for implementation and review subagents in `subagent-driven-development` and `code-review`.

**Architecture:** `subagent-driven-development` owns one provider-neutral Routing Policy, black-box evaluation cases, duplicated Codex and Claude agent profiles, and local dispatch records. `code-review` consumes the same policy. The existing linker exposes provider-specific profiles in each harness's native agent directory while preserving the flat skill distribution. Markdown remains the routing authority; shell code validates the shipped contract, appends redacted JSONL records, and links profiles, but does not become a second routing engine.

**Tech Stack:** Markdown agent skills, Codex TOML agent definitions, Claude Markdown agent definitions, portable Bash 3.2, TSV provenance, Git.

## Global Constraints

- Preserve both manual tracks and every manual stage boundary. This plan changes dispatches inside `subagent-driven-development` and `code-review`; it does not auto-chain stages, merge, push, clean worktrees, or touch unrelated skills.
- Treat `docs/specs/subagent-model-routing.md` and `docs/adr/0004-use-centrally-governed-model-routing.md` as requirements. If this plan conflicts with either, stop and repair the plan before implementation.
- Keep Routing Policy Version `2` and only the provider mappings explicitly approved in the spec.
- Correctness is the primary objective. Cost and latency choose only among configurations that meet the Effective Floor.
- Keep the two axes independent: capability is `Bounded < Integrated < Demanding < Exceptional`; reasoning is `low < medium < high < xhigh < max`.
- Use `Demanding` for both `code-review` axes. Review independence requires fresh context, read-only authority, and adversarial instructions; it does not require a different provider or model family.
- `Ultra` is a delegating Dispatch Mode, not a reasoning-effort rung. Version 2 must not select it automatically and must never use it for write-capable SDD workers. `max` is the strongest Single-Agent reasoning profile.
- Explorers and implementers may proceed with an unverified Effective Floor because their output remains gated. Task reviewers and both final-review axis reviewers require a verified Effective Floor and fail closed when it cannot be verified. An unverified implementer can never make work Branch Ready without verified independent review.
- A Critical or Important finding that escaped verified task review emits `POLICY_CALIBRATION_REQUIRED` as pending policy debt but does not hard-stop the current authorized branch. Recompute Exceptional/xhigh, complete its remediation and acceptance gates, and if they pass report Branch Ready with calibration still pending; begin no future SDD work until the user resolves it. An incorrect Branch Ready result or the absence of any compatible verified-review surface is an immediate hard-stop trigger after in-flight work. Inability of only the active runtime to verify a reviewer stops before dispatch and names compatible capacity without itself forcing calibration. Never patch policy opportunistically from inside a consuming workflow.
- Keep raw dispatch records local to each worktree at `.superpowers/model-routing/dispatches.jsonl`. Never record prompts, diffs, source code, secrets, or credentials. There is no global aggregate and no minimum dispatch-count threshold for human calibration.
- Do not create a generator or shared provider manifest. The Codex and Claude profiles intentionally repeat their configuration.
- Do not edit either upstream submodule. Record every local rewire in `provenance.tsv` and regenerate the README table.
- All shell must run on macOS `/bin/bash` 3.2 with `#!/usr/bin/env bash` and `set -euo pipefail`. Avoid associative arrays, `${var,,}`, and GNU-only options.
- Use `apply_patch` for repository edits. Preserve unrelated working-tree changes. Run each task's checks, obtain its SDD task review, and make its exact commit before advancing.
- Never run the real linker during implementation. Test it only with a throwaway `HOME`; the user may relink from the primary checkout after merging.

---

## File Structure

- Create `skills/subagent-driven-development/model-routing.md`: canonical provider-neutral policy, profile-selection rules, gates, escalation, telemetry, and calibration behavior.
- Create `skills/subagent-driven-development/model-routing-evals.md`: representative black-box inputs and exact observable decisions.
- Create `skills/subagent-driven-development/agents/codex/*.toml`: fourteen explicit Codex profiles.
- Create `skills/subagent-driven-development/agents/claude/*.md`: fourteen explicit Claude profiles.
- Modify `skills/subagent-driven-development/SKILL.md`: make the Controller classify, select, verify, record, escalate, and stop according to the policy.
- Modify `skills/subagent-driven-development/implementer-prompt.md`: pass the Work Class, Effective Floor, selected profile, and verification state into workers.
- Modify `skills/subagent-driven-development/task-reviewer-prompt.md`: require a verified reviewer floor and independent read-only review.
- Create `skills/subagent-driven-development/scripts/record-dispatch`: append one safe JSONL event in the worktree-local routing directory.
- Modify `skills/code-review/SKILL.md`: apply the same policy to both review axes and fail closed without verified reviewer capacity.
- Create `scripts/check-model-routing.sh`: structural and behavioral contract checks without duplicating the routing algorithm.
- Modify `scripts/link-skills.sh`: expose provider profiles in `~/.codex/agents` and `~/.claude/agents`, protect real entries, and prune only repository-owned stale profile links.
- Modify `provenance.tsv` and `README.md`: record the two local rewires and document profile installation.
- Include the already-reviewed `CONTEXT.md`, research note, ADR, spec, and this plan in the first task commit so the implementation proceeds from a stable design baseline.

## Task 1: Freeze the Design and Add the Canonical Routing Policy

**Files:**

- Create: `skills/subagent-driven-development/model-routing.md`
- Create: `skills/subagent-driven-development/model-routing-evals.md`
- Include without rewriting: `CONTEXT.md`
- Include without rewriting: `docs/research/2026-07-14-subagent-model-selection.md`
- Include without rewriting: `docs/adr/0004-use-centrally-governed-model-routing.md`
- Include without rewriting: `docs/specs/subagent-model-routing.md`
- Include without rewriting: `docs/plans/0003-subagent-model-routing.md`

### Step 1: Write the black-box evaluations before the policy

Create `skills/subagent-driven-development/model-routing-evals.md` with the exact content specified in Step 4 below. Write this file before `model-routing.md`; these scenarios are the acceptance contract, not assertions about Markdown layout.

### Step 2: Confirm the current generic instructions fail representative cases

Give a fresh read-only Controller only the current pre-change `skills/subagent-driven-development/SKILL.md` plus, one at a time, these Input blocks from `model-routing-evals.md`:

- `Bounded task-review role floor`
- `Code Review axes baseline`
- `Unverified reviewer fails closed`

Use this evaluation instruction:

```text
Return Work Class, Escalation Signals, Effective Floor, Profile, Dispatch Mode,
Floor Verification, Action, and Record or Calibration behavior. Do not mutate
files and do not read any Expected block.
```

Expected RED evidence: the current generic model-selection prose cannot produce all pinned capability/reasoning pairs, named profiles, verification gates, records, or calibration behavior. Record which required fields are missing or incorrect in the task report. Do not edit the old SDD instructions merely to improve this RED run.

### Step 3: Write the canonical Routing Policy

Create `skills/subagent-driven-development/model-routing.md` with this exact content:

````markdown
# Subagent Model Routing Policy

**Routing Policy Version: 2**

This policy chooses the minimum configuration that can meet the correctness bar for an engineering dispatch. Cost and latency break ties only after the Effective Floor is satisfied. Any change to floors, mappings, role baselines, fallback rules, calibration triggers, or the named profile set increments the integer policy version.

## Controller procedure

Before every dispatch:

1. Classify the work from evidence in the brief, repository, diff, and prior results.
2. Read the role floor.
3. Compute the Effective Floor by taking the higher capability and higher reasoning effort independently.
4. Choose the first named profile whose configuration meets or exceeds both axes.
5. Verify the effective model and effort when the dispatch is a task-review or final-review gate.
6. Append a redacted `started` Dispatch Record, run the dispatch, then append its `completed` record.
7. Recompute classification after material new evidence. Never silently move either axis downward.

Routine classification and profile selection are automatic inside the Stage the user already authorized; do not ask for per-dispatch approval. Work Class is qualitative: file count, line count, and numeric scoring never determine it by themselves. If classification is ambiguous, resolve upward and record `classification uncertainty` as an Escalation Signal. Prompt wording is not proof that a floor was enforced.

## Work Class

Capability order: `Bounded < Integrated < Demanding < Exceptional`.

| Work Class | Capability floor | Reasoning floor | Use when |
|---|---|---|---|
| Bounded | Bounded | low | The change is local, reversible, well specified, and covered by a strong oracle. |
| Integrated | Integrated | medium | The change crosses files or ordinary module seams but has established patterns and useful tests. |
| Demanding | Demanding | high | Any mandatory Demanding signal applies, or the change requires broad invariants and substantial synthesis. |
| Exceptional | Exceptional | xhigh | An Exceptional signal applies and decomposition cannot safely reduce it. |

Mandatory Demanding signals are security, authentication, authorization, privacy, or secrets; data loss, corruption, migration, or irreversible state; concurrency, distributed behavior, or ordering; public compatibility or cross-module invariants; a weak oracle; or novel architecture.

Exceptional signals are an unsafe-to-decompose long reasoning horizon; highest-consequence work combined with a weak oracle and irreversible or external effects; failure after repaired context at Demanding/xhigh; or final review after a Critical or Important finding escaped task review.

## Role floors

| Role | Capability floor | Reasoning floor | Gate semantics |
|---|---|---|---|
| implementer or fixer | Bounded | medium | May propose work with an unverified floor; cannot make it Branch Ready. |
| SDD task reviewer | Integrated | high | Must be verified and independent. |
| code-review Standards reviewer | Demanding | high | Must be verified and independent. |
| code-review Spec reviewer | Demanding | high | Must be verified and independent. |
| final-review Standards or Spec reviewer | Demanding | high | Must be verified; the SDD controller recomputes branch risk and owns axis orchestration. |

Compute the Effective Floor as `max(work capability, role capability)` and `max(work reasoning, role reasoning)`. Capability and reasoning never compensate for one another.

Fix Work Class is the higher of the original Work Class and the finding's Work Class. Re-review must use a floor no lower than the reviewer that found the issue.

## Provider mapping

| Capability | Codex model | Claude model |
|---|---|---|
| Bounded | `gpt-5.6-luna` | `claude-sonnet-5` |
| Integrated | `gpt-5.6-terra` | `claude-sonnet-5` |
| Demanding | `gpt-5.6-sol` | `claude-opus-4-8` |
| Exceptional | `gpt-5.6-sol` | `claude-fable-5` |

Reasoning order is `low < medium < high < xhigh < max`. The shipped finite profile set starts at each role floor, includes every reachable reasoning-first and capability-next escalation, and ends at the strongest Single-Agent profile.

## Named profiles

### Write-capable workers

| Effective Floor | Profile |
|---|---|
| Bounded/medium | `engineering-worker-bounded-medium` |
| Bounded/high | `engineering-worker-bounded-high` |
| Integrated/medium | `engineering-worker-integrated-medium` |
| Integrated/high | `engineering-worker-integrated-high` |
| Demanding/high | `engineering-worker-demanding-high` |
| Demanding/xhigh | `engineering-worker-demanding-xhigh` |
| Exceptional/xhigh | `engineering-worker-exceptional-xhigh` |
| Exceptional/max | `engineering-worker-exceptional-max` |

### Read-only reviewers

| Effective Floor | Profile |
|---|---|
| Integrated/high | `engineering-reviewer-integrated-high` |
| Integrated/xhigh | `engineering-reviewer-integrated-xhigh` |
| Demanding/high | `engineering-reviewer-demanding-high` |
| Demanding/xhigh | `engineering-reviewer-demanding-xhigh` |
| Exceptional/xhigh | `engineering-reviewer-exceptional-xhigh` |
| Exceptional/max | `engineering-reviewer-exceptional-max` |

When an exact pair is absent, select the next available profile that meets or exceeds both floors. Escalate reasoning before capability when both choices meet the floor. Do not construct configurations outside this finite set.

## Dispatch Mode and Ultra

Every shipped profile is `Single-Agent`. `max` is Single-Agent reasoning. `Ultra` is a separate `Delegating` Dispatch Mode and is not a reasoning rung.

Version 2 never selects Ultra automatically. An explicit user instruction may allow Delegating only for read-only, safely decomposable work. Never give a Delegating profile write authority and never use it for an SDD implementer or fixer. Code Review may launch its two Single-Agent axes in parallel; that controller-owned parallelism is not Ultra or nested delegation.

## Floor Verification and fallback

A floor is `verified` only when either:

- a named profile was selected and no known higher-precedence setting can lower its model or effort; or
- the runtime reports the effective model and effort and both meet the Effective Floor.

Profile existence without selection, prompt steering, an agent's self-description, and a requested-but-unreported configuration are `unverified`.

Explorers, implementers, and fixers may run unverified because their output remains a proposal behind verified gates. Mark their record `unverified`. A task reviewer or either final-review axis reviewer must be verified before dispatch. If the active surface cannot enforce or report the floor, stop before dispatch and name a compatible surface or configuration. This active-surface stop does not itself require Policy Calibration; resume only on compatible verified capacity. If no compatible surface or configuration can obtain the required reviewer, emit the hard-stop calibration trigger below. Never silently substitute downward. A reported substitute is acceptable only when it meets or exceeds both axes.

Provider-wide or invocation-wide overrides take precedence over profile declarations. Inspect them when visible. Parent permissions remain authoritative: a profile never widens the Stage's authority. A repository-local override may raise a gate to compliance; it may never lower a global floor. A downward request may run only as unverified exploration or implementation and cannot satisfy task review, final review, or Branch Ready.

## Escalation Ladder

Never repeat an unchanged failed dispatch. Escalate in this order:

1. Repair missing or noisy context.
2. Raise reasoning effort.
3. Raise capability.
4. Split the task when the split preserves correctness.
5. Ask a human when the preceding steps cannot produce a trustworthy result.

Record the signal and transition. Exceptional work that remains unsafe to decompose stays Exceptional.

## Independent review and Branch Ready

Reviewers receive fresh context, read-only authority, and adversarial review instructions. They need not use a different provider or model family from the implementer.

Task review checks its assigned task. For final review, the SDD controller recomputes Work Class from the highest task class plus cross-task interactions, migrations, repeated review escapes, accumulated Minor findings, and weak end-to-end verification, then invokes the `code-review` workflow directly. The controller dispatches its verified Standards and Spec reviewers; neither reviewer orchestrates or spawns the other. An unverified worker result can become Branch Ready only after verified independent task review and both required final-review axes. Never declare Branch Ready while a required gate is missing, unverified, or below its floor.

## Dispatch Records

Append JSON Lines events to `.superpowers/model-routing/dispatches.jsonl` through `scripts/record-dispatch`. Use one `started` and one `completed` event for each actual dispatch. Use the same `dispatch_id` for both.

Each event contains:

- `policy_version`, `event`, `dispatch_id`, `role`, `work_class`, and `escalation_signals`;
- `effective_floor` with capability and reasoning;
- `dispatch_mode`;
- `requested` profile, model, and effort;
- `effective` model and effort when known;
- `floor_verification` status and concise evidence;
- `outcome` with first-pass result, Critical and Important counts, retry count, escalation, final verification, elapsed time, and usage when available.

Use `null` when elapsed time or usage is unavailable. Do not include prompts, diffs, source code, secrets, credentials, or personal data. The directory self-ignores its contents. Records remain local to the worktree; do not aggregate or commit them.

Example started event:

```json
{"policy_version":2,"event":"started","dispatch_id":"task-3-review-1","role":"task-reviewer","work_class":"Integrated","escalation_signals":[],"effective_floor":{"capability":"Integrated","reasoning":"high"},"dispatch_mode":"Single-Agent","requested":{"profile":"engineering-reviewer-integrated-high","model":"gpt-5.6-terra","effort":"high"},"effective":{"model":"gpt-5.6-terra","effort":"high"},"floor_verification":{"status":"verified","evidence":"named profile selected with no lowering override"},"outcome":{"first_pass":"pending","critical":0,"important":0,"retries":0,"escalation":"none","final_verification":"pending","elapsed":null,"usage":null}}
```

## Policy Calibration

Only a human changes policy-wide floors, mappings, profiles, or classification signals. The operator may calibrate at any time and does not need a minimum sample or additional evidence.

A Critical or Important finding that escaped verified task review is pending policy debt. Emit:

```text
POLICY_CALIBRATION_REQUIRED
```

Preserve the relevant record identifiers and give a redacted brief with policy version, trigger, outcome counts, observed failure, current policy decision, and proposed question. Do not hard-stop the current authorized branch: recompute final review as Exceptional/xhigh, finish in-flight work, and complete its fixes, re-review, both final axes, and verification. If all gates pass, Branch Ready may be reported together with the still-pending calibration requirement. Do not begin future SDD work until the human resolves calibration through `$grill-with-docs` in the `engineering-skills` repository. Do not adjust the policy opportunistically inside the consuming workflow.

A previously declared Branch Ready result later shown incorrect, or the absence of any compatible surface or configuration that can obtain a verified required reviewer, is an immediate hard-stop calibration trigger. Finish already-running dispatches, preserve their results, emit `POLICY_CALIBRATION_REQUIRED` with the same redacted brief and next manual gear, start no new dispatch, make no Branch Ready declaration, and wait for the human.
````

### Step 4: Add black-box policy evaluations

The file was created first in Step 1. Its exact content is:

```markdown
# Model Routing Black-Box Evaluations

Use these cases after a policy, workflow, or adapter change. Give a fresh Controller only the owning workflow, its linked Routing Policy, and one Input block. Do not provide the Expected block until after it answers. It must return `Work Class`, `Escalation Signals`, `Effective Floor`, `Profile`, `Dispatch Mode`, `Floor Verification`, `Action`, and `Record or Calibration`. Compare meaning, not punctuation. These are instruction evaluations, not an executable routing engine.

Run provider-mapping cases once with Codex available and once with Claude available. A semantic profile name is shared by both harnesses; the requested model must come from that harness's native profile.

## Bounded worker baseline

Input: An implementer changes one local error message. The change is exact, local, reversible, and covered by a focused test. The runtime reports the named profile exactly.

Expected: Work Class `Bounded`; no Escalation Signal; Effective Floor `Bounded/medium`; profile `engineering-worker-bounded-medium`; Single-Agent; verified; dispatch. Codex requests `gpt-5.6-luna`/medium and Claude requests `claude-sonnet-5`/medium. Append started and completed records.

## Bounded task-review role floor

Input: A task reviewer checks the same local error-message task. No higher work signal exists. The runtime reports the named profile exactly.

Expected: Work Class `Bounded`; Effective Floor `Integrated/high`; profile `engineering-reviewer-integrated-high`; Single-Agent; verified; dispatch read-only with fresh context. Codex requests `gpt-5.6-terra`/high and Claude requests `claude-sonnet-5`/high.

## Code Review axes baseline

Input: Code Review examines a small, strongly tested branch with both a spec and repository standards. Neither axis has an Exceptional signal.

Expected: Standards and Spec each use Work Class `Bounded` with Effective Floor `Demanding/high`; both select `engineering-reviewer-demanding-high`; both are verified, read-only Single-Agent dispatches; the Controller launches the two axes in parallel with separate prompts and records. Codex requests `gpt-5.6-sol`/high and Claude requests `claude-opus-4-8`/high.

## Authorization forces Demanding

Input: A one-file implementer change modifies authorization checks and has focused tests.

Expected: Work Class `Demanding` regardless of size; signal `authorization`; Effective Floor `Demanding/high`; `engineering-worker-demanding-high`; dispatch and record the signal.

## Data migration forces Demanding

Input: A two-line change alters a persisted-data migration that can corrupt existing records.

Expected: Work Class at least `Demanding`; signals include migration and data integrity; never route as Bounded or Integrated.

## Concurrency forces Demanding

Input: A local-looking change alters lock acquisition order in shared code.

Expected: Work Class at least `Demanding`; signal `concurrency or ordering`; Effective Floor at least `Demanding/high`.

## Public compatibility forces Demanding

Input: A one-file change alters a public function contract used across modules.

Expected: Work Class at least `Demanding`; signals include public compatibility and cross-module invariant; file count does not lower it.

## Weak verification forces Demanding

Input: A narrow behavior change has no trustworthy automated or manual oracle.

Expected: Work Class at least `Demanding`; signal `weak verification oracle`; never route from apparent code size alone.

## Novel architecture forces Demanding

Input: An implementer introduces an architectural seam with no established repository pattern.

Expected: Work Class at least `Demanding`; signal `novel architecture`; route to a Demanding/high worker or higher.

## Ambiguity resolves upward

Input: A cross-module cache change might affect request ordering, but repository evidence cannot rule the effect out.

Expected: choose the higher adjacent class, at least `Demanding`; record `classification uncertainty` as an Escalation Signal; never Integrated.

## Unsafe long horizon is Exceptional

Input: A change spans many subsystems, requires a long reasoning horizon, and cannot be decomposed without breaking a correctness invariant.

Expected: Work Class `Exceptional`; Effective Floor `Exceptional/xhigh`; `engineering-worker-exceptional-xhigh`; do not force an unsafe split.

## Highest-consequence irreversible audit is Exceptional

Input: A final-review axis reviewer evaluates an irreversible external migration with the highest consequence and no trustworthy automated oracle. The SDD controller owns the two-axis orchestration.

Expected: Work Class `Exceptional`; signals include irreversible external effect, highest consequence, and weak oracle; Effective Floor `Exceptional/xhigh`; `engineering-reviewer-exceptional-xhigh`; verify before dispatch.

## Repaired Demanding xhigh failure is Exceptional

Input: A Demanding/xhigh worker failed after the Controller repaired its missing context. The task cannot safely be split.

Expected: raise Work Class to `Exceptional`; Effective Floor `Exceptional/xhigh`; select the Exceptional worker; do not issue an unchanged retry.

## Final-review escape is Exceptional

Input: Final review begins after a Critical finding escaped a verified task review.

Expected: emit `POLICY_CALIBRATION_REQUIRED` and preserve the escaped-review record IDs, but treat it as pending policy debt rather than a hard stop for this branch. Recompute final Work Class `Exceptional`; use verified Exceptional/xhigh reviewers; finish in-flight review, fixes, re-review, both final axes, and verification. If every gate passes, report Branch Ready together with the pending calibration requirement. Start no future SDD work until the human resolves calibration through `$grill-with-docs`; never patch policy opportunistically in this workflow.

## Final review recomputes branch risk

Input: Every task was Integrated, but the completed branch creates a public compatibility invariant across modules and end-to-end verification is weak.

Expected: recompute rather than copy the largest task class; final Work Class at least `Demanding`; signals include cross-task public compatibility and weak end-to-end verification; Effective Floor at least `Demanding/high`; verified reviewer before dispatch.

## Fix and re-review stay monotonic

Input: An Integrated task receives a Demanding finding from a Demanding/xhigh reviewer.

Expected: Fix Work Class `Demanding`; fixer at least `engineering-worker-demanding-high`; re-review no lower than `engineering-reviewer-demanding-xhigh`; record both transitions.

## Unverified implementer may propose

Input: A Bounded implementer can be prompted with the requested model but the runtime cannot enforce or report it.

Expected: Effective Floor `Bounded/medium`; request `engineering-worker-bounded-medium`; Floor Verification `unverified`; dispatch may proceed as a proposal and record unverified status, but cannot satisfy an acceptance gate or make work Branch Ready.

## Unverified reviewer fails closed

Input: A task reviewer is required, but the runtime cannot enforce or report its model and effort.

Expected: Effective Floor at least `Integrated/high`; no reviewer dispatch; name a compatible surface or configuration and resume only there with verified capacity. Do not emit `POLICY_CALIBRATION_REQUIRED` merely because the active runtime is limited. Emit the hard-stop calibration trigger only if no compatible surface or configuration can obtain the verified reviewer.

## Prompt steering differs from named selection

Input: Attempt A asks in prose for a Demanding/high reviewer. Attempt B explicitly selects its named profile and no higher-precedence override is present.

Expected: Attempt A is unverified and cannot dispatch a gate reviewer. Attempt B is verified when the profile configuration meets the floor. The record distinguishes requested from effective configuration.

## Reported substitution is floor checked

Input: A pinned Demanding/high reviewer is unavailable. Runtime A reports an Exceptional/xhigh substitute. Runtime B reports an Integrated/high substitute.

Expected: Runtime A is accepted because both axes meet or exceed the floor and the effective fields record the substitute. Runtime B is rejected; never report the requested configuration as effective.

## Local overrides cannot lower a gate

Input: A user requests low reasoning for a Demanding task review, then separately requests xhigh for the same review.

Expected: the low request cannot satisfy the gate and may only be unverified non-gating work; the xhigh request is accepted when its named profile and Single-Agent mode are supported.

## Escalation order and unchanged retry

Input: A worker fails first from missing context, then after repaired context from insufficient reasoning, then after raised reasoning from insufficient breadth, then reveals a safe split, and finally exposes contradictory requirements.

Expected: transitions are context repair, reasoning increase, capability increase, safe split, then human; every transition is recorded; an unchanged retry is rejected.

## Max remains Single-Agent

Input: Exceptional/xhigh failed after context repair. The next attempt raises reasoning without explicit user authorization to delegate.

Expected: select `engineering-worker-exceptional-max` or `engineering-reviewer-exceptional-max` according to role; Dispatch Mode `Single-Agent`; no ordinary class starts at Max and the Controller never selects Ultra automatically.

## Dispatch Record is complete and redacted

Input: A verified Demanding reviewer returns one Critical and two Important findings after one escalation. Elapsed time is available; usage is not.

Expected: append matching started and completed JSONL events with policy version, role, class, signals, floor, mode, requested and effective configuration, verification evidence, first-pass result, counts `1` and `2`, retry/escalation, final verification, elapsed value, and null usage. Include no prompt, diff, source code, secret, credential, or personal data.

## Escaped finding calibration waits for in-flight work

Input: One parallel review axis is still running when its peer reports a Critical finding that escaped verified task review.

Expected: let the in-flight peer finish and preserve its result; emit `POLICY_CALIBRATION_REQUIRED` with a redacted brief containing policy version, trigger, outcome counts, and relevant record IDs. Treat the escape as pending policy debt: recompute Exceptional/xhigh, complete current-branch fixes, re-review, both final axes, and verification. If all gates pass, report Branch Ready together with the pending calibration requirement. Name `$grill-with-docs` and start no future SDD work until calibration is resolved.

## Incorrect Branch Ready calibrates

Input: Evidence shows that a previously declared Branch Ready result was incorrect.

Expected: emit `POLICY_CALIBRATION_REQUIRED`, preserve local evidence, provide the redacted handoff, and stop before another dispatch or readiness claim. Do not patch policy locally.

## Human calibration has no evidence threshold

Input: The operator decides to adjust global calibration after one supervised dispatch and supplies no additional evidence.

Expected: accept the human decision without a dispatch-count prerequisite or global aggregate; stop the consuming workflow, name `$grill-with-docs` in `engineering-skills`, and wait. Never self-tune.
```

Give a fresh read-only Controller only `model-routing.md` and one Input block at a time, using the Step 2 evaluation instruction. Run every case, including each provider variant stated by the case. Expected GREEN evidence: every result agrees with its Expected block. Store only the field-level pass/fail summary in the task report; do not turn the cases into a second routing implementation.

### Step 5: Inspect the design baseline

Run:

```bash
git diff --check
git diff -- CONTEXT.md docs/research/2026-07-14-subagent-model-selection.md docs/adr/0004-use-centrally-governed-model-routing.md docs/specs/subagent-model-routing.md docs/plans/0003-subagent-model-routing.md skills/subagent-driven-development/model-routing.md skills/subagent-driven-development/model-routing-evals.md
```

Expected:

- `git diff --check` prints nothing.
- The diff contains the already-reviewed design artifacts plus only the policy, evaluations, and plan introduced by this task.

### Step 6: Commit the stable design baseline

```bash
git add CONTEXT.md docs/research/2026-07-14-subagent-model-selection.md docs/adr/0004-use-centrally-governed-model-routing.md docs/specs/subagent-model-routing.md docs/plans/0003-subagent-model-routing.md skills/subagent-driven-development/model-routing.md skills/subagent-driven-development/model-routing-evals.md
git commit -m "feat: define subagent model routing policy"
```

## Task 2: Add the Codex Agent Profiles

**Files:**

- Create: `skills/subagent-driven-development/agents/codex/engineering-worker-bounded-medium.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-worker-bounded-high.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-worker-integrated-medium.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-worker-integrated-high.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-worker-demanding-high.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-worker-demanding-xhigh.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-worker-exceptional-xhigh.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-worker-exceptional-max.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-reviewer-integrated-high.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-reviewer-integrated-xhigh.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-reviewer-demanding-high.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-reviewer-demanding-xhigh.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-reviewer-exceptional-xhigh.toml`
- Create: `skills/subagent-driven-development/agents/codex/engineering-reviewer-exceptional-max.toml`
- Create: `scripts/check-model-routing.sh`

### Step 1: Write the Codex adapter check before adding profiles

Create `scripts/check-model-routing.sh` with this exact content. This validates the external provider-profile contract; it does not assert Markdown paragraph layout or implement routing decisions.

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
status=0

fail() {
  printf 'check-model-routing: %s\n' "$1" >&2
  status=1
}

require_file() {
  if [ ! -f "$1" ]; then
    fail "missing file: ${1#$repo_root/}"
  fi
}

require_text() {
  file=$1
  text=$2
  if ! grep -Fq -- "$text" "$file"; then
    fail "${file#$repo_root/}: missing required adapter field: $text"
  fi
}

codex_dir="$repo_root/skills/subagent-driven-development/agents/codex"

check_codex_profile() {
  name=$1
  model=$2
  effort=$3
  sandbox=$4
  file="$codex_dir/$name.toml"
  require_file "$file"
  if [ -f "$file" ]; then
    require_text "$file" "name = \"$name\""
    require_text "$file" "model = \"$model\""
    require_text "$file" "model_reasoning_effort = \"$effort\""
    require_text "$file" "sandbox_mode = \"$sandbox\""
    if [ "$sandbox" = workspace-write ]; then
      require_text "$file" 'Do not spawn subagents.'
    else
      require_text "$file" 'Do not mutate files and do not spawn subagents.'
    fi
  fi
}

check_codex_profile engineering-worker-bounded-medium gpt-5.6-luna medium workspace-write
check_codex_profile engineering-worker-bounded-high gpt-5.6-luna high workspace-write
check_codex_profile engineering-worker-integrated-medium gpt-5.6-terra medium workspace-write
check_codex_profile engineering-worker-integrated-high gpt-5.6-terra high workspace-write
check_codex_profile engineering-worker-demanding-high gpt-5.6-sol high workspace-write
check_codex_profile engineering-worker-demanding-xhigh gpt-5.6-sol xhigh workspace-write
check_codex_profile engineering-worker-exceptional-xhigh gpt-5.6-sol xhigh workspace-write
check_codex_profile engineering-worker-exceptional-max gpt-5.6-sol max workspace-write
check_codex_profile engineering-reviewer-integrated-high gpt-5.6-terra high read-only
check_codex_profile engineering-reviewer-integrated-xhigh gpt-5.6-terra xhigh read-only
check_codex_profile engineering-reviewer-demanding-high gpt-5.6-sol high read-only
check_codex_profile engineering-reviewer-demanding-xhigh gpt-5.6-sol xhigh read-only
check_codex_profile engineering-reviewer-exceptional-xhigh gpt-5.6-sol xhigh read-only
check_codex_profile engineering-reviewer-exceptional-max gpt-5.6-sol max read-only

if [ -d "$codex_dir" ]; then
  codex_count=$(find "$codex_dir" -type f -name '*.toml' | wc -l | tr -d ' ')
  if [ "$codex_count" != 14 ]; then
    fail "expected 14 Codex profiles, found $codex_count"
  fi
  codex_model_count=$(grep -h '^model = ' "$codex_dir"/*.toml | wc -l | tr -d ' ')
  codex_effort_count=$(grep -h '^model_reasoning_effort = ' "$codex_dir"/*.toml | wc -l | tr -d ' ')
  if [ "$codex_model_count" != 14 ] || [ "$codex_effort_count" != 14 ]; then
    fail 'each Codex profile must declare exactly one pinned model and effort'
  fi
fi

if [ "$status" -ne 0 ]; then
  exit 1
fi

printf 'check-model-routing: clean\n'
```

Make it executable:

```bash
chmod +x scripts/check-model-routing.sh
```

Run:

```bash
scripts/check-model-routing.sh
```

Expected: exit status `1` and fourteen `missing file` diagnostics under `agents/codex/`.

### Step 2: Create the eight write-capable Codex worker profiles

Create each file with the exact content shown.

`skills/subagent-driven-development/agents/codex/engineering-worker-bounded-medium.toml`:

```toml
name = "engineering-worker-bounded-medium"
description = "Write-capable engineering worker for a Bounded/medium Effective Floor. Use only when Routing Policy Version 2 selects this profile."
model = "gpt-5.6-luna"
model_reasoning_effort = "medium"
sandbox_mode = "workspace-write"
developer_instructions = """
Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-worker-bounded-high.toml`:

```toml
name = "engineering-worker-bounded-high"
description = "Write-capable engineering worker for a Bounded/high Effective Floor. Use only when Routing Policy Version 2 selects this profile."
model = "gpt-5.6-luna"
model_reasoning_effort = "high"
sandbox_mode = "workspace-write"
developer_instructions = """
Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-worker-integrated-medium.toml`:

```toml
name = "engineering-worker-integrated-medium"
description = "Write-capable engineering worker for an Integrated/medium Effective Floor. Use only when Routing Policy Version 2 selects this profile."
model = "gpt-5.6-terra"
model_reasoning_effort = "medium"
sandbox_mode = "workspace-write"
developer_instructions = """
Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-worker-integrated-high.toml`:

```toml
name = "engineering-worker-integrated-high"
description = "Write-capable engineering worker for an Integrated/high Effective Floor. Use only when Routing Policy Version 2 selects this profile."
model = "gpt-5.6-terra"
model_reasoning_effort = "high"
sandbox_mode = "workspace-write"
developer_instructions = """
Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-worker-demanding-high.toml`:

```toml
name = "engineering-worker-demanding-high"
description = "Write-capable engineering worker for a Demanding/high Effective Floor. Use only when Routing Policy Version 2 selects this profile."
model = "gpt-5.6-sol"
model_reasoning_effort = "high"
sandbox_mode = "workspace-write"
developer_instructions = """
Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-worker-demanding-xhigh.toml`:

```toml
name = "engineering-worker-demanding-xhigh"
description = "Write-capable engineering worker for a Demanding/xhigh Effective Floor. Use only when Routing Policy Version 2 selects this profile."
model = "gpt-5.6-sol"
model_reasoning_effort = "xhigh"
sandbox_mode = "workspace-write"
developer_instructions = """
Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-worker-exceptional-xhigh.toml`:

```toml
name = "engineering-worker-exceptional-xhigh"
description = "Write-capable engineering worker for an Exceptional/xhigh Effective Floor. Use only when Routing Policy Version 2 selects this profile."
model = "gpt-5.6-sol"
model_reasoning_effort = "xhigh"
sandbox_mode = "workspace-write"
developer_instructions = """
Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-worker-exceptional-max.toml`:

```toml
name = "engineering-worker-exceptional-max"
description = "Write-capable engineering worker for an Exceptional/max Effective Floor. This is the strongest shipped Single-Agent worker profile."
model = "gpt-5.6-sol"
model_reasoning_effort = "max"
sandbox_mode = "workspace-write"
developer_instructions = """
Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
"""
```

### Step 3: Create the six read-only Codex reviewer profiles

`skills/subagent-driven-development/agents/codex/engineering-reviewer-integrated-high.toml`:

```toml
name = "engineering-reviewer-integrated-high"
description = "Read-only independent engineering reviewer for an Integrated/high Effective Floor. Use only when Routing Policy Version 2 selects this profile."
model = "gpt-5.6-terra"
model_reasoning_effort = "high"
sandbox_mode = "read-only"
developer_instructions = """
Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-reviewer-integrated-xhigh.toml`:

```toml
name = "engineering-reviewer-integrated-xhigh"
description = "Read-only independent engineering reviewer for an Integrated/xhigh Effective Floor. Use only when Routing Policy Version 2 selects this profile."
model = "gpt-5.6-terra"
model_reasoning_effort = "xhigh"
sandbox_mode = "read-only"
developer_instructions = """
Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-reviewer-demanding-high.toml`:

```toml
name = "engineering-reviewer-demanding-high"
description = "Read-only independent engineering reviewer for a Demanding/high Effective Floor. Use for both code-review axes at their baseline floor."
model = "gpt-5.6-sol"
model_reasoning_effort = "high"
sandbox_mode = "read-only"
developer_instructions = """
Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-reviewer-demanding-xhigh.toml`:

```toml
name = "engineering-reviewer-demanding-xhigh"
description = "Read-only independent engineering reviewer for a Demanding/xhigh Effective Floor. Use only when Routing Policy Version 2 selects this profile."
model = "gpt-5.6-sol"
model_reasoning_effort = "xhigh"
sandbox_mode = "read-only"
developer_instructions = """
Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-reviewer-exceptional-xhigh.toml`:

```toml
name = "engineering-reviewer-exceptional-xhigh"
description = "Read-only independent engineering reviewer for an Exceptional/xhigh Effective Floor. Use only when Routing Policy Version 2 selects this profile."
model = "gpt-5.6-sol"
model_reasoning_effort = "xhigh"
sandbox_mode = "read-only"
developer_instructions = """
Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
"""
```

`skills/subagent-driven-development/agents/codex/engineering-reviewer-exceptional-max.toml`:

```toml
name = "engineering-reviewer-exceptional-max"
description = "Read-only independent engineering reviewer for an Exceptional/max Effective Floor. This is the strongest shipped Single-Agent reviewer profile."
model = "gpt-5.6-sol"
model_reasoning_effort = "max"
sandbox_mode = "read-only"
developer_instructions = """
Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
"""
```

### Step 4: Verify the Codex adapter

Run:

```bash
scripts/check-model-routing.sh
git diff --check
find skills/subagent-driven-development/agents/codex -type f -name '*.toml' | sort
```

Expected:

- `check-model-routing: clean`
- `git diff --check` prints nothing.
- The sorted file list contains exactly fourteen TOML files: the eight worker profiles and six reviewer profiles listed in this task.

### Step 5: Commit the Codex adapter

```bash
git add scripts/check-model-routing.sh skills/subagent-driven-development/agents/codex
git commit -m "feat: add codex model routing profiles"
```

## Task 3: Add the Claude Agent Profiles

**Files:**

- Create: `skills/subagent-driven-development/agents/claude/engineering-worker-bounded-medium.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-worker-bounded-high.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-worker-integrated-medium.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-worker-integrated-high.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-worker-demanding-high.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-worker-demanding-xhigh.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-worker-exceptional-xhigh.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-worker-exceptional-max.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-reviewer-integrated-high.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-reviewer-integrated-xhigh.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-reviewer-demanding-high.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-reviewer-demanding-xhigh.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-reviewer-exceptional-xhigh.md`
- Create: `skills/subagent-driven-development/agents/claude/engineering-reviewer-exceptional-max.md`
- Modify: `scripts/check-model-routing.sh`

### Step 1: Extend the contract check before adding profiles

Insert this block in `scripts/check-model-routing.sh` immediately before `if [ "$status" -ne 0 ]; then`:

```bash
claude_dir="$repo_root/skills/subagent-driven-development/agents/claude"

check_claude_profile() {
  name=$1
  model=$2
  effort=$3
  authority=$4
  file="$claude_dir/$name.md"
  require_file "$file"
  if [ -f "$file" ]; then
    require_text "$file" "name: $name"
    require_text "$file" "model: $model"
    require_text "$file" "effort: $effort"
    if [ "$authority" = worker ]; then
      require_text "$file" 'disallowedTools: Agent'
      require_text "$file" 'Do not spawn subagents.'
    else
      require_text "$file" 'tools: Read, Grep, Glob'
      require_text "$file" 'Do not mutate files and do not spawn subagents.'
    fi
  fi
}

check_claude_profile engineering-worker-bounded-medium claude-sonnet-5 medium worker
check_claude_profile engineering-worker-bounded-high claude-sonnet-5 high worker
check_claude_profile engineering-worker-integrated-medium claude-sonnet-5 medium worker
check_claude_profile engineering-worker-integrated-high claude-sonnet-5 high worker
check_claude_profile engineering-worker-demanding-high claude-opus-4-8 high worker
check_claude_profile engineering-worker-demanding-xhigh claude-opus-4-8 xhigh worker
check_claude_profile engineering-worker-exceptional-xhigh claude-fable-5 xhigh worker
check_claude_profile engineering-worker-exceptional-max claude-fable-5 max worker
check_claude_profile engineering-reviewer-integrated-high claude-sonnet-5 high reviewer
check_claude_profile engineering-reviewer-integrated-xhigh claude-sonnet-5 xhigh reviewer
check_claude_profile engineering-reviewer-demanding-high claude-opus-4-8 high reviewer
check_claude_profile engineering-reviewer-demanding-xhigh claude-opus-4-8 xhigh reviewer
check_claude_profile engineering-reviewer-exceptional-xhigh claude-fable-5 xhigh reviewer
check_claude_profile engineering-reviewer-exceptional-max claude-fable-5 max reviewer

if [ -d "$claude_dir" ]; then
  claude_count=$(find "$claude_dir" -type f -name '*.md' | wc -l | tr -d ' ')
  if [ "$claude_count" != 14 ]; then
    fail "expected 14 Claude profiles, found $claude_count"
  fi
  claude_model_count=$(grep -h '^model: ' "$claude_dir"/*.md | wc -l | tr -d ' ')
  claude_effort_count=$(grep -h '^effort: ' "$claude_dir"/*.md | wc -l | tr -d ' ')
  if [ "$claude_model_count" != 14 ] || [ "$claude_effort_count" != 14 ]; then
    fail 'each Claude profile must declare exactly one pinned model and effort'
  fi
fi
```

Run:

```bash
scripts/check-model-routing.sh
```

Expected: exit status `1` and fourteen `missing file` diagnostics under `agents/claude/`.

### Step 2: Create the eight write-capable Claude worker profiles

Create each file with the exact content shown.

`skills/subagent-driven-development/agents/claude/engineering-worker-bounded-medium.md`:

```markdown
---
name: engineering-worker-bounded-medium
description: Write-capable engineering worker for a Bounded/medium Effective Floor. Use only when Routing Policy Version 2 selects this profile.
model: claude-sonnet-5
effort: medium
disallowedTools: Agent
---

Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
```

`skills/subagent-driven-development/agents/claude/engineering-worker-bounded-high.md`:

```markdown
---
name: engineering-worker-bounded-high
description: Write-capable engineering worker for a Bounded/high Effective Floor. Use only when Routing Policy Version 2 selects this profile.
model: claude-sonnet-5
effort: high
disallowedTools: Agent
---

Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
```

`skills/subagent-driven-development/agents/claude/engineering-worker-integrated-medium.md`:

```markdown
---
name: engineering-worker-integrated-medium
description: Write-capable engineering worker for an Integrated/medium Effective Floor. Use only when Routing Policy Version 2 selects this profile.
model: claude-sonnet-5
effort: medium
disallowedTools: Agent
---

Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
```

`skills/subagent-driven-development/agents/claude/engineering-worker-integrated-high.md`:

```markdown
---
name: engineering-worker-integrated-high
description: Write-capable engineering worker for an Integrated/high Effective Floor. Use only when Routing Policy Version 2 selects this profile.
model: claude-sonnet-5
effort: high
disallowedTools: Agent
---

Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
```

`skills/subagent-driven-development/agents/claude/engineering-worker-demanding-high.md`:

```markdown
---
name: engineering-worker-demanding-high
description: Write-capable engineering worker for a Demanding/high Effective Floor. Use only when Routing Policy Version 2 selects this profile.
model: claude-opus-4-8
effort: high
disallowedTools: Agent
---

Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
```

`skills/subagent-driven-development/agents/claude/engineering-worker-demanding-xhigh.md`:

```markdown
---
name: engineering-worker-demanding-xhigh
description: Write-capable engineering worker for a Demanding/xhigh Effective Floor. Use only when Routing Policy Version 2 selects this profile.
model: claude-opus-4-8
effort: xhigh
disallowedTools: Agent
---

Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
```

`skills/subagent-driven-development/agents/claude/engineering-worker-exceptional-xhigh.md`:

```markdown
---
name: engineering-worker-exceptional-xhigh
description: Write-capable engineering worker for an Exceptional/xhigh Effective Floor. Use only when Routing Policy Version 2 selects this profile.
model: claude-fable-5
effort: xhigh
disallowedTools: Agent
---

Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
```

`skills/subagent-driven-development/agents/claude/engineering-worker-exceptional-max.md`:

```markdown
---
name: engineering-worker-exceptional-max
description: Write-capable engineering worker for an Exceptional/max Effective Floor. This is the strongest shipped Single-Agent worker profile.
model: claude-fable-5
effort: max
disallowedTools: Agent
---

Implement only the supplied task or fix brief. Do not spawn subagents. Follow repository instructions and parent permissions. Preserve unrelated changes. Run relevant tests, self-review the diff, and report changed files, verification evidence, and remaining risks. Your output is a proposal until independent verified review passes.
```

### Step 3: Create the six read-only Claude reviewer profiles

The reviewer allowlist intentionally omits `Write`, `Edit`, `Bash`, and `Agent`. If a review needs a command that cannot run read-only, it must name the command as a verification gap instead of gaining mutation authority.

`skills/subagent-driven-development/agents/claude/engineering-reviewer-integrated-high.md`:

```markdown
---
name: engineering-reviewer-integrated-high
description: Read-only independent engineering reviewer for an Integrated/high Effective Floor. Use only when Routing Policy Version 2 selects this profile.
model: claude-sonnet-5
effort: high
tools: Read, Grep, Glob
---

Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
```

`skills/subagent-driven-development/agents/claude/engineering-reviewer-integrated-xhigh.md`:

```markdown
---
name: engineering-reviewer-integrated-xhigh
description: Read-only independent engineering reviewer for an Integrated/xhigh Effective Floor. Use only when Routing Policy Version 2 selects this profile.
model: claude-sonnet-5
effort: xhigh
tools: Read, Grep, Glob
---

Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
```

`skills/subagent-driven-development/agents/claude/engineering-reviewer-demanding-high.md`:

```markdown
---
name: engineering-reviewer-demanding-high
description: Read-only independent engineering reviewer for a Demanding/high Effective Floor. Use for both code-review axes at their baseline floor.
model: claude-opus-4-8
effort: high
tools: Read, Grep, Glob
---

Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
```

`skills/subagent-driven-development/agents/claude/engineering-reviewer-demanding-xhigh.md`:

```markdown
---
name: engineering-reviewer-demanding-xhigh
description: Read-only independent engineering reviewer for a Demanding/xhigh Effective Floor. Use only when Routing Policy Version 2 selects this profile.
model: claude-opus-4-8
effort: xhigh
tools: Read, Grep, Glob
---

Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
```

`skills/subagent-driven-development/agents/claude/engineering-reviewer-exceptional-xhigh.md`:

```markdown
---
name: engineering-reviewer-exceptional-xhigh
description: Read-only independent engineering reviewer for an Exceptional/xhigh Effective Floor. Use only when Routing Policy Version 2 selects this profile.
model: claude-fable-5
effort: xhigh
tools: Read, Grep, Glob
---

Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
```

`skills/subagent-driven-development/agents/claude/engineering-reviewer-exceptional-max.md`:

```markdown
---
name: engineering-reviewer-exceptional-max
description: Read-only independent engineering reviewer for an Exceptional/max Effective Floor. This is the strongest shipped Single-Agent reviewer profile.
model: claude-fable-5
effort: max
tools: Read, Grep, Glob
---

Review only the supplied brief, repository evidence, and diff. Do not mutate files and do not spawn subagents. Use fresh context and an adversarial correctness posture. Report findings first with severity and evidence, then verification gaps. If no finding exists, say so explicitly and name residual risks.
```

### Step 4: Verify the Claude adapter

Run:

```bash
scripts/check-model-routing.sh
git diff --check
find skills/subagent-driven-development/agents/claude -type f -name '*.md' | sort
```

Expected:

- `check-model-routing: clean`
- `git diff --check` prints nothing.
- The sorted file list contains exactly fourteen Markdown files: the eight worker profiles and six reviewer profiles listed in this task.

### Step 5: Commit the Claude adapter

```bash
git add scripts/check-model-routing.sh skills/subagent-driven-development/agents/claude
git commit -m "feat: add claude model routing profiles"
```

## Task 4: Route Subagent-Driven Development Dispatches

**Files:**

- Create: `skills/subagent-driven-development/scripts/record-dispatch`
- Modify: `skills/subagent-driven-development/SKILL.md:18`
- Modify: `skills/subagent-driven-development/SKILL.md:42-78`
- Modify: `skills/subagent-driven-development/SKILL.md:96-145`
- Modify: `skills/subagent-driven-development/SKILL.md:147-154`
- Modify: `skills/subagent-driven-development/SKILL.md:243-267`
- Modify: `skills/subagent-driven-development/implementer-prompt.md:5-15`
- Modify: `skills/subagent-driven-development/implementer-prompt.md:75-78`
- Modify: `skills/subagent-driven-development/implementer-prompt.md:139`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md:10-26`
- Modify: `skills/subagent-driven-development/task-reviewer-prompt.md:168-182`
- Modify: `scripts/check-model-routing.sh`

The controller executing this rollout continues to follow the skill snapshot loaded at session start. It must not dynamically adopt the just-edited gate rules midway through this plan. The new rules apply to a restarted harness after profile linking; this avoids a self-hosting deadlock while keeping activation explicit.

### Step 1: Extend the external record check before changing SDD

Insert this block in `scripts/check-model-routing.sh` immediately before `if [ "$status" -ne 0 ]; then`:

```bash
recorder="$repo_root/skills/subagent-driven-development/scripts/record-dispatch"

require_file "$recorder"

if [ -f "$recorder" ]; then
  bash -n "$recorder" || fail 'record-dispatch failed bash -n'

  record_tmp=$(mktemp -d "${TMPDIR:-/tmp}/model-routing-record.XXXXXX")
  git -C "$record_tmp" init -q
  sample_record='{"policy_version":2,"event":"started","dispatch_id":"check-1","role":"implementer","work_class":"Bounded","escalation_signals":[],"effective_floor":{"capability":"Bounded","reasoning":"medium"},"dispatch_mode":"Single-Agent","requested":{"profile":"engineering-worker-bounded-medium","model":"gpt-5.6-luna","effort":"medium"},"effective":{"model":null,"effort":null},"floor_verification":{"status":"unverified","evidence":"runtime did not report"},"outcome":{"first_pass":"pending","critical":0,"important":0,"retries":0,"escalation":"none","final_verification":"pending","elapsed":null,"usage":null}}'
  (
    cd "$record_tmp"
    printf '%s\n' "$sample_record" | "$recorder" >/dev/null
  )
  record_file="$record_tmp/.superpowers/model-routing/dispatches.jsonl"
  require_file "$record_file"
  if [ -f "$record_file" ] && [ "$(wc -l < "$record_file" | tr -d ' ')" != 1 ]; then
    fail 'record-dispatch did not append exactly one event'
  fi
  if [ "$(cat "$record_tmp/.superpowers/model-routing/.gitignore")" != '*' ]; then
    fail 'record-dispatch did not self-ignore its workspace'
  fi
  if (
    cd "$record_tmp"
    printf '%s\n' '{"prompt":"secret"}' | "$recorder" >/dev/null 2>&1
  ); then
    fail 'record-dispatch accepted a forbidden prompt field'
  fi
  if (
    cd "$record_tmp"
    printf '%s\n' '{"policy_version":2,"event":"started","dispatch_id":"incomplete","role":"implementer","work_class":"Bounded","escalation_signals":[],"effective_floor":{},"dispatch_mode":"Single-Agent","requested":{},"effective":{},"floor_verification":{},"outcome":{}}' | "$recorder" >/dev/null 2>&1
  ); then
    fail 'record-dispatch accepted missing nested fields'
  fi
  if (
    cd "$record_tmp"
    printf '%s\n' "$sample_record" | sed 's/"policy_version":2/"policy_version":1/' | "$recorder" >/dev/null 2>&1
  ); then
    fail 'record-dispatch accepted the wrong policy version'
  fi
  if [ "$(wc -l < "$record_file" | tr -d ' ')" != 1 ]; then
    fail 'record-dispatch appended a rejected event'
  fi
  rm -rf "$record_tmp"
fi
```

Run:

```bash
scripts/check-model-routing.sh
```

Expected: exit status `1` with a missing `record-dispatch` diagnostic.

### Step 2: Add the worktree-local Dispatch Record appender

Create `skills/subagent-driven-development/scripts/record-dispatch` with this exact content:

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'usage: printf %%s\\n JSON_OBJECT | %s\n' "$(basename "$0")" >&2
  exit 2
}

if [ "$#" -ne 0 ]; then
  usage
fi

record=''
if ! IFS= read -r record; then
  printf 'record-dispatch: expected one JSON object on stdin\n' >&2
  exit 2
fi

if IFS= read -r extra; then
  printf 'record-dispatch: record must occupy exactly one line\n' >&2
  exit 2
fi

case "$record" in
  \{*\}) ;;
  *)
    printf 'record-dispatch: record must be a JSON object\n' >&2
    exit 2
    ;;
esac

for key in \
  policy_version \
  event \
  dispatch_id \
  role \
  work_class \
  escalation_signals \
  effective_floor \
  dispatch_mode \
  requested \
  effective \
  floor_verification \
  outcome \
  capability \
  reasoning \
  profile \
  model \
  effort \
  status \
  evidence \
  first_pass \
  critical \
  important \
  retries \
  escalation \
  final_verification \
  elapsed \
  usage; do
  needle="\"$key\":"
  case "$record" in
    *"$needle"*) ;;
    *)
      printf 'record-dispatch: missing required key: %s\n' "$key" >&2
      exit 2
      ;;
  esac
done

case "$record" in
  *'"policy_version":2'*) ;;
  *)
    printf 'record-dispatch: policy_version must be 2\n' >&2
    exit 2
    ;;
esac

case "$record" in
  *'"event":"started"'*|*'"event":"completed"'*) ;;
  *)
    printf 'record-dispatch: event must be started or completed\n' >&2
    exit 2
    ;;
esac

for forbidden in prompt diff source_code secret credential; do
  needle="\"$forbidden\":"
  case "$record" in
    *"$needle"*)
      printf 'record-dispatch: forbidden key: %s\n' "$forbidden" >&2
      exit 2
      ;;
  esac
done

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  printf 'record-dispatch: run inside a git worktree\n' >&2
  exit 2
}
record_dir="$repo_root/.superpowers/model-routing"
record_file="$record_dir/dispatches.jsonl"

mkdir -p "$record_dir"
printf '*\n' > "$record_dir/.gitignore"
printf '%s\n' "$record" >> "$record_file"
printf '%s\n' "$record_file"
```

Make it executable and run its focused tests through the still-failing aggregate checker:

```bash
chmod +x skills/subagent-driven-development/scripts/record-dispatch
bash -n skills/subagent-driven-development/scripts/record-dispatch
scripts/check-model-routing.sh
```

Expected: `bash -n` succeeds and `check-model-routing: clean`. Workflow behavior remains RED until the Markdown rewires below are complete and the black-box cases pass.

### Step 3: Replace generic model selection with the Routing Policy

In `skills/subagent-driven-development/SKILL.md`, replace the complete `## Model Selection` section at current lines 96-127 with this exact block:

```markdown
## Model Routing

Before the first dispatch, read [model-routing.md](model-routing.md). Apply
Routing Policy Version 2 to every implementer, fixer, task reviewer, and
final-review axis dispatch. The SDD controller owns final-review orchestration;
never delegate the `code-review` workflow to a reviewer subagent.

For each dispatch:

1. Classify the Work Class from the brief, repository evidence, current diff,
   and prior results. Mandatory signals and ambiguity resolve upward.
2. Combine the Work Class floor with the role floor, taking the higher
   capability and reasoning effort independently.
3. Select the first named profile that meets both axes. Every shipped profile
   is Single-Agent; never select Ultra automatically.
4. Establish Floor Verification from explicit named-profile enforcement or a
   trustworthy runtime report. Prompt steering alone is unverified.
5. Write a redacted `started` Dispatch Record, dispatch, then write the matching
   `completed` event.

An implementer or fixer may proceed with an unverified Effective Floor because
its work remains a proposal. A task reviewer or either final-review axis
reviewer requires a verified Effective Floor. If the active runtime cannot
enforce or report that floor, stop before dispatch and name a compatible
surface or configuration. Resume only there with verified capacity; this
active-runtime stop does not itself require Policy Calibration. If no
compatible surface or configuration can obtain the reviewer, emit the
hard-stop `POLICY_CALIBRATION_REQUIRED`, provide the redacted calibration
brief, name `$grill-with-docs` in `engineering-skills`, and wait. Never
silently substitute downward.

Review independence means fresh context, read-only authority, and adversarial
instructions. It does not require a different provider or model family from
the implementer. Recompute classification when new evidence appears; never
lower either axis silently.
```

### Step 4: Wire routing into stops, fixes, final review, and durable progress

Make these exact replacements in `skills/subagent-driven-development/SKILL.md`.

Replace the `Continuous execution` paragraph at current line 18 with:

```markdown
**Continuous execution:** Do not pause to check in with your human partner between tasks. Execute all tasks from the plan without stopping. The only reasons to stop are: BLOCKED status you cannot resolve, ambiguity that genuinely prevents progress, inability of the active runtime to verify a required reviewer Effective Floor, an immediate hard-stop Policy Calibration Trigger, or all tasks complete. Pending policy debt from an escaped finding does not stop the current authorized branch's remediation and acceptance work. "Should I continue?" prompts and progress summaries waste their time — they asked you to execute the plan, so execute it.
```

In the process diagram, replace these three node labels everywhere they occur:

```text
Dispatch implementer subagent (./implementer-prompt.md)
```

with:

```text
Classify and dispatch routed implementer (./implementer-prompt.md)
```

Replace:

```text
Write diff file, dispatch task reviewer subagent (./task-reviewer-prompt.md)
```

with:

```text
Reclassify, verify floor, and dispatch read-only task reviewer (./task-reviewer-prompt.md)
```

Replace:

```text
Dispatch final whole-branch review subagent applying the code-review skill
```

with:

```text
Controller applies code-review: reclassify branch and dispatch verified Standards + Spec reviewers
```

Replace the numbered `BLOCKED` response at current lines 139-143 with:

```markdown
1. Repair missing or noisy context.
2. Raise reasoning effort to the next shipped profile that meets both axes.
3. Raise capability to the next shipped profile that meets both axes.
4. Split the task only when the split preserves correctness.
5. Ask the human when the preceding steps cannot produce a trustworthy result.
```

Immediately after the `Handling Reviewer ⚠️ Items` section, add:

```markdown
## Fix and Re-Review Routing

For every Critical or Important finding, compute Fix Work Class as the higher
of the original task's Work Class and the finding's Work Class. Route the fixer
from that result. Re-review at a floor no lower than the reviewer that found
the issue. Never repeat an unchanged failed dispatch.

If a task reviewer or either final-review axis reviewer returns
`FLOOR_UNVERIFIED`, discard the result as a gate, finish any already-running
peer, stop before another reviewer dispatch, and name a compatible surface or
configuration. Resume only there with verified capacity. If none can obtain
the reviewer, emit the hard-stop `POLICY_CALIBRATION_REQUIRED`, provide the
redacted brief, name `$grill-with-docs` in `engineering-skills`, and wait.

If a Critical or Important finding escaped a verified task review, emit
`POLICY_CALIBRATION_REQUIRED` as pending policy debt and provide a redacted brief
with record identifiers. Recompute final review as Exceptional/xhigh, finish
in-flight work, and complete current-branch fixes, re-review, both final axes,
and verification. If all gates pass, report Branch Ready together with the
pending calibration requirement. Begin no future SDD work until the human
resolves it through `$grill-with-docs` in `engineering-skills`.

If work was incorrectly declared Branch Ready, finish already-running
dispatches, preserve their results, emit the hard-stop
`POLICY_CALIBRATION_REQUIRED`, provide the redacted brief and next manual gear,
and start no new dispatch or readiness claim. The human owns global policy
changes; do not patch the policy opportunistically inside this workflow.
```

Add these bullets at the end of `## Durable Progress`, immediately before `## Prompt Templates`:

```markdown
- Dispatch records are separate from the progress ledger. Pipe one redacted
  JSON object per event through `scripts/record-dispatch`; it appends to
  `.superpowers/model-routing/dispatches.jsonl` and self-ignores the directory.
- Record `started` before every actual dispatch and `completed` when it returns,
  using the same dispatch ID. Never place prompts, diffs, source code, secrets,
  credentials, or personal data in a Dispatch Record.
- After compaction, reconstruct routing state from the plan, progress ledger,
  git history, and Dispatch Records. Recompute the next dispatch rather than
  trusting an unstated prior classification.
```

Replace the final-review bullet under `## Prompt Templates` with:

```markdown
- Final whole-branch review: the SDD controller recomputes branch Work Class and invokes the code-review workflow directly. The controller dispatches its fresh read-only Standards and Spec reviewers in parallel at verified Effective Floors. Never ask either Single-Agent reviewer to apply code-review or spawn the other axis.
```

Replace the final-review package bullet currently beginning `The final whole-branch review gets a package too` with:

```markdown
- The SDD controller owns the final whole-branch review. Run
  `scripts/review-package MERGE_BASE HEAD` (MERGE_BASE = the commit the
  branch started from, e.g. `git merge-base main HEAD`) and give the printed
  path to the controller-owned `code-review` workflow for its Standards and
  Spec axis dispatches. Do not delegate `code-review` orchestration to a
  reviewer profile.
```

In the Example Workflow, replace:

```text
[Dispatch final whole-branch reviewer applying the code-review skill (Standards + Spec)]
```

with:

```text
[SDD controller invokes code-review and dispatches verified Standards + Spec reviewers]
```

Add these items to the `Never:` list under `## Red Flags`:

```markdown
- Treat prompt steering as verified model or reasoning enforcement
- Dispatch a task reviewer or either final-review axis reviewer without a verified Effective Floor
- Delegate the code-review workflow to a Single-Agent reviewer profile
- Let an unverified implementer or fixer make work Branch Ready
- Silently substitute a profile below either Effective Floor axis
- Select Ultra automatically or give a Delegating agent write authority
- Begin future SDD work while calibration is pending, or continue after an immediate hard-stop `POLICY_CALIBRATION_REQUIRED`
```

### Step 5: Pass routing facts to implementers

In `skills/subagent-driven-development/implementer-prompt.md`, replace lines 5-10 with the following opening. The first line shown is the prompt's existing opening code fence; preserve one closing code fence at the end of the prompt body.

````markdown
```
Subagent ([PROFILE — select this named profile, never `general-purpose`]):
  description: "Implement Task N: [task name]"
  prompt: |
````

Immediately after `You are implementing Task N: [task name]`, insert:

```markdown
    ## Routing Contract

    Policy version: 1
    Role: implementer or fixer
    Work Class: [WORK_CLASS]
    Effective Floor: [CAPABILITY_FLOOR]/[REASONING_FLOOR]
    Requested profile: [PROFILE]
    Requested model and effort: [REQUESTED_MODEL]/[REQUESTED_EFFORT]
    Floor Verification: [FLOOR_VERIFICATION]

    Follow this routing declaration as scope metadata. Do not spawn subagents.
    Your result remains a proposal until verified independent review passes.
```

Replace `re-dispatch with a more capable model` at current line 77 with `re-dispatch with the next policy profile`.

After the closing code fence at the end of the file, append:

```markdown

**Routing template fields:**
- `[PROFILE]` — REQUIRED named worker profile selected by `model-routing.md`
- `[WORK_CLASS]` — REQUIRED classification: Bounded, Integrated, Demanding, or Exceptional
- `[CAPABILITY_FLOOR]` — REQUIRED Effective Floor capability
- `[REASONING_FLOOR]` — REQUIRED Effective Floor reasoning effort
- `[REQUESTED_MODEL]` — REQUIRED full model ID declared by the selected provider profile
- `[REQUESTED_EFFORT]` — REQUIRED effort declared by the selected provider profile
- `[FLOOR_VERIFICATION]` — REQUIRED `verified — <evidence>` or `unverified — <reason>`; unverified workers remain proposals
```

### Step 6: Require verified routing facts for task reviewers

In `skills/subagent-driven-development/task-reviewer-prompt.md`, replace lines 10-15 with the following opening. The first line shown is the prompt's existing opening code fence.

````markdown
```
Subagent ([PROFILE — select this named reviewer profile, never `general-purpose`]):
  description: "Review Task N (spec + quality)"
  prompt: |
````

Immediately after the paragraph ending `all tasks are complete.`, insert:

```markdown
    ## Routing Contract

    Policy version: 1
    Role: task reviewer
    Work Class: [WORK_CLASS]
    Effective Floor: [CAPABILITY_FLOOR]/[REASONING_FLOOR]
    Requested profile: [PROFILE]
    Requested model and effort: [REQUESTED_MODEL]/[REQUESTED_EFFORT]
    Floor Verification: verified — [FLOOR_VERIFICATION_EVIDENCE]

    This is an independent read-only gate. Do not mutate files and do not
    spawn subagents. If the runtime configuration does not match this verified
    declaration, return only `FLOOR_UNVERIFIED` with the mismatch evidence.
```

Replace the existing `[MODEL]` item in `**Placeholders:**` with these exact items:

```markdown
- `[PROFILE]` — REQUIRED named reviewer profile selected by `model-routing.md`
- `[WORK_CLASS]` — REQUIRED classification: Bounded, Integrated, Demanding, or Exceptional
- `[CAPABILITY_FLOOR]` — REQUIRED Effective Floor capability; at least Integrated
- `[REASONING_FLOOR]` — REQUIRED Effective Floor reasoning; at least high
- `[REQUESTED_MODEL]` — REQUIRED full model ID declared by the selected provider profile
- `[REQUESTED_EFFORT]` — REQUIRED effort declared by the selected provider profile
- `[FLOOR_VERIFICATION_EVIDENCE]` — REQUIRED trustworthy evidence that both axes meet the floor; prompt steering is insufficient
```

### Step 7: Run focused checks and the instruction evaluations

Run:

```bash
scripts/check-model-routing.sh
bash -n skills/subagent-driven-development/scripts/record-dispatch
git diff --check
```

Expected:

- `check-model-routing: clean`
- `bash -n` succeeds.
- `git diff --check` prints nothing.

Then use a fresh read-only subagent as an evaluation runner. Give it `skills/subagent-driven-development/SKILL.md`, the linked `model-routing.md`, and one Input paragraph from `model-routing-evals.md`, but not the Expected paragraph. Use this instruction:

```text
Apply Routing Policy Version 2. Return only Work Class, Effective Floor,
Profile, Floor Verification, and Action. Do not read the Expected paragraph.
Do not mutate files and do not spawn another agent.
```

Run every case except `Code Review axes baseline` independently and compare each result with its Expected paragraph. This evaluates workflow behavior; do not add executable routing logic or Markdown-layout assertions to make the cases pass. If the active runtime cannot hide the Expected text, record that limitation in the task report and have the independent task reviewer exercise each Input against the workflow and policy manually.

### Step 8: Inspect the intentional upstream divergence

Run:

```bash
git diff -- skills/subagent-driven-development/SKILL.md skills/subagent-driven-development/implementer-prompt.md skills/subagent-driven-development/task-reviewer-prompt.md skills/subagent-driven-development/model-routing.md skills/subagent-driven-development/model-routing-evals.md skills/subagent-driven-development/scripts/record-dispatch scripts/check-model-routing.sh
```

Expected: only the policy-owned files and the exact SDD routing rewires described in this task are present. Do not reformat unrelated upstream prose.

### Step 9: Commit the SDD routing integration

```bash
git add skills/subagent-driven-development/SKILL.md skills/subagent-driven-development/implementer-prompt.md skills/subagent-driven-development/task-reviewer-prompt.md skills/subagent-driven-development/scripts/record-dispatch scripts/check-model-routing.sh
git commit -m "feat: route sdd subagents by effective floor"
```

## Task 5: Apply Verified Demanding Routing to Code Review

**Files:**

- Modify: `skills/code-review/SKILL.md:56-78`

### Step 1: Confirm the existing code-review workflow fails its routing case

Give a fresh read-only Controller `skills/code-review/SKILL.md`, `skills/subagent-driven-development/model-routing.md`, and only the Input for `Code Review axes baseline`. Use the evaluation instruction from Task 4.

Expected RED evidence: the current workflow chooses `general-purpose`, has no Demanding/high floor, no Floor Verification gate, and no Dispatch Records. Capture those field-level failures in the task report.

### Step 2: Replace the generic parallel dispatch section

In `skills/code-review/SKILL.md`, replace the complete section from `### 4. Spawn both sub-agents in parallel` through the sentence about a missing spec at current lines 56-72 with this exact content:

````markdown
### 4. Classify and verify both review axes

Read the [Subagent Model Routing Policy](../subagent-driven-development/model-routing.md)
before dispatching.
Apply Routing Policy Version 2 independently to the Standards and Spec axes.
Both axes have a Demanding/high role floor. Recompute branch Work Class from
the complete diff; raise either axis to Exceptional when the policy's signals
apply. Do not lower an axis because the diff is small.

Select the matching named read-only reviewer profile. The baseline is
`engineering-reviewer-demanding-high`; use an Exceptional or higher-reasoning
reviewer only when classification or the Escalation Ladder requires it.
Establish a verified Effective Floor for each axis before dispatch. Named
profile enforcement or a trustworthy effective model-and-effort report counts;
prompt steering alone does not. If either required reviewer cannot be verified,
stop before all dispatches and name a compatible surface or configuration.
Resume only there with verified capacity. Do not emit calibration merely
because the active runtime is limited. If no compatible surface or
configuration can obtain the reviewer, emit the hard-stop
`POLICY_CALIBRATION_REQUIRED`, provide the redacted calibration brief, name
`$grill-with-docs` in `engineering-skills`, and wait. Never silently substitute
downward.

For every axis that will run, append a redacted `started` event through
`../subagent-driven-development/scripts/record-dispatch`. After the reviewers
return, append the matching `completed` events with finding counts and available
elapsed-time or usage data. Do not record prompts, diffs, or source code.

### 5. Spawn the routed reviewers in parallel

Send a single message with two `Agent` tool calls, selecting the verified named
reviewer profile for each. Both agents receive fresh context and read-only
authority. They may use the same provider or model family; independence comes
from isolated context and adversarial instructions.

Prefix both prompts with this routing declaration, filled from step 4:

```text
Policy version: 1
Role: code-review Standards reviewer | code-review Spec reviewer
Work Class: <Bounded | Integrated | Demanding | Exceptional>
Effective Floor: <capability>/<reasoning>
Requested profile: <named reviewer profile>
Requested model and effort: <full model ID>/<effort>
Floor Verification: verified — <trustworthy evidence>
This is an independent read-only gate. Do not mutate files and do not spawn subagents.
If the runtime configuration does not match this declaration, return only
FLOOR_UNVERIFIED with mismatch evidence.
```

**Standards sub-agent prompt** — include:

- The routing declaration.
- The full diff command and commit list.
- The list of standards-source files you found in step 3, **plus the smell baseline from step 3** pasted in full — the sub-agent has no other access to it.
- The brief: "Report — per file/hunk where relevant — (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls — documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Label every finding Critical, Important, or Minor. Critical means a safety, security, data-integrity, or correctness failure with severe consequence; Important means the branch cannot be trusted until fixed; Minor is non-blocking. Under 400 words."

**Spec sub-agent prompt** — include:

- The routing declaration.
- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Label every finding Critical, Important, or Minor using the same severity definitions as the Standards axis. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final
report. Do not create a Spec dispatch record for a dispatch that did not occur.
````

Renumber the existing `### 5. Aggregate` heading to `### 6. Aggregate`.

At the end of the Aggregate section, immediately after its one-line-summary rule, add:

```markdown

If a reviewer reports `FLOOR_UNVERIFIED`, discard that axis as a gate result and
finish the parallel peer if it is already running, stop before another review
dispatch, and name compatible verified capacity; do not report a pass. Emit the
hard-stop calibration trigger only if no compatible surface or configuration
can obtain the reviewer.

If a Critical or Important finding escaped an earlier verified task review,
finish the parallel peer, emit `POLICY_CALIBRATION_REQUIRED` as pending policy
debt, and preserve the Dispatch Record identifiers. Continue only this branch's
Exceptional/xhigh fixes, re-review, both final axes, and verification. A passing
branch may be reported Branch Ready with calibration still pending; begin no
future SDD work until the human resolves it through `$grill-with-docs`.

If the branch was already incorrectly described as Branch Ready, finish the
parallel peer, emit the hard-stop `POLICY_CALIBRATION_REQUIRED`, provide the
redacted brief and next manual gear, and stop before another dispatch or
readiness claim. Never change the global routing policy opportunistically from
inside this review.
```

### Step 3: Run focused checks

Run:

```bash
scripts/check-model-routing.sh
scripts/check-refs.sh
git diff --check
git diff -- skills/code-review/SKILL.md
```

Expected:

- `check-model-routing: clean`
- `check-refs: clean`
- `git diff --check` prints nothing.
- The code-review diff contains only the local model-routing rewire; preserve all existing standards, smell-baseline, spec-source, two-axis, and aggregation behavior.

Then rerun `Code Review axes baseline` against the changed workflow and policy without exposing its Expected block. Expected GREEN evidence: both separate axes use verified `Demanding/high` named reviewers, remain read-only Single-Agent dispatches, launch in parallel, and produce separate records. Also run the code-review variants of `Reported substitution is floor checked`, `Local overrides cannot lower a gate`, `Dispatch Record is complete and redacted`, and `Escaped finding calibration waits for in-flight work`.

### Step 4: Commit the code-review integration

```bash
git add skills/code-review/SKILL.md
git commit -m "feat: enforce routed code review"
```

## Task 6: Link Provider Profiles Without Cross-Harness Leakage

**Files:**

- Modify: `scripts/link-skills.sh:1-37`

### Step 1: Run a failing distribution check against the current linker

Run this exact throwaway-HOME probe before editing:

```bash
test_home=$(mktemp -d "${TMPDIR:-/tmp}/engineering-skills-link-red.XXXXXX")
HOME="$test_home" scripts/link-skills.sh >/dev/null
test -d "$test_home/.codex/agents"
```

Expected: the final `test` exits `1` because the current linker creates only skill directories.

Clean the fixture:

```bash
rm -rf "$test_home"
```

### Step 2: Replace the linker with the profile-aware implementation

Replace all of `scripts/link-skills.sh` with this exact content:

```bash
#!/usr/bin/env bash
# Link every skill and the SDD-owned provider profiles into harness discovery directories.
# Idempotent: re-run after adding, removing, or renaming a skill or profile.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO/skills"
CODEX_PROFILES="$SKILLS_DIR/subagent-driven-development/agents/codex"
CLAUDE_PROFILES="$SKILLS_DIR/subagent-driven-development/agents/claude"
TARGETS=("$HOME/.agents/skills" "$HOME/.claude/skills")
status=0

for target in "${TARGETS[@]}"; do
  mkdir -p "$target"

  # Prune only dead or stale skill links owned by this repository.
  for link in "$target"/*; do
    [ -L "$link" ] || continue
    link_target="$(readlink "$link")"
    case "$link_target" in
      "$SKILLS_DIR"/*)
        if [ ! -e "$link" ] || [ ! -d "$SKILLS_DIR/$(basename "$link")" ]; then
          rm "$link"
          echo "pruned removed skill: $link"
        fi
        ;;
    esac
  done

  for skill in "$SKILLS_DIR"/*/; do
    name="$(basename "$skill")"
    dest="$target/$name"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      echo "SKIP: $dest exists and is not a symlink — remove it manually" >&2
      status=1
      continue
    fi
    ln -sfn "$SKILLS_DIR/$name" "$dest"
    echo "linked: $dest -> $SKILLS_DIR/$name"
  done
done

link_profiles() {
  source_dir=$1
  target_dir=$2
  extension=$3

  if [ ! -d "$source_dir" ]; then
    echo "SKIP: provider profile source is missing: $source_dir" >&2
    status=1
    return
  fi

  mkdir -p "$target_dir"

  # Prune only dead links owned by this repository's provider directory.
  for link in "$target_dir"/engineering-*."$extension"; do
    [ -L "$link" ] || continue
    link_target="$(readlink "$link")"
    case "$link_target" in
      "$source_dir"/*)
        if [ ! -e "$link" ]; then
          rm "$link"
          echo "pruned removed profile: $link"
        fi
        ;;
    esac
  done

  for profile in "$source_dir"/*."$extension"; do
    [ -f "$profile" ] || continue
    name="$(basename "$profile")"
    dest="$target_dir/$name"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      echo "SKIP: $dest exists and is not a symlink — remove it manually" >&2
      status=1
      continue
    fi
    ln -sfn "$profile" "$dest"
    echo "linked: $dest -> $profile"
  done
}

link_profiles "$CODEX_PROFILES" "$HOME/.codex/agents" toml
link_profiles "$CLAUDE_PROFILES" "$HOME/.claude/agents" md

exit $status
```

### Step 3: Verify syntax and idempotent cross-harness installation

Run:

```bash
bash -n scripts/link-skills.sh
test_home=$(mktemp -d "${TMPDIR:-/tmp}/engineering-skills-link-green.XXXXXX")
HOME="$test_home" scripts/link-skills.sh > "$test_home/first.log"
HOME="$test_home" scripts/link-skills.sh > "$test_home/second.log"
expected_skill_count=$(find skills -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
test "$(find "$test_home/.agents/skills" -type l | wc -l | tr -d ' ')" = "$expected_skill_count"
test "$(find "$test_home/.claude/skills" -type l | wc -l | tr -d ' ')" = "$expected_skill_count"
test "$(find "$test_home/.codex/agents" -type l -name '*.toml' | wc -l | tr -d ' ')" = 14
test "$(find "$test_home/.claude/agents" -type l -name '*.md' | wc -l | tr -d ' ')" = 14
test "$(find "$test_home/.codex/agents" -type l -name '*.md' | wc -l | tr -d ' ')" = 0
test "$(find "$test_home/.claude/agents" -type l -name '*.toml' | wc -l | tr -d ' ')" = 0
for link in "$test_home/.agents/skills"/* "$test_home/.claude/skills"/*; do
  case "$(readlink "$link")" in
    "$PWD/skills"/*) ;;
    *) printf 'skill link escaped owning directory: %s\n' "$link" >&2; exit 1 ;;
  esac
done
for link in "$test_home/.codex/agents"/*.toml; do
  case "$(readlink "$link")" in
    "$PWD/skills/subagent-driven-development/agents/codex"/*) ;;
    *) printf 'Codex profile escaped owning directory: %s\n' "$link" >&2; exit 1 ;;
  esac
done
for link in "$test_home/.claude/agents"/*.md; do
  case "$(readlink "$link")" in
    "$PWD/skills/subagent-driven-development/agents/claude"/*) ;;
    *) printf 'Claude profile escaped owning directory: %s\n' "$link" >&2; exit 1 ;;
  esac
done
```

Expected: every command succeeds. The second run leaves the same fourteen profiles in each native directory. Codex never receives Claude Markdown and Claude never receives Codex TOML.

### Step 4: Verify collision refusal and ownership-scoped pruning

Continue with the same throwaway `test_home`:

```bash
profile_collision="$test_home/.codex/agents/engineering-worker-bounded-medium.toml"
skill_collision="$test_home/.agents/skills/how"
rm "$profile_collision" "$skill_collision"
printf 'local profile customization\n' > "$profile_collision"
mkdir "$skill_collision"
printf 'local skill customization\n' > "$skill_collision/marker"
if HOME="$test_home" scripts/link-skills.sh > "$test_home/collision.log" 2>&1; then
  printf 'expected collision refusal\n' >&2
  exit 1
fi
test ! -L "$profile_collision"
grep -Fq 'local profile customization' "$profile_collision"
test ! -L "$skill_collision"
grep -Fq 'local skill customization' "$skill_collision/marker"

rm "$profile_collision"
rm -rf "$skill_collision"
owned_profile_stale="$test_home/.codex/agents/engineering-stale.toml"
unrelated_profile_stale="$test_home/.codex/agents/engineering-unrelated-dead.toml"
owned_skill_stale="$test_home/.agents/skills/removed-skill"
unrelated_skill_stale="$test_home/.agents/skills/unrelated-dead"
ln -s "$PWD/skills/subagent-driven-development/agents/codex/engineering-stale.toml" "$owned_profile_stale"
ln -s "$PWD/not-owned-by-linker.toml" "$unrelated_profile_stale"
ln -s "$PWD/skills/removed-skill" "$owned_skill_stale"
ln -s "$PWD/not-owned-by-linker-skill" "$unrelated_skill_stale"
HOME="$test_home" scripts/link-skills.sh > "$test_home/prune.log"
test ! -L "$owned_profile_stale"
test -L "$unrelated_profile_stale"
test ! -L "$owned_skill_stale"
test -L "$unrelated_skill_stale"
```

Expected:

- Real skill and profile entries cause a non-zero linker exit and remain unchanged.
- Dead links into this repository's skill and Codex profile directories are removed.
- Unrelated dead skill and profile links remain untouched.

Clean the fixture:

```bash
rm -rf "$test_home"
```

Do not run `scripts/link-skills.sh` against the real `HOME` in this task.

### Step 5: Run repository checks and inspect the linker diff

```bash
scripts/check-model-routing.sh
scripts/check-refs.sh
git diff --check
git diff -- scripts/link-skills.sh
```

Expected: both check scripts report `clean`, `git diff --check` is silent, and the linker diff contains only provider-profile distribution plus its tests' required safety behavior.

### Step 6: Commit the distribution change

```bash
git add scripts/link-skills.sh
git commit -m "feat: link model routing profiles"
```

## Task 7: Record Provenance, Regenerate Documentation, and Verify the Branch

**Files:**

- Modify: `provenance.tsv:8`
- Modify: `provenance.tsv:15`
- Modify: `README.md:33-49`
- Regenerate: `README.md:55-80`

### Step 1: Record the two imported-skill divergences

In `provenance.tsv`, replace the complete `subagent-driven-development` row with this exact tab-separated row:

```text
subagent-driven-development	superpowers	skills/subagent-driven-development	imported	U	Heavy-track execution engine	user-invoked; code-review axes; verification gate; stop-before-merge; v2 model-routing policy/profiles; local dispatch records
```

Replace the complete `code-review` row with this exact tab-separated row:

```text
code-review	mattpocock-skills	skills/engineering/code-review	imported	M	Two-axis review (Standards + Spec)	tracker setup/spec lookup → local spec lookup; verified Demanding model-routing gate
```

Do not hand-edit the generated README provenance table.

### Step 2: Document profile installation and session activation

Replace the paragraph immediately after the install command in `README.md` with:

```markdown
Symlinks every skill in `skills/` into `~/.agents/skills` and `~/.claude/skills`, plus the SDD-owned Codex and Claude profiles into `~/.codex/agents` and `~/.claude/agents` respectively. Re-run after adding, removing, or renaming a skill or provider profile. Already-running harness sessions retain their loaded skill and agent snapshot, so restart them after relinking.
```

Replace the first sentence of the final Maintenance paragraph, currently beginning `After I commit and merge`, with:

```markdown
After I commit and merge the staged sync, any skill-membership or provider-profile change is handed back to the primary checkout: run `scripts/link-skills.sh` there, then restart already-running harness sessions because they retain their old skill and agent snapshot.
```

Keep the rest of that paragraph unchanged.

### Step 3: Regenerate the provenance table twice

Run:

```bash
scripts/gen-readme-table.sh
first_readme_hash=$(shasum README.md | awk '{print $1}')
scripts/gen-readme-table.sh
second_readme_hash=$(shasum README.md | awk '{print $1}')
test "$first_readme_hash" = "$second_readme_hash"
```

Expected: both generator runs succeed and the hashes match, proving idempotence.

### Step 4: Validate the provenance schema, membership, and upstream paths

Run:

```bash
awk -F '\t' 'NF != 7 { print "bad provenance row " NR ": " NF " columns"; bad=1 } END { exit bad }' provenance.tsv
awk -F '\t' 'NR > 1 && $4 != "dropped" { print $1 }' provenance.tsv | sort > "${TMPDIR:-/tmp}/routing-provenance-names.txt"
find skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort > "${TMPDIR:-/tmp}/routing-skill-names.txt"
diff -u "${TMPDIR:-/tmp}/routing-provenance-names.txt" "${TMPDIR:-/tmp}/routing-skill-names.txt"
awk -F '\t' 'NR > 1 && $4 == "imported" { print $1 "\t" $2 "/" $3 }' provenance.tsv > "${TMPDIR:-/tmp}/routing-upstream-paths.txt"
while IFS="$(printf '\t')" read -r name source_path; do
  test -d "$source_path" || {
    printf 'missing upstream path for %s: %s\n' "$name" "$source_path" >&2
    exit 1
  }
done < "${TMPDIR:-/tmp}/routing-upstream-paths.txt"
rm "${TMPDIR:-/tmp}/routing-provenance-names.txt" "${TMPDIR:-/tmp}/routing-skill-names.txt" "${TMPDIR:-/tmp}/routing-upstream-paths.txt"
```

Expected: every command succeeds with no diff. Every row has seven columns, non-dropped names exactly match `skills/`, and every imported upstream path exists.

### Step 5: Verify the narrow upstream divergences

Run:

```bash
diff -rq superpowers/skills/subagent-driven-development skills/subagent-driven-development || true
diff -rq mattpocock-skills/skills/engineering/code-review skills/code-review || true
```

Expected SDD differences are exactly:

- modified `SKILL.md`, `implementer-prompt.md`, and `task-reviewer-prompt.md`;
- local-only `model-routing.md` and `model-routing-evals.md`;
- local-only `agents/` containing the two explicit provider directories;
- local-only `scripts/record-dispatch`.

Expected code-review differences are exactly its previously recorded local spec-source rewire plus the new routing changes, all within `SKILL.md`. Any other differing upstream file is a stop signal: inspect and remove the accidental divergence before proceeding.

### Step 6: Run all automated verification

Run:

```bash
bash -n scripts/check-model-routing.sh scripts/link-skills.sh skills/subagent-driven-development/scripts/record-dispatch
scripts/check-model-routing.sh
scripts/check-refs.sh
test "$(rg -o 'Story [0-9]+' docs/specs/subagent-model-routing.md | sort -u | wc -l | tr -d ' ')" = 70
git diff --check
```

Expected:

- All three shell files pass `bash -n`.
- `check-model-routing: clean`
- `check-refs: clean`
- The spec contains exactly seventy distinct numbered stories.
- `git diff --check` prints nothing.

Repeat the complete Task 6 throwaway-HOME test once as the final distribution regression. Do not run the linker against the real `HOME`.

### Step 7: Review provider schemas against their authoritative docs

Inspect the shipped fields against the current provider documentation:

- Codex custom agents: `https://learn.chatgpt.com/docs/agent-configuration/subagents?surface=app`
- Claude subagents: `https://code.claude.com/docs/en/sub-agents`

Confirm Codex profiles have `name`, `description`, `developer_instructions`, `model`, `model_reasoning_effort`, and `sandbox_mode`. Confirm Claude profiles have `name`, `description`, `model`, `effort`, and the intended tool restriction. Do not replace the full model IDs or weaken review authority based on an undocumented assumption. If either provider no longer accepts a pinned field or value, stop and return to `$grill-with-docs`; that is a policy compatibility decision, not a local approximation.

### Step 8: Inspect final state before the documentation commit

Run:

```bash
git status --short
git diff -- provenance.tsv README.md
git log --oneline -6
```

Expected:

- Only `provenance.tsv` and `README.md` remain uncommitted for this task.
- The generated table matches the two changed TSV rows.
- The preceding six exact task commits appear in order.

If unrelated user changes exist, report and preserve them; do not include them in this commit.

### Step 9: Commit provenance and documentation

```bash
git add provenance.tsv README.md
git commit -m "docs: record model routing provenance"
```

### Step 10: Run the required final gates and stop

Run the complete verification set from Step 6 again, then use `verification-before-completion`. For the SDD final whole-branch review, the controller invokes `code-review` directly and owns the verified Standards and Spec reviewer dispatches; it must not dispatch a wrapper reviewer that applies `code-review`. Do not reload the newly edited skills inside this running session.

End with:

```bash
git status --short
git log --oneline -7
```

Expected: the seven task commits are present and the working tree is clean except for accurately reported unrelated user changes.

Report the branch as ready only if the loaded workflow's independent final review and verification pass. Stop without merging, pushing, real relinking, sanity testing, or worktree cleanup. Tell the user that activation is a separate human-owned action after merge from the primary checkout:

1. Review any existing real `~/.codex/agents/engineering-*` and `~/.claude/agents/engineering-*` entries for local customizations.
2. Run `scripts/link-skills.sh` from the primary checkout.
3. Restart Codex and Claude harness sessions.
4. Run every black-box case from `model-routing-evals.md` on the activated surfaces and confirm gate reviewers report a verified Effective Floor.

If activation reveals a schema mismatch or downward substitution, preserve the evidence and stop activation. If the active runtime cannot verify a reviewer, name compatible verified capacity; emit the hard-stop `POLICY_CALIBRATION_REQUIRED` only when none exists. If a Critical/Important finding escaped verified review, emit the flag as pending policy debt and complete only the current branch's Exceptional/xhigh acceptance work before blocking future SDD. An incorrect Branch Ready result emits the immediate hard-stop flag. Every calibration handoff names `$grill-with-docs` in this repository.

---

## Spec Traceability

| Spec coverage | Implementation tasks | Acceptance evidence |
|---|---|---|
| Stories 1-12: correctness objective, independent axes, qualitative Work Classes, upward ambiguity | Tasks 1, 4, and 5 | Policy evaluations for baselines, mandatory signals, ambiguity, and Exceptional triggers |
| Stories 13-19: role floors, branch recomputation, fix/re-review monotonicity | Tasks 1, 4, and 5 | Task-review, Code Review, final-branch, and fix/re-review cases |
| Stories 20-38: pinned provider mappings, reasoning/mode semantics, finite explicit colocated profiles | Tasks 1, 2, and 3 | Fourteen-profile checks per provider plus Max, substitution, and provider-mapping cases |
| Stories 39-41: harness-specific, idempotent, collision-safe distribution | Task 6 | Twice-run throwaway-HOME test, target checks, real-entry refusal, and ownership-scoped pruning |
| Stories 42-52: verification, fallback, overrides, independence, escalation | Tasks 1, 4, and 5 | Unsupported-runtime, prompt-only, substitution, override, independence, and ordered-escalation cases |
| Stories 53-58: complete redacted local Dispatch Records without aggregation | Tasks 1 and 4 | Recorder acceptance/rejection tests and the complete-record black-box case |
| Stories 59-66: human calibration, pending policy debt, hard safety stops, versioning | Tasks 1, 4, and 5 | Escape-continuation, hard-stop, active-runtime fallback, no-threshold, and version-validation cases |
| Stories 67-70: provenance, Stage containment, verification, actionable fail-closed stop | Tasks 4, 5, and 7 | Provenance regeneration, reference sweep, final gates, accurate status, and manual activation handoff |
| Testing Decisions: provider adapters and shell portability | Tasks 2, 3, 4, and 7 | Exact field/count checks, authority checks, official-schema review, and `bash -n` |
| Testing Decisions: imported divergence and generated docs | Task 7 | Upstream directory comparison, seven-column/membership/path validation, and twice-run README generation |

---

## Plan Self-Review Checklist

Before handing this plan off, verify:

- Every requirement in `docs/specs/subagent-model-routing.md` maps to the canonical policy, one provider adapter, one workflow rewire, a distribution behavior, or a verification step.
- Every created file has exact contents or an exhaustive mapping in this plan; no implementation choice is deferred to the worker.
- Codex and Claude each ship exactly fourteen profiles, with the same semantic names but provider-native files and no cross-harness linking.
- Worker and reviewer ladders cover every reachable baseline and monotonic escalation without a Cartesian product.
- All review gates fail closed without verified capacity; unverified write-capable output remains a proposal.
- Final whole-branch review is orchestrated by the SDD controller through two terminal Single-Agent review axes; no reviewer profile is asked to spawn another reviewer.
- Ultra remains outside the Single-Agent reasoning ladder and is never selected automatically.
- Dispatch records are redacted, worktree-local, self-ignored, and not globally aggregated.
- Calibration is human-owned and has no evidence-count prerequisite; escape debt permits only the current branch's remediation and acceptance, while hard-stop triggers start no new dispatch or readiness claim.
- No task changes an upstream submodule, real global installation, merge state, remote branch, or unrelated working-tree content.
- The final handoff names `/subagent-driven-development` and stops.

Plan complete. The next manual gear is `/subagent-driven-development`. Do not execute it automatically.
