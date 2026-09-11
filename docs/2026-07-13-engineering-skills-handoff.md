# Handoff: engineering-skills — design confirmed, ready to plan the bootstrap

**Date:** 2026-07-13
**Workspace:** `/Users/jakub/workspaces/engineering-skills` (git repo, branch `master`, clean)

## What happened

Jakub uses both superpowers and mattpocock-skills, is happy with neither, and designed his own skill set — **engineering-skills** — through a full `/grilling` session. Every design decision below is *his*, resolved one branch at a time; do not re-litigate them.

The complete decision ledger lives in agent memory: `/Users/jakub/.claude/projects/-Users-jakub-workspaces-engineering-skills/memory/designing-own-skills.md`. Read it before doing anything. Summary of the shape:

- **Two tracks, manual gear shifts, no bootstrap hook.** Light: grill → `/implement` inline on the current branch. Heavy: `/grill-with-docs` → optional `/using-git-worktrees` → `/writing-plans` → `/subagent-driven-development`. Each skill ends by naming the next command; nothing auto-chains, nothing auto-merges — Jakub owns merge, sanity testing, and worktree cleanup.
- **22 skills:** a curated mix from mattpocock and superpowers plus the original `/how` router. Full membership and the model-invoked vs user-invoked split live in `provenance.tsv`.
- **Rewirings (the only permitted edits to verbatim imports):** frontmatter/invocation changes; SDD workers use seams-based `tdd`, reviews use two-axis `code-review`, gate on `verification-before-completion`, stop before merge; dangling refs repoint (test-driven-development→tdd, requesting-code-review→code-review, brainstorming→grilling, executing-plans→implement).
- **Conventions:** inherited names unchanged; artifacts hardcoded — `CONTEXT.md` at repo root, `docs/adr/`, `docs/specs/`, `docs/plans/`; flat `skills/` dir; provenance table generated in `README.md`; install with `npx skills add ./skills --global --skill '*' --agent codex --agent claude-code --yes`. No plugin/marketplace.

## Filesystem facts the next agent needs

- The two source checkouts sit at `superpowers/` and `mattpocock-skills/` inside the workspace. **Jakub will convert them to git submodules himself** — their SHAs pin what each import forked from. mattpocock checkout was at `66898f6` (2026-07-13) during design.
- The installs present during the original design were stale Jul-10 snapshots of upstream. Diff-review existing copies before replacing them so no local customization is lost.

## State of play / next step

The grilling ended with a full shared-understanding recap presented to Jakub. He did not explicitly say "confirmed" — he asked for this handoff instead. **First move of the next session: get his confirm (or corrections), then write the build plan.** Agreed intent: the plan lands as `docs/plans/0001-bootstrap-engineering-skills.md` in the workspace repo, dogfooding the artifact conventions from line one. After the plan is approved, execute: import and rewire the curated skills, write `/how` and `README.md` with the provenance table, then install them with `npx skills`.

## Suggested skills

- `writing-plans` (superpowers) — for authoring the bootstrap plan itself.
- `writing-for-agents` (mattpocock) — governs documents written for agents, including `/how`, skill descriptions, and frontmatter.
- `grilling` — if new decisions surface mid-build, grill them; **ask in plain prose, one question at a time, with a recommended answer — do not use the AskUserQuestion widget** (Jakub rejected it; see memory `grilling-in-prose.md`).
- `verification-before-completion` — before claiming the bootstrap done (it is the set's universal completion gate; apply it to its own birth).

## Working-style notes

- Jakub decides, one question at a time; look up facts yourself, only put *decisions* to him.
- He wants control at stage boundaries — never auto-chain, never auto-merge, don't "helpfully" do the next stage unasked.
