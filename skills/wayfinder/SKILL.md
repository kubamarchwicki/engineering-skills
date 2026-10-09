---
name: wayfinder
description: Plan a huge chunk of work (more than one agent session can hold) as a local Markdown map of decision tickets under docs/specs/, and resolve them one at a time until the way to the destination is clear.
disable-model-invocation: true
---

A loose idea has arrived, too big for one agent session, and wrapped in fog: the way from here to the **destination** isn't visible yet. Wayfinding is about finding that way, not charging at the destination. This skill charts the way as a **shared map** in the repo's Markdown files, then works its **decision tickets** (questions whose resolution is a decision, not slices of a build to execute) one at a time until the route is clear.

The destination varies per effort, and naming it is the first act of charting: it shapes every ticket. It might be a spec to hand off and iterate on, a decision to lock before planning starts, or a change made in place like a data-structure migration. The map is domain-agnostic: engineering work, course content, whatever fits the shape.

## Plan, don't do

Wayfinder is **planning**: each ticket resolves a decision, and the map is done when the way is clear, with nothing left to decide before someone goes and does the thing. The pull to just do the work is usually the signal you've reached the edge of the map and it's time to hand off. This is optional discovery before either the Light or Heavy track; the effort's **Notes** do not authorize production implementation. Keep findings local; commits, publication, merging, and worktree cleanup belong to the user.

## Refer by name

Every map and ticket is a Markdown file with a **name**: its title. In everything the human reads (narration, the map's Decisions-so-far), refer to it by that name, never by a bare id, number, or slug. A wall of `#42, #43, #44` is illegible; names read at a glance. A name wraps a relative link to the file; the path never stands in for the name.

## The Map

The map is `docs/specs/<effort>/map.md`, the canonical index for this effort. Its tickets are files under `docs/specs/<effort>/decisions/`; research notes and rough assets live under `docs/specs/<effort>/research/` and `docs/specs/<effort>/assets/`. Create directories only when needed. Use one effort directory per destination and reuse it when resuming.

The map is an **index**, not a store. It lists the decisions made and points at the tickets that hold their detail; the map never restates that detail, only gists it and links. If domain-modeling records a term in `GLOSSARY.md` or a durable decision in `docs/adr/`, the ticket links to that canonical source instead of copying it. Implementation plans remain numbered documents under `docs/plans/` in the Heavy track.

**Local file operations are defined below.** Read and update these Markdown files directly; this skill needs no external issue service or setup skill.

### The map body

The whole map at low resolution, loaded once per session. Open tickets are **not** listed: find them by scanning the metadata in `decisions/`.

```markdown
# <effort title>

## Destination

<what reaching the end of this map looks like: the spec, decision, or change this effort is finding its way to. One or two lines; every session orients to it before choosing a ticket.>

## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

<!-- the index: one line per closed ticket, enough to judge relevance, then zoom the link for the detail the ticket holds -->

- [<closed ticket title>](link): <one-line gist of the answer>

## Not yet specified

<!-- see "Fog of war": in-scope fog you can't ticket yet; graduates as the frontier advances -->

## Out of scope

<!-- see "Out of scope": work ruled beyond the destination; closed, never graduates -->
```

### Tickets

Each ticket is `decisions/NN-<slug>.md` relative to the map; its filename is its identity. Allocate the next unused number, starting at `01`, and preserve existing filenames. Its body is the question, sized to one 100K token agent session:

```markdown
# <decision title>

Type: grilling
Status: open
Claimed by: none
Blocked by: none

## Question

<the decision or investigation this ticket resolves>
```

Each ticket's `Type:` is one of `research`, `prototype`, `grilling`, `task` (see [Ticket Types](#ticket-types)). Its `Status:` is `open`, `claimed`, `resolved`, or `out-of-scope`. These are decision records, not an implementation queue.

A session **claims** a ticket by setting `Status: claimed` and `Claimed by: <session identifier>`, **first**, before any work. Re-read the metadata before claiming. An `open` ticket with `Claimed by: none` is unclaimed. Resume a claim only when it belongs to this session or the user explicitly reassigns it. If work stops unresolved, record progress and remaining questions, then release the claim by restoring `Status: open` and `Claimed by: none`.

`Blocked by:` contains `none` or a comma-separated list of exact ticket filenames in the same `decisions/` directory. A ticket is **unblocked** when every ticket blocking it has `Status: resolved`; the **frontier** is the open, unblocked, unclaimed tickets, ordered by number. Missing dependencies, dependency cycles, or an `out-of-scope` prerequisite require reconciling the questions and links before dependent work starts; they never count as resolved answers.

The answer is appended under `## Answer` on resolution (see [Work through the map](#work-through-the-map)). Assets created while resolving a ticket are linked from the ticket, not pasted in.

## Ticket Types

Every ticket is either **HITL** (human in the loop, worked _with_ a human who speaks for themselves) or **AFK**, driven by the agent alone. A HITL ticket only resolves through that live exchange; the agent never stands in for the human's side of it (a grilling agent that answers its own questions has broken this).

- **Research** (AFK): Reading documentation, third-party APIs, or local resources like knowledge bases to surface a fact a decision waits on. Call the Skill tool with "research", which dispatches a background agent, and assign its note a distinct path under `docs/specs/<effort>/research/`. The controller records the resolution after inspecting the findings. Use when knowledge outside the current working directory is required.
- **Prototype** (HITL): Raise the fidelity of the discussion by making a cheap, rough, concrete artifact to react to (an outline, a rough take, a stub, or UI/logic code) under `docs/specs/<effort>/assets/`. Agree the question and the experiment's bounds with the user, keep it separate from production implementation, and link it from the ticket. Resolve through the user's reaction to the artifact. Use when "how should it look" or "how should it behave" is the key question.
- **Grilling** (HITL): Conversation. The default case. Always call the Skill tool twice, for "grilling" and "domain-modeling".
- **Task** (HITL or AFK): Manual work that must happen before a _decision_ can be made: nothing to decide, prototype, or research, but the discussion is blocked until it's done. Signing up for a service so its API can be judged, provisioning access, moving data so its shape can be seen. This is the one type that _does_ rather than decides, and it earns its place by unblocking a decision, not by delivering the destination. The agent drives it alone where it can (AFK); otherwise it hands the human a precise checklist (HITL). Resolved when the work is done; the answer records what was done and any resulting facts (credentials location, new URLs, row counts) later tickets depend on.

## Fog of war

The map is _deliberately_ incomplete: don't chart what you can't yet see. Beyond the live tickets lies the **fog of war**: the dim view of decisions and investigations you can tell are coming but can't yet pin down, because they hang on questions still open. Resolving a ticket clears the fog ahead of it, graduating whatever's now specifiable into fresh tickets, one at a time, until the way to the destination is clear and no tickets remain.

The map's **Not yet specified** section is where that dim view is written down: the suspected question, the area to revisit later. It's the undiscovered frontier _toward_ the destination: everything here is in scope, just not sharp enough to ticket. Write as loosely or as fully as the view allows; it doubles as a signpost for collaborators reading where the effort is headed.

**Fog or ticket?** The test is whether you can state the question precisely now, _not_ whether you can answer it now.

- **Ticket when** the question is already sharp, even if it's blocked and you can't act on it yet.
- **Not yet specified when** you can't yet phrase it that sharply. Don't pre-slice the fog into ticket-sized pieces: it's coarser than a ticket, and one patch may graduate into several tickets, or none, once the frontier reaches it.

**Not yet specified** excludes what's already decided (Decisions so far), what's already a live ticket, and what's out of scope (the next section).

## Out of scope

Fog only ever gathers _toward_ the destination. The destination fixes the scope, so work beyond it is **out of scope**: it isn't fog, and it doesn't belong in **Not yet specified**. It gets its own **Out of scope** section on the map: work you've consciously ruled out of _this_ effort. Scope, not sharpness, lands it here.

Out-of-scope work never graduates (the frontier stops at the destination), so it returns only if the destination is redrawn, and then as a fresh effort, not a resumption.

Ruling something out of scope is a scoping act, not a step on the route. When a ticket that already exists turns out to sit past the destination (mis-scoped in while charting, or exposed by a resolution), set **`Status: out-of-scope`**, clear its claim, and record the reason in the ticket. Leave one line in the **Out of scope** section: the gist plus why it's out of scope, linking the ticket. It stays out of **Decisions so far**, which records the route actually walked; a scope boundary isn't a step on it. Reconcile any tickets that depended on it before choosing the next frontier.

## Invocation

Two modes. Either way, **never resolve more than one ticket per session**, with the exception of research tickets.

### Chart the map

User invokes with a loose idea.

1. **Name the destination.** Call the Skill tool twice, for "grilling" and "domain-modeling", to pin down what this map is finding its way to: the spec, decision, or change. The destination fixes the scope, so it's settled first.
2. **Map the frontier.** Grill again, **breadth-first** this time: fan out across the whole space rather than deep on any one thread, surfacing the open decisions and the first steps takeable now. **If this surfaces no fog** (the way to the destination is already clear, the whole journey small enough for one session), you don't need a map. Stop and ask the user how they'd like to proceed.
3. **Create the map** at `docs/specs/<effort>/map.md`: Destination and Notes filled in, Decisions-so-far empty, the fog sketched into **Not yet specified**.
4. **Create the tickets you can specify now** under `decisions/`, then wire `Blocked by:` dependencies in a **second pass** (files need names before they can reference each other). Write cross-references in that pass too, using real relative links. Wiring sorts them into the frontier and the blocked; everything you can't yet specify stays in the fog: the **Not yet specified** section.
5. **Fire the research subagents.** For each unblocked, unclaimed `research` ticket you just created, claim it and call the Skill tool with "research" within the available agent slots. Give each agent only its question, context pointers, and a distinct note path under `docs/specs/<effort>/research/`; agents write only their assigned notes. Keep the notes local on the current branch. The controller waits for the findings, inspects them, and records each answered ticket using the resolution and map-update steps below. If the evidence does not answer the question, record the limits and release the claim. Research never authorizes a non-research ticket or production implementation.
6. Stop: charting is one session's work; it hand-resolves nothing.

### Work through the map

User invokes with a map path. A ticket path or title is **optional**: without one, you pick the next decision, not the user.

1. Load the **map**: the low-res view, not every ticket body, and scan ticket metadata. If all tickets are resolved or out of scope and no fog remains, go to [Stop and hand off](#stop-and-hand-off). If no unresolved tickets remain but fog does, clarify it with the user and chart newly specifiable tickets before stopping.
2. Choose the ticket. If the user named one, use it only when it is unblocked and either unclaimed or claimed by this session; otherwise report its status and stop. Without a named ticket, take the first frontier ticket in order. **Claim it** before any work. If none is available, report the blockers or outstanding claims and stop; an empty frontier alone does not mean the map is complete.
3. Resolve it as the type its `Type:` field names (see [Ticket Types](#ticket-types)). Read the metadata, not just the question. **Zoom as needed**: read the full body of any related or resolved ticket on demand; call the Skill tool for model-invoked disciplines the `## Notes` block names. Notes naming a user-invoked stage are a handoff: name its command and stop. If in doubt, call the Skill tool twice, for "grilling" and "domain-modeling".
4. Record the resolution: append the answer and evidence links under **`## Answer`**, set **`Status: resolved`**, clear `Claimed by:` to `none`, and **append a context pointer** to the map's Decisions-so-far. For a HITL ticket, wait for the user's decision before recording it as resolved. Link canonical glossary terms and ADRs when domain-modeling creates them.
5. Add newly-surfaced tickets (create-then-wire); graduate any fog the answer has made specifiable, clearing each graduated patch from **Not yet specified** so it lives only as its new ticket. If the answer reveals that a ticket (this one or another) sits beyond the destination, **rule it out of scope** rather than resolving it on the route. If the decision invalidates other parts of the map, update affected open tickets and link replacement decisions from resolved tickets, preserving their recorded answers.

The controller alone edits the shared map and ticket metadata; research agents write their distinct notes. For separate concurrent sessions, the user assigns distinct ticket paths and coordinates shared-map writes. A local status field is not a lock across checkouts.

## Stop and hand off

After charting or working one ticket, stop. If open or claimed tickets or **Not yet specified** fog remain, report the next frontier and name `wayfinder` with the map path for a later session. The map is complete only when all tickets are resolved or out of scope and no fog remains.

When the route is clear, name the next command for the user's chosen track: `grill-me` for Light or `grill-with-docs` for Heavy. If no track has been chosen, recommend Light or Heavy based on the scope, ask the user to choose, and stop. Use `$skill-name` in Codex and `/skill-name` in Claude. The user invokes that command; do not start the next stage.
