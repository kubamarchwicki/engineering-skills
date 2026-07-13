# Repository instructions

## Purpose and sources of truth

This repository builds `engineering-skills`, a curated personal set of 22 agent skills imported from the pinned `mattpocock-skills/` and `superpowers/` submodules, with a small, explicitly documented set of local rewirings.

Before changing the repository, read the relevant plan completely:

1. `docs/plans/0001-bootstrap-engineering-skills.md` builds and installs the initial set.
2. `docs/plans/0002-upstream-update-mechanism.md` adds provenance-driven upstream maintenance and may run only after plan 0001's prerequisites are present and committed.

`docs/2026-07-13-engineering-skills-handoff.md` is historical context. The two implementation plans are newer and more specific, so they win if wording or state differs. Do not re-litigate decisions already recorded in these documents.

Determine the current phase from the working tree rather than assuming a plan is complete. For example, `skills/.empty` with no root `README.md` means the bootstrap has not yet run.

## Product contract

Preserve these decisions in every skill, script, and document:

- There are two manually selected tracks:
  - Light: `/grill-me` -> `/implement`, inline on the current branch.
  - Heavy: `/grill-with-docs` -> `/to-spec` -> optional `/using-git-worktrees` -> `/writing-plans` -> `/subagent-driven-development`.
- Every stage boundary is a manual gear shift. Name the next command and stop; never auto-chain stages.
- Never auto-merge. After review and verification, stop. The user owns merging, sanity testing, and worktree cleanup.
- There is no session-start bootstrap hook and no plugin or marketplace packaging. Distribution is through `scripts/link-skills.sh` only.
- Artifact paths are fixed: `CONTEXT.md` at the repository root, `docs/adr/`, `docs/specs/`, and numbered plans at `docs/plans/NNNN-<feature-name>.md`.
- Keep inherited skill names unchanged. `how` is the only original globally distributed skill and is the router for the set.

When a decision is genuinely needed, investigate facts first, then ask in plain prose one question at a time and lead with a recommendation. Do not use a multiple-choice question widget.

## Repository layout and ownership

- `skills/` is a flat directory: one directory per distributed skill.
- `mattpocock-skills/` and `superpowers/` are pinned upstream source submodules. Treat them as read-only inputs. Do not put local product changes in them.
- Copy an imported skill's entire directory, including `agents/`, scripts, and reference files. Do not prune files.
- `.claude/skills/update-from-upstream/` is repo-local maintenance automation. It must not be copied into `skills/` or globally linked.
- `provenance.tsv`, once introduced by plan 0002, is the single source of truth for skill membership, upstream paths, invocation type, role, and local changes.
- The README provenance table between `<!-- provenance:begin -->` and `<!-- provenance:end -->` is generated. Change `provenance.tsv` and run `scripts/gen-readme-table.sh`; never hand-edit that table.

## Editing imported skills

Imported content is verbatim by default. Make only the frontmatter changes, reference repoints, and behavioral rewirings explicitly listed in plan 0001 or subsequently recorded in `provenance.tsv`.

- Do not reformat, rewrite, modernize, or harmonize upstream prose.
- Preserve deliberate upstream wording, including Superpowers' “your human partner” language.
- Treat an expected occurrence-count or old-text mismatch in a plan as a stop signal. Inspect the pinned source and repository state; do not approximate the replacement.
- User-invoked skills have `disable-model-invocation: true`; model-invoked skills do not.
- When adding, removing, renaming, or rerouting a user-reachable skill, keep the `/how` map, provenance data, README, and installed links consistent.
- Do not reintroduce dropped skill names, `superpowers:` prefixes, tracker-based flows, or `docs/superpowers/` paths. Run the reference sweep after relevant changes.

## Executing the plans

Both implementation plans explicitly require `subagent-driven-development`. Execute them task by task, including each task's stated checks and exact commit message. Do not skip ahead:

- Plan 0001 must finish before plan 0002 starts.
- Preserve unrelated working-tree changes.
- Copy or create exact file content where a plan says “exactly this content.”
- Commit after each implementation task when the plan instructs it.
- Never push or merge as part of either plan.
- Do not commit inside a submodule except for a plan-prescribed throwaway test branch; delete that branch and restore the pinned detached commit in the same task.

The normal skill workflow is still user-controlled: finishing one stage or writing a plan does not authorize starting the next stage. The per-task commits above are part of explicitly executing these repository implementation plans, not permission to auto-chain product workflows.

## Shell and portability rules

Repository scripts target macOS `/bin/bash` 3.2:

- Use `#!/usr/bin/env bash` and `set -euo pipefail`, except where an existing documented script intentionally differs.
- Do not use associative arrays, `${var,,}`, GNU-only flags, or BSD `sed` assumptions such as `\t` in replacements. Use `awk` when real tab handling is required.
- Keep scripts idempotent where documented.
- The linker must refuse to replace real non-symlink entries.
- The upstream merge engine must leave changes uncommitted and must not advance submodule pins.

## Upstream maintenance

Use `/update-from-upstream` for an upstream sync after plan 0002 exists. Its workflow is intentionally split:

1. `scripts/update-from-upstream.sh` performs a three-way merge: base is the submodule SHA pinned in the repository's `HEAD`, ours is `skills/<name>`, and theirs is the selected upstream commit.
2. Inspect upstream commit history to understand intent, then narrate clean merges and resolve conflicts, new candidates, deletions, or renames with the user one decision at a time.
3. Record every membership or divergence decision in `provenance.tsv`, regenerate the README, run reference checks, and bump only the relevant submodule pins.
4. Stage the agreed result and stop. Suggest a commit message, but do not commit or push; the sync commit belongs to the user.

Never automatically adopt or drop a skill. Never push changes upstream. A rejected clean upstream change is permanent divergence after the pin advances, so record it in the manifest's `changes` column.

## Verification

Run the checks prescribed by the active plan and verify their actual output before claiming completion. At minimum, when the corresponding files exist:

- Run `bash -n` on every changed shell script.
- Run `scripts/check-refs.sh`; it must report `check-refs: clean`.
- Run `scripts/gen-readme-table.sh` twice when provenance changes and confirm the second run is idempotent with no unexpected README diff.
- Validate `provenance.tsv` has exactly seven tab-separated columns and that non-dropped names match `skills/` while imported paths exist in their submodules.
- Diff verbatim imports against their pinned source directories and separately verify the narrowly rewired files.
- Test `scripts/link-skills.sh` with a throwaway `HOME` before touching real installs.
- For upstream-engine changes, run the dirty-tree guard, pinned-SHA no-op case, and synthetic clean-merge/conflict/new-candidate scenario from plan 0002, then clean up completely.
- End with `git status --short` and report any remaining changes accurately.

Before replacing existing `~/.agents/skills` or `~/.claude/skills` entries, perform plan 0001's diff review. If an old copy contains a possible local customization that is absent from both upstream sources, stop and show it to the user before deleting anything. After relinking, remind the user that already-running harness sessions retain their old skill snapshot until restarted.
