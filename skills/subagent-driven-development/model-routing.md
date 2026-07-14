# Subagent Model Routing Policy

**Routing Policy Version: 1**

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

Version 1 never selects Ultra automatically. An explicit user instruction may allow Delegating only for read-only, safely decomposable work. Never give a Delegating profile write authority and never use it for an SDD implementer or fixer. Code Review may launch its two Single-Agent axes in parallel; that controller-owned parallelism is not Ultra or nested delegation.

## Floor Verification and fallback

A floor is `verified` only when either:

- a named profile was selected and no known higher-precedence setting can lower its model or effort; or
- the runtime reports the effective model and effort and both meet the Effective Floor.

Profile existence without selection, prompt steering, an agent's self-description, and a requested-but-unreported configuration are `unverified`.

Explorers, implementers, and fixers may run unverified because their output remains a proposal behind verified gates. Mark their record `unverified`. A task reviewer or either final-review axis reviewer must be verified before dispatch. If the active surface cannot enforce or report the floor, stop and name a compatible surface or configuration. Never silently substitute downward. A reported substitute is acceptable only when it meets or exceeds both axes.

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
{"policy_version":1,"event":"started","dispatch_id":"task-3-review-1","role":"task-reviewer","work_class":"Integrated","escalation_signals":[],"effective_floor":{"capability":"Integrated","reasoning":"high"},"dispatch_mode":"Single-Agent","requested":{"profile":"engineering-reviewer-integrated-high","model":"gpt-5.6-terra","effort":"high"},"effective":{"model":"gpt-5.6-terra","effort":"high"},"floor_verification":{"status":"verified","evidence":"named profile selected with no lowering override"},"outcome":{"first_pass":"pending","critical":0,"important":0,"retries":0,"escalation":"none","final_verification":"pending","elapsed":null,"usage":null}}
```

## Policy Calibration

Only a human changes policy-wide floors, mappings, profiles, or classification signals. The operator may calibrate at any time and does not need a minimum sample or additional evidence.

The following safety events require calibration: a Critical or Important finding escaped task review; work was incorrectly declared Branch Ready; or no compatible surface can provide a verified required reviewer. Finish already-running dispatches, do not start another dispatch or declare Branch Ready, and emit:

```text
POLICY_CALIBRATION_REQUIRED
```

Then give a redacted brief with policy version, trigger, outcome counts, relevant record identifiers, observed failure, current policy decision, and proposed question. Name `$grill-with-docs` in the `engineering-skills` repository as the next manual gear and wait for the human. Do not adjust the policy locally inside the active implementation or review.
