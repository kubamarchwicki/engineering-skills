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
/grill-with-docs  →  /to-spec  →  [/using-git-worktrees]  →  /writing-plans  →  /subagent-driven-development
                     docs/specs/                              docs/plans/       per-task two-stage review,
                                                                                whole-branch code-review,
                                                                                verification, then STOP
```

Lost? Type `/how`.

## Conventions

- `CONTEXT.md` (repo root) — domain glossary; `docs/adr/` — decisions; `docs/specs/` — specs from `/to-spec`; `docs/plans/NNNN-<feature-name>.md` — plans from `/writing-plans`. All created lazily.
- Skill names are inherited from their source repos, unchanged.
- Imported skills are verbatim except the rewirings listed below. The submodule SHAs pin exactly what each import forked from.
- Meta-philosophy for writing and editing these skills: `writing-great-skills`.

## Install

```bash
scripts/link-skills.sh
```

Symlinks every skill in `skills/` into `~/.agents/skills` and `~/.claude/skills`. Edits in this repo are live immediately; re-run after adding, removing, or renaming a skill.

## Maintenance

`provenance.tsv` is the single source of truth for the skill ↔ upstream mapping. The Reference table below is generated from it by `scripts/gen-readme-table.sh` (between the provenance markers) — edit the tsv, never the table.

Upstream sync: `/update-from-upstream` in Claude or `$update-from-upstream` in Codex, backed by one canonical repo-local source (`skills-internal/update-from-upstream/`) exposed through `.claude/skills/` and `.agents/skills/` discovery symlinks. Claude's frontmatter and Codex's `agents/openai.yaml` both disable implicit invocation. The skill loads only in this workspace and is never part of the globally linked set. It runs only in a linked Git worktree because the primary checkout may be live through the global skill symlinks. If invoked from the primary checkout, it names `/using-git-worktrees` then `/update-from-upstream` for Claude, or `$using-git-worktrees` then `$update-from-upstream` for Codex, and stops before creating or auto-chaining the worktree.

Inside the maintenance worktree, the skill runs `scripts/update-from-upstream.sh` — a three-way merge of every imported skill, base = the pinned submodule SHA — then walks through clean merges and grills every conflict, attention item, new upstream skill, deletion, and rename one at a time. A suspected rename is an explicit human-in-the-loop stop: it explains the evidence and waits for me to reconcile the affected skill directory and provenance entry manually before inspecting my fix and continuing. It records the decisions, completes the repository checks, bumps only moved pins, stages the agreed result only after all checks pass, and stops. It never commits, pushes, merges, or relinks the real global installs.

After I commit and merge the staged sync, any membership change is handed back to the primary checkout: run `scripts/link-skills.sh` there, then restart already-running harness sessions because they retain their old skill snapshot. I own the commit, merge, sanity testing, primary-checkout relinking, and maintenance-worktree cleanup.

## Reference

U = user-invoked (slash only) · M = model-invoked (fires on its own)

<!-- provenance:begin -->
| Skill | Inv. | Role | Source | Changes |
|---|---|---|---|---|
| how | U | Router over the whole set | original | — |
| grill-me | U | Interview to align before building | mattpocock `skills/productivity/grill-me` | verbatim |
| grill-with-docs | U | Grill + CONTEXT.md/ADRs inline | mattpocock `skills/engineering/grill-with-docs` | verbatim |
| to-spec | U | Conversation → `docs/specs/<name>.md` | mattpocock `skills/engineering/to-spec` | tracker → local file; gear-shift ending |
| implement | U | Light-track build | mattpocock `skills/engineering/implement` | + verification-before-completion gate |
| writing-plans | U | Exhaustive plan → `docs/plans/` | superpowers `skills/writing-plans` | user-invoked; docs/plans path; grilling refs; SDD-only handoff |
| subagent-driven-development | U | Heavy-track execution engine | superpowers `skills/subagent-driven-development` | user-invoked; code-review axes; verification gate; stop-before-merge |
| using-git-worktrees | U | Optional isolation for heavy work | superpowers `skills/using-git-worktrees` | user-invoked |
| handoff | U | Compact session → handoff doc | mattpocock `skills/productivity/handoff` | verbatim |
| improve-codebase-architecture | U | Deep-module sweep + report | mattpocock `skills/engineering/improve-codebase-architecture` | verbatim |
| writing-great-skills | U | Meta: how to write skills | mattpocock `skills/productivity/writing-great-skills` | verbatim |
| grilling | M | The reusable interview loop | mattpocock `skills/productivity/grilling` | verbatim |
| tdd | M | Seams-based red-green loop | mattpocock `skills/engineering/tdd` | verbatim |
| code-review | M | Two-axis review (Standards + Spec) | mattpocock `skills/engineering/code-review` | tracker setup/spec lookup → local spec lookup |
| receiving-code-review | M | Rigor when subagent review feedback arrives | superpowers `skills/receiving-code-review` | description rescoped |
| verification-before-completion | M | Universal completion gate | superpowers `skills/verification-before-completion` | verbatim |
| systematic-debugging | M | 4-phase root-cause debugging | superpowers `skills/systematic-debugging` | refs → tdd, verification-before-completion |
| dispatching-parallel-agents | M | Concurrent subagent workflows | superpowers `skills/dispatching-parallel-agents` | verbatim |
| domain-modeling | M | Glossary + ADR discipline | mattpocock `skills/engineering/domain-modeling` | verbatim |
| codebase-design | M | Deep-module vocabulary | mattpocock `skills/engineering/codebase-design` | verbatim |
| resolving-merge-conflicts | M | Conflict resolution by intent | mattpocock `skills/engineering/resolving-merge-conflicts` | verbatim |
| research | M | Cited findings → Markdown in repo | mattpocock `skills/engineering/research` | verbatim |
<!-- provenance:end -->

## Sources

`superpowers/` and `mattpocock-skills/` are git submodules pinning the exact upstream commits these skills were imported from. Diff any skill against its source to see the full delta:

```bash
diff -r superpowers/skills/writing-plans skills/writing-plans
```
