# Repair and adjudication

Required when any of the four review concerns has a blocking finding: a
Critical/Important issue or a controller-confirmed real gap. Apply this
procedure for task repairs and breaker adjudication. For final review, use
its evidence, scoped re-review, and disposition rules with the one-wave cap
in SKILL.md; the five-round task schedule does not apply.

Before the loop starts, two routes leave it immediately:

- Record Minor findings in the progress ledger as you go
  (`Task <N>: minor (deferred): <one-liner>`), and point the final
  whole-branch review at that list so it can triage which must be fixed
  before merge. Defer only findings that do not invalidate accepted outcomes. A roll-up nobody reads is a silent discard. Minor findings
  never enter the loop.
- A finding labeled plan-mandated, or conflicting with the plan, requires
  receiving-code-review classification and investigation. A recorded ruling
  cannot override agreed outcomes or ADRs. Update routine details and evidence
  in the plan; obtain the user decision for behavior, ownership, or scope
  changes before affected work resumes.

Everything else enters the loop. A fix round is one fix dispatch plus one
scoped re-review. Five rounds maximum per task:

**Rounds 1-3 — resume the original implementer.** Send it the open findings
verbatim. Its context is intact: it knows the task, the code, and its own
choices. If your harness cannot send another message to a live subagent,
dispatch a fresh implementer carrying the brief path, the report-file path,
and the findings — the report file is the persistent memory either way.

**Rounds 4-5 — dispatch a fresh implementer on a more capable model** (per
Model Selection), with the brief path, the report-file path, the open
findings, and this framing: "A prior implementer attempted this task
[N] times; you own it now. Read the report file for what was tried." A loop
that survives three resumes usually means the implementer cannot see its
own problem — fresh eyes and a capability bump in one move.

**Every round, either way:** apply verification-before-completion evidence
validity. The implementer runs affected checks and required gates, reuses
applicable results, and appends covering Evidence Records (tested state,
commands, exit status, conditions, inspectable output, criteria, and limits)
to the report. Confirm this evidence before dispatching scoped re-review.
Name affected checks in the fix message; broaden only for concrete risk.

**The re-review is scoped.** Run `bash scripts/review-package PLAN_FILE FIX_BASE HEAD`
where FIX_BASE is the head the previous review saw, and dispatch
[re-review-prompt.md](re-review-prompt.md) with the findings list, the
brief, the report file, and the printed diff path. The re-reviewer verdicts
each finding ADDRESSED or NOT ADDRESSED and flags new breakage in the fix
diff only, reassessing the affected four conclusions. New Critical/Important
breakage in the fix diff joins the open findings list. Route out-of-scope
blocking or consequential discoveries to the controller for unresolved/decision
handling; they do not indefinitely expand fix review. Defer only non-blocking
observations that do not invalidate accepted outcomes.

**After each round,** append to the ledger:
`Task <N>: fix round <R>/5 (<X> addressed, <Y> open — <finding one-liners>; commits <a7>..<b7>)`

Never fix findings yourself in the controller session — your context stays
clean for coordination, and controller fixes skip review.

**The breaker.** When round 5's re-review still leaves findings open, stop
dispatching. Adjudicate each open finding yourself — you hold the plan and
the cross-task context the reviewer lacks:

- **Unsupported finding:** reject with inspectable evidence and record both sides.
- **Real non-blocking finding:** defer only if accepted outcomes remain valid;
  record the reason, evidence, and limits for final review.
- **Real blocking finding:** preserve it as unresolved. Affected work and its
  dependants cannot proceed or be marked complete. Investigate plan defects and
  obtain consequential user decisions; unrelated Ready work may continue.

The five-round cap ends repeated dispatch, never an acceptance requirement.
Record each disposition in the plan and ledger; silent discards are forbidden.
