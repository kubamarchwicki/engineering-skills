# Final Review and Finish

Part of subagent-driven-development. Every task in the plan is
complete.

After all tasks are complete, the controller MUST read and follow
[the final-review gates](../../verification-before-completion/FINAL-REVIEWS.md)
from the fixed Execution base. Complete test-audit and both Thermos reviews,
record their scope, reviewed state, findings, dispositions, proof, and limits
in the plan, and route blocking findings through the existing repair workflow.
Proceed only when tasks and all three gates are satisfied.

Then generate a package from the fixed Execution base including audit repairs.
The controller MUST call the Skill tool with "code-review" (or read and
follow its SKILL.md if the harness has no Skill tool), supplying that fixed
revision and the whole-branch review package. Run its Standards and Spec
reviewers on the most capable available model. Per-task reviews do not replace
this required skill invocation. Both final reviewers receive applicable
agreement, decision/source revisions,
acceptance evidence, the test-audit and both Thermos reports with dispositions,
and unresolved/deferred findings from the durable plan.
Require four supported conclusions: implementation correctness, design validity,
evidence quality, and scope and standards.

If findings remain, follow [fix-loop.md](fix-loop.md): dispatch ONE fix subagent with
the complete findings list and run exactly one scoped re-review of that wave
using FIX_BASE. Apply the breaker dispositions to residual findings. There is
no second fix wave; real blocking findings mean incomplete work. Report
unresolved work and consequential decisions to your human partner.

## Preserve evidence, assess gates, and stop

Before scratch cleanup, maintain this section in the plan:

```markdown
## Execution record
- Agreement baseline: [revision and document paths]
- Execution base: [fixed revision]
- Task refinements: [task, decision/source revision, finding, disposition, reason]
- Acceptance evidence: [criterion, command, exit status, tested state including
  relevant dirty changes, relevant conditions, output/stable reference, limits]
- Test audit: [scope, audited state, retained proof, findings/dispositions, limits]
- Thermos reviews: [each pass, scope, reviewed state, findings/dispositions, evidence, limits]
- Review conclusions: [four concerns, evidence, unresolved/deferred findings]
```

Preserve relevant output or sufficient inspectable summaries; links to
soon-deleted scratch are insufficient. Preserve additional logs where the
claim needs them. Commit agreed plan/evidence updates during task/fix
bookkeeping before deleting their only scratch source. Substantive decisions
follow ADR supersession. After scratch loss, recover from committed documents
and durable evidence, using git history and recorded baselines.

Apply verification-before-completion and assess accepted outcomes and required
gates against current applicable evidence before cleanup. Branch Ready requires
supported accepted outcomes and all required gates with no blocking gap.
Only then delete eligible scratch for this plan, leaving sibling workspaces
alone. Report actual completion, deferred limits, and unresolved work, and stop.
Merging, sanity testing, and Git-worktree cleanup belong to your human partner.
