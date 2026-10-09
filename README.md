# engineering-skills

My personal agent skill set — a deliberate hybrid of [obra/superpowers](https://github.com/obra/superpowers) and [mattpocock/skills](https://github.com/mattpocock/skills), designed 2026-07-13. Design record: `docs/plans/0001-bootstrap-engineering-skills.md` and the grilling session behind it.

**The contract:** two tracks, manual gear shifts. I pick the track; skills never decide for me. No session-start bootstrap, no auto-chaining, and nothing ever merges automatically — verification runs, then the system stops and the branch is mine.

## The two tracks

**Light** — small changes, single issues, inline on the current branch:

```
/grill-me  →  /implement   (tdd at agreed seams → code-review → verification-before-completion → commit)
```

**Heavy** — features and multi-step work:

```
/grill-with-docs  →  [/using-git-worktrees]  →  /writing-plans  →  /subagent-driven-development
                                                docs/plans/       committed baseline,
                                                                  Ready slices, four-concern review,
                                                                  applicable evidence, then STOP
```

Planning checks readiness and obtains independent design review, recording observable Ready/Provisional slices in `docs/plans/`. Execution records committed agreement and fixed review baselines, refines and executes Ready slices within agreed decisions, and uses four-concern task and whole-branch reviews plus applicable verification evidence before stopping.

For an effort too large for one session, optionally start with `$wayfinder` in Codex or `/wayfinder` in Claude. It keeps a local decision map and dependency-linked decision files under `docs/specs/<effort>/`, works one decision per session (research may run in parallel), and stops at the handoff to your chosen track.

## Conventions

- `GLOSSARY.md` (repo root) — domain glossary; `docs/adr/` — decisions; `docs/specs/` — optional specs; `docs/plans/NNNN-<feature-name>.md` — plans from `/writing-plans`. Grilling records terminology and decisions; plans apply those decisions to outcomes, acceptance, Ready/Provisional slices, and durable evidence. Substantive decision changes use superseding ADRs. All created lazily.
- Skill names are inherited from their source repos, unchanged.
- Imported skills are verbatim except the rewirings listed below. The submodule SHAs pin exactly what each import forked from.
- Guidance for writing and editing documents agents consume: `writing-for-agents`.

## Drift from the original skills

The main evolution is toward **validating assumptions before implementation, preserving decisions, and tying completion to observable evidence**.

| Area | How it evolved |
| --- | --- |
| **Grilling and domain modeling** | Grilling now establishes measurable outcomes, acceptance criteria, and state ownership. It permits bounded integration experiments. Changed architectural decisions get superseding ADRs, preserving their history. |
| **Planning** | writing-plans (skills/writing-plans/SKILL.md:23) adds readiness checks and mandatory independent design review. Tasks become **Ready** or **Provisional**, with explicit evidence needed to unblock provisional work. A separate spec is optional. |
| **Heavy execution** | subagent-driven-development (skills/subagent-driven-development/SKILL.md:93) records committed agreement and execution baselines, checks readiness before dispatch, and preserves decisions and evidence beyond scratch cleanup. Retry limits no longer permit accepting unresolved blocking failures. |
| **Review** | code-review (skills/code-review/SKILL.md:6) retains two reviewers but covers four concerns: correctness, design validity, evidence quality, and scope/standards. Working-tree review explicitly includes untracked files. |
| **Review feedback** | Feedback is classified into defects, assumptions, requirements, dependency capabilities, and preferences. Uncertainty blocks dependent work; independent work can continue. |
| **Verification** | verification-before-completion (skills/verification-before-completion/SKILL.md:14) replaces “rerun in this message” with **applicable evidence**. Reuse requires inspectable output, tested state, relevant conditions, and clear limits. |
| **Light execution** | `implement` records its starting revision and reviews the actual working-tree changes before committing. Verification becomes proportional to risk and project requirements. |
| **Parallel delegation** | Parallel work gains explicit dependency and shared-resource checks. |

## Install

From each consuming project's root, install its own set from the published GitHub repository:

```bash
npx skills add https://github.com/kubamarchwicki/engineering-skills/tree/master/skills --skill '*' --agent codex --agent claude-code --yes
```

This installs every distributed skill for Codex and Claude Code in that project. Projects do not share an installation. Re-run there after changes have been published to GitHub.

## Maintenance

`provenance.tsv` is the single source of truth for the skill ↔ upstream mapping. The Reference table below is generated from it by `scripts/gen-readme-table.sh` (between the provenance markers) — edit the tsv, never the table.

Upstream sync: `/update-from-upstream` in Claude or `$update-from-upstream` in Codex, backed by one canonical repo-local source (`skills-internal/update-from-upstream/`) exposed through `.claude/skills/` and `.agents/skills/` discovery symlinks. Claude's frontmatter and Codex's `agents/openai.yaml` both disable implicit invocation. The skill loads only in this repository and is excluded from the distributed `skills/` path. It runs in the primary checkout or an optional linked worktree.

The skill runs `scripts/update-from-upstream.sh` — a three-way merge of every imported skill, base = the pinned submodule SHA — then walks through clean merges and grills every conflict, attention item, new upstream skill, deletion, and rename one at a time. A suspected rename is an explicit human-in-the-loop stop: it explains the evidence and waits for me to reconcile the affected skill directory and provenance entry manually before inspecting my fix and continuing. It records the decisions, completes the repository checks, bumps only moved pins, stages the agreed result only after all checks pass, and stops. It never commits, pushes, merges, or updates consuming projects.

After I publish the sync to GitHub, each project can refresh its own installation with the command above. Already-running harness sessions retain their old skill snapshot until restarted. I own the commit, publication, sanity testing, and any merge or worktree cleanup.

## Reference

U = user-invoked (explicit command) · M = model-invoked (fires on its own)

<!-- provenance:begin -->
| Skill | Inv. | Role | Source | Changes |
|---|---|---|---|---|
| grill-me | U | Interview to align before building | mattpocock `skills/productivity/grill-me` | verbatim |
| grill-with-docs | U | Grill + GLOSSARY.md/ADRs inline | mattpocock `skills/engineering/grill-with-docs` | verbatim |
| implement | U | Light-track build | mattpocock `skills/engineering/implement` | + verification-before-completion gate; applicable evidence and proportionate checks; working-tree review from recorded base; omit upstream tracker-fetch requirement |
| writing-plans | U | Evidence-backed plans → docs/plans/ | superpowers `skills/writing-plans` | user-invoked; optional worktree; docs/plans path; grilling refs; SDD-only handoff; readiness and independent design review; ADR/glossary sources; outcome verification; ready/provisional slices; design-reviewer prompt; ordered planning procedure; required plan-format reference; consolidated task contract |
| subagent-driven-development | U | Heavy-track execution engine | superpowers `skills/subagent-driven-development` | user-invoked; optional worktree; no alternate executor; docs/plans examples; code-review axes; verification gate; stop-before-merge; evidence records and proportionate checks in implementer prompt; four-concern task and scoped re-review prompts; committed agreement baseline; fixed execution review base; readiness-gated task extraction; per-task decision/evidence context; bounded consequential decisions; durable evidence and blocking completion gates; authoritative controller procedure; branch-triggered recovery and fix-loop references; disclosed workflow example |
| using-git-worktrees | U | Optional isolation for heavy work | superpowers `skills/using-git-worktrees` | user-invoked |
| wayfinder | U | Multi-session discovery map before either track | mattpocock `skills/engineering/wayfinder` | tracker operations → local map and decision files under `docs/specs/<effort>/`; local status, claim, dependency, and resolution conventions; glossary/ADR canonical links; planning-only scope; bounded inline prototypes; local research notes with controller-owned map updates; coordinated concurrent file edits; preserve decision history; manual track choice and handoff |
| handoff | U | Compact session → handoff doc | mattpocock `skills/productivity/handoff` | verbatim |
| wait-what | U | Re-pitch an explanation that did not land | mattpocock `skills/productivity/wait-what` | verbatim |
| improve-codebase-architecture | U | Deep-module sweep + report | mattpocock `skills/engineering/improve-codebase-architecture` | verbatim |
| writing-for-agents | M | Guidance for documents agents consume | mattpocock `skills/productivity/writing-for-agents` | verbatim |
| grilling | M | The reusable interview loop | mattpocock `skills/productivity/grilling` | outcome and ownership investigation; bounded experiments; explicit consequential decisions |
| tdd | M | Seams-based red-green loop | mattpocock `skills/engineering/tdd` | verbatim |
| code-review | M | Two reviewers covering correctness, design, evidence, and standards | mattpocock `skills/engineering/code-review` | tracker setup/spec lookup → local spec lookup; four concerns across existing reviewers; ADR/plan agreement sources; working-tree and untracked review |
| receiving-code-review | M | Rigor when subagent review feedback arrives | superpowers `skills/receiving-code-review` | description rescoped; feedback classification; dependency-scoped decisions; durable updates; consolidated feedback procedure and factual-response policy; branch-triggered examples and inline-reply reference |
| verification-before-completion | M | Universal completion gate | superpowers `skills/verification-before-completion` | applicable evidence reuse; risk-based check scope; inspectable evidence records |
| systematic-debugging | M | 4-phase root-cause debugging | superpowers `skills/systematic-debugging` | refs → tdd, verification-before-completion |
| dispatching-parallel-agents | M | Concurrent subagent workflows | superpowers `skills/dispatching-parallel-agents` | independence and shared-resource checklist; isolated outcome-based briefs; concurrency-slot dispatch; disclosed examples; applicable integration verification; manual stage boundary |
| domain-modeling | M | Glossary + ADR discipline | mattpocock `skills/engineering/domain-modeling` | ADR supersession; glossary/ADR/plan responsibility split |
| codebase-design | M | Deep-module vocabulary | mattpocock `skills/engineering/codebase-design` | verbatim |
| research | M | Cited findings → Markdown in repo | mattpocock `skills/engineering/research` | verbatim |
<!-- provenance:end -->

## Sources

`superpowers/` and `mattpocock-skills/` are git submodules pinning the exact upstream commits these skills were imported from. Diff any skill against its source to see the full delta:

```bash
diff -r superpowers/skills/writing-plans skills/writing-plans
```
