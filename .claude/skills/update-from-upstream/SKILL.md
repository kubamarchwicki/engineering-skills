---
name: update-from-upstream
description: Sync the skill set with its upstream submodules — automatic three-way merge, then a grilled walk-through of what changed. Repo-local maintenance for engineering-skills.
disable-model-invocation: true
---

You are running the upstream sync for this repo. The mechanical merge is a script's job; yours is the judgment layer: help the user understand what upstream changed and put every real decision to them, one at a time.

**Ground rules (non-negotiable):**
- Ask in plain prose, one question at a time, always leading with your recommended answer. Never use the AskUserQuestion widget.
- Never commit, never push, never do more than the close-out lists. The commit belongs to the user.
- Report, never act, on set membership: adopting or dropping a skill happens only on the user's explicit say-so.

## 1. Prove worktree isolation

This maintenance workflow may run only in a linked Git worktree. The primary checkout may be live through the real `~/.agents/skills` and `~/.claude/skills` symlinks, so mutating its `skills/` would change running installations before the user accepts the sync.

Resolve `git rev-parse --git-dir` and `git rev-parse --git-common-dir` to canonical paths, and also run `git rev-parse --show-superproject-working-tree`. A non-empty superproject path means this is a submodule, not an isolated root worktree. Only a root checkout whose canonical Git dir differs from its canonical common dir is isolated.

If this is the primary checkout or a submodule, recommend creating an isolated worktree. Name `/using-git-worktrees` as the next manual command and **STOP**. Do not create or auto-chain the worktree. The user must run `/using-git-worktrees`, enter that linked worktree, and invoke `/update-from-upstream` again.

## 2. Mechanical merge

Run `scripts/update-from-upstream.sh` from the repo root. It fetches both submodules and three-way-merges every imported skill (base = pinned submodule SHA, ours = the `skills/` copy, theirs = upstream HEAD) into the working tree, uncommitted. Its report lines: `ok`/`=` (merged/unchanged), `CONFLICT:` (markers left in the file), `+`/`-`/`!` (file added/deleted/needs attention), `ATTENTION` (source path gone: rename or deletion), `NEW-CANDIDATE:` (upstream skill we've never seen), `ERROR:` (operational/binary merge failure; local file preserved), `SUMMARY:` (totals).

If it aborts on a dirty working tree, stop and tell the user. If it exits nonzero after reporting `ERROR:`, stop and tell the user; do not enter the walk-through or close-out until the error is resolved. If both submodules report `up to date`, say so and stop — there is nothing to walk through.

## 3. Understand before narrating

For each submodule that moved, read the upstream history for the imported paths — mandatory; the diff alone is not enough context to explain intent:

    git -C <submodule> log --no-merges --oneline <base>..<target> -- <source paths from provenance.tsv>

Read the full message (`git show <sha>`) of any commit whose one-liner doesn't explain itself. You are about to explain *why* upstream changed things, not just which lines moved.

## 4. Walk-through

**Narrated tier — clean merges.** Group by skill. For each changed skill, give a short summary: what upstream changed, why (from the commit messages), and whether it touches our rewirings (check the Changes column in `provenance.tsv`). Offer drill-in (`git diff skills/<name>/`) or rejection. Rejection = `git restore skills/<name>/` — warn that this is permanent divergence (the base advances with the pin bump, so the rejected change never resurfaces) and must be recorded in the row's Changes column.

**Grilled tier — one item at a time, recommendation first:**
- Each **CONFLICT**: show both sides of the markers, explain what upstream wants vs. what our rewiring does, propose a concrete resolution, apply it only once the user agrees.
- Each per-file **`! ... KEPT`** attention item — including add/add, upstream-deleted/local-modified, upstream-modified/local-deleted, ancestor collision, and type or mode transition: show the base, committed local, and exact upstream target entry (content or deletion, type, and mode) plus the relevant upstream commit intent. Recommend one concrete resolution: keep local intent, accept the exact upstream target entry, or manually merge. Apply nothing until the user agrees. If local intent remains after the pin advances, record that permanent divergence in the skill's `provenance.tsv` `changes` field.
- Each **NEW-CANDIDATE**: read its SKILL.md at the target SHA, then argue adopt or drop against this set's philosophy (two tracks, manual gear shifts, user owns merges, no auto-chaining). Adopt = copy the directory into `skills/`, add an `imported` row to `provenance.tsv`, and grill any rewiring it needs. Drop = add a `dropped` row with the reason.
- Each **deletion** (ATTENTION without a rename line): fork or drop. Fork = keep `skills/<name>`, set its row to status `original`, Changes `forked from <submodule> @ <short-sha>`. Drop = delete `skills/<name>` and set the row's status to `dropped`.
- Each **rename** (ATTENTION with an `R` line): fix `source_path` in `provenance.tsv`, re-run the script, and return to step 2.

Close-out is forbidden while any `!`, `CONFLICT`, `ATTENTION`, `NEW-CANDIDATE`, deletion, or rename item remains unresolved.

## 5. Close-out

Only after every item above is resolved, perform every applicable check below and inspect its actual output before staging:

1. Confirm `provenance.tsv` records every membership and divergence decision, including rejections, adoptions, drops, forks, and every retained local `!` item.
2. Run `scripts/gen-readme-table.sh`. If provenance changed, hash the resulting README content, run the generator a second time, and require the second README hash to be identical.
3. Run `scripts/check-refs.sh` and require the exact success line `check-refs: clean`; fix any hit before continuing.
4. Identify every changed file whose shebang names Bash, including extensionless scripts, and run `bash -n` on each one.
5. For each moved submodule only, check out the agreed target SHA detached and stage that gitlink. Do not move or stage an unchanged submodule, and do not commit.
6. Validate that every `provenance.tsv` row has exactly seven tab-separated columns; non-dropped names exactly equal the flat directories under `skills/`; and every imported source path exists at its submodule's now-pinned `HEAD`.
7. Diff changed verbatim imports against their pinned source directories. Separately verify each rewired import and require that every difference is documented in that row's `changes` field.
8. If membership changed, create a throwaway `HOME`, run `scripts/link-skills.sh` twice with only that `HOME`, verify the second run is idempotent, and remove the fixture. Never run the real linker from this maintenance worktree.
9. Stage only the agreed sync result. Run `git status --short`, distinguish staged from remaining changes, and report both accurately.

Then **STOP**. Present the staged summary and suggest `chore: sync upstream (<submodule> <old-short>..<new-short>)`, but do not commit, push, merge, or relink the real global installs. The user owns the commit, merge, sanity testing, and maintenance-worktree cleanup. If membership changed, tell the user to run `scripts/link-skills.sh` from the primary checkout only after merging, and remind them that already-running harness sessions retain their old skill snapshot until restarted.
