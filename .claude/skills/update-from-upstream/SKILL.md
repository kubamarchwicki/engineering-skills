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

## 1. Mechanical merge

Run `scripts/update-from-upstream.sh` from the repo root. It fetches both submodules and three-way-merges every imported skill (base = pinned submodule SHA, ours = the `skills/` copy, theirs = upstream HEAD) into the working tree, uncommitted. Its report lines: `ok`/`=` (merged/unchanged), `CONFLICT:` (markers left in the file), `+`/`-`/`!` (file added/deleted/needs attention), `ATTENTION` (source path gone: rename or deletion), `NEW-CANDIDATE:` (upstream skill we've never seen), `ERROR:` (operational/binary merge failure; local file preserved), `SUMMARY:` (totals).

If it aborts on a dirty working tree, stop and tell the user. If it exits nonzero after reporting `ERROR:`, stop and tell the user; do not enter the walk-through or close-out until the error is resolved. If both submodules report `up to date`, say so and stop — there is nothing to walk through.

## 2. Understand before narrating

For each submodule that moved, read the upstream history for the imported paths — mandatory; the diff alone is not enough context to explain intent:

    git -C <submodule> log --no-merges --oneline <base>..<target> -- <source paths from provenance.tsv>

Read the full message (`git show <sha>`) of any commit whose one-liner doesn't explain itself. You are about to explain *why* upstream changed things, not just which lines moved.

## 3. Walk-through

**Narrated tier — clean merges.** Group by skill. For each changed skill, give a short summary: what upstream changed, why (from the commit messages), and whether it touches our rewirings (check the Changes column in `provenance.tsv`). Offer drill-in (`git diff skills/<name>/`) or rejection. Rejection = `git restore skills/<name>/` — warn that this is permanent divergence (the base advances with the pin bump, so the rejected change never resurfaces) and must be recorded in the row's Changes column.

**Grilled tier — one item at a time, recommendation first:**
- Each **CONFLICT**: show both sides of the markers, explain what upstream wants vs. what our rewiring does, propose a concrete resolution, apply it only once the user agrees.
- Each **NEW-CANDIDATE**: read its SKILL.md at the target SHA, then argue adopt or drop against this set's philosophy (two tracks, manual gear shifts, user owns merges, no auto-chaining). Adopt = copy the directory into `skills/`, add an `imported` row to `provenance.tsv`, and grill any rewiring it needs. Drop = add a `dropped` row with the reason.
- Each **deletion** (ATTENTION without a rename line): fork or drop. Fork = keep `skills/<name>`, set its row to status `original`, Changes `forked from <submodule> @ <short-sha>`. Drop = delete `skills/<name>` and set the row's status to `dropped`.
- Each **rename** (ATTENTION with an `R` line): fix `source_path` in `provenance.tsv`, re-run the script, and return to step 2.

## 4. Close-out

Only after every item above is resolved:

1. `provenance.tsv` reflects every decision (rejections, adoptions, drops, forks — in the Changes column).
2. `scripts/gen-readme-table.sh` — regenerate the README table.
3. `scripts/check-refs.sh` — must print `check-refs: clean`; fix any hit before proceeding.
4. Bump the pins: for each submodule that moved, `git -C <submodule> checkout -q --detach <target-sha>`, then `git add <submodule>`.
5. If membership changed: `scripts/link-skills.sh`.
6. `git add` the changed `skills/` dirs, `provenance.tsv`, `README.md` — then **STOP**.

Present a summary of everything staged, suggest the commit message `chore: sync upstream (<submodule> <old-short>..<new-short>)`, and end by saying the commit is the user's. Do not commit.
