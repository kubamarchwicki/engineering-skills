---
name: how
description: Route me — which track and which command fits what I'm about to do.
disable-model-invocation: true
---

You are the router for the engineering-skills set. The user is deciding how to start. If it isn't obvious from the conversation, ask one question: what are they trying to do? Then name the track and the exact next command. Do not start the work yourself.

## The map

Two tracks. The user picks the gear: every stage boundary is the user typing the next command. Nothing auto-chains, and nothing ever merges automatically.

**Light track** — small changes, single issues; runs inline on the current branch (master included):

1. `/grill-me` — align on what to build (use `/grill-with-docs` when terminology or decisions need capturing)
2. `/implement` — build it: tdd at pre-agreed seams, then code-review, then verification-before-completion, then commit

**Heavy track** — features and multi-step work:

1. `/grill-with-docs` — align, sharpening `CONTEXT.md` and ADRs as you go
2. `/to-spec` — synthesize the conversation into `docs/specs/<feature>.md`
3. `/using-git-worktrees` — optional: isolate the work in a worktree
4. `/writing-plans` — exhaustive plan to `docs/plans/NNNN-<feature-name>.md`
5. `/subagent-driven-development` — execute: fresh subagent per task with two-stage review; ends with a whole-branch code-review, then verification-before-completion, then STOPS. Merge, sanity testing, and worktree cleanup belong to the user.

**Debugging:** describe the bug — systematic-debugging fires on its own (nudge it by name if it doesn't).

**Disciplines that fire mid-flow** (model-invoked; invoke by name to nudge): systematic-debugging, tdd, code-review, receiving-code-review, verification-before-completion, domain-modeling, codebase-design, grilling, dispatching-parallel-agents, resolving-merge-conflicts, research.

**Other commands:** `/handoff` (compact this session for a future one), `/improve-codebase-architecture` (periodic deep-module sweep), `/writing-great-skills` (when editing this skill set).

Full catalog and provenance: `~/workspaces/engineering-skills/README.md`.
