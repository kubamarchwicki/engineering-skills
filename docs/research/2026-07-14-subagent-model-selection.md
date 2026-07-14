# Model and effort selection for engineering subagents

**Date:** 2026-07-14

**Scope:** implementation, fixing, exploration, plan review, task review, and whole-branch review in this repository's skill workflows

**Method:** current first-party OpenAI/Codex and Anthropic/Claude documentation, plus inspection of this repository. Recommendations and inferences are labelled separately from sourced facts.

## Executive recommendation

Choose two things independently for every dispatch:

1. **Model tier** answers: how much breadth, autonomy, and judgment does this task require?
2. **Effort level** answers: how much deliberation should that model spend on this particular task?

Do not use one fixed model for all implementers or reviewers, and do not make "most capable available" the unconditional final-review rule. Use a four-tier risk policy:

| Task class | Signals | Codex starting point | Claude starting point |
|---|---|---|---|
| A — bounded/mechanical | Exact task text; one or two files; established pattern; strong focused tests; low consequence of a miss | `gpt-5.6-luna`, low or medium | `sonnet`, low or medium |
| B — routine engineering | Several files; some integration judgment; ordinary bug fix or feature; usable tests and local patterns | `gpt-5.6-terra`, medium; high for review | `sonnet`, medium; high for review |
| C — difficult/high-risk | Ambiguous requirements; cross-cutting state; concurrency, security, migration, architecture, weak test oracle, or expensive failure | `gpt-5.6-sol`, high or xhigh | `opus`, high or xhigh |
| D — exceptional/long-horizon | Very large autonomous task, broad investigation, repeated failure after good context, or the highest-consequence final audit | Sol xhigh (or a supported session-level Max setting) | `fable`, high or xhigh; use max only when measured benefit justifies it |

The table is a **starting policy, not a vendor benchmark result**. The repository should calibrate it with its own outcomes: first-pass acceptance, review findings, retries, elapsed time, and usage.

For this repository specifically:

- Keep task implementers dynamic: A/B/C according to the task brief.
- Give review at least a medium-tier reasoning floor. Raise **effort before model** when the diff is compact but subtle; raise **model and effort** when the review requires broad codebase judgment.
- Default final whole-branch review to C, not automatically D. Reserve D for large, high-risk, or weakly verified branches.
- Keep exploration and bulk reading on faster models; keep the synthesis or decision on a stronger model.
- Treat model selection as advisory when the active runtime cannot actually pin it. Never claim a requested model was used unless the dispatch surface exposes and accepts that control.

## What the public names mean

### OpenAI / Codex

The user's labels are public product names, not private aliases. The current Codex model page lists **5.6 Sol**, **5.6 Terra**, **5.6 Luna**, and **5.5**, with CLI identifiers `gpt-5.6-sol`, `gpt-5.6-terra`, `gpt-5.6-luna`, and `gpt-5.5`. It describes Sol as the strongest GPT-5.6 option for complex work, Terra as the balanced everyday model, Luna as the fastest/lowest-cost family member, and 5.5 as the previous-generation frontier model. The documented default Power setting is Sol at medium reasoning. ([OpenAI, Models](https://learn.chatgpt.com/docs/models))

OpenAI's subagent guide separately uses `gpt-5.6` as a demanding-agent starting point and explicitly recommends `gpt-5.6-terra` for fast scans, large-file review, and other read-heavy workers. It says unpinned Codex subagents may balance intelligence, speed, and price automatically. ([OpenAI, Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)) For repeatable repository policy, the exact Sol/Terra/Luna identifiers above are less ambiguous than the generic `gpt-5.6` spelling.

Codex documents reasoning settings from low through high/xhigh, with supported models and surfaces also accepting Max or Ultra. Its current subagent documentation lists `ultra`, `max`, and `xhigh` as `model_reasoning_effort` values when the selected model supports them. Ultra is more than a per-agent deliberation setting because it combines maximum reasoning with permission to delegate proactively. Project agents may therefore request Max or Ultra when the active model and dispatch surface accept them, but the workflow must capability-detect support rather than assume it. ([OpenAI, Models](https://learn.chatgpt.com/docs/models), [OpenAI, Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents), [OpenAI, Configuration Reference](https://learn.chatgpt.com/docs/config-file/config-reference))

### Anthropic / Claude Code

**Fable, Opus, and Sonnet are also public names.** Current generally available model IDs are `claude-fable-5`, `claude-opus-4-8`, and `claude-sonnet-5`. Anthropic describes Fable as its highest-capability widely released model for long-running agents, Opus as the complex agentic-coding/enterprise model, and Sonnet as the speed/intelligence balance. ([Anthropic, Models overview](https://platform.claude.com/docs/en/about-claude/models/overview))

In Claude Code, `fable`, `opus`, and `sonnet` are convenience aliases. `fable` selects Fable 5, while `opus` and `sonnet` resolve to provider-dependent recommended versions and can change over time; full model IDs pin behavior more predictably. ([Anthropic, Model configuration](https://code.claude.com/docs/en/model-config)) Thus the names are official, but the bare family aliases are intentionally dynamic rather than fixed model versions.

Claude Code supports `low`, `medium`, `high`, `xhigh`, and `max` for Fable 5, Opus 4.8, and Sonnet 5. Anthropic says lower effort saves latency/tokens while higher effort increases depth; it also warns that max can have diminishing returns and overthink. ([Anthropic, Model configuration](https://code.claude.com/docs/en/model-config)) At the API level, effort is a behavioral signal across response text, tool calls, and thinking—not a strict token budget. ([Anthropic, Effort](https://platform.claude.com/docs/en/build-with-claude/effort))

As of the research date, Anthropic lists input/output prices of $10/$50 per million tokens for Fable 5, $5/$25 for Opus 4.8, and $3/$15 for Sonnet 5, with introductory Sonnet pricing of $2/$10 through August 31, 2026. It lists comparative latency as slower/moderate/fast respectively. ([Anthropic, Models overview](https://platform.claude.com/docs/en/about-claude/models/overview)) This supports reserving Fable for tasks whose expected reduction in retries or failure risk is worth roughly twice Opus's token price and at least three times Sonnet's—not for every final review.

## Sourced platform controls

### Codex

Codex supports project-scoped custom agents in `.codex/agents/*.toml`. A custom agent requires `name`, `description`, and `developer_instructions`; it may override `model`, `model_reasoning_effort`, sandbox mode, MCP servers, and skill configuration. Omitted fields inherit from the parent session. ([OpenAI, Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)) A concrete project role can therefore be declared as:

```toml
# .codex/agents/sdd_reviewer_high_risk.toml
name = "sdd_reviewer_high_risk"
description = "Read-only review for subtle or high-consequence engineering changes."
model = "gpt-5.6-sol"
model_reasoning_effort = "xhigh"
sandbox_mode = "read-only"
developer_instructions = """
Review the supplied diff and requirements. Lead with concrete correctness,
security, regression, and missing-test findings. Do not edit the checkout.
"""
```

Codex's official examples use the same pattern for read-only explorers and reviewers. It ships built-in `worker`, `explorer`, and `default` roles, and recommends read-heavy parallel work as the safest starting point for subagents because simultaneous write-heavy agents create coordination/conflict costs. ([OpenAI, Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))

There is an important **current-runtime gap**: the `collaboration.spawn_agent` tool exposed in this research session accepts only `task_name`, `message`, and `fork_turns`. It exposes neither a model, an effort setting, nor a custom-agent type. That is direct runtime evidence, not a statement about all Codex clients. In this surface, a skill can select and log a desired tier but cannot enforce it per spawn through that tool. Project custom-agent TOML is the documented Codex mechanism where the client supports selecting a named role; until this particular tool exposes that selector, the repository must not promise literal per-spawn model control.

The current SDD sentence that an omitted model "silently inherits the session's most expensive one" is therefore too categorical. Official behavior is surface-dependent: custom-agent omissions inherit, while unpinned Codex subagents may be auto-routed. The safe wording is: **select a tier every time; pin it when the dispatch surface supports pinning; otherwise report that the run is inherited/runtime-selected.** ([OpenAI, Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents))

### Claude Code

Claude Code project subagents live in `.claude/agents/*.md`. Their frontmatter supports both `model` and `effort`; valid model values include the `fable`, `opus`, `sonnet`, and `haiku` aliases, full IDs, and `inherit`. The invocation can also pass a model. Precedence is: `CLAUDE_CODE_SUBAGENT_MODEL`, then per-invocation model, then agent frontmatter, then the main conversation model. ([Anthropic, Create custom subagents](https://code.claude.com/docs/en/sub-agents))

```markdown
---
name: sdd-implementer-routine
description: Implements a well-scoped engineering task with ordinary integration work.
model: sonnet
effort: medium
---

Implement only the supplied task brief. Follow repository instructions, run the
focused checks, self-review, and return the required report.
```

Use a pinned full ID such as `claude-sonnet-5` instead of `sonnet` if reproducibility is more important than automatic upgrades. Claude Code also accepts temporary agent definitions via `claude --agents '<json>'`, with the same `model` and `effort` fields. ([Anthropic, Create custom subagents](https://code.claude.com/docs/en/sub-agents))

Two precedence traps matter operationally:

- `CLAUDE_CODE_SUBAGENT_MODEL` overrides both per-invocation and frontmatter model selection. ([Anthropic, Create custom subagents](https://code.claude.com/docs/en/sub-agents))
- `CLAUDE_CODE_EFFORT_LEVEL` outranks configured/frontmatter effort. ([Anthropic, Model configuration](https://code.claude.com/docs/en/model-config))

The orchestrator should report the effective model/effort when available, or at least check for these environment overrides before claiming its requested configuration ran.

## Recommended task-risk policy

This section is an inference from the official capability, effort, latency, and price descriptions—not a vendor-certified routing table.

### 1. Score the work before choosing the model

Raise the tier for each material signal:

- **Ambiguity:** multiple valid interpretations or missing design decisions.
- **Breadth:** cross-module contracts, shared state, migrations, or many call sites.
- **Consequence:** security, authorization, data loss, concurrency, public compatibility, or hard-to-roll-back changes.
- **Weak oracle:** tests cannot strongly prove correctness; human judgment carries more weight.
- **Novelty:** no established repository pattern or unfamiliar technology.
- **Horizon:** many dependent steps or a long autonomous run.

Lower the tier when the task is exact, local, reversible, pattern-matched, and covered by a strong test oracle. File count is only a proxy: a one-line lock-order change can be C while a ten-file generated rename can be A.

### 2. Choose effort separately

- **Low:** transcription, extraction, formatting, targeted search, or a mechanical change with decisive tests.
- **Medium:** routine implementation and routine review.
- **High:** debugging, requirements reconciliation, edge cases, or subtle review.
- **Xhigh:** architecture, concurrency/security review, weak test oracle, or a complex final audit.
- **Max:** one-off hardest cases after local evidence shows that xhigh leaves meaningful quality headroom; do not make it a default.

Prefer increasing effort without changing the model when the context is small but reasoning is subtle. Increase the model when the task needs broader judgment, autonomy, or longer-horizon coherence.

### 3. Treat implementation and review differently

Implementation has an execution oracle: code compiles, focused tests pass, and the implementer can iterate. Review often has a weaker oracle and must notice omissions the author did not. Therefore:

- Mechanical implementation may use A, but its independent task review should normally be at least B-medium.
- Routine B implementation can use B-medium; use B-high for its task review.
- C implementation gets C-high; its review gets C-high/xhigh.
- Standards review of a large but conventional diff can favor throughput (Terra/Sonnet medium or high).
- Spec review needs stronger reasoning when requirements are ambiguous (Sol/Opus high).
- Final whole-branch review starts at C-high. Raise to C-xhigh or D only for broad/high-consequence changes, repeated task-review escapes, or weak verification.

Do not require a different vendor/model merely for "independence." Fresh context, a read-only role, separate evidence, and an adversarial review prompt create the primary independence. Model diversity can be tested as an additional defense, but the official sources reviewed here do not establish that it is always superior.

### 4. Escalation and fallback

1. **`NEEDS_CONTEXT`:** add the missing context and keep the same model/effort.
2. **A clear local miss with adequate context:** keep the model and raise effort one step for the focused fix/re-review.
3. **The task was misclassified (unexpected coupling, design choice, weak oracle):** raise one model tier and use high effort.
4. **Repeated Important/Critical findings, repeated blockage, or the highest-consequence work:** use the top justified tier; for Claude, Fable is appropriate only when the work is genuinely long-horizon/highest-capability, not as a ceremonial escalation.
5. **Requested model unavailable or disallowed:** use the next lower documented tier, raise effort if supported, narrow the task, and record the fallback. Never silently substitute while reporting the requested model.
6. **Plan/spec contradiction:** model escalation cannot resolve product authority. Stop for the human decision, preserving this repository's manual gear-shift contract.

## Cost and latency: optimize total workflow cost, not the dispatch sticker

OpenAI's current included-usage examples allow substantially more Luna messages than Terra or Sol and its flexible-credit table prices Sol at about twice Terra and five times Luna per token unit; it also says model choice, reasoning, context, tools, retrieval, and caching all affect usage. ([OpenAI, Pricing](https://learn.chatgpt.com/docs/pricing)) Anthropic's current API price ratios similarly make Fable about twice Opus and Sonnet the least expensive of the three current families. ([Anthropic, Models overview](https://platform.claude.com/docs/en/about-claude/models/overview))

The decision should minimize:

```text
expected total cost = initial run + retries + review loops + context rebuilds
                      + expected cost of an escaped defect
```

A cheap model is not economical when it repeatedly rebuilds context or creates review/fix loops. Conversely, a top model is wasteful when the task is deterministic and strongly tested. The present SDD claim that cheap models "routinely take 2–3× the turns" is not supported by the primary documentation reviewed here; keep it only if labelled as local observation and backed by repository measurements.

Record per dispatch: desired and effective model/effort, task class, wall time, turns, status, review findings by severity, and whether escalation occurred. After 20–50 representative tasks, update the thresholds from observed first-pass acceptance and total usage rather than intuition.

## Repository dispatch-site inventory

| Site | Current state | Recommended treatment |
|---|---|---|
| `skills/subagent-driven-development/SKILL.md` | Has a generic cheap/standard/most-capable section and requires explicit models; has no effort dimension or concrete provider mapping. Unconditionally assigns final review to the most capable model. | Adopt the common A–D policy. Add effort. Make final review risk-based C→D. Replace the unsupported inheritance/2–3× claims. Add capability-aware wording for runtimes that cannot pin per spawn. |
| `skills/subagent-driven-development/implementer-prompt.md` | Active `general-purpose` template with required `[MODEL]`; no `[EFFORT]`. | Add selected task class, desired/effective model, and effort. Keep the task brief/report contract unchanged. |
| `skills/subagent-driven-development/task-reviewer-prompt.md` | Active `general-purpose` template with required `[MODEL]`; no `[EFFORT]`. | Add effort and a reviewer floor. Prefer read-only role/config. Preserve the existing spec+quality gate. |
| SDD fix and final-review dispatches | Described in the main skill but have no complete provider-aware dispatch template. | Fixer normally keeps implementer tier; escalate only when findings show misclassification. Final reviewer uses C-high by default, D only on risk signals. |
| `skills/code-review/SKILL.md` | Spawns Standards and Spec `general-purpose` agents in parallel; no model/effort policy. | Apply separate routing per axis: throughput-oriented Standards versus judgment-oriented Spec. Both read-only; do not force identical configurations. |
| `skills/dispatching-parallel-agents/SKILL.md` | Generic parallel debugging examples use `general-purpose` with no model selection. | Apply the common policy independently per problem domain. Preserve its independence/shared-state guard; do not add one blanket model for the whole batch. |
| `skills/research/SKILL.md` | Spawns one background researcher with no model/effort selection. | Default to Terra/Sonnet medium for bounded primary-source reading; use Sol/Opus high for conflicting sources or consequential synthesis. Keep the main-thread/background separation. |
| `skills/codebase-design/DESIGN-IT-TWICE.md` | Spawns 3+ parallel interface designers with no model/effort policy. | This is judgment-heavy. Use Sol/Opus high (or stronger only for exceptional scope), keep the deliberately different design constraints, and let the orchestrator synthesize. |
| `skills/improve-codebase-architecture/SKILL.md` | Explicitly uses the specialized `Explore` subagent. | Preserve the specialized read-heavy role. Use a faster/read-optimized model where the surface permits, but keep architectural ranking/synthesis in the stronger parent. Do not replace Explore with generic A–D boilerplate. |
| `skills/writing-plans/plan-document-reviewer-prompt.md` | Contains a `general-purpose` plan-review template, but `writing-plans/SKILL.md` now explicitly performs self-review and says it is **not** a subagent dispatch. The file is currently dormant upstream baggage. | Do not wire or edit it merely for consistency. If plan-document review is intentionally reactivated later, use Sol/Opus high because plan errors multiply across implementation tasks. |

No other active dispatch templates were found. `skills/codebase-design/SKILL.md` mentions the Design-It-Twice pattern, but the actual dispatch instructions are in `DESIGN-IT-TWICE.md`; `skills/how/SKILL.md` and `receiving-code-review` describe workflows without creating their own subagents.

## Integration proposal for this repository

This is a proposal only; the research task does not authorize implementation.

### Phase 1 — provider-neutral policy, minimal behavior change

1. Replace SDD's current Model Selection section with the A–D classifier and effort rules above.
2. Add `[EFFORT]`, task class, and fallback reporting to its implementer and task-reviewer templates.
3. Add a short model/effort section to `code-review` so Standards and Spec are selected independently.
4. Add one-line references to the same classifier at the active generic dispatch sites (`dispatching-parallel-agents`, `research`, and Design It Twice); preserve the specialized Explore behavior.
5. Do not reactivate or edit the dormant writing-plans reviewer template.

### Phase 2 — harness adapters

Where project-scoped custom agents are useful, define a small finite role set rather than embedding provider syntax in every dispatch:

- Codex: `.codex/agents/sdd_implementer_mechanical.toml`, `sdd_implementer_routine.toml`, `sdd_reviewer.toml`, and `sdd_reviewer_high_risk.toml` using Luna/Terra/Sol and low→xhigh.
- Claude: matching `.claude/agents/*.md` roles using Sonnet/Opus/Fable and `effort` frontmatter.

Keep exact model names in these adapter files, not scattered through prose. Use full Claude IDs if reproducibility matters; use aliases if automatic upgrades are intentional. For Codex surfaces like the current collaboration tool that cannot select these roles, record the desired tier and inherited/runtime-selected status rather than faking enforcement.

### Phase 3 — measure before tightening

Add lightweight ledger fields to SDD's existing durable progress record, or a separate ignored CSV, and review the routing policy after a representative sample. Do not auto-route based on a complex score until local evidence shows the simple A–D classifier is insufficient.

### Repository contract and provenance consequences

These changes must preserve the two manual tracks, every manual gear shift, final verification, and stop-before-merge behavior. Model selection occurs **inside** an already authorized dispatch; it must never auto-start another workflow stage.

The relevant files are imported content. Under `AGENTS.md`, any behavioral edit must be narrowly intentional and recorded in `provenance.tsv`; the generated README table must then be regenerated rather than edited by hand. Specifically:

- Update `subagent-driven-development` changes to include the risk/effort policy and dispatch-template rewiring.
- Update `code-review` if its dispatch behavior changes.
- Update each additional imported skill row only if that skill is actually edited; leaving the dormant writing-plans prompt untouched avoids unnecessary divergence.
- Run the repository's prescribed reference, provenance, import-diff, and shell checks after implementation.

Because the product contract forbids auto-chaining and auto-merge, no model—not even Fable or Sol at maximum effort—may weaken the human-owned stage boundaries or completion handoff.

## Unresolved gaps

- The primary sources describe capabilities, controls, price, and latency, but they do not publish a controlled comparison of these exact models in this repository's implementer/reviewer roles. The A–D routing table remains a recommendation until local telemetry validates it.
- This session's Codex spawn tool cannot select a model, effort, or custom-agent type, and it does not report an effective model. The documented custom-agent mechanism cannot be assumed to solve that limitation until the active runtime exposes a role selector.
- Alias resolution, organization allowlists, account entitlements, and environment overrides can change the effective Claude model. Exact-version pins improve reproducibility but require explicit maintenance when models retire.
- The repository has no current dispatch telemetry proving where Luna/Terra/Sol or Sonnet/Opus/Fable minimizes total gated-workflow cost. The existing 2–3× turn-count assertion should not be treated as established evidence.

## Bottom line

The useful abstraction is not "cheap model for implementation, expensive model for review." It is:

> Use the least costly model/effort pair that is likely to finish the **whole gated workflow** without escalation, while raising the tier whenever ambiguity, coupling, consequence, weak verification, or task horizon increases.

For ordinary work here, that means Luna/Sonnet for exact mechanical tasks, Terra/Sonnet for most engineering, Sol/Opus for subtle or high-risk work, and Fable only for exceptional long-horizon/highest-capability tasks. Review gets a reasoning floor and is risk-scaled; final review is strong by default but not ritualistically the most expensive model. The policy must also degrade honestly on runtimes that do not expose per-spawn controls.
